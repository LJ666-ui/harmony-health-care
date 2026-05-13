package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 会诊实体类
 * 对应数据库表：consultation
 */
@Data
@TableName("consultation")
public class Consultation implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 发起人ID
     */
    private Long initiatorId;

    /**
     * 患者ID
     */
    private Long patientId;

    /**
     * 会诊标题
     */
    private String title;

    /**
     * 会诊描述
     */
    private String description;

    /**
     * 状态：pending-待开始, in_progress-进行中, completed-已完成, cancelled-已取消
     */
    private String status;

    /**
     * 预定开始时间
     */
    private LocalDateTime scheduledTime;

    /**
     * 实际开始时间
     */
    private LocalDateTime startedTime;

    /**
     * 实际结束时间
     */
    private LocalDateTime endedTime;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}
