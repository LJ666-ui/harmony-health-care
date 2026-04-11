package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("health_article")
public class HealthArticle {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String content;
    @TableField("category_id")
    private Long categoryId;
    private String author;
    @TableField("cover_image")
    private String coverImage;
    @TableField("publish_time")
    private Date publishTime;
    @TableField("view_count")
    private Integer viewCount;
    @TableField("collect_count")
    private Integer collectCount;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
}