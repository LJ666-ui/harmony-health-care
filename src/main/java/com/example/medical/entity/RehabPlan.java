package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("rehab_plan")
public class RehabPlan {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String disease;
    private String title;
    private String content;
    private String source;
    @TableField("start_date")
    private Date startDate;
    @TableField("end_date")
    private Date endDate;
    @TableField("plan_status")
    private Integer planStatus;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
}