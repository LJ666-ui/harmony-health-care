package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.PrescriptionTemplate;
import com.example.medical.mapper.PrescriptionTemplateMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 处方模板服务类
 */
@Service
public class PrescriptionTemplateService {

    @Autowired
    private PrescriptionTemplateMapper prescriptionTemplateMapper;

    /**
     * 创建处方模板
     */
    public PrescriptionTemplate create(PrescriptionTemplate template) {
        template.setUsageCount(0);
        template.setCreatedAt(LocalDateTime.now());
        template.setUpdatedAt(LocalDateTime.now());
        prescriptionTemplateMapper.insert(template);
        return template;
    }

    /**
     * 获取医生的处方模板列表
     */
    public List<PrescriptionTemplate> getByDoctorId(Long doctorId) {
        QueryWrapper<PrescriptionTemplate> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("doctor_id", doctorId);
        queryWrapper.orderByDesc("usage_count");
        return prescriptionTemplateMapper.selectList(queryWrapper);
    }

    /**
     * 获取公开的处方模板列表
     */
    public List<PrescriptionTemplate> getPublicTemplates() {
        QueryWrapper<PrescriptionTemplate> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_public", 1);
        queryWrapper.orderByDesc("usage_count");
        return prescriptionTemplateMapper.selectList(queryWrapper);
    }

    /**
     * 获取处方模板详情
     */
    public PrescriptionTemplate getById(Long id) {
        return prescriptionTemplateMapper.selectById(id);
    }

    /**
     * 更新处方模板
     */
    public PrescriptionTemplate update(PrescriptionTemplate template) {
        template.setUpdatedAt(LocalDateTime.now());
        prescriptionTemplateMapper.updateById(template);
        return template;
    }

    /**
     * 删除处方模板
     */
    public boolean delete(Long id) {
        return prescriptionTemplateMapper.deleteById(id) > 0;
    }

    /**
     * 使用模板（增加使用次数）
     */
    public PrescriptionTemplate useTemplate(Long id) {
        PrescriptionTemplate template = prescriptionTemplateMapper.selectById(id);
        if (template != null) {
            template.setUsageCount(template.getUsageCount() + 1);
            template.setUpdatedAt(LocalDateTime.now());
            prescriptionTemplateMapper.updateById(template);
        }
        return template;
    }
}
