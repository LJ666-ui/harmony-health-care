package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.MedicalRecord;
import com.example.medical.service.MedicalRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/medical/record")
public class MedicalRecordController {

    @Autowired
    private MedicalRecordService medicalRecordService;

    /**
     * 创建病历
     */
    @PostMapping("/create")
    public Map<String, Object> createMedicalRecord(@RequestBody MedicalRecord medicalRecord) {
        Map<String, Object> result = new HashMap<>();
        boolean success = medicalRecordService.createMedicalRecord(medicalRecord);
        result.put("success", success);
        result.put("message", success ? "创建成功" : "创建失败");
        return result;
    }

    /**
     * 分页查询病历
     */
    @GetMapping("/page")
    public Map<String, Object> getMedicalRecordPage(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            Long userId,
            Long hospitalId,
            Long doctorId) {
        Map<String, Object> result = new HashMap<>();
        Page<MedicalRecord> page = new Page<>(pageNum, pageSize);
        Page<MedicalRecord> recordPage = medicalRecordService.getMedicalRecordPage(page, userId, hospitalId, doctorId);
        result.put("success", true);
        result.put("data", recordPage);
        return result;
    }

    /**
     * 根据ID查询病历（完整）
     * 仅授权医生可查看
     */
    @GetMapping("/detail")
    public Map<String, Object> getMedicalRecordDetail(@RequestParam Long id) {
        Map<String, Object> result = new HashMap<>();
        MedicalRecord medicalRecord = medicalRecordService.getMedicalRecordById(id);
        if (medicalRecord != null) {
            result.put("success", true);
            result.put("data", medicalRecord);
        } else {
            result.put("success", false);
            result.put("message", "病历不存在");
        }
        return result;
    }

    /**
     * 根据ID查询脱敏病历
     * 患者可查看
     */
    @GetMapping("/desensitized")
    public Map<String, Object> getDesensitizedMedicalRecord(@RequestParam Long id) {
        Map<String, Object> result = new HashMap<>();
        MedicalRecord medicalRecord = medicalRecordService.getMedicalRecordById(id);
        if (medicalRecord != null) {
            MedicalRecord desensitizedRecord = medicalRecordService.desensitizeMedicalRecord(medicalRecord);
            result.put("success", true);
            result.put("data", desensitizedRecord);
        } else {
            result.put("success", false);
            result.put("message", "病历不存在");
        }
        return result;
    }

    /**
     * 更新病历
     */
    @PutMapping("/update")
    public Map<String, Object> updateMedicalRecord(@RequestBody MedicalRecord medicalRecord) {
        Map<String, Object> result = new HashMap<>();
        boolean success = medicalRecordService.updateMedicalRecord(medicalRecord);
        result.put("success", success);
        result.put("message", success ? "更新成功" : "更新失败");
        return result;
    }

    /**
     * 删除病历
     */
    @DeleteMapping("/delete")
    public Map<String, Object> deleteMedicalRecord(@RequestParam Long id) {
        Map<String, Object> result = new HashMap<>();
        boolean success = medicalRecordService.deleteMedicalRecord(id);
        result.put("success", success);
        result.put("message", success ? "删除成功" : "删除失败");
        return result;
    }

}
