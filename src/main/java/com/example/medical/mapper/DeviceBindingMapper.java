package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.DeviceBinding;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface DeviceBindingMapper extends BaseMapper<DeviceBinding> {

    @Select("SELECT * FROM device_binding WHERE user_id = #{userId} AND is_deleted = 0 ORDER BY bind_time DESC")
    List<DeviceBinding> findByUserId(Long userId);

    @Select("SELECT * FROM device_binding WHERE device_id = #{deviceId} AND is_deleted = 0")
    DeviceBinding findByDeviceId(String deviceId);
}
