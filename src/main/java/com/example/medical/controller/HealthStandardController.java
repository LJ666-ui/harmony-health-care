package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.HealthStandard;
import com.example.medical.service.HealthStandardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/healthStandard")
@CrossOrigin
public class HealthStandardController {

    @Autowired
    private HealthStandardService healthStandardService;

    /**
     * 指标检测接口
     */
    @GetMapping("/check")
    public Result<?> checkIndicator(
            @RequestParam String indicatorName,
            @RequestParam double value) {
        try {
            return Result.success(healthStandardService.checkIndicator(indicatorName, value));
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("指标检测失败：" + e.getMessage());
        }
    }

    /**
     * 全部指标列表接口
     */
    @GetMapping("/list")
    public Result<?> getAllStandards() {
        try {
            return Result.success(healthStandardService.getAllStandards());
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取指标列表失败：" + e.getMessage());
        }
    }

    /**
     * 指标详情接口
     */
    @GetMapping("/detail/{id}")
    public Result<?> getDetail(@PathVariable Long id) {
        try {
            HealthStandard standard = healthStandardService.getById(id);
            if (standard == null) {
                return Result.error("指标不存在");
            }
            return Result.success(standard);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取指标详情失败：" + e.getMessage());
        }
    }

    /**
     * 按年龄筛选接口
     */
    @GetMapping("/ageGroup")
    public Result<?> getByAgeGroup(@RequestParam String ageGroup) {
        try {
            return Result.success(healthStandardService.getByAgeGroup(ageGroup));
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("按年龄筛选指标失败：" + e.getMessage());
        }
    }

    /**
     * 按性别筛选接口
     */
    @GetMapping("/gender")
    public Result<?> getByGender(@RequestParam Integer gender) {
        try {
            return Result.success(healthStandardService.getByGender(gender));
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("按性别筛选指标失败：" + e.getMessage());
        }
    }
}