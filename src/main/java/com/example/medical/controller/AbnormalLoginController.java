package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.AbnormalLogin;
import com.example.medical.service.AbnormalLoginService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Tag(name = "异常登录检测管理")
@RestController
@RequestMapping("/api/security")
public class AbnormalLoginController {

    @Autowired
    private AbnormalLoginService abnormalLoginService;

    @Operation(summary = "记录异常登录")
    @PostMapping("/abnormal-login")
    public Result<AbnormalLogin> record(@RequestBody AbnormalLogin abnormalLogin) {
        AbnormalLogin result = abnormalLoginService.record(abnormalLogin);
        return Result.success(result);
    }

    @Operation(summary = "获取异常登录列表")
    @GetMapping("/abnormal-logins")
    public Result<Page<AbnormalLogin>> getList(@RequestParam(required = false) Long userId,
                                                @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime startDate,
                                                @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime endDate,
                                                @RequestParam(defaultValue = "1") int page,
                                                @RequestParam(defaultValue = "10") int pageSize) {
        Page<AbnormalLogin> result = abnormalLoginService.getList(userId, startDate, endDate, page, pageSize);
        return Result.success(result);
    }

    @Operation(summary = "处理异常登录")
    @PutMapping("/abnormal-login/{id}/handle")
    public Result<AbnormalLogin> handle(@PathVariable Long id) {
        AbnormalLogin result = abnormalLoginService.handle(id);
        return Result.success(result);
    }

    @Operation(summary = "获取未处理的异常登录数量")
    @GetMapping("/abnormal-login/unhandled-count")
    public Result<Long> getUnhandledCount() {
        long result = abnormalLoginService.getUnhandledCount();
        return Result.success(result);
    }

    @Operation(summary = "获取高风险异常登录列表")
    @GetMapping("/abnormal-login/high-risk")
    public Result<List<AbnormalLogin>> getHighRiskList() {
        List<AbnormalLogin> result = abnormalLoginService.getHighRiskList();
        return Result.success(result);
    }
}
