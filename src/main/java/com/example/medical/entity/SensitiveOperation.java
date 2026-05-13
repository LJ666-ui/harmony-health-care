package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 敏感操作实体类
 * 对应数据库表：sensitive_operation
 */
@Data
@TableName("sensitive_operation")
public class SensitiveOperation implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 操作类型：delete, update, export
     */
    private String operationType;

    /**
     * 资源类型
     */
    private String resourceType;

    /**
     * 资源ID
     */
    private Long resourceId;

    /**
     * 操作原因
     */
    private String reason;

    /**
     * 状态：pending_confirmation-待确认, confirmed-已确认, cancelled-已取消
     */
    private String status;

    /**
     * 确认码
     */
    private String confirmationCode;

    /**
     * 确认时间
     */
    private LocalDateTime confirmedAt;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}
