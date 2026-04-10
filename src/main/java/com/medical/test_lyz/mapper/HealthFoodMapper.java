package com.medical.test_lyz.mapper; // 修正为 com.medical.test_lyz.mapper

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.medical.test_lyz.entity.HealthFood; // 引用正确路径的实体
import org.apache.ibatis.annotations.Mapper;

@Mapper // 必须加，让Spring扫描
public interface HealthFoodMapper extends BaseMapper<HealthFood> {
}