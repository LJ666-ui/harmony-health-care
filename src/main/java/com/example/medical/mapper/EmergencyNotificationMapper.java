package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.EmergencyNotification;
import org.apache.ibatis.annotations.Mapper;

/**
 * 紧急通知Mapper
 */
@Mapper
public interface EmergencyNotificationMapper extends BaseMapper<EmergencyNotification> {
}
