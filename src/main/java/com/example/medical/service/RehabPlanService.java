package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.RehabPlan;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.RehabAction;

import java.util.List;
import java.util.Map;

public interface RehabPlanService extends IService<RehabPlan> {
    /**
     * 查询康复计划关联的动作
     * @param planId 康复计划ID
     * @return 动作列表
     */
    List<RehabAction> getPlanActions(Long planId);

    /**
     * 计算康复计划进度
     * @param planId 康复计划ID
     * @param userId 用户ID
     * @return 进度信息
     */
    Map<String, Object> calculatePlanProgress(Long planId, Long userId);

    /**
     * 个性化推荐康复计划
     * @param userId 用户ID
     * @param disease 疾病类型
     * @return 推荐的康复计划列表
     */
    List<RehabPlan> recommendPlans(Long userId, String disease);
}