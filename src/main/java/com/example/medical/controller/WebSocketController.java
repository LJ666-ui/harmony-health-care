package com.example.medical.controller;

import com.example.medical.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.HashMap;
import java.util.Map;

/**
 * WebSocket消息控制器
 * 处理实时通信、聊天、通知等消息
 */
@Controller
public class WebSocketController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    /**
     * 处理聊天消息
     * @param sessionId 会话ID
     * @param message 消息内容
     * @return 消息响应
     */
    @MessageMapping("/chat/{sessionId}")
    @SendTo("/topic/chat/{sessionId}")
    public Map<String, Object> handleChatMessage(
            @DestinationVariable String sessionId,
            @Payload Map<String, Object> message) {
        
        // 添加时间戳
        message.put("timestamp", System.currentTimeMillis());
        message.put("sessionId", sessionId);
        
        return message;
    }

    /**
     * 发送私人消息
     * @param userId 用户ID
     * @param message 消息内容
     */
    @MessageMapping("/private/{userId}")
    public void sendPrivateMessage(
            @DestinationVariable String userId,
            @Payload Map<String, Object> message) {
        
        message.put("timestamp", System.currentTimeMillis());
        
        // 发送给特定用户
        messagingTemplate.convertAndSendToUser(
            userId, 
            "/queue/messages", 
            message
        );
    }

    /**
     * 发送紧急通知
     * @param notification 通知内容
     */
    @MessageMapping("/emergency")
    public void sendEmergencyNotification(@Payload Map<String, Object> notification) {
        
        notification.put("timestamp", System.currentTimeMillis());
        
        // 广播给所有订阅紧急通知的用户
        messagingTemplate.convertAndSend("/topic/emergency", notification);
        
        // 如果指定了接收者，也发送给特定用户
        if (notification.containsKey("recipients")) {
            Object recipients = notification.get("recipients");
            if (recipients instanceof java.util.List) {
                ((java.util.List<String>) recipients).forEach(userId -> {
                    messagingTemplate.convertAndSendToUser(
                        userId,
                        "/queue/emergency",
                        notification
                    );
                });
            }
        }
    }

    /**
     * 发送用药提醒
     * @param patientId 患者ID
     * @param reminder 提醒内容
     */
    @MessageMapping("/medication/{patientId}")
    public void sendMedicationReminder(
            @DestinationVariable String patientId,
            @Payload Map<String, Object> reminder) {
        
        reminder.put("timestamp", System.currentTimeMillis());
        reminder.put("patientId", patientId);
        
        // 发送给患者
        messagingTemplate.convertAndSendToUser(
            patientId,
            "/queue/medication",
            reminder
        );
        
        // 也广播到主题，供其他关注者订阅
        messagingTemplate.convertAndSend(
            "/topic/medication/" + patientId,
            reminder
        );
    }

    /**
     * 发送数据同步消息
     * @param userId 用户ID
     * @param syncData 同步数据
     */
    @MessageMapping("/sync/{userId}")
    public void handleDataSync(
            @DestinationVariable String userId,
            @Payload Map<String, Object> syncData) {
        
        syncData.put("timestamp", System.currentTimeMillis());
        
        // 发送给用户的其他设备
        messagingTemplate.convertAndSendToUser(
            userId,
            "/queue/sync",
            syncData
        );
    }

    /**
     * 用户加入会话
     * @param message 加入消息
     * @param headerAccessor 消息头访问器
     * @return 用户列表
     */
    @MessageMapping("/chat.join")
    @SendTo("/topic/users")
    public Map<String, Object> joinChat(
            @Payload Map<String, Object> message,
            SimpMessageHeaderAccessor headerAccessor) {
        
        // 保存用户信息到session
        String username = (String) message.get("username");
        String userId = (String) message.get("userId");
        
        headerAccessor.getSessionAttributes().put("username", username);
        headerAccessor.getSessionAttributes().put("userId", userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("type", "JOIN");
        response.put("username", username);
        response.put("userId", userId);
        response.put("timestamp", System.currentTimeMillis());
        
        return response;
    }

    /**
     * 用户离开会话
     * @param headerAccessor 消息头访问器
     * @return 用户列表
     */
    @MessageMapping("/chat.leave")
    @SendTo("/topic/users")
    public Map<String, Object> leaveChat(SimpMessageHeaderAccessor headerAccessor) {
        
        String username = (String) headerAccessor.getSessionAttributes().get("username");
        String userId = (String) headerAccessor.getSessionAttributes().get("userId");
        
        Map<String, Object> response = new HashMap<>();
        response.put("type", "LEAVE");
        response.put("username", username);
        response.put("userId", userId);
        response.put("timestamp", System.currentTimeMillis());
        
        return response;
    }

    /**
     * 输入状态通知
     * @param sessionId 会话ID
     * @param typingInfo 输入信息
     */
    @MessageMapping("/typing/{sessionId}")
    @SendTo("/topic/typing/{sessionId}")
    public Map<String, Object> notifyTyping(
            @DestinationVariable String sessionId,
            @Payload Map<String, Object> typingInfo) {
        
        typingInfo.put("timestamp", System.currentTimeMillis());
        return typingInfo;
    }
}
