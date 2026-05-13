# 🔧 护士登录问题修复指南

## 📋 问题诊断

### 症状
- ✅ 护士登录页面正常显示
- ❌ 输入手机号和密码后，页面卡在"加载中..."状态
- ❌ 无法进入护士工作台

### 根本原因
1. **密码不匹配**：数据库中的密码可能是旧版本或加密方式不一致
2. **后端服务未响应**：可能后端未启动或网络连接问题
3. **错误信息未显示**：前端缺少详细日志输出

---

## ✅ 已完成的修复

### 1️⃣ **重置护士密码** 
文件：[fix-nurse-login-password.sql](../sql/fix-nurse-login-password.sql)

**执行步骤：**
```sql
-- 在 MySQL 中执行此SQL文件
SOURCE e:/harmony-health-care/sql/fix-nurse-login-password.sql;
```

**效果：**
- 将手机号 `13800138001` 的密码重置为 `123456`
- 验证 nurse 表和 user 表的关联关系正确

---

### 2️⃣ **优化前端错误处理**
文件：[NurseLogin.ets](../entry/src/main/ets/pages/NurseLogin.ets)

**新增日志输出：**
```typescript
console.log('[NurseLogin] 开始登录请求...');
console.log('[NurseLogin] 手机号:', this.phone);
console.log('[NurseLogin] 收到响应:', JSON.stringify(response));
console.log('[NurseLogin] success:', response.success);
// ... 更多详细日志
```

**作用：**
- 可以在 HiLog 中看到完整的请求/响应流程
- 快速定位问题所在（网络？密码？后端错误？）

---

## 🧪 测试步骤

### 前置条件检查

#### ✓ 检查1：后端服务是否运行
```bash
# 查看后端日志（应该看到 "Started MedicalApplication"）
# 或者访问 http://localhost:8080/nurse/list 测试
```

#### ✓ 检查2：数据库是否已更新密码
```sql
-- 执行查询验证
SELECT phone, password FROM user WHERE phone = '13800138001';
-- 密码应该是: $2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv
```

#### ✓ 检查3：护士账号状态
```sql
SELECT n.*, u.real_name, u.status AS user_status
FROM nurse n 
JOIN user u ON n.user_id = u.id 
WHERE n.phone = '13800138001';
-- status 应该 = 1, is_deleted = 0
```

---

### 执行登录测试

#### 步骤1：打开护士登录页面
- 应用启动 → 进入护士登录页（自动跳转或手动导航）

#### 步骤2：输入测试账号
```
手机号: 13800138001
密码:   123456
```

#### 步骤3：点击"登录"按钮
观察：
1. **按钮状态** → 变为禁用 + 显示"加载中..."
2. **HiLog 日志** → 查看 `[NurseLogin]` 开头的日志
3. **结果** → 成功跳转到 `NurseWorkbench` 页面

---

## 🔍 故障排查

### 场景1：一直显示"加载中..."

**可能原因：**
- 后端服务未启动
- 网络不通（模拟器/真机无法访问 localhost）
- 请求超时

**排查方法：**
```bash
# 1. 检查后端控制台是否有 POST /nurse/login 请求
# 2. 查看HiLog中的 [HttpUtil] 日志
# 3. 检查网络地址配置（ApiConstants.ets）
```

**解决方案：**
```typescript
// ApiConstants.ets - 确保环境配置正确
[EnvType.DEV_EMULATOR]: { 
  BASE_URL: 'http://10.0.2.2:8080',  // 模拟器用这个
}
```

---

### 场景2：提示"手机号不存在或不是护士账号"

**可能原因：**
- 数据库中没有该手机号的护士记录
- nurse 表和 user 表关联断裂

**解决方案：**
```sql
-- 重新插入护士数据
INSERT INTO nurse (user_id, nurse_no, name, phone, department, title, status)
VALUES (109, 'N20230001', '测试护士', '13800138001', '内科', '护师', 1);
```

---

### 场景3：提示"密码错误"

**可能原因：**
- 密码未重置成功
- BCrypt验证失败

**解决方案：**
```sql
-- 再次执行密码重置脚本
UPDATE user SET password = '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv'
WHERE phone = '13800138001';
```

---

### 场景4：提示"护士账号已离职或不可用"

**可能原因：**
- nurse.status ≠ 1
- nurse.is_deleted = 1

**解决方案：**
```sql
UPDATE nurse SET status = 1, is_deleted = 0 WHERE phone = '13800138001';
UPDATE user SET status = 1, is_deleted = 0 WHERE phone = '13800138001';
```

---

## 📊 成功标志

登录成功后，你应该看到：

### ✅ 前端表现
1. Toast 提示："登录成功"
2. 页面跳转到护士工作台
3. 工作台显示护士姓名、科室等信息

### ✅ 日志输出（HiLog）
```
[NurseLogin] 开始登录请求...
[NurseLogin] 手机号: 13800138001
[NurseLogin] 发送POST请求到 /nurse/login
[NurseLogin] 收到响应: {"success":true,"data":{...}}
[NurseLogin] success: true
[NurseLogin] data: 存在
[NurseLogin] 登录成功，保存Token和护士信息...
[NurseLogin] 保存userId到AppStorage: 1
[NurseLogin] 准备跳转到护士工作台...
[NurseLogin] 登录请求结束，isLoading设为false
```

### ✅ AppStorage 状态
```typescript
nurseToken: "eyJhbGciOiJIUzI1NiJ9..."  // JWT Token
nurseInfo: { id: 1, userId: 109, name: "于护士", ... }
isNurseLoggedIn: true
userId: 1  // 或 109（取决于nurseInfo）
```

---

## 🎯 测试账号清单

| 手机号 | 密码 | 姓名 | 科室 | 用途 |
|--------|------|------|------|------|
| 13800138001 | 123456 | 于护士/张护士 | 内科 | 主测试账号 |
| 13900001001 | 123456 | 李梅 | - | 备用护士1 |
| 13900001002 | 123456 | 王芳 | - | 备用护士2 |

> 💡 所有护士账号的密码都已重置为 `123456`

---

## 🚀 下一步操作

1. **执行SQL脚本** 重置密码
2. **重启后端服务**（如果正在运行）
3. **重新运行前端应用**
4. **使用测试账号登录**
5. **查看HiLog日志** 确认流程正常
6. **验证其他功能**（患者列表、用药管理等）

---

## 📝 注意事项

⚠️ **不要修改的内容：**
- 其他页面的代码（避免影响已有功能）
- 数据库表结构
- 后端核心业务逻辑

✅ **只修改了：**
- 护士密码（SQL脚本）
- NurseLogin.ets 的日志输出（不影响功能）

🔒 **安全性提醒：**
- 生产环境请勿使用 `123456` 作为默认密码
- 测试完成后应要求用户修改密码

---

## 📞 如果还有问题

请提供以下信息：
1. HiLog 中 `[NurseLogin]` 开头的所有日志
2. 后端控制台的错误信息（如果有）
3. 当前使用的网络环境（模拟器/真机/WiFi）
4. 数据库查询结果（执行上面的SQL）

**祝测试顺利！** 🎉
