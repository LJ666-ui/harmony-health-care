package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 护理记录实体类
 */
@Data
@TableName("nursing_record")
public class NursingRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("patient_id")
    private Long patientId;
    
    @TableField("nurse_id")
    private Long nurseId;
    
    @TableField("record_type")
    private Integer recordType;
    
    @TableField("record_content")
    private String recordContent;
    
    @TableField("remark")
    private String remark;
    
    @TableField("vital_signs")
    private String vitalSigns;
    
    @TableField("care_time")
    private Date careTime;
    
    @TableField("create_time")
    private Date createTime;
    
    @TableField("update_time")
    private Date updateTime;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}
