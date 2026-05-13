package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthRecord;
import com.example.medical.entity.Nurse;
import com.example.medical.mapper.HealthRecordMapper;
import com.example.medical.service.HealthRecordService;
import com.example.medical.service.DataShareAuthService;
import com.example.medical.service.DataAccessLogService;
import com.example.medical.service.NursePatientRelationService;
import com.example.medical.service.NurseService;
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

    @Autowired
    private NursePatientRelationService nursePatientRelationService;

    @Autowired
    private NurseService nurseService;

    @Override
    public boolean addHealthRecord(HealthRecord healthRecord) {
        return save(healthRecord);
    }

    /**
     * 检查访问权限（支持多种角色）
     * 1. 用户自己访问自己的数据 → 通过
     * 2. 有data_share_auth授权记录 → 通过
     * 3. 护士通过nurse_patient_relation关系访问负责的患者 → 通过
     */
    private boolean checkAccessPermission(Long accessUserId, Long targetUserId) {
        if (accessUserId == null || targetUserId == null) {
            return false;
        }

        // 1. 自己访问自己的数据
        if (accessUserId.equals(targetUserId)) {
            return true;
        }

        // 2. 检查data_share_auth表的显式授权
        if (dataShareAuthService.checkAuth(accessUserId, targetUserId, "health_record")) {
            return true;
        }

        // 3. 护士通过护患关系访问患者数据
        // accessUserId 现在是 user 表的 ID，需要先查找对应的 nurse 记录
        try {
            Nurse nurse = nurseService.lambdaQuery()
                    .eq(Nurse::getUserId, accessUserId)
                    .last("LIMIT 1")
                    .one();
            
            if (nurse != null && nurse.getId() != null) {
                Long nurseId = nurse.getId();
                List<Long> patientIds = nursePatientRelationService.getPatientIdsByNurseId(nurseId);
                if (patientIds != null && !patientIds.isEmpty() && patientIds.contains(targetUserId)) {
                    return true;
                }
            }
        } catch (Exception e) {
            // 忽略异常，继续后续检查
        }

        return false;
    }

    @Override
    public List<HealthRecord> findByUserId(Long userId, Long accessUserId, String accessIp) {
        if (!checkAccessPermission(accessUserId, userId)) {
            throw new RuntimeException("无权限访问该用户的健康记录");
        }

        dataAccessLogService.recordAccessLog(userId, accessUserId, "health_record", null, 1, accessIp);

        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .list();
    }

    @Override
    public List<HealthRecord> findByUserIdAndTimeRange(Long userId, Date startTime, Date endTime, Long accessUserId, String accessIp) {
        if (!checkAccessPermission(accessUserId, userId)) {
            throw new RuntimeException("无权限访问该用户的健康记录");
        }

        dataAccessLogService.recordAccessLog(userId, accessUserId, "health_record", null, 1, accessIp);

        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .ge(HealthRecord::getRecordTime, startTime)
                .le(HealthRecord::getRecordTime, endTime)
                .orderByDesc(HealthRecord::getRecordTime)
                .list();
    }

    @Override
    public PageResult<HealthRecord> findByUserIdWithPage(Long userId, Integer page, Integer size, Long accessUserId, String accessIp) {
        if (!checkAccessPermission(accessUserId, userId)) {
            throw new RuntimeException("无权限访问该用户的健康记录");
        }

        dataAccessLogService.recordAccessLog(userId, accessUserId, "health_record", null, 1, accessIp);

        Page<HealthRecord> pageInfo = new Page<>(page, size);
        
        pageInfo = lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .page(pageInfo);
        
        return new PageResult<>(pageInfo.getTotal(), pageInfo.getRecords(), page, size);
    }

    @Override
    public HealthRecord getLatestByUserId(Long userId) {
        return lambdaQuery()
                .eq(HealthRecord::getUserId, userId)
                .orderByDesc(HealthRecord::getRecordTime)
                .last("LIMIT 1")
                .one();
    }
}
