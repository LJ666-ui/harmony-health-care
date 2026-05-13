package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.util.Date;

@Data
@TableName("examination_report")
public class ExaminationReport {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long appointmentId;

    private Long hospitalId;

    private Long doctorId;

    private String reportType;

    private String reportName;

    @TableField("exam_date")
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private Date examDate;

    private String departmentName;

    private String doctorName;

    private String hospitalName;

    private String pickupLocation;

    private Integer printStatus;

    private Integer resultStatus;

    private String conclusion;

    private String abnormalItems;

    @TableField("print_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date printTime;

    @TableField("result_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date resultTime;

    private BigDecimal fee;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;
}
