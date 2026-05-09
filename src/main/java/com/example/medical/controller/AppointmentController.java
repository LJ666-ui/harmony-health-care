package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.config.RabbitMQConfig;
import com.example.medical.dto.AppointmentMessage;
import com.example.medical.entity.Appointment;
import com.example.medical.entity.PaymentRecord;
import com.example.medical.service.AppointmentService;
import com.example.medical.service.PaymentRecordService;
import com.example.medical.service.RedisStockInterface;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
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
    private PaymentRecordService paymentRecordService;

    @Autowired
    private RedisStockInterface redisStockService;

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

            AppointmentMessage message = new AppointmentMessage();
            message.setUserId(appointment.getUserId());
            message.setDoctorId(appointment.getDoctorId());
            message.setScheduleDate(appointment.getScheduleDate());
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
            List<Appointment> appointments = appointmentService.getByUserId(userId);
            return Result.success(appointments);
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
}
