package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.MedicalRecordTemplate;
import com.example.medical.service.MedicalRecordTemplateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "病历模板管理")
@RestController
@RequestMapping("/api/doctor")
public class MedicalRecordTemplateController {

    @Autowired
    private MedicalRecordTemplateService medicalRecordTemplateService;

    @Operation(summary = "创建病历模板")
    @PostMapping("/medical-record-template")
    public Result<MedicalRecordTemplate> create(@RequestBody MedicalRecordTemplate template) {
        MedicalRecordTemplate result = medicalRecordTemplateService.create(template);
        return Result.success(result);
    }

    @Operation(summary = "获取医生的病历模板列表")
    @GetMapping("/{doctorId}/medical-record-templates")
    public Result<List<MedicalRecordTemplate>> getByDoctorId(@PathVariable Long doctorId) {
        List<MedicalRecordTemplate> result = medicalRecordTemplateService.getByDoctorId(doctorId);
        return Result.success(result);
    }

    @Operation(summary = "获取公开的病历模板列表")
    @GetMapping("/medical-record-templates/public")
    public Result<List<MedicalRecordTemplate>> getPublicTemplates() {
        List<MedicalRecordTemplate> result = medicalRecordTemplateService.getPublicTemplates();
        return Result.success(result);
    }

    @Operation(summary = "获取病历模板详情")
    @GetMapping("/medical-record-template/{id}")
    public Result<MedicalRecordTemplate> getById(@PathVariable Long id) {
        MedicalRecordTemplate result = medicalRecordTemplateService.getById(id);
        return Result.success(result);
    }

    @Operation(summary = "更新病历模板")
    @PutMapping("/medical-record-template/{id}")
    public Result<MedicalRecordTemplate> update(@PathVariable Long id, @RequestBody MedicalRecordTemplate template) {
        template.setId(id);
        MedicalRecordTemplate result = medicalRecordTemplateService.update(template);
        return Result.success(result);
    }

    @Operation(summary = "删除病历模板")
    @DeleteMapping("/medical-record-template/{id}")
    public Result<Boolean> delete(@PathVariable Long id) {
        boolean result = medicalRecordTemplateService.delete(id);
        return Result.success(result);
    }

    @Operation(summary = "使用模板")
    @PostMapping("/medical-record-template/{id}/use")
    public Result<MedicalRecordTemplate> useTemplate(@PathVariable Long id) {
        MedicalRecordTemplate result = medicalRecordTemplateService.useTemplate(id);
        return Result.success(result);
    }
}
