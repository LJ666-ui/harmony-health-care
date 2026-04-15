package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.RehabAction;
import com.example.medical.entity.RehabPlan;
import com.example.medical.mapper.RehabPlanMapper;
import com.example.medical.service.RehabActionService;
import com.example.medical.service.RehabPlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class RehabPlanServiceImpl extends ServiceImpl<RehabPlanMapper, RehabPlan> implements RehabPlanService {

    @Autowired
    private RehabActionService rehabActionService;

    @Override
    public List<RehabAction> getPlanActions(Long planId) {
        QueryWrapper<RehabAction> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("plan_id", planId)
                .eq("is_deleted", 0)
                .orderByAsc("create_time");
        return rehabActionService.list(queryWrapper);
    }

    @Override
    public Map<String, Object> calculatePlanProgress(Long planId, Long userId) {
        // 查询计划关联的所有动作
        List<RehabAction> allActions = getPlanActions(planId);
        if (allActions.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("totalActions", 0);
            result.put("completedActions", 0);
            result.put("progress", 0);
            result.put("difficultyDistribution", new HashMap<>());
            return result;

        }

        // 模拟已完成动作（实际应从用户执行记录中查询）
        int completedCount = (int) (allActions.size() * new Random().nextDouble());

        // 统计难度分布
        Map<String, Long> difficultyDistribution = allActions.stream()
                .collect(Collectors.groupingBy(
                        rehabActionService::calculateDifficulty,
                        Collectors.counting()
                ));

        // 计算进度百分比
        double progress = (double) completedCount / allActions.size() * 100;

        Map<String, Object> result = new HashMap<>();
        result.put("totalActions", allActions.size());
        result.put("completedActions", completedCount);
        result.put("progress", Math.round(progress * 100) / 100.0);
        result.put("difficultyDistribution", difficultyDistribution);
        return result;
    }

    @Override
    public List<RehabPlan> recommendPlans(Long userId, String disease) {
        QueryWrapper<RehabPlan> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_deleted", 0)
                .eq("disease", disease)
                .orderByDesc("create_time");

        // 随机推荐3-5个计划
        List<RehabPlan> allPlans = this.list(queryWrapper);
        if (allPlans.size() <= 5) {
            return allPlans;
        }

        // 随机选择5个计划
        Collections.shuffle(allPlans);
        return allPlans.subList(0, 5);
    }
}