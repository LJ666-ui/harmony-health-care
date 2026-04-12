package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.TransferApply;

import java.util.List;
import java.util.Map;

public interface TransferApplyService extends IService<TransferApply> {

    boolean submitApply(TransferApply apply);

    List<TransferApply> getMyApplies(Long userId);

    List<TransferApply> getPendingApprovals();

    boolean approve(Long applyId, Long approverId);

    boolean reject(Long applyId, Long approverId, String remark);

    List<TransferApply> getHistory(Long userId);

    Map<String, Object> syncMedicalRecord(Long applyId);
}
