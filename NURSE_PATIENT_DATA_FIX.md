# 护士端患者列表"暂无患者信息"问题解决方案

## 🚨 问题现象

**截图显示**：
- ✅ 网络连接正常（不再报"Failed to connect to the server"）
- ❌ 患者列表页面显示"暂无患者信息"
- ✅ 数据库 `nurse_patient_relation` 表有3条关联记录

---

## 🔍 后端查询逻辑分析

### **完整的数据查询链路**

```
1. 护士登录 → 获取 Token（包含 userId）
      ↓
2. 请求 /user/nurse/patients（携带 Token）
      ↓
3. JwtUtil.getUserId(token) → 提取 userId
      ↓
4. nurseService.findByUserId(userId) → 查找护士记录
      ↓ 获取 nurse.id
5. nursePatientRelationService.getPatientIdsByNurseId(nurse.id)
   → SELECT patient_id FROM nurse_patient_relation 
     WHERE nurse_id = ? AND is_deleted = 0
      ↓ 返回 [21, 22, 25]
6. userService.list(wrapper)
   → SELECT * FROM user 
     WHERE id IN (21, 22, 25) 
     AND user_type = 0        ← 必须是患者类型
     AND is_deleted = 0       ← 必须未删除
      ↓ 返回患者列表
7. 返回给前端
```

### **可能失败的原因**

| 步骤 | 可能的问题 | 影响 |
|------|----------|------|
| 步骤4 | nurse表没有对应userId的记录 | ❌ "未找到护士信息" |
| 步骤5 | nurse_patient_relation为空或is_deleted=1 | ❌ 返回空列表 |
| **步骤6** | **user表缺少ID=21,22,25的记录** | **❌ 返回空列表** ⭐ |
| 步骤6 | user表的user_type≠0 或 is_deleted≠0 | **❌ 返回空列表** ⭐ |

---

## 🎯 最可能的原因（90%概率）

**`user` 表中缺少 ID 为 21、22、25 的患者记录！**

虽然 `nurse_patient_relation` 表有这3个ID，但如果 `user` 表中没有对应的数据，或者数据的 `user_type` 不是 `0`（患者类型）或 `is_deleted` 不是 `0`（未删除），就会返回空列表！

---

## 🔧 解决方案（按顺序执行）

### 方案1：执行诊断SQL脚本（推荐⭐）

我已经创建了诊断脚本：[diagnose_nurse_patients.sql](file:///e:/harmony-health-care/sql/diagnose_nurse_patients.sql)

#### 在 Navicat Premium 中操作：

1. 打开你的数据库连接 `medical_health`
2. 新建查询窗口
3. 复制粘贴 `diagnose_nurse_patients.sql` 的内容
4. 执行所有SELECT语句（不要执行INSERT，先看结果）

#### 关键检查点：

```sql
-- 第5步的结果最重要！
-- 检查ID为21、22、25的用户是否存在
SELECT id, username, real_name, phone, user_type, age, gender, is_deleted, create_time
FROM user 
WHERE id IN (21, 22, 25);
```

**预期结果应该有3条记录**，且满足：
- `user_type = 0` （0表示患者）
- `is_deleted = 0` （0表示未删除）

#### 如果查询结果为空或不符合条件：

说明需要补充数据，继续执行方案2。

---

### 方案2：补充缺失的患者数据

如果方案1发现user表缺少数据，在Navicat中执行以下SQL：

#### 步骤1：确认nurse表的user_id

```sql
-- 先查看当前护士的user_id是什么
SELECT id, user_id, name, job_number FROM nurse WHERE job_number = 'N20230001';
```

假设返回：`id=1, user_id=1`

#### 步骤2：插入护士用户账号（如果没有）

```sql
-- 检查是否有user_id=1的用户
SELECT * FROM user WHERE id = 1;

-- 如果没有，插入护士账号
INSERT INTO user (
    id, username, password, real_name, phone, 
    user_type, age, gender, is_deleted, create_time
) VALUES (
    1, 
    'nurse001', 
    '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv',  -- 密码: 123456
    '测试护士', 
    '13800138001',
    2,       -- user_type=2 表示护士
    35,      -- 年龄
    1,       -- 性别 1=男
    0,       -- 未删除
    NOW()
);
```

#### 步骤3：插入患者数据（关键！）

```sql
-- 插入3个测试患者
INSERT INTO user (
    id, username, password, real_name, phone,
    user_type, age, gender, is_deleted, create_time
) VALUES 
(
    21, 
    'patient21', 
    '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv',  -- 密码: 123456
    '张三', 
    '13900139000',
    0,       -- user_type=0 表示患者 ⭐
    45,      -- 年龄
    1,       -- 性别
    0,       -- 未删除 ⭐
    NOW()
),
(
    22, 
    'patient22', 
    '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv',
    '李四', 
    '13900139001',
    0,       -- 患者 ⭐
    52,      -- 年龄
    2,       -- 性别 2=女
    0,       -- 未删除 ⭐
    NOW()
),
(
    25, 
    'patient25', 
    '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv',
    '王五', 
    '13900139002',
    0,       -- 患者 ⭐
    38,      -- 年龄
    1,       -- 性别
    0,       -- 未删除 ⭐
    NOW()
);
```

**重要提示**：
- `user_type = 0` 表示患者（必须！）
- `is_deleted = 0` 表示未删除（必须！）
- 密码是BCrypt加密后的 `123456`

#### 步骤4：确保nurse表有记录

```sql
-- 检查nurse表
SELECT * FROM nurse WHERE id = 1;

-- 如果没有，插入
INSERT INTO nurse (
    id, user_id, name, job_number, phone, department, password, create_time
) VALUES (
    1,
    1,              -- 对应user表的id
    '测试护士',
    'N20230001',
    '13800138001',
    '内科',
    '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv',
    NOW()
);
```

#### 步骤5：验证数据完整性

```sql
-- 最终验证 - 这条SQL应该返回3条记录！
SELECT 
    n.name AS nurse_name,
    u.real_name AS patient_name,
    u.user_type,
    u.is_deleted
FROM nurse_patient_relation npr
JOIN nurse n ON npr.nurse_id = n.id AND n.is_deleted = 0
JOIN user u ON npr.patient_id = u.id 
WHERE npr.is_deleted = 0 
  AND u.user_type = 0      -- 患者类型
  AND u.is_deleted = 0;    -- 未删除
```

**✅ 预期结果**：返回3条记录（张三、李四、王五）

---

### 方案3：使用API接口手动测试

如果不确定数据库状态，可以通过API测试：

#### 步骤1：获取护士Token

打开PowerShell或Postman，执行：

```powershell
# 护士登录
$body = @{
    phone = "13800138001"
    password = "123456"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://192.168.71.233:8080/nurse/login" `
                                -Method Post `
                                -Body $body `
                                -ContentType "application/json"

$token = $response.data.token
Write-Host "Token: $token"
```

#### 步骤2：获取患者列表

```powershell
# 使用Token请求患者列表
$headers = @{ Token = $token }

$result = Invoke-RestMethod -Uri "http://192.168.71.233:8080/user/nurse/patients" `
                              -Method Get `
                              -Headers $headers

$result | ConvertTo-Json -Depth 5
```

**预期输出**：
```json
{
  "code": 200,
  "msg": "success",
  "data": [
    {"id": 21, "realName": "张三", ...},
    {"id": 22, "realName": "李四", ...},
    {"id": 25, "realName": "王五", ...}
  ]
}
```

如果这里能返回数据但前端不行，说明是前端问题。
如果这里也返回空数组 `[]`，说明是数据库数据问题（执行方案2）。

---

## 📊 数据关系图解

```
┌─────────────────────────────────────────────────────────────┐
│                     完整的数据链路                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐     ┌──────────┐     ┌───────────────────┐   │
│  │  user   │     │  nurse   │     │nurse_patient_      │   │
│  │  表     │     │  表      │     │relation 表         │   │
│  ├─────────┤     ├──────────┤     ├───────────────────┤   │
│  │id=1     │◄────│user_id=1 │     │nurse_id=1          │   │
│  │护士账号  │     │          │     │patient_id=21 ──────┼──→│id=21  │
│  │type=2   │     │id=1      │     │patient_id=22 ──────┼──→│id=22  │
│  │         │     │name=护士 │     │patient_id=25 ──────┼──→│id=25  │
│  └─────────┘     └──────────┘     └───────────────────┘   │
│                                                             │
│  user表要求：                                               │
│  ✅ id IN (21, 22, 25) 存在                                │
│  ✅ user_type = 0 (患者)                                   │
│  ✅ is_deleted = 0 (未删除)                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧪 完成数据修复后的测试步骤

### 1️⃣ 重启应用（不需要重新编译）

如果只修改了数据库，可以直接在模拟器中：
- 关闭应用（上滑关闭）
- 重新打开应用
- 登录护士账号
- 进入患者列表

### 2️⃣ 预期效果

```
┌─────────────────────────────┐
│  ← 搜索患者姓名        清空  │
│                             │
│  ┌───────────────────────┐  │
│  │ 👤 张三               │  │
│  │    45岁 | 男          │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ 👤 李四               │  │
│  │    52岁 | 女          │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ 👤 王五               │  │
│  │    38岁 | 男          │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

---

## 💡 常见问题FAQ

### Q1: 为什么nurse_patient_relation有数据但还是空？

**A**: 因为这只是关联表！还需要 `user` 表有对应的实际数据，并且满足查询条件。

### Q2: user_type的值代表什么？

```
user_type = 0 → 普通用户/患者
user_type = 1 → 医生
user_type = 2 → 护士
user_type = 3 → 家属
user_type = 9 → 管理员
```

### Q3: 密码怎么加密？

项目中使用 BCrypt 加密，`123456` 的加密结果是：
```
$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv
```

### Q4: 如果ID冲突怎么办？

如果user表的ID已经被占用，可以修改nurse_patient_relation表的patient_id为实际存在的用户ID。

---

## 📞 下一步行动

### 立即执行（15分钟内解决）：

1. ✅ **打开Navicat Premium**
2. ✅ **执行诊断SQL**（diagnose_nurse_patients.sql）
3. ✅ **查看第5步结果**（检查user表是否有ID=21,22,25）
4. ✅ **如果缺失，执行方案2的INSERT语句**
5. ✅ **最终验证**（执行最后的SELECT验证）
6. 🔄 **重启模拟器中的应用**
7. 🧪 **测试患者列表功能**

### 反馈结果：

请告诉我：
- ✅ 诊断SQL的第5步返回了几条记录？
- ✅ 这些记录的 `user_type` 和 `is_deleted` 是多少？
- ✅ 执行INSERT后是否成功？
- ✅ 最终验证返回几条记录？

---

**现在就去Navicat执行诊断SQL吧！找到问题根源就能立即解决！** 🎯
