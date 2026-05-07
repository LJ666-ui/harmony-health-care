package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.util.Date;

@Data
@TableName("admin")
public class Admin {
    @TableId(type = IdType.AUTO)
    private Long id;

    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 50, message = "用户名长度必须在3-50个字符之间")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 100, message = "密码长度必须在6-100个字符之间")
    private String password;

    @TableField("real_name")
    private String realName;

    private String phone;

    private String email;

    private String avatar;

    private Integer role;

    private Integer status;

    @TableField("last_login_time")
    private Date lastLoginTime;

    @TableField("last_login_ip")
    private String lastLoginIp;

    @TableField("create_time")
    private Date createTime;

    @TableField("update_time")
    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;

    @TableField("user_id")
    private Long userId;
}
