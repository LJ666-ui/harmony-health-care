package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.DoctorMessage;

import java.util.List;
import java.util.Map;

public interface DoctorMessageService extends IService<DoctorMessage> {
    List<DoctorMessage> getConversation(Long userA, Long userB);
    List<Map<String, Object>> getConversationList(Long userId);
    boolean canDoctorSendMessage(Long doctorId, Long patientId);
    DoctorMessage sendMessageWithExpiry(Long senderId, Long receiverId, String content);
    int cleanupExpiredMessages();
}
