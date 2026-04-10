package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("health_record")
public class HealthRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("user_id")
    private Long userId;
    @TableField("blood_pressure")
    private String bloodPressure;
    @TableField("blood_sugar")
    private BigDecimal bloodSugar;
    @TableField("heart_rate")
    private Integer heartRate;
    @TableField("record_time")
    private Date recordTime;
    private BigDecimal weight;
    private BigDecimal height;
    @TableField("step_count")
    private Integer stepCount;
    @TableField("sleep_duration")
    private BigDecimal sleepDuration;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
}