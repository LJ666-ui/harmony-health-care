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