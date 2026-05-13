package com.example.medical.controller;

import com.example.medical.common.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 个人中心控制器
 * 提供个人中心页面所需的数据接口
 */
@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    /**
     * 获取轮播图列表
     * @return 轮播图数据列表
     */
    @GetMapping("/banner/list")
    public Result<List<Map<String, Object>>> getBannerList() {
        List<Map<String, Object>> banners = new ArrayList<>();
        
        // 示例数据
        Map<String, Object> banner1 = new HashMap<>();
        banner1.put("id", 1);
        banner1.put("title", "健康生活小贴士");
        banner1.put("image", "https://example.com/banner1.jpg");
        banner1.put("url", "/pages/HealthTips");
        banners.add(banner1);
        
        Map<String, Object> banner2 = new HashMap<>();
        banner2.put("id", 2);
        banner2.put("title", "春季养生指南");
        banner2.put("image", "https://example.com/banner2.jpg");
        banner2.put("url", "/pages/SeasonalHealth");
        banners.add(banner2);
        
        Map<String, Object> banner3 = new HashMap<>();
        banner3.put("id", 3);
        banner3.put("title", "在线问诊服务");
        banner3.put("image", "https://example.com/banner3.jpg");
        banner3.put("url", "/pages/OnlineConsultation");
        banners.add(banner3);
        
        return Result.success(banners);
    }

    /**
     * 获取健康统计数据
     * @return 健康统计数据
     */
    @GetMapping("/healthStats")
    public Result<Map<String, Object>> getHealthStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // 健康记录统计
        Map<String, Object> healthRecords = new HashMap<>();
        healthRecords.put("total", 15);
        healthRecords.put("thisMonth", 3);
        healthRecords.put("latestType", "血压测量");
        stats.put("healthRecords", healthRecords);
        
        // 预约统计
        Map<String, Object> appointments = new HashMap<>();
        appointments.put("upcoming", 2);
        appointments.put("completed", 8);
        appointments.put("cancelled", 1);
        stats.put("appointments", appointments);
        
        // 健康评分
        stats.put("healthScore", 85);
        stats.put("healthLevel", "良好");
        
        // 风险评估
        Map<String, Object> riskAssessment = new HashMap<>();
        riskAssessment.put("level", "低风险");
        riskAssessment.put("score", 92);
        riskAssessment.put("lastAssessDate", "2026-05-10");
        stats.put("riskAssessment", riskAssessment);
        
        // 康复计划
        Map<String, Object> rehabPlan = new HashMap<>();
        rehabPlan.put("active", 1);
        rehabPlan.put("completed", 3);
        rehabPlan.put("progress", 65);
        stats.put("rehabPlan", rehabPlan);
        
        // 用药提醒
        Map<String, Object> medication = new HashMap<>();
        medication.put("activeReminders", 2);
        medication.put("todayTaken", 1);
        medication.put("totalToday", 3);
        stats.put("medication", medication);
        
        return Result.success(stats);
    }
}
