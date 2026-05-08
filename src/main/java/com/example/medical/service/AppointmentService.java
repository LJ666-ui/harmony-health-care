package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.Appointment;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface AppointmentService extends IService<Appointment> {

    boolean createAppointment(Appointment appointment);

    List<Appointment> getByUserId(Long userId);

    List<Appointment> getByDoctorId(Long doctorId);

    boolean cancelAppointment(Long appointmentId, Long userId);

    boolean updateStatus(Long appointmentId, Integer status);

    int getCountByDoctorAndDateTime(Long doctorId, Date date, Integer period);

    Map<String, Object> getStatistics(Long userId);
}
