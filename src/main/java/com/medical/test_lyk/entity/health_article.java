package com.medical.test_lyk.entity;

import lombok.Data;
import com.baomidou.mybatisplus.annotation.*;
import java.time.LocalDateTime;

@Data
@TableName("health_article")
public class health_article {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String content;
    private String source;
    private String originUrl;
    private LocalDateTime crawlTime;
}