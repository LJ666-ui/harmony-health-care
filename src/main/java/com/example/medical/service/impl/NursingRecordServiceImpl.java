package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.NursingRecord;
import com.example.medical.mapper.NursingRecordMapper;
import com.example.medical.service.NursingRecordService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

/**
 * 护理记录Service实现类
 */
@Service
public class NursingRecordServiceImpl extends ServiceImpl<NursingRecordMapper, NursingRecord> implements NursingRecordService {
    
    @Override
    public List<NursingRecord> getRecordsByPatientId(Long patientId) {
        LambdaQueryWrapper<NursingRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NursingRecord::getPatientId, patientId)
               .eq(NursingRecord::getIsDeleted, 0)
               .orderByDesc(NursingRecord::getCareTime);
        return this.list(wrapper);
    }
    
    @Override
    public List<NursingRecord> getRecordsByNurseId(Long nurseId) {
        LambdaQueryWrapper<NursingRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(NursingRecord::getNurseId, nurseId)
               .eq(NursingRecord::getIsDeleted, 0)
               .orderByDesc(NursingRecord::getCareTime);
        return this.list(wrapper);
    }
    
    @Override
    public NursingRecord createRecord(NursingRecord record) {
        record.setCreateTime(new Date());
        record.setUpdateTime(new Date());
        record.setIsDeleted(0);
        if (record.getCareTime() == null) {
            record.setCareTime(new Date());
        }
        this.save(record);
        return record;
    }
    
    @Override
    public NursingRecord updateRecord(Long id, NursingRecord record) {
        NursingRecord existRecord = this.getById(id);
        if (existRecord == null || existRecord.getIsDeleted() == 1) {
            return null;
        }
        
        if (record.getRecordType() != null) {
            existRecord.setRecordType(record.getRecordType());
        }
        if (record.getRecordContent() != null) {
            existRecord.setRecordContent(record.getRecordContent());
        }
        if (record.getRemark() != null) {
            existRecord.setRemark(record.getRemark());
        }
        if (record.getVitalSigns() != null) {
            existRecord.setVitalSigns(record.getVitalSigns());
        }
        if (record.getCareTime() != null) {
            existRecord.setCareTime(record.getCareTime());
        }
        
        existRecord.setUpdateTime(new Date());
        this.updateById(existRecord);
        return existRecord;
    }
    
    @Override
    public boolean deleteRecord(Long id) {
        NursingRecord record = this.getById(id);
        if (record == null) {
            return false;
        }
        
        record.setIsDeleted(1);
        record.setUpdateTime(new Date());
        return this.updateById(record);
    }
}
