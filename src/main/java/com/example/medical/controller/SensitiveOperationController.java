package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.SensitiveOperation;
import com.example.medical.service.SensitiveOperationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 敏感操作确认控制器
 */
@Tag(name = "敏感操作确认管理")
@RestController
@RequestMapping("/api/security")
public class SensitiveOperationController {

    @Autowired
    private SensitiveOperationService sensitiveOperationService;

    /**
     * 发起敏感操作
     */
    @Operation(summary = "发起敏感操作")
    @PostMapping("/sensitive-operation")
    public Result<SensitiveOperation> initiate(@RequestBody SensitiveOperation operation) {
        SensitiveOperation result = sensitiveOperationService.initiate(operation);
        return Result.success(result);
    }

    /**
     * 确认敏感操作
     */
    @Operation(summary = "确认敏感操作")
    @PostMapping("/sensitive-operation/confirm")
    public Result<SensitiveOperation> confirm(@RequestParam Long operationId,
                                               @RequestParam String confirmationCode) {
        SensitiveOperation result = sensitiveOperationService.confirm(operationId, confirmationCode);
        return Result.success(result);
    }

    /**
     * 取消敏感操作
     */
    @Operation(summary = "取消敏感操作")
    @PostMapping("/sensitive-operation/cancel")
    public Result<SensitiveOperation> cancel(@RequestParam Long operationId) {
        SensitiveOperation result = sensitiveOperationService.cancel(operationId);
        return Result.success(result);
    }

    /**
     * 获取操作详情
     */
    @Operation(summary = "获取操作详情")
    @GetMapping("/sensitive-operation/{id}")
    public Result<SensitiveOperation> getById(@PathVariable Long id) {
        SensitiveOperation result = sensitiveOperationService.getById(id);
        return Result.success(result);
    }

    /**
     * 获取用户的待确认操作列表
     */
    @Operation(summary = "获取用户的待确认操作列表")
    @GetMapping("/sensitive-operation/user/{userId}/pending")
    public Result<List<SensitiveOperation>> getPendingByUserId(@PathVariable Long userId) {
        List<SensitiveOperation> result = sensitiveOperationService.getPendingByUserId(userId);
        return Result.success(result);
    }
}
