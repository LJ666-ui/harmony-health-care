package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("health_standard")
public class HealthStandard {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("indicator_name")
    private String indicatorName;
    @TableField("min_value")
    private BigDecimal minValue;
    @TableField("max_value")
    private BigDecimal maxValue;
    private String unit;
    @TableField("age_group")
    private String ageGroup;
    private Integer gender;
    @TableField("standard_desc")
    private String standardDesc;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
}
