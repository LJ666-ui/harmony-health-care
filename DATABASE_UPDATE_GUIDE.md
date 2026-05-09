# 数据库更新执行指南

## 方法一：使用MySQL命令行（推荐）

### 步骤1：打开MySQL命令行
```bash
mysql -u root -p
```
输入密码后进入MySQL命令行界面。

### 步骤2：执行更新脚本
```sql
source e:/HMOS6.0/Github/harmony-health-care/update-database-optimization.sql
```

### 步骤3：验证更新
```sql
source e:/HMOS6.0/Github/harmony-health-care/verify-database-update.sql
```

### 步骤4：退出MySQL
```sql
exit
```

---

## 方法二：使用MySQL Workbench

1. 打开MySQL Workbench
2. 连接到数据库
3. 打开SQL脚本：`File` → `Open SQL Script`
4. 选择 `update-database-optimization.sql`
5. 点击 `Execute`（闪电图标）执行脚本
6. 打开 `verify-database-update.sql` 验证更新

---

## 方法三：使用Navicat或其他数据库工具

1. 打开Navicat
2. 连接到MySQL数据库
3. 选择 `medical_health` 数据库
4. 右键 → `Execute SQL File`
5. 选择 `update-database-optimization.sql`
6. 执行完成后，执行 `verify-database-update.sql` 验证

---

## 方法四：使用Windows命令行（需要配置MySQL环境变量）

### 更新数据库
```cmd
mysql -u root -p medical_health < update-database-optimization.sql
```

### 验证更新
```cmd
mysql -u root -p medical_health < verify-database-update.sql
```

---

## 常见问题

### 问题1：找不到mysql命令
**解决方案**：
1. 将MySQL的bin目录添加到系统环境变量PATH
2. 或者使用完整路径：
   ```cmd
   "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p
   ```

### 问题2：无法连接到MySQL
**解决方案**：
1. 检查MySQL服务是否启动
2. 检查用户名和密码是否正确
3. 检查端口是否正确（默认3306）

### 问题3：脚本执行失败
**解决方案**：
1. 检查SQL文件路径是否正确
2. 检查数据库是否存在
3. 检查用户是否有足够权限

---

## 更新内容

- 新建表：9张
- 新增索引：12个
- 测试数据：已插入

## 验证标准

执行验证脚本后，应该看到：
- 新建表总数：9
- 新增索引总数：12
- 测试数据已插入

---

## 下一步

数据库更新成功后，开始后端接口开发：
1. 医生排班管理接口（P1）
2. 处方模板管理接口（P1）
3. 病历模板管理接口（P1）
4. 会诊管理接口（P1）
5. 数据访问审批接口（P0）
6. 敏感操作确认接口（P0）
