package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.dto.RiskAssessDTO;
import com.example.medical.entity.HealthRecord;
import com.example.medical.entity.HealthStandard;
import com.example.medical.entity.RiskAssess;
import com.example.medical.entity.User;
import com.example.medical.mapper.RiskAssessMapper;
import com.example.medical.service.HealthRecordService;
import com.example.medical.service.HealthStandardService;
import com.example.medical.service.RiskAssessService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Service
public class RiskAssessServiceImpl extends ServiceImpl<RiskAssessMapper, RiskAssess> implements RiskAssessService {

    @Autowired
    private UserService userService;

    @Autowired
    private HealthRecordService healthRecordService;

    @Autowired
    private HealthStandardService healthStandardService;

    private static final int RISK_SCORE_LOW = 85;
    private static final int RISK_SCORE_MID = 65;
    private static final int RISK_SCORE_HIGH = 35;

    @Override
    public RiskAssess assessRisk(Long userId) {
        User user = userService.getById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        QueryWrapper<HealthRecord> recordWrapper = new QueryWrapper<>();
        recordWrapper.eq("user_id", userId)
                .orderByDesc("record_time")
                .last("LIMIT 1");
        HealthRecord healthRecord = healthRecordService.getOne(recordWrapper);
        if (healthRecord == null) {
            throw new RuntimeException("用户健康记录不存在");
        }
        int hypertensionRisk = assessHypertensionRisk(healthRecord.getBloodPressure());
        int diabetesRisk = assessDiabetesRisk(healthRecord.getBloodSugar());
        int fallRisk = assessFallRisk(user.getAge() != null ? user.getAge() : 0);
        int frailtyRisk = assessFrailtyRisk(
                user.getAge() != null ? user.getAge() : 0,
                healthRecord.getSleepDuration(),
                healthRecord.getStepCount()
        );
        int sarcopeniaRisk = assessSarcopeniaRisk(
                user.getAge() != null ? user.getAge() : 0,
                healthRecord.getWeight(),
                healthRecord.getHeight()
        );
        int totalScore = 0;
        totalScore += hypertensionRisk == 1 ? 1 : (hypertensionRisk == 2 ? 2 : 0);
        totalScore += diabetesRisk == 1 ? 1 : (diabetesRisk == 2 ? 2 : 0);
        totalScore += fallRisk == 1 ? 1 : (fallRisk == 2 ? 2 : 0);
        totalScore += frailtyRisk == 1 ? 1 : (frailtyRisk == 2 ? 2 : 0);
        totalScore += sarcopeniaRisk == 1 ? 1 : (sarcopeniaRisk == 2 ? 2 : 0);
        int totalRisk = calculateTotalRisk(totalScore);
        RiskAssess riskAssess = new RiskAssess();
        riskAssess.setUserId(userId);
        riskAssess.setAssessTime(new Date());
        riskAssess.setHypertensionRisk(toScore(hypertensionRisk));
        riskAssess.setDiabetesRisk(toScore(diabetesRisk));
        riskAssess.setFallRisk(toScore(fallRisk));
        riskAssess.setFrailtyRisk(toScore(frailtyRisk));
        riskAssess.setSarcopeniaRisk(toScore(sarcopeniaRisk));
        riskAssess.setTotalRisk(toScore(totalRisk));
        riskAssess.setIsDeleted(0);
        String assessResult = generateAssessResult(
                hypertensionRisk, diabetesRisk, fallRisk, frailtyRisk, sarcopeniaRisk, totalRisk, totalScore
        );
        riskAssess.setAssessResult(assessResult);
        save(riskAssess);
        return riskAssess;
    }

    @Override
    public RiskAssess assessRisk(Long userId, RiskAssessDTO dto) {
        if (dto == null) {
            throw new RuntimeException("评估数据不能为空");
        }

        int age = 0;
        try {
            age = Integer.parseInt(dto.getAge());
        } catch (NumberFormatException ignored) {
        }

        String bloodPressure = dto.getSystolic() + "/" + dto.getDiastolic();
        BigDecimal bloodSugar = null;
        try {
            bloodSugar = new BigDecimal(dto.getFastingGlucose());
        } catch (NumberFormatException ignored) {
        }

        BigDecimal weight = null;
        try {
            weight = new BigDecimal(dto.getWeight());
        } catch (NumberFormatException ignored) {
        }

        BigDecimal height = null;
        try {
            height = new BigDecimal(dto.getHeight());
        } catch (NumberFormatException ignored) {
        }

        int hypertensionLevel = assessHypertensionRisk(bloodPressure);
        int diabetesLevel = assessDiabetesRisk(bloodSugar);
        int fallLevel = assessFallRisk(age);
        int frailtyLevel = assessFrailtyRiskFromDto(age, dto);
        int sarcopeniaLevel = assessSarcopeniaRisk(age, weight, height);

        int totalScore = 0;
        totalScore += hypertensionLevel == 1 ? 1 : (hypertensionLevel == 2 ? 2 : 0);
        totalScore += diabetesLevel == 1 ? 1 : (diabetesLevel == 2 ? 2 : 0);
        totalScore += fallLevel == 1 ? 1 : (fallLevel == 2 ? 2 : 0);
        totalScore += frailtyLevel == 1 ? 1 : (frailtyLevel == 2 ? 2 : 0);
        totalScore += sarcopeniaLevel == 1 ? 1 : (sarcopeniaLevel == 2 ? 2 : 0);

        int totalRiskLevel = calculateTotalRisk(totalScore);

        RiskAssess riskAssess = new RiskAssess();
        riskAssess.setUserId(userId);
        riskAssess.setAssessTime(new Date());
        riskAssess.setHypertensionRisk(toScore(hypertensionLevel));
        riskAssess.setDiabetesRisk(toScore(diabetesLevel));
        riskAssess.setFallRisk(toScore(fallLevel));
        riskAssess.setFrailtyRisk(toScore(frailtyLevel));
        riskAssess.setSarcopeniaRisk(toScore(sarcopeniaLevel));
        riskAssess.setTotalRisk(toScore(totalRiskLevel));
        riskAssess.setIsDeleted(0);

        String assessResult = generateAssessResult(
                hypertensionLevel, diabetesLevel, fallLevel, frailtyLevel, sarcopeniaLevel, totalRiskLevel, totalScore
        );
        riskAssess.setAssessResult(assessResult);

        save(riskAssess);
        return riskAssess;
    }

    private int toScore(int level) {
        switch (level) {
            case 0:
                return RISK_SCORE_LOW;
            case 1:
                return RISK_SCORE_MID;
            case 2:
                return RISK_SCORE_HIGH;
            default:
                return RISK_SCORE_LOW;
        }
    }

    private int assessFrailtyRiskFromDto(int age, RiskAssessDTO dto) {
        int risk = 0;
        if (age >= 65) {
            risk += 1;
        }
        if (dto.getBmi() != null && (dto.getBmi() < 18.5 || dto.getBmi() >= 27)) {
            risk += 1;
        }
        if ("是".equals(dto.getSmoking())) {
            risk += 1;
        }
        if ("每周1-2次".equals(dto.getExercise())) {
            risk += 1;
        }
        if (dto.getMedicalHistory() != null && dto.getMedicalHistory().size() > 0) {
            risk += 1;
        }
        if (risk >= 2) {
            return 2;
        } else if (risk >= 1) {
            return 1;
        }
        return 0;
    }

    @Override
    public int calculateTotalRisk(int score) {
        if (score <= 3) {
            return 0;
        } else if (score <= 7) {
            return 1;
        } else {
            return 2;
        }
    }

    @Override
    public int assessHypertensionRisk(String bloodPressure) {
        if (bloodPressure == null || bloodPressure.isEmpty()) {
            return 0;
        }
        try {
            String[] parts = bloodPressure.split("/");
            if (parts.length != 2) {
                return 0;
            }
            int systolic = Integer.parseInt(parts[0].trim());
            int diastolic = Integer.parseInt(parts[1].trim());

            List<HealthStandard> standards = healthStandardService.list(
                    new QueryWrapper<HealthStandard>().like("indicator_name", "收缩压")
            );

            int systolicRisk = 0;
            for (HealthStandard standard : standards) {
                BigDecimal min = standard.getMinValue();
                BigDecimal max = standard.getMaxValue();
                if (standard.getIndicatorName().contains("高血压")) {
                    if (min != null && systolic >= min.intValue()) {
                        systolicRisk = 2;
                        break;
                    }
                } else if (standard.getIndicatorName().contains("正常高值")) {
                    if (min != null && max != null && systolic >= min.intValue() && systolic <= max.intValue()) {
                        systolicRisk = 1;
                    }
                }
            }

            int diastolicRisk = 0;
            List<HealthStandard> diastolicStandards = healthStandardService.list(
                    new QueryWrapper<HealthStandard>().like("indicator_name", "舒张压")
            );
            for (HealthStandard standard : diastolicStandards) {
                BigDecimal min = standard.getMinValue();
                BigDecimal max = standard.getMaxValue();
                if (standard.getIndicatorName().contains("高血压")) {
                    if (min != null && diastolic >= min.intValue()) {
                        diastolicRisk = 2;
                        break;
                    }
                } else if (standard.getIndicatorName().contains("正常高值")) {
                    if (min != null && max != null && diastolic >= min.intValue() && diastolic <= max.intValue()) {
                        diastolicRisk = 1;
                    }
                }
            }
            return Math.max(systolicRisk, diastolicRisk);
        } catch (Exception e) {
            return 0;
        }
    }

    @Override
    public int assessDiabetesRisk(BigDecimal bloodSugar) {
        return assessDiabetesRisk(bloodSugar, "空腹血糖");
    }

    @Override
    public int assessDiabetesRisk(BigDecimal bloodSugar, String bloodSugarType) {
        if (bloodSugar == null) {
            return 0;
        }
        List<HealthStandard> standards = healthStandardService.list(
                new QueryWrapper<HealthStandard>().like("indicator_name", bloodSugarType)
        );
        for (HealthStandard standard : standards) {
            BigDecimal min = standard.getMinValue();
            BigDecimal max = standard.getMaxValue();
            if (standard.getIndicatorName().contains("确诊")) {
                if (min != null && bloodSugar.compareTo(min) >= 0) {
                    return 2;
                }
            } else if (standard.getIndicatorName().contains("偏高")) {
                if (min != null && max != null && bloodSugar.compareTo(min) >= 0 && bloodSugar.compareTo(max) <= 0) {
                    return 1;
                }
            }
        }
        return 0;
    }

    @Override
    public int assessFallRisk(int age) {
        List<HealthStandard> standards = healthStandardService.list(
                new QueryWrapper<HealthStandard>().like("indicator_name", "跌倒风险")
        );
        for (HealthStandard standard : standards) {
            BigDecimal min = standard.getMinValue();
            BigDecimal max = standard.getMaxValue();
            if (standard.getIndicatorName().contains("高风险")) {
                if (min != null && age >= min.intValue()) {
                    return 2;
                }
            } else if (standard.getIndicatorName().contains("中风险")) {
                if (min != null && max != null && age >= min.intValue() && age <= max.intValue()) {
                    return 1;
                }
            }
        }
        return 0;
    }

    @Override
    public int assessFrailtyRisk(int age, BigDecimal sleepDuration, Integer stepCount) {
        int risk = 0;
        List<HealthStandard> standards = healthStandardService.list(
                new QueryWrapper<HealthStandard>().like("indicator_name", "衰弱风险")
        );
        for (HealthStandard standard : standards) {
            if (standard.getIndicatorName().contains("年龄")) {
                BigDecimal min = standard.getMinValue();
                if (min != null && age >= min.intValue()) {
                    risk += 1;
                }
            }
        }
        if (sleepDuration != null) {
            List<HealthStandard> sleepStandards = healthStandardService.list(
                    new QueryWrapper<HealthStandard>().like("indicator_name", "睡眠时间")
            );
            for (HealthStandard standard : sleepStandards) {
                BigDecimal min = standard.getMinValue();
                BigDecimal max = standard.getMaxValue();
                if (standard.getIndicatorName().contains("不足/过长")) {
                    if ((min != null && sleepDuration.compareTo(min) < 0) || (max != null && sleepDuration.compareTo(max) > 0)) {
                        risk += 1;
                    }
                }
            }
        }
        if (stepCount != null) {
            List<HealthStandard> stepStandards = healthStandardService.list(
                    new QueryWrapper<HealthStandard>().like("indicator_name", "肌少症_每日步数")
            );
            for (HealthStandard standard : stepStandards) {
                BigDecimal max = standard.getMaxValue();
                if (standard.getIndicatorName().contains("不足") && max != null && stepCount < max.intValue()) {
                    risk += 1;
                }
            }
        }
        if (risk >= 2) {
            return 2;
        } else if (risk >= 1) {
            return 1;
        }
        return 0;
    }

    @Override
    public int assessSarcopeniaRisk(int age, BigDecimal weight, BigDecimal height) {
        if (age < 60 || weight == null || height == null || height.compareTo(BigDecimal.ZERO) == 0) {
            return 0;
        }
        BigDecimal heightInMeters = height.divide(new BigDecimal(100), 2, BigDecimal.ROUND_HALF_UP);
        BigDecimal bmi = weight.divide(heightInMeters.multiply(heightInMeters), 2, BigDecimal.ROUND_HALF_UP);
        List<HealthStandard> standards = healthStandardService.list(
                new QueryWrapper<HealthStandard>().like("indicator_name", "肌少症BMI")
        );
        for (HealthStandard standard : standards) {
            BigDecimal min = standard.getMinValue();
            BigDecimal max = standard.getMaxValue();
            if (standard.getIndicatorName().contains("过低")) {
                if (max != null && bmi.compareTo(max) <= 0) {
                    return 2;
                }
            } else if (standard.getIndicatorName().contains("偏低")) {
                if (min != null && max != null && bmi.compareTo(min) >= 0 && bmi.compareTo(max) <= 0) {
                    return 1;
                }
            }
        }
        return 0;
    }

    private String generateAssessResult(int hypertensionRisk, int diabetesRisk, int fallRisk,
                                        int frailtyRisk, int sarcopeniaRisk, int totalRisk, int totalScore) {
        StringBuilder result = new StringBuilder();
        result.append("{");
        result.append("\"hypertensionRisk\": " + hypertensionRisk + ",");
        result.append("\"diabetesRisk\": " + diabetesRisk + ",");
        result.append("\"fallRisk\": " + fallRisk + ",");
        result.append("\"frailtyRisk\": " + frailtyRisk + ",");
        result.append("\"sarcopeniaRisk\": " + sarcopeniaRisk + ",");
        result.append("\"totalRisk\": " + totalRisk + ",");
        result.append("\"totalScore\": " + totalScore + ",");
        result.append("\"riskLevel\": \"" + (totalRisk == 0 ? "低" : (totalRisk == 1 ? "中" : "高")) + "\",");
        result.append("\"suggestion\": \"" + getSuggestion(totalRisk) + "\"");
        result.append("}");
        return result.toString();
    }

    private String getSuggestion(int totalRisk) {
        switch (totalRisk) {
            case 0:
                return "您的健康风险较低，建议保持良好的生活习惯，定期体检。";
            case 1:
                return "您的健康风险中等，建议改善生活方式，增加运动，控制饮食，定期监测健康指标。";
            case 2:
                return "您的健康风险较高，建议及时就医，制定个性化的健康管理计划，密切监测健康状况。";
            default:
                return "请定期进行健康检查，保持健康的生活方式。";
        }
    }
}
