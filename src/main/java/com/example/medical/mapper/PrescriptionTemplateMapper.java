package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.PrescriptionTemplate;
import org.apache.ibatis.annotations.Mapper;

/**
 * 处方模板Mapper接口
 */
@Mapper
public interface PrescriptionTemplateMapper extends BaseMapper<PrescriptionTemplate> {
}
