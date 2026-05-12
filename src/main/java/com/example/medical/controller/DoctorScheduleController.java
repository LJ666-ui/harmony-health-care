package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.DoctorSchedule;
import com.example.medical.service.DoctorScheduleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

/**
 * 医生排班管理控制器
 */
@RestController
@RequestMapping("/api/doctor/schedule")
@Tag(name = "医生排班管理", description = "医生排班相关接口")
public class DoctorScheduleController {

    @Autowired
    private DoctorScheduleService doctorScheduleService;

    /**
     * 创建排班
     */
    @PostMapping
    @Operation(summary = "创建排班", description = "医生创建新的排班")
    public Result<DoctorSchedule> createSchedule(@RequestBody DoctorSchedule schedule) {
        try {
            DoctorSchedule created = doctorScheduleService.createSchedule(schedule);
            return Result.success(created);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取医生的排班列表
     */
    @GetMapping("/doctor/{doctorId}")
    @Operation(summary = "获取医生排班列表", description = "获取指定医生的所有排班")
    public Result<List<DoctorSchedule>> getDoctorSchedules(
            @Parameter(description = "医生ID") @PathVariable Long doctorId) {
        try {
            List<DoctorSchedule> schedules = doctorScheduleService.getDoctorSchedules(doctorId);
            return Result.success(schedules);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取医生指定日期的排班
     */
    @GetMapping("/doctor/{doctorId}/date")
    @Operation(summary = "获取医生指定日期的排班", description = "获取医生在指定日期的排班")
    public Result<List<DoctorSchedule>> getDoctorSchedulesByDate(
            @Parameter(description = "医生ID") @PathVariable Long doctorId,
            @Parameter(description = "排班日期") @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date scheduleDate) {
        try {
            List<DoctorSchedule> schedules = doctorScheduleService.getDoctorSchedulesByDate(doctorId, scheduleDate);
            return Result.success(schedules);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取排班详情
     */
    @GetMapping("/{scheduleId}")
    @Operation(summary = "获取排班详情", description = "根据排班ID获取排班详情")
    public Result<DoctorSchedule> getScheduleById(
            @Parameter(description = "排班ID") @PathVariable Long scheduleId) {
        try {
            DoctorSchedule schedule = doctorScheduleService.getScheduleById(scheduleId);
            if (schedule == null) {
                return Result.error("排班不存在");
            }
            return Result.success(schedule);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新排班
     */
    @PutMapping("/{scheduleId}")
    @Operation(summary = "更新排班", description = "更新排班信息")
    public Result<DoctorSchedule> updateSchedule(
            @Parameter(description = "排班ID") @PathVariable Long scheduleId,
            @RequestBody DoctorSchedule schedule) {
        try {
            DoctorSchedule updated = doctorScheduleService.updateSchedule(scheduleId, schedule);
            return Result.success(updated);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除排班
     */
    @DeleteMapping("/{scheduleId}")
    @Operation(summary = "删除排班", description = "删除指定排班")
    public Result<Boolean> deleteSchedule(
            @Parameter(description = "排班ID") @PathVariable Long scheduleId) {
        try {
            boolean deleted = doctorScheduleService.deleteSchedule(scheduleId);
            return Result.success(deleted);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取可用的排班列表
     */
    @GetMapping("/available")
    @Operation(summary = "获取可用排班", description = "获取医生在指定日期可用的排班")
    public Result<List<DoctorSchedule>> getAvailableSchedules(
            @Parameter(description = "医生ID") @RequestParam Long doctorId,
            @Parameter(description = "排班日期") @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date scheduleDate) {
        try {
            List<DoctorSchedule> schedules = doctorScheduleService.getAvailableSchedules(doctorId, scheduleDate);
            return Result.success(schedules);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 分页查询排班
     */
    @GetMapping("/page")
    @Operation(summary = "分页查询排班", description = "分页查询医生的排班")
    public Result<Page<DoctorSchedule>> getSchedulesPage(
            @Parameter(description = "医生ID") @RequestParam Long doctorId,
            @Parameter(description = "页码") @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "每页数量") @RequestParam(defaultValue = "10") int pageSize) {
        try {
            Page<DoctorSchedule> pageResult = doctorScheduleService.getSchedulesPage(doctorId, page, pageSize);
            return Result.success(pageResult);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 增加预约数量（内部接口）
     */
    @PostMapping("/{scheduleId}/increment")
    @Operation(summary = "增加预约数量", description = "增加排班的预约数量")
    public Result<Boolean> incrementAppointmentCount(
            @Parameter(description = "排班ID") @PathVariable Long scheduleId) {
        try {
            boolean success = doctorScheduleService.incrementAppointmentCount(scheduleId);
            return Result.success(success);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 减少预约数量（内部接口）
     */
    @PostMapping("/{scheduleId}/decrement")
    @Operation(summary = "减少预约数量", description = "减少排班的预约数量")
    public Result<Boolean> decrementAppointmentCount(
            @Parameter(description = "排班ID") @PathVariable Long scheduleId) {
        try {
            boolean success = doctorScheduleService.decrementAppointmentCount(scheduleId);
            return Result.success(success);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
