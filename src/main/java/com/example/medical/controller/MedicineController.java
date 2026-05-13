package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.Medicine;
import com.example.medical.service.MedicineService;
import com.example.medical.service.PatientMedicationRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/medicine")
public class MedicineController {

    @Autowired
    private MedicineService medicineService;

    @Autowired
    private PatientMedicationRecordService patientMedicationRecordService;

    @GetMapping("/list")
    public Result<List<Medicine>> list(@RequestParam(required = false) String categoryCode) {
        List<Medicine> dataList;
        if (categoryCode != null && !categoryCode.isEmpty()) {
            dataList = medicineService.findByCategoryCode(categoryCode);
        } else {
            dataList = medicineService.list();
        }
        System.out.println("数据库数据：" + dataList);
        return Result.success(dataList);
    }

    @GetMapping("/medication-list")
    public Result<List<Map<String, Object>>> getMedicationList(
            @RequestParam(required = false) Long nurseId,
            @RequestParam(required = false) Long patientId) {
        
        try {
            List<Map<String, Object>> result;
            
            if (nurseId != null) {
                result = patientMedicationRecordService.getMedicationListByNurseId(nurseId);
            } else if (patientId != null) {
                result = patientMedicationRecordService.getMedicationListByPatientId(patientId);
            } else {
                return Result.error("请提供nurseId或patientId参数");
            }
            
            System.out.println("用药记录数据：" + result);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取用药记录失败：" + e.getMessage());
        }
    }

    @PostMapping("/medication-confirm/{id}")
    public Result<Boolean> confirmMedication(
            @PathVariable Long id,
            @RequestBody Map<String, Long> requestBody) {
        
        try {
            Long nurseId = requestBody.get("nurseId");
            if (nurseId == null) {
                return Result.error("缺少nurseId参数");
            }
            
            boolean success = patientMedicationRecordService.confirmMedication(id, nurseId);
            
            if (success) {
                return Result.success(true);
            } else {
                return Result.error("确认失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("确认失败：" + e.getMessage());
        }
    }

    @GetMapping("/page")
    public Result<Page<Medicine>> page(@RequestParam(defaultValue = "1") Integer current, 
                              @RequestParam(defaultValue = "10") Integer size, 
                              @RequestParam(required = false) String sortField, 
                              @RequestParam(required = false) String sortOrder) {
        Page<Medicine> page = new Page<>(current, size);
        Page<Medicine> result = medicineService.page(page);
        return Result.success(result);
    }

    @GetMapping("/search")
    public Result<Page<Medicine>> search(@RequestParam(required = false) String name, 
                               @RequestParam(required = false) String source, 
                               @RequestParam(defaultValue = "1") Integer current, 
                               @RequestParam(defaultValue = "10") Integer size) {
        Page<Medicine> page = new Page<>(current, size);
        Page<Medicine> result = medicineService.page(page);
        return Result.success(result);
    }

    @GetMapping("/detail/{id}")
    public Result<Medicine> detail(@PathVariable Long id) {
        Medicine medicine = medicineService.getById(id);
        return Result.success(medicine);
    }

}
