package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.MonitoringData;

import java.util.List;
import java.util.Map;

/**
 * 监控数据Service接口
 */
public interface MonitoringDataService extends IService<MonitoringData> {
    
    /**
     * 记录监控数据
     * @param data 监控数据
     * @return 记录结果
     */
    boolean recordData(MonitoringData data);
    
    /**
     * 获取设备最新数据
     * @param deviceId 设备ID
     * @return 最新数据
     */
    MonitoringData getLatestData(Long deviceId);
    
    /**
     * 获取患者监控历史
     * @param patientId 患者ID
     * @param dataType 数据类型（可选）
     * @param limit 限制数量
     * @return 历史数据列表
     */
    List<MonitoringData> getPatientHistory(Long patientId, String dataType, Integer limit);
    
    /**
     * 获取异常数据列表
     * @param abnormalLevel 异常等级（可选）
     * @return 异常数据列表
     */
    List<MonitoringData> getAbnormalData(Integer abnormalLevel);
    
    /**
     * 获取监控统计信息
     * @param patientId 患者ID
     * @return 统计信息
     */
    Map<String, Object> getStatistics(Long patientId);
}
