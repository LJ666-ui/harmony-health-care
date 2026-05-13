package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.NursePatientRelation;
import com.example.medical.entity.PatientMedicationRecord;
import com.example.medical.entity.User;
import com.example.medical.mapper.NursePatientRelationMapper;
import com.example.medical.mapper.PatientMedicationRecordMapper;
import com.example.medical.mapper.UserMapper;
import com.example.medical.service.PatientMedicationRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PatientMedicationRecordServiceImpl extends ServiceImpl<PatientMedicationRecordMapper, PatientMedicationRecord> implements PatientMedicationRecordService {

    @Autowired
    private NursePatientRelationMapper nursePatientRelationMapper;

    @Autowired
    private UserMapper userMapper;

    private static final SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    @Override
    public List<Map<String, Object>> getMedicationListByNurseId(Long nurseId) {
        LambdaQueryWrapper<NursePatientRelation> relationWrapper = new LambdaQueryWrapper<>();
        relationWrapper.eq(NursePatientRelation::getNurseId, nurseId);
        relationWrapper.eq(NursePatientRelation::getIsDeleted, 0);
        List<NursePatientRelation> relations = nursePatientRelationMapper.selectList(relationWrapper);

        List<Long> patientIds = new ArrayList<>();
        for (NursePatientRelation relation : relations) {
            patientIds.add(relation.getPatientId());
        }

        if (patientIds.isEmpty()) {
            return new ArrayList<>();
        }

        LambdaQueryWrapper<PatientMedicationRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(PatientMedicationRecord::getPatientId, patientIds);
        wrapper.eq(PatientMedicationRecord::getIsDeleted, 0);
        wrapper.orderByDesc(PatientMedicationRecord::getCreateTime);
        List<PatientMedicationRecord> records = list(wrapper);

        return formatRecords(records);
    }

    @Override
    public List<Map<String, Object>> getMedicationListByPatientId(Long patientId) {
        LambdaQueryWrapper<PatientMedicationRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PatientMedicationRecord::getPatientId, patientId);
        wrapper.eq(PatientMedicationRecord::getIsDeleted, 0);
        wrapper.orderByDesc(PatientMedicationRecord::getCreateTime);
        List<PatientMedicationRecord> records = list(wrapper);

        return formatRecords(records);
    }

    @Override
    public boolean confirmMedication(Long id, Long nurseId) {
        PatientMedicationRecord record = getById(id);
        if (record == null) {
            return false;
        }

        if (record.getStatus() == 0) {
            record.setStatus(2);
        }

        return updateById(record);
    }

    private List<Map<String, Object>> formatRecords(List<PatientMedicationRecord> records) {
        List<Map<String, Object>> result = new ArrayList<>();

        for (PatientMedicationRecord record : records) {
            Map<String, Object> item = new HashMap<>();

            item.put("id", record.getId());
            item.put("patientId", record.getPatientId());

            User patient = userMapper.selectById(record.getPatientId());
            if (patient != null) {
                item.put("patientName", patient.getRealName());
            }

            item.put("medicineName", record.getDrugName());
            item.put("dosage", record.getDosage());
            item.put("frequency", record.getFrequency());

            if (record.getStartTime() != null) {
                item.put("startTime", formatter.format(record.getStartTime()));
            }

            if (record.getEndTime() != null) {
                item.put("endTime", formatter.format(record.getEndTime()));
            }

            item.put("status", record.getStatus());
            item.put("notes", record.getRemark());

            result.add(item);
        }

        return result;
    }
}
