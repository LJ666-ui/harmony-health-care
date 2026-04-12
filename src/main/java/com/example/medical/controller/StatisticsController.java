package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.service.SysStatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.Map;
import org.springframework.format.annotation.DateTimeFormat;

@RestController
@RequestMapping("/statistics")
@CrossOrigin
public class StatisticsController {
    @Autowired
    private SysStatisticsService sysStatisticsService;

    /**
     * 首页系统统计
     * @return 系统统计数据
     */
    @GetMapping("/system")
    public Result<Map<String, Object>> getSystemStatistics() {
        try {
            Map<String, Object> statistics = sysStatisticsService.getSystemStatistics();
            return Result.success(statistics);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取系统统计数据失败：" + e.getMessage());
        }
    }

    /**
     * 个人7天健康趋势
     * @return 健康趋势数据
     */
    @GetMapping("/personal/trend")
    public Result<Map<String, Object>> getPersonalHealthTrend() {
        try {
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long userId = 1L;
            Map<String, Object> trend = sysStatisticsService.getPersonalHealthTrend(userId);
            return Result.success(trend);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取个人健康趋势失败：" + e.getMessage());
        }
    }

    /**
     * 个人30天统计汇总
     * @return 统计汇总数据
     */
    @GetMapping("/personal/summary")
    public Result<Map<String, Object>> getPersonal30DaySummary() {
        try {
            // 假设当前登录用户ID为1，实际项目中应该从JWT token中获取
            Long userId = 1L;
            Map<String, Object> summary = sysStatisticsService.getPersonal30DaySummary(userId);
            return Result.success(summary);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取个人统计汇总失败：" + e.getMessage());
        }
    }

    /**
     * 健康曲线完整数据
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 健康曲线数据
     */
    @GetMapping("/personal/curve")
    public Result<Map<String, Object>> getHealthCurveData(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate) {
        try {
            Map<String, Object> curveData = sysStatisticsService.getHealthCurveData(userId, startDate, endDate);
            return Result.success(curveData);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取健康曲线数据失败：" + e.getMessage());
        }
    }
}