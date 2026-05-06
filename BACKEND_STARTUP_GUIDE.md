# 后端服务启动指南（更新版）

## 问题诊断

您遇到的"Failed to connect to the server"错误是因为**后端Spring Boot服务没有启动**。

## 数据库文件说明

项目中已有完整的数据库文件：
- **sql/medical_health(13).sql** - 完整数据库（约25MB，包含所有表和数据）
- **sql/medical_health.sql** - 基础数据库结构

## 快速启动步骤

### 步骤1：导入数据库

**方法A：使用导入脚本（推荐）**
```bash
双击运行 import-database.bat
```

**方法B：手动导入**
```bash
mysql -u root -p123456 < sql\medical_health(13).sql
```

**方法C：使用MySQL工具**
1. 打开MySQL Workbench或Navicat
2. 连接到MySQL服务器（localhost:3306, root/123456）
3. 执行 `sql/medical_health(13).sql` 文件

### 步骤2：检查环境

双击运行 `check-env.bat`，确认：
- ✓ Java环境正常
- ✓ Maven环境正常
- ✓ 端口8080可用

### 步骤3：启动后端服务

**方法A：使用启动脚本（推荐）**
```bash
双击运行 start-backend.bat
```
脚本会自动：
- 检查环境
- 询问是否导入数据库
- 编译项目
- 启动服务

**方法B：手动启动**
```bash
# 编译项目
mvn clean install -DskipTests

# 启动服务
mvn spring-boot:run
```

**方法C：使用IDE**
1. 用IntelliJ IDEA打开项目
2. 找到 `src/main/java/com/example/medical/MedicalApplication.java`
3. 右键 → Run 'MedicalApplication'

### 步骤4：验证启动成功

启动成功后会看到：
```
Started MedicalApplication in X.XXX seconds
Tomcat started on port(s): 8080 (http)
```

验证方式：
- Swagger文档：http://localhost:8080/swagger-ui.html
- 测试接口：http://localhost:8080/user/info

## 数据库配置

**默认配置**（application.yml）：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/medical_health
    username: root
    password: 123456
```

**如果您的MySQL密码不是123456**，需要修改：
1. 打开 `src/main/resources/application.yml`
2. 修改 `spring.datasource.password` 为您的密码
3. 同时修改 `import-database.bat` 中的密码

## 前端配置

**当前配置**（适用于模拟器）：
- API地址：`http://10.0.2.2:8080`
- 配置文件：`entry/src/main/ets/common/constants/ApiConstants.ets`

**真机测试配置**：
如果使用真机测试，需要修改为电脑局域网IP：
```typescript
[EnvType.DEV]: { 
  BASE_URL: 'http://192.168.x.x:8080',  // 改为你的电脑IP
  UPLOAD_URL: 'http://192.168.x.x:8080/upload' 
}
```

查看电脑IP：
```bash
ipconfig  # Windows
# 找到 "IPv4 地址" 那一行
```

## 常见问题

### Q1: 数据库导入失败

**原因**：文件太大（25MB）或MySQL配置限制

**解决方案**：
1. 修改MySQL配置（my.ini）：
   ```ini
   [mysqld]
   max_allowed_packet=64M
   ```
2. 重启MySQL服务
3. 重新导入

### Q2: 端口8080被占用

**解决方案**：修改端口
```yaml
# application.yml
server:
  port: 8081  # 改为其他端口
```

同时修改前端API地址。

### Q3: MySQL连接失败

**检查项**：
- MySQL服务是否启动
- 用户名密码是否正确
- 数据库 `medical_health` 是否存在
- 防火墙是否阻止连接

### Q4: 编译失败

**解决方案**：
```bash
# 清理缓存
mvn clean

# 更新依赖
mvn dependency:resolve

# 重新编译
mvn compile
```

### Q5: 真机无法连接

**检查项**：
1. 手机和电脑在同一局域网
2. 电脑防火墙开放8080端口
3. 前端API地址配置为电脑IP（不是10.0.2.2）

## 测试账号

数据库中已包含测试数据，可以使用以下账号登录：
- 查看数据库中的 `user` 表获取测试账号

## 完整启动流程

```
1. import-database.bat     → 导入数据库
2. check-env.bat          → 检查环境
3. start-backend.bat      → 启动后端
4. 访问 swagger-ui.html   → 验证服务
5. 运行鸿蒙应用           → 测试功能
```

## 文件说明

- **import-database.bat** - 数据库导入脚本
- **check-env.bat** - 环境检查脚本
- **start-backend.bat** - 后端启动脚本
- **sql/medical_health(13).sql** - 完整数据库文件（25MB）

---
更新时间：2026-05-06
