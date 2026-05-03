package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.DoctorMessage;
import com.example.medical.entity.User;
import com.example.medical.service.DoctorMessageService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/user")
@CrossOrigin
@Validated
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private DoctorMessageService doctorMessageService;

    @PostMapping("/register")
    public Result<?> register(@Valid @RequestBody User user) {
        if (userService.findByUsername(user.getUsername()) != null) {
            return Result.error("用户名已存在");
        }
        if (user.getUserType() == null) {
            user.setUserType(0);
        }
        if (user.getUserType() == 1) {
            if (user.getRealName() == null || user.getRealName().trim().isEmpty()) {
                return Result.error("请填写真实姓名");
            }
            if (user.getHospital() == null || user.getHospital().trim().isEmpty()) {
                return Result.error("请填写所属医院");
            }
            if (user.getDepartment() == null || user.getDepartment().trim().isEmpty()) {
                return Result.error("请填写科室");
            }
            if (user.getLicenseNumber() == null || user.getLicenseNumber().trim().isEmpty()) {
                return Result.error("请填写执业证号");
            }
            if (user.getPhone() == null || user.getPhone().trim().isEmpty()) {
                return Result.error("请填写手机号");
            }
        }
        user.setPassword(BCryptUtil.encrypt(user.getPassword()));
        user.setCreateTime(new Date());
        user.setIsDeleted(0);
        if (userService.save(user)) {
            Map<String, Object> result = new HashMap<>();
            result.put("userId", user.getId());
            result.put("message", "注册成功");
            result.put("userType", user.getUserType());
            return Result.success(result);
        } else {
            return Result.error("注册失败");
        }
    }

    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody User user) {
        User dbUser = userService.findByUsername(user.getUsername());
        if (dbUser == null) {
            return Result.error("用户名不存在");
        }
        if (!BCryptUtil.matches(user.getPassword(), dbUser.getPassword())) {
            return Result.error("密码错误");
        }
        String token = JwtUtil.generateToken(dbUser.getId(), dbUser.getUsername());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userId", dbUser.getId());
        result.put("username", dbUser.getUsername());
        result.put("userType", dbUser.getUserType());
        return Result.success(result);
    }

    @GetMapping("/info")
    public Result<?> getUserInfo(@RequestParam Long id) {
        User user = userService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setPassword(null);
        return Result.success(user);
    }

    @PostMapping("/update")
    public Result<?> updateUser(@Valid @RequestBody User user) {
        if (userService.updateById(user)) {
            return Result.success("更新成功");
        } else {
            return Result.error("更新失败");
        }
    }

    @GetMapping("/doctor/list")
    public Result<List<User>> getDoctorList(@RequestParam(required = false) String keyword) {
        try {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getUserType, 1);
            wrapper.eq(User::getIsDeleted, 0);
            if (keyword != null && !keyword.isEmpty()) {
                final String kw = keyword.trim().toLowerCase();
                wrapper.and(w -> w.like(User::getUsername, kw)
                    .or()
                    .like(User::getPhone, kw));
            }
            wrapper.orderByDesc(User::getCreateTime);
            List<User> doctors = userService.list(wrapper);
            for (User doctor : doctors) {
                doctor.setPassword(null);
            }
            return Result.success(doctors);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取医生列表失败：" + e.getMessage());
        }
    }

    @PostMapping("/message/send")
    public Result<?> sendMessage(@RequestBody Map<String, Object> body) {
        try {
            long senderId = Long.parseLong(body.get("senderId").toString());
            long receiverId = Long.parseLong(body.get("receiverId").toString());
            String content = body.get("content") != null ? body.get("content").toString() : "";

            User sender = userService.getById(senderId);
            if (sender == null) {
                return Result.error("发送者不存在");
            }

            if (sender.getUserType() != null && sender.getUserType() == 1) {
                if (!doctorMessageService.canDoctorSendMessage(senderId, receiverId)) {
                    return Result.error("该患者尚未联系您，您无法主动发起对话");
                }
            }

            DoctorMessage message = doctorMessageService.sendMessageWithExpiry(senderId, receiverId, content);
            return Result.success(message);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("发送消息失败：" + e.getMessage());
        }
    }

    @GetMapping("/message/history")
    public Result<?> getMessageHistory(@RequestParam Long userA, @RequestParam Long userB) {
        try {
            System.out.println("[getMessageHistory] userA=" + userA + " userB=" + userB);
            List<DoctorMessage> messages = doctorMessageService.getConversation(userA, userB);
            System.out.println("[getMessageHistory] 查询结果条数=" + (messages != null ? messages.size() : "null"));
            if (messages != null && !messages.isEmpty()) {
                for (DoctorMessage m : messages) {
                    System.out.println("  msg id=" + m.getId() + " sender=" + m.getSenderId()
                        + " receiver=" + m.getReceiverId() + " content=" + m.getContent()
                        + " expireTime=" + m.getExpireTime());
                }
            }
            LambdaQueryWrapper<DoctorMessage> readWrapper = new LambdaQueryWrapper<>();
            readWrapper.eq(DoctorMessage::getSenderId, userB);
            readWrapper.eq(DoctorMessage::getReceiverId, userA);
            readWrapper.eq(DoctorMessage::getIsRead, 0);
            DoctorMessage updateMsg = new DoctorMessage();
            updateMsg.setIsRead(1);
            doctorMessageService.update(updateMsg, readWrapper);
            return Result.success(messages);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取消息记录失败：" + e.getMessage());
        }
    }

    @GetMapping("/message/conversations")
    public Result<?> getConversations(@RequestParam Long userId) {
        try {
            List<Map<String, Object>> conversations = doctorMessageService.getConversationList(userId);
            return Result.success(conversations);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取会话列表失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/message/delete")
    public Result<?> deleteConversation(@RequestBody Map<String, Object> body) {
        try {
            long userA = Long.parseLong(body.get("userA").toString());
            long userB = Long.parseLong(body.get("userB").toString());
            LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
            wrapper.and(w -> w.eq(DoctorMessage::getSenderId, userA).eq(DoctorMessage::getReceiverId, userB))
                .or(w -> w.eq(DoctorMessage::getSenderId, userB).eq(DoctorMessage::getReceiverId, userA));
            if (doctorMessageService.remove(wrapper)) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除对话失败：" + e.getMessage());
        }
    }

    @GetMapping("/message/can-send")
    public Result<?> canSend(@RequestParam Long senderId, @RequestParam Long receiverId) {
        try {
            User sender = userService.getById(senderId);
            if (sender == null) {
                return Result.error("用户不存在");
            }
            boolean canSend = true;
            if (sender.getUserType() != null && sender.getUserType() == 1) {
                canSend = doctorMessageService.canDoctorSendMessage(senderId, receiverId);
            }
            Map<String, Object> result = new HashMap<>();
            result.put("canSend", canSend);
            result.put("userType", sender.getUserType());
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("检查权限失败：" + e.getMessage());
        }
    }

    @GetMapping("/doctor/patients")
    public Result<?> getDoctorPatients(@RequestParam Long doctorId) {
        try {
            User doctor = userService.getById(doctorId);
            if (doctor == null || doctor.getUserType() != 1) {
                return Result.error("非医生身份，无权访问");
            }
            List<Map<String, Object>> conversations = doctorMessageService.getConversationList(doctorId);
            return Result.success(conversations);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取患者列表失败：" + e.getMessage());
        }
    }

    @PostMapping("/message/cleanup")
    public Result<?> cleanupExpired() {
        try {
            int deleted = doctorMessageService.cleanupExpiredMessages();
            Map<String, Object> result = new HashMap<>();
            result.put("deletedCount", deleted);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("清理过期消息失败：" + e.getMessage());
        }
    }
}
