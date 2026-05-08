package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
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
}
