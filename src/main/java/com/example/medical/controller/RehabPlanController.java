package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.RehabAction;
import com.example.medical.entity.RehabPlan;
import com.example.medical.service.RehabPlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/rehab/plan")
public class RehabPlanController {

    @Autowired
    private RehabPlanService rehabPlanService;

    /**
     * 查询康复计划详情
     * @param id 康复计划ID
     * @return 康复计划详情
     */
    @GetMapping("/detail/{id}")
    public Result getPlanDetail(@PathVariable Long id) {
        RehabPlan plan = rehabPlanService.getById(id);
        if (plan == null) {
            return Result.error("康复计划不存在");
        }
        return Result.success(plan);
    }

    /**
     * 查询康复计划关联的动作
     * @param planId 康复计划ID
     * @return 动作列表
     */
    @GetMapping("/actions/{planId}")
    public Result getPlanActions(@PathVariable Long planId) {
        List<RehabAction> actions = rehabPlanService.getPlanActions(planId);
        return Result.success(actions);
    }

    /**
     * 计算康复计划进度
     * @param planId 康复计划ID
     * @param userId 用户ID
     * @return 进度信息
     */
    @GetMapping("/progress/{planId}")
    public Result calculatePlanProgress(
            @PathVariable Long planId,
            @RequestParam Long userId) {
        Map<String, Object> progress = rehabPlanService.calculatePlanProgress(planId, userId);
        return Result.success(progress);
    }

    /**
     * 个性化推荐康复计划
     * @param userId 用户ID
     * @param disease 疾病类型
     * @return 推荐的康复计划列表
     */
    @GetMapping("/recommend")
    public Result recommendPlans(
            @RequestParam Long userId,
            @RequestParam String disease) {
        List<RehabPlan> plans = rehabPlanService.recommendPlans(userId, disease);
        return Result.success(plans);
    }

    /**
     * 创建康复计划
     * @param plan 康复计划实体
     * @return 创建结果
     */
    @PostMapping("/create")
    public Result createPlan(@RequestBody RehabPlan plan) {
        plan.setIsDeleted(0);
        plan.setCreateTime(new Date());
        plan.setUpdateTime(new Date());
        boolean success = rehabPlanService.save(plan);
        if (success) {
            return Result.success("康复计划创建成功");
        } else {
            return Result.error("康复计划创建失败");
        }
    }

    /**
     * 更新康复计划
     * @param plan 康复计划实体
     * @return 更新结果
     */
    @PostMapping("/update")
    public Result updatePlan(@RequestBody RehabPlan plan) {
        plan.setUpdateTime(new Date());
        boolean success = rehabPlanService.updateById(plan);
        if (success) {
            return Result.success("康复计划更新成功");
        } else {
            return Result.error("康复计划更新失败");
        }
    }

    /**
     * 删除康复计划
     * @param id 康复计划ID
     * @return 删除结果
     */
    @PostMapping("/delete/{id}")
    public Result deletePlan(@PathVariable Long id) {
        RehabPlan plan = new RehabPlan();
        plan.setId(id);
        plan.setIsDeleted(1);
        plan.setUpdateTime(new Date());
        boolean success = rehabPlanService.updateById(plan);
        if (success) {
            return Result.success("康复计划删除成功");
        } else {
            return Result.error("康复计划删除失败");
        }
    }
}