package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.Appointment;

import java.util.List;
import java.util.Map;

/**
 * 预约挂号Service接口
 */
public interface AppointmentService extends IService<Appointment> {
    
    /**
     * 创建预约
     * @param appointment 预约信息
     * @return 创建结果
     */
    boolean createAppointment(Appointment appointment);
    
    /**
     * 根据用户ID获取预约列表
     * @param userId 用户ID
     * @return 预约列表
     */
    List<Appointment> getByUserId(Long userId);
    
    /**
     * 根据医生ID获取预约列表
     * @param doctorId 医生ID
     * @return 预约列表
     */
    List<Appointment> getByDoctorId(Long doctorId);
    
    /**
     * 取消预约
     * @param appointmentId 预约ID
     * @param userId 用户ID（用于权限验证）
     * @return 取消结果
     */
    boolean cancelAppointment(Long appointmentId, Long userId);
    
    /**
     * 更新预约状态
     * @param appointmentId 预约ID
     * @param status 新状态
     * @return 更新结果
     */
    boolean updateStatus(Long appointmentId, Integer status);
    
    /**
     * 获取指定日期和时段的预约数量
     * @param doctorId 医生ID
     * @param date 日期
     * @param timeSlot 时段
     * @return 预约数量
     */
    int getCountByDoctorAndDateTime(Long doctorId, String date, String timeSlot);
    
    /**
     * 获取预约统计信息
     * @param userId 用户ID
     * @return 统计信息
     */
    Map<String, Object> getStatistics(Long userId);
}
