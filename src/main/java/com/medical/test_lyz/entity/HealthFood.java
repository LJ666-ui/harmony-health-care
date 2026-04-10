package com.medical.test_lyz.entity; // 确保包存在

import lombok.Data;
import com.baomidou.mybatisplus.annotation.*;

@Data
@TableName("health_food") // 对应数据库表名
public class HealthFood {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private String foodId;
    private String foodName;
    private String dietTherapy;
    private String applicableDisease;
    private String efficacy;
    private String dietaryTaboo;
}