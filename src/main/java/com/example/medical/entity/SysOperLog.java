package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("sys_oper_log")
public class SysOperLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("operation_type")
    private String operationType;
    
    @TableField("operation_desc")
    private String operationDesc;
    
    @TableField("operation_time")
    private Date operationTime;
    
    @TableField("ip_address")
    private String ipAddress;
    
    @TableField("device_info")
    private String deviceInfo;
    
    @TableField("create_time")
    private Date createTime;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}