# 支付宝沙箱环境配置指南

## 一、获取最新配置信息

### 1. 登录支付宝开放平台
- 地址：https://openhome.alipay.com/
- 使用您的支付宝账号登录

### 2. 进入沙箱环境
- 路径：开发服务 → 研发服务 → 沙箱环境

### 3. 获取关键信息

#### 应用信息
```
AppID: 9021000163649133（或您的新AppID）
```

#### 密钥配置
```
1. 点击"设置" → "RSA2(SHA256)密钥(推荐)"

2. 如果已有密钥：
   - 查看应用私钥（用于 AlipayConfig.APP_PRIVATE_KEY）
   - 查看支付宝公钥（用于 AlipayConfig.ALIPAY_PUBLIC_KEY）

3. 如果需要重新生成：
   a. 使用 OpenSSL 生成新密钥对：
      ```bash
      openssl genrsa -out app_private_key.pem 2048
      openssl rsa -in app_private_key.pem -pubout -out app_public_key.pem
      ```
   
   b. 将公钥内容复制到支付宝平台的"应用公钥"输入框
   
   c. 保存后，复制"支付宝公钥"

#### 沙箱买家账号（重要！）
```
点击"沙箱账号"标签页：

买家账号：xxx@sandbox.com
买家密码：xxxxxx
支付密码：xxxxxx

⚠️ 请务必记录这些信息！
```

---

## 二、更新项目配置

### 更新文件：src/main/java/com/example/medical/config/AlipayConfig.java

将以下字段替换为新值：

```java
// 第11行：AppID（如果有变化）
public static final String APP_ID = "您的AppID";

// 第12行：应用私钥（新生成的）
public static final String APP_PRIVATE_KEY = "您的应用私钥";

// 第13行：支付宝公钥（从平台复制的）
public static final String ALIPAY_PUBLIC_KEY = "您的支付宝公钥";
```

---

## 三、测试支付流程

### 1. 重启后端服务
```bash
cd d:\harmony-health-care
mvn spring-boot:run
```

### 2. 测试创建订单
使用 Postman 或前端发起支付请求：
```
POST http://localhost:8080/pay/create
Body:
{
    "userId": 1,
    "doctorId": 20,
    "scheduleDate": "20260512",
    "schedulePeriod": 1,
    "fee": 50.00
}
```

### 3. 使用沙箱账号完成支付
- 返回的 payForm 是一个 HTML 表单
- 在浏览器中打开该表单
- 使用沙箱买家账号登录并支付
- 密码通常是：`111111`

---

## 四、常见问题 FAQ

### Q1: 提示"账号不存在"怎么办？
A: 去支付宝开放平台重新获取沙箱买家账号，可能被重置了。

### Q2: 提示"密钥不匹配"怎么办？
A: 
1. 确认使用的私钥与上传到平台的公钥是一对
2. 确认使用的是"支付宝公钥"，不是"应用公钥"
3. 尝试重新生成密钥对

### Q3: 支付成功但回调失败怎么办？
A:
1. 检查 NOTIFY_URL 是否可从外网访问
2. 沙箱环境的回调地址可以是 localhost
3. 查看后端日志确认回调是否收到

### Q4: 如何模拟不同支付场景？
A:
- 支付宝沙箱支持多种测试场景：
  - 正常支付
  - 退款
  - 关闭交易
  
参考文档：https://opendocs.alipay.com/open/common/sandbox

---

## 五、应急方案：绕过支付宝直接完成支付

如果沙箱环境持续不可用，可以临时启用"模拟支付模式"：

### 方案：添加模拟支付开关

在 PayController.java 的 createPayment 方法中添加：

```java
// 在第85行之前添加
boolean mockPayment = true; // 设置为true启用模拟支付

if (mockPayment) {
    // 直接标记为已支付，跳过支付宝
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
    
    Map<String, Object> result = new HashMap<>();
    result.put("outTradeNo", outTradeNo);
    result.put("payForm", "");
    result.put("payType", "mock");
    result.put("message", "模拟支付成功");
    return Result.success(result);
}
```

⚠️ 注意：此方案仅用于开发和测试，生产环境必须移除！

---

## 六、联系方式与技术支持

### 官方文档
- 开放平台：https://openhome.alipay.com/
- API文档：https://opendocs.alipay.com/open/
- 沙箱说明：https://opendocs.alipay.com/open/common/sandbox

### 技术支持
- 开发者社区：https://forum.alipay.com/
- 工单系统：在开放平台提交工单

---

**最后更新时间：** 2026-05-12
**适用版本：** Harmony Health Care v1.0
