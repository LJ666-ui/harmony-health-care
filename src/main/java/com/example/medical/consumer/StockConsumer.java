package com.example.medical.consumer;

import com.alibaba.fastjson.JSON;
import com.example.medical.config.RabbitMQConfig;
import com.example.medical.dto.AppointmentMessage;
import com.example.medical.service.RedisStockInterface;
import com.rabbitmq.client.Channel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Profile;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@Profile("rabbitmq")
public class StockConsumer {

    private static final Logger log = LoggerFactory.getLogger(StockConsumer.class);

    @Autowired
    private RedisStockInterface redisStockService;

    @RabbitListener(queues = RabbitMQConfig.STOCK_QUEUE)
    public void handleStockDeduction(AppointmentMessage message, Channel channel,
                                     @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) throws IOException {
        log.info("[减库存队列] 收到消息: {}", JSON.toJSONString(message));

        try {
            int grabResult = redisStockService.grabSlot(
                    message.getDoctorId(),
                    message.getScheduleDate(),
                    message.getSchedulePeriod(),
                    message.getUserId());

            if (grabResult == 1) {
                log.info("[减库存队列] 抢号成功 traceId={}", message.getTraceId());
            } else {
                log.warn("[减库存队列] 抢号失败 traceId={} result={} (1=成功 0=已满 -1=重复)",
                        message.getTraceId(), grabResult);
            }

            channel.basicAck(deliveryTag, false);
        } catch (Exception e) {
            log.error("[减库存队列] 处理异常 traceId={} error={}", message.getTraceId(), e.getMessage());
            channel.basicAck(deliveryTag, false);
        }
    }
}
