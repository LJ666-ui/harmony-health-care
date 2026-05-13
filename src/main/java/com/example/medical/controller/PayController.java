package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.config.AlipayConfig;
import com.example.medical.config.RabbitMQConfig;
import com.example.medical.dto.AppointmentMessage;
import com.example.medical.entity.PaymentRecord;
import com.example.medical.service.AlipayService;
import com.example.medical.service.PaymentRecordService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/pay")
@CrossOrigin
public class PayController {

    @Autowired
    private AlipayService alipayService;

    @Autowired
    private PaymentRecordService paymentRecordService;

    @Autowired
    private StringRedisTemplate redisTemplate;

    @Autowired
    private RabbitTemplate rabbitTemplate;

    @PostMapping("/create")
    public Result<?> createPayment(@RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.parseLong(body.get("userId").toString());
            Long doctorId = Long.parseLong(body.get("doctorId").toString());
            String scheduleDateStr = body.get("scheduleDate").toString().trim();
            
            if (scheduleDateStr.length() > 8) {
                scheduleDateStr = scheduleDateStr.substring(0, 8);
                log.warn("[支付] scheduleDate过长，已截取前8位: {}", scheduleDateStr);
            }
            
            if (scheduleDateStr.contains("-") || scheduleDateStr.contains("T")) {
                scheduleDateStr = scheduleDateStr.replaceAll("[^0-9]", "");
                log.info("[支付] scheduleDate格式化后: {}", scheduleDateStr);
            }
            
            Integer schedulePeriod = Integer.parseInt(body.get("schedulePeriod").toString());
            BigDecimal fee = new BigDecimal(body.get("fee").toString());

            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            Date scheduleDate = sdf.parse(scheduleDateStr);

            log.info("[支付] 创建支付订单 userId={} doctorId={} date={} period={}",
                    userId, doctorId, scheduleDateStr, schedulePeriod);

            String outTradeNo = "APPT" + System.currentTimeMillis() + userId;

            PaymentRecord record = new PaymentRecord();
            record.setOutTradeNo(outTradeNo);
            record.setUserId(userId);
            record.setAppointmentId(0L);
            record.setAmount(fee);
            record.setStatus(0);
            record.setPayMethod("alipay");
            record.setDoctorId(doctorId);
            record.setScheduleDate(scheduleDateStr);
            record.setSchedulePeriod(schedulePeriod);
            record.setCreateTime(new Date());
            record.setUpdateTime(new Date());
            paymentRecordService.save(record);

            String payOrderKey = "pay:order:" + outTradeNo;
            String payOrderValue = userId + ":" + doctorId + ":" + scheduleDateStr + ":" + schedulePeriod;
            redisTemplate.opsForValue().set(payOrderKey, payOrderValue, 20, java.util.concurrent.TimeUnit.MINUTES);

            log.info("[支付] 订单已设置20分钟过期 outTradeNo={}", outTradeNo);

            String subject = "挂号费 - 医生ID:" + doctorId;
            String description = "挂号支付 日期:" + scheduleDate + " 时段:" + schedulePeriod;

            String form = alipayService.createMobilePayment(outTradeNo, subject, fee.toPlainString(), description);
            
            boolean mockPaymentEnabled = false;
            
            if (mockPaymentEnabled || form == null) {
                if (form == null) {
                    log.warn("[支付] 支付宝创建WAP订单失败，启用模拟支付 outTradeNo={}", outTradeNo);
                } else {
                    log.info("[支付] 模拟支付模式已启用 outTradeNo={}", outTradeNo);
                }
                
                paymentRecordService.markPaySuccess(outTradeNo, "MOCK_" + System.currentTimeMillis());
                
                AppointmentMessage message = new AppointmentMessage();
                message.setUserId(userId);
                message.setDoctorId(doctorId);
                message.setScheduleDateStr(scheduleDateStr);
                message.setSchedulePeriod(schedulePeriod);
                message.setFee(fee);
                message.setTraceId(outTradeNo);
                
                rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE_NAME,
                    RabbitMQConfig.ORDER_ROUTING_KEY,
                    message
                );
                
                Map<String, Object> mockResult = new HashMap<>();
                mockResult.put("outTradeNo", outTradeNo);
                mockResult.put("payForm", "");
                mockResult.put("payType", "mock");
                mockResult.put("doctorId", doctorId);
                mockResult.put("scheduleDate", scheduleDateStr);
                mockResult.put("schedulePeriod", schedulePeriod);
                mockResult.put("fee", fee);
                mockResult.put("message", "模拟支付成功");
                return Result.success(mockResult);
            }

            log.info("[支付] WAP支付表单长度={} outTradeNo={}", form.length(), outTradeNo);

            Map<String, Object> result = new HashMap<>();
            result.put("outTradeNo", outTradeNo);
            result.put("payForm", form);
            result.put("payType", "wap");
            result.put("doctorId", doctorId);
            result.put("scheduleDate", scheduleDateStr);
            result.put("schedulePeriod", schedulePeriod);
            result.put("fee", fee);
            result.put("expireTime", System.currentTimeMillis() + 20 * 60 * 1000);
            return Result.success(result);
        } catch (Exception e) {
            log.error("[支付] 创建支付订单异常: {}", e.getMessage(), e);
            return Result.error("创建支付订单失败：" + e.getMessage());
        }
    }

    @PostMapping("/notify")
    public String notify(HttpServletRequest request) {
        Map<String, String> params = new HashMap<>();
        Map<String, String[]> requestParams = request.getParameterMap();
        for (String name : requestParams.keySet()) {
            String[] values = requestParams.get(name);
            StringBuilder valueStr = new StringBuilder();
            for (int i = 0; i < values.length; i++) {
                valueStr.append(i == values.length - 1 ? values[i] : values[i] + ",");
            }
            params.put(name, valueStr.toString());
        }

        log.info("[支付] 收到异步通知 params={}", params);

        String outTradeNo = params.get("out_trade_no");
        String tradeNo = params.get("trade_no");
        String tradeStatus = params.get("trade_status");

        if (!"TRADE_SUCCESS".equals(tradeStatus) && !"TRADE_FINISHED".equals(tradeStatus)) {
            log.warn("[支付] 非成功状态 outTradeNo={} status={}", outTradeNo, tradeStatus);
            return "success";
        }

        log.info("[支付] 异步通知 outTradeNo={} tradeNo={} status={}", outTradeNo, tradeNo, tradeStatus);

        if ("TRADE_SUCCESS".equals(tradeStatus) || "TRADE_FINISHED".equals(tradeStatus)) {
            PaymentRecord record = paymentRecordService.getByOutTradeNo(outTradeNo);
            if (record == null) {
                log.warn("[支付] 未找到支付记录 outTradeNo={}", outTradeNo);
                return "failure";
            }

            if (record.getStatus() == 1) {
                log.info("[支付] 订单已处理过 outTradeNo={}", outTradeNo);
                return "success";
            }

            paymentRecordService.markPaySuccess(outTradeNo, tradeNo);

            AppointmentMessage message = new AppointmentMessage();
            message.setUserId(record.getUserId());
            message.setDoctorId(record.getDoctorId());
            message.setScheduleDateStr(record.getScheduleDate());
            message.setSchedulePeriod(record.getSchedulePeriod());
            message.setFee(record.getAmount());
            message.setTraceId(outTradeNo);

            rabbitTemplate.convertAndSend(
                    RabbitMQConfig.EXCHANGE_NAME,
                    RabbitMQConfig.ORDER_ROUTING_KEY,
                    message);

            log.info("[支付] 支付成功，已发送订单创建消息 outTradeNo={}", outTradeNo);
        }

        return "success";
    }

    @GetMapping("/return")
    public void returnUrl(HttpServletRequest request, HttpServletResponse response) {
        try {
            Map<String, String> params = new HashMap<>();
            Map<String, String[]> requestParams = request.getParameterMap();
            for (String name : requestParams.keySet()) {
                String[] values = requestParams.get(name);
                StringBuilder valueStr = new StringBuilder();
                for (int i = 0; i < values.length; i++) {
                    valueStr.append(i == values.length - 1 ? values[i] : values[i] + ",");
                }
                params.put(name, valueStr.toString());
            }

            String outTradeNo = params.get("out_trade_no");

            log.info("[支付] 同步回调 outTradeNo={}", outTradeNo);

            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().write("<html><body><h2>支付完成</h2><p>订单号: " + outTradeNo + "</p>"
                    + "<script>setTimeout(function(){ window.location.href = 'harmonyhealth://payresult?outTradeNo="
                    + outTradeNo + "'; }, 2000);</script></body></html>");
        } catch (Exception e) {
            log.error("[支付] 同步回调处理异常", e);
        }
    }

    @GetMapping("/status")
    public Result<?> queryPayStatus(@RequestParam String outTradeNo) {
        try {
            PaymentRecord record = paymentRecordService.getByOutTradeNo(outTradeNo);
            if (record == null) {
                return Result.error("支付记录不存在");
            }

            String alipayStatus = alipayService.queryTradeStatus(outTradeNo);
            if ("TRADE_SUCCESS".equals(alipayStatus) || "TRADE_FINISHED".equals(alipayStatus)) {
                if (record.getStatus() == 0) {
                    paymentRecordService.markPaySuccess(outTradeNo, "");

                    AppointmentMessage message = new AppointmentMessage();
                    message.setUserId(record.getUserId());
                    message.setDoctorId(record.getDoctorId());
                    message.setScheduleDateStr(record.getScheduleDate());
                    message.setSchedulePeriod(record.getSchedulePeriod());
                    message.setFee(record.getAmount());
                    message.setTraceId(outTradeNo);

                    rabbitTemplate.convertAndSend(
                            RabbitMQConfig.EXCHANGE_NAME,
                            RabbitMQConfig.ORDER_ROUTING_KEY,
                            message);

                    record.setStatus(1);
                }
            }

            Map<String, Object> result = new HashMap<>();
            result.put("outTradeNo", outTradeNo);
            result.put("status", record.getStatus());
            result.put("amount", record.getAmount());

            return Result.success(result);
        } catch (Exception e) {
            log.error("[支付] 查询支付状态异常: {}", e.getMessage());
            return Result.error("查询支付状态失败");
        }
    }
}
