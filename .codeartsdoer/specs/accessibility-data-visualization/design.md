# 无障碍友好界面与健康数据可视化 - 技术设计文档

**版本**: v1.0
**创建日期**: 2026-04-27
**最后更新**: 2026-04-27
**作者**: AI Assistant
**状态**: 草稿

---

## 1. 设计概述

### 1.1 设计目标

本技术设计文档旨在为"星云医疗助手"HarmonyOS应用提供以下技术方案：

1. **无障碍友好界面**：
   - 实现符合WCAG 2.1 AA级标准的无障碍设计系统
   - 提供可配置的无障碍模式（老年模式、高对比度模式、大字体模式）
   - 确保所有交互元素满足最小触控区域要求
   - 提供完整的屏幕阅读器支持

2. **健康数据可视化**：
   - 开发高性能的自绘图表组件库（折线图、柱状图、雷达图、仪表盘、热力图）
   - 实现动态数据更新和流畅的交互体验
   - 确保图表渲染性能<100ms，支持响应式布局
   - 提供统一的图表配置接口和数据格式规范

### 1.2 技术选型

| 技术领域 | 选型方案 | 选型理由 |
|---------|---------|---------|
| **开发语言** | ArkTS (TypeScript超集) | HarmonyOS官方推荐，类型安全，性能优秀 |
| **UI框架** | ArkUI (声明式UI) | 原生支持，性能最优，开发效率高 |
| **图表实现** | Canvas自绘 | 避免第三方依赖，性能可控，定制灵活 |
| **状态管理** | @State/@Prop/@Link | ArkUI原生状态管理，响应式更新 |
| **数据存储** | Preferences + RDB | Preferences存配置，RDB存缓存数据 |
| **无障碍API** | HarmonyOS Accessibility API | 官方API，兼容性最佳 |
| **性能监控** | HiPerf + Performance API | 官方工具，数据准确 |

### 1.3 设计约束

#### 技术约束
- 必须使用ArkTS，禁止使用JavaScript语法
- 图表组件必须基于Canvas自绘，不依赖第三方库
- 所有异步操作必须使用async/await，禁止回调地狱
- 禁止使用any类型，所有变量必须有明确类型

#### 性能约束
- 图表首次渲染时间<100ms
- 数据更新重绘时间<200ms
- 单个图表内存占用<5MB
- 列表滚动帧率≥55fps

#### 兼容性约束
- 支持HarmonyOS NEXT API 12+
- 适配手机(360-480dp)、平板(600-840dp)、折叠屏
- 兼容TalkBack屏幕阅读器

---

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    应用层 (Application Layer)                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Pages (98个页面)                                         │  │
│  │  ├─ HealthDataPage (健康数据页)                           │  │
│  │  ├─ RiskAssessmentPage (风险评估页)                       │  │
│  │  └─ SettingsPage (设置页 - 无障碍配置)                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    组件层 (Component Layer)                      │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │  无障碍组件           │  │  图表组件             │           │
│  │  ├─ AccessibleButton │  │  ├─ LineChart        │           │
│  │  ├─ AccessibleText   │  │  ├─ BarChart         │           │
│  │  ├─ AccessibleCard   │  │  ├─ RadarChart       │           │
│  │  └─ AccessibleDialog │  │  ├─ GaugeChart       │           │
│  │                      │  │  └─ HeatmapChart     │           │
│  └──────────────────────┘  └──────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    服务层 (Service Layer)                        │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │  AccessibilityService│  │  ChartService        │           │
│  │  ├─ config管理        │  │  ├─ 数据处理         │           │
│  │  ├─ 模式切换          │  │  ├─ 坐标计算         │           │
│  │  └─ 样式应用          │  │  └─ 渲染优化         │           │
│  └──────────────────────┘  └──────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    工具层 (Utility Layer)                        │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │  AccessibilityUtils  │  │  ChartUtils          │           │
│  │  ├─ 对比度计算        │  │  ├─ 数据验证         │           │
│  │  ├─ 尺寸转换          │  │  ├─ 颜色映射         │           │
│  │  └─ WCAG验证          │  │  └─ 动画插值         │           │
│  └──────────────────────┘  └──────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    数据层 (Data Layer)                           │
│  ┌──────────────────────┐  ┌──────────────────────┐           │
│  │  Preferences存储      │  │  RDB存储             │           │
│  │  ├─ 无障碍配置        │  │  ├─ 图表配置缓存     │           │
│  │  └─ 用户偏好          │  │  └─ 健康数据缓存     │           │
│  └──────────────────────┘  └──────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块名称 | 职责 | 文件路径 | 代码行数估算 |
|---------|------|---------|------------|
| **AccessibilityConfig** | 无障碍配置管理 | `common/accessibility/AccessibilityConfig.ets` | ~300行 |
| **AccessibleComponents** | 无障碍UI组件库 | `components/accessible/` | ~800行 |
| **ChartComponents** | 图表组件库 | `components/charts/` | ~2000行 |
| **ChartService** | 图表数据处理服务 | `service/ChartService.ets` | ~400行 |
| **ChartUtils** | 图表工具函数 | `utils/ChartUtils.ets` | ~500行 |
| **AccessibilityUtils** | 无障碍工具函数 | `utils/AccessibilityUtils.ets` | ~300行 |

### 2.3 依赖关系

```
Pages
  ├─→ AccessibleComponents (使用无障碍组件)
  ├─→ ChartComponents (使用图表组件)
  └─→ AccessibilityConfig (获取配置)

ChartComponents
  ├─→ ChartService (数据处理)
  ├─→ ChartUtils (工具函数)
  └─→ AccessibilityConfig (获取无障碍配置)

AccessibleComponents
  ├─→ AccessibilityConfig (获取配置)
  └─→ AccessibilityUtils (工具函数)

AccessibilityConfig
  └─→ Preferences (存储配置)

ChartService
  └─→ RDB (缓存数据)
```

---

## 3. 模块详细设计

### 3.1 AccessibilityConfig 模块

#### 3.1.1 职责定义
- 管理无障碍配置状态（老年模式、高对比度模式、大字体模式等）
- 提供配置的读取、写入、监听功能
- 应用配置到全局样式系统
- 持久化配置到本地存储

#### 3.1.2 类/接口设计

```typescript
// 无障碍配置接口
export interface AccessibilitySettings {
  elderlyMode: boolean;        // 老年模式
  highContrastMode: boolean;   // 高对比度模式
  largeFontMode: boolean;      // 大字体模式
  fontSize: number;            // 字体大小(sp)
  minTouchTarget: number;      // 最小触控区域(dp)
  voiceGuidance: boolean;      // 语音引导
  animationReduced: boolean;   // 减少动画
}

// 配置变更监听器
export type ConfigChangeListener = (settings: AccessibilitySettings) => void;

// AccessibilityConfig类
export class AccessibilityConfig {
  private static instance: AccessibilityConfig;
  private settings: AccessibilitySettings;
  private listeners: ConfigChangeListener[] = [];
  private preferences: Preferences | null = null;
  
  // 单例模式
  public static getInstance(): AccessibilityConfig;
  
  // 初始化配置（从Preferences加载）
  public async initialize(): Promise<void>;
  
  // 获取当前配置
  public getSettings(): AccessibilitySettings;
  
  // 更新配置
  public async updateSettings(newSettings: Partial<AccessibilitySettings>): Promise<void>;
  
  // 监听配置变化
  public addListener(listener: ConfigChangeListener): void;
  
  // 移除监听器
  public removeListener(listener: ConfigChangeListener): void;
  
  // 应用配置到全局样式
  private applySettings(): void;
  
  // 持久化配置
  private async persistSettings(): Promise<void>;
}
```

#### 3.1.3 关键方法

```typescript
/**
 * 更新无障碍配置
 * @param newSettings 新配置（部分字段）
 */
public async updateSettings(newSettings: Partial<AccessibilitySettings>): Promise<void> {
  // 1. 合并新旧配置
  this.settings = { ...this.settings, ...newSettings };
  
  // 2. 应用配置到全局样式
  this.applySettings();
  
  // 3. 通知所有监听器
  this.listeners.forEach(listener => listener(this.settings));
  
  // 4. 持久化到本地存储
  await this.persistSettings();
}

/**
 * 应用配置到全局样式
 */
private applySettings(): void {
  // 根据配置计算样式参数
  const fontSize = this.settings.elderlyMode ? 20 : 
                   this.settings.largeFontMode ? 18 : 16;
  
  const touchTarget = this.settings.elderlyMode ? 48 : 
                      this.settings.minTouchTarget;
  
  // 应用到全局样式系统（通过AppStorage）
  AppStorage.setOrCreate('fontSize', fontSize);
  AppStorage.setOrCreate('minTouchTarget', touchTarget);
  AppStorage.setOrCreate('highContrast', this.settings.highContrastMode);
}
```

#### 3.1.4 数据流

```
用户操作（开启老年模式）
  ↓
AccessibilityConfig.updateSettings({ elderlyMode: true })
  ↓
合并配置 → 应用样式 → 通知监听器 → 持久化存储
  ↓
所有使用@StorageLink的组件自动更新
```

---

### 3.2 ChartComponents 模块

#### 3.2.1 职责定义
- 提供统一的图表组件接口
- 实现折线图、柱状图、雷达图、仪表盘、热力图
- 支持动态数据更新和交互操作
- 确保渲染性能<100ms

#### 3.2.2 类/接口设计

```typescript
// 图表基础配置
export interface ChartConfig {
  width: number;               // 宽度(px)
  height: number;              // 高度(px)
  padding: [number, number, number, number]; // [top, right, bottom, left]
  backgroundColor: string;     // 背景色
  animation: boolean;          // 启用动画
  animationDuration: number;   // 动画时长(ms)
}

// 图表数据接口（泛型）
export interface ChartData<T> {
  data: T[];                   // 数据数组
  metadata?: Record<string, any>; // 元数据
}

// 图表事件
export interface ChartEvent {
  type: 'click' | 'longPress' | 'zoom' | 'pan';
  dataPoint?: any;             // 数据点信息
  position?: [number, number]; // 坐标位置
}

// 图表组件基类
export abstract class BaseChart<T> {
  protected config: ChartConfig;
  protected data: ChartData<T>;
  protected canvas: CanvasRenderingContext2D | null = null;
  protected animationProgress: number = 1;
  
  // 设置配置
  public setConfig(config: Partial<ChartConfig>): void;
  
  // 设置数据
  public setData(data: ChartData<T>): void;
  
  // 刷新图表
  public refresh(): void;
  
  // 导出图片
  public exportImage(format: 'png' | 'jpg'): Promise<string>;
  
  // 事件监听
  public on(event: string, callback: (e: ChartEvent) => void): void;
  
  // 绘制方法（子类实现）
  protected abstract draw(): void;
  
  // 计算坐标轴（子类实现）
  protected abstract calculateAxis(): void;
  
  // 动画渲染
  protected animateDraw(): void;
}
```

#### 3.2.3 折线图组件设计

```typescript
// 折线图数据点
export interface LineChartDataPoint {
  timestamp: number;           // 时间戳
  value: number;               // 数值
  label?: string;              // 标签
}

// 折线图系列
export interface LineChartSeries {
  name: string;                // 系列名称
  data: LineChartDataPoint[];  // 数据点
  color: string;               // 颜色
  lineWidth: number;           // 线宽
  showPoints: boolean;         // 显示数据点
}

// 折线图配置
export interface LineChartConfig extends ChartConfig {
  showGrid: boolean;           // 显示网格
  showAxis: boolean;           // 显示坐标轴
  showLegend: boolean;         // 显示图例
  xAxisFormat: (timestamp: number) => string; // X轴格式化
  yAxisFormat: (value: number) => string;     // Y轴格式化
  smooth: boolean;             // 平滑曲线
  fillArea: boolean;           // 填充区域
}

// 折线图组件
@Component
export struct LineChart {
  @Prop config: LineChartConfig;
  @Prop series: LineChartSeries[];
  @State private canvasWidth: number = 0;
  @State private canvasHeight: number = 0;
  
  private settings: CanvasRenderingContext2D;
  private chartRenderer: LineChartRenderer;
  
  build() {
    Column() {
      Canvas(this.settings)
        .width(this.canvasWidth)
        .height(this.canvasHeight)
        .onReady(() => {
          this.onCanvasReady();
        })
        .onClick((e) => {
          this.onCanvasClick(e);
        })
    }
  }
  
  private onCanvasReady(): void {
    // 初始化渲染器
    this.chartRenderer = new LineChartRenderer(
      this.settings,
      this.config,
      this.series
    );
    
    // 绘制图表
    this.chartRenderer.draw();
  }
}
```

#### 3.2.4 雷达图组件设计

```typescript
// 雷达图维度数据
export interface RadarChartDimension {
  name: string;                // 维度名称
  value: number;               // 当前值
  maxValue: number;            // 最大值
  description?: string;        // 描述
}

// 雷达图配置
export interface RadarChartConfig extends ChartConfig {
  dimensions: RadarChartDimension[]; // 维度数组
  showLabels: boolean;         // 显示标签
  showValues: boolean;         // 显示数值
  levels: number;              // 网格层数
  shape: 'polygon' | 'circle'; // 形状
  fillColor: string;           // 填充色
  strokeColor: string;         // 描边色
}

// 雷达图渲染器
export class RadarChartRenderer {
  private ctx: CanvasRenderingContext2D;
  private config: RadarChartConfig;
  private centerX: number = 0;
  private centerY: number = 0;
  private radius: number = 0;
  
  constructor(ctx: CanvasRenderingContext2D, config: RadarChartConfig) {
    this.ctx = ctx;
    this.config = config;
    this.calculateLayout();
  }
  
  // 计算布局
  private calculateLayout(): void {
    const { width, height, padding } = this.config;
    this.centerX = width / 2;
    this.centerY = height / 2;
    this.radius = Math.min(
      (width - padding[1] - padding[3]) / 2,
      (height - padding[0] - padding[2]) / 2
    );
  }
  
  // 绘制雷达图
  public draw(): void {
    this.drawBackground();
    this.drawGrid();
    this.drawAxes();
    this.drawData();
    this.drawLabels();
  }
  
  // 绘制网格
  private drawGrid(): void {
    const { levels, dimensions, shape } = this.config;
    const angleStep = (2 * Math.PI) / dimensions.length;
    
    for (let level = 1; level <= levels; level++) {
      const levelRadius = (this.radius / levels) * level;
      
      this.ctx.beginPath();
      for (let i = 0; i < dimensions.length; i++) {
        const angle = angleStep * i - Math.PI / 2;
        const x = this.centerX + levelRadius * Math.cos(angle);
        const y = this.centerY + levelRadius * Math.sin(angle);
        
        if (i === 0) {
          this.ctx.moveTo(x, y);
        } else {
          this.ctx.lineTo(x, y);
        }
      }
      this.ctx.closePath();
      this.ctx.stroke();
    }
  }
  
  // 绘制数据区域
  private drawData(): void {
    const { dimensions, fillColor, strokeColor } = this.config;
    const angleStep = (2 * Math.PI) / dimensions.length;
    
    this.ctx.beginPath();
    for (let i = 0; i < dimensions.length; i++) {
      const { value, maxValue } = dimensions[i];
      const ratio = value / maxValue;
      const angle = angleStep * i - Math.PI / 2;
      const x = this.centerX + this.radius * ratio * Math.cos(angle);
      const y = this.centerY + this.radius * ratio * Math.sin(angle);
      
      if (i === 0) {
        this.ctx.moveTo(x, y);
      } else {
        this.ctx.lineTo(x, y);
      }
    }
    this.ctx.closePath();
    
    this.ctx.fillStyle = fillColor;
    this.ctx.fill();
    this.ctx.strokeStyle = strokeColor;
    this.ctx.stroke();
  }
}
```

---

### 3.3 ChartService 模块

#### 3.3.1 职责定义
- 处理图表数据（格式转换、数据验证、异常处理）
- 计算坐标轴范围和刻度
- 提供数据缓存机制
- 优化渲染性能

#### 3.3.2 类/接口设计

```typescript
export class ChartService {
  private static instance: ChartService;
  private dataCache: Map<string, any> = new Map();
  
  // 单例模式
  public static getInstance(): ChartService;
  
  // 处理时间序列数据
  public processTimeSeriesData(
    rawData: any[],
    options: TimeSeriesOptions
  ): LineChartSeries[];
  
  // 计算坐标轴范围
  public calculateAxisRange(
    data: number[],
    options: AxisOptions
  ): { min: number; max: number; ticks: number[] };
  
  // 数据聚合（降采样）
  public aggregateData(
    data: TimeSeriesDataPoint[],
    interval: 'hour' | 'day' | 'week' | 'month'
  ): TimeSeriesDataPoint[];
  
  // 数据验证
  public validateData(data: any, schema: DataSchema): boolean;
  
  // 获取缓存数据
  public getCachedData(key: string): any;
  
  // 设置缓存数据
  public setCachedData(key: string, data: any, ttl?: number): void;
}

// 时间序列处理选项
export interface TimeSeriesOptions {
  startTime: number;           // 开始时间
  endTime: number;             // 结束时间
  interval: 'hour' | 'day' | 'week' | 'month'; // 时间间隔
  aggregation: 'avg' | 'max' | 'min' | 'sum';  // 聚合方式
  fillMissing: boolean;        // 填充缺失值
}

// 坐标轴选项
export interface AxisOptions {
  min?: number;                // 最小值（可选）
  max?: number;                // 最大值（可选）
  tickCount: number;           // 刻度数量
  nice: boolean;               // 美化刻度
  format: (value: number) => string; // 格式化函数
}
```

#### 3.3.3 关键方法

```typescript
/**
 * 计算坐标轴范围和刻度
 * 使用"nice numbers"算法生成美观的刻度
 */
public calculateAxisRange(
  data: number[],
  options: AxisOptions
): { min: number; max: number; ticks: number[] } {
  // 1. 确定数据范围
  let min = options.min ?? Math.min(...data);
  let max = options.max ?? Math.max(...data);
  
  // 2. 计算刻度范围（nice numbers算法）
  const range = this.niceNumber(max - min, false);
  const tickSpacing = this.niceNumber(range / (options.tickCount - 1), true);
  
  // 3. 调整最小值和最大值
  if (options.nice) {
    min = Math.floor(min / tickSpacing) * tickSpacing;
    max = Math.ceil(max / tickSpacing) * tickSpacing;
  }
  
  // 4. 生成刻度数组
  const ticks: number[] = [];
  for (let tick = min; tick <= max; tick += tickSpacing) {
    ticks.push(tick);
  }
  
  return { min, max, ticks };
}

/**
 * Nice number算法
 * 计算接近目标值的美观数字
 */
private niceNumber(range: number, round: boolean): number {
  const exponent = Math.floor(Math.log10(range));
  const fraction = range / Math.pow(10, exponent);
  
  let niceFraction: number;
  if (round) {
    if (fraction < 1.5) niceFraction = 1;
    else if (fraction < 3) niceFraction = 2;
    else if (fraction < 7) niceFraction = 5;
    else niceFraction = 10;
  } else {
    if (fraction <= 1) niceFraction = 1;
    else if (fraction <= 2) niceFraction = 2;
    else if (fraction <= 5) niceFraction = 5;
    else niceFraction = 10;
  }
  
  return niceFraction * Math.pow(10, exponent);
}
```

---

## 4. 数据模型设计

### 4.1 核心数据结构

```typescript
// ==================== 无障碍配置数据 ====================

export interface AccessibilitySettings {
  elderlyMode: boolean;        // 老年模式
  highContrastMode: boolean;   // 高对比度模式
  largeFontMode: boolean;      // 大字体模式
  fontSize: number;            // 字体大小(sp)
  minTouchTarget: number;      // 最小触控区域(dp)
  voiceGuidance: boolean;      // 语音引导
  animationReduced: boolean;   // 减少动画
}

// ==================== 图表数据 ====================

// 时间序列数据点
export interface TimeSeriesDataPoint {
  timestamp: number;           // 时间戳(ms)
  value: number;               // 数值
  label?: string;              // 可选标签
}

// 折线图系列
export interface LineChartSeries {
  name: string;                // 系列名称
  data: TimeSeriesDataPoint[]; // 数据点数组
  color: string;               // 颜色(HEX)
  lineWidth: number;           // 线宽(px)
  showPoints: boolean;         // 显示数据点
}

// 柱状图数据项
export interface BarChartDataItem {
  category: string;            // 类别名称
  value: number;               // 数值
  color?: string;              // 颜色(可选)
}

// 雷达图维度
export interface RadarChartDimension {
  name: string;                // 维度名称
  value: number;               // 当前值
  maxValue: number;            // 最大值
  description?: string;        // 描述
}

// 仪表盘数据
export interface GaugeChartData {
  currentValue: number;        // 当前值
  minValue: number;            // 最小值
  maxValue: number;            // 最大值
  normalRange: [number, number];  // 正常范围
  warningRange?: [number, number]; // 警告范围(可选)
  dangerRange?: [number, number];  // 危险范围(可选)
  unit: string;                // 单位
}

// 热力图数据
export interface HeatmapDataPoint {
  row: number;                 // 行索引
  col: number;                 // 列索引
  value: number;               // 数值
  label?: string;              // 标签(可选)
}

// ==================== 图表配置 ====================

// 基础图表配置
export interface BaseChartConfig {
  width: number;               // 宽度(px)
  height: number;              // 高度(px)
  padding: [number, number, number, number]; // [top, right, bottom, left]
  backgroundColor: string;     // 背景色
  animation: boolean;          // 启用动画
  animationDuration: number;   // 动画时长(ms)
}

// 折线图配置
export interface LineChartConfig extends BaseChartConfig {
  showGrid: boolean;           // 显示网格
  showAxis: boolean;           // 显示坐标轴
  showLegend: boolean;         // 显示图例
  smooth: boolean;             // 平滑曲线
  fillArea: boolean;           // 填充区域
}

// 柱状图配置
export interface BarChartConfig extends BaseChartConfig {
  showGrid: boolean;           // 显示网格
  showAxis: boolean;           // 显示坐标轴
  showLegend: boolean;         // 显示图例
  horizontal: boolean;         // 横向柱状图
  barWidth: number;            // 柱宽(px)
  barGap: number;              // 柱间距(px)
}

// 雷达图配置
export interface RadarChartConfig extends BaseChartConfig {
  showLabels: boolean;         // 显示标签
  showValues: boolean;         // 显示数值
  levels: number;              // 网格层数
  shape: 'polygon' | 'circle'; // 形状
  fillColor: string;           // 填充色
  strokeColor: string;         // 描边色
}

// 仪表盘配置
export interface GaugeChartConfig extends BaseChartConfig {
  startAngle: number;          // 起始角度(度)
  endAngle: number;            // 结束角度(度)
  showValue: boolean;          // 显示数值
  showLabel: boolean;          // 显示标签
  normalColor: string;         // 正常区域颜色
  warningColor: string;        // 警告区域颜色
  dangerColor: string;         // 危险区域颜色
}

// 热力图配置
export interface HeatmapChartConfig extends BaseChartConfig {
  rows: number;                // 行数
  cols: number;                // 列数
  cellWidth: number;           // 单元格宽(px)
  cellHeight: number;          // 单元格高(px)
  colorScale: string[];        // 颜色渐变数组
  showLabels: boolean;         // 显示标签
}
```

### 4.2 数据关系

```
AccessibilitySettings (配置)
  ↓ 应用到
AccessibleComponent (组件)
  ├─ AccessibleButton
  ├─ AccessibleText
  └─ AccessibleCard

ChartConfig (配置)
  ↓ 应用到
ChartComponent (组件)
  ├─ LineChart ← LineChartSeries[]
  ├─ BarChart ← BarChartDataItem[]
  ├─ RadarChart ← RadarChartDimension[]
  ├─ GaugeChart ← GaugeChartData
  └─ HeatmapChart ← HeatmapDataPoint[]

ChartService (服务)
  ↓ 处理
RawData (原始数据)
  ↓ 转换为
ChartData (图表数据)
```

### 4.3 数据存储

#### Preferences存储（无障碍配置）
```typescript
// 存储键名
const ACCESSIBILITY_CONFIG_KEY = 'accessibility_config';

// 存储结构
{
  "accessibility_config": {
    "elderlyMode": false,
    "highContrastMode": false,
    "largeFontMode": false,
    "fontSize": 16,
    "minTouchTarget": 44,
    "voiceGuidance": false,
    "animationReduced": false
  }
}
```

#### RDB存储（图表配置缓存）
```sql
-- 图表配置缓存表
CREATE TABLE IF NOT EXISTS chart_config_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  chart_type TEXT NOT NULL,        -- 图表类型
  config_key TEXT NOT NULL,        -- 配置键
  config_value TEXT NOT NULL,      -- 配置值(JSON)
  created_at INTEGER NOT NULL,     -- 创建时间
  updated_at INTEGER NOT NULL      -- 更新时间
);

-- 健康数据缓存表
CREATE TABLE IF NOT EXISTS health_data_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  data_type TEXT NOT NULL,         -- 数据类型(heart_rate, blood_pressure等)
  data_value TEXT NOT NULL,        -- 数据值(JSON)
  timestamp INTEGER NOT NULL,      -- 时间戳
  expires_at INTEGER NOT NULL      -- 过期时间
);
```

---

## 5. API设计

### 5.1 内部API

#### AccessibilityConfig API

```typescript
// 获取单例实例
const config = AccessibilityConfig.getInstance();

// 初始化
await config.initialize();

// 获取当前配置
const settings = config.getSettings();

// 更新配置
await config.updateSettings({
  elderlyMode: true,
  fontSize: 20
});

// 监听配置变化
config.addListener((newSettings) => {
  console.log('配置已更新:', newSettings);
});
```

#### ChartService API

```typescript
// 获取单例实例
const chartService = ChartService.getInstance();

// 处理时间序列数据
const series = chartService.processTimeSeriesData(rawData, {
  startTime: Date.now() - 7 * 24 * 3600 * 1000,
  endTime: Date.now(),
  interval: 'day',
  aggregation: 'avg',
  fillMissing: true
});

// 计算坐标轴范围
const axisRange = chartService.calculateAxisRange([120, 130, 125, 140], {
  tickCount: 5,
  nice: true,
  format: (v) => v.toFixed(0)
});

// 数据聚合
const aggregated = chartService.aggregateData(dataPoints, 'day');

// 数据验证
const isValid = chartService.validateData(data, {
  type: 'array',
  items: {
    type: 'object',
    properties: {
      timestamp: { type: 'number' },
      value: { type: 'number' }
    }
  }
});
```

### 5.2 组件API

#### LineChart组件

```typescript
@Component
export struct LineChart {
  // 配置属性
  @Prop config: LineChartConfig = {
    width: 300,
    height: 200,
    padding: [20, 20, 40, 50],
    backgroundColor: '#ffffff',
    animation: true,
    animationDuration: 300,
    showGrid: true,
    showAxis: true,
    showLegend: true,
    smooth: true,
    fillArea: false
  };
  
  // 数据属性
  @Prop series: LineChartSeries[] = [];
  
  // 事件回调
  private onDataPointClick?: (point: TimeSeriesDataPoint) => void;
  
  // 公共方法
  public refresh(): void;
  public exportImage(format: 'png' | 'jpg'): Promise<string>;
}
```

#### RadarChart组件

```typescript
@Component
export struct RadarChart {
  // 配置属性
  @Prop config: RadarChartConfig = {
    width: 300,
    height: 300,
    padding: [40, 40, 40, 40],
    backgroundColor: '#ffffff',
    animation: true,
    animationDuration: 500,
    showLabels: true,
    showValues: true,
    levels: 5,
    shape: 'polygon',
    fillColor: 'rgba(54, 162, 235, 0.2)',
    strokeColor: '#36a2eb'
  };
  
  // 维度数据
  @Prop dimensions: RadarChartDimension[] = [];
  
  // 公共方法
  public refresh(): void;
  public exportImage(format: 'png' | 'jpg'): Promise<string>;
}
```

### 5.3 API规范

#### 请求格式
```typescript
// 图表数据请求
interface ChartDataRequest {
  chartType: 'line' | 'bar' | 'radar' | 'gauge' | 'heatmap';
  dataType: string;            // 数据类型(heart_rate, blood_pressure等)
  timeRange?: {                // 时间范围(可选)
    start: number;
    end: number;
  };
  aggregation?: 'avg' | 'max' | 'min' | 'sum'; // 聚合方式(可选)
}
```

#### 响应格式
```typescript
// 图表数据响应
interface ChartDataResponse<T> {
  success: boolean;            // 是否成功
  data?: T;                    // 数据(成功时)
  error?: {                    // 错误信息(失败时)
    code: string;
    message: string;
  };
  metadata?: {                 // 元数据(可选)
    totalCount: number;
    timeRange: [number, number];
    lastUpdate: number;
  };
}
```

---

## 6. 关键算法设计

### 6.1 Nice Numbers算法（坐标轴刻度计算）

#### 算法原理
Nice Numbers算法用于生成美观的坐标轴刻度，避免出现如"0, 13, 26, 39"这样的不美观刻度，而是生成"0, 10, 20, 30"这样的整齐刻度。

#### 伪代码
```
function niceNumber(range, round):
    exponent = floor(log10(range))
    fraction = range / 10^exponent
    
    if round:
        if fraction < 1.5: niceFraction = 1
        else if fraction < 3: niceFraction = 2
        else if fraction < 7: niceFraction = 5
        else: niceFraction = 10
    else:
        if fraction <= 1: niceFraction = 1
        else if fraction <= 2: niceFraction = 2
        else if fraction <= 5: niceFraction = 5
        else: niceFraction = 10
    
    return niceFraction * 10^exponent
```

#### 复杂度分析
- 时间复杂度: O(1)
- 空间复杂度: O(1)

### 6.2 数据降采样算法（LTTB）

#### 算法原理
Largest-Triangle-Three-Buckets (LTTB)算法用于对时间序列数据进行降采样，在保留数据视觉特征的同时减少数据点数量，提升渲染性能。

#### 伪代码
```
function LTTB(data, threshold):
    if length(data) <= threshold:
        return data
    
    sampled = [data[0]]  // 保留第一个点
    
    // 每个桶的大小
    bucketSize = (length(data) - 2) / (threshold - 2)
    
    for i from 0 to threshold - 2:
        // 计算当前桶的范围
        start = floor((i) * bucketSize) + 1
        end = floor((i + 1) * bucketSize) + 1
        
        // 计算下一个桶的平均点
        nextAvg = calculateAverage(data, end, min(end + bucketSize, length(data) - 1))
        
        // 在当前桶中选择形成最大三角形面积的点
        maxArea = -1
        maxAreaIndex = start
        
        for j from start to end - 1:
            area = calculateTriangleArea(sampled[-1], data[j], nextAvg)
            if area > maxArea:
                maxArea = area
                maxAreaIndex = j
        
        sampled.append(data[maxAreaIndex])
    
    sampled.append(data[-1])  // 保留最后一个点
    return sampled
```

#### 复杂度分析
- 时间复杂度: O(n)，其中n为原始数据点数量
- 空间复杂度: O(threshold)，其中threshold为降采样后的数据点数量

### 6.3 颜色对比度计算算法

#### 算法原理
根据WCAG 2.1标准，计算两种颜色的相对亮度，然后计算对比度比率。

#### 伪代码
```
function calculateContrastRatio(color1, color2):
    // 计算相对亮度
    L1 = calculateRelativeLuminance(color1)
    L2 = calculateRelativeLuminance(color2)
    
    // 计算对比度比率
    if L1 > L2:
        return (L1 + 0.05) / (L2 + 0.05)
    else:
        return (L2 + 0.05) / (L1 + 0.05)

function calculateRelativeLuminance(color):
    // 转换RGB到sRGB
    R = color.R / 255
    G = color.G / 255
    B = color.B / 255
    
    // 应用gamma校正
    R = (R <= 0.03928) ? R / 12.92 : ((R + 0.055) / 1.055)^2.4
    G = (G <= 0.03928) ? G / 12.92 : ((G + 0.055) / 1.055)^2.4
    B = (B <= 0.03928) ? B / 12.92 : ((B + 0.055) / 1.055)^2.4
    
    // 计算相对亮度
    return 0.2126 * R + 0.7152 * G + 0.0722 * B
```

#### 复杂度分析
- 时间复杂度: O(1)
- 空间复杂度: O(1)

---

## 7. UI/UX设计

### 7.1 页面结构

```
设置页面 (SettingsPage)
  └─ 无障碍设置 (AccessibilitySettings)
      ├─ 老年模式开关
      ├─ 高对比度模式开关
      ├─ 大字体模式开关
      ├─ 字体大小滑块
      ├─ 最小触控区域设置
      ├─ 语音引导开关
      └─ 减少动画开关

健康数据页面 (HealthDataPage)
  ├─ 心率监测卡片
  │   └─ 折线图 (LineChart)
  ├─ 血压监测卡片
  │   └─ 仪表盘 (GaugeChart)
  ├─ 健康评分卡片
  │   └─ 雷达图 (RadarChart)
  └─ 活动分布卡片
      └─ 热力图 (HeatmapChart)

风险评估页面 (RiskAssessmentPage)
  ├─ 综合评分
  │   └─ 雷达图 (RadarChart)
  ├─ 历史趋势
  │   └─ 折线图 (LineChart)
  └─ 风险对比
      └─ 柱状图 (BarChart)
```

### 7.2 组件设计

#### AccessibleButton组件

```typescript
@Component
export struct AccessibleButton {
  @StorageLink('minTouchTarget') minTouchTarget: number = 44;
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  
  @Prop text: string;
  @Prop onClick: () => void;
  @Prop icon?: Resource;
  @Prop disabled: boolean = false;
  
  build() {
    Button(this.text)
      .width(this.minTouchTarget)
      .height(this.minTouchTarget)
      .fontSize(this.fontSize)
      .fontColor(this.highContrast ? '#000000' : '#ffffff')
      .backgroundColor(this.highContrast ? '#ffffff' : '#3498db')
      .borderRadius(8)
      .accessibilityText(this.text)
      .accessibilityDescription(this.disabled ? '按钮已禁用' : '点击' + this.text)
      .accessibilityLevel('important')
      .onClick(() => {
        if (!this.disabled) {
          this.onClick();
        }
      })
  }
}
```

#### ChartContainer组件（图表容器）

```typescript
@Component
export struct ChartContainer {
  @Prop title: string;
  @Prop chartType: 'line' | 'bar' | 'radar' | 'gauge' | 'heatmap';
  @Prop showToolbar: boolean = true;
  
  @State private isLoading: boolean = false;
  @State private hasError: boolean = false;
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        
        if (this.showToolbar) {
          Blank()
          
          // 工具栏
          Row() {
            Button('刷新')
              .onClick(() => this.refresh())
            
            Button('导出')
              .onClick(() => this.export())
          }
        }
      }
      .width('100%')
      .padding(16)
      
      // 图表区域
      if (this.isLoading) {
        // 加载状态
        LoadingProgress()
          .width(100)
          .height(100)
      } else if (this.hasError) {
        // 错误状态
        Text('数据加载失败')
          .fontColor('#e74c3c')
      } else {
        // 图表内容
        this.buildChart();
      }
    }
    .backgroundColor('#ffffff')
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)' })
  }
  
  @Builder
  buildChart() {
    // 根据chartType渲染对应图表
    if (this.chartType === 'line') {
      LineChart({ /* config */ });
    } else if (this.chartType === 'radar') {
      RadarChart({ /* config */ });
    }
    // ... 其他图表类型
  }
}
```

### 7.3 交互流程

#### 无障碍模式切换流程

```
用户点击"老年模式"开关
  ↓
AccessibilityConfig.updateSettings({ elderlyMode: true })
  ↓
应用新配置到全局样式
  ├─ fontSize: 20sp
  ├─ minTouchTarget: 48dp
  └─ animationDuration: 0ms
  ↓
通知所有监听器
  ↓
所有使用@StorageLink的组件自动更新
  ├─ AccessibleButton: 尺寸增大
  ├─ AccessibleText: 字体增大
  └─ 所有图表: 字体增大
  ↓
持久化配置到Preferences
  ↓
显示Toast提示: "老年模式已开启"
```

#### 图表数据更新流程

```
健康数据更新（如心率测量）
  ↓
ChartService.processTimeSeriesData(rawData, options)
  ├─ 数据验证
  ├─ 数据清洗
  ├─ 数据聚合
  └─ 数据降采样
  ↓
返回处理后的ChartData
  ↓
图表组件接收新数据
  ↓
触发重新渲染
  ├─ 清空Canvas
  ├─ 计算坐标轴
  ├─ 绘制网格
  ├─ 绘制数据
  └─ 绘制标签
  ↓
动画过渡（如果启用）
  ↓
渲染完成，耗时<100ms
```

---

## 8. 性能设计

### 8.1 性能目标

| 性能指标 | 目标值 | 测量方法 |
|---------|-------|---------|
| 图表首次渲染时间 | <100ms | Performance API |
| 图表重绘时间 | <200ms | Performance API |
| 列表滚动帧率 | ≥55fps | HiPerf工具 |
| 单个图表内存占用 | <5MB | DevEco内存分析 |
| 所有图表总内存 | <50MB | DevEco内存分析 |
| 冷启动时间 | <2s | 系统日志 |
| 交互响应时间 | <300ms | Performance API |

### 8.2 优化策略

#### 8.2.1 渲染优化

```typescript
// 1. 使用requestAnimationFrame进行动画渲染
function animateDraw() {
  const startTime = performance.now();
  
  const animate = (timestamp: number) => {
    const progress = (timestamp - startTime) / this.config.animationDuration;
    
    if (progress < 1) {
      this.drawFrame(progress);
      requestAnimationFrame(animate);
    } else {
      this.drawFrame(1);
    }
  };
  
  requestAnimationFrame(animate);
}

// 2. 使用离屏Canvas进行预渲染
const offscreenCanvas = new OffscreenCanvas(width, height);
const offscreenCtx = offscreenCanvas.getContext('2d');

// 在离屏Canvas上绘制
drawToOffscreen(offscreenCtx);

// 一次性绘制到主Canvas
mainCtx.drawImage(offscreenCanvas, 0, 0);

// 3. 使用Path2D进行批量绘制
const path = new Path2D();
dataPoints.forEach(point => {
  path.lineTo(point.x, point.y);
});
ctx.stroke(path);
```

#### 8.2.2 数据优化

```typescript
// 1. 数据降采样（LTTB算法）
const sampledData = LTTB(rawData, 500); // 降采样到500个点

// 2. 数据缓存
const cacheKey = `chart_${chartType}_${dataType}_${timeRange}`;
const cachedData = chartService.getCachedData(cacheKey);
if (cachedData) {
  return cachedData;
}

// 3. 增量更新
if (prevData && newData) {
  const incrementalData = calculateIncrement(prevData, newData);
  updateChartIncrementally(incrementalData);
}
```

#### 8.2.3 内存优化

```typescript
// 1. 及时释放Canvas资源
aboutToDisappear() {
  if (this.canvas) {
    this.canvas = null;
  }
  if (this.chartRenderer) {
    this.chartRenderer.dispose();
    this.chartRenderer = null;
  }
}

// 2. 使用对象池复用对象
const pointPool = new ObjectPool<Point>(() => ({ x: 0, y: 0 }));

function getDataPoint(x: number, y: number): Point {
  const point = pointPool.acquire();
  point.x = x;
  point.y = y;
  return point;
}

// 3. 避免内存泄漏
private listeners: (() => void)[] = [];

aboutToDisappear() {
  // 清除所有监听器
  this.listeners.forEach(listener => {
    eventBus.off('dataUpdate', listener);
  });
  this.listeners = [];
}
```

### 8.3 监控方案

```typescript
// 性能监控装饰器
function measurePerformance(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;
  
  descriptor.value = function(...args: any[]) {
    const startTime = performance.now();
    const result = originalMethod.apply(this, args);
    
    const endTime = performance.now();
    const duration = endTime - startTime;
    
    // 记录性能数据
    PerformanceMonitor.record({
      method: propertyKey,
      duration,
      timestamp: Date.now()
    });
    
    // 超过阈值告警
    if (duration > 100) {
      console.warn(`性能告警: ${propertyKey} 耗时 ${duration.toFixed(2)}ms`);
    }
    
    return result;
  };
  
  return descriptor;
}

// 使用装饰器
class ChartRenderer {
  @measurePerformance
  public draw(): void {
    // 绘制逻辑
  }
}
```

---

## 9. 安全设计

### 9.1 数据安全

```typescript
// 1. 敏感数据加密存储
async function saveHealthData(data: HealthData): Promise<void> {
  const encrypted = await CryptoUtil.encrypt(JSON.stringify(data));
  await rdb.insert('health_data_cache', {
    data_value: encrypted,
    timestamp: Date.now()
  });
}

// 2. 数据脱敏
function desensitizeData(data: HealthData): HealthData {
  return {
    ...data,
    userId: '***',  // 脱敏用户ID
    userName: '***', // 脱敏用户名
    // 保留健康数据用于分析
    heartRate: data.heartRate,
    bloodPressure: data.bloodPressure
  };
}

// 3. 数据验证
function validateHealthData(data: any): boolean {
  const schema = {
    heartRate: { type: 'number', min: 30, max: 220 },
    bloodPressure: {
      systolic: { type: 'number', min: 60, max: 250 },
      diastolic: { type: 'number', min: 40, max: 150 }
    }
  };
  
  return validate(data, schema);
}
```

### 9.2 权限控制

```typescript
// 1. 运行时权限检查
async function checkAccessibilityPermission(): Promise<boolean> {
  const granted = await abilityAccessCtrl.verifyAccessToken(
    tokenID,
    'ohos.permission.ACCESSIBILITY'
  );
  
  if (!granted) {
    // 提示用户授权
    await requestPermission('ohos.permission.ACCESSIBILITY');
  }
  
  return granted;
}

// 2. 功能权限控制
class AccessibilityConfig {
  public async enableVoiceGuidance(): Promise<void> {
    // 检查权限
    const hasPermission = await this.checkPermission('voice');
    if (!hasPermission) {
      throw new Error('缺少语音权限');
    }
    
    // 启用功能
    await this.updateSettings({ voiceGuidance: true });
  }
}
```

### 9.3 安全审计

```typescript
// 安全审计日志
class SecurityAudit {
  public static log(event: SecurityEvent): void {
    const logEntry = {
      timestamp: Date.now(),
      eventType: event.type,
      userId: event.userId,
      action: event.action,
      result: event.result,
      details: event.details
    };
    
    // 写入审计日志
    rdb.insert('security_audit_log', logEntry);
    
    // 敏感操作实时告警
    if (event.type === 'sensitive') {
      this.alert(event);
    }
  }
}

// 记录敏感操作
SecurityAudit.log({
  type: 'sensitive',
  userId: currentUser.id,
  action: 'export_health_data',
  result: 'success',
  details: { dataType: 'heart_rate', format: 'png' }
});
```

---

## 10. 测试设计

### 10.1 测试策略

```
测试金字塔:
  ┌─────────────┐
  │   E2E测试   │  10% - 用户流程测试
  ├─────────────┤
  │  集成测试   │  20% - 模块交互测试
  ├─────────────┤
  │  单元测试   │  70% - 函数/类方法测试
  └─────────────┘
```

### 10.2 测试用例

#### 单元测试用例

```typescript
// 1. AccessibilityConfig测试
describe('AccessibilityConfig', () => {
  it('should initialize with default settings', async () => {
    const config = AccessibilityConfig.getInstance();
    await config.initialize();
    
    const settings = config.getSettings();
    expect(settings.elderlyMode).toBe(false);
    expect(settings.fontSize).toBe(16);
    expect(settings.minTouchTarget).toBe(44);
  });
  
  it('should update settings correctly', async () => {
    const config = AccessibilityConfig.getInstance();
    
    await config.updateSettings({ elderlyMode: true });
    
    const settings = config.getSettings();
    expect(settings.elderlyMode).toBe(true);
    expect(settings.fontSize).toBe(20);
    expect(settings.minTouchTarget).toBe(48);
  });
  
  it('should notify listeners on settings change', async () => {
    const config = AccessibilityConfig.getInstance();
    const listener = jest.fn();
    
    config.addListener(listener);
    await config.updateSettings({ highContrastMode: true });
    
    expect(listener).toHaveBeenCalled();
  });
});

// 2. ChartService测试
describe('ChartService', () => {
  it('should calculate nice axis range', () => {
    const service = ChartService.getInstance();
    
    const result = service.calculateAxisRange([12, 35, 67, 89], {
      tickCount: 5,
      nice: true
    });
    
    expect(result.min).toBe(0);
    expect(result.max).toBe(100);
    expect(result.ticks).toEqual([0, 25, 50, 75, 100]);
  });
  
  it('should aggregate time series data correctly', () => {
    const service = ChartService.getInstance();
    
    const data = [
      { timestamp: 1000, value: 10 },
      { timestamp: 2000, value: 20 },
      { timestamp: 3000, value: 30 }
    ];
    
    const aggregated = service.aggregateData(data, 'hour');
    
    expect(aggregated.length).toBeLessThanOrEqual(data.length);
  });
});

// 3. 颜色对比度计算测试
describe('AccessibilityUtils', () => {
  it('should calculate contrast ratio correctly', () => {
    const ratio = AccessibilityUtils.calculateContrastRatio(
      '#000000',
      '#ffffff'
    );
    
    expect(ratio).toBeCloseTo(21, 0); // 黑白对比度为21:1
  });
  
  it('should meet WCAG AA standard', () => {
    const ratio = AccessibilityUtils.calculateContrastRatio(
      '#767676',
      '#ffffff'
    );
    
    expect(ratio).toBeGreaterThanOrEqual(4.5); // AA级标准
  });
});
```

#### 集成测试用例

```typescript
// 1. 图表渲染集成测试
describe('Chart Integration', () => {
  it('should render line chart with real data', async () => {
    // 准备真实数据
    const rawData = await fetchHealthData('heart_rate');
    
    // 处理数据
    const service = ChartService.getInstance();
    const series = service.processTimeSeriesData(rawData, {
      interval: 'day',
      aggregation: 'avg'
    });
    
    // 渲染图表
    const chart = new LineChart();
    chart.setData({ data: series });
    
    // 验证渲染结果
    const renderTime = await measureRenderTime(() => chart.refresh());
    expect(renderTime).toBeLessThan(100);
  });
});

// 2. 无障碍模式集成测试
describe('Accessibility Integration', () => {
  it('should apply elderly mode to all components', async () => {
    // 开启老年模式
    const config = AccessibilityConfig.getInstance();
    await config.updateSettings({ elderlyMode: true });
    
    // 验证所有组件尺寸
    const buttons = findAllComponents('AccessibleButton');
    buttons.forEach(button => {
      expect(button.width).toBeGreaterThanOrEqual(48);
      expect(button.height).toBeGreaterThanOrEqual(48);
    });
    
    // 验证所有文字大小
    const texts = findAllComponents('Text');
    texts.forEach(text => {
      expect(text.fontSize).toBeGreaterThanOrEqual(20);
    });
  });
});
```

#### E2E测试用例

```typescript
// 1. 用户操作流程测试
describe('User Flow', () => {
  it('should complete health data viewing flow', async () => {
    // 启动应用
    await driver.launchApp();
    
    // 导航到健康数据页面
    await driver.click('健康数据');
    await driver.waitFor('健康数据页面');
    
    // 查看心率趋势
    await driver.click('心率趋势');
    await driver.waitFor('LineChart');
    
    // 验证图表渲染
    const chart = await driver.findElement('LineChart');
    expect(await chart.isDisplayed()).toBe(true);
    
    // 交互操作
    await driver.gesture('pinch', { scale: 1.5 });
    await driver.gesture('pan', { dx: 100, dy: 0 });
    
    // 验证交互响应
    const tooltip = await driver.findElement('ChartTooltip');
    expect(await tooltip.isDisplayed()).toBe(true);
  });
});
```

### 10.3 Mock数据

```typescript
// Mock健康数据
export const mockHealthData = {
  heartRate: [
    { timestamp: 1714521600000, value: 72 },
    { timestamp: 1714525200000, value: 75 },
    { timestamp: 1714528800000, value: 78 },
    // ... 更多数据点
  ],
  
  bloodPressure: [
    { timestamp: 1714521600000, systolic: 120, diastolic: 80 },
    { timestamp: 1714525200000, systolic: 125, diastolic: 82 },
    // ... 更多数据点
  ],
  
  healthScore: {
    dimensions: [
      { name: '心血管', value: 85, maxValue: 100 },
      { name: '呼吸系统', value: 90, maxValue: 100 },
      { name: '消化系统', value: 75, maxValue: 100 },
      { name: '神经系统', value: 88, maxValue: 100 },
      { name: '免疫系统', value: 82, maxValue: 100 },
      { name: '运动系统', value: 70, maxValue: 100 }
    ]
  }
};

// Mock无障碍配置
export const mockAccessibilitySettings: AccessibilitySettings = {
  elderlyMode: false,
  highContrastMode: false,
  largeFontMode: false,
  fontSize: 16,
  minTouchTarget: 44,
  voiceGuidance: false,
  animationReduced: false
};
```

---

## 11. 部署设计

### 11.1 环境要求

| 环境项 | 要求 |
|-------|------|
| **操作系统** | HarmonyOS NEXT API 12+ |
| **设备类型** | 手机、平板、折叠屏 |
| **屏幕尺寸** | 360dp - 840dp |
| **内存** | ≥4GB |
| **存储** | ≥100MB可用空间 |
| **网络** | 支持HTTPS |

### 11.2 配置管理

```typescript
// 应用配置
export interface AppConfig {
  // 无障碍配置
  accessibility: {
    defaultFontSize: number;
    defaultTouchTarget: number;
    highContrastColors: ColorScheme;
  };
  
  // 图表配置
  chart: {
    defaultWidth: number;
    defaultHeight: number;
    maxDataPoints: number;
    animationDuration: number;
  };
  
  // 性能配置
  performance: {
    enableCache: boolean;
    cacheTTL: number;
    maxMemoryUsage: number;
  };
}

// 默认配置
export const defaultAppConfig: AppConfig = {
  accessibility: {
    defaultFontSize: 16,
    defaultTouchTarget: 44,
    highContrastColors: {
      primary: '#000000',
      secondary: '#ffffff',
      accent: '#ff0000'
    }
  },
  
  chart: {
    defaultWidth: 300,
    defaultHeight: 200,
    maxDataPoints: 1000,
    animationDuration: 300
  },
  
  performance: {
    enableCache: true,
    cacheTTL: 3600000, // 1小时
    maxMemoryUsage: 50 * 1024 * 1024 // 50MB
  }
};
```

### 11.3 发布流程

```
1. 代码审查
   ├─ 检查代码规范
   ├─ 检查类型安全
   └─ 检查性能指标

2. 测试验证
   ├─ 运行单元测试
   ├─ 运行集成测试
   └─ 运行E2E测试

3. 构建打包
   ├─ hvigorw clean
   ├─ hvigorw build
   └─ 生成HAP包

4. 真机测试
   ├─ 安装到测试设备
   ├─ 执行功能测试
   └─ 执行性能测试

5. 发布上线
   ├─ 提交应用市场
   ├─ 灰度发布
   └─ 全量发布
```

---

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|-----|------|
| WCAG | Web Content Accessibility Guidelines，网页内容无障碍指南 |
| AA级 | WCAG标准的第二级别，要求较高的无障碍性 |
| dp | Density-independent Pixels，密度无关像素 |
| sp | Scale-independent Pixels，缩放无关像素 |
| Canvas | 画布组件，用于自定义绘制图形 |
| LTTB | Largest-Triangle-Three-Buckets，数据降采样算法 |
| Nice Numbers | 美数算法，用于生成美观的坐标轴刻度 |
| OffscreenCanvas | 离屏画布，用于预渲染优化 |
| Path2D | 路径对象，用于批量绘制优化 |
| Preferences | HarmonyOS轻量级数据存储API |
| RDB | Relational Database，关系型数据库 |

### 12.2 参考资料

- [WCAG 2.1 Guidelines](https://www.w3.org/TR/WCAG21/)
- [HarmonyOS Accessibility Development Guide](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/accessibility-overview-0000001053980525)
- [HarmonyOS Canvas API Reference](https://developer.harmonyos.com/cn/docs/documentation/doc-references/ts-components-canvas-canvas-0000001158301261)
- [HarmonyOS Performance Optimization Guide](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/performance-optimization-0000001059590525)
- [Data Visualization Best Practices](https://www.tableau.com/learn/articles/best-practices-for-data-visualization)

### 12.3 变更历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|---------|
| v1.0 | 2026-04-27 | AI Assistant | 初始版本，完成无障碍设计和数据可视化技术方案 |
