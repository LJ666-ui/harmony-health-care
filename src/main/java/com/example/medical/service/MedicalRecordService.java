package com.example.medical.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.MedicalRecord;

public interface MedicalRecordService extends IService<MedicalRecord> {

    /**
     * 创建病历
     */
    boolean createMedicalRecord(MedicalRecord medicalRecord);

    /**
     * 分页查询病历
     */
    Page<MedicalRecord> getMedicalRecordPage(Page<MedicalRecord> page, Long userId, Long hospitalId, Long doctorId);

    /**
     * 根据ID查询病历
     */
    MedicalRecord getMedicalRecordById(Long id);

    /**
     * 更新病历
     */
    boolean updateMedicalRecord(MedicalRecord medicalRecord);

    /**
     * 删除病历
     */
    boolean deleteMedicalRecord(Long id);

    /**
     * 脱敏处理
     */
    MedicalRecord desensitizeMedicalRecord(MedicalRecord medicalRecord);

}
