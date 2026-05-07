package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.MedicationReminder;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用药提醒Mapper
 */
@Mapper
public interface MedicationReminderMapper extends BaseMapper<MedicationReminder> {
}
