package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Appointment;
import com.example.medical.mapper.AppointmentMapper;
import com.example.medical.service.AppointmentService;
import com.example.medical.service.RedisStockInterface;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AppointmentServiceImpl extends ServiceImpl<AppointmentMapper, Appointment> implements AppointmentService {

    @Autowired(required = false)
    private RedisStockInterface redisStockService;

    @Override
    public boolean createAppointment(Appointment appointment) {
        String lockKey = "lock:appointment:" + appointment.getDoctorId()
                + ":" + new SimpleDateFormat("yyyyMMdd").format(appointment.getScheduleDate())
                + ":" + appointment.getSchedulePeriod();
        String requestId = UUID.randomUUID().toString();

        try {
            if (redisStockService != null) {
                boolean locked = redisStockService.tryLock(lockKey, requestId, 10);
                if (!locked) {
                    return false;
                }
            }

            appointment.setStatus(0);
            appointment.setIsDeleted(0);
            appointment.setCreateTime(new Date());
            appointment.setUpdateTime(new Date());

            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            String dateStr = sdf.format(appointment.getScheduleDate());
            int count = getCountByDoctorAndPeriod(
                    appointment.getDoctorId(), appointment.getScheduleDate(), appointment.getSchedulePeriod());
            String timeSuffix = String.valueOf(System.currentTimeMillis());
            appointment.setAppointmentNo(dateStr + String.format("%04d", count + 1) + timeSuffix.substring(timeSuffix.length() - 4));

            return save(appointment);
        } finally {
            if (redisStockService != null) {
                redisStockService.unlock(lockKey, requestId);
            }
        }
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
               .orderByAsc(Appointment::getScheduleDate)
               .orderByAsc(Appointment::getSchedulePeriod);
        return list(wrapper);
    }

    @Override
    public boolean cancelAppointment(Long appointmentId, Long userId) {
        Appointment appointment = getById(appointmentId);
        if (appointment == null) {
            return false;
        }
        if (!appointment.getUserId().equals(userId)) {
            return false;
        }
        if (appointment.getStatus() != 0) {
            return false;
        }

        if (redisStockService != null) {
            boolean stockReturned = redisStockService.backStock(
                    appointment.getDoctorId(),
                    appointment.getScheduleDate(),
                    appointment.getSchedulePeriod(),
                    userId);

            if (!stockReturned) {
                return false;
            }
        }

        LambdaUpdateWrapper<Appointment> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(Appointment::getId, appointmentId)
               .set(Appointment::getStatus, 2)
               .set(Appointment::getReason, "用户取消")
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
    public int getCountByDoctorAndDateTime(Long doctorId, Date date, Integer period) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getDoctorId, doctorId)
               .eq(Appointment::getScheduleDate, date)
               .eq(Appointment::getSchedulePeriod, period)
               .in(Appointment::getStatus, 0, 1)
               .eq(Appointment::getIsDeleted, 0);
        return (int) count(wrapper);
    }

    @Override
    public Map<String, Object> getStatistics(Long userId) {
        Map<String, Object> stats = new HashMap<>();

        LambdaQueryWrapper<Appointment> totalWrapper = new LambdaQueryWrapper<>();
        totalWrapper.eq(Appointment::getUserId, userId).eq(Appointment::getIsDeleted, 0);
        stats.put("total", count(totalWrapper));

        LambdaQueryWrapper<Appointment> pendingWrapper = new LambdaQueryWrapper<>();
        pendingWrapper.eq(Appointment::getUserId, userId).eq(Appointment::getStatus, 0).eq(Appointment::getIsDeleted, 0);
        stats.put("pending", count(pendingWrapper));

        LambdaQueryWrapper<Appointment> completedWrapper = new LambdaQueryWrapper<>();
        completedWrapper.eq(Appointment::getUserId, userId).eq(Appointment::getStatus, 1).eq(Appointment::getIsDeleted, 0);
        stats.put("completed", count(completedWrapper));

        LambdaQueryWrapper<Appointment> cancelledWrapper = new LambdaQueryWrapper<>();
        cancelledWrapper.eq(Appointment::getUserId, userId).eq(Appointment::getStatus, 2).eq(Appointment::getIsDeleted, 0);
        stats.put("cancelled", count(cancelledWrapper));

        return stats;
    }

    private int getCountByDoctorAndPeriod(Long doctorId, Date date, Integer period) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Appointment::getDoctorId, doctorId)
               .eq(Appointment::getScheduleDate, date)
               .eq(Appointment::getSchedulePeriod, period)
               .eq(Appointment::getIsDeleted, 0);
        return (int) count(wrapper);
    }
}
