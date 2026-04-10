package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.HealthFood;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface HealthFoodMapper extends BaseMapper<HealthFood> {
}