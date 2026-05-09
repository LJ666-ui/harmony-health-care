package com.example.medical.dto;

import com.example.medical.entity.FamilyMember;
import com.example.medical.entity.User;
import lombok.Data;

/**
 * 家属登录响应DTO
 */
@Data
public class FamilyLoginResponse {

    private String token;              // JWT Token
    private FamilyMember familyInfo;   // 家属信息
    private User relatedUser;          // 关联用户信息
}
