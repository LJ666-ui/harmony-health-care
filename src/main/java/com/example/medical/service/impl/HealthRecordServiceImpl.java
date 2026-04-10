package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.HealthRecord;
import com.example.medical.mapper.HealthRecordMapper;
import com.example.medical.service.HealthRecordService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class HealthRecordServiceImpl extends ServiceImpl<HealthRecordMapper, HealthRecord> implements HealthRecordService {
    @Override
    public List<HealthRecord> findByUserId(Long userId) {
        return lambdaQuery().eq(HealthRecord::getUserId, userId).orderByDesc(HealthRecord::getRecordTime).list();
    }

    @Override
    public List<HealthRecord> findByUserIdAndTimeRange(Long userId, Date startTime, Date endTime) {
        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .ge(HealthRecord::getRecordTime, startTime)
                .le(HealthRecord::getRecordTime, endTime)
                .orderByDesc(HealthRecord::getRecordTime)
                .list();
    }

    @Override
    public IPage<HealthRecord> findByUserIdWithPage(Long userId, Integer page, Integer size) {
        IPage<HealthRecord> pageInfo = new Page<>(page, size);
        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .page(pageInfo);
    }
}