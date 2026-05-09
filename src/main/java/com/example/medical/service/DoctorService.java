package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.Doctor;
import java.util.List;
import java.util.Map;

public interface DoctorService extends IService<Doctor> {
    Doctor getByUserId(Long userId);
    Doctor findByPhone(String phone);
    Doctor findById(Long id);
    List<Map<String, Object>> getPatientsByDoctorId(Long doctorId);
}
