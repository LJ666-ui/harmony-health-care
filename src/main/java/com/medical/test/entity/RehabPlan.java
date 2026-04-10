package com.medical.test.entity; // 确保包存在

import lombok.Data;
import com.baomidou.mybatisplus.annotation.*;

@Data
@TableName("rehab_plan") // 对应数据库表名
public class RehabPlan {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String disease;
    private String title;
    private String content;
    private String source;
}