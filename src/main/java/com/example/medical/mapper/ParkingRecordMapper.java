package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.ParkingRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 停车记录Mapper接口
 */
@Mapper
public interface ParkingRecordMapper extends BaseMapper<ParkingRecord> {
}
