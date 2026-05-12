package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 病历模板实体类
 * 对应数据库表：medical_record_template
 */
@Data
@TableName("medical_record_template")
public class MedicalRecordTemplate implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 医生ID
     */
    private Long doctorId;

    /**
     * 模板名称
     */
    private String templateName;

    /**
     * 诊断模板
     */
    private String diagnosisTemplate;

    /**
     * 治疗方案模板
     */
    private String treatmentTemplate;

    /**
     * 备注模板
     */
    private String notesTemplate;

    /**
     * 是否公开：0-私有，1-公开
     */
    private Integer isPublic;

    /**
     * 使用次数
     */
    private Integer usageCount;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}
