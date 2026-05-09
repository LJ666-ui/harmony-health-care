package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.FollowUp;

import java.util.List;

public interface FollowUpService extends IService<FollowUp> {

    List<FollowUp> getPatientFollowUps(Long patientId);

    FollowUp createFollowUp(FollowUp followUp);

    FollowUp updateFollowUpStatus(Long id, String status);
}
