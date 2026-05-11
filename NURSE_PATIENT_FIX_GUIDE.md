# 护士端患者列表问题诊断与修复指南

## 🚨 问题描述

**现象**：护士端"搜索患者姓名"页面一直显示加载图标（转圈），无法显示患者数据

**截图信息**：
1. ✅ 护士已登录成功（显示：欢迎，护士 工号：N20230001 内科|护士）
2. ❌ 患者列表页面加载中但无数据显示
3. ✅ 数据库 `nurse_patient_relation` 表有3条关联记录（nurse_id=1, patient_id=21/22/25）

---

## 🔍 问题诊断结果

### ✅ **后端服务状态**
- 后端运行正常（端口 8080）
- API 接口可访问
- 返回 401 错误（需要 Token 认证）- 这是正常的

### ⚠️ **发现的关键问题**

#### **问题1：API 环境配置可能不匹配**

**当前配置**：
```typescript
// ApiConstants.ets 第22行
let currentEnv: EnvType = EnvType.DEV_EMULATOR;

// 第16行
[EnvType.DEV_EMULATOR]: { BASE_URL: 'http://10.0.2.2:8080', ... }
```

**问题分析**：
- `10.0.2.2` 是 **Android 模拟器** 访问宿主机的特殊 IP
- 你使用的是 **HarmonyOS 模拟器**，不是 Android 模拟器！
- HarmonyOS 模拟器应该使用 `localhost` 或实际 IP 地址

#### **问题2：Token 传递流程**

**正常流程应该是**：
```
护士登录 → 保存 Token → 访问患者列表 → 自动携带 Token → 后端验证 → 返回数据
```

**可能的断点**：
1. Token 未正确保存到 AppStorage/SettingsUtil
2. HttpUtil.get() 未检测到 isNurseLoggedIn 状态
3. getNurseToken() 返回 null
4. 后端解析 Token 失败

#### **问题3：数据库数据完整性**

虽然 `nurse_patient_relation` 表有数据，但还需确认：
- `nurse` 表是否存在 id=1 的记录？
- `user` 表是否存在 id=21, 22, 25 的记录且 userType=0（患者）？

---

## 🔧 解决方案（按优先级排序）

### 方案1：修改API环境配置（最可能的问题⭐）

#### 步骤1：检查当前使用的模拟器类型

确认你是使用哪种模拟器：
- **DevEco Studio 内置模拟器**（HarmonyOS）→ 应该用 `DEV` 环境
- **Android Studio 模拟器** → 用 `DEV_EMULATOR` 环境
- **真机测试** → 用 `DEV_DEVICE` 环境

#### 步骤2：修改环境配置

**文件**: [ApiConstants.ets#L22](file:///e:/harmony-health-care/entry/src/main/ets/common/constants/ApiConstants.ets#L22)

```typescript
// 如果是 HarmonyOS 模拟器，改为 DEV
let currentEnv: EnvType = EnvType.DEV;  // ✅ 改为这个

// 或者如果是真机测试，改为你的电脑IP
let currentEnv: EnvType = EnvType.DEVICE;  // 需要先添加DEVICE环境
```

**可选：添加 HarmonyOS 模拟器专用环境**

在 [ApiConstants.ets#L14-L20](file:///e:/harmony-health-care/entry/src/main/ets/common/constants/ApiConstants.ets#L14) 中添加：

```typescript
const ENV_MAP: Record<EnvType, EnvConfig> = {
  [EnvType.DEV]: { BASE_URL: 'http://localhost:8080', UPLOAD_URL: 'http://localhost:8080/upload' },
  [EnvType.DEV_EMULATOR]: { BASE_URL: 'http://10.0.2.2:8080', UPLOAD_URL: 'http://10.0.2.2:8080/upload' },
  [EnvType.DEV_DEVICE]: { BASE_URL: 'http://192.168.71.233:8080', UPLOAD_URL: 'http://192.168.71.233:8080/upload' },
  // 新增：HarmonyOS 模拟器环境
  [EnvType.DEV_HARMONY]: { BASE_URL: 'http://localhost:8080', UPLOAD_URL: 'http://localhost:8080/upload' },
  [EnvType.TEST]: { BASE_URL: 'http://test.health-care.com', ... },
  [EnvType.PROD]: { BASE_URL: 'https://api.health-care.com', ... }
};
```

然后在枚举中添加：

```typescript
export enum EnvType {
  DEV = 'DEV',
  DEV_EMULATOR = 'DEV_EMULATOR',
  DEV_HARMONY = 'DEV_HARMONY',  // 新增
  DEV_DEVICE = 'DEV_DEVICE',
  TEST = 'TEST',
  PROD = 'PROD'
}
```

最后修改当前环境：

```typescript
let currentEnv: EnvType = EnvType.DEV_HARMONY;  // 或 EnvType.DEV
```

#### 步骤3：重新编译运行

```bash
Ctrl + F9    # 编译
Shift + F10  # 运行
```

---

### 方案2：验证数据库数据完整性

在 Navicat Premium 或 MySQL 客户端中执行以下 SQL：

```sql
-- 1. 检查护士表是否有 id=1 的记录
SELECT * FROM nurse WHERE id = 1;

-- 预期输出：应返回1条记录（工号 N20230001 的护士）

-- 2. 检查用户表是否有对应的患者记录
SELECT id, username, real_name, user_type, is_deleted
FROM user
WHERE id IN (21, 22, 25);

-- 预期输出：应返回3条记录，且 user_type=0（患者），is_deleted=0

-- 3. 检查关联关系是否完整
SELECT
    npr.id,
    npr.nurse_id,
    npr.patient_id,
    n.name AS nurse_name,
    u.real_name AS patient_name
FROM nurse_patient_relation npr
LEFT JOIN nurse n ON npr.nurse_id = n.id
LEFT JOIN user u ON npr.patient_id = u.id
WHERE npr.is_deleted = 0;

-- 预期输出：3条完整记录，包含护士和患者姓名
```

**如果缺少数据，需要补充**：

```sql
-- 如果 nurse 表没有 id=1 的记录
INSERT INTO nurse (id, name, phone, password, department, create_time)
VALUES (1, '测试护士', '13800138000', '加密密码', '内科', NOW());

-- 如果 user 表缺少患者记录
INSERT INTO user (id, username, real_name, user_type, phone, is_deleted, create_time)
VALUES
(21, 'patient21', '张三', 0, '13900139000', 0, NOW()),
(22, 'patient22', '李四', 0, '13900139001', 0, NOW()),
(25, 'patient25', '王五', 0, '13900139002', 0, NOW());
```

---

### 方案3：手动测试API接口

#### 步骤1：获取有效的护士 Token

先通过登录接口获取 Token。在 PowerShell 中执行：

```powershell
# 护士登录获取 Token
$body = @{
    phone = "护士手机号"
    password = "护士密码"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/nurse/login" -Method Post -Body $body -ContentType "application/json"
$token = $response.data.token
Write-Host "Token: $token"
```

#### 步骤2：使用 Token 测试患者列表接口

```powershell
# 使用 Token 获取患者列表
$headers = @{
    "Token" = "$token"
}

$response = Invoke-RestMethod -Uri "http://localhost:8080/user/nurse/patients" -Method Get -Headers $headers
$response | ConvertTo-Json -Depth 5
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

如果这个测试成功，说明后端没问题，问题在前端。

---

### 方案4：添加调试日志（如果以上方案都不行）

在前端代码中添加详细日志来定位问题。

**文件**: [NursePatientList.ets#L59-L89](file:///e:/harmony-health-care/entry/src/main/ets/pages/NursePatientList.ets#L59)

```typescript
private async loadPatients(): Promise<void> {
  this.isLoading = true;
  try {
    // ===== 添加调试日志开始 =====
    let nurseId: number = this.currentUserId;
    
    console.log('[DEBUG] currentUserId:', this.currentUserId);
    console.log('[DEBUG] nurseInfo:', JSON.stringify(this.nurseInfo));
    console.log('[DEBUG] isNurseLoggedIn:', AppStorage.get<boolean>('isNurseLoggedIn'));
    console.log('[DEBUG] nurseToken (前20字符):', 
      AppStorage.get<string>('nurseToken')?.substring(0, 20));
    // ===== 添加调试日志结束 =====

    if (this.nurseInfo !== null && this.nurseInfo !== undefined) {
      nurseId = this.nurseInfo.id;
    }
    
    const url = `${ApiConstants.NURSE_PATIENTS}?nurseId=${nurseId}`;
    console.log('[DEBUG] 请求URL:', url);
    console.log('[DEBUG] 完整URL:', ApiConstants.BASE_URL + url);
    
    const response = await HttpUtil.get<PatientInfo[]>(url);
    console.log('[DEBUG] 响应状态:', response.success);
    console.log('[DEBUG] 响应数据:', JSON.stringify(response));
    
    if (response.success && response.data !== null && response.data !== undefined) {
      this.patients = response.data;
      console.log('[DEBUG] 加载成功，患者数量:', this.patients.length);
    } else {
      this.patients = [];
      const message = response.message || '暂无分配的患者';
      console.error('[DEBUG] 加载失败:', message);
      ToastUtil.showError(message);
    }
  } catch (error) {
    console.error('[DEBUG] 异常:', error);
    this.patients = [];
    this.hasError = true;
    ToastUtil.showError('加载失败，请稍后重试');
  } finally {
    this.isLoading = false;
  }
}
```

然后在 DevEco Studio 的 Log 窗口中查看这些调试信息。

---

## 📊 完整的数据流程图

```
┌─────────────────────────────────────────────────────────────┐
│                     护士端患者列表流程                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 护士登录                                                │
│     NurseLogin.ets                                         │
│     ↓ POST /nurse/login                                     │
│     ↓ 返回 Token + NurseInfo                                │
│     ↓ 保存到 AppStorage & SettingsUtil                      │
│                                                             │
│  2. 进入患者列表                                            │
│     NursePatientList.ets                                    │
│     ↓ aboutToAppear()                                       │
│     ↓ 检查 isNurseLoggedIn                                  │
│                                                             │
│  3. 加载患者数据                                            │
│     loadPatients()                                          │
│     ↓ 获取 nurseId (从 nurseInfo 或 userId)                 │
│     ↓ 构建URL: /user/nurse/patients?nurseId=xxx            │
│                                                             │
│  4. HTTP请求                                                │
│     HttpUtil.get()                                          │
│     ↓ 检测 isNurseLoggedIn=true                             │
│     ↓ 调用 getNurseToken() 获取 Token                       │
│     ↓ 添加请求头: Token: xxx                                │
│     ↓ 发送 GET 请求                                         │
│                                                             │
│  5. 后端处理                                                │
│     UserController.getNursePatients()                       │
│     ↓ 从请求头获取 Token                                     │
│     ↓ JwtUtil.getNurseId(token) 解析 nurseId               │
│     ↓ 查询 nurse 表确认护士存在                              │
│     ↓ 查询 nurse_patient_relation 表获取 patientIds         │
│     ↓ SELECT patient_id FROM nurse_patient_relation          │
│       WHERE nurse_id=? AND is_deleted=0                     │
│     ↓ 查询 user 表获取患者详情                               │
│     ↓ SELECT * FROM user WHERE id IN (...)                  │
│       AND user_type=0 AND is_deleted=0                      │
│     ↓ 返回患者列表                                           │
│                                                             │
│  6. 前端渲染                                                │
│     接收响应数据                                             │
│     ↓ 更新 patients 状态                                     │
│     ↓ ForEach 渲染列表                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧪 测试清单

完成修复后，请按以下步骤测试：

### 基础功能测试
- [ ] **护士登录成功**：输入正确的手机号和密码
- [ ] **进入工作台正常**：看到"欢迎，护士"和快捷功能
- [ ] **点击"患者列表"**：能进入患者列表页面
- [ ] **页面不再卡在加载状态**：加载完成后显示内容或提示

### 数据显示测试
- [ ] **显示患者列表**：能看到3个患者（张三、李四、王五）
- [ ] **患者信息完整**：显示姓名、年龄、性别、科室等
- [ ] **搜索功能正常**：输入关键词能过滤患者
- [ ] **点击跳转正常**：点击患者能进入详情页

### 边界情况测试
- [ ] **无网络时提示友好**：不崩溃，显示错误提示
- [ ] **无患者时显示空状态**："暂无分配的患者"
- [ ] **Token过期时重新登录**：自动跳转到登录页

---

## 💡 常见问题 FAQ

### Q1: 改了环境配置还是不行？

**A**: 请检查：
1. 后端服务是否真的在运行？访问 http://localhost:8080/test-health-food
2. 防火墙是否阻止了连接？暂时关闭防火墙测试
3. 模拟器网络设置？确保能访问外网

### Q2: 如何确认Token是否有效？

**A**: 在浏览器或Postman中测试：
```bash
# 使用从AppStorage获取的Token
curl -H "Token: YOUR_TOKEN_HERE" http://localhost:8080/user/nurse/patients
```

### Q3: 数据库有数据但前端不显示？

**A**: 可能原因：
1. SQL查询条件不满足（is_deleted、user_type等）
2. 字段名不匹配（驼峰命名 vs 下划线）
3. 数据转换错误（Long vs Integer）
4. 前端状态未更新（@State装饰器缺失）

### Q4: 日志太多看不过来？

**A**: 在 DevEco Studio Log 窗口中使用过滤器：
- 输入 `NursePatientList` 过滤相关日志
- 输入 `[DEBUG]` 只看调试日志
- 输入 `ERROR` 只看错误日志

---

## 📞 下一步操作建议

### 立即执行（按顺序）：

1. **✅ 先尝试方案1**：修改 API 环境配置（最可能解决问题）
2. **🔄 重启应用并测试**
3. **📝 如果还不行，执行方案2**：验证数据库数据
4. **🔧 如果还不行，执行方案3**：手动测试 API
5. **🐛 最后手段**：执行方案4，添加详细调试日志

### 提供反馈：

如果以上方案都无法解决，请提供以下信息：

1. **控制台日志**（DevEco Studio Log窗口）
   - 搜索关键词：`NursePatientList`、`HttpUtil`、`ERROR`
   
2. **网络请求详情**
   - URL、请求头、响应状态码、响应体

3. **数据库查询结果**
   - 执行方案2中的SQL语句的结果截图

4. **你使用的模拟器类型**
   - DevEco Studio 内置模拟器？
   - Android 模拟器？
   - 真机？

---

**文档版本**：v1.0  
**创建时间**：2026-01-15  
**适用场景**：HarmonyOS 护士端患者列表加载失败
