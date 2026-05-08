package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.dto.NurseLoginRequest;
import com.example.medical.dto.NurseLoginResponse;
import com.example.medical.dto.NurseUpdateRequest;
import com.example.medical.entity.Nurse;
import com.example.medical.entity.User;
import com.example.medical.mapper.NurseMapper;
import com.example.medical.mapper.UserMapper;
import com.example.medical.service.NurseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * 护士Service实现类
 */
@Service
public class NurseServiceImpl extends ServiceImpl<NurseMapper, Nurse> implements NurseService {

    @Autowired
    private NurseMapper nurseMapper;

    @Autowired
    private UserMapper userMapper;

    @Override
    public NurseLoginResponse login(NurseLoginRequest request) {
        // 1. 根据手机号查询护士信息
        Nurse nurse = nurseMapper.selectByPhone(request.getPhone());
        if (nurse == null) {
            throw new RuntimeException("手机号不存在或不是护士账号");
        }

        // 2. 检查护士状态
        if (nurse.getStatus() == null || nurse.getStatus() != 1) {
            throw new RuntimeException("护士账号已离职或不可用");
        }

        // 3. 查询关联的用户信息
        User user = userMapper.selectById(nurse.getUserId());
        if (user == null) {
            throw new RuntimeException("关联用户信息不存在");
        }

        // 4. 验证密码
        if (!BCryptUtil.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("密码错误");
        }

        // 5. 生成护士Token
        String token = JwtUtil.generateNurseToken(nurse.getId(), nurse.getPhone());

        // 6. 构建响应
        NurseLoginResponse response = new NurseLoginResponse();
        response.setToken(token);
        response.setNurseInfo(nurse);
        response.setRelatedUser(user);

        return response;
    }

    @Override
    public Nurse findByPhone(String phone) {
        return nurseMapper.selectByPhone(phone);
    }

    @Override
    public Nurse findByUserId(Long userId) {
        return nurseMapper.selectByUserId(userId);
    }

    @Override
    public Nurse findByNurseNo(String nurseNo) {
        return nurseMapper.selectByNurseNo(nurseNo);
    }

    @Override
    public Nurse updateNurseInfo(Long nurseId, NurseUpdateRequest request) {
        Nurse nurse = nurseMapper.selectById(nurseId);
        if (nurse == null) {
            throw new RuntimeException("护士信息不存在");
        }

        // 更新字段
        if (request.getName() != null) {
            nurse.setName(request.getName());
        }
        if (request.getGender() != null) {
            nurse.setGender(request.getGender());
        }
        if (request.getPhone() != null) {
            nurse.setPhone(request.getPhone());
        }
        if (request.getDepartment() != null) {
            nurse.setDepartment(request.getDepartment());
        }
        if (request.getTitle() != null) {
            nurse.setTitle(request.getTitle());
        }
        if (request.getCertificateNo() != null) {
            nurse.setCertificateNo(request.getCertificateNo());
        }
        if (request.getWorkYears() != null) {
            nurse.setWorkYears(request.getWorkYears());
        }
        if (request.getAvatar() != null) {
            nurse.setAvatar(request.getAvatar());
        }

        nurse.setUpdateTime(new Date());
        nurseMapper.updateById(nurse);

        return nurse;
    }

    @Override
    public Nurse getNurseByToken(String token) {
        if (!JwtUtil.isNurseToken(token)) {
            throw new RuntimeException("无效的护士Token");
        }

        Long nurseId = JwtUtil.getNurseId(token);
        if (nurseId == null) {
            throw new RuntimeException("无法获取护士信息");
        }

        return nurseMapper.selectById(nurseId);
    }
}
