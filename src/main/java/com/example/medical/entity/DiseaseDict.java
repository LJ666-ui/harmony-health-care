package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("disease_dict")
public class DiseaseDict {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("disease_code")
    private String diseaseCode;
    
    @TableField("disease_name")
    private String diseaseName;
    
    private String description;
    
    private String category;
    
    @TableField("create_time")
    private Date createTime;
    
    @TableField("update_time")
    private Date updateTime;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}