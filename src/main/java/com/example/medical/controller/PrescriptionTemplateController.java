package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.PrescriptionTemplate;
import com.example.medical.service.PrescriptionTemplateService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 处方模板控制器
 */
@Api(tags = "处方模板管理")
@RestController
@RequestMapping("/api/doctor")
public class PrescriptionTemplateController {

    @Autowired
    private PrescriptionTemplateService prescriptionTemplateService;

    /**
     * 创建处方模板
     */
    @ApiOperation("创建处方模板")
    @PostMapping("/prescription-template")
    public Result<PrescriptionTemplate> create(@RequestBody PrescriptionTemplate template) {
        PrescriptionTemplate result = prescriptionTemplateService.create(template);
        return Result.success(result);
    }

    /**
     * 获取医生的处方模板列表
     */
    @ApiOperation("获取医生的处方模板列表")
    @GetMapping("/{doctorId}/prescription-templates")
    public Result<List<PrescriptionTemplate>> getByDoctorId(@PathVariable Long doctorId) {
        List<PrescriptionTemplate> result = prescriptionTemplateService.getByDoctorId(doctorId);
        return Result.success(result);
    }

    /**
     * 获取公开的处方模板列表
     */
    @ApiOperation("获取公开的处方模板列表")
    @GetMapping("/prescription-templates/public")
    public Result<List<PrescriptionTemplate>> getPublicTemplates() {
        List<PrescriptionTemplate> result = prescriptionTemplateService.getPublicTemplates();
        return Result.success(result);
    }

    /**
     * 获取处方模板详情
     */
    @ApiOperation("获取处方模板详情")
    @GetMapping("/prescription-template/{id}")
    public Result<PrescriptionTemplate> getById(@PathVariable Long id) {
        PrescriptionTemplate result = prescriptionTemplateService.getById(id);
        return Result.success(result);
    }

    /**
     * 更新处方模板
     */
    @ApiOperation("更新处方模板")
    @PutMapping("/prescription-template/{id}")
    public Result<PrescriptionTemplate> update(@PathVariable Long id, @RequestBody PrescriptionTemplate template) {
        template.setId(id);
        PrescriptionTemplate result = prescriptionTemplateService.update(template);
        return Result.success(result);
    }

    /**
     * 删除处方模板
     */
    @ApiOperation("删除处方模板")
    @DeleteMapping("/prescription-template/{id}")
    public Result<Boolean> delete(@PathVariable Long id) {
        boolean result = prescriptionTemplateService.delete(id);
        return Result.success(result);
    }

    /**
     * 使用模板（增加使用次数）
     */
    @ApiOperation("使用模板")
    @PostMapping("/prescription-template/{id}/use")
    public Result<PrescriptionTemplate> useTemplate(@PathVariable Long id) {
        PrescriptionTemplate result = prescriptionTemplateService.useTemplate(id);
        return Result.success(result);
    }
}
