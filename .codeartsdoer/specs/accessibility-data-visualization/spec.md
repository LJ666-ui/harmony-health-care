# 无障碍友好界面与健康数据可视化 - 需求规格文档

**版本**: v1.0
**创建日期**: 2026-04-27
**最后更新**: 2026-04-27
**作者**: AI Assistant
**状态**: 草稿

---

## 1. 概述

### 1.1 功能简介

本需求规格文档定义了"星云医疗助手"HarmonyOS应用的两个核心优化方向：
1. **无障碍友好界面设计**：针对老年用户、视障用户、运动障碍用户和认知障碍用户，提供符合WCAG 2.1 AA级标准的无障碍体验
2. **健康数据可视化方案**：为医疗健康数据提供完整的可视化解决方案，支持生命体征、健康指标、历史趋势和风险评估等多维度数据展示

### 1.2 业务背景

**当前问题**：
- **无障碍问题**：
  - 字体过小，老年人阅读困难
  - 颜色对比度不足，视障用户无法辨识
  - 按钮太小容易误触，运动障碍用户操作困难
  - 操作流程过于复杂，认知障碍用户容易迷失
  - 缺乏语音引导，视障用户无法独立使用

- **数据可视化问题**：
  - 健康数据展示形式单一，缺乏直观性
  - 无法展示历史趋势和多维度对比
  - 缺少风险评估的可视化表达
  - 数据更新不及时，用户体验差

**解决方案**：
- 实现符合WCAG 2.1 AA级标准的无障碍设计
- 提供老年模式、高对比度模式、大字体模式等多种辅助模式
- 开发完整的健康数据可视化组件库
- 支持动态数据更新和交互式图表操作

### 1.3 范围定义

**包含范围**：
- 无障碍设计规范制定与实施
- AccessibilityConfig工具类开发
- 老年模式、高对比度模式、大字体模式实现
- 健康数据可视化组件库开发（折线图、柱状图、雷达图、仪表盘、热力图）
- 数据格式规范定义
- 交互设计（缩放、筛选、详情查看）
- 性能优化策略

**排除范围**：
- 第三方图表库的深度集成（仅允许轻量级库）
- 复杂的3D可视化（不属于本次范围）
- 机器学习算法优化（使用现有算法）
- 后端数据接口开发（假设数据已就绪）

---

## 2. 用户故事

### US-001: 老年用户阅读健康报告
**作为** 一位65岁的老年用户
**我想要** 在使用医疗助手时能够清晰阅读所有文字内容
**以便于** 准确理解我的健康状况和医生建议

**验收标准**:
- Given 用户开启老年模式
- When 用户查看健康报告页面
- Then 所有文字字体不小于20sp，行间距不小于1.5倍，段落间距不小于2倍

### US-002: 视障用户独立操作应用
**作为** 一位视障用户
**我想要** 通过屏幕阅读器完整使用应用所有功能
**以便于** 无需他人帮助即可管理我的健康

**验收标准**:
- Given 用户启用屏幕阅读器
- When 用户浏览任何页面
- Then 所有交互元素都有明确的accessibilityText和accessibilityDescription

### US-003: 运动障碍用户精准操作
**作为** 一位手部运动障碍用户
**我想要** 有足够大的触控区域来操作应用
**以便于** 避免误触并准确完成操作

**验收标准**:
- Given 用户点击任何可交互元素
- When 触控区域尺寸测量
- Then 最小触控区域不小于44x44dp

### US-004: 查看心率趋势变化
**作为** 一位关注心脏健康的用户
**我想要** 通过折线图查看我的心率历史趋势
**以便于** 了解心率变化规律和异常情况

**验收标准**:
- Given 用户进入健康数据页面
- When 用户选择"心率趋势"查看
- Then 显示折线图，支持日/周/月/年维度切换，渲染时间<100ms

### US-005: 多维度健康评估
**作为** 一位进行全面体检的用户
**我想要** 通过雷达图查看我的综合健康评分
**以便于** 直观了解各维度健康状态和改进方向

**验收标准**:
- Given 用户完成健康风险评估
- When 用户查看评估结果
- Then 显示多维度雷达图，包含至少6个健康维度，每个维度有明确标注

---

## 3. 功能需求

### 3.1 无障碍设计需求

#### FR-001: 老年模式支持
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide an elderly mode that enlarges all UI elements to improve readability and operability for users aged 60 and above.

**验收标准**:
- Given 用户在设置中开启"老年模式"
- When 系统应用老年模式配置
- Then 所有字体不小于20sp，按钮不小于48x48dp，图标不小于32x32dp，行间距增加50%

**依赖**: 无

#### FR-002: 高对比度模式
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a high contrast mode that ensures all text and interactive elements meet WCAG 2.1 AA color contrast ratio of at least 4.5:1.

**验收标准**:
- Given 用户开启"高对比度模式"
- When 系统应用高对比度配色
- Then 所有文字与背景对比度≥4.5:1，大文字(≥18pt)对比度≥3:1

**依赖**: 无

#### FR-003: 屏幕阅读器支持
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide complete accessibility labels for all interactive elements to support screen readers used by visually impaired users.

**验收标准**:
- Given 用户启用屏幕阅读器
- When 用户聚焦任何交互元素
- Then 元素朗读清晰的描述文本，包括元素类型、当前状态、操作提示

**依赖**: 无

#### FR-004: 最小触控区域
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall ensure all interactive elements have a minimum touch target size of 44x44dp to accommodate users with motor impairments.

**验收标准**:
- Given 用户点击任何按钮、链接、图标
- When 测量触控区域
- Then 触控区域≥44x44dp，相邻元素间距≥8dp

**依赖**: 无

#### FR-005: 操作撤销机制
**优先级**: P1
**类型**: 功能需求

**需求描述**:
When user performs a critical operation (delete, submit, cancel), the system shall provide an undo mechanism or confirmation dialog to prevent accidental actions.

**验收标准**:
- Given 用户执行关键操作（删除记录、取消预约等）
- When 操作触发
- Then 显示二次确认对话框，或提供3秒内撤销选项

**依赖**: 无

#### FR-006: 简化操作流程
**优先级**: P1
**类型**: 功能需求

**需求描述**:
Where elderly mode is enabled, the system shall simplify multi-step operations to reduce cognitive load for users with cognitive impairments.

**验收标准**:
- Given 用户开启老年模式
- When 执行多步骤操作（如预约挂号）
- Then 每个步骤有明确指引，提供进度提示，支持随时返回上一步

**依赖**: FR-001

#### FR-007: 语音引导功能
**优先级**: P2
**类型**: 功能需求

**需求描述**:
Where voice guidance is enabled, the system shall announce important information and operation results through speech synthesis.

**验收标准**:
- Given 用户开启语音引导
- When 发生重要事件（预约成功、用药提醒等）
- Then 系统语音播报事件内容，语速可调节

**依赖**: 无

### 3.2 健康数据可视化需求

#### FR-008: 折线图组件
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a line chart component for displaying time-series health data trends such as heart rate and blood glucose.

**验收标准**:
- Given 传入时间序列数据
- When 渲染折线图
- Then 显示平滑曲线，支持多数据系列，支持缩放和拖拽，渲染时间<100ms

**依赖**: 无

#### FR-009: 柱状图组件
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a bar chart component for comparing health data across different time periods or categories.

**验收标准**:
- Given 传入对比数据
- When 渲染柱状图
- Then 显示清晰柱状条，支持横向/纵向切换，支持点击查看详情，渲染时间<100ms

**依赖**: 无

#### FR-010: 雷达图组件
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a radar chart component for multi-dimensional health assessment visualization.

**验收标准**:
- Given 传入多维度评分数据
- When 渲染雷达图
- Then 显示多边形雷达图，每个维度有标签和数值，支持悬停查看详情，渲染时间<100ms

**依赖**: 无

#### FR-011: 仪表盘组件
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall provide a gauge chart component for real-time monitoring of health indicators within defined ranges.

**验收标准**:
- Given 传入当前值和正常范围
- When 渲染仪表盘
- Then 显示半圆或全圆仪表盘，指针指向当前值，颜色区分正常/警告/危险区域，渲染时间<100ms

**依赖**: 无

#### FR-012: 热力图组件
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall provide a heatmap component for visualizing time-distributed health data such as activity intensity throughout the day.

**验收标准**:
- Given 传入时间分布数据
- When 渲染热力图
- Then 显示网格热力图，颜色深浅表示数值大小，支持悬停查看具体值，渲染时间<100ms

**依赖**: 无

#### FR-013: 动态数据更新
**优先级**: P0
**类型**: 功能需求

**需求描述**:
When health data is updated, the system shall refresh all related charts in real-time without requiring page reload.

**验收标准**:
- Given 图表已渲染
- When 数据源更新
- Then 图表在200ms内完成重绘，动画过渡平滑，无闪烁

**依赖**: FR-008, FR-009, FR-010, FR-011, FR-012

#### FR-014: 图表交互功能
**优先级**: P1
**类型**: 功能需求

**需求描述**:
The system shall provide interactive features for all charts including zoom, pan, tooltip, and data point selection.

**验收标准**:
- Given 用户查看图表
- When 执行交互操作（缩放、拖拽、点击）
- Then 图表响应流畅，显示详细信息，支持手势操作

**依赖**: FR-008, FR-009, FR-010, FR-011, FR-012

#### FR-015: 响应式图表布局
**优先级**: P0
**类型**: 功能需求

**需求描述**:
The system shall ensure all charts adapt to different screen sizes and orientations while maintaining readability.

**验收标准**:
- Given 设备屏幕尺寸变化
- When 图表重新布局
- Then 图表尺寸自适应，保持宽高比，文字和元素不重叠，无信息丢失

**依赖**: FR-008, FR-009, FR-010, FR-011, FR-012

---

## 4. 非功能需求

### 4.1 性能需求

#### NFR-001: 图表渲染性能
**指标**: 所有图表组件首次渲染时间<100ms，数据更新重绘时间<200ms
**测试方法**: 使用Performance API测量渲染时间，进行100次渲染测试取P95值

#### NFR-002: 内存占用
**指标**: 单个图表组件内存占用<5MB，所有图表总内存占用<50MB
**测试方法**: 使用DevEco Studio内存分析工具监控

#### NFR-003: 滚动流畅度
**指标**: 包含图表的列表滚动帧率≥55fps
**测试方法**: 使用HiPerf工具测量帧率

### 4.2 兼容性需求

#### NFR-004: HarmonyOS版本兼容
**指标**: 支持HarmonyOS NEXT API 12及以上版本
**测试方法**: 在不同API版本的模拟器和真机上测试

#### NFR-005: 屏幕尺寸适配
**指标**: 支持手机(360dp-480dp)、平板(600dp-840dp)、折叠屏多种形态
**测试方法**: 在不同尺寸设备上测试布局和交互

#### NFR-006: 无障碍工具兼容
**指标**: 兼容HarmonyOS TalkBack屏幕阅读器、开关控制等辅助工具
**测试方法**: 启用各类辅助工具进行功能测试

### 4.3 可用性需求

#### NFR-007: 学习成本
**指标**: 新用户5分钟内学会使用图表交互功能
**测试方法**: 用户测试，记录任务完成时间和错误率

#### NFR-008: 错误恢复
**指标**: 图表数据异常时显示友好提示，不崩溃
**测试方法**: 注入异常数据（null、undefined、超范围值）测试

### 4.4 可维护性需求

#### NFR-009: 代码规范
**指标**: 遵循ArkTS编码规范，无any类型，无编译警告
**测试方法**: 使用hvigorw build检查编译结果

#### NFR-010: 组件复用
**指标**: 图表组件可在不同页面复用，无需修改
**测试方法**: 在至少3个不同页面集成同一组件测试

---

## 5. 数据需求

### 5.1 数据模型

#### 时间序列数据 (TimeSeriesData)
```typescript
interface TimeSeriesData {
  timestamp: number;      // 时间戳
  value: number;          // 数值
  label?: string;         // 可选标签
}
```

#### 多维度评分数据 (MultiDimensionScore)
```typescript
interface MultiDimensionScore {
  dimension: string;      // 维度名称
  score: number;          // 评分(0-100)
  maxValue: number;       // 最大值
  description?: string;   // 描述
}
```

#### 仪表盘数据 (GaugeData)
```typescript
interface GaugeData {
  currentValue: number;   // 当前值
  minValue: number;       // 最小值
  maxValue: number;       // 最大值
  normalRange: [number, number];  // 正常范围
  warningRange: [number, number]; // 警告范围
  unit: string;           // 单位
}
```

#### 热力图数据 (HeatmapData)
```typescript
interface HeatmapData {
  row: number;            // 行索引
  col: number;            // 列索引
  value: number;          // 数值
  label?: string;         // 标签
}
```

### 5.2 数据存储

- **图表配置数据**: 存储在本地SQLite，包括颜色主题、坐标轴配置、图例位置等
- **用户偏好设置**: 存储在本地Preferences，包括老年模式开关、高对比度开关、字体大小等
- **健康数据缓存**: 存储在SQLite，支持离线查看最近7天的数据

### 5.3 数据安全

- **敏感数据保护**: 健康数据在本地存储时加密，使用HarmonyOS提供的加密API
- **数据传输**: 所有健康数据传输使用HTTPS，敏感字段额外加密
- **数据脱敏**: 图表截图和分享时，自动脱敏用户个人信息

---

## 6. 接口需求

### 6.1 用户界面

#### UI-001: 无障碍模式切换界面
- 在"设置 > 无障碍"页面提供老年模式、高对比度模式、大字体模式开关
- 每个模式提供预览功能，用户可实时查看效果
- 提供一键恢复默认设置功能

#### UI-002: 图表通用交互界面
- 所有图表支持双指缩放、单指拖拽
- 点击数据点显示详细信息弹窗
- 长按数据点可进行标注或分享
- 提供图例开关、坐标轴开关等控制项

#### UI-003: 响应式布局
- 手机竖屏：图表宽度占满屏幕，高度自适应
- 手机横屏：图表高度占满屏幕，支持左右滑动查看多个图表
- 平板：支持2列或3列图表并排显示

### 6.2 系统接口

#### API-001: AccessibilityConfig接口
```typescript
interface AccessibilityConfig {
  // 获取当前无障碍配置
  getConfig(): AccessibilitySettings;
  
  // 应用无障碍配置
  applyConfig(settings: AccessibilitySettings): void;
  
  // 监听配置变化
  onConfigChange(callback: (settings: AccessibilitySettings) => void): void;
}

interface AccessibilitySettings {
  elderlyMode: boolean;        // 老年模式
  highContrastMode: boolean;   // 高对比度模式
  largeFontMode: boolean;      // 大字体模式
  fontSize: number;            // 字体大小(sp)
  minTouchTarget: number;      // 最小触控区域(dp)
  voiceGuidance: boolean;      // 语音引导
}
```

#### API-002: ChartComponent接口
```typescript
interface ChartComponent {
  // 设置数据
  setData(data: any): void;
  
  // 设置配置
  setConfig(config: ChartConfig): void;
  
  // 刷新图表
  refresh(): void;
  
  // 导出图片
  exportImage(format: 'png' | 'jpg'): Promise<string>;
  
  // 事件监听
  on(event: ChartEvent, callback: Function): void;
}

interface ChartConfig {
  width: number;               // 宽度
  height: number;              // 高度
  colors: string[];            // 颜色数组
  showLegend: boolean;         // 显示图例
  showAxis: boolean;           // 显示坐标轴
  animation: boolean;          // 启用动画
}
```

---

## 7. 约束条件

### 7.1 技术约束

- **开发语言**: 必须使用ArkTS，遵循HarmonyOS ArkUI规范
- **图表实现**: 优先使用Canvas自绘，避免依赖第三方库；如需使用，仅限轻量级库(<100KB)
- **无障碍API**: 必须使用HarmonyOS官方提供的无障碍API，不使用自定义实现
- **性能要求**: 所有图表渲染必须在UI线程完成，避免阻塞主线程

### 7.2 业务约束

- **WCAG标准**: 必须符合WCAG 2.1 AA级标准，不降低标准
- **数据隐私**: 健康数据展示需遵守《个人信息保护法》和《医疗健康数据安全指南》
- **用户同意**: 开启无障碍功能需用户明确授权，不得默认开启

### 7.3 时间约束

- **Phase 1 (需求规格)**: 1天完成
- **Phase 2 (技术设计)**: 1天完成
- **Phase 3 (任务规划)**: 0.5天完成
- **Phase 4 (开发实现)**: 3天完成
- **Phase 5 (测试验收)**: 1天完成

---

## 8. 验收标准汇总

| 需求ID | 需求描述 | 验收标准 | 优先级 | 状态 |
|--------|---------|---------|--------|------|
| FR-001 | 老年模式支持 | 字体≥20sp, 按钮≥48x48dp, 图标≥32x32dp | P0 | 待验证 |
| FR-002 | 高对比度模式 | 对比度≥4.5:1 (普通文字), ≥3:1 (大文字) | P0 | 待验证 |
| FR-003 | 屏幕阅读器支持 | 所有交互元素有accessibilityText和Description | P0 | 待验证 |
| FR-004 | 最小触控区域 | 触控区域≥44x44dp, 间距≥8dp | P0 | 待验证 |
| FR-005 | 操作撤销机制 | 关键操作有二次确认或撤销选项 | P1 | 待验证 |
| FR-006 | 简化操作流程 | 每步有指引, 提供进度提示, 支持返回 | P1 | 待验证 |
| FR-007 | 语音引导功能 | 重要事件语音播报, 语速可调 | P2 | 待验证 |
| FR-008 | 折线图组件 | 支持多系列, 缩放拖拽, 渲染<100ms | P0 | 待验证 |
| FR-009 | 柱状图组件 | 支持横纵向切换, 点击详情, 渲染<100ms | P0 | 待验证 |
| FR-010 | 雷达图组件 | 多维度标签数值, 悬停详情, 渲染<100ms | P0 | 待验证 |
| FR-011 | 仪表盘组件 | 颜色区分区域, 指针指向当前值, 渲染<100ms | P0 | 待验证 |
| FR-012 | 热力图组件 | 颜色深浅表示数值, 悬停查看, 渲染<100ms | P1 | 待验证 |
| FR-013 | 动态数据更新 | 数据更新后200ms内重绘, 动画平滑 | P0 | 待验证 |
| FR-014 | 图表交互功能 | 支持缩放、拖拽、点击、手势操作 | P1 | 待验证 |
| FR-015 | 响应式图表布局 | 自适应屏幕尺寸, 保持宽高比, 无信息丢失 | P0 | 待验证 |

---

## 9. 术语表

| 术语 | 定义 |
|-----|------|
| WCAG | Web Content Accessibility Guidelines，网页内容无障碍指南 |
| AA级 | WCAG标准的第二级别，要求较高的无障碍性 |
| dp | Density-independent Pixels，密度无关像素，Android/HarmonyOS布局单位 |
| sp | Scale-independent Pixels，缩放无关像素，用于字体大小 |
| 对比度 | 前景色与背景色的亮度比值，影响文字可读性 |
| 触控区域 | 可响应触摸操作的区域大小 |
| 屏幕阅读器 | 辅助技术，将屏幕内容转换为语音输出 |
| Canvas | 画布组件，用于自定义绘制图形 |
| 时间序列数据 | 按时间顺序排列的数据点序列 |
| 雷达图 | 多维度数据可视化图表，呈放射状 |
| 仪表盘 | 显示当前值在范围内的仪表式图表 |
| 热力图 | 用颜色深浅表示数值大小的二维图表 |

---

## 10. 附录

### 10.1 参考资料

- [WCAG 2.1 Guidelines](https://www.w3.org/TR/WCAG21/)
- [HarmonyOS Accessibility Development Guide](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/accessibility-overview-0000001053980525)
- [HarmonyOS Canvas API Reference](https://developer.harmonyos.com/cn/docs/documentation/doc-references/ts-components-canvas-canvas-0000001158301261)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)

### 10.2 变更历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|---------|
| v1.0 | 2026-04-27 | AI Assistant | 初始版本，定义无障碍设计和数据可视化需求 |
