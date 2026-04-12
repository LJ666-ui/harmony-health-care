package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("sys_statistics")
public class SysStatistics {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("stat_type")
    private String statType;
    
    @TableField("user_id")
    private Long userId;
    
    @TableField("stat_key")
    private String statKey;
    
    @TableField("stat_value")
    private String statValue;
    
    @TableField("stat_time")
    private Date statTime;
    
    private String remark;
    
    @TableField("create_time")
    private Date createTime;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}