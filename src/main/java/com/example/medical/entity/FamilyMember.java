package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 家属信息实体类
 */
@Data
@TableName("family_member")
public class FamilyMember {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;              // 关联用户ID
    private String name;              // 家属姓名
    private String relation;          // 与用户关系
    private String phone;             // 手机号
    private String idCard;            // 身份证号
    private Integer gender;           // 性别：0-未知，1-男，2-女
    private Integer age;              // 年龄
    private String address;           // 地址
    private Integer isEmergencyContact; // 是否紧急联系人：0-否，1-是
    private String healthCondition;   // 健康状况

    // 登录相关字段
    private String password;          // 登录密码（BCrypt加密）
    private String username;          // 登录用户名（可选）
    private Integer loginEnabled;     // 是否允许登录：0-否，1-是
    private Integer loginFailCount;   // 登录失败次数
    private Date lockUntil;           // 账号锁定截止时间
    private Date lastLoginTime;       // 最后登录时间

    // 通用字段
    private Date createTime;          // 创建时间
    private Date updateTime;          // 更新时间
    private Integer isDeleted;        // 逻辑删除：0-未删除，1-已删除
}
