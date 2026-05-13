package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.NurseSchedule;
import com.example.medical.service.NurseScheduleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/nurse/schedule")
@CrossOrigin
@Tag(name = "护士排班管理", description = "护士排班相关接口")
public class NurseScheduleController {

    @Autowired
    private NurseScheduleService nurseScheduleService;

    @GetMapping("/nurse/{nurseId}")
    @Operation(summary = "获取护士排班列表", description = "根据护士ID获取排班列表")
    public Result<List<NurseSchedule>> getNurseSchedules(
            @Parameter(description = "护士ID") @PathVariable Long nurseId,
            @Parameter(description = "开始日期") @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @Parameter(description = "结束日期") @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate) {
        try {
            List<NurseSchedule> schedules;
            if (startDate != null && endDate != null) {
                schedules = nurseScheduleService.getByNurseIdAndDateRange(nurseId, startDate, endDate);
            } else {
                Date today = new Date();
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(today);
                calendar.add(Calendar.DATE, 7);
                schedules = nurseScheduleService.getByNurseIdAndDateRange(nurseId, today, calendar.getTime());
            }
            return Result.success(schedules);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/weekly/{nurseId}")
    @Operation(summary = "获取护士周排班", description = "获取指定护士的一周排班信息")
    public Result<Map<String, Object>> getWeeklySchedule(
            @Parameter(description = "护士ID") @PathVariable Long nurseId,
            @Parameter(description = "周开始日期(默认本周)") @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate) {
        try {
            if (startDate == null) {
                Calendar calendar = Calendar.getInstance();
                int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
                int offset = dayOfWeek == Calendar.SUNDAY ? -6 : (2 - dayOfWeek);
                calendar.add(Calendar.DATE, offset);
                startDate = calendar.getTime();
            }
            Map<String, Object> result = nurseScheduleService.getWeeklySchedule(nurseId, startDate);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/daily")
    @Operation(summary = "获取每日排班概览", description = "获取指定日期的所有护士排班概览")
    public Result<Map<String, Object>> getDailyOverview(
            @Parameter(description = "日期(默认今天)") @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date date) {
        try {
            if (date == null) {
                date = new Date();
            }
            Map<String, Object> result = nurseScheduleService.getDailyOverview(date);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/detail/{nurseId}")
    @Operation(summary = "获取护士排班详情", description = "获取指定护士的详细排班信息")
    public Result<List<Map<String, Object>>> getNurseScheduleDetail(
            @Parameter(description = "护士ID") @PathVariable Long nurseId,
            @Parameter(description = "查询天数(默认7天)") @RequestParam(defaultValue = "7") int days) {
        try {
            List<Map<String, Object>> detail = nurseScheduleService.getNurseScheduleDetail(nurseId, days);
            return Result.success(detail);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/date/{date}")
    @Operation(summary = "按日期查询排班", description = "获取指定日期的所有排班记录")
    public Result<List<NurseSchedule>> getSchedulesByDate(
            @Parameter(description = "日期") @PathVariable @DateTimeFormat(pattern = "yyyy-MM-dd") Date date,
            @Parameter(description = "班次类型(可选)") @RequestParam(required = false) Integer shiftType,
            @Parameter(description = "科室(可选)") @RequestParam(required = false) String department) {
        try {
            List<NurseSchedule> schedules;
            if (department != null && !department.isEmpty()) {
                schedules = nurseScheduleService.getByDepartmentAndDate(department, date);
            } else if (shiftType != null) {
                schedules = nurseScheduleService.getByDateAndShift(date, shiftType);
            } else {
                schedules = nurseScheduleService.getByDate(date);
            }
            return Result.success(schedules);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @PostMapping
    @Operation(summary = "创建排班", description = "新增护士排班记录")
    public Result<NurseSchedule> createSchedule(@RequestBody NurseSchedule schedule) {
        try {
            schedule.setCreateTime(new Date());
            schedule.setUpdateTime(new Date());
            schedule.setIsDeleted(0);
            if (schedule.getStatus() == null) {
                schedule.setStatus(1);
            }
            boolean success = nurseScheduleService.save(schedule);
            if (success) {
                return Result.success(schedule);
            } else {
                return Result.error("创建失败");
            }
        } catch (Exception e) {
            return Result.error("创建失败：" + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新排班", description = "更新排班信息")
    public Result<NurseSchedule> updateSchedule(
            @Parameter(description = "排班ID") @PathVariable Long id,
            @RequestBody NurseSchedule schedule) {
        try {
            schedule.setId(id);
            schedule.setUpdateTime(new Date());
            boolean success = nurseScheduleService.updateById(schedule);
            if (success) {
                return Result.success(schedule);
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            return Result.error("更新失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除排班", description = "逻辑删除排班记录")
    public Result<Boolean> deleteSchedule(@PathVariable Long id) {
        try {
            NurseSchedule schedule = new NurseSchedule();
            schedule.setId(id);
            schedule.setIsDeleted(1);
            schedule.setUpdateTime(new Date());
            boolean success = nurseScheduleService.updateById(schedule);
            return Result.success(success);
        } catch (Exception e) {
            return Result.error("删除失败：" + e.getMessage());
        }
    }

    @GetMapping("/shift/{shiftType}")
    @Operation(summary = "按班次查询", description = "根据班次类型查询今日排班")
    public Result<List<NurseSchedule>> getByShiftType(
            @Parameter(description = "班次类型: 1=早班 2=中班 3=夜班") @PathVariable Integer shiftType,
            @Parameter(description = "日期(默认今天)") @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date date) {
        try {
            if (date == null) {
                date = new Date();
            }
            List<NurseSchedule> schedules = nurseScheduleService.getByDateAndShift(date, shiftType);
            return Result.success(schedules);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }
}
