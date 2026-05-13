package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.NursingRecord;

import java.util.List;

/**
 * 护理记录Service接口
 */
public interface NursingRecordService extends IService<NursingRecord> {
    
    List<NursingRecord> getRecordsByPatientId(Long patientId);
    
    List<NursingRecord> getRecordsByNurseId(Long nurseId);
    
    NursingRecord createRecord(NursingRecord record);
    
    NursingRecord updateRecord(Long id, NursingRecord record);
    
    boolean deleteRecord(Long id);
}
