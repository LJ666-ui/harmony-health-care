package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.medical.common.Result;
import com.example.medical.entity.MonitoringData;
import com.example.medical.service.MonitoringDataService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 智慧病房监控Controller
 * 提供实时监控数据管理的RESTful API接口
 * 
 * @author Medical System
 * @version 1.0
 * @since 2026-04-27
 */
@Tag(name = "智慧病房监控")
@RestController
@RequestMapping("/monitoring")
@CrossOrigin
@Validated
public class MonitoringController {
    
    @Autowired
    private MonitoringDataService monitoringDataService;
    
    /**
     * 记录监控数据
     * 
     * @param data 监控数据
     * @return 记录结果
     */
    @Operation(summary = "记录监控数据", description = "设备上报监控数据，系统自动检测异常")
    @PostMapping("/record")
    public Result<?> recordData(@Valid @RequestBody MonitoringData data) {
        try {
            if (data.getDeviceId() == null) {
                return Result.error("设备ID不能为空");
            }
            if (data.getDataType() == null || data.getDataType().isEmpty()) {
                return Result.error("数据类型不能为空");
            }
            if (data.getValue() == null) {
                return Result.error("数值不能为空");
            }
            
            if (monitoringDataService.recordData(data)) {
                Map<String, Object> result = new HashMap<>();
                result.put("dataId", data.getId());
                result.put("isAbnormal", data.getIsAbnormal());
                result.put("abnormalLevel", data.getAbnormalLevel());
                result.put("message", data.getIsAbnormal() == 1 ? "检测到异常数据" : "数据正常");
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
     * 获取设备最新数据
     * 
     * @param deviceId 设备ID
     * @return 最新数据
     */
    @Operation(summary = "获取设备最新数据", description = "查询指定设备的最新监控数据")
    @GetMapping("/latest/{deviceId}")
    public Result<?> getLatestData(@Parameter(description = "设备ID") @PathVariable Long deviceId) {
        try {
            MonitoringData data = monitoringDataService.getLatestData(deviceId);
            if (data == null) {
                return Result.error("暂无数据");
            }
            return Result.success(data);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取患者监控历史
     * 
     * @param patientId 患者ID
     * @param dataType 数据类型（可选）
     * @param limit 限制数量（可选）
     * @return 历史数据列表
     */
    @Operation(summary = "获取患者监控历史", description = "查询患者的监控数据历史记录")
    @GetMapping("/history/{patientId}")
    public Result<?> getPatientHistory(
            @Parameter(description = "患者ID") @PathVariable Long patientId,
            @Parameter(description = "数据类型") @RequestParam(required = false) String dataType,
            @Parameter(description = "限制数量") @RequestParam(required = false) Integer limit) {
        try {
            if (limit == null) {
                limit = 100; // 默认返回最近100条
            }
            List<MonitoringData> history = monitoringDataService.getPatientHistory(patientId, dataType, limit);
            return Result.success(history);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取异常数据列表
     * 
     * @param abnormalLevel 异常等级（可选）
     * @return 异常数据列表
     */
    @Operation(summary = "获取异常数据列表", description = "查询所有或指定等级的异常数据")
    @GetMapping("/abnormal")
    public Result<?> getAbnormalData(
            @Parameter(description = "异常等级") @RequestParam(required = false) Integer abnormalLevel) {
        try {
            List<MonitoringData> abnormalData = monitoringDataService.getAbnormalData(abnormalLevel);
            return Result.success(abnormalData);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取监控统计信息
     * 
     * @param patientId 患者ID
     * @return 统计信息
     */
    @Operation(summary = "获取监控统计", description = "统计患者的监控数据情况")
    @GetMapping("/statistics/{patientId}")
    public Result<?> getStatistics(@Parameter(description = "患者ID") @PathVariable Long patientId) {
        try {
            Map<String, Object> stats = monitoringDataService.getStatistics(patientId);
            return Result.success(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("统计失败：" + e.getMessage());
        }
    }
    
    /**
     * 批量记录监控数据
     * 
     * @param dataList 监控数据列表
     * @return 记录结果
     */
    @Operation(summary = "批量记录监控数据", description = "一次上报多个监控数据")
    @PostMapping("/batch-record")
    public Result<?> batchRecordData(@Valid @RequestBody List<MonitoringData> dataList) {
        try {
            int successCount = 0;
            int abnormalCount = 0;
            
            for (MonitoringData data : dataList) {
                if (monitoringDataService.recordData(data)) {
                    successCount++;
                    if (data.getIsAbnormal() == 1) {
                        abnormalCount++;
                    }
                }
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("total", dataList.size());
            result.put("success", successCount);
            result.put("abnormal", abnormalCount);
            result.put("message", "批量记录完成");
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("批量记录失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取病床监控概览
     * 
     * @param bedId 病床ID
     * @return 监控概览
     */
    @Operation(summary = "获取病床监控概览", description = "查询病床的所有监控数据概览")
    @GetMapping("/bed-overview/{bedId}")
    public Result<?> getBedOverview(@Parameter(description = "病床ID") @PathVariable Long bedId) {
        try {
            LambdaQueryWrapper<MonitoringData> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(MonitoringData::getBedId, bedId)
                   .orderByDesc(MonitoringData::getCollectTime)
                   .last("LIMIT 50");
            
            List<MonitoringData> recentData = monitoringDataService.list(wrapper);
            
            // 按数据类型分组
            Map<String, MonitoringData> latestByType = new HashMap<>();
            for (MonitoringData data : recentData) {
                if (!latestByType.containsKey(data.getDataType())) {
                    latestByType.put(data.getDataType(), data);
                }
            }
            
            // 统计异常数量
            long abnormalCount = recentData.stream()
                    .filter(d -> d.getIsAbnormal() == 1)
                    .count();
            
            Map<String, Object> result = new HashMap<>();
            result.put("latestData", latestByType);
            result.put("recentCount", recentData.size());
            result.put("abnormalCount", abnormalCount);
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 清理过期数据
     * 
     * @param days 保留天数
     * @return 清理结果
     */
    @Operation(summary = "清理过期数据", description = "删除指定天数之前的监控数据")
    @DeleteMapping("/cleanup")
    public Result<?> cleanupOldData(@Parameter(description = "保留天数") @RequestParam(defaultValue = "30") Integer days) {
        try {
            // 计算截止时间
            long cutoffTime = System.currentTimeMillis() - (days * 24L * 60 * 60 * 1000);
            java.util.Date cutoffDate = new java.util.Date(cutoffTime);
            
            LambdaQueryWrapper<MonitoringData> wrapper = new LambdaQueryWrapper<>();
            wrapper.lt(MonitoringData::getCollectTime, cutoffDate);
            
            boolean deleted = monitoringDataService.remove(wrapper);
            
            Map<String, Object> result = new HashMap<>();
            result.put("deleted", deleted);
            result.put("cutoffDate", cutoffDate);
            result.put("message", "清理完成");
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("清理失败：" + e.getMessage());
        }
    }
}
