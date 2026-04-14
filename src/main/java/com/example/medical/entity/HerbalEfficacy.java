package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

@Data
@TableName("herbal_efficacy")
public class HerbalEfficacy implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("medicine_id")
    private Long medicineId;

    @TableField("efficacy_name")
    private String efficacyName;

    @TableField("efficacy_category")
    private String efficacyCategory;

    @TableField("strength_level")
    private Integer strengthLevel;

    private String description;

    @TableField(exist = false)
    private Integer isDeleted;

    @TableField(exist = false)
    private Date createTime;

    @TableField(exist = false)
    private Date updateTime;
}
