package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("article_collect")
public class ArticleCollect {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("user_id")
    private Long userId;
    @TableField("article_id")
    private Long articleId;
    @TableField("collect_time")
    private Date collectTime;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
    
    @TableField(exist = false)
    private String title;
    @TableField(exist = false)
    private String coverImage;
    @TableField(exist = false)
    private String summary;
    @TableField(exist = false)
    private String categoryName;
    @TableField(exist = false)
    private Integer viewCount;

    public ArticleCollect() {
    }

    public ArticleCollect(Long id, Long userId, Long articleId, Date collectTime, Date createTime, Date updateTime, Integer isDeleted) {
        this.id = id;
        this.userId = userId;
        this.articleId = articleId;
        this.collectTime = collectTime;
        this.createTime = createTime;
        this.updateTime = updateTime;
        this.isDeleted = isDeleted;
    }
}