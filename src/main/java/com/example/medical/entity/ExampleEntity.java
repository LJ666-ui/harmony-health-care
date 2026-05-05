package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.*;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
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
@ApiModel(value = "示例实体", description = "示例模块数据实体")
public class ExampleEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @ApiModelProperty("主键ID")
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 名称
     */
    @ApiModelProperty(value = "名称", required = true)
    @TableField("name")
    private String name;

    /**
     * 描述
     */
    @ApiModelProperty("描述")
    @TableField("description")
    private String description;

    /**
     * 状态：0-禁用，1-启用
     */
    @ApiModelProperty("状态：0-禁用，1-启用")
    @TableField("status")
    private Integer status;

    /**
     * 排序值
     */
    @ApiModelProperty("排序值")
    @TableField("sort_order")
    private Integer sortOrder;

    /**
     * 创建时间
     */
    @ApiModelProperty("创建时间")
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    private Date createTime;

    /**
     * 更新时间
     */
    @ApiModelProperty("更新时间")
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    /**
     * 创建人ID
     */
    @ApiModelProperty("创建人ID")
    @TableField("create_by")
    private Long createBy;

    /**
     * 更新人ID
     */
    @ApiModelProperty("更新人ID")
    @TableField("update_by")
    private Long updateBy;

    /**
     * 是否删除：0-未删除，1-已删除
     */
    @ApiModelProperty("是否删除")
    @TableLogic
    @TableField("is_deleted")
    private Integer isDeleted;

    /**
     * 备注
     */
    @ApiModelProperty("备注")
    @TableField("remark")
    private String remark;
}
