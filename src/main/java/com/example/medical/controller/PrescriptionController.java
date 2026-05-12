package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.Prescription;
import com.example.medical.entity.MedicationReminder;
import com.example.medical.service.PrescriptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

import java.util.List;
import java.util.Map;

/**
 * 处方控制器
 * 处理处方开具、用药提醒等医疗业务
 */
@RestController
@RequestMapping("/medical")
@CrossOrigin
public class PrescriptionController {

    @Autowired
    private PrescriptionService prescriptionService;
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    /**
     * 开具处方
     * @param prescriptionData 处方数据
     * @return 处方信息
     */
    @PostMapping("/prescriptions")
    public Result<Prescription> createPrescription(@RequestBody Map<String, Object> prescriptionData) {
        try {
            Prescription prescription = prescriptionService.createPrescription(prescriptionData);
            return Result.success(prescription);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("开具处方失败: " + e.getMessage());
        }
    }

    /**
     * 获取患者处方列表
     * @param patientId 患者ID
     * @return 处方列表
     */
    @GetMapping("/prescriptions/patient/{patientId}")
    public Result<List<Prescription>> getPatientPrescriptions(@PathVariable String patientId) {
        try {
            List<Prescription> prescriptions = prescriptionService.getPatientPrescriptions(patientId);
            return Result.success(prescriptions);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取处方详情
     * @param prescriptionId 处方ID
     * @return 处方详情
     */
    @GetMapping("/prescriptions/{prescriptionId}")
    public Result<Prescription> getPrescriptionDetail(@PathVariable String prescriptionId) {
        try {
            Prescription prescription = prescriptionService.getPrescriptionById(prescriptionId);
            return Result.success(prescription);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 验证处方合理性
     * @param prescriptionData 处方数据
     * @return 验证结果
     */
    @PostMapping("/validate-prescription")
    public Result<Boolean> validatePrescription(@RequestBody Map<String, Object> prescriptionData) {
        try {
            boolean isValid = prescriptionService.validatePrescription(prescriptionData);
            return Result.success(isValid);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取用药提醒列表
     * @param patientId 患者ID
     * @return 提醒列表
     */
    @GetMapping("/reminders/{patientId}")
    public Result<List<MedicationReminder>> getMedicationReminders(@PathVariable String patientId) {
        try {
            List<MedicationReminder> reminders = prescriptionService.getMedicationReminders(patientId);
            return Result.success(reminders);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 确认服药
     * @param reminderId 提醒ID
     * @param confirmData 确认数据
     * @return 操作结果
     */
    @PostMapping("/reminders/{reminderId}/confirm")
    public Result<Void> confirmMedication(
            @PathVariable String reminderId,
            @RequestBody Map<String, Object> confirmData) {
        try {
            // 更新提醒状态
            MedicationReminder reminder = prescriptionService.confirmMedication(reminderId, confirmData);
            
            // 通过WebSocket同步到医生端和护士端
            String patientId = reminder.getPatientId().toString();
            
            Map<String, Object> confirmData2 = new HashMap<>();
            confirmData2.put("type", "MEDICATION_CONFIRMED");
            confirmData2.put("reminder", reminder);
            
            messagingTemplate.convertAndSend(
                "/topic/medication-confirmed/" + patientId,
                confirmData2
            );
            
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 批量保存用药提醒
     * @param data 提醒数据
     * @return 操作结果
     */
    @PostMapping("/reminders/batch")
    public Result<Void> saveRemindersBatch(@RequestBody Map<String, Object> data) {
        try {
            @SuppressWarnings("unchecked")
            List<MedicationReminder> reminders = (List<MedicationReminder>) data.get("reminders");
            prescriptionService.saveRemindersBatch(reminders);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新用药提醒
     * @param reminderId 提醒ID
     * @param updateData 更新数据
     * @return 操作结果
     */
    @PutMapping("/reminders/{reminderId}")
    public Result<Void> updateMedicationReminder(
            @PathVariable String reminderId,
            @RequestBody Map<String, Object> updateData) {
        try {
            prescriptionService.updateMedicationReminder(reminderId, updateData);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
