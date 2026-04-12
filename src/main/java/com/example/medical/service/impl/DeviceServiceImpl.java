package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.DeviceBinding;
import com.example.medical.mapper.DeviceBindingMapper;
import com.example.medical.service.DeviceService;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class DeviceServiceImpl extends ServiceImpl<DeviceBindingMapper, DeviceBinding> implements DeviceService {

    @Override
    public boolean bindDevice(DeviceBinding device) {
        DeviceBinding existing = baseMapper.findByDeviceId(device.getDeviceId());
        if (existing != null) {
            return false;
        }
        device.setStatus(1);
        device.setBindTime(new Date());
        device.setLastSyncTime(new Date());
        device.setIsDeleted(0);
        return save(device);
    }

    @Override
    public boolean unbindDevice(Long userId, String deviceId) {
        DeviceBinding device = lambdaQuery()
                .eq(DeviceBinding::getUserId, userId)
                .eq(DeviceBinding::getDeviceId, deviceId)
                .one();
        if (device == null) {
            return false;
        }
        device.setIsDeleted(1);
        device.setStatus(0);
        return updateById(device);
    }

    @Override
    public List<DeviceBinding> getDeviceList(Long userId) {
        return baseMapper.findByUserId(userId);
    }

    @Override
    public DeviceBinding getDeviceInfo(String deviceId) {
        return baseMapper.findByDeviceId(deviceId);
    }

    @Override
    public boolean updateDeviceStatus(String deviceId, Integer status) {
        DeviceBinding device = baseMapper.findByDeviceId(deviceId);
        if (device == null) {
            return false;
        }
        device.setStatus(status);
        device.setLastSyncTime(new Date());
        return updateById(device);
    }

    @Override
    public Map<String, Object> syncData(Long userId, String deviceId, String syncData) {
        Map<String, Object> result = new HashMap<>();
        DeviceBinding device = baseMapper.findByDeviceId(deviceId);
        if (device == null || !device.getUserId().equals(userId)) {
            result.put("success", false);
            result.put("message", "设备不存在或未绑定");
            return result;
        }
        device.setSyncData(syncData);
        device.setLastSyncTime(new Date());
        updateById(device);

        List<DeviceBinding> userDevices = baseMapper.findByUserId(userId);
        result.put("success", true);
        result.put("message", "数据同步成功");
        result.put("syncTime", new Date());
        result.put("syncedDevices", userDevices.size());
        result.put("devices", userDevices);

        logSyncRecord(userId, deviceId, "DATA_SYNC", "数据同步完成");
        return result;
    }

    @Override
    public List<DeviceBinding> getOnlineDevices(Long userId) {
        return lambdaQuery()
                .eq(DeviceBinding::getUserId, userId)
                .eq(DeviceBinding::getStatus, 1)
                .eq(DeviceBinding::getIsDeleted, 0)
                .orderByDesc(DeviceBinding::getLastSyncTime)
                .list();
    }

    private void logSyncRecord(Long userId, String deviceId, String action, String detail) {
    }
}
