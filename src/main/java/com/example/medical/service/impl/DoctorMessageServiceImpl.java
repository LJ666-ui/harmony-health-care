package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.DoctorMessage;
import com.example.medical.entity.User;
import com.example.medical.mapper.DoctorMessageMapper;
import com.example.medical.service.DoctorMessageService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class DoctorMessageServiceImpl extends ServiceImpl<DoctorMessageMapper, DoctorMessage> implements DoctorMessageService {

    @Autowired
    private UserService userService;

    private static final long CONVERSATION_TTL_MS = 48L * 60 * 60 * 1000;

    @Override
    public List<DoctorMessage> getConversation(Long userA, Long userB) {
        Date now = new Date();
        System.out.println("[getConversation] userA=" + userA + " userB=" + userB + " now=" + now);

        LambdaQueryWrapper<DoctorMessage> scanAll = new LambdaQueryWrapper<>();
        List<DoctorMessage> allRecords = this.list(scanAll);
        System.out.println("[getConversation] ===== 全表扫描 doctor_message 共 " + (allRecords != null ? allRecords.size() : 0) + " 条 =====");
        if (allRecords != null) {
            for (DoctorMessage m : allRecords) {
                System.out.println("  id=" + m.getId() + " sender=" + m.getSenderId()
                    + " receiver=" + m.getReceiverId() + " content=" + m.getContent()
                    + " createTime=" + m.getCreateTime() + " expireTime=" + m.getExpireTime()
                    + " isRead=" + m.getIsRead());
            }
        }
        System.out.println("[getConversation] ===== 全表扫描结束 =====");

        LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.eq(DoctorMessage::getSenderId, userA).eq(DoctorMessage::getReceiverId, userB))
            .or(w -> w.eq(DoctorMessage::getSenderId, userB).eq(DoctorMessage::getReceiverId, userA));
        wrapper.and(w -> w.gt(DoctorMessage::getExpireTime, now).or().isNull(DoctorMessage::getExpireTime));
        wrapper.orderByAsc(DoctorMessage::getCreateTime);
        return this.list(wrapper);
    }

    @Override
    public List<Map<String, Object>> getConversationList(Long userId) {
        Date now = new Date();
        LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.eq(DoctorMessage::getSenderId, userId))
            .or(w -> w.eq(DoctorMessage::getReceiverId, userId));
        wrapper.and(w -> w.gt(DoctorMessage::getExpireTime, now).or().isNull(DoctorMessage::getExpireTime));
        wrapper.orderByDesc(DoctorMessage::getCreateTime);
        List<DoctorMessage> allMessages = this.list(wrapper);

        Map<Long, DoctorMessage> latestMessageMap = new LinkedHashMap<>();
        Map<Long, Integer> unreadCountMap = new HashMap<>();
        Map<Long, Date> earliestTimeMap = new HashMap<>();

        for (DoctorMessage msg : allMessages) {
            Long otherUserId = msg.getSenderId().equals(userId) ? msg.getReceiverId() : msg.getSenderId();
            if (!latestMessageMap.containsKey(otherUserId)) {
                latestMessageMap.put(otherUserId, msg);
            }
            if (!earliestTimeMap.containsKey(otherUserId) || msg.getCreateTime().before(earliestTimeMap.get(otherUserId))) {
                earliestTimeMap.put(otherUserId, msg.getCreateTime());
            }
            if (msg.getReceiverId().equals(userId) && msg.getIsRead() == 0) {
                unreadCountMap.put(otherUserId, unreadCountMap.getOrDefault(otherUserId, 0) + 1);
            }
        }

        List<Map<String, Object>> conversations = new ArrayList<>();
        for (Map.Entry<Long, DoctorMessage> entry : latestMessageMap.entrySet()) {
            Long otherUserId = entry.getKey();
            DoctorMessage latestMsg = entry.getValue();

            Map<String, Object> conv = new HashMap<>();
            conv.put("otherUserId", otherUserId);
            conv.put("lastMessage", latestMsg.getContent());
            conv.put("lastTime", latestMsg.getCreateTime());
            conv.put("unreadCount", unreadCountMap.getOrDefault(otherUserId, 0));
            conv.put("expireTime", latestMsg.getExpireTime());

            Date earliest = earliestTimeMap.get(otherUserId);
            long remainMs = (latestMsg.getExpireTime() != null)
                ? latestMsg.getExpireTime().getTime() - now.getTime()
                : CONVERSATION_TTL_MS;
            conv.put("remainHours", Math.max(0, remainMs / (60 * 60 * 1000)));

            User otherUser = userService.getById(otherUserId);
            if (otherUser != null) {
                conv.put("otherUserName", otherUser.getUsername());
                conv.put("otherUserType", otherUser.getUserType());
            } else {
                conv.put("otherUserName", "未知用户");
                conv.put("otherUserType", 0);
            }

            conversations.add(conv);
        }

        return conversations;
    }

    @Override
    public boolean canDoctorSendMessage(Long doctorId, Long patientId) {
        User doctor = userService.getById(doctorId);
        if (doctor == null || doctor.getUserType() != 1) {
            return false;
        }
        Date now = new Date();
        LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DoctorMessage::getSenderId, patientId);
        wrapper.eq(DoctorMessage::getReceiverId, doctorId);
        wrapper.and(w -> w.gt(DoctorMessage::getExpireTime, now).or().isNull(DoctorMessage::getExpireTime));
        wrapper.last("LIMIT 1");
        return this.count(wrapper) > 0;
    }

    @Override
    public DoctorMessage sendMessageWithExpiry(Long senderId, Long receiverId, String content) {
        Date now = new Date();
        Date expireTime = new Date(now.getTime() + CONVERSATION_TTL_MS);

        DoctorMessage message = new DoctorMessage();
        message.setSenderId(senderId);
        message.setReceiverId(receiverId);
        message.setContent(content);
        message.setIsRead(0);
        message.setCreateTime(now);
        message.setExpireTime(expireTime);
        this.save(message);

        refreshConversationExpiry(senderId, receiverId);

        return message;
    }

    private void refreshConversationExpiry(Long userA, Long userB) {
        Date newExpiry = new Date(System.currentTimeMillis() + CONVERSATION_TTL_MS);
        LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.and(inner -> inner.eq(DoctorMessage::getSenderId, userA)
                    .eq(DoctorMessage::getReceiverId, userB))
                .or()
                .and(inner2 -> inner2.eq(DoctorMessage::getSenderId, userB)
                    .eq(DoctorMessage::getReceiverId, userA)));
        DoctorMessage update = new DoctorMessage();
        update.setExpireTime(newExpiry);
        this.update(update, wrapper);
    }

    @Override
    public int cleanupExpiredMessages() {
        Date now = new Date();
        LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.le(DoctorMessage::getExpireTime, now);
        return baseMapper.delete(wrapper);
    }
}
