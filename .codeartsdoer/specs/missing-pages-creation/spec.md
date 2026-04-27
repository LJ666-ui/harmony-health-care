# 缺失页面创建 - 需求规格文档

**版本**: v1.0
**创建日期**: 2025-01-14
**最后更新**: 2025-01-14
**作者**: SDD Agent
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
鸿蒙健康护理应用首页存在9个快捷服务功能跳转失败的问题，原因是目标页面文件不存在。本需求旨在创建这9个缺失的页面文件并完成路由注册，确保用户能够正常访问这些服务功能。

### 1.2 业务背景
应用首页提供了快捷服务入口，用户点击服务图标时应跳转到对应功能页面。当前9个服务功能因页面文件缺失导致跳转失败，严重影响用户体验和功能完整性。需要补充这些页面以完善应用功能闭环。

### 1.3 范围定义

**包含范围**:
- 创建9个缺失的页面文件（ReportPage、MedicationPage、ConsultationPage、EmergencyPage、FamilyDoctorPage、InsurancePage、RehabilitationPage、AIAssistantPage、DistributedCollaborationPage）
- 在main_pages.json中注册新页面路由
- 实现页面的基础UI框架和导航功能
- 参考现有类似功能页面的设计风格

**排除范围**:
- 页面内复杂业务逻辑的完整实现（仅实现基础框架）
- 后端API接口开发
- 数据库设计和数据迁移
- 第三方服务集成

## 2. 用户故事

### US-001: 体检报告页面访问
**作为** 用户
**我想要** 从首页点击"体检报告"服务图标
**以便于** 查看我的体检报告列表和详情

**验收标准**:
- Given 用户在应用首页
- When 用户点击"体检报告"服务图标
- Then 系统成功跳转到ReportPage页面并显示报告列表

### US-002: 用药提醒页面访问
**作为** 用户
**我想要** 从首页点击"用药提醒"服务图标
**以便于** 管理我的用药提醒计划

**验收标准**:
- Given 用户在应用首页
- When 用户点击"用药提醒"服务图标
- Then 系统成功跳转到MedicationPage页面并显示提醒管理界面

### US-003: 在线问诊页面访问
**作为** 用户
**我想要** 从首页点击"在线问诊"服务图标
**以便于** 选择科室和医生进行在线咨询

**验收标准**:
- Given 用户在应用首页
- When 用户点击"在线问诊"服务图标
- Then 系统成功跳转到ConsultationPage页面并显示科室选择界面

### US-004: 急救指南页面访问
**作为** 用户
**我想要** 从首页点击"急救指南"服务图标
**以便于** 学习急救知识和处理紧急情况

**验收标准**:
- Given 用户在应用首页
- When 用户点击"急救指南"服务图标
- Then 系统成功跳转到EmergencyPage页面并显示急救知识列表

### US-005: 家庭医生页面访问
**作为** 用户
**我想要** 从首页点击"家庭医生"服务图标
**以便于** 查看家庭医生服务和签约管理

**验收标准**:
- Given 用户在应用首页
- When 用户点击"家庭医生"服务图标
- Then 系统成功跳转到FamilyDoctorPage页面并显示家庭医生服务

### US-006: 医保服务页面访问
**作为** 用户
**我想要** 从首页点击"医保服务"服务图标
**以便于** 查询医保信息和报销记录

**验收标准**:
- Given 用户在应用首页
- When 用户点击"医保服务"服务图标
- Then 系统成功跳转到InsurancePage页面并显示医保服务界面

### US-007: 康复训练页面访问
**作为** 用户
**我想要** 从首页点击"康复训练"服务图标
**以便于** 查看康复训练计划和记录

**验收标准**:
- Given 用户在应用首页
- When 用户点击"康复训练"服务图标
- Then 系统成功跳转到RehabilitationPage页面并显示训练计划

### US-008: AI助手页面访问
**作为** 用户
**我想要** 从首页点击"AI助手"服务图标
**以便于** 与AI智能助手进行对话咨询

**验收标准**:
- Given 用户在应用首页
- When 用户点击"AI助手"服务图标
- Then 系统成功跳转到AIAssistantPage页面并显示AI对话界面

### US-009: 跨院协同页面访问
**作为** 用户
**我想要** 从首页点击"跨院协同"服务图标
**以便于** 管理跨院数据协同和病历共享

**验收标准**:
- Given 用户在应用首页
- When 用户点击"跨院协同"服务图标
- Then 系统成功跳转到DistributedCollaborationPage页面并显示协同管理界面

## 3. 功能需求

### 3.1 页面创建需求

#### FR-001: ReportPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create ReportPage.ets file in pages directory with basic UI structure for displaying medical examination reports.

**验收标准**:
- Given pages目录存在
- When 创建ReportPage.ets文件
- Then 文件包含@Entry和@Component装饰器、页面标题"体检报告"、报告列表展示区域、返回导航功能

**依赖**: 无

#### FR-002: MedicationPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create MedicationPage.ets file in pages directory with medication reminder management interface.

**验收标准**:
- Given pages目录存在
- When 创建MedicationPage.ets文件
- Then 文件包含页面标题"用药提醒"、提醒列表展示、添加/编辑提醒入口、返回导航功能

**依赖**: 无

#### FR-003: ConsultationPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create ConsultationPage.ets file in pages directory with online consultation entry interface.

**验收标准**:
- Given pages目录存在
- When 创建ConsultationPage.ets文件
- Then 文件包含页面标题"在线问诊"、科室选择列表、医生推荐区域、返回导航功能

**依赖**: 无

#### FR-004: EmergencyPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create EmergencyPage.ets file in pages directory with emergency guide knowledge display.

**验收标准**:
- Given pages目录存在
- When 创建EmergencyPage.ets文件
- Then 文件包含页面标题"急救指南"、急救知识分类列表、搜索功能、返回导航功能

**依赖**: 无

#### FR-005: FamilyDoctorPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create FamilyDoctorPage.ets file in pages directory with family doctor service management.

**验收标准**:
- Given pages目录存在
- When 创建FamilyDoctorPage.ets文件
- Then 文件包含页面标题"家庭医生"、医生信息展示、签约管理入口、返回导航功能

**依赖**: 无

#### FR-006: InsurancePage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create InsurancePage.ets file in pages directory with medical insurance service interface.

**验收标准**:
- Given pages目录存在
- When 创建InsurancePage.ets文件
- Then 文件包含页面标题"医保服务"、医保查询入口、报销记录列表、返回导航功能

**依赖**: 无

#### FR-007: RehabilitationPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create RehabilitationPage.ets file in pages directory with rehabilitation training plan display.

**验收标准**:
- Given pages目录存在
- When 创建RehabilitationPage.ets文件
- Then 文件包含页面标题"康复训练"、训练计划列表、训练记录展示、返回导航功能

**依赖**: 无

#### FR-008: AIAssistantPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create AIAssistantPage.ets file in pages directory with AI assistant chat interface.

**验收标准**:
- Given pages目录存在
- When 创建AIAssistantPage.ets文件
- Then 文件包含页面标题"AI助手"、对话消息列表、输入框和发送按钮、返回导航功能

**依赖**: 无

#### FR-009: DistributedCollaborationPage页面创建
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall create DistributedCollaborationPage.ets file in pages directory with cross-hospital collaboration interface.

**验收标准**:
- Given pages目录存在
- When 创建DistributedCollaborationPage.ets文件
- Then 文件包含页面标题"跨院协同"、协同记录列表、病历共享入口、返回导航功能

**依赖**: 无

### 3.2 路由注册需求

#### FR-010: 路由配置更新
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When all 9 page files are created, the system shall register them in main_pages.json routing configuration file.

**验收标准**:
- Given 9个页面文件已创建
- When 更新main_pages.json文件
- Then 文件包含所有9个新页面的路由配置项（pages/ReportPage、pages/MedicationPage、pages/ConsultationPage、pages/EmergencyPage、pages/FamilyDoctorPage、pages/InsurancePage、pages/RehabilitationPage、pages/AIAssistantPage、pages/DistributedCollaborationPage）

**依赖**: FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-008, FR-009

### 3.3 页面导航需求

#### FR-011: 页面返回导航
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When user clicks the back button on any of the 9 new pages, the system shall navigate back to the previous page.

**验收标准**:
- Given 用户在任意新建页面
- When 用户点击返回按钮
- Then 系统成功返回到上一页面（首页）

**依赖**: FR-001至FR-009

#### FR-012: 页面标题显示
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall display correct page title on each of the 9 new pages according to their functionality.

**验收标准**:
- Given 用户打开任意新建页面
- When 页面加载完成
- Then 页面顶部显示对应的功能标题

**依赖**: FR-001至FR-009

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 页面加载性能
**指标**: 页面首次加载时间不超过500ms
**测试方法**: 使用DevEco Studio性能分析工具测量页面加载时间

#### NFR-002: 路由跳转性能
**指标**: 页面跳转响应时间不超过200ms
**测试方法**: 测量从点击图标到新页面开始渲染的时间

### 4.2 兼容性需求

#### NFR-003: 设备兼容性
**指标**: 支持HarmonyOS 6.0及以上版本
**测试方法**: 在不同HarmonyOS版本设备上测试页面功能

#### NFR-004: 屏幕适配
**指标**: 适配不同屏幕尺寸和分辨率
**测试方法**: 在不同尺寸设备上验证UI布局正确性

### 4.3 可用性需求

#### NFR-005: UI一致性
**指标**: 新页面UI风格与现有页面保持一致
**测试方法**: UI设计评审和用户测试

#### NFR-006: 适老模式支持
**指标**: 支持适老模式切换，字体和布局自动调整
**测试方法**: 切换适老模式验证页面显示效果

## 5. 数据需求

### 5.1 数据模型

本阶段仅创建页面框架，数据模型定义如下（供后续实现参考）：

**体检报告数据模型**:
- 报告ID、报告名称、检查日期、检查机构、报告状态

**用药提醒数据模型**:
- 提醒ID、药品名称、用药时间、剂量、提醒状态

**问诊记录数据模型**:
- 问诊ID、科室、医生、问诊时间、问诊状态

**急救知识数据模型**:
- 知识ID、标题、分类、内容、图片

**家庭医生数据模型**:
- 医生ID、姓名、职称、科室、签约状态

**医保记录数据模型**:
- 记录ID、类型、金额、日期、状态

**康复训练数据模型**:
- 训练ID、计划名称、训练时间、完成状态

**AI对话数据模型**:
- 消息ID、内容、发送者、时间戳

**跨院协同数据模型**:
- 协同ID、医院名称、共享类型、时间、状态

### 5.2 数据存储

本阶段不涉及数据持久化实现，仅预留数据接口。

### 5.3 数据安全

所有页面应遵循应用现有的数据安全规范，敏感数据需加密处理。

## 6. 接口需求

### 6.1 用户界面

**UI设计要求**:
- 使用项目统一的Header组件
- 使用项目统一的GlobalTheme主题配置
- 支持适老模式（isElderMode）
- 使用ToastUtil进行提示信息展示
- 页面布局采用Flex布局，支持响应式

**交互设计要求**:
- 所有页面支持返回导航
- 列表项支持点击交互
- 提供加载状态和空状态展示

### 6.2 系统接口

**路由接口**:
- 使用HarmonyOS router模块进行页面导航
- 路由参数传递遵循项目规范

**组件接口**:
- 引入项目公共组件（Header、Footer等）
- 使用项目工具类（HttpUtil、ToastUtil等）

## 7. 约束条件

### 7.1 技术约束

- 开发语言：ArkTS
- 最低API版本：HarmonyOS 6.0
- UI框架：ArkUI声明式开发范式
- 必须使用项目现有的组件和工具类

### 7.2 业务约束

- 页面功能应与首页快捷服务描述一致
- 不得修改现有页面的功能逻辑
- 路由配置不得与现有路由冲突

### 7.3 时间约束

- 页面创建和路由注册应在1个工作日内完成
- 基础UI框架实现应在2个工作日内完成

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | ReportPage页面创建 | 文件创建成功，包含基础UI结构 | P0 | 待验证 |
| FR-002 | MedicationPage页面创建 | 文件创建成功，包含提醒管理界面 | P0 | 待验证 |
| FR-003 | ConsultationPage页面创建 | 文件创建成功，包含问诊入口界面 | P0 | 待验证 |
| FR-004 | EmergencyPage页面创建 | 文件创建成功，包含急救指南界面 | P0 | 待验证 |
| FR-005 | FamilyDoctorPage页面创建 | 文件创建成功，包含家庭医生界面 | P0 | 待验证 |
| FR-006 | InsurancePage页面创建 | 文件创建成功，包含医保服务界面 | P0 | 待验证 |
| FR-007 | RehabilitationPage页面创建 | 文件创建成功，包含康复训练界面 | P0 | 待验证 |
| FR-008 | AIAssistantPage页面创建 | 文件创建成功，包含AI助手界面 | P0 | 待验证 |
| FR-009 | DistributedCollaborationPage页面创建 | 文件创建成功，包含跨院协同界面 | P0 | 待验证 |
| FR-010 | 路由配置更新 | main_pages.json包含所有新页面路由 | P0 | 待验证 |
| FR-011 | 页面返回导航 | 返回按钮功能正常 | P0 | 待验证 |
| FR-012 | 页面标题显示 | 各页面标题正确显示 | P1 | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| ArkTS | HarmonyOS应用开发语言，基于TypeScript扩展 |
| ArkUI | HarmonyOS声明式UI开发框架 |
| @Entry | 页面入口装饰器，标识页面组件 |
| @Component | 组件装饰器，定义UI组件 |
| router | HarmonyOS路由模块，用于页面导航 |
| 适老模式 | 针对老年用户的界面优化模式，字体更大、布局更简洁 |

## 10. 附录

### 10.1 参考资料

- 项目现有页面实现：pages/Medications、pages/AiChatPage、pages/DoctorListPage、pages/RehabPage、pages/MedicalRecordSyncPage
- HarmonyOS官方文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-get-start-V5
- 项目路由配置：entry/src/main/resources/base/profile/main_pages.json

### 10.2 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-14 | 初始版本创建 | SDD Agent |
