package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.EmergencyNotification;
import com.example.medical.service.EmergencyNotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 紧急通知控制器
 * 处理紧急通知的发送、接收、确认等
 */
@RestController
@RequestMapping("/notifications")
@CrossOrigin
public class EmergencyNotificationController {

    @Autowired
    private EmergencyNotificationService notificationService;
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    /**
     * 发送紧急通知
     * @param notificationData 通知数据
     * @return 通知信息
     */
    @PostMapping("/emergency")
    public Result<EmergencyNotification> sendEmergencyNotification(
            @RequestBody Map<String, Object> notificationData) {
        try {
            // 创建紧急通知
            EmergencyNotification notification = notificationService.createEmergencyNotification(notificationData);
            
            // 获取接收者列表（护士、医生、家属）
            List<String> recipients = notificationService.getEmergencyRecipients(notification.getPatientId());
            
            // 并行推送给所有接收者
            for (String recipientId : recipients) {
                messagingTemplate.convertAndSendToUser(
                    recipientId,
                    "/queue/emergency",
                    notification
                );
            }
            
            // 也广播到紧急通知主题
            messagingTemplate.convertAndSend("/topic/emergency", notification);
            
            return Result.success(notification);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取紧急通知列表
     * @param userId 用户ID
     * @return 通知列表
     */
    @GetMapping("/emergency/user/{userId}")
    public Result<List<EmergencyNotification>> getUserEmergencyNotifications(@PathVariable String userId) {
        try {
            List<EmergencyNotification> notifications = 
                notificationService.getUserEmergencyNotifications(userId);
            return Result.success(notifications);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取紧急通知详情
     * @param notificationId 通知ID
     * @return 通知详情
     */
    @GetMapping("/emergency/{notificationId}")
    public Result<EmergencyNotification> getEmergencyNotificationDetail(@PathVariable String notificationId) {
        try {
            EmergencyNotification notification = 
                notificationService.getEmergencyNotificationById(notificationId);
            return Result.success(notification);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 确认处理紧急通知
     * @param notificationId 通知ID
     * @param confirmData 确认数据
     * @return 操作结果
     */
    @PostMapping("/emergency/{notificationId}/handle")
    public Result<Void> handleEmergencyNotification(
            @PathVariable String notificationId,
            @RequestBody Map<String, Object> confirmData) {
        try {
            notificationService.handleEmergencyNotification(notificationId, confirmData);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取普通通知列表
     * @param userId 用户ID
     * @param params 查询参数
     * @return 通知列表
     */
    @GetMapping
    public Result<List<Map<String, Object>>> getNotifications(
            @RequestParam String userId,
            @RequestParam(required = false) Map<String, Object> params) {
        try {
            List<Map<String, Object>> notifications = 
                notificationService.getUserNotifications(userId, params);
            return Result.success(notifications);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 发送普通通知
     * @param notificationData 通知数据
     * @return 通知信息
     */
    @PostMapping
    public Result<Map<String, Object>> sendNotification(@RequestBody Map<String, Object> notificationData) {
        try {
            Map<String, Object> notification = notificationService.createNotification(notificationData);
            
            // 推送给接收者
            String receiverId = (String) notificationData.get("receiverId");
            messagingTemplate.convertAndSendToUser(
                receiverId,
                "/queue/notifications",
                notification
            );
            
            return Result.success(notification);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 标记通知已读
     * @param notificationId 通知ID
     * @return 操作结果
     */
    @PostMapping("/{notificationId}/read")
    public Result<Void> markAsRead(@PathVariable String notificationId) {
        try {
            notificationService.markAsRead(notificationId);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 标记所有通知已读
     * @param data 请求数据
     * @return 操作结果
     */
    @PostMapping("/read-all")
    public Result<Void> markAllAsRead(@RequestBody Map<String, String> data) {
        try {
            String userId = data.get("userId");
            notificationService.markAllAsRead(userId);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除通知
     * @param notificationId 通知ID
     * @return 操作结果
     */
    @DeleteMapping("/{notificationId}")
    public Result<Void> deleteNotification(@PathVariable String notificationId) {
        try {
            notificationService.deleteNotification(notificationId);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取未读通知数量
     * @param userId 用户ID
     * @return 未读数量
     */
    @GetMapping("/unread-count")
    public Result<Integer> getUnreadCount(@RequestParam String userId) {
        try {
            int count = notificationService.getUnreadCount(userId);
            return Result.success(count);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
