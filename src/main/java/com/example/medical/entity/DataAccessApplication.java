package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 数据访问申请实体类
 * 对应数据库表：data_access_application
 */
@Data
@TableName("data_access_application")
public class DataAccessApplication implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 申请人ID
     */
    private Long requesterId;

    /**
     * 申请人角色
     */
    private String requesterRole;

    /**
     * 审批人ID
     */
    private Long approverId;

    /**
     * 数据类型
     */
    private String dataType;

    /**
     * 数据ID
     */
    private Long dataId;

    /**
     * 申请原因
     */
    private String reason;

    /**
     * 访问时长（小时）
     */
    private Integer duration;

    /**
     * 状态：pending-待审批, approved-已批准, rejected-已拒绝, expired-已过期
     */
    private String status;

    /**
     * 审批时间
     */
    private LocalDateTime approvedAt;

    /**
     * 过期时间
     */
    private LocalDateTime expiresAt;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}
