package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.EmergencyNotification;
import com.example.medical.mapper.EmergencyNotificationMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 紧急通知服务类
 */
@Service
public class EmergencyNotificationService extends ServiceImpl<EmergencyNotificationMapper, EmergencyNotification> {
    
    /**
     * 创建紧急通知
     */
    public EmergencyNotification createEmergencyNotification(Map<String, Object> notificationData) {
        EmergencyNotification notification = new EmergencyNotification();
        
        notification.setType((String) notificationData.get("type"));
        notification.setPatientId(Long.valueOf(notificationData.get("patientId").toString()));
        notification.setPatientName((String) notificationData.get("patientName"));
        notification.setSeverity((String) notificationData.get("severity"));
        notification.setTitle((String) notificationData.get("title"));
        notification.setContent((String) notificationData.get("content"));
        notification.setCreatedAt(new java.util.Date());
        
        // 处理生命体征
        Map<String, Object> vitalSigns = (Map<String, Object>) notificationData.get("vitalSigns");
        if (vitalSigns != null) {
            if (vitalSigns.get("heartRate") != null) {
                notification.setHeartRate(Integer.valueOf(vitalSigns.get("heartRate").toString()));
            }
            notification.setBloodPressure((String) vitalSigns.get("bloodPressure"));
            if (vitalSigns.get("temperature") != null) {
                notification.setTemperature(Double.valueOf(vitalSigns.get("temperature").toString()));
            }
            if (vitalSigns.get("bloodOxygen") != null) {
                notification.setBloodOxygen(Integer.valueOf(vitalSigns.get("bloodOxygen").toString()));
            }
        }
        
        // 处理位置信息
        Map<String, Object> location = (Map<String, Object>) notificationData.get("patientLocation");
        if (location != null) {
            if (location.get("latitude") != null) {
                notification.setPatientLatitude(Double.valueOf(location.get("latitude").toString()));
            }
            if (location.get("longitude") != null) {
                notification.setPatientLongitude(Double.valueOf(location.get("longitude").toString()));
            }
            notification.setPatientAddress((String) location.get("address"));
        }
        
        notification.setMedicalSummary((String) notificationData.get("medicalSummary"));
        
        this.save(notification);
        return notification;
    }
    
    /**
     * 获取紧急通知接收者列表
     */
    public List<String> getEmergencyRecipients(Long patientId) {
        // TODO: 查询患者的护士、医生、家属
        // 这里返回示例数据
        List<String> recipients = new ArrayList<>();
        recipients.add("nurse1");
        recipients.add("doctor1");
        recipients.add("family1");
        return recipients;
    }
    
    /**
     * 获取用户的紧急通知列表
     */
    public List<EmergencyNotification> getUserEmergencyNotifications(String userId) {
        // TODO: 查询用户相关的紧急通知
        return this.list();
    }
    
    /**
     * 根据ID获取紧急通知
     */
    public EmergencyNotification getEmergencyNotificationById(String notificationId) {
        return this.getById(Long.valueOf(notificationId));
    }
    
    /**
     * 处理紧急通知
     */
    public void handleEmergencyNotification(String notificationId, Map<String, Object> confirmData) {
        EmergencyNotification notification = this.getById(Long.valueOf(notificationId));
        if (notification != null) {
            notification.setHandledBy(Long.valueOf(confirmData.get("handlerId").toString()));
            notification.setHandledAt(new java.util.Date());
            this.updateById(notification);
        }
    }
    
    /**
     * 获取用户通知列表
     */
    public List<Map<String, Object>> getUserNotifications(String userId, Map<String, Object> params) {
        // TODO: 实现通知查询逻辑
        return new ArrayList<>();
    }
    
    /**
     * 创建普通通知
     */
    public Map<String, Object> createNotification(Map<String, Object> notificationData) {
        // TODO: 实现通知创建逻辑
        return notificationData;
    }
    
    /**
     * 标记通知已读
     */
    public void markAsRead(String notificationId) {
        // TODO: 实现已读标记逻辑
    }
    
    /**
     * 标记所有通知已读
     */
    public void markAllAsRead(String userId) {
        // TODO: 实现全部已读逻辑
    }
    
    /**
     * 删除通知
     */
    public void deleteNotification(String notificationId) {
        // TODO: 实现删除逻辑
    }
    
    /**
     * 获取未读通知数量
     */
    public int getUnreadCount(String userId) {
        // TODO: 实现未读计数逻辑
        return 0;
    }
}
