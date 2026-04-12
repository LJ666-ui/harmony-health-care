package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.MedicalRecord;
import com.example.medical.mapper.MedicalRecordMapper;
import com.example.medical.service.MedicalRecordService;
import org.springframework.stereotype.Service;

@Service
public class MedicalRecordServiceImpl extends ServiceImpl<MedicalRecordMapper, MedicalRecord> implements MedicalRecordService {

    @Override
    public boolean createMedicalRecord(MedicalRecord medicalRecord) {
        return save(medicalRecord);
    }

    @Override
    public Page<MedicalRecord> getMedicalRecordPage(Page<MedicalRecord> page, Long userId, Long hospitalId, Long doctorId) {
        LambdaQueryWrapper<MedicalRecord> queryWrapper = new LambdaQueryWrapper<>();
        if (userId != null) {
            queryWrapper.eq(MedicalRecord::getUserId, userId);
        }
        if (hospitalId != null) {
            queryWrapper.eq(MedicalRecord::getHospitalId, hospitalId);
        }
        if (doctorId != null) {
            queryWrapper.eq(MedicalRecord::getDoctorId, doctorId);
        }
        return page(page, queryWrapper);
    }

    @Override
    public MedicalRecord getMedicalRecordById(Long id) {
        return getById(id);
    }

    @Override
    public boolean updateMedicalRecord(MedicalRecord medicalRecord) {
        return updateById(medicalRecord);
    }

    @Override
    public boolean deleteMedicalRecord(Long id) {
        return removeById(id);
    }

    @Override
    public MedicalRecord desensitizeMedicalRecord(MedicalRecord medicalRecord) {
        if (medicalRecord == null) {
            return null;
        }
        // 这里需要根据实际情况处理脱敏，例如处理用户相关的敏感信息
        // 假设用户信息存储在其他表中，这里模拟手机号脱敏
        // 实际项目中可能需要关联查询用户表获取手机号进行脱敏
        // 这里仅作为示例
        return medicalRecord;
    }

    /**
     * 手机号脱敏方法
     */
    public String desensitizePhone(String phone) {
        if (phone == null || phone.length() != 11) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(7);
    }

}
