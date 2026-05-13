package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.DoctorSchedule;

import java.util.Date;
import java.util.List;

/**
 * 医生排班管理服务接口
 */
public interface DoctorScheduleService extends IService<DoctorSchedule> {

    /**
     * 根据医生ID和日期获取排班
     */
    List<DoctorSchedule> getByDoctorAndDate(Long doctorId, Date date);

    /**
     * 根据医生ID、日期和时段获取排班
     */
    DoctorSchedule getByDoctorAndPeriod(Long doctorId, Date date, Integer period);

    /**
     * 创建排班
     */
    DoctorSchedule createSchedule(DoctorSchedule schedule);

    /**
     * 获取医生的排班列表
     */
    List<DoctorSchedule> getDoctorSchedules(Long doctorId);

    /**
     * 获取医生指定日期的排班
     */
    List<DoctorSchedule> getDoctorSchedulesByDate(Long doctorId, Date scheduleDate);

    /**
     * 获取排班详情
     */
    DoctorSchedule getScheduleById(Long scheduleId);

    /**
     * 更新排班
     */
    DoctorSchedule updateSchedule(Long scheduleId, DoctorSchedule schedule);

    /**
     * 删除排班
     */
    boolean deleteSchedule(Long scheduleId);

    /**
     * 增加预约数量
     */
    boolean incrementAppointmentCount(Long scheduleId);

    /**
     * 减少预约数量
     */
    boolean decrementAppointmentCount(Long scheduleId);

    /**
     * 获取可用的排班列表
     */
    List<DoctorSchedule> getAvailableSchedules(Long doctorId, Date scheduleDate);

    /**
     * 分页查询排班
     */
    com.baomidou.mybatisplus.extension.plugins.pagination.Page<DoctorSchedule> getSchedulesPage(Long doctorId, int page, int pageSize);
}
