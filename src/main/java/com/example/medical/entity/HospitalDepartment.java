package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("hospital_department")
public class HospitalDepartment implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("hospital_id")
    private Long hospitalId;

    @TableField("dept_name")
    private String deptName;

    @TableField("dept_intro")
    private String deptIntro;

    @TableField("source")
    private String source;

    @TableField("crawl_time")
    private Date crawlTime;

    @TableField("location")
    private String location;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;
}
