package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.HealthStandard;
import com.example.medical.mapper.HealthStandardMapper;
import com.example.medical.service.HealthStandardService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class HealthStandardServiceImpl extends ServiceImpl<HealthStandardMapper, HealthStandard> implements HealthStandardService {

    @Override
    public Map<String, Object> checkIndicator(String indicatorName, double value) {
        Map<String, Object> result = new HashMap<>();
        
        // 查询相关指标标准
        QueryWrapper<HealthStandard> queryWrapper = new QueryWrapper<>();
        queryWrapper.like("indicator_name", indicatorName);
        List<HealthStandard> standards = list(queryWrapper);
        
        if (standards.isEmpty()) {
            result.put("status", "error");
            result.put("message", "未找到相关指标标准");
            return result;
        }
        
        BigDecimal valueBD = new BigDecimal(value);
        HealthStandard matchedStandard = null;
        
        // 匹配指标值对应的标准
        for (HealthStandard standard : standards) {
            BigDecimal minValue = standard.getMinValue();
            BigDecimal maxValue = standard.getMaxValue();
            
            boolean isMatch = false;
            if (minValue == null && maxValue != null) {
                // 小于等于最大值
                isMatch = valueBD.compareTo(maxValue) <= 0;
            } else if (minValue != null && maxValue == null) {
                // 大于等于最小值
                isMatch = valueBD.compareTo(minValue) >= 0;
            } else if (minValue != null && maxValue != null) {
                // 在最小值和最大值之间
                isMatch = valueBD.compareTo(minValue) >= 0 && valueBD.compareTo(maxValue) <= 0;
            }
            
            if (isMatch) {
                matchedStandard = standard;
                break;
            }
        }
        
        if (matchedStandard != null) {
            result.put("status", "success");
            result.put("standard", matchedStandard);
            result.put("message", "指标检测完成");
        } else {
            result.put("status", "warning");
            result.put("message", "未找到匹配的指标标准");
        }
        
        return result;
    }

    @Override
    public List<HealthStandard> getAllStandards() {
        return list();
    }

    @Override
    public List<HealthStandard> getByAgeGroup(String ageGroup) {
        QueryWrapper<HealthStandard> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("age_group", ageGroup);
        return list(queryWrapper);
    }

    @Override
    public List<HealthStandard> getByGender(Integer gender) {
        QueryWrapper<HealthStandard> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("gender", gender);
        return list(queryWrapper);
    }
}

