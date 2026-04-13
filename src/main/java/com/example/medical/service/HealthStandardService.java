package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.HealthStandard;

import java.util.List;
import java.util.Map;

public interface HealthStandardService extends IService<HealthStandard> {
    /**
     * 检测指标是否在正常范围内
     * @param indicatorName 指标名称
     * @param value 指标值
     * @return 检测结果
     */
    Map<String, Object> checkIndicator(String indicatorName, double value);

    /**
     * 获取所有健康标准指标
     * @return 指标列表
     */
    List<HealthStandard> getAllStandards();

    /**
     * 按年龄组获取健康标准指标
     * @param ageGroup 年龄组
     * @return 指标列表
     */
    List<HealthStandard> getByAgeGroup(String ageGroup);

    /**
     * 按性别获取健康标准指标
     * @param gender 性别 (0=女, 1=男)
     * @return 指标列表
     */
    List<HealthStandard> getByGender(Integer gender);
}
