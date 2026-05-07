package com.example.medical.dto;

import com.example.medical.entity.Nurse;
import com.example.medical.entity.User;
import lombok.Data;

/**
 * 护士登录响应DTO
 */
@Data
public class NurseLoginResponse {

    private String token;          // JWT Token
    private Nurse nurseInfo;       // 护士信息
    private User relatedUser;      // 关联用户信息
}
