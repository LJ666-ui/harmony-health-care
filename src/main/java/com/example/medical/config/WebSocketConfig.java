package com.example.medical.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

/**
 * WebSocket配置类
 * 用于实时通信、聊天、通知推送
 */
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // 启用简单的内存消息代理
        // /topic 用于广播消息
        // /queue 用于点对点消息
        config.enableSimpleBroker("/topic", "/queue");
        
        // 客户端发送消息的前缀
        config.setApplicationDestinationPrefixes("/app");
        
        // 点对点消息的前缀
        config.setUserDestinationPrefix("/user");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 注册STOMP端点
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS();
        
        // 也支持原生WebSocket
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*");
    }
}
