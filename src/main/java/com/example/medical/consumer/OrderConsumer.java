package com.example.medical.consumer;

import com.alibaba.fastjson.JSON;
import com.example.medical.config.RabbitMQConfig;
import com.example.medical.dto.AppointmentMessage;
import com.example.medical.entity.Appointment;
import com.example.medical.service.AppointmentService;
import com.rabbitmq.client.Channel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

@Component
public class OrderConsumer {

    private static final Logger log = LoggerFactory.getLogger(OrderConsumer.class);

    @Autowired
    private AppointmentService appointmentService;

    @RabbitListener(queues = RabbitMQConfig.ORDER_QUEUE)
    public void handleOrderCreation(AppointmentMessage message, Channel channel,
                                    @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) throws IOException {
        log.info("[生成订单队列] 收到消息: {}", JSON.toJSONString(message));

        try {
            Appointment appointment = new Appointment();
            appointment.setUserId(message.getUserId());
            appointment.setDoctorId(message.getDoctorId());
            if (message.getScheduleDateStr() != null && !message.getScheduleDateStr().isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                sdf.setTimeZone(TimeZone.getTimeZone("GMT+8"));
                appointment.setScheduleDate(sdf.parse(message.getScheduleDateStr()));
            } else if (message.getScheduleDate() != null) {
                appointment.setScheduleDate(message.getScheduleDate());
            }
            appointment.setSchedulePeriod(message.getSchedulePeriod());
            appointment.setFee(message.getFee());

            boolean success = appointmentService.createAppointment(appointment);

            if (success) {
                log.info("[生成订单队列] 订单创建成功 traceId={} appointmentNo={}",
                        message.getTraceId(), appointment.getAppointmentNo());
            } else {
                log.warn("[生成订单队列] 订单创建失败 traceId={}", message.getTraceId());
            }

            channel.basicAck(deliveryTag, false);
        } catch (Exception e) {
            log.error("[生成订单队列] 处理异常 traceId={} error={}", message.getTraceId(), e.getMessage());
            channel.basicAck(deliveryTag, false);
        }
    }
}
