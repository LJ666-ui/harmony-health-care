package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.Appointment;
import org.apache.ibatis.annotations.Mapper;

/**
 * 预约挂号Mapper接口
 */
@Mapper
public interface AppointmentMapper extends BaseMapper<Appointment> {
}
