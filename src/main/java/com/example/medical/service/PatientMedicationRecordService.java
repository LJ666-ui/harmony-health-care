package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.PatientMedicationRecord;

import java.util.List;
import java.util.Map;

public interface PatientMedicationRecordService extends IService<PatientMedicationRecord> {

    List<Map<String, Object>> getMedicationListByNurseId(Long nurseId);

    List<Map<String, Object>> getMedicationListByPatientId(Long patientId);

    boolean confirmMedication(Long id, Long nurseId);
}
