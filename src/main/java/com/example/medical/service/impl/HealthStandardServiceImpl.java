package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.HealthCheckResult;
import com.example.medical.entity.HealthStandard;
import com.example.medical.mapper.HealthStandardMapper;
import com.example.medical.service.HealthStandardService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HealthStandardServiceImpl extends ServiceImpl<HealthStandardMapper, HealthStandard> implements HealthStandardService {
    @Override
    public HealthCheckResult checkIndicator(String indicatorName, double value) {
        HealthCheckResult result = new HealthCheckResult();
        
        // 构建查询条件
        LambdaQueryWrapper<HealthStandard> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthStandard::getIndicatorName, indicatorName);
        wrapper.eq(HealthStandard::getIsDeleted, 0);
        
        // 查询指标标准
        HealthStandard standard = baseMapper.selectOne(wrapper);
        
        if (standard == null) {
            result.setIsNormal(false);
            result.setStatus("error");
            result.setMessage("未找到该指标的标准值");
            return result;
        }
        
        // 判断数值是否在正常范围
        boolean isNormal = true;
        String status = "normal";
        String message = "指标正常";
        
        if (standard.getMinValue() != null && value < standard.getMinValue().doubleValue()) {
            isNormal = false;
            status = "low";
            message = "指标偏低";
        } else if (standard.getMaxValue() != null && value > standard.getMaxValue().doubleValue()) {
            isNormal = false;
            status = "high";
            message = "指标偏高";
        }
        
        // 设置结果
        result.setIsNormal(isNormal);
        result.setStatus(status);
        result.setMessage(message);
        result.setStandard(standard);
        result.setValue(value);
        result.setUnit(standard.getUnit());
        
        return result;
    }
    
    @Override
    public List<HealthStandard> getAllStandards() {
        LambdaQueryWrapper<HealthStandard> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthStandard::getIsDeleted, 0);
        return baseMapper.selectList(wrapper);
    }
    
    @Override
    public HealthStandard getById(Long id) {
        return baseMapper.selectById(id);
    }
    
    @Override
    public List<HealthStandard> getByAgeGroup(String ageGroup) {
        LambdaQueryWrapper<HealthStandard> wrapper = new LambdaQueryWrapper<>();
        if (ageGroup != null && !ageGroup.isEmpty()) {
            wrapper.eq(HealthStandard::getAgeGroup, ageGroup);
        }
        wrapper.eq(HealthStandard::getIsDeleted, 0);
        return baseMapper.selectList(wrapper);
    }
    
    @Override
    public List<HealthStandard> getByGender(Integer gender) {
        LambdaQueryWrapper<HealthStandard> wrapper = new LambdaQueryWrapper<>();
        if (gender != null) {
            wrapper.eq(HealthStandard::getGender, gender);
        }
        wrapper.eq(HealthStandard::getIsDeleted, 0);
        return baseMapper.selectList(wrapper);
    }
}