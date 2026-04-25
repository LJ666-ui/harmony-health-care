package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.dto.RiskAssessDTO;
import com.example.medical.entity.RiskAssess;
import com.example.medical.service.RiskAssessService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/risk")
public class RiskAssessController {

    @Autowired
    private RiskAssessService riskAssessService;

    @PostMapping("/assess/{userId}")
    public Result<RiskAssess> assessRisk(@PathVariable Long userId, @RequestBody RiskAssessDTO dto) {
        try {
            RiskAssess result = riskAssessService.assessRisk(userId, dto);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("评估失败：" + e.getMessage());
        }
    }

    @GetMapping("/list/{userId}")
    public Result<Map<String, Object>> listByUserId(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Page<RiskAssess> pageInfo = new Page<>(page, size);
        QueryWrapper<RiskAssess> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                .orderByDesc("assess_time");
        Page<RiskAssess> result = riskAssessService.page(pageInfo, queryWrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("records", result.getRecords());
        data.put("total", result.getTotal());
        data.put("pages", result.getPages());
        data.put("current", result.getCurrent());
        return Result.success(data);
    }

    @GetMapping("/latest/{userId}")
    public Result<RiskAssess> getLatestAssess(@PathVariable Long userId) {
        QueryWrapper<RiskAssess> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                .orderByDesc("assess_time")
                .last("LIMIT 1");
        return Result.success(riskAssessService.getOne(queryWrapper));
    }

    @GetMapping("/get/{id}")
    public Result<RiskAssess> getAssess(@PathVariable Long id) {
        return Result.success(riskAssessService.getById(id));
    }

    @DeleteMapping("/delete/{id}")
    public Result<Boolean> deleteAssess(@PathVariable Long id) {
        return Result.success(riskAssessService.removeById(id));
    }
}
