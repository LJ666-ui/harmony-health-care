package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.BusinessException;
import com.example.medical.common.ResponseCode;
import com.example.medical.entity.DoctorSchedule;
import com.example.medical.mapper.DoctorScheduleMapper;
import com.example.medical.service.DoctorScheduleService;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

@Service
public class DoctorScheduleServiceImpl extends ServiceImpl<DoctorScheduleMapper, DoctorSchedule> implements DoctorScheduleService {

    @Override
    public List<DoctorSchedule> getByDoctorAndDate(Long doctorId, Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH);
        int day = cal.get(Calendar.DAY_OF_MONTH);

        LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DoctorSchedule::getDoctorId, doctorId)
               .eq(DoctorSchedule::getStatus, 1)
               .orderByAsc(DoctorSchedule::getSchedulePeriod);
        List<DoctorSchedule> all = list(wrapper);

        List<DoctorSchedule> result = new java.util.ArrayList<>();
        for (DoctorSchedule s : all) {
            if (s.getScheduleDate() != null) {
                Calendar sc = Calendar.getInstance();
                sc.setTime(s.getScheduleDate());
                if (sc.get(Calendar.YEAR) == year && sc.get(Calendar.MONTH) == month && sc.get(Calendar.DAY_OF_MONTH) == day) {
                    result.add(s);
                }
            }
        }
        return result;
    }

    @Override
    public DoctorSchedule getByDoctorAndPeriod(Long doctorId, Date date, Integer period) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH);
        int day = cal.get(Calendar.DAY_OF_MONTH);

        LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DoctorSchedule::getDoctorId, doctorId)
               .eq(DoctorSchedule::getSchedulePeriod, period)
               .eq(DoctorSchedule::getStatus, 1);
        List<DoctorSchedule> list = list(wrapper);

        for (DoctorSchedule s : list) {
            if (s.getScheduleDate() != null) {
                Calendar sc = Calendar.getInstance();
                sc.setTime(s.getScheduleDate());
                if (sc.get(Calendar.YEAR) == year && sc.get(Calendar.MONTH) == month && sc.get(Calendar.DAY_OF_MONTH) == day) {
                    return s;
                }
            }
        }
        return null;
    }

    @Override
    public DoctorSchedule createSchedule(DoctorSchedule schedule) {
        schedule.setCreateTime(new Date());
        schedule.setUpdateTime(new Date());
        schedule.setCurrentCount(0);
        schedule.setStatus(1);
        save(schedule);
        return schedule;
    }

    @Override
    public List<DoctorSchedule> getDoctorSchedules(Long doctorId) {
        QueryWrapper<DoctorSchedule> wrapper = new QueryWrapper<>();
        wrapper.eq("doctor_id", doctorId)
               .orderByAsc("schedule_date", "schedule_period");
        return list(wrapper);
    }

    @Override
    public List<DoctorSchedule> getDoctorSchedulesByDate(Long doctorId, Date scheduleDate) {
        QueryWrapper<DoctorSchedule> wrapper = new QueryWrapper<>();
        wrapper.eq("doctor_id", doctorId)
               .eq("schedule_date", scheduleDate)
               .orderByAsc("schedule_period");
        return list(wrapper);
    }

    @Override
    public DoctorSchedule getScheduleById(Long scheduleId) {
        return getById(scheduleId);
    }

    @Override
    public DoctorSchedule updateSchedule(Long scheduleId, DoctorSchedule schedule) {
        DoctorSchedule existingSchedule = getById(scheduleId);
        if (existingSchedule == null) {
            throw new BusinessException(ResponseCode.SCHEDULE_NOT_FOUND);
        }
        
        schedule.setId(scheduleId);
        schedule.setUpdateTime(new Date());
        updateById(schedule);
        return getById(scheduleId);
    }

    @Override
    public boolean deleteSchedule(Long scheduleId) {
        DoctorSchedule schedule = getById(scheduleId);
        if (schedule == null) {
            throw new BusinessException(ResponseCode.SCHEDULE_NOT_FOUND);
        }
        
        // 检查是否已有预约
        if (schedule.getCurrentCount() > 0) {
            throw new BusinessException(ResponseCode.SCHEDULE_HAS_APPOINTMENT);
        }
        
        return removeById(scheduleId);
    }

    @Override
    public boolean incrementAppointmentCount(Long scheduleId) {
        DoctorSchedule schedule = getById(scheduleId);
        if (schedule == null) {
            throw new BusinessException(ResponseCode.SCHEDULE_NOT_FOUND);
        }
        
        if (schedule.getCurrentCount() >= schedule.getMaxCount()) {
            throw new BusinessException(ResponseCode.SCHEDULE_ALREADY_BOOKED);
        }
        
        schedule.setCurrentCount(schedule.getCurrentCount() + 1);
        schedule.setUpdateTime(new Date());
        return updateById(schedule);
    }

    @Override
    public boolean decrementAppointmentCount(Long scheduleId) {
        DoctorSchedule schedule = getById(scheduleId);
        if (schedule == null) {
            throw new BusinessException(ResponseCode.SCHEDULE_NOT_FOUND);
        }
        
        if (schedule.getCurrentCount() > 0) {
            schedule.setCurrentCount(schedule.getCurrentCount() - 1);
            schedule.setUpdateTime(new Date());
            return updateById(schedule);
        }
        
        return false;
    }

    @Override
    public List<DoctorSchedule> getAvailableSchedules(Long doctorId, Date scheduleDate) {
        QueryWrapper<DoctorSchedule> wrapper = new QueryWrapper<>();
        wrapper.eq("doctor_id", doctorId)
               .eq("schedule_date", scheduleDate)
               .eq("status", 1)
               .orderByAsc("schedule_period");
        
        List<DoctorSchedule> schedules = list(wrapper);
        
        // 过滤掉已满的排班
        schedules.removeIf(schedule -> schedule.getCurrentCount() >= schedule.getMaxCount());
        
        return schedules;
    }

    @Override
    public Page<DoctorSchedule> getSchedulesPage(Long doctorId, int page, int pageSize) {
        Page<DoctorSchedule> pageParam = new Page<>(page, pageSize);
        QueryWrapper<DoctorSchedule> wrapper = new QueryWrapper<>();
        wrapper.eq("doctor_id", doctorId)
               .orderByDesc("schedule_date", "schedule_period");
        return page(pageParam, wrapper);
    }
}
