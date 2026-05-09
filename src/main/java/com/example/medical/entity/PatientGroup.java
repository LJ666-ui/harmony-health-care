package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 患者分组实体类
 */
@Data
@TableName("patient_group")
public class PatientGroup implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("doctor_id")
    private Long doctorId;

    @TableField("group_name")
    private String groupName;

    @TableField("description")
    private String description;

    @TableField("color")
    private String color;

    @TableField("sort_order")
    private Integer sortOrder;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;
}
