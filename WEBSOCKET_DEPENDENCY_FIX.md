# WebSocket依赖缺失问题修复说明

## 问题描述

在编译项目时出现以下错误：

```
程序包 org.springframework.messaging.simp.config 不存在
程序包 org.springframework.web.socket.config.annotation 不存在
找不到符号: 类 MessageBrokerRegistry
找不到符号: 类 EnableWebSocketMessageBroker
找不到符号: 类 StompEndpointRegistry
```

## 问题原因

项目缺少Spring WebSocket和Spring Messaging相关依赖包。这些类属于Spring Framework的WebSocket模块，需要显式引入依赖。

## 解决方案

已在`pom.xml`中添加WebSocket依赖：

```xml
<!-- WebSocket依赖（实时通信必需） -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

这个依赖包含了：
- `spring-websocket`：WebSocket核心功能
- `spring-messaging`：STOMP消息协议支持
- `spring-boot-starter-web`：Web功能（已包含）

## 下一步操作

### 1. 刷新Maven依赖

在IDE中执行以下操作之一：

**方法A：使用IDE**
- 右键点击`pom.xml`
- 选择`Maven` → `Reload Project`
- 或点击Maven工具栏的刷新按钮（🔄）

**方法B：使用命令行**
```bash
mvn clean install
```

### 2. 重新构建项目

**方法A：使用IDE**
- 菜单栏：`Build` → `Rebuild Project`

**方法B：使用命令行**
```bash
mvn clean compile
```

### 3. 验证修复

重新编译后，以下文件应该不再报错：
- `WebSocketConfig.java`
- `WebSocketController.java`
- `PrescriptionController.java`
- `EmergencyNotificationController.java`

## WebSocket功能说明

添加此依赖后，项目将支持以下功能：

### 1. WebSocket配置
- STOMP协议支持
- 消息代理配置
- 端点注册

### 2. 实时通信
- 聊天消息实时推送
- 紧急通知多端推送
- 用药提醒实时推送
- 数据同步实时推送

### 3. 消息类型
- `/topic/*`：广播消息
- `/queue/*`：点对点消息
- `/user/*`：用户特定消息

## 相关文件

### 已创建的WebSocket相关文件：

**后端：**
- `src/main/java/com/example/medical/config/WebSocketConfig.java`
- `src/main/java/com/example/medical/controller/WebSocketController.java`
- `src/main/java/com/example/medical/controller/PrescriptionController.java`
- `src/main/java/com/example/medical/controller/EmergencyNotificationController.java`

**前端：**
- `entry/src/main/ets/services/WebSocketService.ets`
- `entry/src/main/ets/services/ChatService.ets`
- `entry/src/main/ets/services/MedicalService.ets`
- `entry/src/main/ets/services/NotificationService.ets`
- `entry/src/main/ets/components/MedicationReminderComponent.ets`
- `entry/src/main/ets/components/EmergencyNotificationComponent.ets`

## 验证步骤

### 1. 检查依赖是否正确引入

在IDE中打开`External Libraries`，应该能看到：
- `spring-websocket-5.3.x.jar`
- `spring-messaging-5.3.x.jar`

### 2. 检查类是否可导入

在Java文件中，以下导入应该不再报错：
```java
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
```

### 3. 启动应用测试

启动Spring Boot应用后，WebSocket端点应该可用：
- WebSocket端点：`ws://localhost:8080/ws`
- STOMP端点：`ws://localhost:8080/ws`（支持SockJS）

## 常见问题

### Q1: 刷新Maven后仍然报错？

**解决方案：**
1. 清理IDE缓存：`File` → `Invalidate Caches / Restart`
2. 删除本地Maven仓库中的相关依赖，重新下载
3. 检查网络连接，确保能访问Maven中央仓库

### Q2: 启动应用时WebSocket相关错误？

**解决方案：**
1. 检查端口8080是否被占用
2. 检查WebSocket配置是否正确
3. 查看应用启动日志，确认WebSocket端点是否注册成功

### Q3: 前端无法连接WebSocket？

**解决方案：**
1. 检查后端是否正常启动
2. 检查WebSocket URL是否正确
3. 检查跨域配置
4. 查看浏览器控制台错误信息

## 总结

✅ 已在`pom.xml`中添加`spring-boot-starter-websocket`依赖
✅ 该依赖包含WebSocket和STOMP协议支持
✅ 刷新Maven依赖后，编译错误应该消失
✅ 项目现在支持完整的实时通信功能

**请按照上述步骤操作，问题应该得到解决。**
