package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("payment_record")
public class PaymentRecord {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("out_trade_no")
    private String outTradeNo;

    @TableField("trade_no")
    private String tradeNo;

    @TableField("user_id")
    private Long userId;

    @TableField("appointment_id")
    private Long appointmentId;

    private BigDecimal amount;

    private Integer status;

    @TableField("pay_method")
    private String payMethod;

    @TableField("doctor_id")
    private Long doctorId;

    @TableField("schedule_date")
    private String scheduleDate;

    @TableField("schedule_period")
    private Integer schedulePeriod;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;
}
