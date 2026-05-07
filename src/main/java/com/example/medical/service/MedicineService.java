package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.Medicine;

import java.util.List;

public interface MedicineService extends IService<Medicine> {
    
    /**
     * 根据分类编码查询药品列表
     */
    List<Medicine> findByCategoryCode(String categoryCode);
}