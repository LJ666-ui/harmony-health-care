package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 用药提醒实体类
 */
@Data
@TableName("medication_reminder")
public class MedicationReminder {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 处方ID
     */
    private Long prescriptionId;
    
    /**
     * 患者ID
     */
    private Long patientId;
    
    /**
     * 药品名称
     */
    private String medicationName;
    
    /**
     * 剂量
     */
    private String medicationDosage;
    
    /**
     * 用法说明
     */
    private String medicationInstructions;
    
    /**
     * 注意事项（JSON格式）
     */
    private String medicationWarnings;
    
    /**
     * 计划服药时间
     */
    private Date scheduledTime;
    
    /**
     * 状态：PENDING-待服药, TAKEN-已服药, SKIPPED-已跳过, DELAYED-已延迟
     */
    private String status;
    
    /**
     * 实际服药时间
     */
    private Date actualTime;
    
    /**
     * 操作类型
     */
    private String action;
    
    /**
     * 创建时间
     */
    private Date createdAt;
}
