package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Medicine;
import com.example.medical.mapper.MedicineMapper;
import com.example.medical.service.MedicineService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicineServiceImpl extends ServiceImpl<MedicineMapper, Medicine> implements MedicineService {

    @Override
    public List<Medicine> findByCategoryCode(String categoryCode) {
        QueryWrapper<Medicine> wrapper = new QueryWrapper<>();
        wrapper.eq("category_code", categoryCode);
        wrapper.eq("is_deleted", 0);
        return list(wrapper);
    }
}