package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.BusinessException;
import com.example.medical.common.ResponseCode;
import com.example.medical.entity.Consultation;
import com.example.medical.entity.ConsultationParticipant;
import com.example.medical.entity.ConsultationRecord;
import com.example.medical.mapper.ConsultationMapper;
import com.example.medical.mapper.ConsultationParticipantMapper;
import com.example.medical.mapper.ConsultationRecordMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 会诊服务类
 */
@Service
public class ConsultationService {

    @Autowired
    private ConsultationMapper consultationMapper;

    @Autowired
    private ConsultationParticipantMapper consultationParticipantMapper;

    @Autowired
    private ConsultationRecordMapper consultationRecordMapper;

    /**
     * 发起会诊
     */
    @Transactional
    public Consultation initiate(Consultation consultation, List<Long> doctorIds, List<Long> departmentIds) {
        // 设置初始状态
        consultation.setStatus("pending");
        consultation.setCreatedAt(LocalDateTime.now());
        consultation.setUpdatedAt(LocalDateTime.now());
        
        // 保存会诊
        consultationMapper.insert(consultation);
        
        // 添加参与人
        if (doctorIds != null && !doctorIds.isEmpty()) {
            for (int i = 0; i < doctorIds.size(); i++) {
                ConsultationParticipant participant = new ConsultationParticipant();
                participant.setConsultationId(consultation.getId());
                participant.setDoctorId(doctorIds.get(i));
                participant.setDepartmentId(departmentIds.get(i));
                participant.setStatus("invited");
                participant.setCreatedAt(LocalDateTime.now());
                participant.setUpdatedAt(LocalDateTime.now());
                consultationParticipantMapper.insert(participant);
            }
        }
        
        return consultation;
    }

    /**
     * 获取医生的会诊列表
     */
    public Page<Consultation> getByDoctorId(Long doctorId, String status, int page, int pageSize) {
        Page<Consultation> pageParam = new Page<>(page, pageSize);
        QueryWrapper<Consultation> queryWrapper = new QueryWrapper<>();
        
        // 查询医生参与的会诊
        queryWrapper.inSql("id", 
            "SELECT consultation_id FROM consultation_participant WHERE doctor_id = " + doctorId);
        
        if (status != null && !status.isEmpty()) {
            queryWrapper.eq("status", status);
        }
        
        queryWrapper.orderByDesc("created_at");
        
        return consultationMapper.selectPage(pageParam, queryWrapper);
    }

    /**
     * 获取会诊详情
     */
    public Consultation getById(Long id) {
        return consultationMapper.selectById(id);
    }

    /**
     * 开始会诊
     */
    public Consultation start(Long id) {
        Consultation consultation = consultationMapper.selectById(id);
        if (consultation == null) {
            throw new BusinessException(ResponseCode.CONSULTATION_NOT_FOUND);
        }
        
        if (!"pending".equals(consultation.getStatus())) {
            throw new BusinessException(ResponseCode.CONSULTATION_NOT_IN_PROGRESS);
        }
        
        consultation.setStatus("in_progress");
        consultation.setStartedTime(LocalDateTime.now());
        consultation.setUpdatedAt(LocalDateTime.now());
        consultationMapper.updateById(consultation);
        
        return consultation;
    }

    /**
     * 结束会诊
     */
    public Consultation end(Long id) {
        Consultation consultation = consultationMapper.selectById(id);
        if (consultation == null) {
            throw new BusinessException(ResponseCode.CONSULTATION_NOT_FOUND);
        }
        
        if (!"in_progress".equals(consultation.getStatus())) {
            throw new BusinessException(ResponseCode.CONSULTATION_NOT_IN_PROGRESS);
        }
        
        consultation.setStatus("completed");
        consultation.setEndedTime(LocalDateTime.now());
        consultation.setUpdatedAt(LocalDateTime.now());
        consultationMapper.updateById(consultation);
        
        return consultation;
    }

    /**
     * 取消会诊
     */
    public Consultation cancel(Long id) {
        Consultation consultation = consultationMapper.selectById(id);
        if (consultation == null) {
            throw new BusinessException(ResponseCode.CONSULTATION_NOT_FOUND);
        }
        
        consultation.setStatus("cancelled");
        consultation.setUpdatedAt(LocalDateTime.now());
        consultationMapper.updateById(consultation);
        
        return consultation;
    }

    /**
     * 添加会诊记录
     */
    public ConsultationRecord addRecord(ConsultationRecord record) {
        record.setRecordTime(LocalDateTime.now());
        record.setCreatedAt(LocalDateTime.now());
        consultationRecordMapper.insert(record);
        return record;
    }

    /**
     * 获取会诊记录列表
     */
    public List<ConsultationRecord> getRecords(Long consultationId) {
        QueryWrapper<ConsultationRecord> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("consultation_id", consultationId);
        queryWrapper.orderByAsc("record_time");
        return consultationRecordMapper.selectList(queryWrapper);
    }

    /**
     * 获取会诊参与人列表
     */
    public List<ConsultationParticipant> getParticipants(Long consultationId) {
        QueryWrapper<ConsultationParticipant> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("consultation_id", consultationId);
        return consultationParticipantMapper.selectList(queryWrapper);
    }

    /**
     * 接受会诊邀请
     */
    public ConsultationParticipant acceptInvitation(Long consultationId, Long doctorId) {
        QueryWrapper<ConsultationParticipant> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("consultation_id", consultationId);
        queryWrapper.eq("doctor_id", doctorId);
        
        ConsultationParticipant participant = consultationParticipantMapper.selectOne(queryWrapper);
        if (participant == null) {
            throw new BusinessException(ResponseCode.CONSULTATION_INVITATION_NOT_FOUND);
        }
        
        participant.setStatus("accepted");
        participant.setJoinedTime(LocalDateTime.now());
        participant.setUpdatedAt(LocalDateTime.now());
        consultationParticipantMapper.updateById(participant);
        
        return participant;
    }
}
