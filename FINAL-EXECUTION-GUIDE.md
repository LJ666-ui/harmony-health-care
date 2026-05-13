# 家属功能完整实现指南

## ✅ 前后端连接状态

### 后端API已实现
1. **家属信息接口**：`GET /family/info`
   - 返回家属基本信息和关联患者ID

2. **病例查看接口**：`GET /medical/record/my?userId={患者ID}`
   - 返回患者的病例记录

3. **健康记录接口**：`GET /healthRecord/my?userId={患者ID}`
   - 返回患者的健康记录（血压、血糖、心率等）

### 前端页面已实现
1. **FamilyMedicalRecords.ets**：家属查看病例页面
   - 自动获取关联患者ID
   - 调用`/medical/record/my`接口
   - 显示病例列表

2. **FamilyHealthRecords.ets**：家属查看健康记录页面
   - 自动获取关联患者ID
   - 调用`/healthRecord/my`接口
   - 显示血压、血糖、心率等数据

---

## 🚀 完整执行步骤

### 步骤1：备份数据库
```bash
mysqldump -u root -p123456 medical_health > backup_final_$(date +%Y%m%d).sql
```

### 步骤2：修正家属关联
```bash
mysql -u root -p123456

USE medical_health;

# 执行简化版修复脚本
source e:/HMOS6.0/Github/harmony-health-care/fix-family-simple.sql
```

**根据查询结果执行UPDATE**：
```sql
-- 将家属关联到患者21（马建国）
UPDATE family_member SET user_id = 21, update_time = NOW() WHERE id IN (1, 2, 3);

-- 将家属关联到患者22（任桂英）
UPDATE family_member SET user_id = 22, update_time = NOW() WHERE id IN (4, 5);
```

### 步骤3：插入完整测试数据
```bash
source e:/HMOS6.0/Github/harmony-health-care/insert-complete-test-data.sql
```

**取消注释并执行所有INSERT语句**：
- 病例数据（高血压、糖尿病、冠心病等）
- 健康记录（血压、血糖、心率、体重、体温）

### 步骤4：验证数据流通
```bash
source e:/HMOS6.0/Github/harmony-health-care/verify-family-data-flow.sql
```

**预期结果**：
```
家属姓名 | 关系 | 关联患者 | 可查看病例数 | 可查看健康记录数 | 数据完整性
王秀英   | 配偶 | 马建国   | 3           | 10              | ✅ 完整
王明     | 子女 | 马建国   | 3           | 10              | ✅ 完整
```

### 步骤5：重启后端服务
```bash
# 方式1：使用Maven
cd e:/HMOS6.0/Github/harmony-health-care
mvn clean spring-boot:run

# 方式2：使用IDE
# 在IDEA中重启Spring Boot应用

# 方式3：使用JAR包
mvn clean package
java -jar target/medical-0.0.1-SNAPSHOT.jar
```

### 步骤6：测试前端功能

#### 测试家属登录
1. 打开HarmonyOS应用
2. 使用家属账户登录（如果已启用）
   - 用户名：家属手机号
   - 密码：123456（默认）

#### 测试家属查看病例
1. 进入"家属中心"
2. 点击"医疗记录"
3. 查看病例列表
4. 点击病例查看详情

**预期显示**：
```
患者：马建国
诊断：高血压病3级（极高危）
治疗：降压药物治疗...
就诊时间：2026-05-01
```

#### 测试家属查看健康记录
1. 进入"家属中心"
2. 点击"健康记录"
3. 查看血压、血糖、心率等数据

**预期显示**：
```
血压：145/92 mmHg (2026-05-10)
血糖：7.2 mmol/L (2026-05-10)
心率：78 bpm (2026-05-10)
体重：72.5 kg (2026-05-10)
```

---

## 📊 数据流通验证

### 后端API测试

#### 1. 测试家属信息接口
```bash
curl -X GET "http://localhost:8080/family/info" \
  -H "Authorization: Bearer {家属Token}"
```

**预期返回**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "name": "王秀英",
    "relation": "配偶",
    "userId": 21,
    "phone": "13912345001"
  }
}
```

#### 2. 测试病例查看接口
```bash
curl -X GET "http://localhost:8080/medical/record/my?userId=21" \
  -H "Authorization: Bearer {家属Token}"
```

**预期返回**：
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "userId": 21,
      "diagnosis": "高血压病3级（极高危）",
      "treatment": "降压药物治疗...",
      "recordTime": "2026-05-01T10:00:00"
    }
  ]
}
```

#### 3. 测试健康记录接口
```bash
curl -X GET "http://localhost:8080/healthRecord/my?userId=21" \
  -H "Authorization: Bearer {家属Token}"
```

**预期返回**：
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "userId": 21,
      "recordType": "BLOOD_PRESSURE",
      "value": "145/92",
      "unit": "mmHg",
      "recordTime": "2026-05-10T08:00:00"
    }
  ]
}
```

---

## 🔧 常见问题排查

### Q1: 家属登录失败
**原因**：家属账户未启用登录功能
**解决**：
```sql
-- 启用家属登录
UPDATE family_member 
SET login_enabled = 1, 
    username = phone, 
    password = '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.' 
WHERE id IN (1, 2, 3, 4, 5);
```

### Q2: 前端显示"未找到关联患者信息"
**原因**：family_member的user_id关联错误
**解决**：
```sql
-- 检查关联
SELECT fm.id, fm.name, fm.user_id, u.username, u.user_type
FROM family_member fm
LEFT JOIN user u ON fm.user_id = u.id
WHERE fm.is_deleted = 0;

-- 修正关联
UPDATE family_member SET user_id = 21 WHERE id IN (1, 2, 3);
```

### Q3: 前端显示"暂无病例记录"
**原因**：medical_record表无数据
**解决**：
```sql
-- 检查病例数据
SELECT COUNT(*) FROM medical_record WHERE user_id = 21 AND is_deleted = 0;

-- 如果为0，执行insert-complete-test-data.sql插入数据
```

### Q4: 前端显示"暂无健康记录"
**原因**：health_record表无数据
**解决**：
```sql
-- 检查健康记录
SELECT COUNT(*) FROM health_record WHERE user_id = 21 AND is_deleted = 0;

-- 如果为0，执行insert-complete-test-data.sql插入数据
```

### Q5: API返回401 Unauthorized
**原因**：Token无效或过期
**解决**：
1. 重新登录获取新Token
2. 检查Token是否正确传递
3. 检查后端JWT配置

---

## 📝 数据库表结构说明

### family_member表
```sql
id              - 家属ID
user_id         - 关联患者ID（重要！）
name            - 家属姓名
relation        - 与患者关系
phone           - 手机号
username        - 登录用户名
password        - 登录密码
login_enabled   - 是否允许登录
```

### medical_record表
```sql
id              - 病例ID
user_id         - 患者ID
hospital_id     - 医院ID
doctor_id       - 医生ID
diagnosis       - 诊断
treatment       - 治疗方案
record_time     - 就诊时间
```

### health_record表
```sql
id              - 记录ID
user_id         - 患者ID
record_type     - 记录类型（BLOOD_PRESSURE, BLOOD_SUGAR等）
value           - 数值
unit            - 单位
record_time     - 记录时间
```

---

## ✅ 完成检查清单

- [ ] 已备份数据库
- [ ] 已修正family_member关联
- [ ] 已插入病例数据
- [ ] 已插入健康记录数据
- [ ] 已验证数据流通
- [ ] 已重启后端服务
- [ ] 已测试家属登录
- [ ] 已测试病例查看
- [ ] 已测试健康记录查看
- [ ] 所有功能正常

---

## 📞 技术支持

如果遇到问题，请提供：
1. 数据库查询结果
2. 后端日志（特别是错误日志）
3. 前端控制台日志
4. API请求和响应数据

---

**脚本文件位置**：
- `fix-family-simple.sql` - 修正家属关联
- `insert-complete-test-data.sql` - 插入完整测试数据
- `verify-family-data-flow.sql` - 验证数据流通

**生成时间**：2026-05-11
**作者**：CodeArts Agent
