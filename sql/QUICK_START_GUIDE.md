# 🚀 快速使用指南 - 家属登录功能

## 📋 根据您的数据库状态，推荐使用：

### ✅ **family_login_upgrade_enhanced.sql** （增强版升级脚本）

**适用场景：**
- ✅ 已有现有数据（您的情况：39个用户、5个家属）
- ✅ user表密码是明文（需要加密）
- ✅ family_member表缺少登录字段
- ✅ 需要保留现有数据

---

## 🎯 执行步骤（3步完成）

### 步骤1：备份数据库（重要！）
```bash
# 在命令行执行
mysqldump -u root -p medical_health > medical_health_backup_20260508.sql
```

### 步骤2：执行升级脚本
```sql
-- 方式1：在MySQL命令行执行
mysql -u root -p
USE medical_health;
source e:\HMOS6.0\Github\harmony-health-care\sql\family_login_upgrade_enhanced.sql

-- 方式2：在Navicat/DBeaver等工具中
-- 打开family_login_upgrade_enhanced.sql文件，直接执行全部
```

### 步骤3：验证结果
```sql
-- 查看user表密码是否已加密
SELECT id, username, password FROM user LIMIT 5;

-- 查看family_member表新字段
SHOW COLUMNS FROM family_member;

-- 查看已开启登录的家属
SELECT id, name, phone, relation, login_enabled, is_emergency_contact
FROM family_member;
```

---

## 📊 执行后的变化

### user表变化：
- ✅ 密码从明文"123456"变为BCrypt加密
- ✅ password字段长度扩展为VARCHAR(255)
- ✅ phone字段添加唯一索引

### family_member表变化：
- ✅ 新增password字段（登录密码）
- ✅ 新增username字段（登录用户名）
- ✅ 新增login_enabled字段（是否允许登录）
- ✅ 新增login_fail_count字段（登录失败次数）
- ✅ 新增lock_until字段（账号锁定时间）
- ✅ 新增last_login_time字段（最后登录时间）
- ✅ 紧急联系人自动开启登录权限

### 新增表：
- ✅ family_auth_log表（登录日志）
- ✅ migration_log表（迁移日志）

---

## 🔐 登录信息

### 用户登录（不变）：
- 使用username或phone字段登录
- 密码：123456（已BCrypt加密）

### 家属登录（新增）：
- 使用phone字段登录
- 密码：123456（已BCrypt加密）
- 只有login_enabled=1的家属可以登录

### 当前可登录的家属：
根据您的数据，以下家属已自动开启登录权限：
- 王秀英（配偶，紧急联系人）
- 李强（配偶，紧急联系人）

---

## ⚠️ 重要提示

### 1. 密码验证
后端需要使用BCrypt验证密码：
```java
// Java示例
BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
boolean matches = encoder.matches("123456", user.getPassword());
```

### 2. 开启其他家属登录权限
```sql
-- 手动开启某个家属的登录权限
UPDATE family_member
SET login_enabled = 1
WHERE id = 家属ID;
```

### 3. 如需回滚
```sql
-- 执行回滚脚本
source e:\HMOS6.0\Github\harmony-health-care\sql\family_login_rollback_enhanced.sql
```

---

## 📞 常见问题

### Q1: 执行报错怎么办？
**A:**
1. 检查MySQL版本（建议5.7+）
2. 确认有足够权限
3. 查看错误信息，通常是字段已存在
4. 可以先执行回滚，再重新升级

### Q2: 密码验证失败？
**A:**
1. 确认使用BCrypt验证
2. 检查密码字段长度是否为255
3. 确认前端传输的密码未加密

### Q3: 家属无法登录？
**A:**
1. 检查login_enabled是否为1
2. 检查phone字段是否有值
3. 检查password字段是否有值

---

## 🎉 完成后下一步

1. ✅ 开发后端登录接口
2. ✅ 开发前端登录页面
3. ✅ 测试登录功能
4. ✅ 部署到生产环境

---

## 📁 相关文件

- `family_login_upgrade_enhanced.sql` - 增强版升级脚本（推荐）
- `family_login_rollback_enhanced.sql` - 增强版回滚脚本
- `family_login_upgrade.sql` - 基础升级脚本
- `family_login_complete.sql` - 完整创建脚本（新项目用）
- `FAMILY_LOGIN_README.md` - 详细说明文档

---

**现在就开始执行吧！** 🚀
