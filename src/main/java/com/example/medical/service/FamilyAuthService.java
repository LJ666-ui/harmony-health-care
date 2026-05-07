package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.dto.FamilyLoginRequest;
import com.example.medical.dto.FamilyLoginResponse;
import com.example.medical.entity.FamilyMember;

/**
 * 家属认证服务接口
 */
public interface FamilyAuthService extends IService<FamilyMember> {

    /**
     * 家属登录
     */
    FamilyLoginResponse login(FamilyLoginRequest request);

    /**
     * 获取家属信息
     */
    FamilyMember getFamilyInfo(Long familyId);

    /**
     * 开启/关闭家属登录权限
     */
    boolean updateLoginEnabled(Long familyId, Integer loginEnabled, String defaultPassword);
}
