package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthFood;

public interface HealthFoodService extends IService<HealthFood> {
    /**
     * 分页查询健康食材
     * @param page 当前页
     * @param pageSize 每页条数
     * @param foodName 食材名称（可选）
     * @param applicableDisease 适用病症（可选）
     * @param dietTherapy 食疗作用（可选）
     * @param efficacy 功效（可选）
     * @param dietaryTaboo 饮食禁忌（可选）
     * @return 分页结果
     */
    PageResult<HealthFood> pageQuery(int page, int pageSize, String foodName, String applicableDisease, String dietTherapy, String efficacy, String dietaryTaboo);

    /**
     * 根据ID查询食材详情
     * @param id 食材ID
     * @return 食材详情
     */
    HealthFood getById(Long id);

    /**
     * 按适用病症模糊筛选
     * @param applicableDisease 适用病症
     * @return 符合条件的食材列表
     */
    java.util.List<HealthFood> listByApplicableDisease(String applicableDisease);
}