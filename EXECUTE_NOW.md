# 立即执行：数据库表结构更新

## 问题确认

错误信息：
```
java.sql.SQLSyntaxErrorException: Unknown column 'real_name' in 'field list'
```

**原因**：数据库表 `user` 缺少 `real_name` 等字段，您还没有执行数据库更新脚本。

## 立即执行（3种方式任选其一）

### 方式1：执行批处理脚本（推荐）

双击运行：
```
update-database.bat
```

### 方式2：执行SQL文件

打开命令行，执行：
```bash
mysql -u root -p123456 medical_health < update-user-table.sql
```

### 方式3：手动执行SQL

打开MySQL命令行或Navicat等工具，执行：

```sql
USE medical_health;

-- 添加缺失的字段
ALTER TABLE `user` 
ADD COLUMN `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名' AFTER `user_type`,
ADD COLUMN `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号' AFTER `age`,
ADD COLUMN `hospital` varchar(100) DEFAULT NULL COMMENT '所属医院' AFTER `real_name`,
ADD COLUMN `department` varchar(50) DEFAULT NULL COMMENT '科室' AFTER `hospital`,
ADD COLUMN `license_number` varchar(50) DEFAULT NULL COMMENT '执业证号' AFTER `department`;

-- 验证表结构
DESC user;
```

## 验证步骤

执行更新后，运行以下命令验证：

```sql
USE medical_health;
DESC user;
```

**期望输出应包含**：
```
real_name
id_card
hospital
department
license_number
```

## 重启服务

1. **停止后端服务**（Ctrl+C 或关闭运行窗口）

2. **重新启动后端服务**

3. **测试注册功能**

## 如果字段已存在

如果执行时提示字段已存在，说明数据库可能已经更新过，但MyBatis缓存了旧的表结构。

**解决方案**：
1. 重启MySQL服务
2. 重启后端应用
3. 清除MyBatis缓存（如果有）

## 完整操作流程

```
1. 执行数据库更新脚本
   ↓
2. 验证表结构（DESC user）
   ↓
3. 重启后端服务
   ↓
4. 测试注册功能
```

## 预期结果

执行成功后，注册流程应该正常工作：

1. 输入手机号：13948999643
2. 获取验证码：自动填充123456
3. 设置密码：123456
4. 确认密码：123456
5. 勾选协议
6. 点击注册 → 成功！

## 如果仍然失败

请提供：
1. 数据库表结构截图（DESC user 的结果）
2. 后端完整错误日志
3. 执行更新脚本的输出信息
