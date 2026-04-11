package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthRecord;
import com.example.medical.mapper.HealthRecordMapper;
import com.example.medical.service.HealthRecordService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class HealthRecordServiceImpl extends ServiceImpl<HealthRecordMapper, HealthRecord> implements HealthRecordService {

    @Override
    public boolean addHealthRecord(HealthRecord healthRecord) {
        // 自动填充创建/更新时间（由MyBatis-Plus全局配置处理）
        // 保存到数据库
        return save(healthRecord);
    }

    @Override
    public List<HealthRecord> findByUserId(Long userId) {
        // 必须带上userId做数据隔离
        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .list();
    }

    @Override
    public List<HealthRecord> findByUserIdAndTimeRange(Long userId, Date startTime, Date endTime) {
        // 必须带上userId做数据隔离
        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .ge(HealthRecord::getRecordTime, startTime)
                .le(HealthRecord::getRecordTime, endTime)
                .orderByDesc(HealthRecord::getRecordTime)
                .list();
    }

    @Override
    public PageResult<HealthRecord> findByUserIdWithPage(Long userId, Integer page, Integer size) {
        // 构建分页对象
        Page<HealthRecord> pageInfo = new Page<>(page, size);
        
        // 必须带上userId做数据隔离
        pageInfo = lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .page(pageInfo);
        
        // 构建分页结果
        return new PageResult<>(pageInfo.getTotal(), pageInfo.getRecords(), page, size);
    }
}