# 医院系统数据修复 - 需求规格文档

**版本**: v1.0
**创建日期**: 2025-01-15
**最后更新**: 2025-01-15
**作者**: System
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
本修复任务旨在解决医院系统中的多个前后端数据不匹配和功能缺失问题，包括医院筛选条件不一致、护士数据查询失败、家属中心数据同步缺失等核心问题，确保系统各端数据一致性和功能完整性。

### 1.2 业务背景
当前医院系统存在以下严重问题：
1. 医院前端筛选条件与后端数据库存储值不匹配，导致筛选功能完全失效
2. 护士列表无法加载，SQL查询引用不存在的字段导致查询失败
3. 家属中心与患者端数据不同步，部分功能无数据显示
4. 缺乏统一的数据字典和前后端数据契约，导致多处数据不一致

这些问题严重影响用户体验，需要紧急修复。

### 1.3 范围定义

**包含范围**:
- 修复医院筛选功能，统一前后端数据契约
- 修复护士数据查询，纠正SQL语句错误
- 完善家属中心数据同步机制
- 建立统一数据字典，防止类似问题再次发生

**排除范围**:
- 不涉及数据库表结构变更
- 不涉及新增功能开发
- 不涉及性能优化

## 2. 用户故事

### US-001: 医院筛选功能正常使用
**作为** 患者
**我想要** 能够按照医院等级筛选医院列表
**以便于** 快速找到符合需求的医院

**验收标准**:
- Given 患者进入医院列表页面
- When 点击"三级甲等"筛选标签
- Then 列表显示所有三级甲等医院，数量正确

### US-002: 护士列表正常加载
**作为** 患者
**我想要** 能够查看护士列表并选择护士进行聊天
**以便于** 与护士沟通病情

**验收标准**:
- Given 患者进入护士列表页面
- When 页面加载完成
- Then 显示所有可用护士信息，包括姓名、科室、职称等

### US-003: 家属中心数据显示完整
**作为** 家属
**我想要** 能够查看关联患者的完整健康信息
**以便于** 了解患者健康状况

**验收标准**:
- Given 家属已登录并关联患者
- When 进入家属中心首页
- Then 显示患者基本信息、健康记录、用药情况等完整数据

## 3. 功能需求

### 3.1 医院筛选修复

#### FR-001: 统一医院等级数据契约
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall establish a unified data contract for hospital levels between frontend and backend, ensuring consistent data representation.

**验收标准**:
- Given 前端筛选标签为"三级甲等"
- When 后端查询数据库
- Then 数据库level字段值为"三级甲等医院"时能够正确匹配
- Given 前端筛选标签为"综合医院"
- When 后端查询数据库
- Then 数据库level字段值为"综合医院"时能够正确匹配

**依赖**: 无

#### FR-002: 修复医院筛选查询逻辑
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When user selects a hospital level filter, the system shall query hospitals using fuzzy matching or exact matching based on the unified data contract.

**验收标准**:
- Given 用户选择"三级甲等"筛选
- When 后端执行查询
- Then 返回所有level字段包含"三级甲等"的医院
- Given 用户选择"综合医院"筛选
- When 后端执行查询
- Then 返回所有level字段为"综合医院"的医院

**依赖**: FR-001

### 3.2 护士数据查询修复

#### FR-003: 修复护士SQL查询语句
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall correct the SQL query statement to remove reference to non-existent gender field in nurse table.

**验收标准**:
- Given 护士表存在数据但不包含gender字段
- When 执行护士列表查询
- Then SQL查询不包含gender字段引用
- Then 查询成功返回护士列表

**依赖**: 无

#### FR-004: 护士列表正常显示
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When nurse list query succeeds, the system shall display nurse information including name, department, title, work years, and avatar.

**验收标准**:
- Given 护士列表查询成功
- When 前端渲染护士列表
- Then 显示护士姓名、科室、职称、工作年限、头像等信息
- Then 列表项可点击进入聊天页面

**依赖**: FR-003

### 3.3 家属中心数据同步

#### FR-005: 家属中心加载患者数据
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When family member logs in, the system shall load related patient information including basic info, health records, and medication data.

**验收标准**:
- Given 家属已登录并关联患者
- When 进入家属中心页面
- Then 显示患者姓名、关系、联系方式
- Then 显示患者健康记录摘要
- Then 显示患者用药情况

**依赖**: 无

#### FR-006: 家属查看患者详情
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When family member clicks to view patient details, the system shall display complete patient health information with proper authorization.

**验收标准**:
- Given 家属有查看权限
- When 点击"查看详情"按钮
- Then 跳转到患者健康记录页面
- Then 显示患者完整健康数据

**依赖**: FR-005

### 3.4 数据字典建设

#### FR-007: 建立医院等级数据字典
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall establish a data dictionary for hospital levels, defining all possible values and their mappings between frontend display and backend storage.

**验收标准**:
- Given 数据字典文件存在
- When 查询医院等级映射
- Then 返回前端显示值与后端存储值的对应关系
- Then 包含所有医院等级类型：三级甲等医院、综合医院、社区医院、专科医院、卫生院、保健机构、诊所

**依赖**: 无

#### FR-008: 建立护士数据模型规范
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall define a standardized nurse data model, specifying all required fields and their types to prevent SQL query errors.

**验收标准**:
- Given 护士数据模型定义存在
- When 查询护士信息
- Then 返回数据包含id、userId、nurseNo、name、phone、department、title、workYears、avatar、status字段
- Then 不包含不存在的gender字段

**依赖**: 无

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 查询响应时间
**指标**: 医院筛选查询响应时间 < 1秒
**测试方法**: 模拟用户筛选操作，测量从点击筛选到列表更新的时间

#### NFR-002: 护士列表加载时间
**指标**: 护士列表加载时间 < 500ms
**测试方法**: 测量从进入护士列表页面到数据显示完成的时间

### 4.2 兼容性需求

#### NFR-003: 数据库兼容性
**指标**: 修复后的SQL语句兼容现有数据库表结构
**测试方法**: 在现有数据库环境执行查询，验证无错误

### 4.3 可维护性需求

#### NFR-004: 代码可读性
**指标**: 修复后的代码添加清晰的注释说明数据映射关系
**测试方法**: 代码审查

## 5. 数据需求

### 5.1 数据模型

**医院数据模型**:
```typescript
interface Hospital {
  id: number;
  name: string;
  address: string;
  phone: string;
  level: string; // 数据库存储值：三级甲等医院、综合医院等
  department: string;
  description: string;
}
```

**护士数据模型**:
```typescript
interface Nurse {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  phone: string;
  department: string;
  title: string;
  workYears: number;
  avatar: string;
  status: number;
}
```

**家属信息模型**:
```typescript
interface FamilyInfo {
  id: number;
  name: string;
  phone: string;
  relation: string;
  age?: number;
  gender?: number;
  healthCondition?: string;
  isEmergencyContact: number;
  userId: number;
}
```

### 5.2 数据字典

**医院等级映射表**:
| 前端显示值 | 后端存储值 |
|-----------|-----------|
| 三级甲等 | 三级甲等医院 |
| 综合医院 | 综合医院 |
| 社区医院 | 社区医院 |
| 专科医院 | 专科医院 |
| 卫生院 | 卫生院 |
| 保健机构 | 保健机构 |
| 诊所 | 诊所 |

### 5.3 数据安全

**安全要求**:
- 护士数据查询需验证用户权限
- 家属查看患者数据需验证授权关系
- 敏感信息（如手机号）需脱敏显示

## 6. 接口需求

### 6.1 用户界面

**医院筛选界面**:
- 筛选标签横向排列，支持点击切换
- 当前选中标签高亮显示
- 显示当前筛选结果数量

**护士列表界面**:
- 显示护士头像、姓名、工号
- 显示科室、职称、工作年限
- 支持搜索护士姓名或工号
- 列表项可点击进入聊天

**家属中心界面**:
- 显示家属基本信息卡片
- 显示关联患者信息卡片
- 功能菜单列表展示

### 6.2 系统接口

**医院列表API**:
```
GET /hospital/list
GET /hospital/page?level={level}&page=1&size=500
```

**护士列表API**:
```
GET /nurse/list?keyword={keyword}
```

**家属信息API**:
```
GET /family/info
GET /user/{userId}
```

## 7. 约束条件

### 7.1 技术约束

- 前端框架：ArkUI（HarmonyOS）
- 后端框架：Node.js + Express
- 数据库：MySQL
- 不允许修改数据库表结构

### 7.2 业务约束

- 医院等级数据必须与现有数据库值匹配
- 护士查询必须基于现有表结构
- 家属数据需符合隐私保护要求

### 7.3 时间约束

- 修复完成时间：2个工作日
- 测试验证时间：1个工作日

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 统一医院等级数据契约 | 前后端数据值正确匹配 | P0 | 待验证 |
| FR-002 | 修复医院筛选查询逻辑 | 筛选功能正常工作 | P0 | 待验证 |
| FR-003 | 修复护士SQL查询语句 | 移除不存在的gender字段 | P0 | 待验证 |
| FR-004 | 护士列表正常显示 | 显示完整护士信息 | P0 | 待验证 |
| FR-005 | 家属中心加载患者数据 | 显示患者基本信息和健康数据 | P0 | 待验证 |
| FR-006 | 家属查看患者详情 | 跳转并显示完整健康数据 | P1 | 待验证 |
| FR-007 | 建立医院等级数据字典 | 定义完整的映射关系 | P1 | 待验证 |
| FR-008 | 建立护士数据模型规范 | 定义标准数据模型 | P1 | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| 数据契约 | 前后端之间约定的数据格式和取值范围 |
| 数据字典 | 系统中所有数据项的定义和映射关系 |
| 模糊匹配 | 查询时使用LIKE关键字进行部分匹配 |
| 精确匹配 | 查询时使用=进行完全匹配 |

## 10. 附录

### 10.1 参考资料

- HospitalPage.ets - 医院列表页面代码
- FamilyNurseListPage.ets - 家属护士列表页面代码
- FamilyHome.ets - 家属中心页面代码
- ApiConstants.ets - API常量定义

### 10.2 变更历史

| 版本 | 日期 | 变更内容 | 变更人 |
|-----|------|---------|--------|
| v1.0 | 2025-01-15 | 初始版本，完成需求规格文档 | System |
