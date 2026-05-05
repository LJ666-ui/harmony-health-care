package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.ExampleEntity;

import java.util.List;

/**
 * 示例Service接口
 * 继承MyBatis-Plus的IService接口，提供基础CRUD方法
 *
 * @author Nebula Medical Team
 * @date 2026-05-06
 */
public interface ExampleService extends IService<ExampleEntity> {

    /**
     * 根据名称查询
     * @param name 名称
     * @return 实体对象
     */
    ExampleEntity findByName(String name);

    /**
     * 根据状态查询列表
     * @param status 状态
     * @return 实体列表
     */
    List<ExampleEntity> findByStatus(Integer status);

    /**
     * 复杂条件查询
     * @param keyword 关键词
     * @param status 状态
     * @return 实体列表
     */
    List<ExampleEntity> search(String keyword, Integer status);
}
