package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.TransferApply;
import com.example.medical.service.TransferApplyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/transfer")
@CrossOrigin
@Validated
public class TransferApplyController {

    @Autowired
    private TransferApplyService transferApplyService;

    @PostMapping("/apply")
    public Result<?> submitApply(@Valid @RequestBody TransferApply apply, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        apply.setUserId(userId);
        if (transferApplyService.submitApply(apply)) {
            return Result.success("转院申请提交成功，状态为待审批");
        }
        return Result.error("转院申请提交失败");
    }

    @GetMapping("/my")
    public Result<?> getMyApplies(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        List<TransferApply> applies = transferApplyService.getMyApplies(userId);
        return Result.success(applies);
    }

    @GetMapping("/pending")
    public Result<?> getPendingApprovals() {
        List<TransferApply> pending = transferApplyService.getPendingApprovals();
        return Result.success(pending);
    }

    @PostMapping("/approve/{id}")
    public Result<?> approve(@PathVariable Long id, HttpServletRequest request) {
        Long approverId = (Long) request.getAttribute("userId");

        if (transferApplyService.approve(id, approverId)) {
            Map<String, Object> syncResult = transferApplyService.syncMedicalRecord(id);
            return Result.success(syncResult);
        }
        return Result.error("审批失败，申请不存在或状态不正确");
    }

    @PostMapping("/reject/{id}")
    public Result<?> reject(@PathVariable Long id, @RequestBody(required = false) Map<String, String> params, HttpServletRequest request) {
        Long approverId = (Long) request.getAttribute("userId");
        String remark = params != null ? params.getOrDefault("remark", "未说明原因") : "未说明原因";

        if (transferApplyService.reject(id, approverId, remark)) {
            return Result.success("已拒绝该转院申请");
        }
        return Result.error("拒绝失败，申请不存在或状态不正确");
    }

    @GetMapping("/history")
    public Result<?> getHistory(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        List<TransferApply> history = transferApplyService.getHistory(userId);
        return Result.success(history);
    }

    @GetMapping("/sync/{id}")
    public Result<?> syncMedicalRecord(@PathVariable Long id) {
        Map<String, Object> result = transferApplyService.syncMedicalRecord(id);
        if ((Boolean) result.getOrDefault("success", false)) {
            return Result.success(result);
        }
        return Result.error((String) result.get("message"));
    }
}
