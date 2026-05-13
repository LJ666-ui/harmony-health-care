package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 会诊参与人实体类
 * 对应数据库表：consultation_participant
 */
@Data
@TableName("consultation_participant")
public class ConsultationParticipant implements Serializable {

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
     * 科室ID
     */
    private Long departmentId;

    /**
     * 状态：invited-已邀请, accepted-已接受, declined-已拒绝
     */
    private String status;

    /**
     * 加入时间
     */
    private LocalDateTime joinedTime;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}
