package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 会诊记录实体类
 * 对应数据库表：consultation_record
 */
@Data
@TableName("consultation_record")
public class ConsultationRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 会诊ID
     */
    private Long consultationId;

    /**
     * 医生ID
     */
    private Long doctorId;

    /**
     * 记录内容
     */
    private String content;

    /**
     * 记录时间
     */
    private LocalDateTime recordTime;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}
