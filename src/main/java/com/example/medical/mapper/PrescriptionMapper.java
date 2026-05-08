package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.Prescription;
import org.apache.ibatis.annotations.Mapper;

/**
 * 处方Mapper
 */
@Mapper
public interface PrescriptionMapper extends BaseMapper<Prescription> {
}
