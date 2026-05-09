package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.example.medical.common.Result;
import com.example.medical.entity.DoctorSchedule;
import com.example.medical.service.DoctorScheduleService;
import com.example.medical.service.RedisStockInterface;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/schedule")
@CrossOrigin
public class ScheduleController {

    @Autowired
    private DoctorScheduleService scheduleService;

    @Autowired(required = false)
    private RedisStockInterface redisStockService;

    @PostMapping("/add")
    public Result<?> addSchedule(@RequestBody DoctorSchedule schedule) {
        try {
            if (schedule.getDoctorId() == null) {
                return Result.error("医生ID不能为空");
            }
            if (schedule.getScheduleDate() == null) {
                return Result.error("排班日期不能为空");
            }
            if (schedule.getSchedulePeriod() == null || schedule.getSchedulePeriod() < 1 || schedule.getSchedulePeriod() > 3) {
                return Result.error("时间段不合法（1上午 2下午 3晚上）");
            }
            if (schedule.getMaxCount() == null || schedule.getMaxCount() <= 0) {
                return Result.error("最大号源数必须大于0");
            }

            DoctorSchedule existing = scheduleService.getByDoctorAndPeriod(
                    schedule.getDoctorId(), schedule.getScheduleDate(), schedule.getSchedulePeriod());
            if (existing != null) {
                return Result.error("该医生该时段已有排班，请修改而非新增");
            }

            schedule.setCurrentCount(0);
            schedule.setStatus(1);
            schedule.setCreateTime(new Date());
            schedule.setUpdateTime(new Date());

            if (scheduleService.save(schedule)) {
                if (redisStockService != null) {
                    redisStockService.setStock(
                            schedule.getDoctorId(),
                            schedule.getScheduleDate(),
                            schedule.getSchedulePeriod(),
                            schedule.getMaxCount());
                }
                Map<String, Object> result = new HashMap<>();
                result.put("scheduleId", schedule.getId());
                result.put("message", "排班添加成功");
                return Result.success(result);
            } else {
                return Result.error("排班添加失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("排班添加失败：" + e.getMessage());
        }
    }

    @PutMapping("/update")
    public Result<?> updateSchedule(@RequestBody DoctorSchedule schedule) {
        try {
            if (schedule.getId() == null) {
                return Result.error("排班ID不能为空");
            }
            schedule.setUpdateTime(new Date());
            if (scheduleService.updateById(schedule)) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public Result<?> deleteSchedule(@PathVariable Long id) {
        try {
            LambdaUpdateWrapper<DoctorSchedule> wrapper = new LambdaUpdateWrapper<>();
            wrapper.eq(DoctorSchedule::getId, id)
                   .set(DoctorSchedule::getStatus, 0)
                   .set(DoctorSchedule::getUpdateTime, new Date());
            if (scheduleService.update(wrapper)) {
                return Result.success("停诊成功");
            } else {
                return Result.error("操作失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("操作失败：" + e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result<?> getScheduleList(
            @RequestParam(required = false) Long doctorId,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate) {
        try {
            LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(DoctorSchedule::getStatus, 1);

            if (doctorId != null) {
                wrapper.eq(DoctorSchedule::getDoctorId, doctorId);
            }

            wrapper.orderByAsc(DoctorSchedule::getScheduleDate)
                   .orderByAsc(DoctorSchedule::getSchedulePeriod);

            List<DoctorSchedule> list = scheduleService.list(wrapper);

            if (startDate != null && endDate != null) {
                List<DoctorSchedule> filtered = new java.util.ArrayList<>();
                for (DoctorSchedule s : list) {
                    if (s.getScheduleDate() != null) {
                        Date d = s.getScheduleDate();
                        if (!d.before(startDate) && !d.after(endDate)) {
                            filtered.add(s);
                        }
                    }
                }
                return Result.success(filtered);
            }

            return Result.success(list);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/doctor/{doctorId}/date/{date}")
    public Result<?> getSchedulesByDoctorAndDate(
            @PathVariable Long doctorId,
            @PathVariable @DateTimeFormat(pattern = "yyyy-MM-dd") Date date) {
        try {
            List<DoctorSchedule> schedules = scheduleService.getByDoctorAndDate(doctorId, date);
            return Result.success(schedules);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public Result<?> getScheduleDetail(@PathVariable Long id) {
        try {
            DoctorSchedule schedule = scheduleService.getById(id);
            if (schedule == null) {
                return Result.error("排班不存在");
            }
            return Result.success(schedule);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }
}
