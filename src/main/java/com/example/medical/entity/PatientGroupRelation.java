package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 患者分组关系实体类
 */
@Data
@TableName("patient_group_relation")
public class PatientGroupRelation implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("group_id")
    private Long groupId;

    @TableField("patient_id")
    private Long patientId;

    @TableField("create_time")
    private Date createTime;
}
