package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.Appointment;
import com.example.medical.service.AppointmentService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 预约挂号Controller
 * 提供预约管理的RESTful API接口
 * 
 * @author Medical System
 * @version 1.0
 * @since 2026-04-27
 */
@Api(tags = "预约挂号管理")
@RestController
@RequestMapping("/appointment")
@CrossOrigin
@Validated
public class AppointmentController {
    
    @Autowired
    private AppointmentService appointmentService;
    
    /**
     * 创建预约
     * 
     * @param appointment 预约信息
     * @return 创建结果
     */
    @ApiOperation(value = "创建预约", notes = "用户预约挂号，系统自动分配排队号")
    @PostMapping("/create")
    public Result<?> createAppointment(@Valid @RequestBody Appointment appointment) {
        try {
            // 参数校验
            if (appointment.getUserId() == null) {
                return Result.error("用户ID不能为空");
            }
            if (appointment.getDoctorId() == null) {
                return Result.error("医生ID不能为空");
            }
            if (appointment.getAppointmentDate() == null || appointment.getAppointmentDate().isEmpty()) {
                return Result.error("预约日期不能为空");
            }
            if (appointment.getTimeSlot() == null || appointment.getTimeSlot().isEmpty()) {
                return Result.error("预约时段不能为空");
            }
            
            // 检查是否已有相同时段的预约
            int count = appointmentService.getCountByDoctorAndDateTime(
                appointment.getDoctorId(),
                appointment.getAppointmentDate(),
                appointment.getTimeSlot()
            );
            
            // 限制每个时段最多预约20人
            if (count >= 20) {
                return Result.error("该时段预约已满，请选择其他时段");
            }
            
            // 创建预约
            if (appointmentService.createAppointment(appointment)) {
                Map<String, Object> result = new HashMap<>();
                result.put("appointmentId", appointment.getId());
                result.put("queueNumber", appointment.getQueueNumber());
                result.put("message", "预约成功");
                return Result.success(result);
            } else {
                return Result.error("预约失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("预约失败：" + e.getMessage());
        }
    }
    
    /**
     * 分页查询预约列表
     * 
     * @param userId 用户ID（可选）
     * @param doctorId 医生ID（可选）
     * @param status 预约状态（可选）
     * @param page 页码
     * @param size 每页数量
     * @return 预约列表
     */
    @ApiOperation(value = "分页查询预约列表", notes = "支持按用户、医生、状态筛选")
    @GetMapping("/list")
    public Result<?> getAppointmentList(
            @ApiParam("用户ID") @RequestParam(required = false) Long userId,
            @ApiParam("医生ID") @RequestParam(required = false) Long doctorId,
            @ApiParam("预约状态") @RequestParam(required = false) Integer status,
            @ApiParam("页码") @RequestParam(defaultValue = "1") Integer page,
            @ApiParam("每页数量") @RequestParam(defaultValue = "10") Integer size) {
        try {
            LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Appointment::getIsDeleted, 0);
            
            if (userId != null) {
                wrapper.eq(Appointment::getUserId, userId);
            }
            if (doctorId != null) {
                wrapper.eq(Appointment::getDoctorId, doctorId);
            }
            if (status != null) {
                wrapper.eq(Appointment::getStatus, status);
            }
            
            wrapper.orderByDesc(Appointment::getCreateTime);
            
            Page<Appointment> pageParam = new Page<>(page, size);
            Page<Appointment> result = appointmentService.page(pageParam, wrapper);
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取预约详情
     * 
     * @param id 预约ID
     * @return 预约详情
     */
    @ApiOperation(value = "获取预约详情", notes = "根据预约ID查询详细信息")
    @GetMapping("/{id}")
    public Result<?> getAppointmentDetail(@ApiParam("预约ID") @PathVariable Long id) {
        try {
            Appointment appointment = appointmentService.getById(id);
            if (appointment == null || appointment.getIsDeleted() == 1) {
                return Result.error("预约不存在");
            }
            return Result.success(appointment);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新预约信息
     * 
     * @param id 预约ID
     * @param appointment 更新的预约信息
     * @return 更新结果
     */
    @ApiOperation(value = "更新预约信息", notes = "修改预约的日期、时段等信息")
    @PutMapping("/{id}")
    public Result<?> updateAppointment(
            @ApiParam("预约ID") @PathVariable Long id,
            @Valid @RequestBody Appointment appointment) {
        try {
            Appointment existing = appointmentService.getById(id);
            if (existing == null || existing.getIsDeleted() == 1) {
                return Result.error("预约不存在");
            }
            
            // 只能修改待就诊的预约
            if (existing.getStatus() != 1) {
                return Result.error("只能修改待就诊的预约");
            }
            
            appointment.setId(id);
            appointment.setUpdateTime(new java.util.Date());
            
            if (appointmentService.updateById(appointment)) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新失败：" + e.getMessage());
        }
    }
    
    /**
     * 取消预约
     * 
     * @param id 预约ID
     * @param body 请求体（包含userId）
     * @return 取消结果
     */
    @ApiOperation(value = "取消预约", notes = "用户取消自己的预约")
    @DeleteMapping("/{id}")
    public Result<?> cancelAppointment(
            @ApiParam("预约ID") @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.parseLong(body.get("userId").toString());
            
            if (appointmentService.cancelAppointment(id, userId)) {
                return Result.success("取消成功");
            } else {
                return Result.error("取消失败，请检查权限或预约状态");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("取消失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取用户的预约列表
     * 
     * @param userId 用户ID
     * @return 预约列表
     */
    @ApiOperation(value = "获取用户预约列表", notes = "查询指定用户的所有预约")
    @GetMapping("/user/{userId}")
    public Result<?> getUserAppointments(@ApiParam("用户ID") @PathVariable Long userId) {
        try {
            List<Appointment> appointments = appointmentService.getByUserId(userId);
            return Result.success(appointments);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取医生的预约列表
     * 
     * @param doctorId 医生ID
     * @return 预约列表
     */
    @ApiOperation(value = "获取医生预约列表", notes = "查询指定医生的所有预约")
    @GetMapping("/doctor/{doctorId}")
    public Result<?> getDoctorAppointments(@ApiParam("医生ID") @PathVariable Long doctorId) {
        try {
            List<Appointment> appointments = appointmentService.getByDoctorId(doctorId);
            return Result.success(appointments);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新预约状态
     * 
     * @param id 预约ID
     * @param body 请求体（包含status）
     * @return 更新结果
     */
    @ApiOperation(value = "更新预约状态", notes = "医生或系统更新预约状态")
    @PutMapping("/{id}/status")
    public Result<?> updateAppointmentStatus(
            @ApiParam("预约ID") @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        try {
            Integer status = Integer.parseInt(body.get("status").toString());
            
            if (appointmentService.updateStatus(id, status)) {
                return Result.success("状态更新成功");
            } else {
                return Result.error("状态更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("状态更新失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取预约统计信息
     * 
     * @param userId 用户ID
     * @return 统计信息
     */
    @ApiOperation(value = "获取预约统计", notes = "统计用户的预约数量")
    @GetMapping("/statistics/{userId}")
    public Result<?> getStatistics(@ApiParam("用户ID") @PathVariable Long userId) {
        try {
            Map<String, Object> stats = appointmentService.getStatistics(userId);
            return Result.success(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("统计失败：" + e.getMessage());
        }
    }
    
    /**
     * 检查时段是否可预约
     * 
     * @param doctorId 医生ID
     * @param date 预约日期
     * @param timeSlot 时段
     * @return 可预约信息
     */
    @ApiOperation(value = "检查时段可预约性", notes = "查询指定时段是否还有名额")
    @GetMapping("/check-availability")
    public Result<?> checkAvailability(
            @ApiParam("医生ID") @RequestParam Long doctorId,
            @ApiParam("预约日期") @RequestParam String date,
            @ApiParam("时段") @RequestParam String timeSlot) {
        try {
            int count = appointmentService.getCountByDoctorAndDateTime(doctorId, date, timeSlot);
            int maxCount = 20; // 每个时段最多20人
            boolean available = count < maxCount;
            
            Map<String, Object> result = new HashMap<>();
            result.put("available", available);
            result.put("currentCount", count);
            result.put("maxCount", maxCount);
            result.put("remaining", maxCount - count);
            
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
}
