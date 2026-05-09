package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Doctor;
import com.example.medical.mapper.DoctorMapper;
import com.example.medical.service.DoctorService;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;

@Service
public class DoctorServiceImpl extends ServiceImpl<DoctorMapper, Doctor> implements DoctorService {
    @Override
    public Doctor getByUserId(Long userId) {
        return lambdaQuery().eq(Doctor::getUserId, userId).eq(Doctor::getIsDeleted, 0).one();
    }

    @Override
    public Doctor findByPhone(String phone) {
        return lambdaQuery().eq(Doctor::getPhone, phone).eq(Doctor::getIsDeleted, 0).one();
    }

    @Override
    public Doctor findById(Long id) {
        return lambdaQuery().eq(Doctor::getId, id).eq(Doctor::getIsDeleted, 0).one();
    }

    @Override
    public List<Map<String, Object>> getPatientsByDoctorId(Long doctorId) {
        // TODO: 实现查询医生的患者列表
        // 这里返回空列表，实际应该从数据库查询
        return new ArrayList<>();
    }
}
