package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.SysOperLog;
import com.example.medical.service.SysOperLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/log")
@CrossOrigin
public class LogController {
    @Autowired
    private SysOperLogService sysOperLogService;

    /**
     * 操作日志列表分页
     * @param page 页码
     * @param pageSize 每页条数
     * @return 操作日志列表
     */
    @GetMapping("/oper/list")
    public Result<List<SysOperLog>> getOperLogs(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            List<SysOperLog> logs = sysOperLogService.getOperLogs(page, pageSize);
            return Result.success(logs);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取操作日志失败：" + e.getMessage());
        }
    }

    /**
     * 查询单个用户的操作历史
     * @param userId 用户ID
     * @param page 页码
     * @param pageSize 每页条数
     * @return 操作日志列表
     */
    @GetMapping("/oper/user")
    public Result<List<SysOperLog>> getOperLogsByUserId(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            List<SysOperLog> logs = sysOperLogService.getOperLogsByUserId(userId, page, pageSize);
            return Result.success(logs);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取用户操作日志失败：" + e.getMessage());
        }
    }

    /**
     * 按时间范围查询操作日志
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param page 页码
     * @param pageSize 每页条数
     * @return 操作日志列表
     */
    @GetMapping("/oper/time")
    public Result<List<SysOperLog>> getOperLogsByTimeRange(
            @RequestParam Date startTime,
            @RequestParam Date endTime,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize) {
        try {
            List<SysOperLog> logs = sysOperLogService.getOperLogsByTimeRange(startTime, endTime, page, pageSize);
            return Result.success(logs);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取操作日志失败：" + e.getMessage());
        }
    }

    /**
     * 操作类型统计
     * @return 操作类型统计结果
     */
    @GetMapping("/oper/statistics")
    public Result<List<Object>> getOperTypeStatistics() {
        try {
            List<Object> statistics = sysOperLogService.getOperTypeStatistics();
            return Result.success(statistics);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取操作类型统计失败：" + e.getMessage());
        }
    }
}