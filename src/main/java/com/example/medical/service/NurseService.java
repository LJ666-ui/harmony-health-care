package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.dto.NurseLoginRequest;
import com.example.medical.dto.NurseLoginResponse;
import com.example.medical.dto.NurseUpdateRequest;
import com.example.medical.entity.Nurse;

/**
 * 护士Service接口
 */
public interface NurseService extends IService<Nurse> {

    /**
     * 护士登录
     */
    NurseLoginResponse login(NurseLoginRequest request);

    /**
     * 根据手机号查询护士信息
     */
    Nurse findByPhone(String phone);

    /**
     * 根据用户ID查询护士信息
     */
    Nurse findByUserId(Long userId);

    /**
     * 根据护士工号查询护士信息
     */
    Nurse findByNurseNo(String nurseNo);

    /**
     * 更新护士信息
     */
    Nurse updateNurseInfo(Long nurseId, NurseUpdateRequest request);

    /**
     * 根据Token获取护士信息
     */
    Nurse getNurseByToken(String token);
}
