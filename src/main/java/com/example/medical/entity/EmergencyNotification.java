package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 紧急通知实体类
 */
@Data
@TableName("emergency_notification")
public class EmergencyNotification {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 通知类型：HEALTH_ANOMALY-健康异常, PATIENT_HELP-患者求助, CRITICAL_ALERT-危急警报
     */
    private String type;
    
    /**
     * 患者ID
     */
    private Long patientId;
    
    /**
     * 患者姓名
     */
    private String patientName;
    
    /**
     * 患者位置-纬度
     */
    private Double patientLatitude;
    
    /**
     * 患者位置-经度
     */
    private Double patientLongitude;
    
    /**
     * 患者位置-地址
     */
    private String patientAddress;
    
    /**
     * 严重程度：LOW-低, MEDIUM-中, HIGH-高, CRITICAL-危急
     */
    private String severity;
    
    /**
     * 通知标题
     */
    private String title;
    
    /**
     * 通知内容
     */
    private String content;
    
    /**
     * 心率
     */
    private Integer heartRate;
    
    /**
     * 血压
     */
    private String bloodPressure;
    
    /**
     * 体温
     */
    private Double temperature;
    
    /**
     * 血氧
     */
    private Integer bloodOxygen;
    
    /**
     * 病历摘要
     */
    private String medicalSummary;
    
    /**
     * 处理人ID
     */
    private Long handledBy;
    
    /**
     * 处理时间
     */
    private Date handledAt;
    
    /**
     * 创建时间
     */
    private Date createdAt;
}
