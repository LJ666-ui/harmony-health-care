package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.config.AlipayConfig;
import com.example.medical.config.RabbitMQConfig;
import com.example.medical.dto.AppointmentMessage;
import com.example.medical.entity.PaymentRecord;
import com.example.medical.service.AlipayService;
import com.example.medical.service.PaymentRecordService;
import com.example.medical.service.RedisStockInterface;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
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
    private RedisStockInterface redisStockService;

    @Autowired
    private RabbitTemplate rabbitTemplate;

    @PostMapping("/create")
    public Result<?> createPayment(@RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.parseLong(body.get("userId").toString());
            Long doctorId = Long.parseLong(body.get("doctorId").toString());
            String scheduleDateStr = body.get("scheduleDate").toString();
            Integer schedulePeriod = Integer.parseInt(body.get("schedulePeriod").toString());
            BigDecimal fee = new BigDecimal(body.get("fee").toString());

            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            Date scheduleDate = sdf.parse(scheduleDateStr);

            int grabResult = redisStockService.grabSlot(doctorId, scheduleDate, schedulePeriod, userId);
            if (grabResult != 1) {
                if (grabResult == -1) {
                    return Result.error("您今天已预约该医生，不可重复挂号");
                }
                return Result.error("号源已满，请选择其他时段");
            }

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

            String subject = "挂号费 - 医生ID:" + doctorId;
            String description = "挂号支付 日期:" + scheduleDate + " 时段:" + schedulePeriod;

            String form = alipayService.createPayment(outTradeNo, subject, fee.toPlainString(), description);
            if (form == null) {
                redisStockService.backStock(doctorId, scheduleDate, schedulePeriod, userId);
                paymentRecordService.removeByOutTradeNo(outTradeNo);
                return Result.error("创建支付订单失败");
            }

            Map<String, Object> result = new HashMap<>();
            result.put("outTradeNo", outTradeNo);
            result.put("payForm", form);
            result.put("doctorId", doctorId);
            result.put("scheduleDate", scheduleDateStr);
            result.put("schedulePeriod", schedulePeriod);
            result.put("fee", fee);
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
