package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 药品分类字典实体类，对应 medicine_categories 表
 */
@Data
@TableName("medicine_categories")
public class MedicineCategory {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 分类编码 */
    @TableField("category_code")
    private String categoryCode;

    /** 分类名称 */
    @TableField("category_name")
    private String categoryName;

    /** 父分类编码 */
    @TableField("parent_code")
    private String parentCode;

    /** 分类层级：1=一级 2=二级 3=三级 */
    private Integer level;

    /** 显示顺序 */
    @TableField("display_order")
    private Integer displayOrder;

    /** 状态：0=禁用 1=启用 */
    private Integer status;

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
