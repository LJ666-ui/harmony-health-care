package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.HealthRecord;
import com.baomidou.mybatisplus.core.metadata.IPage;

import java.util.Date;
import java.util.List;

public interface HealthRecordService extends IService<HealthRecord> {
    List<HealthRecord> findByUserId(Long userId);
    List<HealthRecord> findByUserIdAndTimeRange(Long userId, Date startTime, Date endTime);
    IPage<HealthRecord> findByUserIdWithPage(Long userId, Integer page, Integer size);
}