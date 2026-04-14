package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.HerbalMedicine;
import com.example.medical.entity.HerbalEfficacy;

import java.util.List;

public interface HerbalMedicineService extends IService<HerbalMedicine> {

    /**
     * 分页查询 + 关键词模糊搜索
     */
    Page<HerbalMedicine> pageQuery(Integer page, Integer size, String keyword);

    /**
     * 根据药材ID查询对应所有功效
     */
    List<HerbalEfficacy> getEfficaciesByMedicineId(Long medicineId);
}
