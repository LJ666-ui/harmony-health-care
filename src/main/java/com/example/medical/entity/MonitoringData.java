package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 监控数据实体类
 * 对应数据库表：monitoring_data
 */
@Data
@TableName("monitoring_data")
public class MonitoringData {
    
    /**
     * 监控数据ID（主键，自增）
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 设备ID
     */
    private Long deviceId;
    
    /**
     * 病床ID
     */
    private Long bedId;
    
    /**
     * 患者ID
     */
    private Long patientId;
    
    /**
     * 数据类型（heart_rate-心率, blood_pressure-血压, temperature-体温, oxygen-血氧）
     */
    private String dataType;
    
    /**
     * 数值
     */
    private Double value;
    
    /**
     * 单位
     */
    private String unit;
    
    /**
     * 是否异常（0-正常，1-异常）
     */
    private Integer isAbnormal;
    
    /**
     * 异常等级（0-正常，1-轻微，2-中等，3-严重）
     */
    private Integer abnormalLevel;
    
    /**
     * 备注
     */
    private String remark;
    
    /**
     * 采集时间
     */
    private Date collectTime;
    
    /**
     * 创建时间
     */
    private Date createTime;
}
