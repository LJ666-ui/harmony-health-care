package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.config.RabbitMQConfig;
import com.example.medical.dto.AppointmentMessage;
import com.example.medical.entity.Appointment;
import com.example.medical.entity.Doctor;
import com.example.medical.entity.DoctorSchedule;
import com.example.medical.entity.PaymentRecord;
import com.example.medical.entity.User;
import com.example.medical.service.AppointmentService;
import com.example.medical.service.DoctorScheduleService;
import com.example.medical.service.DoctorService;
import com.example.medical.service.PaymentRecordService;
import com.example.medical.service.RedisStockInterface;
import com.example.medical.service.UserService;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.Date;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/appointment")
@CrossOrigin
@Validated
public class AppointmentController {

    @Autowired
    private AppointmentService appointmentService;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private DoctorScheduleService doctorScheduleService;

    @Autowired
    private PaymentRecordService paymentRecordService;

    @Autowired
    private RedisStockInterface redisStockService;

    @Autowired
    private UserService userService;

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private RabbitTemplate rabbitTemplate;

    @PostMapping("/create")
    public Result<?> createAppointment(@RequestBody Appointment appointment) {
        try {
            if (appointment.getUserId() == null) {
                return Result.error("用户ID不能为空");
            }
            if (appointment.getDoctorId() == null) {
                return Result.error("医生ID不能为空");
            }
            if (appointment.getScheduleDate() == null) {
                return Result.error("看诊日期不能为空");
            }
            if (appointment.getSchedulePeriod() == null || appointment.getSchedulePeriod() < 1 || appointment.getSchedulePeriod() > 3) {
                return Result.error("时间段不合法（1上午 2下午 3晚上）");
            }

            String traceId = UUID.randomUUID().toString().replace("-", "");

            System.out.println("[挂号调试] doctorId=" + appointment.getDoctorId()
                + " scheduleDate=" + appointment.getScheduleDate()
                + " period=" + appointment.getSchedulePeriod()
                + " userId=" + appointment.getUserId()
                + " traceId=" + traceId);

            SimpleDateFormat checkFormat = new SimpleDateFormat("yyyyMMdd");
            String dateStr = checkFormat.format(appointment.getScheduleDate());

            String bookedKey = "booked:" + appointment.getDoctorId() + ":" + dateStr + ":" + appointment.getSchedulePeriod();
            Boolean isMember = redisTemplate.boundSetOps(bookedKey).isMember(String.valueOf(appointment.getUserId()));

            if (isMember != null && isMember) {
                System.out.println("[挂号调试] Redis检测到重复预约！userId=" + appointment.getUserId() +
                    " 已在 booked 集合中: " + bookedKey);
                return Result.error("您今天已预约该医生该时段，不可重复挂号");
            }

            LambdaQueryWrapper<Appointment> dupWrapper = new LambdaQueryWrapper<>();
            dupWrapper.eq(Appointment::getUserId, appointment.getUserId())
                      .eq(Appointment::getDoctorId, appointment.getDoctorId())
                      .eq(Appointment::getScheduleDate, appointment.getScheduleDate())
                      .eq(Appointment::getSchedulePeriod, appointment.getSchedulePeriod())
                      .eq(Appointment::getIsDeleted, 0)
                      .in(Appointment::getStatus, 0, 1);
            long dupCount = appointmentService.count(dupWrapper);

            if (dupCount > 0) {
                System.out.println("[挂号调试] 数据库检测到重复预约！userId=" + appointment.getUserId() +
                    " 已有 " + dupCount + " 条有效预约记录");

                try {
                    redisTemplate.boundSetOps(bookedKey).add(String.valueOf(appointment.getUserId()));
                    System.out.println("[挂号调试] 已将用户同步到Redis booked集合: " + bookedKey);
                } catch (Exception syncEx) {
                    System.err.println("[挂号调试] 同步Redis失败: " + syncEx.getMessage());
                }

                return Result.error("您今天已预约该医生该时段，不可重复挂号");
            }

            AppointmentMessage message = new AppointmentMessage();
            message.setUserId(appointment.getUserId());
            message.setDoctorId(appointment.getDoctorId());
            message.setScheduleDate(appointment.getScheduleDate());
            message.setScheduleDateStr(new SimpleDateFormat("yyyyMMdd").format(appointment.getScheduleDate()));
            message.setSchedulePeriod(appointment.getSchedulePeriod());
            message.setFee(appointment.getFee());
            message.setTraceId(traceId);

            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE_NAME,
                    RabbitMQConfig.STOCK_ROUTING_KEY,
                    message);

            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE_NAME,
                    RabbitMQConfig.ORDER_ROUTING_KEY,
                    message);

            Map<String, Object> result = new HashMap<>();
            result.put("traceId", traceId);
            result.put("message", "挂号请求已提交，请稍后查询结果");
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("挂号失败：" + e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result<?> getAppointmentList(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long doctorId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String todayStr = sdf.format(new Date());

            LambdaUpdateWrapper<Appointment> expireWrapper = new LambdaUpdateWrapper<>();
            expireWrapper.eq(Appointment::getStatus, 0)
                         .eq(Appointment::getIsDeleted, 0)
                         .lt(Appointment::getScheduleDate, sdf.parse(todayStr))
                         .set(Appointment::getStatus, 3)
                         .set(Appointment::getReason, "该号已超出时效")
                         .set(Appointment::getUpdateTime, new Date());
            appointmentService.update(expireWrapper);

            LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Appointment::getIsDeleted, 0);

            if (userId != null) wrapper.eq(Appointment::getUserId, userId);
            if (doctorId != null) wrapper.eq(Appointment::getDoctorId, doctorId);
            if (status != null) wrapper.eq(Appointment::getStatus, status);

            wrapper.orderByDesc(Appointment::getCreateTime);
            Page<Appointment> pageParam = new Page<>(page, size);
            Page<Appointment> result = appointmentService.page(pageParam, wrapper);

            List<Map<String, Object>> records = new java.util.ArrayList<>();
            for (Appointment apt : result.getRecords()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", apt.getId());
                map.put("doctorId", apt.getDoctorId());
                map.put("userId", apt.getUserId());
                map.put("scheduleDate", apt.getScheduleDate());
                map.put("schedulePeriod", apt.getSchedulePeriod());
                map.put("appointmentNo", apt.getAppointmentNo());
                map.put("fee", apt.getFee());
                map.put("status", apt.getStatus());
                map.put("reason", apt.getReason());
                map.put("createTime", apt.getCreateTime());
                map.put("updateTime", apt.getUpdateTime());

                Doctor doctor = doctorService.getById(apt.getDoctorId());
                if (doctor != null) {
                    User user = userService.getById(doctor.getUserId());
                    if (user != null) {
                        map.put("doctorName", user.getRealName() != null ? user.getRealName() : "未知医生");
                    } else {
                        map.put("doctorName", "未知医生");
                    }
                    map.put("hospitalName", doctor.getHospital() != null ? doctor.getHospital() : "-");
                    map.put("departmentName", doctor.getDepartment() != null ? doctor.getDepartment() : "");
                    map.put("title", doctor.getTitle() != null ? doctor.getTitle() : "");
                } else {
                    map.put("doctorName", "未知医生");
                    map.put("hospitalName", "-");
                    map.put("departmentName", "");
                    map.put("title", "");
                }

                LambdaQueryWrapper<PaymentRecord> payWrapper = new LambdaQueryWrapper<>();
                payWrapper.eq(PaymentRecord::getUserId, apt.getUserId())
                          .eq(PaymentRecord::getDoctorId, apt.getDoctorId())
                          .eq(PaymentRecord::getSchedulePeriod, apt.getSchedulePeriod())
                          .orderByDesc(PaymentRecord::getCreateTime)
                          .last("LIMIT 1");
                PaymentRecord payRecord = paymentRecordService.getOne(payWrapper);
                map.put("payStatus", payRecord != null ? payRecord.getStatus() : 0);

                records.add(map);
            }

            Map<String, Object> pageResult = new HashMap<>();
            pageResult.put("records", records);
            pageResult.put("total", result.getTotal());
            pageResult.put("current", result.getCurrent());
            pageResult.put("size", result.getSize());
            pageResult.put("pages", result.getPages());

            return Result.success(pageResult);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public Result<?> getAppointmentDetail(@PathVariable Long id) {
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

    @PutMapping("/{id}")
    public Result<?> updateAppointment(@PathVariable Long id, @RequestBody Appointment appointment) {
        try {
            Appointment existing = appointmentService.getById(id);
            if (existing == null || existing.getIsDeleted() == 1) {
                return Result.error("预约不存在");
            }

            appointment.setId(id);
            appointment.setUpdateTime(new Date());

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

    @DeleteMapping("/{id}")
    public Result<?> cancelAppointment(@PathVariable Long id, @RequestBody Map<String, Object> body) {
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

    @GetMapping("/user/{userId}")
    public Result<?> getUserAppointments(@PathVariable Long userId) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String todayStr = sdf.format(new Date());

            LambdaUpdateWrapper<Appointment> expireWrapper = new LambdaUpdateWrapper<>();
            expireWrapper.eq(Appointment::getStatus, 0)
                         .eq(Appointment::getIsDeleted, 0)
                         .lt(Appointment::getScheduleDate, sdf.parse(todayStr))
                         .set(Appointment::getStatus, 3)
                         .set(Appointment::getReason, "该号已超出时效")
                         .set(Appointment::getUpdateTime, new Date());
            appointmentService.update(expireWrapper);

            List<Appointment> appointments = appointmentService.getByUserId(userId);

            List<Map<String, Object>> result = new java.util.ArrayList<>();

            for (Appointment appointment : appointments) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", appointment.getId());
                item.put("userId", appointment.getUserId());
                item.put("doctorId", appointment.getDoctorId());
                item.put("scheduleDate", appointment.getScheduleDate());
                item.put("schedulePeriod", appointment.getSchedulePeriod());
                item.put("status", appointment.getStatus());
                item.put("fee", appointment.getFee());
                item.put("appointmentNo", appointment.getAppointmentNo());
                item.put("createTime", appointment.getCreateTime());
                item.put("updateTime", appointment.getUpdateTime());

                Doctor doctor = doctorService.getById(appointment.getDoctorId());
                if (doctor != null) {
                    User user = userService.getById(doctor.getUserId());
                    if (user != null) {
                        item.put("doctorName", user.getRealName());
                        item.put("phone", user.getPhone());
                        item.put("avatar", user.getAvatar());
                    } else {
                        item.put("doctorName", "未知医生");
                        item.put("phone", "");
                        item.put("avatar", "");
                    }
                    item.put("hospitalName", doctor.getHospital() != null ? doctor.getHospital() : "");
                    item.put("departmentName", doctor.getDepartment() != null ? doctor.getDepartment() : "");
                    item.put("title", doctor.getTitle() != null ? doctor.getTitle() : "主治医师");
                } else {
                    item.put("doctorName", "未知医生");
                    item.put("hospitalName", "");
                    item.put("departmentName", "");
                    item.put("title", "");
                    item.put("phone", "");
                    item.put("avatar", "");
                }

                PaymentRecord payRecord = paymentRecordService.getOne(
                    new LambdaQueryWrapper<PaymentRecord>()
                        .eq(PaymentRecord::getAppointmentId, appointment.getId())
                        .last("LIMIT 1")
                );
                if (payRecord != null) {
                    item.put("payStatus", payRecord.getStatus());
                    item.put("outTradeNo", payRecord.getOutTradeNo());
                } else {
                    item.put("payStatus", 0);
                    item.put("outTradeNo", "");
                }

                result.add(item);
            }

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/doctor/{doctorId}")
    public Result<?> getDoctorAppointments(@PathVariable Long doctorId) {
        try {
            List<Appointment> appointments = appointmentService.getByDoctorId(doctorId);
            return Result.success(appointments);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @PutMapping("/{id}/status")
    public Result<?> updateAppointmentStatus(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            Integer status = Integer.parseInt(body.get("status").toString());

            Appointment existingAppointment = appointmentService.getById(id);
            if (existingAppointment == null || existingAppointment.getIsDeleted() == 1) {
                return Result.error("预约不存在");
            }

            boolean operationSuccess;

            if (status != null && status.intValue() == 2) {
                System.out.println("[退号调试] 预约取消，开始归还Redis库存...");
                System.out.println("[退号调试] appointmentId=" + id +
                    " doctorId=" + existingAppointment.getDoctorId() +
                    " userId=" + existingAppointment.getUserId() +
                    " date=" + existingAppointment.getScheduleDate() +
                    " period=" + existingAppointment.getSchedulePeriod());

                try {
                    boolean stockReturned = redisStockService.backStock(
                        existingAppointment.getDoctorId(),
                        existingAppointment.getScheduleDate(),
                        existingAppointment.getSchedulePeriod(),
                        existingAppointment.getUserId()
                    );

                    if (stockReturned) {
                        System.out.println("[退号调试] Redis库存归还成功 ✓");
                    } else {
                        System.out.println("[退号调试] Redis库存归还失败（可能用户未在Redis中记录），尝试强制归还库存...");

                        try {
                            String dateStr = new java.text.SimpleDateFormat("yyyyMMdd")
                                .format(existingAppointment.getScheduleDate());
                            String stockKey = "stock:" + existingAppointment.getDoctorId() +
                                ":" + dateStr + ":" + existingAppointment.getSchedulePeriod();

                            Boolean hasStockKey = redisTemplate.hasKey(stockKey);
                            if (hasStockKey != null && hasStockKey) {
                                redisTemplate.opsForValue().increment(stockKey, 1);
                                System.out.println("[退号调试] 强制Redis库存+1成功 ✓ (key=" + stockKey + ")");
                            }

                            String bookedKey = "booked:" + existingAppointment.getDoctorId() +
                                ":" + dateStr + ":" + existingAppointment.getSchedulePeriod();
                            Boolean hasBookedKey = redisTemplate.hasKey(bookedKey);
                            if (hasBookedKey != null && hasBookedKey) {
                                redisTemplate.boundSetOps(bookedKey).remove(String.valueOf(existingAppointment.getUserId()));
                                System.out.println("[退号调试] 强制从booked集合移除用户 ✓ (key=" + bookedKey + ")");
                            }
                        } catch (Exception forceEx) {
                            System.err.println("[退号调试] 强制归还库存失败: " + forceEx.getMessage());
                        }
                    }
                } catch (Exception redisEx) {
                    System.err.println("[退号调试] Redis库存归还异常: " + redisEx.getMessage());
                }

                try {
                    LambdaUpdateWrapper<DoctorSchedule> scheduleWrapper = new LambdaUpdateWrapper<>();
                    scheduleWrapper.eq(DoctorSchedule::getDoctorId, existingAppointment.getDoctorId())
                                   .eq(DoctorSchedule::getScheduleDate, existingAppointment.getScheduleDate())
                                   .eq(DoctorSchedule::getSchedulePeriod, existingAppointment.getSchedulePeriod())
                                   .ge(DoctorSchedule::getCurrentCount, 1)
                                   .setSql("current_count = current_count - 1");

                    boolean scheduleUpdated = doctorScheduleService.update(scheduleWrapper);
                    if (scheduleUpdated) {
                        System.out.println("[退号调试] doctor_schedule.current_count 已 -1 ✓");
                    } else {
                        System.out.println("[退号调试] doctor_schedule.current_count 未更新（可能不存在或已为0）");
                    }
                } catch (Exception scheduleEx) {
                    System.err.println("[退号调试] 更新doctor_schedule异常: " + scheduleEx.getMessage());
                }

                operationSuccess = appointmentService.updateStatus(id, 2);
            } else {
                operationSuccess = appointmentService.updateStatus(id, status);
            }

            if (operationSuccess) {
                return Result.success(status != null && status.intValue() == 2 ? "退号成功" : "状态更新成功");
            } else {
                return Result.error(status != null && status.intValue() == 2 ? "退号失败" : "状态更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("操作失败：" + e.getMessage());
        }
    }

    @PutMapping("/{id}/complete")
    public Result<?> completeAppointment(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.parseLong(body.get("userId").toString());
            Appointment appointment = appointmentService.getById(id);
            if (appointment == null || appointment.getIsDeleted() == 1) {
                return Result.error("预约不存在");
            }
            if (!appointment.getUserId().equals(userId)) {
                return Result.error("无权操作此预约");
            }
            if (appointment.getStatus() != 0) {
                return Result.error("只有待就诊状态才能完成就诊");
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String scheduleDateStr = sdf.format(appointment.getScheduleDate());
            String todayStr = sdf.format(new Date());
            if (!scheduleDateStr.equals(todayStr)) {
                return Result.error("只能完成当天的就诊");
            }

            LambdaUpdateWrapper<Appointment> wrapper = new LambdaUpdateWrapper<>();
            wrapper.eq(Appointment::getId, id)
                   .set(Appointment::getStatus, 1)
                   .set(Appointment::getUpdateTime, new Date());

            if (appointmentService.update(wrapper)) {
                return Result.success("就诊完成");
            } else {
                return Result.error("操作失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("操作失败：" + e.getMessage());
        }
    }

    @PostMapping("/check-expired")
    public Result<?> checkAndMarkExpired() {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String todayStr = sdf.format(new Date());

            LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Appointment::getStatus, 0)
                   .eq(Appointment::getIsDeleted, 0)
                   .lt(Appointment::getScheduleDate, sdf.parse(todayStr));

            List<Appointment> expiredList = appointmentService.list(wrapper);

            int count = 0;
            for (Appointment apt : expiredList) {
                LambdaUpdateWrapper<Appointment> updateWrapper = new LambdaUpdateWrapper<>();
                updateWrapper.eq(Appointment::getId, apt.getId())
                             .set(Appointment::getStatus, 3)
                             .set(Appointment::getReason, "该号已超出时效")
                             .set(Appointment::getUpdateTime, new Date());
                if (appointmentService.update(updateWrapper)) {
                    count++;
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("expiredCount", count);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("检查过期失败：" + e.getMessage());
        }
    }

    @GetMapping("/statistics/{userId}")
    public Result<?> getStatistics(@PathVariable Long userId) {
        try {
            Map<String, Object> stats = appointmentService.getStatistics(userId);
            return Result.success(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("统计失败：" + e.getMessage());
        }
    }

    @GetMapping("/check-availability")
    public Result<?> checkAvailability(
            @RequestParam Long doctorId,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") Date date,
            @RequestParam Integer period) {
        try {
            int remaining = redisStockService.getRemainingStock(doctorId, date, period);
            Map<String, Object> result = new HashMap<>();
            result.put("remaining", remaining);
            result.put("available", remaining > 0);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @PutMapping("/{id}/check-in")
    public Result<?> checkIn(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.parseLong(body.get("userId").toString());
            Appointment appointment = appointmentService.getById(id);
            if (appointment == null || appointment.getIsDeleted() == 1) {
                return Result.error("预约不存在");
            }
            if (!appointment.getUserId().equals(userId)) {
                return Result.error("无权操作此预约");
            }
            if (appointment.getStatus() != 0) {
                return Result.error("只有待就诊状态才能报到");
            }
            if (appointment.getCheckInTime() != null) {
                return Result.error("已报到，请勿重复操作");
            }

            LambdaUpdateWrapper<Appointment> updateWrapper = new LambdaUpdateWrapper<>();
            updateWrapper.eq(Appointment::getId, id)
                          .set(Appointment::getCheckInTime, new Date())
                          .set(Appointment::getUpdateTime, new Date());

            if (appointmentService.update(updateWrapper)) {
                Map<String, Object> result = new HashMap<>();
                result.put("message", "报到成功");
                result.put("checkInTime", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
                return Result.success(result);
            } else {
                return Result.error("报到失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("报到失败：" + e.getMessage());
        }
    }

    @GetMapping("/queue-info")
    public Result<?> getQueueInfo(@RequestParam Long userId) {
        try {
            SimpleDateFormat sdfExpire = new SimpleDateFormat("yyyy-MM-dd");
            String todayStr = sdfExpire.format(new Date());

            LambdaUpdateWrapper<Appointment> expireWrapper = new LambdaUpdateWrapper<>();
            expireWrapper.eq(Appointment::getStatus, 0)
                         .eq(Appointment::getIsDeleted, 0)
                         .lt(Appointment::getScheduleDate, sdfExpire.parse(todayStr))
                         .set(Appointment::getStatus, 3)
                         .set(Appointment::getReason, "该号已超出时效")
                         .set(Appointment::getUpdateTime, new Date());
            appointmentService.update(expireWrapper);

            LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Appointment::getUserId, userId)
                   .eq(Appointment::getIsDeleted, 0)
                   .eq(Appointment::getStatus, 0)
                   .orderByAsc(Appointment::getScheduleDate)
                   .orderByAsc(Appointment::getSchedulePeriod);
            List<Appointment> pendingList = appointmentService.list(wrapper);

            List<Map<String, Object>> queueList = new java.util.ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat sdfCompact = new SimpleDateFormat("yyyyMMdd");

            for (Appointment apt : pendingList) {
                Map<String, Object> item = new HashMap<>();
                item.put("appointmentId", apt.getId());
                item.put("appointmentNo", apt.getAppointmentNo());
                item.put("scheduleDate", sdf.format(apt.getScheduleDate()));
                item.put("schedulePeriod", apt.getSchedulePeriod());
                item.put("fee", apt.getFee());
                item.put("status", apt.getStatus());

                if (apt.getCheckInTime() != null) {
                    item.put("checkInTime", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(apt.getCheckInTime()));
                    item.put("isCheckedIn", true);
                } else {
                    item.put("checkInTime", null);
                    item.put("isCheckedIn", false);
                }

                String dateStr = sdfCompact.format(apt.getScheduleDate());
                LambdaQueryWrapper<Appointment> queueWrapper = new LambdaQueryWrapper<>();
                queueWrapper.eq(Appointment::getDoctorId, apt.getDoctorId())
                            .eq(Appointment::getScheduleDate, apt.getScheduleDate())
                            .eq(Appointment::getSchedulePeriod, apt.getSchedulePeriod())
                            .eq(Appointment::getIsDeleted, 0)
                            .in(Appointment::getStatus, 0, 1)
                            .isNotNull(Appointment::getCheckInTime)
                            .orderByAsc(Appointment::getCheckInTime);
                List<Appointment> checkedInList = appointmentService.list(queueWrapper);

                LambdaQueryWrapper<Appointment> notCheckedInWrapper = new LambdaQueryWrapper<>();
                notCheckedInWrapper.eq(Appointment::getDoctorId, apt.getDoctorId())
                                   .eq(Appointment::getScheduleDate, apt.getScheduleDate())
                                   .eq(Appointment::getSchedulePeriod, apt.getSchedulePeriod())
                                   .eq(Appointment::getIsDeleted, 0)
                                   .in(Appointment::getStatus, 0, 1)
                                   .isNull(Appointment::getCheckInTime)
                                   .orderByAsc(Appointment::getCreateTime);
                List<Appointment> notCheckedInList = appointmentService.list(notCheckedInWrapper);

                List<Appointment> sameSlotList = new java.util.ArrayList<>();
                sameSlotList.addAll(checkedInList);
                sameSlotList.addAll(notCheckedInList);

                int myPosition = 0;
                int totalAhead = 0;
                boolean foundMe = false;
                for (int i = 0; i < sameSlotList.size(); i++) {
                    Appointment a = sameSlotList.get(i);
                    if (a.getId().equals(apt.getId())) {
                        myPosition = i + 1;
                        foundMe = true;
                    } else if (!foundMe) {
                        totalAhead++;
                    }
                }

                item.put("myPosition", myPosition);
                item.put("totalAhead", totalAhead);
                item.put("totalInSlot", sameSlotList.size());

                Doctor doctor = doctorService.getById(apt.getDoctorId());
                if (doctor != null) {
                    User docUser = userService.getById(doctor.getUserId());
                    if (docUser != null) {
                        item.put("doctorName", docUser.getRealName() != null ? docUser.getRealName() : "未知医生");
                    } else {
                        item.put("doctorName", "未知医生");
                    }
                    item.put("hospitalName", doctor.getHospital() != null ? doctor.getHospital() : "-");
                    item.put("departmentName", doctor.getDepartment() != null ? doctor.getDepartment() : "");
                    item.put("title", doctor.getTitle() != null ? doctor.getTitle() : "");
                } else {
                    item.put("doctorName", "未知医生");
                    item.put("hospitalName", "-");
                    item.put("departmentName", "");
                    item.put("title", "");
                }

                String periodText = "";
                if (apt.getSchedulePeriod() == 1) periodText = "上午 08:00-12:00";
                else if (apt.getSchedulePeriod() == 2) periodText = "下午 14:00-17:00";
                else if (apt.getSchedulePeriod() == 3) periodText = "晚上 18:00-20:00";
                item.put("periodText", periodText);

                queueList.add(item);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("queueList", queueList);
            result.put("totalPending", pendingList.size());

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询排队信息失败：" + e.getMessage());
        }
    }

    @GetMapping("/queue-realtime")
    public Result<?> getRealTimeQueue(@RequestParam Long appointmentId) {
        try {
            Appointment myAppointment = appointmentService.getById(appointmentId);
            if (myAppointment == null || myAppointment.getIsDeleted() == 1) {
                return Result.error("预约不存在");
            }

            long nowMs = System.currentTimeMillis();
            long fiveMinutesMs = 5 * 60 * 1000;

            LambdaQueryWrapper<Appointment> checkedInWrapper = new LambdaQueryWrapper<>();
            checkedInWrapper.eq(Appointment::getDoctorId, myAppointment.getDoctorId())
                           .eq(Appointment::getScheduleDate, myAppointment.getScheduleDate())
                           .eq(Appointment::getSchedulePeriod, myAppointment.getSchedulePeriod())
                           .eq(Appointment::getIsDeleted, 0)
                           .in(Appointment::getStatus, 0, 1)
                           .isNotNull(Appointment::getCheckInTime)
                           .orderByAsc(Appointment::getCheckInTime);
            List<Appointment> checkedInList = appointmentService.list(checkedInWrapper);

            if (checkedInList.size() > 1 && checkedInList.get(0).getCheckInTime() != null) {
                long firstCheckInTime = checkedInList.get(0).getCheckInTime().getTime();
                long waitDuration = nowMs - firstCheckInTime;
                if (waitDuration > fiveMinutesMs) {
                    Appointment firstPerson = checkedInList.get(0);
                    checkedInList.remove(0);
                    int dropPositions = 3;
                    int newIndex = Math.min(dropPositions, checkedInList.size());
                    long targetTime;
                    if (newIndex < checkedInList.size()) {
                        targetTime = checkedInList.get(newIndex).getCheckInTime().getTime() - 1000;
                    } else {
                        targetTime = nowMs;
                    }
                    LambdaUpdateWrapper<Appointment> dropWrapper = new LambdaUpdateWrapper<>();
                    dropWrapper.eq(Appointment::getId, firstPerson.getId())
                               .set(Appointment::getCheckInTime, new Date(targetTime));
                    appointmentService.update(dropWrapper);
                    firstPerson.setCheckInTime(new Date(targetTime));
                    checkedInList.add(newIndex, firstPerson);
                    checkedInList.sort((a, b) -> a.getCheckInTime().compareTo(b.getCheckInTime()));
                    System.out.println("[排队调试] 第一名超时5分钟未响应，已下降" + dropPositions + "名 appointmentId=" + firstPerson.getId());
                }
            }

            List<Map<String, Object>> queueList = new java.util.ArrayList<>();
            int myPosition = 0;
            SimpleDateFormat timeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

            for (int i = 0; i < checkedInList.size(); i++) {
                Appointment apt = checkedInList.get(i);
                Map<String, Object> item = new HashMap<>();
                item.put("position", i + 1);
                item.put("appointmentId", apt.getId());
                item.put("checkInTime", timeFormat.format(apt.getCheckInTime()));
                item.put("isSelf", apt.getId().equals(appointmentId));
                item.put("isOnline", apt.getVisitType() != null && apt.getVisitType() == 1);

                User user = userService.getById(apt.getUserId());
                if (user != null && user.getRealName() != null) {
                    String name = user.getRealName();
                    if (name.length() > 2) {
                        name = name.substring(0, 1) + "**";
                    } else if (name.length() == 2) {
                        name = name.substring(0, 1) + "*";
                    }
                    item.put("patientName", name);
                } else {
                    item.put("patientName", "患者");
                }

                if (i == 0 && apt.getCheckInTime() != null) {
                    long waitMs = nowMs - apt.getCheckInTime().getTime();
                    long remainingMs = Math.max(0, fiveMinutesMs - waitMs);
                    item.put("waitSeconds", waitMs / 1000);
                    item.put("remainingSeconds", remainingMs / 1000);
                }

                queueList.add(item);

                if (apt.getId().equals(appointmentId)) {
                    myPosition = i + 1;
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("queueList", queueList);
            result.put("myPosition", myPosition);
            result.put("totalInQueue", checkedInList.size());

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("查询实时排队失败：" + e.getMessage());
        }
    }

    @PostMapping("/online-join")
    public Result<?> onlineJoin(@RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.parseLong(body.get("userId").toString());
            Long doctorId = Long.parseLong(body.get("doctorId").toString());
            String scheduleDateStr = body.get("scheduleDate").toString();
            Integer schedulePeriod = Integer.parseInt(body.get("schedulePeriod").toString());
            BigDecimal fee = new BigDecimal(body.get("fee").toString());

            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            sdf.setTimeZone(TimeZone.getTimeZone("GMT+8"));
            Date scheduleDate = sdf.parse(scheduleDateStr);

            String bookedKey = "booked:" + doctorId + ":" + scheduleDateStr + ":" + schedulePeriod;
            Boolean isMember = redisTemplate.boundSetOps(bookedKey).isMember(String.valueOf(userId));
            if (isMember != null && isMember) {
                return Result.error("您今天已预约该医生该时段，不可重复挂号");
            }

            LambdaQueryWrapper<Appointment> dupWrapper = new LambdaQueryWrapper<>();
            dupWrapper.eq(Appointment::getUserId, userId)
                      .eq(Appointment::getDoctorId, doctorId)
                      .eq(Appointment::getScheduleDate, scheduleDate)
                      .eq(Appointment::getSchedulePeriod, schedulePeriod)
                      .eq(Appointment::getIsDeleted, 0)
                      .in(Appointment::getStatus, 0, 1);
            long dupCount = appointmentService.count(dupWrapper);
            if (dupCount > 0) {
                return Result.error("您今天已预约该医生该时段，不可重复挂号");
            }

            int grabResult = redisStockService.grabSlot(doctorId, scheduleDate, schedulePeriod, userId);
            if (grabResult != 1) {
                if (grabResult == -1) {
                    return Result.error("您今天已预约该医生，不可重复挂号");
                }
                return Result.error("号源已满，请选择其他时段");
            }

            Appointment newAppointment = new Appointment();
            newAppointment.setUserId(userId);
            newAppointment.setDoctorId(doctorId);
            newAppointment.setScheduleDate(scheduleDate);
            newAppointment.setSchedulePeriod(schedulePeriod);
            newAppointment.setFee(fee);
            newAppointment.setStatus(0);
            newAppointment.setVisitType(1);
            newAppointment.setCheckInTime(new Date());

            boolean saved = appointmentService.createAppointment(newAppointment);

            if (saved && newAppointment.getId() != null) {
                try {
                    redisTemplate.boundSetOps(bookedKey).add(String.valueOf(userId));
                } catch (Exception ignored) {}

                AppointmentMessage message = new AppointmentMessage();
                message.setUserId(userId);
                message.setDoctorId(doctorId);
                message.setScheduleDate(scheduleDate);
                message.setScheduleDateStr(scheduleDateStr);
                message.setSchedulePeriod(schedulePeriod);
                message.setFee(fee);
                message.setTraceId("ONLINE_" + System.currentTimeMillis());

                rabbitTemplate.convertAndSend(
                        RabbitMQConfig.EXCHANGE_NAME,
                        RabbitMQConfig.ORDER_ROUTING_KEY,
                        message);

                Map<String, Object> result = new HashMap<>();
                result.put("appointmentId", newAppointment.getId());
                result.put("message", "线上就诊已加入排队");
                result.put("visitType", 1);
                return Result.success(result);
            } else {
                redisStockService.backStock(doctorId, scheduleDate, schedulePeriod, userId);
                return Result.error("创建线上就诊记录失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("线上就诊加入失败：" + e.getMessage());
        }
    }
}
