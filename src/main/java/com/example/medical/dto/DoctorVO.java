package com.example.medical.dto;

import lombok.Data;

import java.util.Date;

@Data
public class DoctorVO {
    private Long id;
    private Long userId;

    private String hospital;
    private String department;
    private String licenseNumber;
    private String title;
    private String specialty;
    private String description;
    private Double rating;
    private Integer status;
    private Date createTime;
    private Date updateTime;
    private Integer isDeleted;

    private String realName;
    private String phone;
    private String avatar;
    private String username;
    private Integer age;
}
