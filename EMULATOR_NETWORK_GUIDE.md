# 鸿蒙模拟器网络连接问题诊断

## 问题现象

- 使用鸿蒙模拟器测试
- 后端服务已启动（端口8080监听正常）
- 前端配置：`http://10.0.2.2:8080`
- 错误：**"Failed to connect to the server"**

## 关键发现

**鸿蒙模拟器与Android模拟器的网络机制不同！**

- Android模拟器：`10.0.2.2` 指向宿主机
- **鸿蒙模拟器**：可能不支持 `10.0.2.2`，需要使用宿主机实际IP

## 解决方案

### 方案1：使用宿主机IP（推荐）

从您的ipconfig结果，选择合适的IP地址：
- `10.0.9.202` - 可能是WSL或虚拟网络
- `192.168.137.1` - 可能是移动热点
- `192.168.66.1` - 可能是虚拟网络
- `192.168.108.1` - 可能是虚拟网络

**建议使用**：`10.0.9.202`（看起来是主网络接口）

#### 修改步骤：

1. 编辑文件：`entry/src/main/ets/common/constants/ApiConstants.ets`

2. 修改第16行：
```typescript
// 修改前
[EnvType.DEV]: { BASE_URL: 'http://10.0.2.2:8080', UPLOAD_URL: 'http://10.0.2.2:8080/upload' }

// 修改后（尝试方案1）
[EnvType.DEV]: { BASE_URL: 'http://10.0.9.202:8080', UPLOAD_URL: 'http://10.0.9.202:8080/upload' }
```

3. 重新运行应用测试

### 方案2：尝试其他IP地址

如果方案1不行，依次尝试：

```typescript
// 尝试方案2
[EnvType.DEV]: { BASE_URL: 'http://192.168.137.1:8080', UPLOAD_URL: 'http://192.168.137.1:8080/upload' }

// 尝试方案3
[EnvType.DEV]: { BASE_URL: 'http://192.168.66.1:8080', UPLOAD_URL: 'http://192.168.66.1:8080/upload' }

// 尝试方案4
[EnvType.DEV]: { BASE_URL: 'http://192.168.108.1:8080', UPLOAD_URL: 'http://192.168.108.1:8080/upload' }
```

### 方案3：使用localhost（如果模拟器支持）

某些鸿蒙模拟器版本可能支持：
```typescript
[EnvType.DEV]: { BASE_URL: 'http://localhost:8080', UPLOAD_URL: 'http://localhost:8080/upload' }
```

## 验证步骤

### 步骤1：测试后端接口

运行测试脚本：
```bash
双击 test-api.bat
```

确认所有接口返回正常。

### 步骤2：在模拟器浏览器测试

在鸿蒙模拟器的浏览器中访问：
```
http://10.0.9.202:8080/swagger-ui.html
```

如果能打开，说明网络连通。

### 步骤3：查看应用日志

在DevEco Studio中查看日志：
- 打开 HiLog
- 过滤关键字：`HttpUtil`
- 查看实际请求的URL和错误信息

## 防火墙配置

确保Windows防火墙允许8080端口：

```powershell
# 以管理员身份运行
netsh advfirewall firewall add rule name="HealthCare API" dir=in action=allow protocol=tcp localport=8080
netsh advfirewall firewall add rule name="HealthCare API" dir=out action=allow protocol=tcp localport=8080
```

## 后端配置检查

确认后端监听所有网络接口：

检查 `application.yml`：
```yaml
server:
  address: 0.0.0.0  # 监听所有接口
  port: 8080
```

从您的日志看，后端配置正确：
```
TCP    0.0.0.0:8080    LISTENING
```

## 完整测试流程

1. **修改前端配置**
   - 使用 `http://10.0.9.202:8080`

2. **配置防火墙**
   - 开放8080端口

3. **重启应用**
   - 在DevEco Studio重新运行应用

4. **测试验证码**
   - 输入手机号
   - 点击"获取验证码"
   - 查看是否成功

5. **查看日志**
   - DevEco Studio HiLog
   - 后端控制台日志

## 调试技巧

### 在前端添加日志

在 `Register.ets` 的 `sendVerificationCode` 方法中添加：
```typescript
console.log('[Register] 发送验证码请求:', ApiConstants.USER_SEND_CODE);
console.log('[Register] 完整URL:', getBaseUrl() + '/user/send-code');
```

### 检查网络状态

在应用中添加网络检测：
```typescript
import connection from '@ohos.net.connection';

// 检查网络连接
let netHandle = connection.getDefaultNet();
console.log('[Network] 默认网络:', netHandle);
```

## 常见问题

### Q1: 修改IP后还是无法连接

尝试：
1. 完全关闭模拟器，重新启动
2. 清除应用数据，重新安装
3. 检查是否有多个网络适配器冲突

### Q2: 后端日志没有收到请求

说明请求根本没到达后端，是网络层面的问题：
1. 检查防火墙
2. 尝试关闭防火墙测试
3. 检查IP地址是否正确

### Q3: 后端收到请求但返回错误

查看后端日志，可能是：
1. 接口路径错误
2. 参数格式错误
3. CORS跨域问题

## 推荐配置

基于您的网络环境，推荐配置：

```typescript
// ApiConstants.ets
const ENV_MAP: Record<EnvType, EnvConfig> = {
  [EnvType.DEV]: {
    BASE_URL: 'http://10.0.9.202:8080',
    UPLOAD_URL: 'http://10.0.9.202:8080/upload'
  },
  // ...
};
```

---
创建时间：2026-05-06
