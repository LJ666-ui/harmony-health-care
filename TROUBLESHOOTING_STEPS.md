# 问题排查步骤

## 当前状态

- 后端服务：运行中（端口8080监听）
- 前端配置：已修改为 `http://10.0.9.202:8080`
- 错误：仍然显示 "Failed to connect to the server"

## 可能的原因

### 1. 应用未重新编译（最可能）

修改 `ApiConstants.ets` 后，**必须重新编译应用**才能生效！

**解决方法**：
1. 在DevEco Studio中，点击 **Build → Clean Project**
2. 然后点击 **Build → Rebuild Project**
3. 停止当前运行的应用
4. 重新运行应用

### 2. IP地址不正确

`10.0.9.202` 可能不是正确的网络接口。

**诊断方法**：
```bash
双击运行 diagnose-network.bat
```

查看哪个IP地址可以成功连接后端。

### 3. 防火墙阻止连接

即使配置了规则，防火墙可能仍在阻止。

**解决方法**：
- 临时关闭防火墙测试
- 或确保防火墙规则已添加

### 4. 模拟器网络配置问题

鸿蒙模拟器的网络配置可能有问题。

**解决方法**：
- 重启模拟器
- 检查模拟器网络设置

## 完整排查流程

### 步骤1：运行网络诊断

```bash
双击 diagnose-network.bat
```

查看输出，找到可以连接的IP地址。

### 步骤2：根据诊断结果修改配置

如果诊断显示某个IP可以连接，修改 `ApiConstants.ets`：

```typescript
[EnvType.DEV]: {
  BASE_URL: 'http://可连接的IP:8080',
  UPLOAD_URL: 'http://可连接的IP:8080/upload'
}
```

### 步骤3：重新编译应用（重要！）

在DevEco Studio中：
1. Build → Clean Project
2. Build → Rebuild Project
3. 停止应用
4. 重新运行应用

### 步骤4：查看应用日志

在DevEco Studio的HiLog中：
1. 过滤关键字：`HttpUtil`
2. 查看实际请求的URL
3. 查看错误详情

### 步骤5：查看后端日志

在后端控制台查看是否收到请求：
- 如果收到请求：说明网络通了，可能是接口问题
- 如果没收到请求：说明网络不通，继续排查网络

## 快速测试方法

### 方法1：在模拟器浏览器测试

在鸿蒙模拟器的浏览器中访问：
```
http://10.0.9.202:8080/swagger-ui.html
```

- 如果能打开：说明网络通了
- 如果打不开：说明网络不通，需要换IP

### 方法2：查看DevEco Studio日志

运行应用后，在HiLog中搜索：
- `HttpUtil`
- `Register`
- `send-code`

查看实际的请求URL和错误信息。

## 常见错误

### 错误1：修改配置后未重新编译

❌ 只修改了文件，没有重新编译
✅ 必须Clean + Rebuild + 重新运行

### 错误2：使用了错误的IP

❌ 使用了虚拟网络IP
✅ 使用实际可连接的IP

### 错误3：防火墙阻止

❌ 防火墙规则未生效
✅ 临时关闭防火墙测试

## 下一步操作

**请按顺序执行**：

1. **运行诊断工具**
   ```bash
   双击 diagnose-network.bat
   ```
   查看哪个IP可以连接

2. **根据结果修改配置**
   - 如果某个IP测试成功，使用该IP
   - 如果都失败，说明是防火墙问题

3. **重新编译应用**
   - DevEco Studio: Build → Clean Project
   - Build → Rebuild Project
   - 重新运行应用

4. **查看日志**
   - HiLog: 搜索 "HttpUtil"
   - 后端控制台: 查看是否收到请求

5. **测试验证码**
   - 输入手机号
   - 点击"获取验证码"
   - 查看是否成功

## 如果还是不行

请提供以下信息：
1. diagnose-network.bat 的完整输出
2. DevEco Studio HiLog 中的错误日志
3. 后端控制台是否收到请求

---
创建时间：2026-05-06
