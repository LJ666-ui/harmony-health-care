package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthFood;
import com.example.medical.mapper.HealthFoodMapper;
import com.example.medical.service.HealthFoodService;
import org.springframework.stereotype.Service;

@Service
public class HealthFoodServiceImpl extends ServiceImpl<HealthFoodMapper, HealthFood> implements HealthFoodService {

    @Override
    public PageResult<HealthFood> pageQuery(int page, int pageSize, String foodName, String applicableDisease, String dietTherapy, String efficacy, String dietaryTaboo) {
        // 构建分页对象
        Page<HealthFood> pageInfo = new Page<>(page, pageSize);
        
        // 构建查询条件
        LambdaQueryWrapper<HealthFood> wrapper = new LambdaQueryWrapper<>();
        if (foodName != null && !foodName.isEmpty()) {
            wrapper.like(HealthFood::getFoodName, foodName);
        }
        if (applicableDisease != null && !applicableDisease.isEmpty()) {
            wrapper.like(HealthFood::getApplicableDisease, applicableDisease);
        }
        if (dietTherapy != null && !dietTherapy.isEmpty()) {
            wrapper.like(HealthFood::getDietTherapy, dietTherapy);
        }
        if (efficacy != null && !efficacy.isEmpty()) {
            wrapper.like(HealthFood::getEfficacy, efficacy);
        }
        if (dietaryTaboo != null && !dietaryTaboo.isEmpty()) {
            wrapper.like(HealthFood::getDietaryTaboo, dietaryTaboo);
        }
        
        // 执行分页查询
        pageInfo = baseMapper.selectPage(pageInfo, wrapper);
        
        // 构建分页结果
        return new PageResult<>(pageInfo.getTotal(), pageInfo.getRecords(), page, pageSize);
    }

    @Override
    public HealthFood getById(Long id) {
        // 直接调用父类方法
        return super.getById(id);
    }

    @Override
    public java.util.List<HealthFood> listByApplicableDisease(String applicableDisease) {
        // 构建查询条件
        LambdaQueryWrapper<HealthFood> wrapper = new LambdaQueryWrapper<>();
        if (applicableDisease != null && !applicableDisease.isEmpty()) {
            wrapper.like(HealthFood::getApplicableDisease, applicableDisease);
        }
        
        // 执行查询
        return baseMapper.selectList(wrapper);
    }
}