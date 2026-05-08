package com.example.medical.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    public static final String EXCHANGE_NAME = "appointment.exchange";

    public static final String STOCK_QUEUE = "appointment.stock.queue";
    public static final String STOCK_ROUTING_KEY = "appointment.stock";

    public static final String ORDER_QUEUE = "appointment.order.queue";
    public static final String ORDER_ROUTING_KEY = "appointment.order";

    @Bean
    public MessageConverter jsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory, MessageConverter messageConverter) {
        RabbitTemplate rabbitTemplate = new RabbitTemplate(connectionFactory);
        rabbitTemplate.setMessageConverter(messageConverter);
        return rabbitTemplate;
    }

    @Bean
    public DirectExchange appointmentExchange() {
        return new DirectExchange(EXCHANGE_NAME, true, false);
    }

    @Bean
    public Queue stockQueue() {
        return new Queue(STOCK_QUEUE, true, false, false);
    }

    @Bean
    public Queue orderQueue() {
        return new Queue(ORDER_QUEUE, true, false, false);
    }

    @Bean
    public Binding stockBinding(Queue stockQueue, DirectExchange appointmentExchange) {
        return BindingBuilder.bind(stockQueue).to(appointmentExchange).with(STOCK_ROUTING_KEY);
    }

    @Bean
    public Binding orderBinding(Queue orderQueue, DirectExchange appointmentExchange) {
        return BindingBuilder.bind(orderQueue).to(appointmentExchange).with(ORDER_ROUTING_KEY);
    }
}
