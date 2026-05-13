package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 异常登录记录实体类
 * 对应数据库表：abnormal_login
 */
@Data
@TableName("abnormal_login")
public class AbnormalLogin implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 登录时间
     */
    private LocalDateTime loginTime;

    /**
     * 登录地点
     */
    private String loginLocation;

    /**
     * 设备信息
     */
    private String deviceInfo;

    /**
     * IP地址
     */
    private String ipAddress;

    /**
     * 异常原因：abnormal_location-异地登录, abnormal_device-异常设备, abnormal_time-异常时间
     */
    private String abnormalReason;

    /**
     * 风险等级：low-低, medium-中, high-高
     */
    private String riskLevel;

    /**
     * 是否已处理：0-未处理，1-已处理
     */
    private Integer isHandled;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}
