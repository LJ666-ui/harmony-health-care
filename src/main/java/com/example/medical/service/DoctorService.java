package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.Doctor;

public interface DoctorService extends IService<Doctor> {
    Doctor getByUserId(Long userId);
}
