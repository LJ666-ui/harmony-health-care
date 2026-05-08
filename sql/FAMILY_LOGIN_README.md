# 家属登录功能 - SQL脚本使用说明

## 📋 文件说明

### 1. family_login_complete.sql（推荐使用）
**用途：** 完整创建家属登录功能，包含示例数据
**适用场景：**
- 新项目初始化
- 演示和测试
- 完整功能体验

**包含内容：**
- ✅ 创建user表（用户表）
- ✅ 创建family_member表（家属表，包含登录字段）
- ✅ 创建family_auth_log表（登录日志表）
- ✅ 插入示例用户数据（4个用户）
- ✅ 插入示例家属数据（10个家属）
- ✅ 插入示例登录日志
- ✅ 创建查询视图
- ✅ 数据统计

### 2. family_login_upgrade.sql
**用途：** 在现有数据库基础上升级，添加家属登录功能
**适用场景：**
- 已有项目升级
- 保留现有数据
- 生产环境部署

**包含内容：**
- ✅ 备份现有family_member表
- ✅ 扩展family_member表结构（添加登录字段）
- ✅ 创建family_auth_log表
- ✅ 数据迁移（生成默认密码）
- ✅ 紧急联系人自动开启登录
- ✅ 迁移日志记录

### 3. family_login_rollback.sql
**用途：** 回滚家属登录功能的所有变更
**适用场景：**
- 升级失败需要回滚
- 测试环境清理
- 功能撤销

**包含内容：**
- ✅ 删除新增的表
- ✅ 从备份恢复family_member表
- ✅ 验证恢复结果

---

## 🚀 快速开始

### 方案一：全新安装（推荐）

```bash
# 1. 登录MySQL
mysql -u root -p

# 2. 执行完整脚本
source /path/to/family_login_complete.sql

# 3. 验证安装
USE medical_health;
SHOW TABLES;
SELECT * FROM user;
SELECT * FROM family_member;
```

### 方案二：现有项目升级

```bash
# 1. 备份数据库（重要！）
mysqldump -u root -p medical_health > medical_health_backup_$(date +%Y%m%d).sql

# 2. 登录MySQL
mysql -u root -p

# 3. 执行升级脚本
USE medical_health;
source /path/to/family_login_upgrade.sql

# 4. 验证升级
SHOW COLUMNS FROM family_member;
SELECT * FROM family_member WHERE login_enabled = 1;
```

---

## 📊 数据库表结构

### user表（用户表）
```sql
主要字段：
- id: 用户ID（主键）
- username: 用户名/手机号（唯一）
- password: 密码（BCrypt加密）
- phone: 手机号（唯一）
- user_type: 用户类型（0-普通用户，1-医生）
- status: 状态（0-禁用，1-正常）
```

### family_member表（家属表）
```sql
基础字段：
- id: 家属ID（主键）
- user_id: 关联用户ID（外键）
- name: 家属姓名
- relation: 关系（配偶/子女/父母/兄弟姐妹/其他）
- phone: 手机号
- is_emergency_contact: 是否紧急联系人

登录字段（新增）：
- password: 登录密码（BCrypt加密）
- username: 登录用户名（可选）
- login_enabled: 是否允许登录（0-否，1-是）
- login_fail_count: 登录失败次数
- lock_until: 账号锁定截止时间
- last_login_time: 最后登录时间
```

### family_auth_log表（登录日志表）
```sql
主要字段：
- id: 日志ID（主键）
- family_id: 家属ID
- login_time: 登录时间
- login_ip: 登录IP
- login_device: 登录设备
- login_result: 登录结果（1-成功，0-失败）
- fail_reason: 失败原因
```

---

## 🔐 示例账号

### 用户账号（密码均为：123456）
| 用户ID | 手机号 | 姓名 | 说明 |
|--------|--------|------|------|
| 1 | 13900139001 | 王建国 | 普通用户 |
| 2 | 13900139002 | 李淑琴 | 普通用户 |
| 3 | 13900139003 | 张伟 | 普通用户 |
| 4 | 13900139004 | 刘芳 | 普通用户 |

### 家属账号（密码均为：123456）
| 家属ID | 手机号 | 姓名 | 关系 | 登录状态 | 说明 |
|--------|--------|------|------|----------|------|
| 1 | 13800138001 | 王秀英 | 配偶 | ✅ 已开启 | 紧急联系人 |
| 2 | 13800138002 | 王明 | 子女 | ❌ 未开启 | 需用户开启 |
| 3 | 13800138003 | 王建国（父亲） | 父母 | ❌ 未开启 | 需用户开启 |
| 4 | 13800138004 | 李强 | 配偶 | ✅ 已开启 | 紧急联系人 |
| 5 | 13800138005 | 李小雨 | 子女 | ❌ 未开启 | 需用户开启 |
| 6 | 13800138006 | 张丽 | 配偶 | ✅ 已开启 | 紧急联系人 |
| 7 | 13800138007 | 张小明 | 子女 | ❌ 未开启 | 需用户开启 |
| 8 | 13800138008 | 刘强 | 配偶 | ✅ 已开启 | 紧急联系人 |
| 9 | 13800138009 | 刘小芳 | 子女 | ❌ 未开启 | 需用户开启 |
| 10 | 13800138010 | 刘母 | 父母 | ❌ 未开启 | 需用户开启 |

---

## 🔧 关键SQL语句

### 1. 查询已开启登录的家属
```sql
SELECT
  f.id,
  f.name,
  f.phone,
  f.relation,
  u.real_name AS user_name
FROM family_member f
LEFT JOIN user u ON f.user_id = u.id
WHERE f.login_enabled = 1 AND f.is_deleted = 0;
```

### 2. 开启家属登录权限
```sql
-- 开启登录权限并设置密码
UPDATE family_member
SET
  login_enabled = 1,
  password = '$2a$10$N.zmdr9k7uOCQv37uk7jO.9.Mq8P5x1KQJ5Z5Z5Z5Z5Z5Z5Z5Z5Z5' -- 密码：123456
WHERE id = 2;
```

### 3. 关闭家属登录权限
```sql
UPDATE family_member
SET login_enabled = 0
WHERE id = 2;
```

### 4. 解锁被锁定的家属账号
```sql
UPDATE family_member
SET
  login_fail_count = 0,
  lock_until = NULL
WHERE id = 1;
```

### 5. 查询家属登录日志
```sql
SELECT
  f.name AS family_name,
  l.login_time,
  l.login_ip,
  l.login_device,
  CASE l.login_result
    WHEN 1 THEN '成功'
    ELSE '失败'
  END AS result,
  l.fail_reason
FROM family_auth_log l
LEFT JOIN family_member f ON l.family_id = f.id
ORDER BY l.login_time DESC
LIMIT 20;
```

### 6. 统计家属登录情况
```sql
SELECT
  '家属总数' AS item,
  COUNT(*) AS count
FROM family_member
WHERE is_deleted = 0
UNION ALL
SELECT
  '已开启登录' AS item,
  COUNT(*) AS count
FROM family_member
WHERE is_deleted = 0 AND login_enabled = 1
UNION ALL
SELECT
  '紧急联系人' AS item,
  COUNT(*) AS count
FROM family_member
WHERE is_deleted = 0 AND is_emergency_contact = 1;
```

---

## ⚠️ 注意事项

### 1. 密码安全
- ✅ 所有密码均使用BCrypt算法加密
- ✅ 示例密码为"123456"，生产环境请修改
- ✅ 建议使用手机号后6位作为初始密码

### 2. 登录权限
- ✅ 紧急联系人自动开启登录权限
- ✅ 其他家属需用户手动开启
- ✅ 用户可在家属管理页面控制

### 3. 账号安全
- ✅ 登录失败3次，账号锁定30分钟
- ✅ 所有登录尝试都会记录日志
- ✅ 支持IP和设备信息记录

### 4. 数据备份
- ⚠️ 升级前务必备份数据库
- ⚠️ 升级脚本会自动创建备份表
- ⚠️ 回滚脚本可恢复到升级前状态

---

## 🔄 升级流程

### 生产环境升级步骤

```bash
# 1. 停止应用服务
systemctl stop medical-app

# 2. 备份数据库
mysqldump -u root -p medical_health > backup_$(date +%Y%m%d_%H%M%S).sql

# 3. 执行升级脚本
mysql -u root -p medical_health < family_login_upgrade.sql

# 4. 验证升级结果
mysql -u root -p -e "USE medical_health; SELECT COUNT(*) FROM family_member WHERE login_enabled = 1;"

# 5. 启动应用服务
systemctl start medical-app

# 6. 测试登录功能
# 使用测试账号验证家属登录功能
```

### 回滚步骤（如果升级失败）

```bash
# 1. 停止应用服务
systemctl stop medical-app

# 2. 执行回滚脚本
mysql -u root -p medical_health < family_login_rollback.sql

# 3. 验证回滚结果
mysql -u root -p -e "USE medical_health; SHOW COLUMNS FROM family_member;"

# 4. 启动应用服务
systemctl start medical-app
```

---

## 📞 技术支持

如有问题，请检查：
1. MySQL版本是否支持（建议5.7+）
2. 字符集是否为utf8mb4
3. 外键约束是否正常
4. 索引是否创建成功

---

## 📝 更新日志

### v1.0 (2026-05-08)
- ✅ 初始版本发布
- ✅ 支持家属独立登录
- ✅ 支持登录权限管理
- ✅ 支持登录日志记录
- ✅ 支持账号锁定机制
