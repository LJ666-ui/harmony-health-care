# 普通用户注册失败问题完整修复指南

## 问题诊断

根据后端日志，错误信息为：
```
java.sql.SQLSyntaxErrorException: Unknown column 'real_name' in 'field list'
```

**原因**：数据库表 `user` 缺少医生相关字段，导致查询失败。

## 完整修复步骤

### 步骤1：诊断数据库当前状态

执行诊断脚本：
```bash
mysql -u root -p123456 < diagnose-database.sql
```

检查输出结果，确认：
- user表是否存在
- real_name字段是否存在
- 其他必需字段是否完整

### 步骤2：更新数据库表结构

**如果real_name字段不存在**，执行更新脚本：

```bash
mysql -u root -p123456 medical_health < update-user-table.sql
```

**或者手动执行SQL**：
```sql
USE medical_health;

ALTER TABLE `user` 
ADD COLUMN `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名' AFTER `user_type`,
ADD COLUMN `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号' AFTER `age`,
ADD COLUMN `hospital` varchar(100) DEFAULT NULL COMMENT '所属医院' AFTER `real_name`,
ADD COLUMN `department` varchar(50) DEFAULT NULL COMMENT '科室' AFTER `hospital`,
ADD COLUMN `license_number` varchar(50) DEFAULT NULL COMMENT '执业证号' AFTER `department`;
```

### 步骤3：验证表结构

```sql
USE medical_health;
DESC user;
```

**期望输出应包含以下字段**：
```
+---------------+--------------+------+-----+---------+----------------+
| Field         | Type         | Null | Key | Default | Extra          |
+---------------+--------------+------+-----+---------+----------------+
| id            | bigint       | NO   | PRI | NULL    | auto_increment |
| username      | varchar(50)  | NO   | UNI | NULL    |                |
| password      | varchar(100) | NO   |     | NULL    |                |
| nickname      | varchar(50)  | YES  |     | NULL    |                |
| avatar        | varchar(255) | YES  |     | NULL    |                |
| gender        | tinyint      | YES  |     | NULL    |                |
| age           | int          | YES  |     | NULL    |                |
| id_card       | varchar(18)  | YES  |     | NULL    |                |
| phone         | varchar(20)  | YES  |     | NULL    |                |
| email         | varchar(50)  | YES  |     | NULL    |                |
| user_type     | tinyint      | YES  |     | 0       |                |
| real_name     | varchar(50)  | YES  |     | NULL    |                |
| hospital      | varchar(100) | YES  |     | NULL    |                |
| department    | varchar(50)  | YES  |     | NULL    |                |
| license_number| varchar(50)  | YES  |     | NULL    |                |
| status        | tinyint      | YES  |     | 1       |                |
| create_time   | datetime     | YES  |     | NULL    |                |
| update_time   | datetime     | YES  |     | NULL    |                |
| is_deleted    | tinyint      | YES  |     | 0       |                |
+---------------+--------------+------+-----+---------+----------------+
```

### 步骤4：重启后端服务

1. 停止当前运行的Spring Boot应用
2. 重新启动应用
3. 查看启动日志，确认没有错误

### 步骤5：测试注册功能

**使用Postman或curl测试**：

```bash
curl -X POST http://localhost:8080/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "13948999643",
    "password": "123456",
    "phone": "13948999643",
    "userType": 0
  }'
```

**期望响应**：
```json
{
  "code": 200,
  "msg": "操作成功",
  "data": {
    "userId": 1,
    "message": "注册成功",
    "userType": 0
  }
}
```

### 步骤6：前端测试

1. 打开前端应用
2. 进入注册页面
3. 选择"普通用户"
4. 输入手机号：`13948999643`
5. 点击"获取验证码"（自动填充：`123456`）
6. 输入密码：`123456`
7. 确认密码：`123456`
8. 勾选用户协议
9. 点击"立即注册"
10. 应该成功注册并自动登录

## 常见问题排查

### Q1: 字段已存在但仍然报错

**可能原因**：
- MyBatis缓存问题
- 数据库连接池缓存

**解决方案**：
```bash
# 重启MySQL服务
net stop MySQL80
net start MySQL80

# 重启后端应用
```

### Q2: 注册时提示"用户名已存在"

**检查数据库**：
```sql
SELECT * FROM user WHERE username = '13948999643';
```

**如果存在，删除测试数据**：
```sql
DELETE FROM user WHERE username = '13948999643';
```

### Q3: 密码加密问题

**检查BCrypt加密**：
```sql
SELECT username, password FROM user WHERE username = '13948999643';
```

密码应该是BCrypt加密后的格式，类似：
```
$2a$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Q4: 前端发送数据格式问题

**检查前端请求**：
- 打开浏览器开发者工具
- 切换到Network标签
- 提交注册表单
- 查看 `/user/register` 请求
- 检查Request Payload

**期望格式**：
```json
{
  "username": "13948999643",
  "password": "123456",
  "phone": "13948999643",
  "userType": 0
}
```

## 完整数据库重建（最后手段）

如果以上步骤都无法解决，可以重建数据库：

```bash
# 1. 删除数据库
mysql -u root -p123456 -e "DROP DATABASE IF EXISTS medical_health;"

# 2. 重新创建并初始化
mysql -u root -p123456 < init-database.sql

# 3. 验证表结构
mysql -u root -p123456 -e "USE medical_health; DESC user;"

# 4. 重启后端服务
```

## 验证清单

- [ ] MySQL服务正常运行
- [ ] 数据库连接成功（用户名：root，密码：123456）
- [ ] medical_health数据库存在
- [ ] user表存在
- [ ] user表包含所有必需字段（包括real_name等）
- [ ] 后端服务启动成功
- [ ] 验证码接口正常（/user/send-code）
- [ ] 注册接口正常（/user/register）
- [ ] 前端可以成功注册

## 联系支持

如果问题仍然存在，请提供：
1. 数据库诊断脚本输出结果
2. 后端完整错误日志
3. 前端请求和响应数据
4. 数据库表结构截图
