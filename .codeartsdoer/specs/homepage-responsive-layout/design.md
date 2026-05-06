# 首页响应式布局开发 - 技术设计文档

**版本**: v1.0
**创建日期**: 2026-05-06
**最后更新**: 2026-05-06
**作者**: SDD Agent
**状态**: 草稿

## 1. 设计概述

### 1.1 设计目标
基于需求规格文档，设计并实现一个高性能、可维护的响应式首页布局系统，支持手机(sm)、平板(md)、二合一设备(lg)三种设备类型的自动适配，提供一致且优化的用户体验。

### 1.2 技术选型

| 技术组件 | 选型方案 | 选型理由 |
|---------|---------|---------|
| 开发语言 | ArkTS | HarmonyOS官方推荐，类型安全，性能优异 |
| UI框架 | ArkUI声明式 | 声明式UI开发效率高，支持响应式布局 |
| 断点系统 | BreakpointSystem | 已有实现，提供完整的断点计算和监听能力 |
| 状态管理 | @StorageLink/@State | ArkUI官方状态管理方案，响应式更新 |
| 路由导航 | router | ArkUI内置路由，支持页面跳转 |
| 布局组件 | Column/Row/Grid/Scroll | ArkUI核心布局组件，灵活强大 |

### 1.3 设计约束
- 必须兼容现有BreakpointSystem实现
- 必须保持与现有HomePage.ets的兼容性
- 禁止使用any类型，确保类型安全
- 页面加载时间 < 1秒
- 断点切换响应时间 < 100ms

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                    HomePage.ets                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │              @StorageLink                          │  │
│  │  - currentBreakpoint: BreakpointType              │  │
│  │  - isElderMode: boolean                           │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                               │
│  ┌───────────────────────────────────────────────────┐  │
│  │           BreakpointSystem (依赖)                  │  │
│  │  - getInstance()                                   │  │
│  │  - getGridColumns()                                │  │
│  │  - getFontSizeScale()                              │  │
│  │  - getScaledPadding()                              │  │
│  └───────────────────────────────────────────────────┘  │
│                          │                               │
│  ┌───────────────────────────────────────────────────┐  │
│  │              UI组件层                              │  │
│  │  ┌─────────────┐  ┌─────────────┐                │  │
│  │  │ Header      │  │ Scroll      │                │  │
│  │  └─────────────┘  └─────────────┘                │  │
│  │         │                  │                       │  │
│  │         │         ┌────────┴────────┐            │  │
│  │         │         │                 │            │  │
│  │  ┌──────┴──────┐  │  ┌────────────┐│            │  │
│  │  │WelcomeCard  │  │  │QuickActions││            │  │
│  │  └─────────────┘  │  └────────────┘│            │  │
│  │                    │  ┌────────────┐│            │  │
│  │                    │  │HealthTips  ││            │  │
│  │                    │  └────────────┘│            │  │
│  │                    └─────────────────┘            │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块名称 | 职责说明 | 文件位置 |
|---------|---------|---------|
| HomePage | 主页面组件，协调各子模块 | pages/HomePage.ets |
| BreakpointSystem | 断点计算和监听服务 | utils/BreakpointSystem.ets |
| Header | 顶部导航栏组件 | components/Header.ets |
| Footer | 底部导航栏组件 | components/Footer.ets |
| AccessibilityConfig | 无障碍配置管理 | utils/AccessibilityConfig.ets |

### 2.3 依赖关系

```
HomePage.ets
    ├── @kit.ArkUI (router)
    ├── components/Header
    ├── components/Footer
    ├── global/GlobalTheme
    ├── utils/AccessibilityConfig
    └── utils/BreakpointSystem
```

## 3. 模块详细设计

### 3.1 HomePage主组件

#### 3.1.1 职责定义
- 作为首页入口组件，负责整体布局编排
- 监听断点变化，动态调整布局参数
- 协调Header、WelcomeCard、QuickActions、HealthTips等子组件
- 处理功能入口的点击跳转逻辑

#### 3.1.2 类/接口设计

```typescript
@Entry
@Component
export struct HomePage {
  // 状态属性
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointType = BreakpointType.SM;
  @State currentIndex: number = 0;
  
  // 私有属性
  private theme: AccessibilityConfig = new AccessibilityConfig();
  private breakpointSystem: BreakpointSystem = BreakpointSystem.getInstance();
  private quickActions: QuickAction[] = [...];
  
  // 生命周期方法
  aboutToAppear(): void;
  
  // 布局计算方法
  private getGridColumnsTemplate(): string;
  private getContentMaxWidth(): number | string;
  private getHorizontalPadding(): number;
  private getCardPadding(): number;
  private getActionItemPadding(): number;
  private getIconFontSize(): number;
  private getTitleFontSize(): number;
  private getBodyFontSize(): number;
  private getSectionTitleFontSize(): number;
  
  // UI构建方法
  @Builder private buildWelcomeCard(): void;
  @Builder private buildQuickActions(): void;
  @Builder private buildHealthTips(): void;
  @Builder private buildActionItem(action: QuickAction): void;
  
  // 主构建方法
  build(): void;
}
```

#### 3.1.3 关键方法

**断点响应式计算方法**:

```typescript
// 获取Grid列模板
private getGridColumnsTemplate(): string {
  const columns = BreakpointConstants.QUICK_ACTION_COLUMNS[this.currentBreakpoint] ?? 4;
  return `1fr `.repeat(columns).trim();
}

// 获取内容最大宽度
private getContentMaxWidth(): number | string {
  if (this.currentBreakpoint === BreakpointType.LG) {
    return 840;
  } else if (this.currentBreakpoint === BreakpointType.MD) {
    return 600;
  }
  return '100%';
}

// 获取水平内边距(响应式)
private getHorizontalPadding(): number {
  return this.breakpointSystem.getScaledPadding(16);
}

// 获取标题字体大小(响应式)
private getTitleFontSize(): number {
  const base = this.isElderMode ? 24 : 20;
  return Math.round(base * this.breakpointSystem.getFontSizeScale());
}
```

**功能入口点击处理**:

```typescript
private handleActionClick(action: QuickAction): void {
  router.pushUrl({ url: action.route })
    .catch((err: Error) => {
      console.error(`路由跳转失败: ${err.message}`);
    });
}
```

#### 3.1.4 数据流

```
AppStorage
    │
    ├── currentBreakpoint ──→ HomePage.@StorageLink
    │                              │
    │                              ├── 触发布局重计算
    │                              │   ├── getGridColumnsTemplate()
    │                              │   ├── getContentMaxWidth()
    │                              │   ├── getHorizontalPadding()
    │                              │   └── get*FontSize()
    │                              │
    │                              └── 触发UI重渲染
    │
    └── isOldModeEnabled ──→ HomePage.@StorageLink
                                   │
                                   └── 触发字体大小调整
```

### 3.2 BreakpointSystem服务

#### 3.2.1 职责定义
- 提供断点类型枚举和常量定义
- 计算当前窗口宽度对应的断点类型
- 提供响应式布局参数计算方法
- 支持断点变化监听

#### 3.2.2 关键接口

```typescript
// 断点类型枚举
export enum BreakpointType {
  SM = 'sm',  // 小屏设备(手机) <= 600vp
  MD = 'md',  // 中屏设备(平板) 600-840vp
  LG = 'lg'   // 大屏设备(二合一) > 840vp
}

// 断点系统类
export class BreakpointSystem {
  // 单例获取
  static getInstance(): BreakpointSystem;
  
  // 断点查询
  getCurrentBreakpoint(): BreakpointType;
  isSM(): boolean;
  isMD(): boolean;
  isLG(): boolean;
  
  // 布局参数计算
  getGridColumns(): number;
  getGutter(): number;
  getQuickActionColumns(): number;
  getListColumns(): number;
  getCardSpan(): number;
  
  // 响应式缩放
  getFontSizeScale(): number;
  getIconSize(baseSize: number): number;
  getPaddingScale(): number;
  getScaledPadding(basePadding: number): number;
  
  // 监听器管理
  registerListener(id: string, callback: (bp: BreakpointType) => void): void;
  unregisterListener(id: string): void;
  updateBreakpoint(width: number): void;
}
```

### 3.3 数据模型设计

#### 3.3.1 核心数据结构

```typescript
// 功能入口数据模型
interface QuickAction {
  id: string;           // 唯一标识
  icon: string;         // 图标(emoji或资源引用)
  title: string;        // 标题
  color: string;        // 主题色(十六进制)
  route: string;        // 路由路径
}

// 健康提示数据模型
interface HealthTip {
  id: string;
  icon: string;
  title: string;
  description: string;
  color: string;
}

// 断点范围定义
interface BreakpointRange {
  type: BreakpointType;
  minWidth: number;
  maxWidth: number;
}
```

#### 3.3.2 常量定义

```typescript
// 断点常量
export class BreakpointConstants {
  static readonly SM_MAX_WIDTH: number = 600;
  static readonly MD_MAX_WIDTH: number = 840;
  
  // Grid列数配置
  static readonly GRID_COLUMNS: Record<string, number> = {
    [BreakpointType.SM]: 4,
    [BreakpointType.MD]: 8,
    [BreakpointType.LG]: 12
  };
  
  // 快捷操作列数配置
  static readonly QUICK_ACTION_COLUMNS: Record<string, number> = {
    [BreakpointType.SM]: 4,
    [BreakpointType.MD]: 4,
    [BreakpointType.LG]: 6
  };
  
  // 间距配置
  static readonly GUTTER: Record<string, number> = {
    [BreakpointType.SM]: 8,
    [BreakpointType.MD]: 12,
    [BreakpointType.LG]: 16
  };
  
  // 内容最大宽度
  static readonly CONTENT_MAX_WIDTH: Record<string, number> = {
    [BreakpointType.SM]: 360,
    [BreakpointType.MD]: 600,
    [BreakpointType.LG]: 840
  };
}
```

#### 3.3.3 数据关系

```
QuickAction[] (13个功能入口)
    │
    ├── 预定义在HomePage组件中
    │
    └── 通过Grid布局渲染
        │
        └── 点击触发router.pushUrl({ url: action.route })
```

## 4. API设计

### 4.1 内部API

**HomePage组件内部方法**:

| 方法签名 | 功能说明 | 调用时机 |
|---------|---------|---------|
| `getGridColumnsTemplate(): string` | 获取Grid列模板字符串 | build()时调用 |
| `getContentMaxWidth(): number \| string` | 获取内容区最大宽度 | build()时调用 |
| `getHorizontalPadding(): number` | 获取水平内边距 | build()时调用 |
| `getCardPadding(): number` | 获取卡片内边距 | build()时调用 |
| `getIconFontSize(): number` | 获取图标字体大小 | build()时调用 |
| `getTitleFontSize(): number` | 获取标题字体大小 | build()时调用 |
| `getBodyFontSize(): number` | 获取正文字体大小 | build()时调用 |

**@Builder装饰器方法**:

| 方法签名 | 功能说明 |
|---------|---------|
| `@Builder buildWelcomeCard(): void` | 构建欢迎卡片UI |
| `@Builder buildQuickActions(): void` | 构建快捷操作区UI |
| `@Builder buildHealthTips(): void` | 构建健康提示区UI |
| `@Builder buildActionItem(action: QuickAction): void` | 构建单个功能入口项UI |

### 4.2 外部API

**依赖的外部接口**:

| 接口来源 | 接口方法 | 用途 |
|---------|---------|------|
| BreakpointSystem | `getInstance()` | 获取断点系统单例 |
| BreakpointSystem | `getScaledPadding(base)` | 计算响应式内边距 |
| BreakpointSystem | `getFontSizeScale()` | 获取字体缩放比例 |
| BreakpointSystem | `getIconSize(base)` | 计算响应式图标大小 |
| router | `pushUrl(options)` | 页面路由跳转 |
| AppStorage | `setOrCreate(key, value)` | 全局状态存储 |

### 4.3 API规范

**路由跳转规范**:

```typescript
// 正确的路由跳转方式
router.pushUrl({ url: 'pages/HospitalPage' })
  .then(() => {
    console.info('路由跳转成功');
  })
  .catch((err: Error) => {
    console.error(`路由跳转失败: ${err.message}`);
    // 可选：显示错误提示
  });
```

**断点监听规范**:

```typescript
// 在aboutToAppear中注册监听
aboutToAppear(): void {
  this.breakpointSystem.registerListener('HomePage', (bp: BreakpointType) => {
    // 断点变化时的处理逻辑
    console.info(`断点变化: ${bp}`);
  });
}

// 在aboutToDisappear中注销监听
aboutToDisappear(): void {
  this.breakpointSystem.unregisterListener('HomePage');
}
```

## 5. 关键算法设计

### 5.1 断点计算算法

#### 算法原理
根据窗口宽度计算对应的断点类型，使用阈值比较法。

#### 伪代码

```
算法: calculateBreakpoint(width)
输入: width - 窗口宽度(vp)
输出: BreakpointType

1. IF width >= MD_MAX_WIDTH (840) THEN
2.     RETURN BreakpointType.LG
3. ELSE IF width >= SM_MAX_WIDTH (600) THEN
4.     RETURN BreakpointType.MD
5. ELSE
6.     RETURN BreakpointType.SM
7. END IF
```

#### 复杂度分析
- 时间复杂度: O(1)
- 空间复杂度: O(1)

### 5.2 响应式缩放算法

#### 算法原理
基于断点类型计算字体、图标、间距的缩放比例。

#### 伪代码

```
算法: getFontSizeScale()
输出: number - 字体缩放比例

1. SWITCH currentBreakpoint
2.     CASE BreakpointType.SM:
3.         RETURN 1.0
4.     CASE BreakpointType.MD:
5.         RETURN 1.05
6.     CASE BreakpointType.LG:
7.         RETURN 1.1
8.     DEFAULT:
9.         RETURN 1.0
10. END SWITCH

算法: getScaledPadding(basePadding)
输入: basePadding - 基础内边距
输出: number - 缩放后的内边距

1. scale ← getPaddingScale()
2. RETURN ROUND(basePadding * scale)
```

#### 复杂度分析
- 时间复杂度: O(1)
- 空间复杂度: O(1)

## 6. UI/UX设计

### 6.1 页面结构

```
HomePage
├── Header (固定高度)
│   ├── 返回按钮
│   ├── 标题 "智慧医疗健康平台"
│   └── 右侧操作区
│
└── Scroll (flex: 1)
    └── Column (内容容器)
        ├── WelcomeCard (欢迎卡片)
        │   ├── 用户头像
        │   ├── 问候语
        │   ├── 日期显示
        │   └── 健康数据统计
        │
        ├── QuickActions (快捷操作区)
        │   ├── 标题 "快捷操作"
        │   └── Grid (响应式列数)
        │       ├── ActionItem 1
        │       ├── ActionItem 2
        │       ├── ...
        │       └── ActionItem 13
        │
        └── HealthTips (健康提示区)
            ├── 标题 "健康提示"
            └── Scroll (横向)
                ├── TipCard 1
                ├── TipCard 2
                └── ...
```

### 6.2 组件设计

**WelcomeCard组件**:

| 属性 | 类型 | 说明 |
|-----|------|------|
| 用户头像 | Image | 48x48圆形头像 |
| 问候语 | Text | 根据时间动态生成 |
| 日期 | Text | 格式: YYYY年MM月DD日 星期X |
| 健康数据 | Row | 横向排列的健康指标 |

**ActionItem组件**:

| 属性 | 类型 | 说明 |
|-----|------|------|
| icon | Text | emoji图标，大小响应式 |
| title | Text | 功能标题，字体响应式 |
| color | string | 背景主题色 |
| onClick | () => void | 点击跳转处理 |

**响应式参数对照表**:

| 参数 | SM | MD | LG |
|-----|----|----|-----|
| Grid列数 | 4 | 4 | 6 |
| 内容最大宽度 | 100% | 600vp | 840vp |
| 水平内边距 | 16vp | 20vp | 24vp |
| 卡片内边距 | 20vp | 25vp | 30vp |
| 图标大小 | 28fp | 29fp | 31fp |
| 标题字体 | 20fp | 21fp | 22fp |
| 正文字体 | 14fp | 15fp | 15fp |

### 6.3 交互流程

**页面加载流程**:

```
用户打开应用
    │
    ├── EntryAbility.onCreate()
    │   └── 初始化BreakpointSystem
    │       └── AppStorage.setOrCreate('currentBreakpoint', bp)
    │
    ├── HomePage.aboutToAppear()
    │   ├── 读取currentBreakpoint
    │   ├── 读取isElderMode
    │   └── 注册断点监听器
    │
    └── HomePage.build()
        ├── 计算响应式参数
        └── 渲染UI组件
```

**断点变化流程**:

```
用户调整窗口大小
    │
    ├── BreakpointSystem.updateBreakpoint(width)
    │   ├── 计算新断点
    │   ├── 更新currentBreakpoint
    │   └── 触发监听器回调
    │
    ├── AppStorage更新
    │   └── 触发@StorageLink更新
    │
    └── HomePage重新渲染
        ├── 重新计算响应式参数
        └── 更新UI布局
```

**功能入口点击流程**:

```
用户点击ActionItem
    │
    ├── onClick事件触发
    │   └── router.pushUrl({ url: action.route })
    │
    └── 页面跳转
        ├── 成功: 打开目标页面
        └── 失败: 记录错误日志
```

## 7. 性能设计

### 7.1 性能目标

| 性能指标 | 目标值 | 测量方法 |
|---------|--------|---------|
| 页面加载时间 | < 1秒 | DevEco Studio性能分析 |
| 断点切换响应 | < 100ms | 手动调整窗口测量 |
| 首屏渲染时间 | < 500ms | DevEco Studio性能分析 |
| 内存占用 | < 50MB | DevEco Studio内存分析 |

### 7.2 优化策略

**1. 布局优化**:
- 使用`constraintSize`限制内容最大宽度，避免过度重排
- 使用`layoutWeight`替代固定高度，减少测量次数
- Grid布局使用预计算的列模板，避免动态计算

**2. 渲染优化**:
- 使用@Builder复用UI片段，减少组件实例化
- 避免在build()方法中进行复杂计算，提前在生命周期中计算
- 使用@StorageLink精确监听需要的状态，避免不必要的重渲染

**3. 内存优化**:
- 功能入口数据预定义为常量，避免重复创建
- 及时注销断点监听器，避免内存泄漏
- 使用单例模式管理BreakpointSystem，避免多实例

**4. 字体优化**:
- 字体大小使用fp单位，系统自动缩放
- 响应式字体缩放基于预定义比例，避免运行时计算

### 7.3 监控方案

**性能监控埋点**:

```typescript
// 页面加载时间监控
aboutToAppear(): void {
  const startTime = Date.now();
  // ... 初始化逻辑
  const loadTime = Date.now() - startTime;
  console.info(`HomePage加载时间: ${loadTime}ms`);
}

// 断点切换时间监控
private onBreakpointChange(bp: BreakpointType): void {
  const startTime = Date.now();
  // 断点变化处理
  const responseTime = Date.now() - startTime;
  console.info(`断点切换响应时间: ${responseTime}ms`);
}
```

## 8. 安全设计

### 8.1 数据安全
- 首页不展示敏感数据，无需加密
- 用户名显示前检查隐私设置
- 路由跳转使用白名单验证

### 8.2 权限控制
- 首页为公开页面，无需特殊权限
- 功能入口跳转时，目标页面自行检查权限

### 8.3 安全审计
- 路由跳转失败时记录错误日志
- 断点异常时记录警告日志
- 所有用户交互操作可追溯

## 9. 测试设计

### 9.1 测试策略

| 测试类型 | 测试重点 | 测试方法 |
|---------|---------|---------|
| 单元测试 | 响应式计算方法正确性 | Jest单元测试 |
| 集成测试 | 断点系统与HomePage集成 | DevEco Studio测试框架 |
| UI测试 | 多设备布局正确性 | 手动测试+模拟器 |
| 性能测试 | 加载时间和响应时间 | DevEco Studio性能分析 |

### 9.2 测试用例

**单元测试用例**:

```typescript
// 测试断点计算
test('calculateBreakpoint should return correct type', () => {
  expect(BreakpointSystem.calculateBreakpoint(500)).toBe(BreakpointType.SM);
  expect(BreakpointSystem.calculateBreakpoint(700)).toBe(BreakpointType.MD);
  expect(BreakpointSystem.calculateBreakpoint(1000)).toBe(BreakpointType.LG);
});

// 测试字体缩放
test('getFontSizeScale should return correct scale', () => {
  const bpSystem = BreakpointSystem.getInstance();
  bpSystem.updateBreakpoint(500);
  expect(bpSystem.getFontSizeScale()).toBe(1.0);
  
  bpSystem.updateBreakpoint(700);
  expect(bpSystem.getFontSizeScale()).toBe(1.05);
  
  bpSystem.updateBreakpoint(1000);
  expect(bpSystem.getFontSizeScale()).toBe(1.1);
});
```

**UI测试用例**:

| 测试场景 | 测试步骤 | 预期结果 |
|---------|---------|---------|
| 手机布局 | 在Phone模拟器打开首页 | Grid显示4列，字体适配小屏 |
| 平板布局 | 在Tablet模拟器打开首页 | Grid显示4列，字体适配中屏 |
| 二合一布局 | 在2in1模拟器打开首页 | Grid显示6列，字体适配大屏 |
| 断点切换 | 调整窗口大小跨越断点 | 布局自动调整，无闪烁 |
| 功能入口点击 | 点击任意功能入口卡片 | 正确跳转到目标页面 |

### 9.3 Mock数据

**功能入口Mock数据**:

```typescript
const mockQuickActions: QuickAction[] = [
  { id: 'appointment', icon: '📅', title: '预约挂号', color: '#3498DB', route: 'pages/HospitalPage' },
  { id: 'medical_record', icon: '📋', title: '病历档案', color: '#9B59B6', route: 'pages/MedicalRecord' },
  { id: 'health_report', icon: '📊', title: '体检报告', color: '#2ECC71', route: 'pages/ReportPage' },
  { id: 'medication', icon: '💊', title: '用药提醒', color: '#E74C3C', route: 'pages/MedicationPage' },
  { id: 'consultation', icon: '👨‍⚕️', title: '在线问诊', color: '#F39C12', route: 'pages/ConsultationPage' },
  { id: 'emergency', icon: '🚑', title: '急救指南', color: '#E67E22', route: 'pages/EmergencyPage' },
  { id: 'health_edu', icon: '📚', title: '健康科普', color: '#1ABC9C', route: 'pages/SciencePage' },
  { id: 'family_doctor', icon: '🏥', title: '家庭医生', color: '#34495E', route: 'pages/FamilyDoctorPage' },
  { id: 'insurance', icon: '🛡️', title: '医保服务', color: '#8E44AD', route: 'pages/InsurancePage' },
  { id: 'rehabilitation', icon: '🧘', title: '康复训练', color: '#16A085', route: 'pages/RehabilitationPage' },
  { id: 'ai_assistant', icon: '🤖', title: 'AI助手', color: '#2980B9', route: 'pages/AIAssistantPage' },
  { id: 'distributed', icon: '🔗', title: '跨院协同', color: '#D35400', route: 'pages/DistributedCollaborationPage' },
  { id: 'digital_twin', icon: '🫀', title: '数字孪生', color: '#C0392B', route: 'pages/DigitalTwinPage' }
];
```

## 10. 部署设计

### 10.1 环境要求

| 环境项 | 要求 |
|-------|------|
| HarmonyOS SDK | API 12及以上 |
| DevEco Studio | 4.0及以上 |
| Node.js | 14.x及以上 |
| 设备/模拟器 | Phone/Tablet/2in1 |

### 10.2 配置管理

**断点配置**:

```typescript
// 可在BreakpointConstants中调整断点阈值
export class BreakpointConstants {
  static readonly SM_MAX_WIDTH: number = 600;  // 可调整
  static readonly MD_MAX_WIDTH: number = 840;  // 可调整
}
```

**字体缩放配置**:

```typescript
// 可在BreakpointSystem中调整缩放比例
getFontSizeScale(): number {
  switch (this.currentBreakpoint) {
    case BreakpointType.SM:
      return 1.0;   // 可调整
    case BreakpointType.MD:
      return 1.05;  // 可调整
    case BreakpointType.LG:
      return 1.1;   // 可调整
    default:
      return 1.0;
  }
}
```

### 10.3 发布流程

```
1. 代码开发完成
   │
2. 本地测试验证
   ├── Phone模拟器测试
   ├── Tablet模拟器测试
   └── 2in1模拟器测试
   │
3. 代码审查
   │
4. 合并到主分支
   │
5. 构建HAP包
   └── hvigorw assembleHap --mode module -p product=default
   │
6. 签名打包
   │
7. 发布到应用市场/内部分发
```

## 11. 附录

### 11.1 术语表

| 术语 | 定义 |
|-----|------|
| ArkTS | HarmonyOS应用开发语言，TypeScript的超集 |
| ArkUI | HarmonyOS声明式UI框架 |
| @Entry | 页面入口装饰器 |
| @Component | 组件装饰器 |
| @State | 状态变量装饰器，触发UI刷新 |
| @StorageLink | 全局状态链接装饰器 |
| @Builder | UI构建方法装饰器，用于复用 |
| Breakpoint | 断点，响应式布局的屏幕宽度阈值 |
| vp | virtual pixel，虚拟像素，布局单位 |
| fp | font pixel，字体像素，字体单位 |

### 11.2 参考资料
- [HarmonyOS ArkUI开发文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkui-overview-0000001815367605)
- [BreakpointSystem源码](../entry/src/main/ets/utils/BreakpointSystem.ets)
- [项目规划总览V17.0.md](../项目规划总览V17.0.md)
- [需求规格文档](./spec.md)

### 11.3 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v1.0 | 2026-05-06 | 初始版本创建 | SDD Agent |
