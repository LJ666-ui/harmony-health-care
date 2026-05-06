package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Appointment;
import com.example.medical.mapper.AppointmentMapper;
import com.example.medical.service.AppointmentService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 预约挂号Service实现类
 */
@Service
public class AppointmentServiceImpl extends ServiceImpl<AppointmentMapper, Appointment> implements AppointmentService {
    
    @Override
    public boolean createAppointment(Appointment appointment) {
        // 设置初始状态
        appointment.setStatus(1); // 待就诊
        appointment.setPaymentStatus(0); // 未支付
        appointment.setIsDeleted(0);
        appointment.setCreateTime(new Date());
        appointment.setUpdateTime(new Date());
        
        // 计算排队号
        int count = getCountByDoctorAndDateTime(
            appointment.getDoctorId(),
            appointment.getAppointmentDate(),
            appointment.getTimeSlot()
        );
        appointment.setQueueNumber(count + 1);
        
        return save(appointment);
    }
    
    @Override
    public List<Appointment> getByUserId(Long userId) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getUserId, userId)
               .eq(Appointment::getIsDeleted, 0)
               .orderByDesc(Appointment::getCreateTime);
        return list(wrapper);
    }
    
    @Override
    public List<Appointment> getByDoctorId(Long doctorId) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getDoctorId, doctorId)
               .eq(Appointment::getIsDeleted, 0)
               .orderByAsc(Appointment::getQueueNumber);
        return list(wrapper);
    }
    
    @Override
    public boolean cancelAppointment(Long appointmentId, Long userId) {
        Appointment appointment = getById(appointmentId);
        if (appointment == null) {
            return false;
        }
        
        // 验证权限
        if (!appointment.getUserId().equals(userId)) {
            return false;
        }
        
        // 只能取消待就诊的预约
        if (appointment.getStatus() != 1) {
            return false;
        }
        
        LambdaUpdateWrapper<Appointment> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Appointment::getId, appointmentId)
               .set(Appointment::getStatus, 0) // 已取消
               .set(Appointment::getUpdateTime, new Date());
        
        return update(wrapper);
    }
    
    @Override
    public boolean updateStatus(Long appointmentId, Integer status) {
        LambdaUpdateWrapper<Appointment> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Appointment::getId, appointmentId)
               .set(Appointment::getStatus, status)
               .set(Appointment::getUpdateTime, new Date());
        return update(wrapper);
    }
    
    @Override
    public int getCountByDoctorAndDateTime(Long doctorId, String date, String timeSlot) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getDoctorId, doctorId)
               .eq(Appointment::getAppointmentDate, date)
               .eq(Appointment::getTimeSlot, timeSlot)
               .in(Appointment::getStatus, 1, 2) // 待就诊或已就诊
               .eq(Appointment::getIsDeleted, 0);
        return (int) count(wrapper);
    }
    
    @Override
    public Map<String, Object> getStatistics(Long userId) {
        Map<String, Object> stats = new HashMap<>();
        
        // 总预约数
        LambdaQueryWrapper<Appointment> totalWrapper = new LambdaQueryWrapper<>();
        totalWrapper.eq(Appointment::getUserId, userId)
                    .eq(Appointment::getIsDeleted, 0);
        stats.put("total", count(totalWrapper));
        
        // 待就诊数
        LambdaQueryWrapper<Appointment> pendingWrapper = new LambdaQueryWrapper<>();
        pendingWrapper.eq(Appointment::getUserId, userId)
                     .eq(Appointment::getStatus, 1)
                     .eq(Appointment::getIsDeleted, 0);
        stats.put("pending", count(pendingWrapper));
        
        // 已就诊数
        LambdaQueryWrapper<Appointment> completedWrapper = new LambdaQueryWrapper<>();
        completedWrapper.eq(Appointment::getUserId, userId)
                       .eq(Appointment::getStatus, 2)
                       .eq(Appointment::getIsDeleted, 0);
        stats.put("completed", count(completedWrapper));
        
        // 已取消数
        LambdaQueryWrapper<Appointment> cancelledWrapper = new LambdaQueryWrapper<>();
        cancelledWrapper.eq(Appointment::getUserId, userId)
                       .eq(Appointment::getStatus, 0)
                       .eq(Appointment::getIsDeleted, 0);
        stats.put("cancelled", count(cancelledWrapper));
        
        return stats;
    }
}
