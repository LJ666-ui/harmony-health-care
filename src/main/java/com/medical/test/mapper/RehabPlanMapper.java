package com.medical.test.mapper; // 修正为 com.medical.test.mapper

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.medical.test.entity.RehabPlan; // 引用正确路径的实体
import org.apache.ibatis.annotations.Mapper;

@Mapper // 必须加，让Spring扫描
public interface RehabPlanMapper extends BaseMapper<RehabPlan> {
}
