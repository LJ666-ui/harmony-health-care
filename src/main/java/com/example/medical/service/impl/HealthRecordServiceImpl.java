package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthRecord;
import com.example.medical.mapper.HealthRecordMapper;
import com.example.medical.service.HealthRecordService;
import com.example.medical.service.DataShareAuthService;
import com.example.medical.service.DataAccessLogService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class HealthRecordServiceImpl extends ServiceImpl<HealthRecordMapper, HealthRecord> implements HealthRecordService {
    @Autowired
    private DataShareAuthService dataShareAuthService;

    @Autowired
    private DataAccessLogService dataAccessLogService;

    @Override
    public boolean addHealthRecord(HealthRecord healthRecord) {
        // 自动填充创建/更新时间（由MyBatis-Plus全局配置处理）
        // 保存到数据库
        return save(healthRecord);
    }

    @Override
    public List<HealthRecord> findByUserId(Long userId, Long accessUserId, String accessIp) {
        // 数据授权校验
        if (!userId.equals(accessUserId)) {
            boolean hasAuth = dataShareAuthService.checkAuth(accessUserId, userId, "health_record");
            if (!hasAuth) {
                throw new RuntimeException("无权限访问该用户的健康记录");
            }
        }

        // 记录数据访问日志
        dataAccessLogService.recordAccessLog(userId, accessUserId, "health_record", null, 1, accessIp);

        // 必须带上userId做数据隔离
        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .list();
    }

    @Override
    public List<HealthRecord> findByUserIdAndTimeRange(Long userId, Date startTime, Date endTime, Long accessUserId, String accessIp) {
        // 数据授权校验
        if (!userId.equals(accessUserId)) {
            boolean hasAuth = dataShareAuthService.checkAuth(accessUserId, userId, "health_record");
            if (!hasAuth) {
                throw new RuntimeException("无权限访问该用户的健康记录");
            }
        }

        // 记录数据访问日志
        dataAccessLogService.recordAccessLog(userId, accessUserId, "health_record", null, 1, accessIp);

        // 必须带上userId做数据隔离
        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .ge(HealthRecord::getRecordTime, startTime)
                .le(HealthRecord::getRecordTime, endTime)
                .orderByDesc(HealthRecord::getRecordTime)
                .list();
    }

    @Override
    public PageResult<HealthRecord> findByUserIdWithPage(Long userId, Integer page, Integer size, Long accessUserId, String accessIp) {
        // 数据授权校验
        if (!userId.equals(accessUserId)) {
            boolean hasAuth = dataShareAuthService.checkAuth(accessUserId, userId, "health_record");
            if (!hasAuth) {
                throw new RuntimeException("无权限访问该用户的健康记录");
            }
        }

        // 记录数据访问日志
        dataAccessLogService.recordAccessLog(userId, accessUserId, "health_record", null, 1, accessIp);

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