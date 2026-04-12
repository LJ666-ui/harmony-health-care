package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.DeviceBinding;
import com.example.medical.service.DeviceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/device")
@CrossOrigin
@Validated
public class DeviceController {

    @Autowired
    private DeviceService deviceService;

    @PostMapping("/bind")
    public Result<?> bindDevice(@Valid @RequestBody DeviceBinding device, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        device.setUserId(userId);
        if (deviceService.bindDevice(device)) {
            return Result.success("设备绑定成功");
        }
        return Result.error("设备已存在或绑定失败");
    }

    @PostMapping("/unbind")
    public Result<?> unbindDevice(@RequestParam String deviceId, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        if (deviceService.unbindDevice(userId, deviceId)) {
            return Result.success("设备解绑成功");
        }
        return Result.error("设备解绑失败或设备不存在");
    }

    @GetMapping("/list")
    public Result<?> getDeviceList(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        List<DeviceBinding> devices = deviceService.getDeviceList(userId);
        return Result.success(devices);
    }

    @GetMapping("/info")
    public Result<?> getDeviceInfo(@RequestParam String deviceId) {
        DeviceBinding device = deviceService.getDeviceInfo(deviceId);
        if (device == null) {
            return Result.error("设备不存在");
        }
        return Result.success(device);
    }

    @PostMapping("/sync")
    public Result<?> syncData(@RequestBody Map<String, String> params, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        String deviceId = params.get("deviceId");
        String syncData = params.get("syncData");
        Map<String, Object> result = deviceService.syncData(userId, deviceId, syncData);
        if ((Boolean) result.getOrDefault("success", false)) {
            return Result.success(result);
        }
        return Result.error((String) result.get("message"));
    }

    @GetMapping("/online")
    public Result<?> getOnlineDevices(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        List<DeviceBinding> devices = deviceService.getOnlineDevices(userId);
        return Result.success(devices);
    }

    @PutMapping("/status")
    public Result<?> updateStatus(@RequestParam String deviceId, @RequestParam Integer status) {
        if (deviceService.updateDeviceStatus(deviceId, status)) {
            return Result.success("状态更新成功");
        }
        return Result.error("状态更新失败");
    }
}
