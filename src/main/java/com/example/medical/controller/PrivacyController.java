package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.DataAccessLog;
import com.example.medical.entity.DataShareAuth;
import com.example.medical.service.DataAccessLogService;
import com.example.medical.service.DataShareAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import org.springframework.format.annotation.DateTimeFormat;

@RestController
@RequestMapping("/privacy")
@CrossOrigin
public class PrivacyController {
    @Autowired
    private DataShareAuthService dataShareAuthService;

    @Autowired
    private DataAccessLogService dataAccessLogService;

    /**
     * 创建数据授权
     * @param authUserId 被授权用户ID（医生）
     * @param dataType 授权数据类型
     * @param authStartTime 授权开始时间
     * @param authEndTime 授权结束时间
     * @return 授权结果
     */
    @PostMapping("/createAuth")
    public Result<DataShareAuth> createAuth(
            @RequestParam Long authUserId,
            @RequestParam String dataType,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") Date authStartTime,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") Date authEndTime) {
        try {
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long userId = 1L;
            DataShareAuth auth = dataShareAuthService.createAuth(userId, authUserId, dataType, authStartTime, authEndTime);
            return Result.success(auth);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("创建授权失败：" + e.getMessage());
        }
    }

    /**
     * 撤销授权
     * @param authId 授权ID
     * @return 撤销结果
     */
    @PostMapping("/revokeAuth")
    public Result<Boolean> revokeAuth(@RequestParam Long authId) {
        try {
            boolean result = dataShareAuthService.revokeAuth(authId);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("撤销授权失败：" + e.getMessage());
        }
    }

    /**
     * 查询我的授权列表
     * @return 授权列表
     */
    @GetMapping("/myAuths")
    public Result<List<DataShareAuth>> getMyAuths() {
        try {
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long userId = 1L;
            List<DataShareAuth> auths = dataShareAuthService.getAuthList(userId, null, null);
            return Result.success(auths);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询授权列表失败：" + e.getMessage());
        }
    }

    /**
     * 查询谁访问过我的数据
     * @return 访问日志列表
     */
    @GetMapping("/accessLogs")
    public Result<List<DataAccessLog>> getAccessLogs() {
        try {
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long userId = 1L;
            List<DataAccessLog> logs = dataAccessLogService.getAccessLogsByUserId(userId);
            return Result.success(logs);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询访问日志失败：" + e.getMessage());
        }
    }

    /**
     * 校验是否有访问权限
     * @param targetUserId 目标用户ID
     * @param dataType 数据类型
     * @return 是否有访问权限
     */
    @GetMapping("/checkAuth")
    public Result<Boolean> checkAuth(
            @RequestParam Long targetUserId,
            @RequestParam String dataType) {
        try {
            // 假设当前登录用户ID为2（医生），实际项目中应该从JWT token中获取
            Long accessUserId = 2L;
            boolean hasAuth = dataShareAuthService.checkAuth(accessUserId, targetUserId, dataType);
            return Result.success(hasAuth);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("权限校验失败：" + e.getMessage());
        }
    }
}