package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.HealthRecord;
import com.example.medical.entity.HealthStandard;
import com.example.medical.entity.RiskAssess;
import com.example.medical.entity.User;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public interface RiskAssessService extends IService<RiskAssess> {
    /**
     * 评估用户的健康风险
     * @param userId 用户ID
     * @return 风险评估结果
     */
    RiskAssess assessRisk(Long userId);

    /**
     * 计算综合风险等级
     * @param score 总分
     * @return 风险等级 (0=低, 1=中, 2=高)
     */
    int calculateTotalRisk(int score);

    /**
     * 评估高血压风险
     * @param bloodPressure 血压值 (格式: "收缩压/舒张压")
     * @return 风险等级 (0=低, 1=中, 2=高)
     */
    int assessHypertensionRisk(String bloodPressure);

    /**
     * 评估糖尿病风险（默认空腹血糖）
     * @param bloodSugar 血糖值
     * @return 风险等级
     */
    int assessDiabetesRisk(BigDecimal bloodSugar);

    /**
     * 评估糖尿病风险，支持选择血糖类型
     * @param bloodSugar 血糖值
     * @param bloodSugarType 血糖类型（"空腹血糖"或"餐后2小时血糖"）
     * @return 风险等级
     */
    int assessDiabetesRisk(BigDecimal bloodSugar, String bloodSugarType);

    /**
     * 评估跌倒风险
     * @param age 年龄
     * @return 风险等级 (0=低, 1=中, 2=高)
     */
    int assessFallRisk(int age);

    /**
     * 评估衰弱风险
     * @param age 年龄
     * @param sleepDuration 睡眠时长
     * @param stepCount 步数
     * @return 风险等级 (0=低, 1=中, 2=高)
     */
    int assessFrailtyRisk(int age, BigDecimal sleepDuration, Integer stepCount);

    /**
     * 评估肌少症风险
     * @param age 年龄
     * @param weight 体重
     * @param height 身高
     * @return 风险等级 (0=低, 1=中, 2=高)
     */
    int assessSarcopeniaRisk(int age, BigDecimal weight, BigDecimal height);
}
