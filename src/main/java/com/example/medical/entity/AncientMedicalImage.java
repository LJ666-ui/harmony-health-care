package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("ancient_medical_img")
public class AncientMedicalImage {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String originalUrl;

    private String restoreUrl;

    private String model3dUrl;

    private String title;

    private String desc;

    private String source;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;

    private Integer isDeleted;
}