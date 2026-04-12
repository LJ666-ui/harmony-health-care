package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("data_share_auth")
public class DataShareAuth {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("auth_user_id")
    private Long authUserId;
    
    @TableField("data_type")
    private String dataType;
    
    @TableField("auth_start_time")
    private Date authStartTime;
    
    @TableField("auth_end_time")
    private Date authEndTime;
    
    private Integer status;
    
    @TableField("create_time")
    private Date createTime;
    
    @TableField("update_time")
    private Date updateTime;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}