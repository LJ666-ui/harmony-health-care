package com.example.medical.entity.medicalimage;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("diagnosis_record")
public class DiagnosisRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "result_id", type = IdType.ASSIGN_ID)
    private String resultId;

    @TableField("image_id")
    private String imageId;

    @TableField("user_id")
    private Long userId;

    @TableField("image_type")
    private String imageType;

    @TableField("lesion_count")
    private Integer lesionCount;

    @TableField("overall_confidence")
    private BigDecimal overallConfidence;

    @TableField("analysis_status")
    private String analysisStatus;

    @TableField("analysis_time")
    private LocalDateTime analysisTime;

    @TableField("analysis_duration")
    private Integer analysisDuration;

    @TableField("ai_engine_version")
    private String aiEngineVersion;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
