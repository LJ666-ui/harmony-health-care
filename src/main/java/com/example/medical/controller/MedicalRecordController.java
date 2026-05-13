package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.Doctor;
import com.example.medical.entity.Hospital;
import com.example.medical.entity.MedicalRecord;
import com.example.medical.service.DoctorService;
import com.example.medical.service.HospitalService;
import com.example.medical.service.MedicalRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/medical/record")
public class MedicalRecordController {

    @Autowired
    private MedicalRecordService medicalRecordService;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private HospitalService hospitalService;

    /**
     * 创建病历
     */
    @PostMapping("/create")
    public Result<?> createMedicalRecord(@RequestBody MedicalRecord medicalRecord) {
        try {
            if (medicalRecord.getIsDeleted() == null) {
                medicalRecord.setIsDeleted(0);
            }
            boolean success = medicalRecordService.createMedicalRecord(medicalRecord);
            if (success) {
                return Result.success("创建成功");
            } else {
                return Result.error("创建失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("创建失败：" + e.getMessage());
        }
    }

    /**
     * 获取用户的病历列表（家属端/患者端）
     * GET /medical/record/my
     */
    @GetMapping("/my")
    public Result<?> getMyMedicalRecords(
            @RequestParam Long userId,
            @RequestParam(required = false) Integer pageNum,
            @RequestParam(required = false) Integer pageSize) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        
        try {
            LambdaQueryWrapper<MedicalRecord> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(MedicalRecord::getUserId, userId);
            wrapper.eq(MedicalRecord::getIsDeleted, 0);
            wrapper.orderByDesc(MedicalRecord::getRecordTime);
            
            List<MedicalRecord> records;
            long total;
            
            if (pageNum != null && pageSize != null && pageNum > 0 && pageSize > 0) {
                Page<MedicalRecord> page = new Page<>(pageNum, pageSize);
                Page<MedicalRecord> recordPage = medicalRecordService.page(page, wrapper);
                records = recordPage.getRecords();
                total = recordPage.getTotal();
            } else {
                records = medicalRecordService.list(wrapper);
                total = records.size();
            }
            
            // 转换为前端期望的格式
            List<Map<String, Object>> formattedRecords = new java.util.ArrayList<>();
            for (MedicalRecord record : records) {
                Map<String, Object> formattedRecord = new HashMap<>();
                formattedRecord.put("id", record.getId());
                formattedRecord.put("userId", record.getUserId());
                
                // 获取医院信息
                String hospitalName = "未知医院";
                String department = "";
                if (record.getHospitalId() != null) {
                    Hospital hospital = hospitalService.getById(record.getHospitalId());
                    if (hospital != null) {
                        hospitalName = hospital.getName();
                        department = hospital.getDepartment();
                    }
                }
                formattedRecord.put("hospitalName", hospitalName);
                formattedRecord.put("department", department);
                
                // 获取医生信息
                String doctorName = "未知医生";
                if (record.getDoctorId() != null) {
                    Doctor doctor = doctorService.getById(record.getDoctorId());
                    if (doctor != null) {
                        doctorName = doctor.getRealName();
                        if (doctor.getDepartment() != null && !doctor.getDepartment().isEmpty()) {
                            department = doctor.getDepartment();
                            formattedRecord.put("department", department);
                        }
                    }
                }
                formattedRecord.put("doctorName", doctorName);
                
                // 病历信息
                formattedRecord.put("diagnosis", record.getDiagnosis());
                formattedRecord.put("treatmentPlan", record.getTreatment());
                formattedRecord.put("medicationAdvice", ""); // 从处方表获取，暂时为空
                
                // 时间信息
                String visitTime = "";
                if (record.getRecordTime() != null) {
                    visitTime = record.getRecordTime().format(formatter);
                }
                formattedRecord.put("visitTime", visitTime);
                
                String createTime = "";
                if (record.getCreateTime() != null) {
                    createTime = record.getCreateTime().format(formatter);
                }
                formattedRecord.put("createTime", createTime);
                
                formattedRecords.add(formattedRecord);
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("list", formattedRecords);
            result.put("total", total);
            
            return Result.success(formattedRecords);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取病历失败：" + e.getMessage());
        }
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
