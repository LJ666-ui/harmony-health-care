# 页面导航增强功能 - 需求规格文档

**版本**: v1.0
**创建日期**: 2025-01-14
**最后更新**: 2025-01-14
**作者**: AI Assistant
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
本功能旨在完善HarmonyOS智慧医疗健康应用中的页面导航系统，确保所有页面之间能够正常跳转，提升用户体验和应用可用性。

### 1.2 业务背景
用户反馈项目中存在大量页面无法进行跳转的问题，导致：
- 用户无法访问部分功能页面
- 应用导航流程不完整
- 用户体验受损
- 功能模块之间缺乏有效连接

### 1.3 范围定义

**包含范围**:
- 为缺少导航功能的页面添加跳转能力
- 完善现有页面的导航逻辑
- 统一页面跳转方式和错误处理
- 添加返回导航功能
- 确保所有页面在路由配置中正确注册

**排除范围**:
- 页面内容重构
- 页面UI设计修改
- 后端API接口开发
- 数据存储相关功能

## 2. 用户故事

### US-001: 完整的页面导航体验
**作为** 应用用户
**我想要** 能够从任何页面跳转到相关功能页面
**以便于** 顺畅地使用应用的各项功能

**验收标准**:
- Given 用户在任意页面
- When 用户点击导航按钮或链接
- Then 系统应成功跳转到目标页面

### US-002: 可靠的返回导航
**作为** 应用用户
**我想要** 能够返回到上一页面
**以便于** 在不同页面间自由切换

**验收标准**:
- Given 用户已跳转到新页面
- When 用户点击返回按钮
- Then 系统应返回到上一页面

### US-003: 友好的错误提示
**作为** 应用用户
**我想要** 在导航失败时收到明确提示
**以便于** 了解问题并采取相应操作

**验收标准**:
- Given 页面跳转发生错误
- When 导航失败
- Then 系统应显示友好的错误提示信息

## 3. 功能需求

### 3.1 页面路由注册

#### FR-001: 路由配置完整性
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The navigation system shall register all application pages in the router configuration file (main_pages.json).

**验收标准**:
- 所有页面文件都应在 main_pages.json 中注册
- 路由路径格式应为 "pages/FileName"（不含.ets扩展名）
- 未注册的页面应被识别并添加到配置中

**依赖**: 无

#### FR-002: 路由路径规范化
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The navigation system shall use consistent router path format across all pages.

**验收标准**:
- 所有路由路径使用统一格式
- 路径不包含文件扩展名
- 路径使用正斜杠分隔符

**依赖**: FR-001

### 3.2 页面跳转功能

#### FR-003: Router导入完整性
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When a page requires navigation functionality, the page shall import router module from '@kit.ArkUI'.

**验收标准**:
- 所有需要跳转功能的页面都导入 router
- 导入语句格式统一：`import { router } from '@kit.ArkUI';`
- 识别并列出缺少 router 导入的页面

**依赖**: 无

#### FR-004: 导航跳转实现
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When user triggers a navigation action, the system shall execute router.pushUrl() or router.push() method to navigate to target page.

**验收标准**:
- 所有导航按钮都有 onClick 事件处理
- 使用 try-catch 包裹跳转逻辑
- 跳转失败时记录错误日志

**依赖**: FR-003

#### FR-005: 参数传递支持
**优先级**: P1
**类型**: 功能需求

**需求描述**:
Where navigation requires data transfer, the system shall support passing parameters via router.pushUrl().

**验收标准**:
- 支持通过 params 传递参数
- 目标页面能正确接收参数
- 参数类型安全

**依赖**: FR-004

### 3.3 返回导航功能

#### FR-006: 返回按钮实现
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When user needs to return to previous page, the page shall provide a back button or navigation method using router.back().

**验收标准**:
- 页面提供返回按钮或手势
- 返回按钮调用 router.back()
- 返回操作不丢失上一页面的状态

**依赖**: FR-003

#### FR-007: Header组件返回功能
**优先级**: P1
**类型**: 功能需求

**需求描述**:
Where Header component is used, the Header shall support showBack property to display back button.

**验收标准**:
- Header 组件支持 showBack 参数
- showBack 为 true 时显示返回按钮
- 点击返回按钮执行 router.back()

**依赖**: FR-006

### 3.4 错误处理

#### FR-008: 导航错误捕获
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The navigation system shall catch and handle navigation errors gracefully in order to prevent application crash.

**验收标准**:
- 所有跳转操作使用 try-catch 包裹
- 错误信息记录到控制台
- 不因导航错误导致应用崩溃

**依赖**: FR-004

#### FR-009: 用户友好提示
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When navigation fails, the system shall display user-friendly error message in order to inform user of the issue.

**验收标准**:
- 导航失败时显示提示信息
- 提示信息清晰易懂
- 不显示技术性错误堆栈

**依赖**: FR-008

### 3.5 特定页面导航修复

#### FR-010: AI问诊页面导航
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The AiConsultationPage shall support navigation to related pages such as doctor list and chat history.

**验收标准**:
- AiConsultationPage 导入 router 模块
- 支持跳转到医生列表页面
- 支持跳转到聊天历史页面

**依赖**: FR-003

#### FR-011: 知识图谱页面导航
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The KnowledgeGraphPage and KnowledgeExplorePage shall support navigation to detail pages.

**验收标准**:
- 知识图谱页面导入 router 模块
- 支持跳转到节点详情页面
- 支持跳转到相关内容页面

**依赖**: FR-003

#### FR-012: 病历同步页面导航
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The MedicalRecordSyncPage shall support navigation to device management and sync history pages.

**验收标准**:
- MedicalRecordSyncPage 导入 router 模块
- 支持跳转到设备管理页面
- 支持跳转到同步历史页面

**依赖**: FR-003

#### FR-013: 转院审批页面导航
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The TransferApprovalPage shall support navigation to application detail and related pages.

**验收标准**:
- TransferApprovalPage 导入 router 模块
- 支持跳转到申请详情页面
- 支持跳转到相关病历页面

**依赖**: FR-003

#### FR-014: 医疗服务页面导航完善
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The MedicalPage shall provide navigation for all service items including queue and payment services.

**验收标准**:
- 排队叫号服务支持跳转
- 缴费支付服务支持跳转
- 未实现的服务显示提示信息

**依赖**: FR-004

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 导航响应时间
**指标**: 页面跳转应在500ms内完成
**测试方法**: 使用性能分析工具测量跳转耗时

#### NFR-002: 路由配置加载
**指标**: 路由配置应在应用启动时完成加载
**测试方法**: 检查应用启动性能

### 4.2 可维护性需求

#### NFR-003: 代码一致性
**指标**: 所有页面使用统一的导航实现方式
**测试方法**: 代码审查

#### NFR-004: 错误日志完整性
**指标**: 所有导航错误都记录到日志
**测试方法**: 检查日志输出

### 4.3 兼容性需求

#### NFR-005: HarmonyOS版本兼容
**指标**: 支持HarmonyOS 6.0及以上版本
**测试方法**: 在不同版本设备上测试

## 5. 数据需求

### 5.1 导航参数模型
```typescript
interface NavigationParams {
  [key: string]: string | number | boolean | object;
}
```

### 5.2 路由配置数据
- 路由路径列表
- 页面参数定义
- 导航关系映射

### 5.3 错误日志数据
- 错误类型
- 错误时间戳
- 错误上下文信息

## 6. 接口需求

### 6.1 用户界面
- 导航按钮样式统一
- 返回按钮位置一致
- 加载状态提示

### 6.2 系统接口
- router.pushUrl() - 页面跳转
- router.push() - 页面跳转（带参数）
- router.back() - 返回上一页
- router.replace() - 替换当前页

## 7. 约束条件

### 7.1 技术约束
- 使用HarmonyOS ArkUI框架
- 遵循ArkTS语法规范
- 使用@kit.ArkUI提供的router模块

### 7.2 业务约束
- 不改变现有页面功能逻辑
- 保持现有UI设计不变
- 兼容现有导航流程

### 7.3 时间约束
- 优先修复P0级别问题
- 分阶段完成所有页面导航修复
- 每个修复后进行测试验证

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 路由配置完整性 | 所有页面在main_pages.json中注册 | P0 | 待验证 |
| FR-003 | Router导入完整性 | 所有需要导航的页面导入router | P0 | 待验证 |
| FR-004 | 导航跳转实现 | 所有导航按钮有onClick处理 | P0 | 待验证 |
| FR-006 | 返回按钮实现 | 页面提供返回功能 | P0 | 待验证 |
| FR-008 | 导航错误捕获 | 使用try-catch处理错误 | P0 | 待验证 |
| FR-010 | AI问诊页面导航 | AiConsultationPage支持导航 | P1 | 待验证 |
| FR-011 | 知识图谱页面导航 | 知识图谱页面支持导航 | P1 | 待验证 |
| FR-012 | 病历同步页面导航 | MedicalRecordSyncPage支持导航 | P1 | 待验证 |
| FR-013 | 转院审批页面导航 | TransferApprovalPage支持导航 | P1 | 待验证 |
| FR-014 | 医疗服务页面导航完善 | MedicalPage所有服务支持跳转 | P1 | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| Router | HarmonyOS页面路由管理器 |
| pushUrl | 页面跳转方法，将新页面压入导航栈 |
| push | 带参数的页面跳转方法 |
| back | 返回上一页面方法 |
| main_pages.json | HarmonyOS路由配置文件 |
| EARS | Easy Approach to Requirements Syntax |

## 10. 附录

### 10.1 参考资料
- HarmonyOS应用开发文档
- ArkUI组件参考
- 项目现有诊断报告

### 10.2 变更历史
| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2025-01-14 | 初始版本创建 | AI Assistant |
