package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("risk_assess")
public class RiskAssess {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    @TableField("assess_time")
    private Date assessTime;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
    @TableField("hypertension_risk")
    private Integer hypertensionRisk;
    @TableField("diabetes_risk")
    private Integer diabetesRisk;
    @TableField("fall_risk")
    private Integer fallRisk;
    @TableField("frailty_risk")
    private Integer frailtyRisk;
    @TableField("sarcopenia_risk")
    private Integer sarcopeniaRisk;
    @TableField("total_risk")
    private Integer totalRisk;
    @TableField("assess_result")
    private String assessResult;
}
