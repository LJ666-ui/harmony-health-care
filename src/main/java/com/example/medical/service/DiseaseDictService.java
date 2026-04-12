package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.common.PageResult;
import com.example.medical.entity.DiseaseDict;

public interface DiseaseDictService extends IService<DiseaseDict> {
    /**
     * 根据关键词模糊搜索疾病
     * @param keyword 关键词
     * @param page 当前页
     * @param pageSize 每页条数
     * @return 分页结果
     */
    PageResult<DiseaseDict> searchByKeyword(String keyword, int page, int pageSize);
    
    /**
     * 根据疾病分类分页查询
     * @param category 疾病分类
     * @param page 当前页
     * @param pageSize 每页条数
     * @return 分页结果
     */
    PageResult<DiseaseDict> getByCategory(String category, int page, int pageSize);
    
    /**
     * 根据疾病 ID 查询详情
     * @param id 疾病 ID
     * @return 疾病详情
     */
    DiseaseDict getById(Long id);
}