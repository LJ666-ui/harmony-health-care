package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.ParkingRecord;
import com.example.medical.service.ParkingRecordService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 智慧停车Controller
 * 提供停车服务的RESTful API接口
 * 
 * @author Medical System
 * @version 1.0
 * @since 2026-04-27
 */
@Api(tags = "智慧停车服务")
@RestController
@RequestMapping("/parking")
@CrossOrigin
@Validated
public class ParkingController {
    
    @Autowired
    private ParkingRecordService parkingRecordService;
    
    /**
     * 记录停车位置
     * 
     * @param record 停车记录
     * @return 记录结果
     */
    @ApiOperation(value = "记录停车位置", notes = "用户停车后记录车位信息")
    @PostMapping("/record")
    public Result<?> recordParking(@Valid @RequestBody ParkingRecord record) {
        try {
            if (record.getUserId() == null) {
                return Result.error("用户ID不能为空");
            }
            if (record.getSpaceNumber() == null || record.getSpaceNumber().isEmpty()) {
                return Result.error("车位编号不能为空");
            }
            
            if (parkingRecordService.createParkingRecord(record)) {
                Map<String, Object> result = new HashMap<>();
                result.put("recordId", record.getId());
                result.put("message", "停车记录创建成功");
                return Result.success(result);
            } else {
                return Result.error("记录失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("记录失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取当前停车信息
     * 
     * @param userId 用户ID
     * @return 停车信息
     */
    @ApiOperation(value = "获取当前停车信息", notes = "查询用户当前的停车记录")
    @GetMapping("/current/{userId}")
    public Result<?> getCurrentParking(@ApiParam("用户ID") @PathVariable Long userId) {
        try {
            ParkingRecord record = parkingRecordService.getCurrentParking(userId);
            if (record == null) {
                return Result.error("暂无停车记录");
            }
            
            // 计算当前费用
            double currentFee = parkingRecordService.calculateFee(record.getParkTime());
            long duration = (System.currentTimeMillis() - record.getParkTime().getTime()) / (1000 * 60);
            
            Map<String, Object> result = new HashMap<>();
            result.put("record", record);
            result.put("currentFee", currentFee);
            result.put("durationMinutes", duration);
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 寻车导航
     * 
     * @param userId 用户ID
     * @return 导航信息
     */
    @ApiOperation(value = "寻车导航", notes = "获取停车位置导航信息")
    @GetMapping("/find-car/{userId}")
    public Result<?> findCar(@ApiParam("用户ID") @PathVariable Long userId) {
        try {
            ParkingRecord record = parkingRecordService.getCurrentParking(userId);
            if (record == null) {
                return Result.error("暂无停车记录");
            }
            
            Map<String, Object> navigation = new HashMap<>();
            navigation.put("spaceNumber", record.getSpaceNumber());
            navigation.put("floor", record.getFloor());
            navigation.put("zone", record.getZone());
            navigation.put("latitude", record.getLatitude());
            navigation.put("longitude", record.getLongitude());
            navigation.put("parkingLotName", record.getParkingLotName());
            navigation.put("note", record.getNote());
            
            // 计算当前费用
            double currentFee = parkingRecordService.calculateFee(record.getParkTime());
            navigation.put("currentFee", currentFee);
            
            return Result.success(navigation);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 结算停车费用
     * 
     * @param recordId 记录ID
     * @return 结算结果
     */
    @ApiOperation(value = "结算停车费用", notes = "离开时结算停车费用")
    @PostMapping("/settle/{recordId}")
    public Result<?> settleParking(@ApiParam("记录ID") @PathVariable Long recordId) {
        try {
            Map<String, Object> result = parkingRecordService.settleParking(recordId);
            
            if ((Boolean) result.get("success")) {
                return Result.success(result);
            } else {
                return Result.error((String) result.get("message"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("结算失败：" + e.getMessage());
        }
    }
    
    /**
     * 支付停车费
     * 
     * @param recordId 记录ID
     * @return 支付结果
     */
    @ApiOperation(value = "支付停车费", notes = "支付停车费用")
    @PostMapping("/pay/{recordId}")
    public Result<?> payParking(@ApiParam("记录ID") @PathVariable Long recordId) {
        try {
            ParkingRecord record = parkingRecordService.getById(recordId);
            if (record == null) {
                return Result.error("记录不存在");
            }
            
            if (record.getPaymentStatus() == 1) {
                return Result.error("已支付");
            }
            
            // 模拟支付成功
            record.setPaymentStatus(1);
            record.setUpdateTime(new java.util.Date());
            parkingRecordService.updateById(record);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("fee", record.getFee());
            result.put("message", "支付成功");
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("支付失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取停车历史
     * 
     * @param userId 用户ID
     * @return 历史记录列表
     */
    @ApiOperation(value = "获取停车历史", notes = "查询用户的停车历史记录")
    @GetMapping("/history/{userId}")
    public Result<?> getParkingHistory(@ApiParam("用户ID") @PathVariable Long userId) {
        try {
            List<ParkingRecord> history = parkingRecordService.getParkingHistory(userId);
            return Result.success(history);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 计算预估费用
     * 
     * @param parkTime 停车时间（时间戳）
     * @return 预估费用
     */
    @ApiOperation(value = "计算预估费用", notes = "根据停车时间计算预估费用")
    @GetMapping("/calculate-fee")
    public Result<?> calculateFee(@ApiParam("停车时间戳") @RequestParam Long parkTime) {
        try {
            java.util.Date date = new java.util.Date(parkTime);
            double fee = parkingRecordService.calculateFee(date);
            
            long duration = (System.currentTimeMillis() - parkTime) / (1000 * 60);
            
            Map<String, Object> result = new HashMap<>();
            result.put("fee", fee);
            result.put("durationMinutes", duration);
            result.put("hourlyRate", 5.0);
            result.put("dailyCap", 50.0);
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("计算失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取停车场信息
     * 
     * @param parkingLotId 停车场ID
     * @return 停车场信息
     */
    @ApiOperation(value = "获取停车场信息", notes = "查询停车场详细信息")
    @GetMapping("/lot/{parkingLotId}")
    public Result<?> getParkingLotInfo(@ApiParam("停车场ID") @PathVariable Long parkingLotId) {
        try {
            // 模拟停车场信息
            Map<String, Object> info = new HashMap<>();
            info.put("id", parkingLotId);
            info.put("name", "门诊楼地下停车场");
            info.put("totalSpaces", 500);
            info.put("availableSpaces", 128);
            info.put("hourlyRate", 5.0);
            info.put("dailyCap", 50.0);
            info.put("floors", new String[]{"B1", "B2", "B3"});
            info.put("openTime", "06:00");
            info.put("closeTime", "22:00");
            
            return Result.success(info);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
}
