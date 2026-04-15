package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("rehab_action")
public class RehabAction {
    @TableId(type = IdType.AUTO)
    private Long id;
    @TableField("plan_id")
    private Long planId;
    @TableField("action_name")
    private String actionName;
    @TableField("action_desc")
    private String actionDesc;
    private Integer duration;
    private Integer sets;
    private Integer reps;
    @TableField("video_url")
    private String videoUrl;
    @TableField("model_3d_url")
    private String model3dUrl;
    @TableField("create_time")
    private Date createTime;
    @TableField("update_time")
    private Date updateTime;
    @TableField("is_deleted")
    private Integer isDeleted;
}