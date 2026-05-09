# 护士端功能 - 需求规格文档

**版本**: v1.0
**创建日期**: 2025-01-09
**最后更新**: 2025-01-09
**作者**: SDD Agent
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
为现有的医疗健康护理系统增加护士端功能模块，实现护士独立登录认证、信息管理和专属工作界面，与现有系统架构保持一致，为护士提供便捷的移动端工作支持。

### 1.2 业务背景
当前系统已实现患者端、医生端、家属端和管理员端功能，但缺少护士端支持。护士作为医疗护理工作的核心执行者，需要独立的系统入口来：
- 快速查看负责患者信息
- 记录护理执行情况
- 接收和执行医嘱
- 与医生、家属进行沟通

### 1.3 范围定义

**包含范围**:
- 护士数据库表设计与创建
- 护士登录认证功能（前后端）
- 护士信息管理接口
- 护士端独立登录页面
- 护士端专属工作台页面
- 与现有用户体系的集成

**排除范围**:
- 护士排班管理功能（后续扩展）
- 护理文书详细编辑功能（后续扩展）
- 护士绩效统计功能（后续扩展）

## 2. 用户故事

### US-001: 护士账号登录
**作为** 护士
**我想要** 使用我的工号和密码登录系统
**以便于** 访问我的专属工作界面和患者信息

**验收标准**:
- Given 护士已注册账号
- When 输入正确的工号和密码并点击登录
- Then 系统验证通过，跳转到护士端工作台页面

### US-002: 查看个人信息
**作为** 护士
**我想要** 查看和编辑我的个人信息
**以便于** 保持信息的准确性和时效性

**验收标准**:
- Given 护士已登录系统
- When 进入个人中心页面
- Then 显示护士的姓名、工号、科室、职称等信息，且可编辑部分字段

### US-003: 访问工作台
**作为** 护士
**我想要** 登录后看到清晰的工作台界面
**以便于** 快速了解今日工作安排和重要提醒

**验收标准**:
- Given 护士已登录系统
- When 进入工作台页面
- Then 显示今日待办、患者列表、重要提醒等模块

## 3. 功能需求

### 3.1 数据库设计需求

#### FR-001: 创建护士数据表
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a nurse table with complete fields including id, user_id, nurse_number, real_name, phone, department, title, avatar, status, create_time, update_time, is_deleted

**验收标准**:
- Given 数据库初始化脚本执行
- When 创建nurse表
- Then 表结构包含所有必需字段，user_id作为外键关联user表，主键自增，索引正确创建

**依赖**: 无

#### FR-002: 护士表与用户表关联
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall establish foreign key relationship between nurse.user_id and user.id to maintain data integrity

**验收标准**:
- Given nurse表和user表已创建
- When 插入护士记录
- Then user_id必须对应user表中存在的记录，删除用户时级联处理护士记录

**依赖**: FR-001

### 3.2 后端API需求

#### FR-003: 护士登录认证接口
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When nurse submits login credentials, the system shall validate nurse_number and password, generate JWT token, and return nurse info with token

**验收标准**:
- Given 护士账号存在且状态正常
- When POST /nurse/login with correct credentials
- Then 返回200状态码，包含token、护士ID、姓名、科室等信息

**依赖**: FR-001, FR-002

#### FR-004: 获取护士信息接口
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When nurse requests profile, the system shall return complete nurse information including department and title

**验收标准**:
- Given 护士已登录且token有效
- When GET /nurse/info with valid token
- Then 返回护士完整信息，不包含敏感字段如密码

**依赖**: FR-003

#### FR-005: 更新护士信息接口
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When nurse updates profile, the system shall validate input and update allowed fields only

**验收标准**:
- Given 护士已登录
- When PUT /nurse/info with valid data
- Then 更新成功返回200，只更新允许修改的字段（如头像、手机号）

**依赖**: FR-004

#### FR-006: 护士注册接口
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When admin registers a new nurse, the system shall create user record and nurse record with validated data

**验收标准**:
- Given 管理员已登录
- When POST /nurse/register with complete nurse data
- Then 创建user表记录和nurse表记录，返回护士ID，初始状态为待激活

**依赖**: FR-001, FR-002

### 3.3 前端页面需求

#### FR-007: 护士登录页面
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a dedicated nurse login page with nurse_number and password input fields, following existing UI design patterns

**验收标准**:
- Given 用户访问护士登录页面
- When 页面加载完成
- Then 显示工号输入框、密码输入框、登录按钮，样式与现有登录页面一致

**依赖**: 无

#### FR-008: 登录页面入口
**优先级**: P0
**类型**: 功能需求

**需求描述**:
Where the main login page is displayed, the system shall provide a nurse login entry button for navigation

**验收标准**:
- Given 用户在主登录页面
- When 页面显示其他登录方式区域
- Then 包含"护士登录"按钮，点击跳转到护士登录页面

**依赖**: FR-007

#### FR-009: 护士工作台页面
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When nurse logs in successfully, the system shall display a dedicated nurse dashboard with work modules

**验收标准**:
- Given 护士登录成功
- When 跳转到工作台页面
- Then 显示护士专属界面，包含患者列表、今日任务、消息通知等模块

**依赖**: FR-003, FR-007

#### FR-010: 护士个人中心页面
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall provide a nurse profile page for viewing and editing personal information

**验收标准**:
- Given 护士已登录
- When 进入个人中心
- Then 显示护士头像、姓名、工号、科室、职称等信息，支持编辑部分字段

**依赖**: FR-004

### 3.4 系统集成需求

#### FR-011: 用户类型扩展
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall extend user_type field to support nurse type (user_type = 3) for unified user management

**验收标准**:
- Given 用户表存在user_type字段
- When 创建护士账号
- Then user_type设置为3，系统正确识别护士身份

**依赖**: FR-001, FR-002

#### FR-012: 路由配置集成
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall add nurse pages to route configuration for proper navigation

**验收标准**:
- Given 路由配置文件存在
- When 添加护士页面路由
- Then 护士登录页、工作台页等路由正确配置，可正常跳转

**依赖**: FR-007, FR-009

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 登录响应时间
**指标**: 护士登录接口响应时间 < 500ms（正常网络环境）
**测试方法**: 使用Postman或JMeter进行接口性能测试

#### NFR-002: 页面加载性能
**指标**: 护士端页面首屏加载时间 < 2s
**测试方法**: 使用DevTools Profiler测量页面加载时间

### 4.2 安全需求

#### NFR-003: 密码安全存储
**指标**: 护士密码使用BCrypt加密存储，强度因子≥10
**测试方法**: 检查数据库密码字段，验证为BCrypt哈希值

#### NFR-004: Token安全
**指标**: JWT Token有效期24小时，包含用户类型标识，使用HS256算法签名
**测试方法**: 解析Token验证payload和签名算法

#### NFR-005: 接口权限控制
**指标**: 护士接口需要Token认证，未认证返回401状态码
**测试方法**: 不带Token访问护士接口，验证返回401

### 4.3 兼容性需求

#### NFR-006: 设备兼容性
**指标**: 护士端页面在手机、平板设备上正常显示
**测试方法**: 在不同尺寸设备上测试页面布局

#### NFR-007: 系统版本兼容
**指标**: 支持HarmonyOS 3.0及以上版本
**测试方法**: 在不同HarmonyOS版本设备上测试

### 4.4 可用性需求

#### NFR-008: 界面一致性
**指标**: 护士端UI风格与现有系统保持一致
**测试方法**: 对比护士端与其他端页面，验证颜色、字体、布局一致

#### NFR-009: 错误提示友好性
**指标**: 所有错误场景提供明确的中文提示信息
**测试方法**: 模拟各种错误场景，验证提示信息清晰准确

## 5. 数据需求

### 5.1 数据模型

**护士实体（Nurse）**:
```
- id: Long (主键，自增)
- userId: Long (外键，关联user.id)
- nurseNumber: String (工号，唯一，非空)
- realName: String (真实姓名，非空)
- phone: String (手机号，11位)
- department: String (所属科室)
- title: String (职称，如：护士、护师、主管护师)
- avatar: String (头像URL)
- status: Integer (状态：0-待激活，1-正常，2-禁用)
- createTime: Date (创建时间)
- updateTime: Date (更新时间)
- isDeleted: Integer (逻辑删除标记)
```

**用户类型扩展**:
```
user_type字段值定义：
- 0: 普通用户/患者
- 1: 医生
- 2: 家属
- 3: 护士 (新增)
- 9: 管理员
```

### 5.2 数据存储

- 护士信息存储在MySQL数据库的`nurse`表中
- 用户认证信息存储在`user`表中
- 护士与用户通过`user_id`外键关联
- 采用逻辑删除机制，不物理删除数据

### 5.3 数据安全

- 护士密码在user表中使用BCrypt加密存储
- 敏感信息（如身份证号）脱敏显示
- 数据库连接使用加密通道
- 定期备份护士数据

## 6. 接口需求

### 6.1 用户界面

**护士登录页面**:
- 路径: `pages/NurseLogin`
- 样式: 参照现有Login.ets和FamilyLogin.ets
- 包含: 工号输入、密码输入、登录按钮、返回按钮

**护士工作台页面**:
- 路径: `pages/NurseHomePage`
- 样式: 参照DoctorHomePage.ets
- 包含: 顶部导航、患者列表、今日任务、消息通知、个人中心入口

**护士个人中心页面**:
- 路径: `pages/NurseProfile`
- 样式: 参照Profile.ets
- 包含: 头像、基本信息、编辑功能、退出登录

### 6.2 系统接口

**护士登录接口**:
```
POST /nurse/login
Request: { nurseNumber: string, password: string }
Response: { 
  code: 200, 
  data: { 
    token: string, 
    nurseId: number, 
    realName: string, 
    department: string,
    title: string 
  } 
}
```

**获取护士信息接口**:
```
GET /nurse/info
Header: Authorization: Bearer {token}
Response: { 
  code: 200, 
  data: { 
    id: number, 
    nurseNumber: string, 
    realName: string, 
    phone: string, 
    department: string, 
    title: string, 
    avatar: string 
  } 
}
```

**更新护士信息接口**:
```
PUT /nurse/info
Header: Authorization: Bearer {token}
Request: { phone?: string, avatar?: string }
Response: { code: 200, message: "更新成功" }
```

**护士注册接口（管理员调用）**:
```
POST /nurse/register
Header: Authorization: Bearer {adminToken}
Request: { 
  nurseNumber: string, 
  password: string, 
  realName: string, 
  phone: string, 
  department: string, 
  title: string 
}
Response: { code: 200, data: { nurseId: number } }
```

## 7. 约束条件

### 7.1 技术约束

- 前端框架: HarmonyOS ArkTS (Stage模型)
- 后端框架: Spring Boot + MyBatis Plus
- 数据库: MySQL 8.0+
- 认证方式: JWT Token
- 密码加密: BCrypt
- 遵循现有项目架构和代码规范

### 7.2 业务约束

- 护士工号唯一，不可重复
- 护士账号需管理员创建，不可自助注册
- 护士登录后只能查看和操作自己负责的患者信息
- 护士信息修改需记录操作日志

### 7.3 时间约束

- 数据库设计: 1天
- 后端开发: 2天
- 前端开发: 2天
- 联调测试: 1天
- 总计: 6个工作日

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 创建护士数据表 | 表结构完整，字段齐全，索引正确 | P0 | 待验证 |
| FR-002 | 护士表与用户表关联 | 外键约束有效，级联处理正确 | P0 | 待验证 |
| FR-003 | 护士登录认证接口 | 正确验证并返回token和护士信息 | P0 | 待验证 |
| FR-004 | 获取护士信息接口 | 返回完整信息，不含敏感字段 | P0 | 待验证 |
| FR-005 | 更新护士信息接口 | 只更新允许字段，返回成功 | P1 | 待验证 |
| FR-006 | 护士注册接口 | 创建user和nurse记录，返回ID | P1 | 待验证 |
| FR-007 | 护士登录页面 | 显示工号密码输入，样式一致 | P0 | 待验证 |
| FR-008 | 登录页面入口 | 主登录页包含护士登录按钮 | P0 | 待验证 |
| FR-009 | 护士工作台页面 | 显示工作模块，布局合理 | P0 | 待验证 |
| FR-010 | 护士个人中心页面 | 显示个人信息，支持编辑 | P1 | 待验证 |
| FR-011 | 用户类型扩展 | user_type=3正确识别护士 | P0 | 待验证 |
| FR-012 | 路由配置集成 | 护士页面路由正确配置 | P0 | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| 护士工号 | 护士在医院的唯一标识编号，用于系统登录 |
| JWT | JSON Web Token，用于身份认证的令牌 |
| BCrypt | 一种密码哈希算法，用于安全存储密码 |
| ArkTS | HarmonyOS的应用开发语言，基于TypeScript |
| Stage模型 | HarmonyOS的应用模型，提供更好的性能和能力 |
| MyBatis Plus | MyBatis的增强工具，简化数据库操作 |

## 10. 附录

### 10.1 参考资料

- 现有登录页面实现: `entry/src/main/ets/pages/Login.ets`
- 家属登录实现: `entry/src/main/ets/pages/FamilyLogin.ets`
- 医生工作台实现: `entry/src/main/ets/pages/DoctorHomePage.ets`
- 用户实体定义: `src/main/java/com/example/medical/entity/User.java`
- 后端认证实现: `src/main/java/com/example/medical/controller/FamilyAuthController.java`

### 10.2 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-09 | 初始版本，定义护士端功能需求 | SDD Agent |
