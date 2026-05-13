package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.dto.DoctorVO;
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
import java.util.stream.Collectors;

@Service
public class DoctorServiceImpl extends ServiceImpl<DoctorMapper, Doctor> implements DoctorService {

    @Autowired
    private UserService userService;

    @Override
    public Doctor getByUserId(Long userId) {
        return lambdaQuery().eq(Doctor::getUserId, userId).eq(Doctor::getIsDeleted, 0).one();
    }

    @Override
    public Doctor findByPhone(String phone) {
        User user = userService.lambdaQuery()
                .eq(User::getPhone, phone)
                .eq(User::getUserType, 1)
                .one();
        
        if (user == null) {
            return null;
        }
        
        return getByUserId(user.getId());
    }

    @Override
    public Doctor findById(Long id) {
        return lambdaQuery().eq(Doctor::getId, id).eq(Doctor::getIsDeleted, 0).one();
    }

    @Override
    public List<Map<String, Object>> getPatientsByDoctorId(Long doctorId) {
        return new ArrayList<>();
    }

    @Override
    public DoctorVO getDoctorVO(Long doctorId) {
        Doctor doctor = this.getById(doctorId);
        if (doctor == null || doctor.getIsDeleted() != null && doctor.getIsDeleted() == 1) {
            return null;
        }
        
        User user = userService.getById(doctor.getUserId());
        
        DoctorVO vo = new DoctorVO();
        vo.setId(doctor.getId());
        vo.setUserId(doctor.getUserId());
        vo.setHospital(doctor.getHospital());
        vo.setDepartment(doctor.getDepartment());
        vo.setLicenseNumber(doctor.getLicenseNumber());
        vo.setTitle(doctor.getTitle());
        vo.setSpecialty(doctor.getSpecialty());
        vo.setDescription(doctor.getDescription());
        vo.setRating(doctor.getRating());
        vo.setStatus(doctor.getStatus());
        vo.setCreateTime(doctor.getCreateTime());
        vo.setUpdateTime(doctor.getUpdateTime());
        vo.setIsDeleted(doctor.getIsDeleted());
        
        if (user != null) {
            vo.setRealName(user.getRealName());
            vo.setPhone(user.getPhone());
            vo.setAvatar(user.getAvatar());
            vo.setUsername(user.getUsername());
            vo.setAge(user.getAge());
        }
        
        return vo;
    }

    @Override
    public List<DoctorVO> getDoctorVOList() {
        List<Doctor> doctors = this.list();
        
        return doctors.stream()
                .filter(d -> d.getIsDeleted() == null || d.getIsDeleted() != 1)
                .map(doctor -> this.getDoctorVO(doctor.getId()))
                .collect(Collectors.toList());
    }
}
