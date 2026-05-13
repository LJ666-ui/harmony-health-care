# 🚨 家属端紧急修复指南（最终版）

## 问题现象
1. ❌ 家属端页面显示"暂无用药记录"、"暂无病历记录"
2. ❌ 后端API返回 `"userId": 1` 而不是 `21`
3. ❌ SQL执行报错：`Unknown column 'hospital_name'`

---

## 🔍 根本原因分析

### 原因1：数据库关联错误 ⭐⭐⭐
**现状**：
```json
// /family/info 返回（错误）
{"code":200,"msg":"成功","data":{"name":"王秀英","userId":1,...}}
```

**期望**：
```json
// 应该返回（正确）
{"code":200,"msg":"成功","data":{"name":"王秀英","userId":21,...}}
```

**数据库当前状态**：
- `family_member.user_id = 1` ❌ （错误，这是其他用户的ID）
- 应该改为：`family_member.user_id = 21` ✅ （患者马建军的ID）

### 原因2：SQL字段名错误 ⭐⭐
**medical_record表实际结构**：
```sql
-- ✅ 正确的字段
userId, hospitalId, doctorId, diagnosis, treatment, recordTime

-- ❌ 错误的字段（之前的SQL使用了这些）
hospital_name, department, doctor_name, treatment_plan, medication_advice
```

### 原因3：缺少测试数据 ⭐
患者ID=21的账号可能没有：
- 病历记录（medical_record表）
- 处方记录（prescription表）  
- 用药提醒（medication_reminder表）

---

## 🛠️ 立即修复步骤

### ✅ 步骤1：执行修正后的SQL脚本

我已创建符合实际表结构的SQL文件：**[fix-family-corrected.sql](fix-family-corrected.sql)**

#### 方法A：在MySQL命令行中执行
```bash
mysql -u root -p medical_health < fix-family-corrected.sql
```

#### 方法B：在Navicat/Workbench中执行
1. 打开 `fix-family-corrected.sql` 文件
2. 连接到 `medical_health` 数据库
3. 执行整个脚本

#### 方法C：手动执行核心语句
如果上面方法都不行，直接复制以下SQL到MySQL执行：

```sql
USE medical_health;

-- ⭐ 核心修复1：将家属关联到患者21
UPDATE family_member 
SET user_id = 21, update_time = NOW() 
WHERE is_deleted = 0;

-- 验证修改结果
SELECT id, name, user_id FROM family_member WHERE is_deleted = 0;
-- 应该看到 user_id = 21

-- ⭐ 核心修复2：添加病历数据（使用正确的字段名）
INSERT IGNORE INTO medical_record (
  userId, hospitalId, doctorId, diagnosis, treatment, 
  recordTime, isDesensitized, is_deleted, create_time, update_time
) VALUES 
(21, 1, 1, '高血压', '降压治疗', NOW(), 0, 0, NOW(), NOW()),
(21, 1, 2, '2型糖尿病', '控制血糖', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 0, NOW(), NOW());

-- 验证病历
SELECT COUNT(*) FROM medical_record WHERE userId = 21 AND is_deleted = 0;
-- 应该返回 2

-- ⭐ 核心修复3：添加处方数据
INSERT IGNORE INTO prescription (
  patient_id, patient_name, doctor_id, doctor_name, 
  diagnosis, medications, notes, status, created_at, valid_until
) VALUES 
(
  21, '马建军', 1, '张医生', '高血压',
  '[{"medicineName":"硝苯地平控释片","specification":"30mg","dosage":"1片","frequency":"每日1次"}]',
  '按时服药', 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)
),
(
  21, '马建军', 2, '李医生', '2型糖尿病',
  '[{"medicineName":"盐酸二甲双胍片","specification":"500mg","dosage":"1片","frequency":"每日3次"}]',
  '餐后服用', 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY)
);

-- 验证处方
SELECT COUNT(*) FROM prescription WHERE patient_id = 21;
-- 应该返回 2

-- ⭐ 核心修复4：添加用药提醒（用于"用药管理"页面）
INSERT IGNORE INTO medication_reminder (
  patient_id, medication_name, dosage, frequency, 
  time_of_day, start_date, end_date, status, notes,
  create_time, update_time
) VALUES
(21, '硝苯地平控释片', '30mg', '每日1次', '08:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'PENDING', '早餐前服用', NOW(), NOW()),
(21, '盐酸二甲双胍片', '500mg', '每日3次', '08:00,12:00,18:00', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 60 DAY), 'PENDING', '餐后服用', NOW(), NOW());

-- 验证用药提醒
SELECT COUNT(*) FROM medication_reminder WHERE patient_id = 21;
-- 应该返回 2
```

---

### ✅ 步骤2：重启后端服务

**重要**：必须重启后端，否则可能有缓存！

```bash
# 在运行Spring Boot的终端按 Ctrl+C 停止
# 然后重新启动
mvn spring-boot:run

# 或者在IDE中：
# 1. 停止当前运行的Application
# 2. 重新运行main()方法
```

---

### ✅ 步骤3：验证API接口

打开浏览器或Postman，依次测试以下接口：

#### 3.1 测试家属信息（最重要！）
```
GET http://localhost:8080/family/info
```
**期望返回**：
```json
{
  "code": 200,
  "msg": "成功",
  "data": {
    "id": 6,
    "name": "王秀英",
    "userId": 21,  // ← 必须是21！
    "relation": "配偶",
    ...
  }
}
```
❌ 如果还是 `userId: 1`，说明SQL没执行成功！

#### 3.2 测试患者信息
```
GET http://localhost:8080/user/info?id=21
```
应该返回患者马建军的信息。

#### 3.3 测试病历数据
```
GET http://localhost:8080/medical/record/my?userId=21
```
应该返回2条病历记录。

#### 3.4 测试处方数据
```
GET http://localhost:8080/medical/prescriptions/patient/21
```
应该返回2条处方记录。

#### 3.5 测试用药提醒
```
GET http://localhost:8080/family/medications
```
需要携带家属Token，应该返回2条用药提醒。

---

### ✅ 步骤4：刷新前端测试

在鸿蒙模拟器/真机上：

1. **完全关闭**家属端应用
   - 不是最小化！要从最近任务列表中滑走关闭
   
2. **清除应用数据**（可选但推荐）
   - 设置 → 应用 → 健康护理 → 存储 → 清除数据
   
3. **重新打开应用**
   
4. **重新登录家属账号**
   - 手机号：13812345021（或你设置的手机号）
   - 密码：123456（或你设置的密码）

5. **验证各页面**

---

## 📋 验证清单

执行完以上步骤后，请逐项确认：

### API层面验证
- [ ] `/family/info` 返回 `"userId": 21` ✅
- [ ] `/user/info?id=21` 返回患者信息 ✅  
- [ ] `/medical/record/my?userId=21` 返回≥1条记录 ✅
- [ ] `/medical/prescriptions/patient/21` 返回≥1条记录 ✅
- [ ] `/family/medications` 返回≥1条记录 ✅

### 前端页面验证
- [ ] **家属中心页**：显示"王秀英 (配偶)"和"马建军 (ID: 21)" ✅
- [ ] **医疗记录页**：显示高血压、糖尿病等病历 ✅
- [ ] **处方药品页**：显示硝苯地平、二甲双胍等处方 ✅
- [ ] **用药管理页**：显示药品列表和服药时间 ✅
- [ ] **所有页面可以正常滚动** ✅

---

## 🔧 故障排查

### Q1: SQL执行报错怎么办？
**错误信息**: `Unknown column 'xxx' in 'field list'`

**解决**:
1. 先查看表的实际结构：
   ```sql
   DESCRIBE medical_record;
   DESCRIBE prescription;
   DESCRIBE medication_reminder;
   ```
2. 使用我提供的 **[fix-family-corrected.sql](fix-family-corrected.sql)** 文件（已修正字段名）

### Q2: 执行SQL后API还是返回userId=1？
**可能原因**:
- SQL没真正执行（只复制了注释没复制语句）
- 后端有缓存
- 连接了错误的数据库

**解决**:
```bash
# 1. 确认SQL执行了
mysql -u root -p -e "SELECT * FROM medical_health.family_member;"

# 2. 重启后端（清除缓存）
# Ctrl+C 停止，然后 mvn spring-boot:run

# 3. 再次测试API
curl http://localhost:8080/family/info
```

### Q3: 前端显示"请求失败"或网络错误？
**可能原因**:
- 后端服务未启动或端口不对
- Token无效或过期
- CORS跨域问题

**解决**:
1. 确认后端运行在8080端口：
   ```bash
   curl http://localhost:8080/
   ```
   
2. 检查家属Token是否保存：
   - 登录后查看控制台日志 `[FamilyLogin] Token已保存到AppStorage`
   
3. 完全退出应用重进（清除缓存）

### Q4: 页面可以滚动但还是空白？
**检查顺序**:
1. 浏览器访问 `http://localhost:8080/family/info` 看是否返回正确数据
2. 如果API正确，问题在前端渲染
3. 查看鸿蒙DevEco Studio的控制台日志

---

## 📊 技术细节参考

### 数据流图解
```
┌─────────────────────────────────────────────────────┐
│                     家属登录                         │
│  POST /family/login {phone, password}               │
│         ↓                                           │
│  返回 {token, familyInfo: {userId: 21}}             │
│         ↓                                           │
│  保存token到AppStorage('familyToken')               │
│  保存info到AppStorage('familyInfo')                 │
│         ↓                                           │
│  跳转到FamilyHome页面                               │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                   FamilyHome页面                    │
│  aboutToAppear()                                    │
│    ↓                                                │
│  GET /family/info (skipAuth: true)                  │
│    ↓                                                │
│  返回 familyInfo {userId: 21}                       │
│    ↓                                                │
│  GET /user/info?id=21 (获取患者信息)                │
│    ↓                                                │
│  显示"马建军 (ID: 21)"                              │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              子页面（病历/处方/用药）                │
│  从AppStorage获取familyInfo.userId = 21             │
│    ↓                                                │
│  GET /medical/record/my?userId=21                   │
│  GET /medical/prescriptions/patient/21              │
│  GET /family/medications                            │
│    ↓                                                │
│  渲染数据列表                                       │
└─────────────────────────────────────────────────────┘
```

### 关键代码位置
| 文件 | 作用 | 状态 |
|------|------|------|
| [FamilyHome.ets](entry/src/main/ets/pages/FamilyHome.ets) | 家属主页面 | ✅ 已添加Scroll |
| [FamilyLogin.ets](entry/src/main/ets/pages/FamilyLogin.ets) | 登录逻辑 | ✅ 正常 |
| [HttpUtil.ets](entry/src/main/ets/common/utils/HttpUtil.ets) | HTTP请求工具 | ✅ 正常 |
| [FamilyAuthController.java](src/main/java/com/example/medical/controller/FamilyAuthController.java) | 后端API | ✅ 正常 |
| [MedicalRecord.java](src/main/java/com/example/medical/entity/MedicalRecord.java) | 病历实体 | ✅ 参考用 |

---

## 🎯 最终目标

修复完成后，家属端应该：

✅ **家属中心页面**
- 可以滚动查看所有内容
- 显示"王秀英 (配偶)"
- 显示关联患者"马建军 (ID: 21)"

✅ **医疗记录页面**
- 显示2条就诊记录
- 高血压（北京协和医院 心内科 张医生）
- 2型糖尿病（北京协和医院 内分泌科 李医生）

✅ **处方药品页面**
- 显示2张处方
- 硝苯地平控释片（降压药）
- 盐酸二甲双胍片（降糖药）

✅ **用药管理页面**
- 显示2条用药提醒
- 08:00 服用硝苯地平
- 08:00/12:00/18:00 服用二甲双胍

---

## 📞 如果还有问题

请提供以下信息：
1. 执行SQL后的输出截图
2. 浏览器访问 `http://localhost:8080/family/info` 的返回结果
3. 鸿蒙控制台的错误日志
4. 具体是哪个页面有问题

我会继续帮你排查！💪

---

**修复日期**: 2026-05-11  
**版本**: v3.0 Final（已修正所有已知问题）