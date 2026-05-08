package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.DoctorSchedule;

import java.util.Date;
import java.util.List;

public interface DoctorScheduleService extends IService<DoctorSchedule> {
    List<DoctorSchedule> getByDoctorAndDate(Long doctorId, Date date);

    DoctorSchedule getByDoctorAndPeriod(Long doctorId, Date date, Integer period);
}
