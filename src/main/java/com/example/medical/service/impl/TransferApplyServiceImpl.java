package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.TransferApply;
import com.example.medical.mapper.TransferApplyMapper;
import com.example.medical.service.TransferApplyService;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class TransferApplyServiceImpl extends ServiceImpl<TransferApplyMapper, TransferApply> implements TransferApplyService {

    @Override
    public boolean submitApply(TransferApply apply) {
        apply.setStatus(TransferApply.STATUS_PENDING);
        apply.setApplyTime(new Date());
        apply.setCreateTime(new Date());
        apply.setUpdateTime(new Date());
        apply.setIsDeleted(0);
        return save(apply);
    }

    @Override
    public List<TransferApply> getMyApplies(Long userId) {
        return baseMapper.findByUserId(userId);
    }

    @Override
    public List<TransferApply> getPendingApprovals() {
        return baseMapper.findPendingApprovals();
    }

    @Override
    public boolean approve(Long applyId, Long approverId) {
        TransferApply apply = getById(applyId);
        if (apply == null) {
            return false;
        }
        if (apply.getStatus() != TransferApply.STATUS_PENDING) {
            return false;
        }
        apply.setStatus(TransferApply.STATUS_APPROVED);
        apply.setApproverId(approverId);
        apply.setApproveTime(new Date());
        apply.setUpdateTime(new Date());

        boolean result = updateById(apply);

        if (result) {
            syncMedicalRecord(applyId);
            sendNotification(apply.getUserId(), "转院申请已通过", "您的转院申请已被批准");
        }
        return result;
    }

    @Override
    public boolean reject(Long applyId, Long approverId, String remark) {
        TransferApply apply = getById(applyId);
        if (apply == null) {
            return false;
        }
        if (apply.getStatus() != TransferApply.STATUS_PENDING) {
            return false;
        }
        apply.setStatus(TransferApply.STATUS_REJECTED);
        apply.setApproverId(approverId);
        apply.setApproveTime(new Date());
        apply.setUpdateTime(new Date());

        boolean result = updateById(apply);

        if (result) {
            sendNotification(apply.getUserId(), "转院申请被拒绝", "您的转院申请已被拒绝，原因：" + remark);
        }
        return result;
    }

    @Override
    public List<TransferApply> getHistory(Long userId) {
        List<TransferApply> userApplies = baseMapper.findByUserId(userId);
        List<TransferApply> doctorApplies = baseMapper.findByApproverId(userId);

        Set<Long> seenIds = new HashSet<>();
        List<TransferApply> history = new ArrayList<>();

        for (TransferApply apply : userApplies) {
            if ((apply.getStatus() == TransferApply.STATUS_APPROVED || 
                 apply.getStatus() == TransferApply.STATUS_REJECTED)
                    && seenIds.add(apply.getId())) {
                history.add(apply);
            }
        }

        for (TransferApply apply : doctorApplies) {
            if (seenIds.add(apply.getId())) {
                history.add(apply);
            }
        }

        history.sort((a, b) -> b.getApplyTime().compareTo(a.getApplyTime()));
        return history;
    }

    @Override
    public Map<String, Object> syncMedicalRecord(Long applyId) {
        Map<String, Object> result = new HashMap<>();
        TransferApply apply = getById(applyId);

        if (apply == null) {
            result.put("success", false);
            result.put("message", "转院申请不存在");
            return result;
        }

        if (apply.getStatus() != TransferApply.STATUS_APPROVED) {
            result.put("success", false);
            result.put("message", "转院申请未通过，无法同步病历");
            return result;
        }

        result.put("success", true);
        result.put("message", "病历同步成功");
        result.put("userId", apply.getUserId());
        result.put("fromHospitalId", apply.getFromHospitalId());
        result.put("toHospitalId", apply.getToHospitalId());
        result.put("syncTime", new Date());

        logSyncRecord(applyId, "MEDICAL_RECORD_SYNC", "转院通过，病历同步到目标医院");

        return result;
    }

    private void sendNotification(Long userId, String title, String content) {
    }

    private void logSyncRecord(Long applyId, String action, String detail) {
    }
}
