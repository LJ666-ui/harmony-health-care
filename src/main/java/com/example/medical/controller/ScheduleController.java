package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.example.medical.common.Result;
import com.example.medical.entity.Doctor;
import com.example.medical.entity.DoctorSchedule;
import com.example.medical.entity.User;
import com.example.medical.service.DoctorService;
import com.example.medical.service.DoctorScheduleService;
import com.example.medical.service.RedisStockInterface;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import java.text.SimpleDateFormat;

@RestController
@RequestMapping("/schedule")
@CrossOrigin
public class ScheduleController {

    @Autowired
    private DoctorScheduleService scheduleService;

    @Autowired(required = false)
    private RedisStockInterface redisStockService;

    @Autowired(required = false)
    private StringRedisTemplate redisTemplate;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private UserService userService;

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
            @RequestParam(required = false) String department,
            @RequestParam(required = false) Long hospitalId,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date date) {
        try {
            LambdaQueryWrapper<DoctorSchedule> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(DoctorSchedule::getStatus, 1);

            if (doctorId != null) {
                wrapper.eq(DoctorSchedule::getDoctorId, doctorId);
            }

            wrapper.orderByAsc(DoctorSchedule::getScheduleDate)
                   .orderByAsc(DoctorSchedule::getSchedulePeriod);

            List<DoctorSchedule> scheduleList = scheduleService.list(wrapper);

            List<Map<String, Object>> result = new java.util.ArrayList<>();

            for (DoctorSchedule schedule : scheduleList) {
                try {
                    Doctor doctor = doctorService.getById(schedule.getDoctorId());

                    if (doctor == null) {
                        System.out.println("[DEBUG] 排班记录 id=" + schedule.getId() + 
                            " 的医生 doctorId=" + schedule.getDoctorId() + " 在 Doctor 表中不存在");
                        continue;
                    }

                    if (doctor.getStatus() == null || doctor.getStatus() != 1) {
                        User statusUser = (doctor.getUserId() != null) ? userService.getById(doctor.getUserId()) : null;
                        String doctorNameForLog = (statusUser != null && statusUser.getRealName() != null) ?
                            statusUser.getRealName() : ("医生ID=" + doctor.getId());
                        System.out.println("[DEBUG] 医生 id=" + doctor.getId() +
                            " (" + doctorNameForLog + ") 状态为：" + doctor.getStatus() + "，非启用状态（仍显示）");
                    }

                    if (date != null && schedule.getScheduleDate() != null) {
                        if (!isSameDay(schedule.getScheduleDate(), date)) {
                            continue;
                        }
                    }

                    if (department != null && !department.isEmpty()) {
                        String docDept = doctor.getDepartment();
                        if (docDept == null || !docDept.contains(department)) {
                            User deptUser = userService.getById(doctor.getUserId());
                            String deptDoctorName = (deptUser != null && deptUser.getRealName() != null) ? 
                                deptUser.getRealName() : ("医生ID=" + doctor.getId());
                            System.out.println("[DEBUG] 医生 " + deptDoctorName +
                                " (id=" + doctor.getId() + ")" +
                                " 科室=[" + docDept + "]" +
                                " 不匹配查询条件：[" + department + "]");
                            continue;
                        }
                    }

                    Map<String, Object> item = new HashMap<>();
                    item.put("id", schedule.getId());
                    item.put("scheduleId", schedule.getId());
                    item.put("doctorId", schedule.getDoctorId());

                    User userInfo = (doctor.getUserId() != null) ? userService.getById(doctor.getUserId()) : null;
                    String realNameValue = (userInfo != null && userInfo.getRealName() != null) ?
                        userInfo.getRealName() : "未知医生";
                    String phoneValue = (userInfo != null) ? userInfo.getPhone() : "";
                    String avatarValue = (userInfo != null) ? userInfo.getAvatar() : "";

                    item.put("doctorName", realNameValue);
                    item.put("realName", realNameValue);
                    item.put("userId", doctor.getUserId());
                    item.put("phone", phoneValue);
                    item.put("title", doctor.getTitle());
                    item.put("specialty", doctor.getSpecialty());
                    item.put("avatar", avatarValue);
                    item.put("description", doctor.getDescription());
                    item.put("rating", doctor.getRating());
                    item.put("department", doctor.getDepartment());
                    item.put("hospital", doctor.getHospital());
                    item.put("scheduleDate", schedule.getScheduleDate());
                    item.put("schedulePeriod", schedule.getSchedulePeriod());
                    item.put("maxCount", schedule.getMaxCount());
                    item.put("currentCount", schedule.getCurrentCount());

                    int remainingStock = 0;
                    if (schedule.getMaxCount() != null && schedule.getCurrentCount() != null) {
                        remainingStock = schedule.getMaxCount() - schedule.getCurrentCount();
                    }
                    item.put("remainingStock", remainingStock);
                    item.put("stock", remainingStock);

                    result.add(item);

                    System.out.println("[SUCCESS] 找到匹配排班: 医生=" + realNameValue + 
                        ", 科室=" + doctor.getDepartment() + 
                        ", 日期=" + schedule.getScheduleDate() + 
                        ", 剩余号源=" + remainingStock);

                } catch (Exception ex) {
                    System.err.println("[ERROR] 处理排班记录 id=" + schedule.getId() + 
                        " 时发生异常: " + ex.getMessage());
                    ex.printStackTrace();
                }
            }

            System.out.println("[SUMMARY] 查询完成，共找到 " + result.size() + " 条匹配记录");

            if (startDate != null && endDate != null) {
                List<Map<String, Object>> filtered = new java.util.ArrayList<>();
                for (Map<String, Object> item : result) {
                    Object scheduleDateObj = item.get("scheduleDate");
                    if (scheduleDateObj instanceof Date) {
                        Date d = (Date) scheduleDateObj;
                        if (!d.before(startDate) && !d.after(endDate)) {
                            filtered.add(item);
                        }
                    }
                }
                return Result.success(filtered);
            }

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    private boolean isSameDay(Date date1, Date date2) {
        if (date1 == null || date2 == null) return false;
        java.util.Calendar cal1 = java.util.Calendar.getInstance();
        cal1.setTime(date1);
        java.util.Calendar cal2 = java.util.Calendar.getInstance();
        cal2.setTime(date2);
        return cal1.get(java.util.Calendar.YEAR) == cal2.get(java.util.Calendar.YEAR) &&
               cal1.get(java.util.Calendar.MONTH) == cal2.get(java.util.Calendar.MONTH) &&
               cal1.get(java.util.Calendar.DAY_OF_MONTH) == cal2.get(java.util.Calendar.DAY_OF_MONTH);
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

    @GetMapping("/stock/query")
    public Result<?> queryRealTimeStock(
            @RequestParam Long doctorId,
            @RequestParam String scheduleDate,
            @RequestParam Integer schedulePeriod) {
        try {
            SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat redisFormat = new SimpleDateFormat("yyyyMMdd");
            Date date = inputFormat.parse(scheduleDate);
            String dateStr = redisFormat.format(date);

            int remainingStock = redisStockService.getRemainingStock(doctorId, date, schedulePeriod);

            String stockKey = "stock:" + doctorId + ":" + dateStr + ":" + schedulePeriod;
            String bookedKey = "booked:" + doctorId + ":" + dateStr + ":" + schedulePeriod;

            Boolean hasBooked = redisTemplate.hasKey(bookedKey);
            Long bookedCount = hasBooked ? redisTemplate.opsForSet().size(bookedKey) : 0L;

            System.out.println("[库存查询] doctorId=" + doctorId +
                " date=" + scheduleDate +
                " period=" + schedulePeriod +
                " remainingStock=" + remainingStock +
                " bookedCount=" + bookedCount);

            Map<String, Object> result = new HashMap<>();
            result.put("doctorId", doctorId);
            result.put("scheduleDate", scheduleDate);
            result.put("schedulePeriod", schedulePeriod);
            result.put("remainingStock", remainingStock);
            result.put("bookedCount", bookedCount);
            result.put("stockKey", stockKey);
            result.put("timestamp", System.currentTimeMillis());

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询库存失败：" + e.getMessage());
        }
    }
}
