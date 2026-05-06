package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.MonitoringData;
import org.apache.ibatis.annotations.Mapper;

/**
 * 监控数据Mapper接口
 */
@Mapper
public interface MonitoringDataMapper extends BaseMapper<MonitoringData> {
}
