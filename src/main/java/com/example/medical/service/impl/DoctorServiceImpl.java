package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Doctor;
import com.example.medical.mapper.DoctorMapper;
import com.example.medical.service.DoctorService;
import org.springframework.stereotype.Service;

@Service
public class DoctorServiceImpl extends ServiceImpl<DoctorMapper, Doctor> implements DoctorService {
    @Override
    public Doctor getByUserId(Long userId) {
        return lambdaQuery().eq(Doctor::getUserId, userId).eq(Doctor::getIsDeleted, 0).one();
    }
}
