package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("ai_conversation")
public class AIConversation {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;
    private String question;
    private String answer;
    private String type;
    private Date createTime;
}
