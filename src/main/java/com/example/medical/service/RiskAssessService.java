package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.dto.RiskAssessDTO;
import com.example.medical.entity.RiskAssess;

import java.math.BigDecimal;

public interface RiskAssessService extends IService<RiskAssess> {

    RiskAssess assessRisk(Long userId);

    RiskAssess assessRisk(Long userId, RiskAssessDTO dto);

    int calculateTotalRisk(int score);

    int assessHypertensionRisk(String bloodPressure);

    int assessDiabetesRisk(BigDecimal bloodSugar);

    int assessDiabetesRisk(BigDecimal bloodSugar, String bloodSugarType);

    int assessFallRisk(int age);

    int assessFrailtyRisk(int age, BigDecimal sleepDuration, Integer stepCount);

    int assessSarcopeniaRisk(int age, BigDecimal weight, BigDecimal height);
}
