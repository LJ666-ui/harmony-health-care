package com.example.medical.entity.medicalimage;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("diagnosis_recommendation")
public class DiagnosisRecommendation implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "recommendation_id", type = IdType.AUTO)
    private Long recommendationId;

    @TableField("result_id")
    private String resultId;

    @TableField("lesion_id")
    private String lesionId;

    @TableField("recommendation_type")
    private String recommendationType;

    @TableField("recommendation_text")
    private String recommendationText;

    @TableField("priority")
    private Integer priority;

    @TableField("created_at")
    private LocalDateTime createdAt;
}
