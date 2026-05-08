package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("appointment")
public class Appointment {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("doctor_id")
    private Long doctorId;

    @TableField("user_id")
    private Long userId;

    @TableField("schedule_date")
    @JsonFormat(pattern = "yyyyMMdd", timezone = "GMT+8")
    private Date scheduleDate;

    @TableField("schedule_period")
    private Integer schedulePeriod;

    @TableField("appointment_no")
    private String appointmentNo;

    private BigDecimal fee;

    private Integer status;

    private String reason;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;
}
