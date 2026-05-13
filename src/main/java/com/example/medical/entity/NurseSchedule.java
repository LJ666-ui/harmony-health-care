package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;

@Data
@TableName("nurse_schedule")
public class NurseSchedule {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("nurse_id")
    private Long nurseId;

    @TableField("nurse_name")
    private String nurseName;

    @TableField("department")
    private String department;

    @TableField("schedule_date")
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date scheduleDate;

    @TableField("shift_type")
    private Integer shiftType;

    @TableField("ward_area")
    private String wardArea;

    @TableField("bed_count")
    private Integer bedCount;

    @TableField("patient_ids")
    private String patientIds;

    private Integer status;

    @TableField("remark")
    private String remark;

    @TableField("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;

    @TableField("update_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;
}
