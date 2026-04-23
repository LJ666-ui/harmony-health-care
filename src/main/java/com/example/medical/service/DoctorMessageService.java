package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.DoctorMessage;

import java.util.List;

public interface DoctorMessageService extends IService<DoctorMessage> {
    List<DoctorMessage> getConversation(Long userA, Long userB);
}
