package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.RiskAssess;
import com.example.medical.service.RiskAssessService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/risk")
public class RiskAssessController {

    @Autowired
    private RiskAssessService riskAssessService;

    /**
     * 评估用户健康风险
     * @param userId 用户ID
     * @return 风险评估结果
     */
    @PostMapping("/assess/{userId}")
    public RiskAssess assessRisk(@PathVariable Long userId) {
        return riskAssessService.assessRisk(userId);
    }

    /**
     * 获取用户的风险评估记录列表（分页）
     * @param userId 用户ID
     * @param page 页码
     * @param size 每页数量
     * @return 分页的评估记录
     */
    @GetMapping("/list/{userId}")
    public Page<RiskAssess> listByUserId(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Page<RiskAssess> pageInfo = new Page<>(page, size);
        QueryWrapper<RiskAssess> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                .orderByDesc("assess_time");
        return riskAssessService.page(pageInfo, queryWrapper);
    }

    /**
     * 获取最新的风险评估记录
     * @param userId 用户ID
     * @return 最新的评估记录
     */
    @GetMapping("/latest/{userId}")
    public RiskAssess getLatestAssess(@PathVariable Long userId) {
        QueryWrapper<RiskAssess> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId)
                .orderByDesc("assess_time")
                .last("LIMIT 1");
        return riskAssessService.getOne(queryWrapper);
    }

    /**
     * 获取单个风险评估记录
     * @param id 评估记录ID
     * @return 评估记录
     */
    @GetMapping("/get/{id}")
    public RiskAssess getAssess(@PathVariable Long id) {
        return riskAssessService.getById(id);
    }

    /**
     * 删除风险评估记录
     * @param id 评估记录ID
     * @return 是否删除成功
     */
    @DeleteMapping("/delete/{id}")
    public boolean deleteAssess(@PathVariable Long id) {
        return riskAssessService.removeById(id);
    }

}
