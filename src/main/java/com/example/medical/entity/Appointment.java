package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 预约挂号实体类
 * 对应数据库表：appointment
 */
@Data
@TableName("appointment")
public class Appointment {
    
    /**
     * 预约ID（主键，自增）
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户ID（预约人）
     */
    private Long userId;
    
    /**
     * 医生ID
     */
    private Long doctorId;
    
    /**
     * 医院ID
     */
    private Long hospitalId;
    
    /**
     * 科室ID
     */
    private Long departmentId;
    
    /**
     * 预约日期（格式：yyyy-MM-dd）
     */
    private String appointmentDate;
    
    /**
     * 预约时段（如：上午、下午、08:00-09:00等）
     */
    private String timeSlot;
    
    /**
     * 预约状态（0-已取消，1-待就诊，2-已就诊，3-已过期）
     */
    private Integer status;
    
    /**
     * 患者姓名
     */
    private String patientName;
    
    /**
     * 患者手机号
     */
    private String patientPhone;
    
    /**
     * 患者身份证号
     */
    private String patientIdCard;
    
    /**
     * 病情描述
     */
    private String symptomDescription;
    
    /**
     * 挂号费用
     */
    private Double registrationFee;
    
    /**
     * 支付状态（0-未支付，1-已支付）
     */
    private Integer paymentStatus;
    
    /**
     * 排队号
     */
    private Integer queueNumber;
    
    /**
     * 备注
     */
    private String remark;
    
    /**
     * 创建时间
     */
    private Date createTime;
    
    /**
     * 更新时间
     */
    private Date updateTime;
    
    /**
     * 是否删除（0-未删除，1-已删除）
     */
    private Integer isDeleted;
}
