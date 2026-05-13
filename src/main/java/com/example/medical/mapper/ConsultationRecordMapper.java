package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.ConsultationRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 会诊记录Mapper接口
 */
@Mapper
public interface ConsultationRecordMapper extends BaseMapper<ConsultationRecord> {
}
