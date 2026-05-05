package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.ExampleEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 示例Mapper接口
 * 继承MyBatis-Plus的BaseMapper接口，提供基础CRUD方法
 *
 * @author Nebula Medical Team
 * @date 2026-05-06
 */
@Mapper
public interface ExampleMapper extends BaseMapper<ExampleEntity> {
    // BaseMapper已提供以下方法：
    // - int insert(T entity)
    // - int deleteById(Serializable id)
    // - int updateById(T entity)
    // - T selectById(Serializable id)
    // - List<T> selectList(Wrapper<T> wrapper)
    // - ... 更多方法

    // 如需自定义SQL，可在此定义方法并在XML中实现
}
