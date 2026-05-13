package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.medical.common.BusinessException;
import com.example.medical.common.ResponseCode;
import com.example.medical.entity.SensitiveOperation;
import com.example.medical.mapper.SensitiveOperationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;

/**
 * 敏感操作确认服务类
 */
@Service
public class SensitiveOperationService {

    @Autowired
    private SensitiveOperationMapper sensitiveOperationMapper;

    /**
     * 发起敏感操作
     */
    public SensitiveOperation initiate(SensitiveOperation operation) {
        // 生成确认码
        String confirmationCode = generateConfirmationCode();
        
        // 设置初始状态
        operation.setStatus("pending_confirmation");
        operation.setConfirmationCode(confirmationCode);
        operation.setCreatedAt(LocalDateTime.now());
        
        // 保存操作
        sensitiveOperationMapper.insert(operation);
        return operation;
    }

    /**
     * 确认敏感操作
     */
    public SensitiveOperation confirm(Long id, String confirmationCode) {
        SensitiveOperation operation = sensitiveOperationMapper.selectById(id);
        if (operation == null) {
            throw new BusinessException(ResponseCode.SENSITIVE_OPERATION_NOT_FOUND);
        }
        
        if (!"pending_confirmation".equals(operation.getStatus())) {
            throw new BusinessException(ResponseCode.SENSITIVE_OPERATION_ALREADY_CONFIRMED);
        }
        
        if (!operation.getConfirmationCode().equals(confirmationCode)) {
            throw new BusinessException(ResponseCode.CONFIRMATION_CODE_ERROR);
        }
        
        // 更新状态
        operation.setStatus("confirmed");
        operation.setConfirmedAt(LocalDateTime.now());
        sensitiveOperationMapper.updateById(operation);
        
        return operation;
    }

    /**
     * 取消敏感操作
     */
    public SensitiveOperation cancel(Long id) {
        SensitiveOperation operation = sensitiveOperationMapper.selectById(id);
        if (operation == null) {
            throw new BusinessException(ResponseCode.SENSITIVE_OPERATION_NOT_FOUND);
        }
        
        if (!"pending_confirmation".equals(operation.getStatus())) {
            throw new BusinessException(ResponseCode.SENSITIVE_OPERATION_ALREADY_CANCELLED);
        }
        
        // 更新状态
        operation.setStatus("cancelled");
        sensitiveOperationMapper.updateById(operation);
        
        return operation;
    }

    /**
     * 获取操作详情
     */
    public SensitiveOperation getById(Long id) {
        return sensitiveOperationMapper.selectById(id);
    }

    /**
     * 获取用户的待确认操作列表
     */
    public java.util.List<SensitiveOperation> getPendingByUserId(Long userId) {
        QueryWrapper<SensitiveOperation> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        queryWrapper.eq("status", "pending_confirmation");
        queryWrapper.orderByDesc("created_at");
        
        return sensitiveOperationMapper.selectList(queryWrapper);
    }

    /**
     * 生成6位数字确认码
     */
    private String generateConfirmationCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }
}
