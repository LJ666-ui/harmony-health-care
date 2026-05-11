package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("nurse_patient_relation")
public class NursePatientRelation {
    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("nurse_id")
    private Long nurseId;

    @TableField("patient_id")
    private Long patientId;

    @TableField("relation_type")
    private Integer relationType;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;
}
