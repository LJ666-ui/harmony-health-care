package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.DataAccessApplication;
import com.example.medical.service.DataAccessApplicationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 数据访问审批控制器
 */
@Tag(name = "数据访问审批管理")
@RestController
@RequestMapping("/api/security")
public class DataAccessApplicationController {

    @Autowired
    private DataAccessApplicationService dataAccessApplicationService;

    /**
     * 申请数据访问
     */
    @Operation(summary = "申请数据访问")
    @PostMapping("/data-access-apply")
    public Result<DataAccessApplication> apply(@RequestBody DataAccessApplication application) {
        DataAccessApplication result = dataAccessApplicationService.apply(application);
        return Result.success(result);
    }

    /**
     * 审批数据访问
     */
    @Operation(summary = "审批数据访问")
    @PostMapping("/data-access-approve")
    public Result<DataAccessApplication> approve(@RequestParam Long applicationId,
                                                  @RequestParam Long approverId,
                                                  @RequestParam boolean approved,
                                                  @RequestParam(required = false) String comment) {
        DataAccessApplication result = dataAccessApplicationService.approve(applicationId, approverId, approved, comment);
        return Result.success(result);
    }

    /**
     * 获取待审批列表
     */
    @Operation(summary = "获取待审批列表")
    @GetMapping("/data-access-pending")
    public Result<Page<DataAccessApplication>> getPendingList(@RequestParam(required = false) Long approverId,
                                                               @RequestParam(defaultValue = "1") int page,
                                                               @RequestParam(defaultValue = "10") int pageSize) {
        Page<DataAccessApplication> result = dataAccessApplicationService.getPendingList(approverId, page, pageSize);
        return Result.success(result);
    }

    /**
     * 获取申请详情
     */
    @Operation(summary = "获取申请详情")
    @GetMapping("/data-access/{id}")
    public Result<DataAccessApplication> getById(@PathVariable Long id) {
        DataAccessApplication result = dataAccessApplicationService.getById(id);
        return Result.success(result);
    }

    /**
     * 获取用户的申请列表
     */
    @Operation(summary = "获取用户的申请列表")
    @GetMapping("/data-access/user/{requesterId}")
    public Result<List<DataAccessApplication>> getByRequesterId(@PathVariable Long requesterId) {
        List<DataAccessApplication> result = dataAccessApplicationService.getByRequesterId(requesterId);
        return Result.success(result);
    }

    /**
     * 检查访问权限
     */
    @Operation(summary = "检查访问权限")
    @GetMapping("/data-access/check")
    public Result<Boolean> checkAccessPermission(@RequestParam Long requesterId,
                                                  @RequestParam String dataType,
                                                  @RequestParam Long dataId) {
        boolean result = dataAccessApplicationService.checkAccessPermission(requesterId, dataType, dataId);
        return Result.success(result);
    }
}
