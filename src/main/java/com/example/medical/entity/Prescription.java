package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 处方实体类
 */
@Data
@TableName("prescription")
public class Prescription {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 患者ID
     */
    private Long patientId;
    
    /**
     * 患者姓名
     */
    private String patientName;
    
    /**
     * 医生ID
     */
    private Long doctorId;
    
    /**
     * 医生姓名
     */
    private String doctorName;
    
    /**
     * 药品信息（JSON格式）
     */
    private String medications;
    
    /**
     * 诊断
     */
    private String diagnosis;
    
    /**
     * 备注
     */
    private String notes;
    
    /**
     * 状态：ACTIVE-有效, COMPLETED-已完成, CANCELLED-已取消
     */
    private String status;
    
    /**
     * 创建时间
     */
    private Date createdAt;
    
    /**
     * 有效期至
     */
    private Date validUntil;
}
