package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 示例实体
 * 演示标准的Entity定义规范
 *
 * @author Nebula Medical Team
 * @date 2026-05-06
 */
@Data
@TableName("example_table")
@Schema(description = "示例模块数据实体")
public class ExampleEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @Schema(description = "主键ID")
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 名称
     */
    @Schema(description = "名称", required = true)
    @TableField("name")
    private String name;

    /**
     * 描述
     */
    @Schema(description = "描述")
    @TableField("description")
    private String description;

    /**
     * 状态：0-禁用，1-启用
     */
    @Schema(description = "状态：0-禁用，1-启用")
    @TableField("status")
    private Integer status;

    /**
     * 排序值
     */
    @Schema(description = "排序值")
    @TableField("sort_order")
    private Integer sortOrder;

    /**
     * 创建时间
     */
    @Schema(description = "创建时间")
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private Date createTime;

    /**
     * 更新时间
     */
    @Schema(description = "更新时间")
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    /**
     * 创建人ID
     */
    @Schema(description = "创建人ID")
    @TableField("create_by")
    private Long createBy;

    /**
     * 更新人ID
     */
    @Schema(description = "更新人ID")
    @TableField("update_by")
    private Long updateBy;

    /**
     * 是否删除：0-未删除，1-已删除
     */
    @Schema(description = "是否删除")
    @TableLogic
    @TableField("is_deleted")
    private Integer isDeleted;

    /**
     * 备注
     */
    @Schema(description = "备注")
    @TableField("remark")
    private String remark;
}
