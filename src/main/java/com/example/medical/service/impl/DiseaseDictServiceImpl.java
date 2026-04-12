package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.PageResult;
import com.example.medical.entity.DiseaseDict;
import com.example.medical.mapper.DiseaseDictMapper;
import com.example.medical.service.DiseaseDictService;
import org.springframework.stereotype.Service;

@Service
public class DiseaseDictServiceImpl extends ServiceImpl<DiseaseDictMapper, DiseaseDict> implements DiseaseDictService {
    @Override
    public PageResult<DiseaseDict> searchByKeyword(String keyword, int page, int pageSize) {
        // 构建分页对象
        Page<DiseaseDict> pageInfo = new Page<>(page, pageSize);
        
        // 构建查询条件
        LambdaQueryWrapper<DiseaseDict> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(DiseaseDict::getDiseaseName, keyword)
                   .or().like(DiseaseDict::getDescription, keyword)
                   .or().like(DiseaseDict::getCategory, keyword);
        }
        wrapper.eq(DiseaseDict::getIsDeleted, 0);
        
        // 执行分页查询
        pageInfo = baseMapper.selectPage(pageInfo, wrapper);
        
        // 构建分页结果
        return new PageResult<>(pageInfo.getTotal(), pageInfo.getRecords(), page, pageSize);
    }
    
    @Override
    public PageResult<DiseaseDict> getByCategory(String category, int page, int pageSize) {
        // 构建分页对象
        Page<DiseaseDict> pageInfo = new Page<>(page, pageSize);
        
        // 构建查询条件
        LambdaQueryWrapper<DiseaseDict> wrapper = new LambdaQueryWrapper<>();
        if (category != null && !category.isEmpty()) {
            wrapper.eq(DiseaseDict::getCategory, category);
        }
        wrapper.eq(DiseaseDict::getIsDeleted, 0);
        
        // 执行分页查询
        pageInfo = baseMapper.selectPage(pageInfo, wrapper);
        
        // 构建分页结果
        return new PageResult<>(pageInfo.getTotal(), pageInfo.getRecords(), page, pageSize);
    }
    
    @Override
    public DiseaseDict getById(Long id) {
        return baseMapper.selectById(id);
    }
}