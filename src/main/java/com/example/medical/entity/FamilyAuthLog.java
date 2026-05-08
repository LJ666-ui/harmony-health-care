package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 家属认证日志实体类
 */
@Data
@TableName("family_auth_log")
public class FamilyAuthLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long familyId;        // 家属ID
    private Date loginTime;       // 登录时间
    private String loginIp;       // 登录IP地址
    private String loginDevice;   // 登录设备信息
    private Integer loginResult;  // 登录结果：1-成功，0-失败
    private String failReason;    // 失败原因
    private Date createTime;      // 创建时间
}
