package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("doctor")
public class Doctor {
    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField(exist = false)
    private String realName;

    @TableField(exist = false)
    private String phone;

    private String hospital;

    @TableField("department")
    private String department;

    @TableField("license_number")
    private String licenseNumber;

    private String title;

    private String specialty;

    @TableField(exist = false)
    private String avatar;

    private String description;

    private Double rating;

    private Integer status;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;
}
