# 首页响应式布局开发 - 需求规格文档

**版本**: v1.0
**创建日期**: 2026-05-06
**最后更新**: 2026-05-06
**作者**: SDD Agent
**状态**: 草稿

## 1. 概述

### 1.1 功能简介
为星云医疗助手项目完善首页 HomePage.ets 的响应式布局，使其能够完美适配手机(sm)、平板(md)、二合一设备(lg)三种设备类型，提供一致且优化的用户体验。

### 1.2 业务背景
当前医疗应用需要在多种设备上运行，包括手机、平板和二合一设备。不同设备屏幕尺寸差异较大，需要响应式布局来确保内容合理展示，提升用户在不同设备上的使用体验。

### 1.3 范围定义
**包含范围**:
- 响应式断点系统适配
- Grid网格布局响应式调整
- 字体大小响应式适配
- 卡片组件响应式设计
- 13个功能入口卡片布局
- 顶部问候语和日期显示
- 数据统计区域横向滚动

**排除范围**:
- 功能入口的具体业务逻辑实现
- 后端API数据对接
- 用户认证和权限管理
- 图表组件的详细实现

## 2. 用户故事

### US-001: 多设备适配体验
**作为** 使用不同设备的用户
**我想要** 在手机、平板、二合一设备上都能获得优化的布局体验
**以便于** 在任何设备上都能方便地访问医疗助手功能

**验收标准**:
- Given 用户使用手机设备(sm断点)
- When 打开首页
- Then 显示2列Grid布局，字体和间距适配小屏幕

- Given 用户使用平板设备(md断点)
- When 打开首页
- Then 显示3列Grid布局，字体和间距适配中等屏幕

- Given 用户使用二合一设备(lg断点)
- When 打开首页
- Then 显示4列Grid布局，字体和间距适配大屏幕

### US-002: 功能入口快速访问
**作为** 医疗助手用户
**我想要** 在首页快速找到并访问各种功能入口
**以便于** 高效使用医疗助手的各项功能

**验收标准**:
- Given 用户在首页
- When 查看功能入口区域
- Then 显示13个功能入口卡片，每个卡片包含图标、标题和副标题

- Given 用户点击任意功能入口卡片
- When 点击事件触发
- Then 正确跳转到对应功能页面

## 3. 功能需求

### 3.1 响应式断点系统

#### FR-001: 断点读取与监听
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The HomePage shall read the current breakpoint from AppStorage using @StorageLink decorator and respond to breakpoint changes in real-time.

**验收标准**:
- Given BreakpointSystem已初始化并写入AppStorage
- When HomePage加载时
- Then 通过@StorageLink('currentBreakpoint')成功读取当前断点值

- Given 用户调整窗口大小跨越断点阈值
- When 断点值发生变化
- Then HomePage自动更新布局以适配新断点

#### FR-002: Grid布局响应式适配
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When the breakpoint changes, the HomePage shall adjust Grid columns, columnsGap, and rowsGap according to the breakpoint rules.

**验收标准**:
- Given 当前断点为SM(宽度<=600vp)
- When 渲染Grid布局
- Then GridColumns=2, columnsGap=12vp, rowsGap=12vp

- Given 当前断点为MD(宽度600-840vp)
- When 渲染Grid布局
- Then GridColumns=3, columnsGap=16vp, rowsGap=16vp

- Given 当前断点为LG(宽度>840vp)
- When 渲染Grid布局
- Then GridColumns=4, columnsGap=20vp, rowsGap=20vp

### 3.2 字体大小适配

#### FR-003: 标题字体响应式
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The HomePage shall adjust title font size based on current breakpoint: 18fp for SM, 20fp for MD, 24fp for LG.

**验收标准**:
- Given 当前断点为SM
- When 渲染标题文字
- Then 字体大小为18fp

- Given 当前断点为MD
- When 渲染标题文字
- Then 字体大小为20fp

- Given 当前断点为LG
- When 渲染标题文字
- Then 字体大小为24fp

#### FR-004: 正文字体响应式
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The HomePage shall adjust body text font size based on current breakpoint: 14fp for SM, 16fp for MD, 18fp for LG.

**验收标准**:
- Given 当前断点为SM
- When 渲染正文文字
- Then 字体大小为14fp

- Given 当前断点为MD
- When 渲染正文文字
- Then 字体大小为16fp

- Given 当前断点为LG
- When 渲染正文文字
- Then 字体大小为18fp

### 3.3 卡片组件设计

#### FR-005: HealthCard组件复用
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The HomePage shall use @Builder decorator to create reusable HealthCard component with parameters: icon, title, subtitle, value, unit, color, onClick.

**验收标准**:
- Given 需要渲染健康数据卡片
- When 调用HealthCard @Builder方法
- Then 生成包含图标、标题、副标题、数值、单位的卡片组件

- Given HealthCard组件渲染
- When 用户点击卡片
- Then 触发onClick回调函数

#### FR-006: 卡片样式响应式
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When the breakpoint changes, the HealthCard shall adjust padding: 12vp for SM, 16vp for MD, 20vp for LG, with consistent border radius 12vp and shadow effect.

**验收标准**:
- Given 当前断点为SM
- When 渲染HealthCard
- Then 内边距为12vp，圆角12vp，包含阴影效果

- Given 当前断点为MD
- When 渲染HealthCard
- Then 内边距为16vp，圆角12vp，包含阴影效果

- Given 当前断点为LG
- When 渲染HealthCard
- Then 内边距为20vp，圆角12vp，包含阴影效果

### 3.4 功能入口卡片

#### FR-007: 13个功能入口展示
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The HomePage shall display 13 function entry cards in Grid layout: 健康档案、用药提醒、AI问诊、在线咨询、医院查询、智慧停车、康复训练、风险评估、AR导航、数字孪生、古医影像、分布式协同、急救中心.

**验收标准**:
- Given 首页加载完成
- When 查看功能入口区域
- Then 显示13个功能入口卡片，每个包含图标和标题

- Given 用户点击任意功能入口
- When 点击事件触发
- Then 使用router.pushUrl跳转到对应页面

### 3.5 顶部区域

#### FR-008: 问候语显示
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The HomePage shall display greeting message based on current time: "早上好" for 6-12点, "下午好" for 12-18点, "晚上好" for 18-6点, followed by username.

**验收标准**:
- Given 当前时间为上午9点
- When 渲染问候语
- Then 显示"早上好, 用户名"

- Given 当前时间为下午15点
- When 渲染问候语
- Then 显示"下午好, 用户名"

- Given 当前时间为晚上20点
- When 渲染问候语
- Then 显示"晚上好, 用户名"

#### FR-009: 日期显示
**优先级**: P2
**类型**: 功能需求

**需求描述**:
The HomePage shall display current date in format "YYYY年MM月DD日 星期X".

**验收标准**:
- Given 当前日期为2026年5月6日星期三
- When 渲染日期区域
- Then 显示"2026年5月6日 星期三"

### 3.6 数据统计区域

#### FR-010: 健康数据横向滚动
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The HomePage shall display health statistics in horizontal scroll area including: 今日步数、心率、血压、血糖、睡眠时长, with mini trend charts.

**验收标准**:
- Given 首页加载完成
- When 查看数据统计区域
- Then 显示横向滚动的健康数据卡片，每个包含数值和迷你趋势图

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 页面加载性能
**指标**: 首页加载时间 < 1秒
**测试方法**: 使用DevEco Studio性能分析工具测量页面加载时间

#### NFR-002: 断点切换流畅性
**指标**: 断点切换响应时间 < 100ms
**测试方法**: 调整窗口大小，测量布局重排时间

### 4.2 兼容性需求

#### NFR-003: 多设备兼容
**指标**: 支持Phone/Tablet/2in1三种设备类型
**测试方法**: 在三种模拟器上运行并验证布局正确性

### 4.3 可用性需求

#### NFR-004: 触摸目标大小
**指标**: 所有可点击元素最小尺寸 >= 44vp
**测试方法**: 检查所有按钮和卡片的点击区域大小

## 5. 数据需求

### 5.1 数据模型

```typescript
// 断点类型
enum BreakpointType {
  SM = 'SM',  // 小屏设备(手机)
  MD = 'MD',  // 中屏设备(平板)
  LG = 'LG'   // 大屏设备(二合一)
}

// 功能入口数据模型
interface FunctionEntry {
  id: string
  icon: Resource
  title: string
  subtitle?: string
  route: string
  color?: Color
}

// 健康数据模型
interface HealthStatistic {
  id: string
  icon: Resource
  title: string
  value: string
  unit: string
  trend: 'up' | 'down' | 'stable'
  trendValue?: string
}
```

### 5.2 数据存储
- 断点值存储在AppStorage中，key为'currentBreakpoint'
- 窗口宽高存储在AppStorage中，key为'windowWidth'和'windowHeight'
- 用户信息从AppStorage读取，key为'userInfo'

### 5.3 数据安全
- 首页不涉及敏感数据展示
- 用户名显示时需考虑隐私保护设置

## 6. 接口需求

### 6.1 用户界面

**UI设计要求**:
- 整体采用Column布局，包含顶部区域、数据统计区域、功能入口区域
- 顶部区域固定高度，包含问候语、日期、头像、消息图标
- 数据统计区域横向滚动，高度固定
- 功能入口区域使用Grid布局，占据剩余空间

**色彩规范**:
- 主色调: #4A90D9 (医疗蓝)
- 背景色: #F5F5F5 (浅灰)
- 卡片背景: #FFFFFF (白色)
- 文字主色: #333333 (深灰)
- 文字辅色: #666666 (中灰)

### 6.2 系统接口

**依赖接口**:
- BreakpointSystem: 提供断点计算和监听
- router: 页面路由跳转
- AppStorage: 全局状态存储

**输出接口**:
- 无对外API接口，仅作为展示页面

## 7. 约束条件

### 7.1 技术约束
- 必须使用ArkTS语言开发
- 必须使用ArkUI声明式UI框架
- 禁止使用any类型
- 必须使用@State/@Prop/@Link/@StorageLink正确管理状态
- 必须使用@Builder/@Styles/@Extend复用代码

### 7.2 业务约束
- 功能入口数量固定为13个
- 功能入口顺序按业务重要性排列
- 健康数据统计项固定为5项

### 7.3 时间约束
- 开发周期: 1天
- 交付时间: Day1结束前

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 断点读取与监听 | 成功读取AppStorage断点值并响应变化 | P0 | 待验证 |
| FR-002 | Grid布局响应式适配 | 根据断点调整Grid列数和间距 | P0 | 待验证 |
| FR-003 | 标题字体响应式 | 根据断点调整标题字体大小 | P1 | 待验证 |
| FR-004 | 正文字体响应式 | 根据断点调整正文字体大小 | P1 | 待验证 |
| FR-005 | HealthCard组件复用 | 使用@Builder创建可复用卡片组件 | P0 | 待验证 |
| FR-006 | 卡片样式响应式 | 根据断点调整卡片内边距 | P1 | 待验证 |
| FR-007 | 13个功能入口展示 | 显示13个功能入口并支持跳转 | P0 | 待验证 |
| FR-008 | 问候语显示 | 根据时间显示对应问候语 | P1 | 待验证 |
| FR-009 | 日期显示 | 显示当前日期和星期 | P2 | 待验证 |
| FR-010 | 健康数据横向滚动 | 显示5项健康数据统计 | P1 | 待验证 |

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| Breakpoint | 断点，用于响应式布局的屏幕宽度阈值 |
| SM | Small，小屏设备断点(宽度<=600vp) |
| MD | Medium，中屏设备断点(宽度600-840vp) |
| LG | Large，大屏设备断点(宽度>840vp) |
| vp | virtual pixel，虚拟像素，HarmonyOS布局单位 |
| fp | font pixel，字体像素，HarmonyOS字体单位 |
| Grid | 网格布局组件 |
| @Builder | ArkUI装饰器，用于创建可复用UI片段 |

## 10. 附录

### 10.1 参考资料
- HarmonyOS ArkUI开发文档
- BreakpointSystem.ets源码
- 项目规划总览V17.0.md

### 10.2 变更历史
| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2026-05-06 | 初始版本创建 | SDD Agent |
