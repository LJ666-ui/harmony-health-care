package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.ExampleEntity;
import com.example.medical.mapper.ExampleMapper;
import com.example.medical.service.ExampleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 示例Service实现
 * 实现自定义业务逻辑方法
 *
 * @author Nebula Medical Team
 * @date 2026-05-06
 */
@Service
@Transactional(rollbackFor = Exception.class)
public class ExampleServiceImpl extends ServiceImpl<ExampleMapper, ExampleEntity> implements ExampleService {

    @Autowired
    private ExampleMapper exampleMapper;

    @Override
    public ExampleEntity findByName(String name) {
        LambdaQueryWrapper<ExampleEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ExampleEntity::getName, name);
        return exampleMapper.selectOne(wrapper);
    }

    @Override
    public List<ExampleEntity> findByStatus(Integer status) {
        LambdaQueryWrapper<ExampleEntity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ExampleEntity::getStatus, status);
        wrapper.orderByDesc(ExampleEntity::getCreateTime);
        return exampleMapper.selectList(wrapper);
    }

    @Override
    public List<ExampleEntity> search(String keyword, Integer status) {
        LambdaQueryWrapper<ExampleEntity> wrapper = new LambdaQueryWrapper<>();

        // 关键词搜索
        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(ExampleEntity::getName, keyword)
                   .or()
                   .like(ExampleEntity::getDescription, keyword);
        }

        // 状态筛选
        if (status != null) {
            wrapper.eq(ExampleEntity::getStatus, status);
        }

        // 排序
        wrapper.orderByDesc(ExampleEntity::getCreateTime);

        return exampleMapper.selectList(wrapper);
    }
}
