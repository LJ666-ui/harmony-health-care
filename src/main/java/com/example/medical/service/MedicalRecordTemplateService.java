package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.medical.entity.MedicalRecordTemplate;
import com.example.medical.mapper.MedicalRecordTemplateMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 病历模板服务类
 */
@Service
public class MedicalRecordTemplateService {

    @Autowired
    private MedicalRecordTemplateMapper medicalRecordTemplateMapper;

    /**
     * 创建病历模板
     */
    public MedicalRecordTemplate create(MedicalRecordTemplate template) {
        template.setUsageCount(0);
        template.setCreatedAt(LocalDateTime.now());
        template.setUpdatedAt(LocalDateTime.now());
        medicalRecordTemplateMapper.insert(template);
        return template;
    }

    /**
     * 获取医生的病历模板列表
     */
    public List<MedicalRecordTemplate> getByDoctorId(Long doctorId) {
        QueryWrapper<MedicalRecordTemplate> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("doctor_id", doctorId);
        queryWrapper.orderByDesc("usage_count");
        return medicalRecordTemplateMapper.selectList(queryWrapper);
    }

    /**
     * 获取公开的病历模板列表
     */
    public List<MedicalRecordTemplate> getPublicTemplates() {
        QueryWrapper<MedicalRecordTemplate> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_public", 1);
        queryWrapper.orderByDesc("usage_count");
        return medicalRecordTemplateMapper.selectList(queryWrapper);
    }

    /**
     * 获取病历模板详情
     */
    public MedicalRecordTemplate getById(Long id) {
        return medicalRecordTemplateMapper.selectById(id);
    }

    /**
     * 更新病历模板
     */
    public MedicalRecordTemplate update(MedicalRecordTemplate template) {
        template.setUpdatedAt(LocalDateTime.now());
        medicalRecordTemplateMapper.updateById(template);
        return template;
    }

    /**
     * 删除病历模板
     */
    public boolean delete(Long id) {
        return medicalRecordTemplateMapper.deleteById(id) > 0;
    }

    /**
     * 使用模板（增加使用次数）
     */
    public MedicalRecordTemplate useTemplate(Long id) {
        MedicalRecordTemplate template = medicalRecordTemplateMapper.selectById(id);
        if (template != null) {
            template.setUsageCount(template.getUsageCount() + 1);
            template.setUpdatedAt(LocalDateTime.now());
            medicalRecordTemplateMapper.updateById(template);
        }
        return template;
    }
}
