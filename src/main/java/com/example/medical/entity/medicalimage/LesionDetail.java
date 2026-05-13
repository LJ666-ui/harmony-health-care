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
@TableName("lesion_detail")
public class LesionDetail implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "lesion_id", type = IdType.ASSIGN_ID)
    private String lesionId;

    @TableField("result_id")
    private String resultId;

    @TableField("lesion_type")
    private String lesionType;

    @TableField("lesion_name")
    private String lesionName;

    @TableField("position_x")
    private BigDecimal positionX;

    @TableField("position_y")
    private BigDecimal positionY;

    @TableField("bounding_box")
    private String boundingBox;

    @TableField("confidence")
    private BigDecimal confidence;

    @TableField("severity")
    private String severity;

    @TableField("description")
    private String description;

    @TableField("size_mm")
    private BigDecimal sizeMm;

    @TableField("shape")
    private String shape;

    @TableField("density")
    private String density;

    @TableField("edge")
    private String edge;

    @TableField("internal_structure")
    private String internalStructure;

    @TableField("created_at")
    private LocalDateTime createdAt;
}
