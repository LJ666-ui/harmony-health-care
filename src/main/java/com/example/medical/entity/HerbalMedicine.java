package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

@Data
@TableName("herbal_medicine")
public class HerbalMedicine implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String pinyin;

    private String alias;

    private String category;

    private String nature;

    private String taste;

    private String meridian;

    @TableField("efficacy_summary")
    private String efficacySummary;

    @TableField("efficacy_detail")
    private String efficacyDetail;

    private String indication;

    @TableField("usage_dosage")
    private String usageDosage;

    private String contraindication;

    private String toxicity;

    @TableField("processing_method")
    private String processingMethod;

    @TableField("source_origin")
    private String sourceOrigin;

    private String appearance;

    @TableField("image_url")
    private String imageUrl;

    @TableField(exist = false)
    private String model3dUrl;

    @TableField(exist = false)
    private String classicPrescription;

    @TableField(exist = false)
    private String modernResearch;

    @TableField(exist = false)
    private String referenceSource;

    @TableField(exist = false)
    private Integer viewCount;

    @TableField(exist = false)
    private Integer collectCount;

    private Integer isDeleted;

    private Date createTime;

    private Date updateTime;
}
