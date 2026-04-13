package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.DeviceBinding;

import java.util.List;
import java.util.Map;

public interface DeviceService extends IService<DeviceBinding> {

    boolean bindDevice(DeviceBinding device);

    boolean unbindDevice(Long userId, String deviceId);

    List<DeviceBinding> getDeviceList(Long userId);

    DeviceBinding getDeviceInfo(String deviceId);

    boolean updateDeviceStatus(String deviceId, Integer status);

    Map<String, Object> syncData(Long userId, String deviceId, String syncData);

    List<DeviceBinding> getOnlineDevices(Long userId);
}
