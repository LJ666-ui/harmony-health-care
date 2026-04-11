package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("health_food")
public class HealthFood {
    @TableId(type = IdType.AUTO)
    private Integer id;
    @TableField("food_id")
    private String foodId;
    @TableField("food_name")
    private String foodName;
    @TableField("diet_therapy")
    private String dietTherapy;
    @TableField("applicable_disease")
    private String applicableDisease;
    private String efficacy;
    @TableField("dietary_taboo")
    private String dietaryTaboo;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
}