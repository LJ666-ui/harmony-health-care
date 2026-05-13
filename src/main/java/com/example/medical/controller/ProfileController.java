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

        Map<String, Object> banner1 = new HashMap<>();
        banner1.put("id", "1");
        banner1.put("icon", "💡");
        banner1.put("title", "健康生活小贴士");
        banner1.put("subtitle", "每日健康提醒，科学管理您的身体");
        banner1.put("ctaText", "立即查看");
        banner1.put("targetUrl", "pages/HealthPage");
        List<Map<String, Object>> colors1 = new ArrayList<>();
        Map<String, Object> c1a = new HashMap<>(); c1a.put("color", "#1677FF"); c1a.put("offset", 0);
        Map<String, Object> c1b = new HashMap<>(); c1b.put("color", "#36CFC9"); c1b.put("offset", 1);
        colors1.add(c1a); colors1.add(c1b);
        banner1.put("gradientColors", colors1);
        banners.add(banner1);

        Map<String, Object> banner2 = new HashMap<>();
        banner2.put("id", "2");
        banner2.put("icon", "🌸");
        banner2.put("title", "春季养生指南");
        banner2.put("subtitle", "顺应时节，调养身心");
        banner2.put("ctaText", "了解更多");
        banner2.put("targetUrl", "pages/HealthPage");
        List<Map<String, Object>> colors2 = new ArrayList<>();
        Map<String, Object> c2a = new HashMap<>(); c2a.put("color", "#52C41A"); c2a.put("offset", 0);
        Map<String, Object> c2b = new HashMap<>(); c2b.put("color", "#95DE64"); c2b.put("offset", 1);
        colors2.add(c2a); colors2.add(c2b);
        banner2.put("gradientColors", colors2);
        banners.add(banner2);

        Map<String, Object> banner3 = new HashMap<>();
        banner3.put("id", "3");
        banner3.put("icon", "🏥");
        banner3.put("title", "在线问诊服务");
        banner3.put("subtitle", "专业医生，随时咨询");
        banner3.put("ctaText", "开始问诊");
        banner3.put("targetUrl", "pages/MedicalPage");
        List<Map<String, Object>> colors3 = new ArrayList<>();
        Map<String, Object> c3a = new HashMap<>(); c3a.put("color", "#722ED1"); c3a.put("offset", 0);
        Map<String, Object> c3b = new HashMap<>(); c3b.put("color", "#B37FEB"); c3b.put("offset", 1);
        colors3.add(c3a); colors3.add(c3b);
        banner3.put("gradientColors", colors3);
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
        stats.put("healthRecordCount", 15);
        stats.put("collectCount", 8);
        stats.put("browseHistoryCount", 23);
        return Result.success(stats);
    }
}
