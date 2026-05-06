# 数据库更新操作指南（解决乱码问题）

## 问题说明

批处理脚本在Windows CMD中执行时出现乱码错误，这是因为编码问题。

## 解决方案（3种方式，任选其一）

### 方式1：使用MySQL命令行（推荐）

1. **打开MySQL命令行**：
   - 按 `Win + R`，输入 `cmd`，回车
   - 输入：`mysql -u root -p123456`
   - 回车进入MySQL

2. **执行更新SQL**：
   ```sql
   USE medical_health;

   ALTER TABLE `user` 
   ADD COLUMN `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名' AFTER `user_type`,
   ADD COLUMN `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号' AFTER `age`,
   ADD COLUMN `hospital` varchar(100) DEFAULT NULL COMMENT '所属医院' AFTER `real_name`,
   ADD COLUMN `department` varchar(50) DEFAULT NULL COMMENT '科室' AFTER `hospital`,
   ADD COLUMN `license_number` varchar(50) DEFAULT NULL COMMENT '执业证号' AFTER `department`;

   DESC user;
   ```

### 方式2：使用Navicat或其他MySQL工具

1. 打开Navicat、MySQL Workbench或其他数据库管理工具
2. 连接到MySQL数据库（用户：root，密码：123456）
3. 选择数据库 `medical_health`
4. 打开查询窗口
5. 复制粘贴以下SQL并执行：

```sql
ALTER TABLE `user` 
ADD COLUMN `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名' AFTER `user_type`,
ADD COLUMN `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号' AFTER `age`,
ADD COLUMN `hospital` varchar(100) DEFAULT NULL COMMENT '所属医院' AFTER `real_name`,
ADD COLUMN `department` varchar(50) DEFAULT NULL COMMENT '科室' AFTER `hospital`,
ADD COLUMN `license_number` varchar(50) DEFAULT NULL COMMENT '执业证号' AFTER `department`;
```

### 方式3：使用PowerShell（避免编码问题）

1. 按 `Win + X`，选择 "Windows PowerShell"
2. 切换到项目目录：
   ```powershell
   cd E:\HMOS6.0\Github\harmony-health-care
   ```
3. 执行SQL文件：
   ```powershell
   Get-Content fix-user-table.sql | mysql -u root -p123456
   ```

## 验证步骤

执行更新后，验证表结构：

```sql
USE medical_health;
DESC user;
```

**期望输出应包含以下字段**：
```
real_name
id_card
hospital
department
license_number
```

## 完整SQL脚本

如果上述方式都不方便，可以直接复制以下完整SQL执行：

```sql
-- 切换数据库
USE medical_health;

-- 检查字段是否存在
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'medical_health' 
  AND TABLE_NAME = 'user'
  AND COLUMN_NAME IN ('real_name', 'id_card', 'hospital', 'department', 'license_number');

-- 如果上述查询返回0行，说明字段不存在，需要添加
-- 执行以下ALTER语句：

ALTER TABLE `user` 
ADD COLUMN `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名' AFTER `user_type`,
ADD COLUMN `id_card` varchar(18) DEFAULT NULL COMMENT '身份证号' AFTER `age`,
ADD COLUMN `hospital` varchar(100) DEFAULT NULL COMMENT '所属医院' AFTER `real_name`,
ADD COLUMN `department` varchar(50) DEFAULT NULL COMMENT '科室' AFTER `hospital`,
ADD COLUMN `license_number` varchar(50) DEFAULT NULL COMMENT '执业证号' AFTER `department`;

-- 再次验证
DESC user;
```

## 执行后操作

1. **验证成功后，重启后端服务**
2. **测试注册功能**

## 如果提示字段已存在

如果执行ALTER TABLE时提示字段已存在，说明：
- 数据库表结构可能已经正确
- 问题可能是MyBatis缓存或连接池缓存

**解决方案**：
1. 重启MySQL服务
2. 重启后端应用
3. 清除浏览器缓存

## 常见错误处理

### 错误1：Access denied

```
ERROR 1045 (28000): Access denied for user 'root'@'localhost'
```

**解决**：密码不正确，请确认MySQL的root密码

### 错误2：Unknown database

```
ERROR 1049 (42000): Unknown database 'medical_health'
```

**解决**：数据库不存在，需要先创建：
```sql
CREATE DATABASE medical_health DEFAULT CHARACTER SET utf8mb4;
```

### 错误3：Duplicate column

```
ERROR 1060 (42S21): Duplicate column name 'real_name'
```

**解决**：字段已存在，无需添加，直接重启服务即可

## 下一步

执行成功后：
1. 重启后端Spring Boot应用
2. 打开前端应用
3. 测试注册功能
4. 应该能够成功注册

---

**推荐使用方式1（MySQL命令行）或方式2（Navicat），最可靠！**
