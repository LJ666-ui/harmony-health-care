package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.Consultation;
import org.apache.ibatis.annotations.Mapper;

/**
 * 会诊Mapper接口
 */
@Mapper
public interface ConsultationMapper extends BaseMapper<Consultation> {
}
