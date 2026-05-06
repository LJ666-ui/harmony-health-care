# 网络连接问题解决方案

## 测试结果分析

从测试结果看：
- ✅ 10.0.9.202 - 可以连接（返回401）
- ✅ 192.168.66.1 - 可以连接（返回401）
- ✅ 192.168.108.1 - 可以连接（返回401）
- ✅ 127.0.0.1 - 可以连接（返回401）

**401错误是正常的**，说明网络通了，只是接口需要认证。

## 问题原因

虽然从宿主机可以连接这些IP，但**鸿蒙模拟器可能无法访问某些网络接口**。

可能的原因：
1. 模拟器网络隔离
2. 防火墙阻止了模拟器的连接
3. 模拟器使用的是虚拟网络，无法访问宿主机的某些IP

## 解决方案

### 方案1：配置防火墙允许模拟器连接

**步骤1：添加防火墙规则**

以管理员身份运行PowerShell：
```powershell
# 允许所有入站连接到8080端口
netsh advfirewall firewall add rule name="HealthCare-Allow-All" dir=in action=allow protocol=tcp localport=8080

# 允许所有出站连接
netsh advfirewall firewall add rule name="HealthCare-Allow-All-Out" dir=out action=allow protocol=tcp localport=8080
```

**步骤2：或者临时关闭防火墙**

1. Windows设置 → 更新和安全
2. Windows安全 → 防火墙和网络保护
3. 关闭所有网络的防火墙

### 方案2：尝试其他IP地址

既然测试显示多个IP都可以连接，尝试在模拟器中使用其他IP：

**尝试顺序**：

1. **192.168.66.1**（虚拟网络，可能模拟器可以访问）
2. **192.168.108.1**（另一个虚拟网络）
3. **127.0.0.1**（某些模拟器支持）

### 方案3：使用端口转发

如果模拟器支持端口转发，配置模拟器将8080端口转发到宿主机。

### 方案4：检查模拟器网络设置

在DevEco Studio中：
1. 打开模拟器设置
2. 查看网络配置
3. 确认模拟器可以访问宿主机网络

## 推荐操作步骤

### 步骤1：配置防火墙

```powershell
# 以管理员身份运行
netsh advfirewall firewall add rule name="HealthCare-8080" dir=in action=allow protocol=tcp localport=8080
```

### 步骤2：尝试 192.168.66.1

修改 `ApiConstants.ets`：
```typescript
[EnvType.DEV]: {
  BASE_URL: 'http://192.168.66.1:8080',
  UPLOAD_URL: 'http://192.168.66.1:8080/upload'
}
```

然后：
- Clean Project
- Rebuild Project
- 重新运行应用

### 步骤3：在模拟器浏览器测试

在鸿蒙模拟器的浏览器中访问：
```
http://192.168.66.1:8080/swagger-ui.html
```

如果能打开，说明这个IP可用。

### 步骤4：如果还不行，尝试 127.0.0.1

某些鸿蒙模拟器版本支持使用 localhost：
```typescript
[EnvType.DEV]: {
  BASE_URL: 'http://127.0.0.1:8080',
  UPLOAD_URL: 'http://127.0.0.1:8080/upload'
}
```

## 验证方法

修改配置并重新编译后：

1. 在HiLog中查看请求URL
2. 在后端查看是否收到请求
3. 查看是否还有"登录已过期"错误

## 如果所有方案都失败

考虑使用真机测试：

1. 手机和电脑连接同一Wi-Fi
2. 查看电脑IP：`ipconfig`
3. 使用电脑的局域网IP（如 192.168.1.100）
4. 确保防火墙允许连接

---
创建时间：2026-05-06
