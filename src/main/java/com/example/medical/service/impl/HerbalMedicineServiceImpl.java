package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.medical.entity.HerbalMedicine;
import com.example.medical.entity.HerbalEfficacy;
import com.example.medical.mapper.HerbalMedicineMapper;
import com.example.medical.mapper.HerbalEfficacyMapper;
import com.example.medical.service.HerbalMedicineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HerbalMedicineServiceImpl extends ServiceImpl<HerbalMedicineMapper, HerbalMedicine> implements HerbalMedicineService {

    @Autowired
    private HerbalEfficacyMapper herbalEfficacyMapper;

    @Override
    public Page<HerbalMedicine> pageQuery(Integer page, Integer size, String keyword) {
        Page<HerbalMedicine> pageInfo = new Page<>(page, size);
        QueryWrapper<HerbalMedicine> queryWrapper = new QueryWrapper<>();
        
        // 过滤已逻辑删除的数据
        queryWrapper.eq("is_deleted", 0);
        
        // 关键词模糊搜索
        if (keyword != null && !keyword.isEmpty()) {
            queryWrapper.like("name", keyword)
                       .or().like("alias", keyword)
                       .or().like("pinyin", keyword);
        }
        
        return page(pageInfo, queryWrapper);
    }

    @Override
    public List<HerbalEfficacy> getEfficaciesByMedicineId(Long medicineId) {
        QueryWrapper<HerbalEfficacy> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("medicine_id", medicineId);
        
        return herbalEfficacyMapper.selectList(queryWrapper);
    }
}
