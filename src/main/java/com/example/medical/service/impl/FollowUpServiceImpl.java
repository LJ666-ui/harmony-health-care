package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.FollowUp;
import com.example.medical.mapper.FollowUpMapper;
import com.example.medical.service.FollowUpService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class FollowUpServiceImpl extends ServiceImpl<FollowUpMapper, FollowUp> implements FollowUpService {

    @Override
    public List<FollowUp> getPatientFollowUps(Long patientId) {
        QueryWrapper<FollowUp> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("patient_id", patientId);
        queryWrapper.eq("is_deleted", 0);
        queryWrapper.orderByAsc("follow_up_date");
        queryWrapper.orderByAsc("follow_up_time");
        return this.list(queryWrapper);
    }

    @Override
    public FollowUp createFollowUp(FollowUp followUp) {
        followUp.setIsDeleted(0);
        followUp.setCreatedAt(LocalDateTime.now());
        followUp.setUpdatedAt(LocalDateTime.now());
        if (followUp.getReminderEnabled() == null) {
            followUp.setReminderEnabled(1);
        }
        if (followUp.getReminderDaysBefore() == null) {
            followUp.setReminderDaysBefore(1);
        }
        if (followUp.getStatus() == null) {
            followUp.setStatus("UPCOMING");
        }
        this.save(followUp);
        return followUp;
    }

    @Override
    public FollowUp updateFollowUpStatus(Long id, String status) {
        UpdateWrapper<FollowUp> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", id);
        updateWrapper.set("status", status);
        updateWrapper.set("updated_at", LocalDateTime.now());
        this.update(updateWrapper);
        return this.getById(id);
    }
}
