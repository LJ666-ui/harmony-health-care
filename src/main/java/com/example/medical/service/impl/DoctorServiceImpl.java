package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Doctor;
import com.example.medical.entity.User;
import com.example.medical.mapper.DoctorMapper;
import com.example.medical.service.DoctorService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;

@Service
public class DoctorServiceImpl extends ServiceImpl<DoctorMapper, Doctor> implements DoctorService {

    @Autowired
    private UserService userService;

    @Override
    public Doctor getByUserId(Long userId) {
        Doctor doctor = lambdaQuery().eq(Doctor::getUserId, userId).eq(Doctor::getIsDeleted, 0).one();
        if (doctor != null) {
            User user = userService.getById(userId);
            if (user != null) {
                doctor.setRealName(user.getRealName());
                doctor.setPhone(user.getPhone());
                doctor.setAvatar(user.getAvatar());
            }
        }
        return doctor;
    }

    @Override
    public Doctor findByPhone(String phone) {
        User user = userService.findByPhone(phone);
        if (user != null) {
            return getByUserId(user.getId());
        }
        return null;
    }

    @Override
    public Doctor findById(Long id) {
        Doctor doctor = lambdaQuery().eq(Doctor::getId, id).eq(Doctor::getIsDeleted, 0).one();
        if (doctor != null && doctor.getUserId() != null) {
            User user = userService.getById(doctor.getUserId());
            if (user != null) {
                doctor.setRealName(user.getRealName());
                doctor.setPhone(user.getPhone());
                doctor.setAvatar(user.getAvatar());
            }
        }
        return doctor;
    }

    @Override
    public List<Map<String, Object>> getPatientsByDoctorId(Long doctorId) {
        // TODO: 实现查询医生的患者列表
        // 这里返回空列表，实际应该从数据库查询
        return new ArrayList<>();
    }
}
