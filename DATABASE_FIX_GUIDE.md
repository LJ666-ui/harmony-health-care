# 数据库连接失败问题修复指南

## 问题描述

后端日志显示：
```
java.sql.SQLException: Access denied for user 'root'@'localhost' (using password: YES)
```

**原因**：MySQL数据库拒绝了用户 `root` 的连接请求，密码验证失败。

## 当前配置

配置文件：`src/main/resources/application.yml`
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/medical_health?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8&allowPublicKeyRetrieval=true
    username: root
    password: 123456
```

## 解决方案

### 方案1：修改MySQL root密码为123456（推荐用于测试环境）

1. **打开MySQL命令行工具**（以管理员身份运行）

2. **执行以下SQL命令**：
```sql
-- 如果您能登录MySQL，执行以下命令修改root密码
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
FLUSH PRIVILEGES;
```

3. **如果无法登录MySQL，需要重置root密码**：
   - 停止MySQL服务
   - 以跳过权限表的方式启动MySQL
   - 重置密码
   - 重启MySQL服务

### 方案2：修改配置文件使用正确的MySQL密码

如果您知道MySQL的实际root密码，修改配置文件：

1. 打开 `src/main/resources/application.yml`
2. 修改第10行的密码：
```yaml
password: 您的MySQL实际密码
```

### 方案3：创建专用数据库用户（推荐用于生产环境）

1. **登录MySQL**：
```bash
mysql -u root -p
```

2. **执行以下SQL命令**：
```sql
-- 创建数据库
CREATE DATABASE IF NOT EXISTS medical_health 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_general_ci;

-- 创建专用用户
CREATE USER 'medical_user'@'localhost' IDENTIFIED BY 'medical123';

-- 授予权限
GRANT ALL PRIVILEGES ON medical_health.* TO 'medical_user'@'localhost';
FLUSH PRIVILEGES;

-- 退出
exit;
```

3. **修改配置文件** `src/main/resources/application.yml`：
```yaml
spring:
  datasource:
    username: medical_user
    password: medical123
```

## 初始化数据库

解决连接问题后，需要初始化数据库：

1. **登录MySQL**：
```bash
mysql -u root -p
```

2. **执行初始化脚本**：
```sql
source E:/HMOS6.0/Github/harmony-health-care/init-database.sql
```

或者在命令行中直接执行：
```bash
mysql -u root -p < E:/HMOS6.0/Github/harmony-health-care/init-database.sql
```

## 验证步骤

1. **测试数据库连接**：
```bash
mysql -u root -p123456
```

2. **检查数据库是否存在**：
```sql
SHOW DATABASES;
USE medical_health;
SHOW TABLES;
```

3. **重启后端服务**：
   - 停止当前运行的Spring Boot应用
   - 重新启动应用

4. **测试注册功能**：
   - 打开前端应用
   - 进入注册页面
   - 填写信息并提交
   - 应该能够成功注册

## 常见问题

### Q1: MySQL服务未启动

**Windows**：
```bash
net start MySQL80  # 或 MySQL57，取决于您的版本
```

**Linux/Mac**：
```bash
sudo systemctl start mysql
# 或
sudo service mysql start
```

### Q2: 端口3306被占用

检查端口占用：
```bash
netstat -ano | findstr :3306
```

### Q3: 防火墙阻止连接

确保Windows防火墙允许MySQL通过，或临时关闭防火墙进行测试。

### Q4: 字符集问题

确保数据库使用utf8mb4字符集：
```sql
SHOW VARIABLES LIKE 'character_set%';
```

## 快速修复脚本

创建一个批处理文件 `fix-database.bat`：

```batch
@echo off
echo ========================================
echo 鸿蒙健康医疗应用 - 数据库修复脚本
echo ========================================
echo.

echo 请确保MySQL服务已启动
echo.

set /p DB_PASSWORD=请输入MySQL root密码：

echo.
echo 正在创建数据库和用户...
mysql -u root -p%DB_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS medical_health DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; ALTER USER 'root'@'localhost' IDENTIFIED BY '123456'; FLUSH PRIVILEGES;"

echo.
echo 正在初始化数据库表结构...
mysql -u root -p123456 medical_health < init-database.sql

echo.
echo ========================================
echo 数据库修复完成！
echo 请重启后端服务
echo ========================================
pause
```

## 下一步

1. 选择上述方案之一修复数据库连接问题
2. 初始化数据库表结构
3. 重启后端服务
4. 测试注册功能

如果问题仍然存在，请检查：
- MySQL服务是否正常运行
- 防火墙设置
- MySQL配置文件（my.ini或my.cnf）
- MySQL错误日志
