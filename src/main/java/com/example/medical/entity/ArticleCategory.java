package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("article_category")
public class ArticleCategory {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("category_name")
    private String categoryName;
    @TableField("category_code")
    private String categoryCode;
    @TableField("parent_id")
    private Long parentId;
    private Integer level;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
}
