package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.MedicalRecordTemplate;
import org.apache.ibatis.annotations.Mapper;

/**
 * 病历模板Mapper接口
 */
@Mapper
public interface MedicalRecordTemplateMapper extends BaseMapper<MedicalRecordTemplate> {
}
