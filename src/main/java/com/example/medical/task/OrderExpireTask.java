package com.example.medical.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.example.medical.entity.Appointment;
import com.example.medical.entity.DoctorSchedule;
import com.example.medical.entity.PaymentRecord;
import com.example.medical.service.AppointmentService;
import com.example.medical.service.DoctorScheduleService;
import com.example.medical.service.PaymentRecordService;
import com.example.medical.service.RedisStockInterface;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Set;

@Component
@Profile("redis")
public class OrderExpireTask {

    private static final Logger log = LoggerFactory.getLogger(OrderExpireTask.class);

    @Autowired
    private PaymentRecordService paymentRecordService;

    @Autowired
    private AppointmentService appointmentService;

    @Autowired
    private DoctorScheduleService doctorScheduleService;

    @Autowired(required = false)
    private RedisStockInterface redisStockService;

    @Autowired(required = false)
    private StringRedisTemplate redisTemplate;

    @Scheduled(fixedRate = 60000)
    public void checkExpiredOrders() {
        try {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MINUTE, -20);
            Date expireTime = cal.getTime();

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            log.info("[订单过期检查] 开始检查 {} 之前创建的未支付订单", sdf.format(expireTime));

            LambdaQueryWrapper<PaymentRecord> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(PaymentRecord::getStatus, 0)
                  .lt(PaymentRecord::getCreateTime, expireTime);

            List<PaymentRecord> expiredOrders = paymentRecordService.list(wrapper);

            if (expiredOrders.isEmpty()) {
                return;
            }

            log.info("[订单过期检查] 发现 {} 条过期订单", expiredOrders.size());

            for (PaymentRecord record : expiredOrders) {
                processExpiredOrder(record);
            }
        } catch (Exception e) {
            log.error("[订单过期检查] 执行异常: {}", e.getMessage(), e);
        }
    }

    private void processExpiredOrder(PaymentRecord record) {
        try {
            log.info("[订单过期处理] 处理过期订单 outTradeNo={} userId={} doctorId={}",
                    record.getOutTradeNo(), record.getUserId(), record.getDoctorId());

            String payOrderKey = "pay:order:" + record.getOutTradeNo();
            if (redisTemplate != null) {
                Boolean hasKey = redisTemplate.hasKey(payOrderKey);

                if (hasKey != null && hasKey) {
                    redisTemplate.delete(payOrderKey);
                    log.info("[订单过期处理] Redis订单key已删除: {}", payOrderKey);
                }
            }

            LambdaQueryWrapper<Appointment> aptWrapper = new LambdaQueryWrapper<>();
            aptWrapper.eq(Appointment::getUserId, record.getUserId())
                     .eq(Appointment::getDoctorId, record.getDoctorId())
                     .eq(Appointment::getScheduleDate, parseScheduleDate(record.getScheduleDate()))
                     .eq(Appointment::getSchedulePeriod, record.getSchedulePeriod())
                     .in(Appointment::getStatus, 0, 1)
                     .eq(Appointment::getIsDeleted, 0)
                     .orderByDesc(Appointment::getCreateTime)
             .last("LIMIT 1");

            Appointment appointment = appointmentService.getOne(aptWrapper);

            if (appointment != null) {
                boolean removed = appointmentService.removeById(appointment.getId());
                if (removed) {
                    log.info("[订单过期处理] 预约记录已删除 appointmentId={}", appointment.getId());

                    try {
                        if (redisStockService != null) {
                            boolean stockReturned = redisStockService.backStock(
                                record.getDoctorId(),
                                appointment.getScheduleDate(),
                                record.getSchedulePeriod(),
                                record.getUserId()
                            );

                            if (stockReturned) {
                                log.info("[订单过期处理] Redis库存已归还 ✓");
                            } else {
                                forceReturnStock(record, appointment);
                            }
                        } else {
                            log.info("[订单过期处理] Redis未启用，跳过库存归还");
                            forceReturnStock(record, appointment);
                        }
                    } catch (Exception redisEx) {
                        log.warn("[订单过期处理] Redis库存归还异常: {}", redisEx.getMessage());
                        forceReturnStock(record, appointment);
                    }

                    try {
                        LambdaUpdateWrapper<DoctorSchedule> scheduleWrapper = new LambdaUpdateWrapper<>();
                        scheduleWrapper.eq(DoctorSchedule::getDoctorId, record.getDoctorId())
                                       .eq(DoctorSchedule::getScheduleDate, parseScheduleDate(record.getScheduleDate()))
                                       .eq(DoctorSchedule::getSchedulePeriod, record.getSchedulePeriod())
                                       .ge(DoctorSchedule::getCurrentCount, 1)
                                       .setSql("current_count = current_count - 1");
                        
                        doctorScheduleService.update(scheduleWrapper);
                        log.info("[订单过期处理] doctor_schedule已更新 ✓");
                    } catch (Exception scheduleEx) {
                        log.warn("[订单过期处理] 更新doctor_schedule异常: {}", scheduleEx.getMessage());
                    }
                } else {
                    log.warn("[订单过期处理] 预约记录删除失败 appointmentId={}", appointment.getId());
                }
            } else {
                log.info("[订单过期处理] 未找到对应的预约记录（可能已被取消）");
            }

            record.setStatus(3);
            record.setUpdateTime(new Date());
            paymentRecordService.updateById(record);
            log.info("[订单过期处理] payment_record状态已更新为已过期(3) id={}", record.getId());

        } catch (Exception e) {
            log.error("[订单过期处理] 处理异常 outTradeNo={}: {}", record.getOutTradeNo(), e.getMessage(), e);
        }
    }

    private void forceReturnStock(PaymentRecord record, Appointment appointment) {
        try {
            if (redisTemplate == null) {
                log.info("[订单过期处理] Redis未启用，跳过强制库存归还");
                return;
            }

            SimpleDateFormat dateFmt = new SimpleDateFormat("yyyyMMdd");
            String dateStr = dateFmt.format(appointment.getScheduleDate());

            String stockKey = "stock:" + record.getDoctorId() + ":" + dateStr + ":" + record.getSchedulePeriod();
            Boolean hasStockKey = redisTemplate.hasKey(stockKey);
            if (hasStockKey != null && hasStockKey) {
                redisTemplate.opsForValue().increment(stockKey, 1);
                log.info("[订单过期处理] 强制Redis库存+1 ✓ key={}", stockKey);
            }

            String bookedKey = "booked:" + record.getDoctorId() + ":" + dateStr + ":" + record.getSchedulePeriod();
            Boolean hasBookedKey = redisTemplate.hasKey(bookedKey);
            if (hasBookedKey != null && hasBookedKey) {
                redisTemplate.boundSetOps(bookedKey).remove(String.valueOf(record.getUserId()));
                log.info("[订单过期处理] 强制从booked集合移除用户 ✓ key={}", bookedKey);
            }
        } catch (Exception ex) {
            log.error("[订单过期处理] 强制归还库存失败: {}", ex.getMessage());
        }
    }

    private Date parseScheduleDate(String scheduleDateStr) {
        try {
            if (scheduleDateStr.contains("-")) {
                return new SimpleDateFormat("yyyy-MM-dd").parse(scheduleDateStr);
            } else {
                return new SimpleDateFormat("yyyyMMdd").parse(scheduleDateStr);
            }
        } catch (Exception e) {
            return new Date();
        }
    }
}
