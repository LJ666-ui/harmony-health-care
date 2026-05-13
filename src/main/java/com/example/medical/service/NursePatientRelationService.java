package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.NursePatientRelation;
import com.example.medical.mapper.NursePatientRelationMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NursePatientRelationService extends ServiceImpl<NursePatientRelationMapper, NursePatientRelation> {
    
    public List<Long> getPatientIdsByNurseId(Long nurseId) {
        return baseMapper.selectPatientIdsByNurseId(nurseId);
    }
}
