# 家属功能修复快速指南

## ⚠️ 问题说明

执行SQL脚本时出现错误：`Unknown column 'd.name' in 'field list'`

**原因**：doctor表的字段名是`real_name`，不是`name`

**影响**：原脚本无法正常执行，需要使用修复后的简化版脚本

---

## ✅ 已修复的脚本

我已经创建了两个简化版脚本，避免了字段名错误：

### 1. fix-family-simple.sql
**位置**：`e:\HMOS6.0\Github\harmony-health-care\fix-family-simple.sql`

**功能**：
- 查看当前数据关联
- 提供修正SQL语句
- 验证修正结果

### 2. insert-medical-records-simple.sql
**位置**：`e:\HMOS6.0\Github\harmony-health-care\insert-medical-records-simple.sql`

**功能**：
- 查看现有患者和医生
- 插入测试病例数据
- 验证家属能否查看

---

## 🚀 快速修复步骤

### 步骤1：备份数据库
```bash
mysqldump -u root -p123456 medical_health > backup_$(date +%Y%m%d).sql
```

### 步骤2：执行诊断脚本
```bash
mysql -u root -p123456

USE medical_health;

source e:/HMOS6.0/Github/harmony-health-care/fix-family-simple.sql
```

**预期输出**：
```
用户类型 | 数量
0       | 80   (患者)
1       | 20   (医生)

家属ID | 家属姓名 | 关联用户ID | 关联用户类型
1      | 王秀英   | 1          | 1 (医生) ← 错误！
2      | 王明     | 1          | 1 (医生) ← 错误！
```

### 步骤3：修正数据关联
根据查询结果，执行UPDATE语句：

```sql
-- 将家属关联到患者21（马建国）
UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将家属关联到患者22（任桂英）
UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);

-- 验证修正结果
SELECT 
    fm.id AS 家属ID,
    fm.name AS 家属姓名,
    fm.user_id AS 关联用户ID,
    u.username AS 关联用户名,
    u.user_type AS 关联用户类型
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;
```

**预期结果**：
```
家属ID | 家属姓名 | 关联用户ID | 关联用户类型
1      | 王秀英   | 21         | 0 (患者) ← 正确！
2      | 王明     | 21         | 0 (患者) ← 正确！
```

### 步骤4：插入测试病例数据
```bash
source e:/HMOS6.0/Github/harmony-health-care/insert-medical-records-simple.sql
```

取消注释并执行INSERT语句：

```sql
-- 为患者21添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(21, 1, 1, '高血压病', '降压药物治疗，定期监测血压', '2026-05-01 10:00:00', 0, 0, NOW(), NOW()),
(21, 1, 1, '2型糖尿病', '口服降糖药，饮食控制', '2026-04-15 14:30:00', 0, 0, NOW(), NOW()),
(21, 1, 1, '冠心病', '抗血小板治疗，调脂治疗', '2026-03-20 09:00:00', 0, 0, NOW(), NOW());

-- 为患者22添加病例
INSERT INTO medical_record (
    user_id, hospital_id, doctor_id, 
    diagnosis, treatment, record_time, 
    is_desensitized, is_deleted, create_time, update_time
) VALUES 
(22, 1, 1, '慢性胃炎', '抑酸治疗，胃黏膜保护', '2026-04-28 11:00:00', 0, 0, NOW(), NOW()),
(22, 1, 1, '颈椎病', '物理治疗，避免长时间低头', '2026-04-10 15:00:00', 0, 0, NOW(), NOW());
```

### 步骤5：验证家属能否查看病例
```sql
SELECT 
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    u.username AS 关联患者,
    COUNT(mr.id) AS 可查看病例数,
    CASE 
        WHEN COUNT(mr.id) > 0 THEN '✅ 修复成功'
        ELSE '❌ 仍需修复'
    END AS 验证结果
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
LEFT JOIN medical_record mr ON u.id = mr.user_id AND mr.is_deleted = 0
WHERE fm.is_deleted = 0
GROUP BY fm.id, fm.name, fm.relation, u.username;
```

**预期结果**：
```
家属姓名 | 关系   | 关联患者 | 可查看病例数 | 验证结果
王秀英   | 配偶   | 马建国   | 3           | ✅ 修复成功
王明     | 子女   | 马建国   | 3           | ✅ 修复成功
```

### 步骤6：重启服务并测试
```bash
# 重启后端服务
# 如果使用IDE，重启Spring Boot应用
# 如果使用命令行
cd e:/HMOS6.0/Github/harmony-health-care
mvn spring-boot:run
```

**测试步骤**：
1. 使用家属账户登录
2. 进入"家属中心" -> "医疗记录"
3. 确认能看到病例信息

---

## 📊 问题根源总结

### 核心问题
1. **家属关联的是医生（user_id=1, user_type=1）**
2. **医生没有病例数据，所以家属看不到病例**
3. **doctor表字段名是real_name，不是name**

### 数据证据
```
user表：
- ID 1-20: user_type=1 (医生)
- ID 21-100: user_type=0 (患者)

family_member表：
- family_id=1,2,3 关联 user_id=1 (医生) ← 错误
- 应该关联 user_id=21 (患者) ← 正确

doctor表：
- 字段名：real_name (不是name)
```

### 解决方案
1. **修正关联**：将家属关联到患者（user_type=0）
2. **添加数据**：为患者插入病例数据
3. **使用简化脚本**：避免字段名错误

---

## ✅ 修复完成检查清单

- [ ] 已备份数据库
- [ ] 已执行fix-family-simple.sql
- [ ] 已修正family_member关联
- [ ] 已执行insert-medical-records-simple.sql
- [ ] 已插入测试病例数据
- [ ] 已验证家属能查看病例
- [ ] 已重启后端服务
- [ ] 已测试前端功能

---

## 📞 如果还有问题

请提供以下信息：
1. 执行的SQL语句和错误信息
2. 数据库查询结果截图
3. 后端日志（特别是错误日志）
4. 前端控制台日志

---

**修复脚本位置**：
- `fix-family-simple.sql` - 数据关联修复（简化版）
- `insert-medical-records-simple.sql` - 病例数据插入（简化版）

**生成时间**：2026-05-11
**作者**：CodeArts Agent
