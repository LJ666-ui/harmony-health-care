package com.example.medical.dto;

import lombok.Data;

import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

/**
 * 护士信息更新请求DTO
 */
@Data
public class NurseUpdateRequest {

    /**
     * 真实姓名
     */
    @Size(min = 2, max = 50, message = "姓名长度必须在2-50个字符之间")
    private String name;

    /**
     * 手机号
     */
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    /**
     * 所属科室
     */
    private String department;

    /**
     * 职称
     */
    private String title;

    /**
     * 头像URL
     */
    private String avatar;
}