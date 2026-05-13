# 家属功能数据修正完整指南

## ⚠️ 问题说明

### 问题1：health_record表字段错误
**错误信息**：`1054 - Unknown column 'hr.record_type' in 'field list'`

**原因**：health_record表的字段不是`record_type`和`value`，而是：
- `blood_pressure` - 血压
- `blood_sugar` - 血糖
- `heart_rate` - 心率
- `weight` - 体重
- `height` - 身高
- `step_count` - 步数
- `sleep_duration` - 睡眠时长

### 问题2：家属关联的是医生，不是患者
**原因**：family_member表的user_id关联的是医生（user_type=1），应该关联患者（user_type=0）

---

## ✅ 已修正的脚本

### 1. fix-family-to-patient.sql
**功能**：将家属关联从医生改为患者
**位置**：`e:\HMOS6.0\Github\harmony-health-care\fix-family-to-patient.sql`

### 2. insert-health-records-correct.sql
**功能**：插入正确的健康记录数据
**位置**：`e:\HMOS6.0\Github\harmony-health-care\insert-health-records-correct.sql`

### 3. verify-all-data-correct.sql
**功能**：验证所有数据流通
**位置**：`e:\HMOS6.0\Github\harmony-health-care\verify-all-data-correct.sql`

---

## 🚀 完整执行步骤

### 步骤1：备份数据库
```bash
mysqldump -u root -p123456 medical_health > backup_correct_$(date +%Y%m%d).sql
```

### 步骤2：修正家属关联
```bash
mysql -u root -p123456

USE medical_health;

# 执行诊断脚本
source e:/HMOS6.0/Github/harmony-health-care/fix-family-to-patient.sql
```

**根据查询结果执行UPDATE**：
```sql
-- 查看当前关联状态
-- 预期显示：关联用户类型 = 1（医生）← 错误

-- 将家属关联到患者21（马建国，64岁）
UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将家属关联到患者22（任桂英，36岁）
UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- 验证修正结果
SELECT 
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 关联用户类型,
    CASE u.user_type 
        WHEN 0 THEN '✅ 正确：关联患者'
        ELSE '❌ 仍然错误'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;
```

**预期结果**：
```
家属ID | 家属姓名 | 关联用户ID | 关联用户名 | 关联用户类型 | 验证结果
1      | 王秀英   | 21         | 马建国     | 0           | ✅ 正确：关联患者
2      | 王明     | 21         | 马建国     | 0           | ✅ 正确：关联患者
```

### 步骤3：插入病例数据
```sql
-- 为患者21添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(21, 1, 1, '高血压病3级（极高危）', 
 '降压药物治疗：氨氯地平5mg qd + 缬沙坦80mg qd\n低盐低脂饮食\n定期监测血压', 
 '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
 
(21, 1, 1, '2型糖尿病', 
 '口服降糖药：二甲双胍0.5g tid\n饮食控制\n定期监测血糖', 
 '2026-04-15 14:30:00', 0, 0, NOW(), NOW()),
 
(21, 1, 1, '冠心病', 
 '抗血小板治疗：阿司匹林100mg qd\n调脂治疗：阿托伐他汀20mg qn', 
 '2026-03-20 09:00:00', 0, 0, NOW(), NOW());

-- 为患者22添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(22, 1, 1, '慢性浅表性胃炎', 
 '抑酸治疗：奥美拉唑20mg qd\n胃黏膜保护：铝碳酸镁1g tid', 
 '2026-04-28 11:00:00', 0, 0, NOW(), NOW()),
 
(22, 1, 1, '颈椎病', 
 '物理治疗：颈椎牵引\n避免长时间低头', 
 '2026-04-10 15:00:00', 0, 0, NOW(), NOW());
```

### 步骤4：插入健康记录数据
```bash
source e:/HMOS6.0/Github/harmony-health-care/insert-health-records-correct.sql
```

**取消注释并执行INSERT语句**：
```sql
-- 为患者21（马建国）添加健康记录
INSERT INTO health_record (
    user_id, 
    blood_pressure, 
    blood_sugar, 
    heart_rate, 
    weight, 
    height,
    step_count,
    sleep_duration,
    record_time, 
    is_deleted, 
    create_time, 
    update_time
) VALUES 
-- 2026-05-10的记录
(21, '145/92', 7.2, 78, 72.5, 170, 8500, 7.5, '2026-05-10 08:00:00', 0, NOW(), NOW()),

-- 2026-05-09的记录
(21, '138/85', 6.8, 82, 72.8, 170, 9200, 7.0, '2026-05-09 08:00:00', 0, NOW(), NOW()),

-- 2026-05-08的记录
(21, '142/88', 7.5, 76, 72.6, 170, 7800, 8.0, '2026-05-08 08:00:00', 0, NOW(), NOW());

-- 为患者22（任桂英）添加健康记录
INSERT INTO health_record (
    user_id, 
    blood_pressure, 
    blood_sugar, 
    heart_rate, 
    weight, 
    height,
    step_count,
    sleep_duration,
    record_time, 
    is_deleted, 
    create_time, 
    update_time
) VALUES 
-- 2026-05-10的记录
(22, '118/76', 5.6, 72, 58.5, 165, 10000, 8.0, '2026-05-10 08:00:00', 0, NOW(), NOW()),

-- 2026-05-09的记录
(22, '120/78', 5.8, 70, 58.3, 165, 9500, 7.5, '2026-05-09 08:00:00', 0, NOW(), NOW());
```

### 步骤5：验证所有数据
```bash
source e:/HMOS6.0/Github/harmony-health-care/verify-all-data-correct.sql
```

**预期结果**：
```
家属姓名 | 关系 | 关联患者 | 可查看病例数 | 可查看健康记录数 | 数据完整性
王秀英   | 配偶 | 马建国   | 3           | 3               | ✅ 完整
王明     | 子女 | 马建国   | 3           | 3               | ✅ 完整
```

### 步骤6：重启后端服务
```bash
cd e:/HMOS6.0/Github/harmony-health-care
mvn clean spring-boot:run
```

### 步骤7：测试前端功能
1. 家属登录
2. 查看病例记录
3. 查看健康记录（血压、血糖、心率等）

---

## 📊 health_record表字段说明

| 字段名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| id | Long | 记录ID | 1 |
| user_id | Long | 患者ID | 21 |
| blood_pressure | String | 血压 | '145/92' |
| blood_sugar | BigDecimal | 血糖 | 7.2 |
| heart_rate | Integer | 心率 | 78 |
| weight | BigDecimal | 体重 | 72.5 |
| height | BigDecimal | 身高 | 170 |
| step_count | Integer | 步数 | 8500 |
| sleep_duration | BigDecimal | 睡眠时长(小时) | 7.5 |
| record_time | Date | 记录时间 | '2026-05-10 08:00:00' |

---

## ✅ 完成检查清单

- [ ] 已备份数据库
- [ ] 已修正family_member关联（从医生改为患者）
- [ ] 已插入病例数据
- [ ] 已插入健康记录数据
- [ ] 已验证数据流通
- [ ] 已重启后端服务
- [ ] 已测试家属登录
- [ ] 已测试病例查看
- [ ] 已测试健康记录查看
- [ ] 所有功能正常

---

## 📞 如果还有问题

请提供：
1. 执行的SQL语句和错误信息
2. 数据库查询结果截图
3. 后端日志
4. 前端控制台日志

---

**脚本文件位置**：
- `fix-family-to-patient.sql` - 修正家属关联
- `insert-health-records-correct.sql` - 插入健康记录
- `verify-all-data-correct.sql` - 验证所有数据

**生成时间**：2026-05-11
**作者**：CodeArts Agent
