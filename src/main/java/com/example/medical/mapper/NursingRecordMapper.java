package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.NursingRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 护理记录Mapper接口
 */
@Mapper
public interface NursingRecordMapper extends BaseMapper<NursingRecord> {
}
