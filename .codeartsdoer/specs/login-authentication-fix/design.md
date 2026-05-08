# 登录认证系统修复 - 技术设计文档

**版本**: v1.0
**创建日期**: 2026-05-08
**最后更新**: 2026-05-08
**作者**: 系统架构师
**状态**: 草稿

## 1. 设计概述

### 1.1 设计目标

本技术设计旨在解决当前登录认证系统存在的三个核心问题：

1. **Token验证失败问题**：修复401错误处理逻辑，确保家属和护士Token能够正确验证
2. **权限控制问题**：优化登录权限检查机制，提供灵活的权限管理方案
3. **数据关联问题**：确保家属和护士数据正确关联到用户表，完善认证流程

**技术目标**：
- 实现多角色Token独立管理和验证
- 优化前端Token存储和恢复机制
- 完善后端认证拦截器和异常处理
- 提供统一的登录状态管理方案

### 1.2 技术选型

| 技术领域 | 选型方案 | 选型理由 |
|---------|---------|---------|
| Token生成 | JWT (HS256) | 已有实现，支持多角色标识，无需额外依赖 |
| 密码加密 | BCrypt | 业界标准，安全性高，已有实现 |
| 前端状态管理 | AppStorage + SettingsUtil | HarmonyOS原生方案，支持持久化 |
| HTTP拦截 | HttpUtil统一封装 | 已有实现，需扩展多角色Token支持 |
| 后端认证 | Spring Interceptor | Spring生态标准，易于扩展 |

### 1.3 设计约束

**技术约束**：
- 必须兼容现有用户和管理员登录逻辑
- 不能破坏现有API接口契约
- Token格式必须保持向后兼容
- 数据库表结构变更需提供迁移脚本

**业务约束**：
- 家属登录权限默认关闭
- 护士账号由管理员创建
- Token有效期24小时不可更改
- 登录失败3次锁定30分钟

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         前端层 (HarmonyOS)                        │
├─────────────────────────────────────────────────────────────────┤
│  FamilyLogin Page    │  NurseLogin Page    │  Login Page        │
│  ├─ 表单验证          │  ├─ 表单验证         │  ├─ 表单验证        │
│  ├─ 登录请求          │  ├─ 登录请求         │  ├─ 登录请求        │
│  └─ Token存储         │  └─ Token存储        │  └─ Token存储       │
├─────────────────────────────────────────────────────────────────┤
│                    HttpUtil (HTTP请求封装)                        │
│  ├─ Token获取策略 (多角色支持)                                      │
│  ├─ 401错误处理 (角色识别)                                          │
│  └─ Token持久化 (SettingsUtil)                                     │
├─────────────────────────────────────────────────────────────────┤
│                    AuthManager (认证管理)                          │
│  ├─ getCurrentRole() - 角色识别                                     │
│  ├─ hasPermission() - 权限检查                                      │
│  └─ clearAuth() - 清除认证                                          │
└─────────────────────────────────────────────────────────────────┘
                                   │
                                   │ HTTPS
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                        后端层 (Spring Boot)                        │
├─────────────────────────────────────────────────────────────────┤
│  FamilyAuthController │ NurseController      │ UserController    │
│  ├─ POST /family/login│ ├─ POST /nurse/login │ ├─ POST /login    │
│  ├─ GET /family/info  │ ├─ GET /nurse/info   │ └─ GET /info      │
│  └─ PUT login-enabled │ └─ ...               │                   │
├─────────────────────────────────────────────────────────────────┤
│                    Service Layer                                  │
│  FamilyAuthService    │ NurseService         │ UserService       │
│  ├─ login()           │ ├─ login()           │ ├─ login()        │
│  ├─ validateToken()   │ ├─ validateToken()   │ └─ validateToken()│
│  └─ updateLoginEnabled│ └─ ...               │                   │
├─────────────────────────────────────────────────────────────────┤
│                    JwtUtil (Token工具)                             │
│  ├─ generateFamilyToken(familyId, phone)                          │
│  ├─ generateNurseToken(nurseId, phone)                            │
│  ├─ isFamilyToken(token) / isNurseToken(token)                    │
│  └─ validateToken(token)                                          │
├─────────────────────────────────────────────────────────────────┤
│                    Database (MySQL)                               │
│  ├─ user表 (用户基础信息)                                           │
│  ├─ family_member表 (家属信息 + 登录字段)                            │
│  ├─ nurse表 (护士信息)                                              │
│  └─ family_auth_log表 (家属认证日志)                                │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

#### 前端模块

| 模块名称 | 职责 | 关键文件 |
|---------|------|---------|
| FamilyLogin | 家属登录页面，表单验证和登录请求 | `pages/FamilyLogin.ets` |
| NurseLogin | 护士登录页面，表单验证和登录请求 | `pages/NurseLogin.ets` |
| HttpUtil | HTTP请求封装，Token管理和401处理 | `common/utils/HttpUtil.ets` |
| SettingsUtil | 持久化存储，Token和用户信息存储 | `utils/SettingsUtil.ets` |
| AuthManager | 认证管理，角色识别和权限检查 | `utils/AuthManager.ets` |

#### 后端模块

| 模块名称 | 职责 | 关键文件 |
|---------|------|---------|
| FamilyAuthController | 家属认证API接口 | `controller/FamilyAuthController.java` |
| FamilyAuthService | 家属认证业务逻辑 | `service/impl/FamilyAuthServiceImpl.java` |
| NurseController | 护士认证API接口 | `controller/NurseController.java` |
| NurseService | 护士认证业务逻辑 | `service/impl/NurseServiceImpl.java` |
| JwtUtil | JWT Token生成和验证 | `common/JwtUtil.java` |

### 2.3 依赖关系

```
前端依赖关系：
FamilyLogin/NurseLogin → HttpUtil → SettingsUtil
                      → AuthManager → SessionInfo

后端依赖关系：
FamilyAuthController → FamilyAuthService → FamilyMemberMapper
                                     → JwtUtil
                                     → BCryptUtil
                                     → UserMapper
```

## 3. 模块详细设计

### 3.1 HttpUtil模块（前端核心）

#### 3.1.1 职责定义
HttpUtil是前端HTTP请求的核心封装模块，负责：
- 统一HTTP请求发送和响应处理
- 多角色Token获取和管理
- 401错误智能处理（根据角色跳转）
- Token持久化存储

#### 3.1.2 关键接口设计

```typescript
// Token获取策略接口
interface TokenStrategy {
  getToken(): string | null;
  getStorageKey(): string;
  getLoginPage(): string;
}

// 家属Token策略
class FamilyTokenStrategy implements TokenStrategy {
  getToken(): string | null {
    // 优先从AppStorage获取，其次从持久化存储获取
    const token = AppStorage.get<string>('familyToken');
    if (token && token.length > 0) return token;
    
    const settings = SettingsUtil.getInstance();
    return settings.getFamilyTokenSync();
  }
  
  getStorageKey(): string {
    return 'familyToken';
  }
  
  getLoginPage(): string {
    return 'pages/FamilyLogin';
  }
}

// 护士Token策略
class NurseTokenStrategy implements TokenStrategy {
  getToken(): string | null {
    const token = AppStorage.get<string>('nurseToken');
    if (token && token.length > 0) return token;
    
    const settings = SettingsUtil.getInstance();
    return settings.getNurseTokenSync();
  }
  
  getStorageKey(): string {
    return 'nurseToken';
  }
  
  getLoginPage(): string {
    return 'pages/NurseLogin';
  }
}
```

#### 3.1.3 关键方法改进

**改进点1：多角色Token获取**

```typescript
// 原方法：仅支持普通用户和管理员
static getToken(): string | null {
  // 只获取 'token' 键
}

// 改进后：支持多角色
static getToken(role?: 'user' | 'family' | 'nurse' | 'admin'): string | null {
  const tokenRole = role || this.detectCurrentRole();
  
  switch (tokenRole) {
    case 'family':
      return this.getFamilyToken();
    case 'nurse':
      return this.getNurseToken();
    case 'admin':
      return this.getAdminToken();
    default:
      return this.getUserToken();
  }
}

// 角色检测
private static detectCurrentRole(): string {
  if (AppStorage.get<boolean>('isFamilyLoggedIn')) return 'family';
  if (AppStorage.get<boolean>('isNurseLoggedIn')) return 'nurse';
  if (AppStorage.get<boolean>('isAdminLoggedIn')) return 'admin';
  if (AppStorage.get<boolean>('isLoggedIn')) return 'user';
  return 'user';
}
```

**改进点2：401错误智能处理**

```typescript
// 原方法：仅判断管理员和普通用户
if (response.responseCode === 401) {
  if (isAdminLoggedIn) {
    // 跳转管理员登录
  } else if (isLoggedIn) {
    // 跳转普通用户登录
  }
}

// 改进后：支持多角色
if (response.responseCode === 401) {
  if (!isHandling401) {
    isHandling401 = true;
    
    // 按优先级检测角色
    const role = this.detectCurrentRole();
    
    switch (role) {
      case 'family':
        this.clearFamilyToken();
        AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
        this.showToast('登录已过期，请重新登录');
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/FamilyLogin' });
          isHandling401 = false;
        }, 1500);
        break;
        
      case 'nurse':
        this.clearNurseToken();
        AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
        this.showToast('登录已过期，请重新登录');
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/NurseLogin' });
          isHandling401 = false;
        }, 1500);
        break;
        
      case 'admin':
        // 管理员处理逻辑
        break;
        
      default:
        // 普通用户处理逻辑
    }
  }
}
```

#### 3.1.4 数据流

```
登录请求流程：
FamilyLogin.ets
  │
  ├─> HttpUtil.post('/family/login', data, { skipAuth: true })
  │     │
  │     ├─> executeRequest() - 发送请求
  │     │
  │     └─> handleResponse() - 处理响应
  │           │
  │           └─> 返回 { token, familyInfo, relatedUser }
  │
  ├─> SettingsUtil.saveFamilyToken(token)
  │
  ├─> SettingsUtil.saveFamilyInfo(familyInfo)
  │
  ├─> AppStorage.setOrCreate('familyToken', token)
  │
  ├─> AppStorage.setOrCreate('familyInfo', familyInfo)
  │
  ├─> AppStorage.setOrCreate('isFamilyLoggedIn', true)
  │
  └─> router.replaceUrl({ url: 'pages/FamilyHome' })
```

### 3.2 SettingsUtil模块（持久化存储）

#### 3.2.1 职责定义
负责用户数据的持久化存储，包括：
- Token的保存、读取、清除
- 用户信息的保存和读取
- 登录状态的持久化

#### 3.2.2 新增方法

```typescript
class SettingsUtil {
  // ========== 家属相关方法 ==========
  
  async saveFamilyToken(token: string): Promise<void> {
    await this.preferences.put('family_token', token);
    await this.preferences.flush();
  }
  
  getFamilyTokenSync(): string {
    return this.preferences.getSync('family_token', '') as string;
  }
  
  async saveFamilyInfo(familyInfo: FamilyInfo): Promise<void> {
    await this.preferences.put('family_info', JSON.stringify(familyInfo));
    await this.preferences.flush();
  }
  
  getFamilyInfoSync(): FamilyInfo | null {
    const json = this.preferences.getSync('family_info', '') as string;
    if (json && json.length > 0) {
      return JSON.parse(json) as FamilyInfo;
    }
    return null;
  }
  
  async clearFamilyToken(): Promise<void> {
    await this.preferences.delete('family_token');
    await this.preferences.delete('family_info');
    await this.preferences.flush();
  }
  
  // ========== 护士相关方法 ==========
  
  async saveNurseToken(token: string): Promise<void> {
    await this.preferences.put('nurse_token', token);
    await this.preferences.flush();
  }
  
  getNurseTokenSync(): string {
    return this.preferences.getSync('nurse_token', '') as string;
  }
  
  async saveNurseInfo(nurseInfo: NurseInfo): Promise<void> {
    await this.preferences.put('nurse_info', JSON.stringify(nurseInfo));
    await this.preferences.flush();
  }
  
  getNurseInfoSync(): NurseInfo | null {
    const json = this.preferences.getSync('nurse_info', '') as string;
    if (json && json.length > 0) {
      return JSON.parse(json) as NurseInfo;
    }
    return null;
  }
  
  async clearNurseToken(): Promise<void> {
    await this.preferences.delete('nurse_token');
    await this.preferences.delete('nurse_info');
    await this.preferences.flush();
  }
}
```

### 3.3 FamilyAuthService模块（后端核心）

#### 3.3.1 职责定义
负责家属认证的业务逻辑，包括：
- 登录验证（手机号、权限、密码）
- Token生成
- 登录失败处理
- 登录权限管理

#### 3.3.2 关键方法设计

**登录方法流程**：

```java
public FamilyLoginResponse login(FamilyLoginRequest request) {
    // 1. 查询家属信息
    FamilyMember family = familyMemberMapper.selectByPhone(request.getPhone());
    if (family == null) {
        throw new RuntimeException("手机号不存在");
    }
    
    // 2. 检查登录权限
    if (family.getLoginEnabled() == null || family.getLoginEnabled() != 1) {
        throw new RuntimeException("家属登录功能未开启，请联系用户开启");
    }
    
    // 3. 检查账号锁定
    if (family.getLockUntil() != null && family.getLockUntil().after(new Date())) {
        throw new RuntimeException("账号已锁定，请稍后再试");
    }
    
    // 4. 验证密码
    if (!BCryptUtil.matches(request.getPassword(), family.getPassword())) {
        handleLoginFail(family);  // 增加失败次数
        throw new RuntimeException("密码错误");
    }
    
    // 5. 生成Token
    String token = JwtUtil.generateFamilyToken(family.getId(), family.getPhone());
    
    // 6. 更新登录信息
    family.setLoginFailCount(0);
    family.setLockUntil(null);
    family.setLastLoginTime(new Date());
    familyMemberMapper.updateById(family);
    
    // 7. 记录登录日志
    saveAuthLog(family.getId(), true, null);
    
    // 8. 构建响应
    FamilyLoginResponse response = new FamilyLoginResponse();
    response.setToken(token);
    response.setFamilyInfo(family);
    
    User relatedUser = userMapper.selectById(family.getUserId());
    response.setRelatedUser(relatedUser);
    
    return response;
}
```

**登录失败处理**：

```java
private void handleLoginFail(FamilyMember family) {
    // 增加失败次数
    int failCount = (family.getLoginFailCount() == null ? 0 : family.getLoginFailCount()) + 1;
    family.setLoginFailCount(failCount);
    
    // 失败3次，锁定30分钟
    if (failCount >= 3) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MINUTE, 30);
        family.setLockUntil(cal.getTime());
    }
    
    familyMemberMapper.updateById(family);
    saveAuthLog(family.getId(), false, "密码错误");
}
```

### 3.4 JwtUtil模块（Token工具）

#### 3.4.1 职责定义
负责JWT Token的生成、解析和验证，支持多角色标识。

#### 3.4.2 Token结构设计

**家属Token结构**：
```json
{
  "familyId": 1,
  "phone": "13800138001",
  "sub": "FAMILY",
  "iat": 1715145600,
  "exp": 1715232000
}
```

**护士Token结构**：
```json
{
  "nurseId": 1,
  "phone": "13900139001",
  "sub": "NURSE",
  "iat": 1715145600,
  "exp": 1715232000
}
```

#### 3.4.3 关键方法

```java
// 生成家属Token
public static String generateFamilyToken(Long familyId, String phone) {
    Map<String, Object> claims = new HashMap<>();
    claims.put("familyId", familyId);
    claims.put("phone", phone);
    return Jwts.builder()
            .setClaims(claims)
            .setSubject("FAMILY")  // 角色标识
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + EXPIRE_TIME))
            .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
            .compact();
}

// 判断是否为家属Token
public static boolean isFamilyToken(String token) {
    try {
        Claims claims = parseToken(token);
        return "FAMILY".equals(claims.getSubject());
    } catch (Exception e) {
        return false;
    }
}

// 获取家属ID
public static Long getFamilyId(String token) {
    Claims claims = parseToken(token);
    if ("FAMILY".equals(claims.getSubject())) {
        return claims.get("familyId", Long.class);
    }
    return null;
}
```

## 4. 数据模型设计

### 4.1 核心数据结构

#### 前端数据模型

```typescript
// 家属信息
interface FamilyInfo {
  id: number;
  name: string;
  phone: string;
  relation: string;
  age?: number;
  gender?: number;
  healthCondition?: string;
  isEmergencyContact: number;
  loginEnabled?: number;  // 是否允许登录
}

// 护士信息
interface NurseInfo {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  gender: number;
  phone: string;
  department: string;
  title: string;
  certificateNo: string;
  workYears: number;
  avatar: string;
  status: number;
}

// 登录响应
interface FamilyLoginResponseData {
  token: string;
  familyInfo: FamilyInfo;
  relatedUser: RelatedUser;
}

interface NurseLoginResponseData {
  token: string;
  nurseInfo: NurseInfo;
  relatedUser: RelatedUser;
}
```

#### 后端数据模型

```java
// 家属实体
public class FamilyMember {
    private Long id;
    private Long userId;          // 关联用户ID
    private String name;
    private String phone;
    private String password;      // BCrypt加密
    private String relation;
    private Integer loginEnabled; // 是否允许登录 0/1
    private Integer loginFailCount; // 登录失败次数
    private Date lockUntil;       // 锁定截止时间
    private Date lastLoginTime;   // 最后登录时间
    // ... 其他字段
}

// 护士实体
public class Nurse {
    private Long id;
    private Long userId;
    private String nurseNo;
    private String name;
    private String phone;
    private String password;      // BCrypt加密
    private Integer status;       // 状态 0-禁用 1-正常
    // ... 其他字段
}
```

### 4.2 数据关系

```
ER图：

┌─────────────┐         ┌─────────────────┐
│    user     │         │  family_member  │
├─────────────┤         ├─────────────────┤
│ id (PK)     │◄────────│ user_id (FK)    │
│ username    │    1:N  │ id (PK)         │
│ password    │         │ name            │
│ phone       │         │ phone           │
│ user_type   │         │ password        │
└─────────────┘         │ login_enabled   │
                        │ login_fail_count│
                        │ lock_until      │
                        └─────────────────┘

┌─────────────┐         ┌─────────────────┐
│    user     │         │      nurse      │
├─────────────┤         ├─────────────────┤
│ id (PK)     │◄────────│ user_id (FK)    │
│ username    │    1:1  │ id (PK)         │
│ password    │         │ nurse_no        │
│ phone       │         │ name            │
│ user_type   │         │ phone           │
└─────────────┘         │ password        │
                        │ status          │
                        └─────────────────┘
```

### 4.3 数据存储

#### 前端存储方案

| 存储位置 | 存储内容 | 存储方式 |
|---------|---------|---------|
| AppStorage | familyToken, familyInfo, isFamilyLoggedIn | 内存，应用级共享 |
| AppStorage | nurseToken, nurseInfo, isNurseLoggedIn | 内存，应用级共享 |
| Preferences | family_token, family_info | 持久化，应用重启后恢复 |
| Preferences | nurse_token, nurse_info | 持久化，应用重启后恢复 |

#### 后端存储方案

| 表名 | 存储内容 | 关键字段 |
|-----|---------|---------|
| family_member | 家属信息 + 登录字段 | password, login_enabled, login_fail_count, lock_until |
| nurse | 护士信息 | password, status |
| family_auth_log | 家属认证日志 | login_time, login_result, fail_reason |

## 5. API设计

### 5.1 内部API

#### 家属登录API

```
POST /family/login

Request:
{
  "phone": "13800138001",
  "password": "123456"
}

Response (成功):
{
  "code": 200,
  "msg": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "familyInfo": {
      "id": 1,
      "name": "王秀英",
      "phone": "13800138001",
      "relation": "配偶",
      "loginEnabled": 1
    },
    "relatedUser": {
      "id": 1,
      "username": "13900139001",
      "realName": "王建国"
    }
  }
}

Response (失败 - 权限未开启):
{
  "code": 500,
  "msg": "家属登录功能未开启，请联系用户开启"
}

Response (失败 - 密码错误):
{
  "code": 500,
  "msg": "密码错误"
}
```

#### 护士登录API

```
POST /nurse/login

Request:
{
  "phone": "13900139001",
  "password": "123456"
}

Response (成功):
{
  "code": 200,
  "msg": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "nurseInfo": {
      "id": 1,
      "nurseNo": "N001",
      "name": "李护士",
      "phone": "13900139001",
      "department": "内科"
    },
    "relatedUser": {
      "id": 5,
      "username": "13900139001"
    }
  }
}
```

#### 更新家属登录权限API

```
PUT /family/{familyId}/login-enabled

Request:
{
  "loginEnabled": 1,
  "defaultPassword": "123456"  // 可选，首次开启时设置默认密码
}

Response:
{
  "code": 200,
  "msg": "操作成功"
}
```

### 5.2 外部API

无外部系统交互。

### 5.3 API规范

#### 请求规范

- 所有请求使用HTTPS协议
- 请求头包含 `Content-Type: application/json`
- 需要认证的接口在请求头携带 `Token: {token}`

#### 响应规范

```typescript
interface BaseResponse<T> {
  success: boolean;   // 业务成功标识
  message: string;    // 提示信息
  data?: T;          // 业务数据
  code?: number;     // 业务状态码
}
```

#### 错误码规范

| 错误码 | 含义 | 处理建议 |
|-------|------|---------|
| 200 | 成功 | - |
| 401 | Token无效或过期 | 跳转登录页 |
| 500 | 业务错误 | 显示错误信息 |

## 6. 关键算法设计

### 6.1 角色检测算法

#### 算法原理
根据AppStorage中的登录状态标识，按优先级检测当前登录角色。

#### 伪代码

```
function detectCurrentRole(): string
  if AppStorage.get('isFamilyLoggedIn') == true then
    return 'family'
  end if
  
  if AppStorage.get('isNurseLoggedIn') == true then
    return 'nurse'
  end if
  
  if AppStorage.get('isAdminLoggedIn') == true then
    return 'admin'
  end if
  
  if AppStorage.get('isLoggedIn') == true then
    return 'user'
  end if
  
  return 'guest'
end function
```

#### 复杂度分析
- 时间复杂度：O(1)
- 空间复杂度：O(1)

### 6.2 登录失败锁定算法

#### 算法原理
记录连续登录失败次数，达到阈值后锁定账号一段时间。

#### 伪代码

```
function handleLoginFail(family: FamilyMember): void
  failCount = family.loginFailCount + 1
  family.loginFailCount = failCount
  
  if failCount >= 3 then
    lockUntil = currentTime + 30 minutes
    family.lockUntil = lockUntil
  end if
  
  updateDatabase(family)
  saveAuthLog(family.id, false, "密码错误")
end function

function isAccountLocked(family: FamilyMember): boolean
  if family.lockUntil == null then
    return false
  end if
  
  if currentTime < family.lockUntil then
    return true
  end if
  
  return false
end function
```

#### 复杂度分析
- 时间复杂度：O(1)
- 空间复杂度：O(1)

## 7. UI/UX设计

### 7.1 页面结构

```
登录页面层级：

Index (入口页面)
  ├─> Login (普通用户登录)
  ├─> FamilyLogin (家属登录)
  │     └─> FamilyHome (家属主页)
  ├─> NurseLogin (护士登录)
  │     └─> NurseWorkbench (护士工作台)
  └─> AdminLogin (管理员登录)
        └─> AdminDashboard (管理员仪表盘)
```

### 7.2 组件设计

#### FamilyLogin页面组件

| 组件 | 属性 | 说明 |
|-----|------|------|
| Header | title: '家属登录' | 顶部导航栏 |
| Image | src: $r('app.media.startIcon') | Logo图标 |
| TextInput | type: PhoneNumber | 手机号输入框 |
| TextInput | type: Password | 密码输入框 |
| Button | text: '登录' | 登录按钮 |
| Text | text: '家属登录功能需由用户在"家属管理"中开启' | 提示信息 |
| Loading | - | 加载遮罩 |

#### NurseLogin页面组件

| 组件 | 属性 | 说明 |
|-----|------|------|
| Header | title: '护士登录' | 顶部导航栏 |
| Image | src: $r('app.media.startIcon') | Logo图标 |
| TextInput | type: PhoneNumber | 手机号输入框 |
| TextInput | type: Password | 密码输入框 |
| Button | text: '登录' | 登录按钮 |
| Loading | - | 加载遮罩 |

### 7.3 交互流程

```
家属登录时序图：

用户                FamilyLogin           HttpUtil           后端              数据库
 │                      │                    │                 │                  │
 │─输入手机号和密码────>│                    │                 │                  │
 │                      │                    │                 │                  │
 │─点击登录按钮────────>│                    │                 │                  │
 │                      │─验证输入──────────>│                 │                  │
 │                      │                    │                 │                  │
 │                      │─POST /family/login────────────────>│                  │
 │                      │                    │                 │─查询家属信息────>│
 │                      │                    │                 │<─返回家属数据────│
 │                      │                    │                 │                  │
 │                      │                    │                 │─检查登录权限────>│
 │                      │                    │                 │                  │
 │                      │                    │                 │─验证密码────────>│
 │                      │                    │                 │                  │
 │                      │                    │                 │─生成Token───────>│
 │                      │                    │                 │                  │
 │                      │<─返回Token和家属信息─────────────────│                  │
 │                      │                    │                 │                  │
 │                      │─保存Token─────────>│                 │                  │
 │                      │                    │─持久化存储─────>│                  │
 │                      │                    │                 │                  │
 │<─跳转到FamilyHome────│                    │                 │                  │
 │                      │                    │                 │                  │
```

## 8. 性能设计

### 8.1 性能目标

| 性能指标 | 目标值 | 测量方法 |
|---------|--------|---------|
| 登录响应时间 | < 3秒 | 网络抓包测量 |
| Token验证时间 | < 100ms | 服务端日志 |
| 页面加载时间 | < 2秒 | Performance API |
| Token存储时间 | < 50ms | 本地测量 |

### 8.2 优化策略

#### 前端优化

1. **Token缓存**：优先从AppStorage获取Token，减少持久化读取
2. **预加载**：应用启动时预加载Token和用户信息
3. **防抖处理**：登录按钮添加防抖，防止重复提交

#### 后端优化

1. **索引优化**：family_member表的phone字段建立索引
2. **连接池**：使用数据库连接池，减少连接开销
3. **Token缓存**：可考虑Redis缓存Token验证结果

### 8.3 监控方案

```typescript
// 前端性能监控
console.log('[Performance] Login start:', Date.now());
// ... 登录操作
console.log('[Performance] Login end:', Date.now());
```

```java
// 后端性能监控
long startTime = System.currentTimeMillis();
// ... 登录处理
long endTime = System.currentTimeMillis();
log.info("Login cost: {}ms", endTime - startTime);
```

## 9. 安全设计

### 9.1 数据安全

#### 密码安全
- 使用BCrypt算法加密，每次加密生成不同盐值
- 密码不明文存储，不明文传输
- 密码验证使用BCrypt.matches()方法

#### Token安全
- Token包含过期时间，默认24小时
- Token使用HS256算法签名，防止篡改
- Token不包含敏感信息（如密码）

#### 传输安全
- 使用HTTPS协议传输
- 敏感字段不记录日志

### 9.2 权限控制

#### 登录权限
- 家属登录需检查`login_enabled`字段
- 护士登录需检查`status`字段
- 权限不足时返回明确错误信息

#### Token验证
- 每次请求验证Token有效性
- 验证Token类型与请求角色匹配
- Token过期返回401状态码

### 9.3 安全审计

#### 审计点

| 审计项 | 审计内容 | 审计频率 |
|-------|---------|---------|
| 密码存储 | 检查password字段为BCrypt格式 | 每次部署 |
| Token有效期 | 检查exp声明不超过24小时 | 每次部署 |
| 登录日志 | 记录所有登录尝试 | 实时 |
| 权限检查 | 检查权限验证逻辑 | 代码审查 |

## 10. 测试设计

### 10.1 测试策略

#### 测试重点
1. **功能测试**：验证登录流程的正确性
2. **安全测试**：验证密码加密、Token验证
3. **异常测试**：验证错误处理和提示
4. **性能测试**：验证响应时间满足要求

#### 测试方法
- 单元测试：测试工具类方法
- 集成测试：测试API接口
- E2E测试：测试完整登录流程

### 10.2 测试用例

#### 家属登录测试用例

| 用例ID | 场景 | 输入 | 预期结果 |
|-------|------|------|---------|
| TC-001 | 正常登录 | 正确手机号和密码 | 登录成功，跳转主页 |
| TC-002 | 手机号不存在 | 不存在的手机号 | 提示"手机号不存在" |
| TC-003 | 权限未开启 | login_enabled=0 | 提示"家属登录功能未开启" |
| TC-004 | 密码错误 | 错误密码 | 提示"密码错误"，失败次数+1 |
| TC-005 | 账号锁定 | 连续失败3次 | 提示"账号已锁定" |
| TC-006 | Token过期 | 过期Token | 返回401，跳转登录页 |

#### 护士登录测试用例

| 用例ID | 场景 | 输入 | 预期结果 |
|-------|------|------|---------|
| TC-007 | 正常登录 | 正确手机号和密码 | 登录成功，跳转工作台 |
| TC-008 | 账号禁用 | status=0 | 提示"账号已禁用" |
| TC-009 | 密码错误 | 错误密码 | 提示"密码错误" |

### 10.3 Mock数据

```typescript
// 家属Mock数据
const mockFamilyMember: FamilyInfo = {
  id: 1,
  name: '王秀英',
  phone: '13800138001',
  relation: '配偶',
  age: 47,
  gender: 2,
  healthCondition: '身体健康',
  isEmergencyContact: 1,
  loginEnabled: 1
};

// 护士Mock数据
const mockNurse: NurseInfo = {
  id: 1,
  userId: 5,
  nurseNo: 'N001',
  name: '李护士',
  gender: 0,
  phone: '13900139001',
  department: '内科',
  title: '主管护师',
  certificateNo: 'CERT001',
  workYears: 10,
  avatar: '',
  status: 1
};
```

## 11. 部署设计

### 11.1 环境要求

#### 前端环境
- HarmonyOS SDK 4.0+
- DevEco Studio 4.0+
- Node.js 16+

#### 后端环境
- JDK 11+
- Spring Boot 2.7+
- MySQL 8.0+
- Maven 3.6+

### 11.2 配置管理

#### 前端配置

```typescript
// ApiConstants.ets
export const API_CONFIG = {
  BASE_URL: 'https://api.example.com',
  TIMEOUT: 30000,
  TOKEN_EXPIRE: 24 * 60 * 60 * 1000
};
```

#### 后端配置

```yaml
# application.yml
jwt:
  secret: medical-health-care-2024-secret-key-jwt-token
  expire: 86400000  # 24小时

bcrypt:
  strength: 10  # BCrypt加密强度

login:
  max-fail-count: 3
  lock-minutes: 30
```

### 11.3 发布流程

```
发布步骤：

1. 数据库迁移
   ├─ 执行family_login_upgrade.sql
   └─ 验证表结构

2. 后端部署
   ├─ 编译打包：mvn clean package
   ├─ 停止旧服务
   ├─ 部署新版本
   └─ 启动新服务

3. 前端部署
   ├─ 编译构建：hvigorw assembleHap
   ├─ 签名打包
   └─ 安装到设备

4. 验证测试
   ├─ 执行冒烟测试
   ├─ 验证登录功能
   └─ 监控日志
```

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|-----|------|
| JWT | JSON Web Token，一种开放标准（RFC 7519） |
| BCrypt | 一种密码哈希函数，基于Blowfish加密算法 |
| AppStorage | HarmonyOS应用级状态存储 |
| Preferences | HarmonyOS持久化存储API |
| Token | 认证令牌，用于标识用户身份 |

### 12.2 参考资料

- [HarmonyOS应用开发文档](https://developer.harmonyos.com/)
- [Spring Boot Security文档](https://spring.io/projects/spring-security)
- [JWT最佳实践](https://jwt.io/introduction)
- [BCrypt算法规范](https://en.wikipedia.org/wiki/Bcrypt)

### 12.3 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2026-05-08 | 初始版本创建 | 系统架构师 |
