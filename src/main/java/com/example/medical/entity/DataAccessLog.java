package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("data_access_log")
public class DataAccessLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("access_user_id")
    private Long accessUserId;
    
    @TableField("data_type")
    private String dataType;
    
    @TableField("data_id")
    private Long dataId;
    
    @TableField("access_time")
    private Date accessTime;
    
    @TableField("access_ip")
    private String accessIp;
    
    @TableField("is_authorized")
    private Integer isAuthorized;
    
    @TableField("create_time")
    private Date createTime;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}