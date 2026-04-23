package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.DoctorMessage;
import com.example.medical.mapper.DoctorMessageMapper;
import com.example.medical.service.DoctorMessageService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DoctorMessageServiceImpl extends ServiceImpl<DoctorMessageMapper, DoctorMessage> implements DoctorMessageService {

    @Override
    public List<DoctorMessage> getConversation(Long userA, Long userB) {
        LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
        wrapper.and(w -> w.and(inner -> inner.eq(DoctorMessage::getSenderId, userA)
                    .eq(DoctorMessage::getReceiverId, userB))
                .or()
                .and(inner2 -> inner2.eq(DoctorMessage::getSenderId, userB)
                    .eq(DoctorMessage::getReceiverId, userA)));
        wrapper.orderByAsc(DoctorMessage::getCreateTime);
        return this.list(wrapper);
    }
}
