package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.common.HealthCheckResult;
import com.example.medical.entity.HealthStandard;

import java.util.List;

public interface HealthStandardService extends IService<HealthStandard> {
    /**
     * 根据指标名称和数值判断是否在正常范围
     * @param indicatorName 指标名称
     * @param value 检测数值
     * @return 检测结果
     */
    HealthCheckResult checkIndicator(String indicatorName, double value);
    
    /**
     * 查询所有健康指标标准
     * @return 指标列表
     */
    List<HealthStandard> getAllStandards();
    
    /**
     * 根据 ID 查询单个指标详情
     * @param id 指标 ID
     * @return 指标详情
     */
    HealthStandard getById(Long id);
    
    /**
     * 根据年龄段筛选指标
     * @param ageGroup 年龄段
     * @return 指标列表
     */
    List<HealthStandard> getByAgeGroup(String ageGroup);
    
    /**
     * 根据性别筛选指标
     * @param gender 性别：0=不限 1=男 2=女
     * @return 指标列表
     */
    List<HealthStandard> getByGender(Integer gender);
}