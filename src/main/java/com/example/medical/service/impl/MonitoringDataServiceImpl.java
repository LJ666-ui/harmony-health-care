package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.MonitoringData;
import com.example.medical.mapper.MonitoringDataMapper;
import com.example.medical.service.MonitoringDataService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 监控数据Service实现类
 */
@Service
public class MonitoringDataServiceImpl extends ServiceImpl<MonitoringDataMapper, MonitoringData> implements MonitoringDataService {
    
    @Override
    public boolean recordData(MonitoringData data) {
        data.setCollectTime(new Date());
        data.setCreateTime(new Date());
        
        // 简单的异常检测逻辑
        if (data.getDataType() != null && data.getValue() != null) {
            boolean isAbnormal = false;
            int abnormalLevel = 0;
            
            switch (data.getDataType()) {
                case "heart_rate":
                    // 心率正常范围：60-100
                    if (data.getValue() < 60 || data.getValue() > 100) {
                        isAbnormal = true;
                        abnormalLevel = data.getValue() < 50 || data.getValue() > 120 ? 3 : 2;
                    }
                    break;
                case "blood_pressure":
                    // 血压正常范围：90-140
                    if (data.getValue() < 90 || data.getValue() > 140) {
                        isAbnormal = true;
                        abnormalLevel = data.getValue() < 80 || data.getValue() > 160 ? 3 : 2;
                    }
                    break;
                case "temperature":
                    // 体温正常范围：36.0-37.5
                    if (data.getValue() < 36.0 || data.getValue() > 37.5) {
                        isAbnormal = true;
                        abnormalLevel = data.getValue() < 35.0 || data.getValue() > 39.0 ? 3 : 2;
                    }
                    break;
                case "oxygen":
                    // 血氧正常范围：95-100
                    if (data.getValue() < 95) {
                        isAbnormal = true;
                        abnormalLevel = data.getValue() < 90 ? 3 : 2;
                    }
                    break;
            }
            
            data.setIsAbnormal(isAbnormal ? 1 : 0);
            data.setAbnormalLevel(abnormalLevel);
        }
        
        return save(data);
    }
    
    @Override
    public MonitoringData getLatestData(Long deviceId) {
        LambdaQueryWrapper<MonitoringData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MonitoringData::getDeviceId, deviceId)
               .orderByDesc(MonitoringData::getCollectTime)
               .last("LIMIT 1");
        return getOne(wrapper);
    }
    
    @Override
    public List<MonitoringData> getPatientHistory(Long patientId, String dataType, Integer limit) {
        LambdaQueryWrapper<MonitoringData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MonitoringData::getPatientId, patientId);
        
        if (dataType != null && !dataType.isEmpty()) {
            wrapper.eq(MonitoringData::getDataType, dataType);
        }
        
        wrapper.orderByDesc(MonitoringData::getCollectTime);
        
        if (limit != null && limit > 0) {
            wrapper.last("LIMIT " + limit);
        }
        
        return list(wrapper);
    }
    
    @Override
    public List<MonitoringData> getAbnormalData(Integer abnormalLevel) {
        LambdaQueryWrapper<MonitoringData> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MonitoringData::getIsAbnormal, 1);
        
        if (abnormalLevel != null && abnormalLevel > 0) {
            wrapper.ge(MonitoringData::getAbnormalLevel, abnormalLevel);
        }
        
        wrapper.orderByDesc(MonitoringData::getCollectTime);
        return list(wrapper);
    }
    
    @Override
    public Map<String, Object> getStatistics(Long patientId) {
        Map<String, Object> stats = new HashMap<>();
        
        // 总数据量
        LambdaQueryWrapper<MonitoringData> totalWrapper = new LambdaQueryWrapper<>();
        totalWrapper.eq(MonitoringData::getPatientId, patientId);
        stats.put("total", count(totalWrapper));
        
        // 异常数据量
        LambdaQueryWrapper<MonitoringData> abnormalWrapper = new LambdaQueryWrapper<>();
        abnormalWrapper.eq(MonitoringData::getPatientId, patientId)
                      .eq(MonitoringData::getIsAbnormal, 1);
        stats.put("abnormal", count(abnormalWrapper));
        
        // 各类型数据统计
        String[] dataTypes = {"heart_rate", "blood_pressure", "temperature", "oxygen"};
        for (String type : dataTypes) {
            LambdaQueryWrapper<MonitoringData> typeWrapper = new LambdaQueryWrapper<>();
            typeWrapper.eq(MonitoringData::getPatientId, patientId)
                      .eq(MonitoringData::getDataType, type);
            stats.put(type + "_count", count(typeWrapper));
        }
        
        return stats;
    }
}
