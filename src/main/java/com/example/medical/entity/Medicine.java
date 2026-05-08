package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 药品信息实体类，对应 medicine 表
 */
@Data
@TableName("medicine")
public class Medicine {

    @TableId(type = IdType.AUTO) // 主键，自动递增
    private Long id;

    /** 药品名 */
    private String name;

    /** 药品类别 */
    private String category;

    /** 分类编码 */
    @TableField("category_code")
    private String categoryCode;

    /** 适应症 */
    private String indication;

    /** 用法用量 */
    @TableField("usage_desc")
    private String usageDesc;

    /** 禁忌 */
    private String taboo;

    /** 来源 */
    private String source;

    /** 创建时间 */
    @TableField("create_time")
    private Date createTime;

    /** 更新时间 */
    @TableField("update_time")
    private Date updateTime;

    /** 是否删除 */
    @TableField("is_deleted")
    private Integer isDeleted;
}