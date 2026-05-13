package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.ConsultationParticipant;
import org.apache.ibatis.annotations.Mapper;

/**
 * 会诊参与人Mapper接口
 */
@Mapper
public interface ConsultationParticipantMapper extends BaseMapper<ConsultationParticipant> {
}
