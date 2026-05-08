# 登录认证系统修复 - 需求规格文档

**版本**: v1.0
**创建日期**: 2026-05-08
**最后更新**: 2026-05-08
**作者**: 系统分析员
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
修复当前系统中家属和护士登录认证存在的问题，确保多角色用户能够正常登录并访问相应功能模块。本需求旨在解决登录过期、权限限制和数据库关联等问题。

### 1.2 业务背景
当前系统存在以下核心问题：
1. **登录过期问题**：家属和护士登录后，系统提示"登录已过期，请重新登录"，导致无法正常使用系统
2. **权限限制问题**：家属登录功能被限制，提示"家属登录功能需由用户在'家属管理'中开启"，影响用户体验
3. **数据库关联问题**：家属数据未正确关联到用户表，导致认证流程失败

这些问题严重影响了系统的可用性和用户满意度，需要系统性地修复登录认证机制。

### 1.3 范围定义

**包含范围**:
- 家属登录认证流程修复
- 护士登录认证流程修复
- Token管理机制优化
- 权限控制逻辑调整
- 数据库表结构验证与修复
- 登录状态持久化改进

**排除范围**:
- 管理员登录功能（已正常工作）
- 普通用户登录功能（已正常工作）
- 新用户注册功能
- 第三方登录集成

## 2. 用户故事

### US-001: 家属独立登录
**作为** 家属用户
**我想要** 使用手机号和密码独立登录系统
**以便于** 查看关联患者的健康信息、接收提醒通知、与医护人员沟通

**验收标准**:
- Given 家属账号已创建且登录权限已开启
- When 家属输入正确的手机号和密码
- Then 系统验证通过，生成有效Token，跳转到家属主页

### US-002: 护士独立登录
**作为** 护士用户
**我想要** 使用手机号和密码登录护士工作台
**以便于** 管理患者信息、执行护理任务、记录工作日志

**验收标准**:
- Given 护士账号已创建且状态正常
- When 护士输入正确的手机号和密码
- Then 系统验证通过，生成有效Token，跳转到护士工作台

### US-003: 登录状态持久化
**作为** 已登录用户（家属或护士）
**我想要** 在应用重启后保持登录状态
**以便于** 无需重复登录，提升使用体验

**验收标准**:
- Given 用户已成功登录且Token未过期
- When 用户关闭并重新打开应用
- Then 系统自动恢复登录状态，无需重新输入凭证

### US-004: 登录权限管理
**作为** 系统用户
**我想要** 在家属管理页面控制家属的登录权限
**以便于** 保护患者隐私，仅授权信任的家属登录

**验收标准**:
- Given 用户已登录且在家属管理页面
- When 用户开启/关闭某家属的登录权限
- Then 系统更新数据库，该家属获得/失去登录资格

## 3. 功能需求

### 3.1 家属登录认证

#### FR-001: 家属登录验证
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When 家属提交登录请求（手机号和密码）, the system shall 验证手机号是否存在、登录权限是否开启、密码是否正确

**验收标准**:
- Given 手机号存在于family_member表
- And login_enabled字段为1
- And 密码验证通过
- When 系统处理登录请求
- Then 返回成功响应，包含Token和家属信息

**依赖**: DR-001（数据库表结构）

#### FR-002: 家属Token生成
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When 家属登录验证通过后, the system shall 生成包含家属ID和手机号的JWT Token，并标记为家属类型Token

**验收标准**:
- Given 家属身份验证通过
- When 生成JWT Token
- Then Token包含familyId、phone、tokenType="family"等声明
- And Token有效期默认为24小时

**依赖**: FR-001

#### FR-003: 家属Token存储
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When 家属Token生成后, the system shall 将Token存储到AppStorage和持久化存储中，使用独立的存储键名

**验收标准**:
- Given Token已生成
- When 存储Token
- Then AppStorage中存储familyToken和familyInfo
- And SettingsUtil持久化存储familyToken
- And 不与普通用户Token混淆

**依赖**: FR-002

### 3.2 护士登录认证

#### FR-004: 护士登录验证
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When 护士提交登录请求（手机号和密码）, the system shall 验证手机号是否存在、账号状态是否正常、密码是否正确

**验收标准**:
- Given 手机号存在于nurse表
- And status字段为1（正常）
- And 密码验证通过
- When 系统处理登录请求
- Then 返回成功响应，包含Token和护士信息

**依赖**: DR-002（数据库表结构）

#### FR-005: 护士Token生成与存储
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When 护士登录验证通过后, the system shall 生成JWT Token并存储到独立存储位置

**验收标准**:
- Given 护士身份验证通过
- When 生成并存储Token
- Then Token包含nurseId、phone、tokenType="nurse"等声明
- And AppStorage中存储nurseToken和nurseInfo
- And 不与其他角色Token混淆

**依赖**: FR-004

### 3.3 Token验证与刷新

#### FR-006: Token有效性验证
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When 系统接收到需要认证的请求时, the system shall 验证Token的有效性、类型匹配性和过期时间

**验收标准**:
- Given 请求携带Token
- When 验证Token
- Then 检查Token签名是否有效
- And 检查Token是否过期
- And 检查Token类型是否匹配请求角色（家属/护士）
- And 返回验证结果

**依赖**: FR-002, FR-005

#### FR-007: 401错误处理优化
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When Token验证失败返回401状态码时, the system shall 根据当前登录角色类型跳转到对应的登录页面

**验收标准**:
- Given Token验证失败（401）
- When 处理401错误
- Then 判断当前登录角色（家属/护士/普通用户）
- And 清除对应Token
- And 跳转到对应登录页面（FamilyLogin/NurseLogin/Login）
- And 显示友好提示信息

**依赖**: FR-006

### 3.4 权限控制

#### FR-008: 家属登录权限控制
**优先级**: P1
**类型**: 功能需求

**需求描述**:
Where 家属登录功能被使用时, the system shall 检查family_member表的login_enabled字段，仅允许已开启权限的家属登录

**验收标准**:
- Given 家属尝试登录
- When 检查login_enabled字段
- Then 若login_enabled=1，允许继续验证
- And 若login_enabled=0或NULL，拒绝登录并提示"家属登录功能未开启"

**依赖**: DR-001

#### FR-009: 登录权限管理接口
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When 用户请求更新家属登录权限时, the system shall 更新family_member表的login_enabled字段，并可选设置默认密码

**验收标准**:
- Given 用户已登录且有权限管理家属
- When 更新家属登录权限
- Then 更新login_enabled字段
- And 若提供默认密码，则加密后更新password字段
- And 返回操作结果

**依赖**: FR-008

### 3.5 登录状态管理

#### FR-010: 登录状态持久化
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When 用户成功登录后, the system shall 将登录状态和Token持久化存储，应用重启后自动恢复

**验收标准**:
- Given 用户已登录
- When 应用关闭并重新启动
- Then 从持久化存储读取Token
- And 验证Token有效性
- And 若有效，恢复登录状态和用户信息
- And 若无效，跳转到登录页面

**依赖**: FR-003, FR-005

#### FR-011: 登出功能
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When 用户执行登出操作时, the system shall 清除所有相关Token和登录状态，跳转到登录页面

**验收标准**:
- Given 用户已登录
- When 执行登出
- Then 清除AppStorage中的Token和用户信息
- And 清除持久化存储中的Token
- And 跳转到对应登录页面

**依赖**: FR-003, FR-005

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 登录响应时间
**指标**: 登录请求响应时间不超过3秒（正常网络条件下）
**测试方法**: 使用网络抓包工具测量从请求发送到响应接收的时间

#### NFR-002: Token验证性能
**指标**: Token验证时间不超过100ms
**测试方法**: 在服务端添加性能监控日志

### 4.2 安全需求

#### NFR-003: 密码加密
**指标**: 所有密码必须使用BCrypt算法加密存储，禁止明文存储
**测试方法**: 检查数据库中的password字段，验证为BCrypt格式

#### NFR-004: Token安全
**指标**: Token有效期不超过24小时，敏感操作需要重新验证
**测试方法**: 检查JWT Token的exp声明

#### NFR-005: 登录失败保护
**指标**: 连续登录失败3次后，账号锁定30分钟
**测试方法**: 模拟连续失败登录，验证锁定机制

### 4.3 可用性需求

#### NFR-006: 错误提示友好性
**指标**: 所有登录失败场景都应有明确的中文提示
**测试方法**: 测试各种失败场景，验证提示信息

### 4.4 兼容性需求

#### NFR-007: 多角色Token隔离
**指标**: 家属、护士、普通用户、管理员的Token互不干扰
**测试方法**: 同时登录不同角色，验证Token独立性

## 5. 数据需求

### 5.1 数据模型

#### 核心实体关系
```
User (用户表)
  ├── id: BIGINT (主键)
  ├── username: VARCHAR(50)
  ├── password: VARCHAR(100) [BCrypt加密]
  ├── phone: VARCHAR(20)
  ├── user_type: TINYINT (0-普通用户, 1-医生)
  └── status: TINYINT

FamilyMember (家属表)
  ├── id: BIGINT (主键)
  ├── user_id: BIGINT (外键 → User.id)
  ├── name: VARCHAR(50)
  ├── phone: VARCHAR(20)
  ├── password: VARCHAR(255) [BCrypt加密]
  ├── login_enabled: TINYINT (0-否, 1-是)
  ├── login_fail_count: INT
  ├── lock_until: DATETIME
  └── last_login_time: DATETIME

Nurse (护士表)
  ├── id: BIGINT (主键)
  ├── user_id: BIGINT (外键 → User.id)
  ├── nurse_no: VARCHAR(50)
  ├── name: VARCHAR(50)
  ├── phone: VARCHAR(20)
  ├── status: TINYINT
  └── department: VARCHAR(50)

FamilyAuthLog (家属认证日志表)
  ├── id: BIGINT (主键)
  ├── family_id: BIGINT (外键 → FamilyMember.id)
  ├── login_time: DATETIME
  ├── login_result: TINYINT (0-失败, 1-成功)
  └── fail_reason: VARCHAR(200)
```

### 5.2 数据存储

#### DR-001: 家属表结构要求
family_member表必须包含以下字段：
- `password`: 存储BCrypt加密后的密码
- `login_enabled`: 标识是否允许登录（0/1）
- `login_fail_count`: 记录连续登录失败次数
- `lock_until`: 账号锁定截止时间
- `last_login_time`: 最后成功登录时间

#### DR-002: 护士表结构要求
nurse表必须包含以下字段：
- `phone`: 用于登录的手机号
- `password`: 存储BCrypt加密后的密码
- `status`: 账号状态（0-禁用, 1-正常）

### 5.3 数据安全

- 所有密码字段必须使用BCrypt算法加密
- Token存储时需考虑安全性，避免泄露
- 敏感信息（如身份证号）需脱敏显示

## 6. 接口需求

### 6.1 用户界面

#### IR-001: 家属登录页面
- 显示手机号输入框（支持PhoneNumber类型）
- 显示密码输入框（支持显示/隐藏切换）
- 显示登录按钮
- 显示错误提示信息
- 显示"家属登录功能需由用户在'家属管理'中开启"提示

#### IR-002: 护士登录页面
- 显示手机号输入框
- 显示密码输入框
- 显示登录按钮
- 显示返回按钮

### 6.2 系统接口

#### IR-003: 家属登录API
```
POST /family/login
Request: { phone: string, password: string }
Response: {
  code: 200,
  msg: "登录成功",
  data: {
    token: string,
    familyInfo: FamilyMember,
    relatedUser: User
  }
}
```

#### IR-004: 护士登录API
```
POST /nurse/login
Request: { phone: string, password: string }
Response: {
  code: 200,
  msg: "登录成功",
  data: {
    token: string,
    nurseInfo: Nurse,
    relatedUser: User
  }
}
```

#### IR-005: 更新家属登录权限API
```
PUT /family/{familyId}/login-enabled
Request: { loginEnabled: number, defaultPassword?: string }
Response: { code: 200, msg: "操作成功" }
```

## 7. 约束条件

### 7.1 技术约束

- 前端使用HarmonyOS ArkTS开发
- 后端使用Spring Boot + MyBatis Plus
- 数据库使用MySQL 8.0+
- Token使用JWT标准（HS256算法）
- 密码加密使用BCrypt算法

### 7.2 业务约束

- 家属登录权限默认关闭，需用户手动开启
- 紧急联系人可自动开启登录权限
- 护士账号由管理员创建，不可自行注册
- Token有效期24小时，过期需重新登录

### 7.3 时间约束

- 需求评审：1天
- 设计评审：1天
- 开发实现：3天
- 测试验证：2天
- 总计：7天

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 家属登录验证 | 手机号、权限、密码验证通过 | P0 | 待验证 |
| FR-002 | 家属Token生成 | 生成包含家属信息的JWT Token | P0 | 待验证 |
| FR-003 | 家属Token存储 | 独立存储，不与其他角色混淆 | P0 | 待验证 |
| FR-004 | 护士登录验证 | 手机号、状态、密码验证通过 | P0 | 待验证 |
| FR-005 | 护士Token生成与存储 | 独立生成和存储Token | P0 | 待验证 |
| FR-006 | Token有效性验证 | 验证签名、过期、类型匹配 | P0 | 待验证 |
| FR-007 | 401错误处理优化 | 根据角色跳转对应登录页 | P0 | 待验证 |
| FR-008 | 家属登录权限控制 | 检查login_enabled字段 | P1 | 待验证 |
| FR-009 | 登录权限管理接口 | 更新权限和默认密码 | P1 | 待验证 |
| FR-010 | 登录状态持久化 | 应用重启后自动恢复 | P0 | 待验证 |
| FR-011 | 登出功能 | 清除Token和状态 | P1 | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| JWT | JSON Web Token，一种开放标准（RFC 7519），用于安全传输信息 |
| BCrypt | 一种密码哈希函数，基于Blowfish加密算法 |
| Token | 认证令牌，用于标识用户身份和会话状态 |
| AppStorage | HarmonyOS应用级状态存储 |
| SettingsUtil | 持久化存储工具类 |
| 401 | HTTP状态码，表示未授权（Unauthorized） |

## 10. 附录

### 10.1 参考资料
- HarmonyOS应用开发文档
- Spring Boot Security文档
- JWT最佳实践指南
- BCrypt算法规范

### 10.2 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2026-05-08 | 初始版本创建 | 系统分析员 |
