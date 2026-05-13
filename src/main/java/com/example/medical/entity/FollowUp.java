package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("follow_up")
public class FollowUp {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("patient_id")
    private Long patientId;

    private String type;

    private String title;

    @TableField("hospital_name")
    private String hospitalName;

    private String department;

    @TableField("doctor_name")
    private String doctorName;

    @TableField("follow_up_date")
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private LocalDate followUpDate;

    @TableField("follow_up_time")
    private String followUpTime;

    private String status;

    private String notes;

    @TableField("reminder_enabled")
    private Integer reminderEnabled;

    @TableField("reminder_days_before")
    private Integer reminderDaysBefore;

    @TableField("created_by")
    private Long createdBy;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;

    @TableField("is_deleted")
    private Integer isDeleted;
}
