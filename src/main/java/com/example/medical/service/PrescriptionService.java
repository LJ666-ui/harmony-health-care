package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Prescription;
import com.example.medical.entity.MedicationReminder;
import com.example.medical.mapper.PrescriptionMapper;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 处方服务类
 */
@Service
public class PrescriptionService extends ServiceImpl<PrescriptionMapper, Prescription> {
    
    /**
     * 创建处方
     */
    public Prescription createPrescription(Map<String, Object> prescriptionData) {
        Prescription prescription = new Prescription();
        
        prescription.setPatientId(Long.valueOf(prescriptionData.get("patientId").toString()));
        prescription.setDoctorId(Long.valueOf(prescriptionData.get("doctorId").toString()));
        prescription.setDiagnosis((String) prescriptionData.get("diagnosis"));
        prescription.setNotes((String) prescriptionData.get("notes"));
        prescription.setStatus("ACTIVE");
        prescription.setCreatedAt(new Date());
        
        // 设置有效期（默认30天）
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.DAY_OF_MONTH, 30);
        prescription.setValidUntil(calendar.getTime());
        
        // 处理药品信息
        List<Map<String, Object>> medications = (List<Map<String, Object>>) prescriptionData.get("medications");
        prescription.setMedications(toJsonString(medications));
        
        this.save(prescription);
        return prescription;
    }
    
    /**
     * 生成用药提醒
     */
    public List<MedicationReminder> generateMedicationReminders(Prescription prescription) {
        List<MedicationReminder> reminders = new ArrayList<>();
        
        // 解析药品信息
        String medicationsJson = prescription.getMedications();
        List<Map<String, Object>> medications = parseJsonToList(medicationsJson);
        
        for (Map<String, Object> medication : medications) {
            String frequency = (String) medication.get("frequency");
            Integer duration = Integer.valueOf(medication.get("duration").toString());
            
            // 计算提醒时间
            List<Date> times = calculateReminderTimes(frequency, duration, prescription.getCreatedAt());
            
            for (Date time : times) {
                MedicationReminder reminder = new MedicationReminder();
                reminder.setPrescriptionId(prescription.getId());
                reminder.setPatientId(prescription.getPatientId());
                reminder.setMedicationName((String) medication.get("name"));
                reminder.setMedicationDosage((String) medication.get("dosage"));
                reminder.setMedicationInstructions((String) medication.get("instructions"));
                
                List<String> warnings = (List<String>) medication.get("warnings");
                if (warnings != null) {
                    reminder.setMedicationWarnings(toJsonString(warnings));
                }
                
                reminder.setScheduledTime(time);
                reminder.setStatus("PENDING");
                reminder.setCreatedAt(new Date());
                
                reminders.add(reminder);
            }
        }
        
        return reminders;
    }
    
    /**
     * 计算提醒时间
     */
    private List<Date> calculateReminderTimes(String frequency, int duration, Date startTime) {
        List<Date> times = new ArrayList<>();
        int timesPerDay = 1;
        int[] defaultHours = {8};
        
        // 解析频次
        if (frequency.contains("一日一次") || frequency.contains("每天一次")) {
            timesPerDay = 1;
            defaultHours = new int[]{8};
        } else if (frequency.contains("一日两次") || frequency.contains("每天两次")) {
            timesPerDay = 2;
            defaultHours = new int[]{8, 20};
        } else if (frequency.contains("一日三次") || frequency.contains("每天三次")) {
            timesPerDay = 3;
            defaultHours = new int[]{8, 12, 18};
        } else if (frequency.contains("每8小时") || frequency.contains("每八小时")) {
            timesPerDay = 3;
            defaultHours = new int[]{0, 8, 16};
        } else if (frequency.contains("每12小时") || frequency.contains("每十二小时")) {
            timesPerDay = 2;
            defaultHours = new int[]{0, 12};
        }
        
        // 生成提醒时间
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(startTime);
        
        for (int day = 0; day < duration; day++) {
            for (int hour : defaultHours) {
                Calendar reminderTime = Calendar.getInstance();
                reminderTime.setTime(startTime);
                reminderTime.add(Calendar.DAY_OF_MONTH, day);
                reminderTime.set(Calendar.HOUR_OF_DAY, hour);
                reminderTime.set(Calendar.MINUTE, 0);
                reminderTime.set(Calendar.SECOND, 0);
                reminderTime.set(Calendar.MILLISECOND, 0);
                times.add(reminderTime.getTime());
            }
        }
        
        return times;
    }
    
    /**
     * 获取患者处方列表
     */
    public List<Prescription> getPatientPrescriptions(String patientId) {
        // TODO: 实现查询逻辑
        return this.list();
    }
    
    /**
     * 根据ID获取处方
     */
    public Prescription getPrescriptionById(String prescriptionId) {
        return this.getById(Long.valueOf(prescriptionId));
    }
    
    /**
     * 验证处方合理性
     */
    public boolean validatePrescription(Map<String, Object> prescriptionData) {
        // TODO: 实现验证逻辑
        return true;
    }
    
    /**
     * 获取用药提醒列表
     */
    public List<MedicationReminder> getMedicationReminders(String patientId) {
        // TODO: 实现查询逻辑
        return new ArrayList<>();
    }
    
    /**
     * 确认服药
     */
    public MedicationReminder confirmMedication(String reminderId, Map<String, Object> confirmData) {
        // TODO: 实现确认逻辑
        return new MedicationReminder();
    }
    
    /**
     * 批量保存用药提醒
     */
    public void saveRemindersBatch(List<MedicationReminder> reminders) {
        // TODO: 实现批量保存逻辑
    }
    
    /**
     * 更新用药提醒
     */
    public void updateMedicationReminder(String reminderId, Map<String, Object> updateData) {
        // TODO: 实现更新逻辑
    }
    
    /**
     * JSON工具方法
     */
    private String toJsonString(Object obj) {
        // 简单实现，实际应使用Jackson或Gson
        return obj.toString();
    }
    
    private List<Map<String, Object>> parseJsonToList(String json) {
        // 简单实现，实际应使用Jackson或Gson
        return new ArrayList<>();
    }
}
