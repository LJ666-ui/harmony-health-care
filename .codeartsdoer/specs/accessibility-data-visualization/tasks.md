# 无障碍友好界面与健康数据可视化 - 开发任务文档

**版本**: v1.0
**创建日期**: 2026-04-27
**最后更新**: 2026-04-27
**作者**: AI Assistant
**状态**: 待执行

---

## 任务概览

本文档将技术设计转化为具体的开发任务，按照优先级和依赖关系组织，确保开发过程有序进行。

### 任务统计
- **总任务数**: 18个主任务 + 42个子任务
- **P0优先级**: 8个主任务（核心功能）
- **P1优先级**: 7个主任务（重要功能）
- **P2优先级**: 3个主任务（增强功能）
- **预计总工时**: 32-40小时

### 任务依赖关系图

```
T01 (无障碍配置基础)
  ↓
T02 (无障碍组件库) → T03 (无障碍工具函数)
  ↓
T04 (图表基础框架)
  ↓
T05 (折线图) ─┐
T06 (柱状图) ─┼─→ T10 (图表交互)
T07 (雷达图) ─┤      ↓
T08 (仪表盘) ─┤   T11 (图表服务)
T09 (热力图) ─┘      ↓
                 T12 (性能优化)
                    ↓
                 T13 (测试编写)
                    ↓
                 T14 (文档完善)
```

---

## 任务详细规划

### T01: 无障碍配置基础模块 【P0】

**任务描述**: 实现AccessibilityConfig单例类，提供无障碍配置的管理、存储和应用功能。

**输入**:
- 无障碍配置接口定义（AccessibilitySettings）
- Preferences存储API

**输出**:
- `common/accessibility/AccessibilityConfig.ets` 文件
- 完整的配置管理功能
- 单元测试用例

**验收标准**:
- ✅ 单例模式正确实现
- ✅ 配置初始化从Preferences加载成功
- ✅ 配置更新后自动持久化
- ✅ 配置变更通知所有监听器
- ✅ 单元测试覆盖率>80%

**子任务**:

#### T01.1: 创建AccessibilityConfig类框架
- 创建 `common/accessibility/AccessibilityConfig.ets` 文件
- 定义AccessibilitySettings接口
- 实现单例模式getInstance()方法
- 定义私有属性：settings、listeners、preferences

**代码提示**:
```typescript
export class AccessibilityConfig {
  private static instance: AccessibilityConfig;
  private settings: AccessibilitySettings;
  private listeners: ConfigChangeListener[] = [];
  
  public static getInstance(): AccessibilityConfig {
    if (!AccessibilityConfig.instance) {
      AccessibilityConfig.instance = new AccessibilityConfig();
    }
    return AccessibilityConfig.instance;
  }
}
```

#### T01.2: 实现配置初始化功能
- 实现initialize()方法
- 从Preferences加载已保存的配置
- 如果无保存配置，使用默认配置
- 处理加载异常情况

**代码提示**:
```typescript
public async initialize(): Promise<void> {
  try {
    const preferences = await PreferencesUtil.getPreferences('accessibility');
    const savedConfig = await preferences.get('config', '');
    
    if (savedConfig) {
      this.settings = JSON.parse(savedConfig);
    } else {
      this.settings = this.getDefaultSettings();
    }
    
    this.applySettings();
  } catch (error) {
    console.error('初始化无障碍配置失败:', error);
    this.settings = this.getDefaultSettings();
  }
}
```

#### T01.3: 实现配置更新和持久化
- 实现updateSettings()方法
- 合并新旧配置
- 应用配置到全局样式（AppStorage）
- 通知所有监听器
- 持久化到Preferences

**代码提示**:
```typescript
public async updateSettings(newSettings: Partial<AccessibilitySettings>): Promise<void> {
  this.settings = { ...this.settings, ...newSettings };
  this.applySettings();
  this.notifyListeners();
  await this.persistSettings();
}

private applySettings(): void {
  const fontSize = this.settings.elderlyMode ? 20 : 
                   this.settings.largeFontMode ? 18 : 16;
  AppStorage.setOrCreate('fontSize', fontSize);
  AppStorage.setOrCreate('minTouchTarget', this.settings.minTouchTarget);
  AppStorage.setOrCreate('highContrast', this.settings.highContrastMode);
}
```

#### T01.4: 实现监听器机制
- 实现addListener()方法
- 实现removeListener()方法
- 实现notifyListeners()私有方法
- 处理监听器异常，避免影响其他监听器

**预计工时**: 3-4小时

---

### T02: 无障碍UI组件库 【P0】

**任务描述**: 开发AccessibleButton、AccessibleText、AccessibleCard等无障碍组件，自动应用无障碍配置。

**输入**:
- AccessibilityConfig配置
- HarmonyOS无障碍API

**输出**:
- `components/accessible/` 目录下的组件文件
- 组件使用文档
- 组件测试用例

**验收标准**:
- ✅ 所有组件支持accessibilityText和accessibilityDescription
- ✅ 组件尺寸根据配置自动调整
- ✅ 高对比度模式正确应用
- ✅ 最小触控区域满足要求
- ✅ 屏幕阅读器可正确朗读

**子任务**:

#### T02.1: 开发AccessibleButton组件
- 创建 `components/accessible/AccessibleButton.ets`
- 使用@StorageLink绑定配置
- 实现最小触控区域约束
- 添加完整的无障碍属性
- 支持图标和文字组合

**代码提示**:
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
      .width(Math.max(this.minTouchTarget, this.width))
      .height(this.minTouchTarget)
      .fontSize(this.fontSize)
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

#### T02.2: 开发AccessibleText组件
- 创建 `components/accessible/AccessibleText.ets`
- 支持自动字体大小调整
- 支持高对比度颜色
- 支持屏幕阅读器朗读
- 支持最大行数限制

**代码提示**:
```typescript
@Component
export struct AccessibleText {
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  
  @Prop text: string;
  @Prop maxLines?: number;
  @Prop textColor?: string;
  
  build() {
    Text(this.text)
      .fontSize(this.fontSize)
      .fontColor(this.highContrast ? '#000000' : (this.textColor ?? '#333333'))
      .maxLines(this.maxLines ?? Infinity)
      .accessibilityText(this.text)
  }
}
```

#### T02.3: 开发AccessibleCard组件
- 创建 `components/accessible/AccessibleCard.ets`
- 实现卡片容器组件
- 支持点击和长按事件
- 添加无障碍焦点管理
- 支持内边距和圆角配置

#### T02.4: 开发AccessibleDialog组件
- 创建 `components/accessible/AccessibleDialog.ets`
- 实现确认对话框组件
- 支持二次确认机制
- 添加无障碍焦点陷阱
- 支持键盘导航（确认/取消）

**预计工时**: 4-5小时

---

### T03: 无障碍工具函数库 【P1】

**任务描述**: 开发AccessibilityUtils工具类，提供颜色对比度计算、WCAG验证等工具函数。

**输入**:
- WCAG 2.1标准规范
- 颜色格式定义

**输出**:
- `utils/AccessibilityUtils.ets` 文件
- 工具函数文档
- 单元测试用例

**验收标准**:
- ✅ 颜色对比度计算准确
- ✅ WCAG AA级验证正确
- ✅ 颜色格式转换正确
- ✅ 单元测试覆盖率>90%

**子任务**:

#### T03.1: 实现颜色对比度计算
- 实现calculateRelativeLuminance()方法
- 实现calculateContrastRatio()方法
- 支持HEX、RGB、RGBA颜色格式
- 处理颜色格式异常

**代码提示**:
```typescript
export class AccessibilityUtils {
  public static calculateContrastRatio(color1: string, color2: string): number {
    const L1 = this.calculateRelativeLuminance(color1);
    const L2 = this.calculateRelativeLuminance(color2);
    
    const lighter = Math.max(L1, L2);
    const darker = Math.min(L1, L2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  private static calculateRelativeLuminance(color: string): number {
    const rgb = this.hexToRgb(color);
    const R = this.gammaCorrection(rgb.r / 255);
    const G = this.gammaCorrection(rgb.g / 255);
    const B = this.gammaCorrection(rgb.b / 255);
    
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }
  
  private static gammaCorrection(value: number): number {
    return value <= 0.03928 ? value / 12.92 : Math.pow((value + 0.055) / 1.055, 2.4);
  }
}
```

#### T03.2: 实现WCAG标准验证
- 实现isWCAGAACompliant()方法
- 验证普通文字对比度≥4.5:1
- 验证大文字对比度≥3:1
- 返回验证结果和建议

#### T03.3: 实现颜色格式转换
- 实现hexToRgb()方法
- 实现rgbToHex()方法
- 实现parseColor()方法（支持多种格式）
- 处理颜色格式异常

**预计工时**: 2-3小时

---

### T04: 图表基础框架搭建 【P0】

**任务描述**: 搭建图表组件的基础框架，包括BaseChart抽象类、ChartConfig配置、ChartData数据结构。

**输入**:
- Canvas API文档
- 图表需求规格

**输出**:
- `components/charts/base/` 目录下的基础文件
- 基础类型定义文件
- 基础框架文档

**验收标准**:
- ✅ BaseChart抽象类定义完整
- ✅ 配置接口类型安全
- ✅ 数据接口泛型实现
- ✅ 动画框架可复用

**子任务**:

#### T04.1: 定义图表基础类型
- 创建 `components/charts/types.ts` 文件
- 定义BaseChartConfig接口
- 定义ChartData<T>泛型接口
- 定义ChartEvent接口
- 定义ChartConfigChangeListener类型

**代码提示**:
```typescript
export interface BaseChartConfig {
  width: number;
  height: number;
  padding: [number, number, number, number];
  backgroundColor: string;
  animation: boolean;
  animationDuration: number;
}

export interface ChartData<T> {
  data: T[];
  metadata?: Record<string, string | number>;
}

export interface ChartEvent {
  type: 'click' | 'longPress' | 'zoom' | 'pan';
  dataPoint?: any;
  position?: [number, number];
}
```

#### T04.2: 实现BaseChart抽象类
- 创建 `components/charts/base/BaseChart.ets`
- 定义公共属性和方法
- 定义抽象方法（draw、calculateAxis）
- 实现动画渲染框架
- 实现事件监听机制

**代码提示**:
```typescript
export abstract class BaseChart<T> {
  protected config: BaseChartConfig;
  protected data: ChartData<T>;
  protected canvas: CanvasRenderingContext2D | null = null;
  protected animationProgress: number = 1;
  
  public setConfig(config: Partial<BaseChartConfig>): void {
    this.config = { ...this.config, ...config };
    this.refresh();
  }
  
  public setData(data: ChartData<T>): void {
    this.data = data;
    this.refresh();
  }
  
  public refresh(): void {
    if (this.config.animation) {
      this.animateDraw();
    } else {
      this.draw();
    }
  }
  
  protected abstract draw(): void;
  protected abstract calculateAxis(): void;
  
  protected animateDraw(): void {
    const startTime = performance.now();
    const animate = (timestamp: number) => {
      this.animationProgress = Math.min(
        (timestamp - startTime) / this.config.animationDuration,
        1
      );
      this.draw();
      if (this.animationProgress < 1) {
        requestAnimationFrame(animate);
      }
    };
    requestAnimationFrame(animate);
  }
}
```

#### T04.3: 实现ChartContainer容器组件
- 创建 `components/charts/ChartContainer.ets`
- 实现标题栏和工具栏
- 实现加载状态和错误状态
- 实现图表导出功能
- 支持响应式布局

**预计工时**: 3-4小时

---

### T05: 折线图组件开发 【P0】

**任务描述**: 实现LineChart组件，支持时间序列数据展示、多系列、缩放拖拽等功能。

**输入**:
- BaseChart基础框架
- 时间序列数据格式

**输出**:
- `components/charts/LineChart.ets` 文件
- LineChartRenderer渲染器
- 组件使用文档

**验收标准**:
- ✅ 支持多数据系列
- ✅ 支持平滑曲线
- ✅ 支持区域填充
- ✅ 支持缩放和拖拽
- ✅ 渲染时间<100ms
- ✅ 数据点可点击查看详情

**子任务**:

#### T05.1: 定义折线图类型和配置
- 定义LineChartSeries接口
- 定义LineChartConfig接口（继承BaseChartConfig）
- 定义TimeSeriesDataPoint接口
- 创建 `components/charts/line/types.ts`

**代码提示**:
```typescript
export interface LineChartSeries {
  name: string;
  data: TimeSeriesDataPoint[];
  color: string;
  lineWidth: number;
  showPoints: boolean;
}

export interface LineChartConfig extends BaseChartConfig {
  showGrid: boolean;
  showAxis: boolean;
  showLegend: boolean;
  smooth: boolean;
  fillArea: boolean;
}

export interface TimeSeriesDataPoint {
  timestamp: number;
  value: number;
  label?: string;
}
```

#### T05.2: 实现LineChartRenderer渲染器
- 创建 `components/charts/line/LineChartRenderer.ets`
- 实现calculateLayout()方法（计算坐标轴范围）
- 实现drawGrid()方法（绘制网格）
- 实现drawAxis()方法（绘制坐标轴）
- 实现drawData()方法（绘制数据线）
- 实现drawPoints()方法（绘制数据点）
- 实现drawLegend()方法（绘制图例）

**代码提示**:
```typescript
export class LineChartRenderer {
  private ctx: CanvasRenderingContext2D;
  private config: LineChartConfig;
  private series: LineChartSeries[];
  
  public draw(): void {
    this.drawBackground();
    if (this.config.showGrid) this.drawGrid();
    if (this.config.showAxis) this.drawAxis();
    this.drawData();
    if (this.config.showLegend) this.drawLegend();
  }
  
  private drawData(): void {
    this.series.forEach(s => {
      this.ctx.beginPath();
      this.ctx.strokeStyle = s.color;
      this.ctx.lineWidth = s.lineWidth;
      
      s.data.forEach((point, index) => {
        const x = this.mapX(point.timestamp);
        const y = this.mapY(point.value);
        
        if (index === 0) {
          this.ctx.moveTo(x, y);
        } else {
          if (this.config.smooth) {
            // 贝塞尔曲线平滑
            this.drawSmoothLine(prevX, prevY, x, y);
          } else {
            this.ctx.lineTo(x, y);
          }
        }
      });
      
      this.ctx.stroke();
      
      if (this.config.fillArea) {
        this.fillArea(s);
      }
      
      if (s.showPoints) {
        this.drawPoints(s);
      }
    });
  }
}
```

#### T05.3: 实现LineChart组件
- 创建 `components/charts/LineChart.ets`
- 使用Canvas组件
- 集成LineChartRenderer
- 实现交互功能（缩放、拖拽、点击）
- 添加无障碍支持

**代码提示**:
```typescript
@Component
export struct LineChart {
  @Prop config: LineChartConfig;
  @Prop series: LineChartSeries[];
  @State private canvasWidth: number = 0;
  @State private canvasHeight: number = 0;
  
  private settings: CanvasRenderingContext2D;
  private renderer: LineChartRenderer | null = null;
  
  build() {
    Column() {
      Canvas(this.settings)
        .width(this.canvasWidth)
        .height(this.canvasHeight)
        .onReady(() => {
          this.onCanvasReady();
        })
        .onClick((e) => {
          this.onCanvasClick(e.x, e.y);
        })
        .onTouch((e) => {
          this.handleTouch(e);
        })
    }
    .width('100%')
    .height('100%')
  }
  
  private onCanvasReady(): void {
    this.renderer = new LineChartRenderer(
      this.settings,
      this.config,
      this.series
    );
    this.renderer.draw();
  }
}
```

#### T05.4: 实现折线图交互功能
- 实现双指缩放（pinch gesture）
- 实现单指拖拽（pan gesture）
- 实现数据点点击显示Tooltip
- 实现长按数据点标注功能
- 处理边界情况

**预计工时**: 5-6小时

---

### T06: 柱状图组件开发 【P0】

**任务描述**: 实现BarChart组件，支持数据对比、横向/纵向切换、点击查看详情等功能。

**输入**:
- BaseChart基础框架
- 柱状图数据格式

**输出**:
- `components/charts/BarChart.ets` 文件
- BarChartRenderer渲染器
- 组件使用文档

**验收标准**:
- ✅ 支持横向和纵向切换
- ✅ 支持多系列对比
- ✅ 支持点击查看详情
- ✅ 渲染时间<100ms
- ✅ 支持动画效果

**子任务**:

#### T06.1: 定义柱状图类型和配置
- 定义BarChartDataItem接口
- 定义BarChartConfig接口
- 创建 `components/charts/bar/types.ts`

#### T06.2: 实现BarChartRenderer渲染器
- 创建 `components/charts/bar/BarChartRenderer.ets`
- 实现柱状条绘制
- 实现坐标轴绘制
- 实现图例绘制
- 支持横向/纵向切换

#### T06.3: 实现BarChart组件
- 创建 `components/charts/BarChart.ets`
- 集成BarChartRenderer
- 实现点击交互
- 添加动画效果

**预计工时**: 4-5小时

---

### T07: 雷达图组件开发 【P0】

**任务描述**: 实现RadarChart组件，支持多维度健康评估可视化。

**输入**:
- BaseChart基础框架
- 雷达图数据格式

**输出**:
- `components/charts/RadarChart.ets` 文件
- RadarChartRenderer渲染器
- 组件使用文档

**验收标准**:
- ✅ 支持多维度展示（≥6个维度）
- ✅ 支持多边形和圆形网格
- ✅ 支持悬停查看详情
- ✅ 渲染时间<100ms
- ✅ 支持动画效果

**子任务**:

#### T07.1: 定义雷达图类型和配置
- 定义RadarChartDimension接口
- 定义RadarChartConfig接口
- 创建 `components/charts/radar/types.ts`

#### T07.2: 实现RadarChartRenderer渲染器
- 创建 `components/charts/radar/RadarChartRenderer.ets`
- 实现网格绘制（多边形/圆形）
- 实现轴线绘制
- 实现数据区域绘制
- 实现标签绘制

**代码提示**:
```typescript
export class RadarChartRenderer {
  private centerX: number = 0;
  private centerY: number = 0;
  private radius: number = 0;
  
  public draw(): void {
    this.calculateLayout();
    this.drawBackground();
    this.drawGrid();
    this.drawAxes();
    this.drawData();
    this.drawLabels();
  }
  
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
}
```

#### T07.3: 实现RadarChart组件
- 创建 `components/charts/RadarChart.ets`
- 集成RadarChartRenderer
- 实现悬停交互
- 添加动画效果

**预计工时**: 4-5小时

---

### T08: 仪表盘组件开发 【P0】

**任务描述**: 实现GaugeChart组件，支持实时监测数据展示，颜色区分正常/警告/危险区域。

**输入**:
- BaseChart基础框架
- 仪表盘数据格式

**输出**:
- `components/charts/GaugeChart.ets` 文件
- GaugeChartRenderer渲染器
- 组件使用文档

**验收标准**:
- ✅ 支持半圆和全圆仪表盘
- ✅ 颜色区分正常/警告/危险区域
- ✅ 指针指向当前值
- ✅ 渲染时间<100ms
- ✅ 支持动画效果

**子任务**:

#### T08.1: 定义仪表盘类型和配置
- 定义GaugeChartData接口
- 定义GaugeChartConfig接口
- 创建 `components/charts/gauge/types.ts`

#### T08.2: 实现GaugeChartRenderer渲染器
- 创建 `components/charts/gauge/GaugeChartRenderer.ets`
- 实现背景圆弧绘制
- 实现区域颜色填充
- 实现指针绘制
- 实现数值显示

#### T08.3: 实现GaugeChart组件
- 创建 `components/charts/GaugeChart.ets`
- 集成GaugeChartRenderer
- 实现动态更新
- 添加动画效果

**预计工时**: 3-4小时

---

### T09: 热力图组件开发 【P1】

**任务描述**: 实现HeatmapChart组件，支持时间分布数据可视化。

**输入**:
- BaseChart基础框架
- 热力图数据格式

**输出**:
- `components/charts/HeatmapChart.ets` 文件
- HeatmapChartRenderer渲染器
- 组件使用文档

**验收标准**:
- ✅ 颜色深浅正确表示数值
- ✅ 支持悬停查看具体值
- ✅ 支持颜色渐变配置
- ✅ 渲染时间<100ms

**子任务**:

#### T09.1: 定义热力图类型和配置
- 定义HeatmapDataPoint接口
- 定义HeatmapChartConfig接口
- 创建 `components/charts/heatmap/types.ts`

#### T09.2: 实现HeatmapChartRenderer渲染器
- 创建 `components/charts/heatmap/HeatmapChartRenderer.ets`
- 实现单元格绘制
- 实现颜色映射
- 实现标签绘制

#### T09.3: 实现HeatmapChart组件
- 创建 `components/charts/HeatmapChart.ets`
- 集成HeatmapChartRenderer
- 实现悬停交互

**预计工时**: 3-4小时

---

### T10: 图表交互功能完善 【P1】

**任务描述**: 完善所有图表的交互功能，包括缩放、拖拽、Tooltip、数据点选择等。

**输入**:
- 已完成的图表组件
- 交互需求规格

**输出**:
- 统一的交互管理器
- Tooltip组件
- 交互功能文档

**验收标准**:
- ✅ 所有图表支持缩放和拖拽
- ✅ Tooltip显示正确
- ✅ 手势操作流畅
- ✅ 交互响应时间<300ms

**子任务**:

#### T10.1: 实现ChartInteractionManager
- 创建 `components/charts/interaction/ChartInteractionManager.ets`
- 统一管理缩放、拖拽状态
- 处理手势事件
- 计算变换矩阵

#### T10.2: 实现ChartTooltip组件
- 创建 `components/charts/interaction/ChartTooltip.ets`
- 实现Tooltip定位算法
- 支持自定义内容渲染
- 处理边界情况（Tooltip超出画布）

#### T10.3: 集成交互功能到所有图表
- 为LineChart添加交互
- 为BarChart添加交互
- 为RadarChart添加交互
- 为HeatmapChart添加交互

**预计工时**: 3-4小时

---

### T11: ChartService服务层开发 【P0】

**任务描述**: 实现ChartService，提供数据处理、坐标轴计算、数据聚合、数据验证等功能。

**输入**:
- 图表数据格式定义
- 数据处理需求

**输出**:
- `service/ChartService.ets` 文件
- 数据处理算法实现
- 服务层文档

**验收标准**:
- ✅ 坐标轴计算使用Nice Numbers算法
- ✅ 数据聚合正确
- ✅ 数据验证完整
- ✅ 缓存机制有效

**子任务**:

#### T11.1: 实现ChartService基础框架
- 创建 `service/ChartService.ets`
- 实现单例模式
- 定义数据处理方法签名
- 实现数据缓存机制

#### T11.2: 实现坐标轴计算（Nice Numbers算法）
- 实现niceNumber()方法
- 实现calculateAxisRange()方法
- 生成美观的刻度值
- 处理边界情况

**代码提示**:
```typescript
public calculateAxisRange(
  data: number[],
  options: AxisOptions
): { min: number; max: number; ticks: number[] } {
  let min = options.min ?? Math.min(...data);
  let max = options.max ?? Math.max(...data);
  
  const range = this.niceNumber(max - min, false);
  const tickSpacing = this.niceNumber(range / (options.tickCount - 1), true);
  
  if (options.nice) {
    min = Math.floor(min / tickSpacing) * tickSpacing;
    max = Math.ceil(max / tickSpacing) * tickSpacing;
  }
  
  const ticks: number[] = [];
  for (let tick = min; tick <= max; tick += tickSpacing) {
    ticks.push(tick);
  }
  
  return { min, max, ticks };
}

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

#### T11.3: 实现数据聚合功能
- 实现aggregateData()方法
- 支持hour、day、week、month聚合
- 支持avg、max、min、sum聚合方式
- 处理缺失数据填充

#### T11.4: 实现数据验证功能
- 实现validateData()方法
- 定义数据Schema
- 验证数据类型和范围
- 返回验证结果和错误信息

#### T11.5: 实现数据降采样（LTTB算法）
- 实现LTTB()方法
- 保留数据视觉特征
- 减少数据点数量
- 提升渲染性能

**预计工时**: 4-5小时

---

### T12: 性能优化实施 【P1】

**任务描述**: 实施性能优化策略，包括渲染优化、内存优化、缓存优化等。

**输入**:
- 已完成的图表组件
- 性能优化策略

**输出**:
- 性能优化代码
- 性能监控工具
- 性能测试报告

**验收标准**:
- ✅ 图表渲染时间<100ms
- ✅ 重绘时间<200ms
- ✅ 内存占用<50MB
- ✅ 滚动帧率≥55fps

**子任务**:

#### T12.1: 实现渲染优化
- 使用requestAnimationFrame优化动画
- 使用离屏Canvas预渲染
- 使用Path2D批量绘制
- 减少不必要的重绘

#### T12.2: 实现内存优化
- 及时释放Canvas资源
- 实现对象池复用
- 避免内存泄漏
- 监控内存使用

#### T12.3: 实现数据缓存优化
- 优化缓存策略
- 设置合理的TTL
- 实现缓存失效机制
- 监控缓存命中率

#### T12.4: 实现性能监控
- 创建性能监控装饰器
- 记录关键方法耗时
- 超阈值告警
- 生成性能报告

**预计工时**: 3-4小时

---

### T13: 测试用例编写 【P1】

**任务描述**: 编写单元测试、集成测试和E2E测试，确保代码质量和功能正确性。

**输入**:
- 已完成的所有模块
- 测试设计文档

**输出**:
- 测试用例文件
- Mock数据
- 测试报告

**验收标准**:
- ✅ 单元测试覆盖率>80%
- ✅ 集成测试覆盖关键流程
- ✅ E2E测试覆盖用户场景
- ✅ 所有测试通过

**子任务**:

#### T13.1: 编写AccessibilityConfig单元测试
- 测试单例模式
- 测试配置初始化
- 测试配置更新
- 测试监听器机制

#### T13.2: 编写ChartService单元测试
- 测试坐标轴计算
- 测试数据聚合
- 测试数据验证
- 测试LTTB算法

#### T13.3: 编写图表组件集成测试
- 测试折线图渲染
- 测试柱状图渲染
- 测试雷达图渲染
- 测试仪表盘渲染
- 测试热力图渲染

#### T13.4: 编写E2E测试
- 测试无障碍模式切换流程
- 测试健康数据查看流程
- 测试图表交互流程

**预计工时**: 4-5小时

---

### T14: 文档完善 【P2】

**任务描述**: 完善代码文档、API文档、使用指南等。

**输入**:
- 已完成的所有代码

**输出**:
- API文档
- 使用指南
- 最佳实践文档

**验收标准**:
- ✅ 所有公共API有JSDoc注释
- ✅ 使用指南清晰完整
- ✅ 包含代码示例

**子任务**:

#### T14.1: 编写API文档
- 为所有公共类添加JSDoc
- 为所有公共方法添加注释
- 生成API参考文档

#### T14.2: 编写使用指南
- 编写无障碍功能使用指南
- 编写图表组件使用指南
- 包含完整代码示例

#### T14.3: 编写最佳实践文档
- 编写性能优化最佳实践
- 编写无障碍设计最佳实践
- 编写常见问题FAQ

**预计工时**: 2-3小时

---

### T15: 无障碍设置页面开发 【P1】

**任务描述**: 开发无障碍设置页面，提供老年模式、高对比度模式等配置界面。

**输入**:
- AccessibilityConfig服务
- Accessible组件库

**输出**:
- `pages/AccessibilitySettingsPage.ets` 文件
- 设置页面UI

**验收标准**:
- ✅ 所有设置项可操作
- ✅ 配置实时生效
- ✅ 支持预览功能
- ✅ 支持恢复默认

**子任务**:

#### T15.1: 创建设置页面框架
- 创建页面文件
- 设计页面布局
- 添加页面标题和返回按钮

#### T15.2: 实现设置项UI
- 实现老年模式开关
- 实现高对比度模式开关
- 实现大字体模式开关
- 实现字体大小滑块
- 实现语音引导开关

#### T15.3: 实现配置保存和预览
- 配置变更实时保存
- 提供预览功能
- 提供恢复默认功能

**预计工时**: 2-3小时

---

### T16: 健康数据页面集成 【P1】

**任务描述**: 在健康数据页面集成图表组件，展示心率、血压、健康评分等数据。

**输入**:
- 图表组件库
- ChartService服务
- 健康数据API

**输出**:
- 更新后的HealthDataPage
- 数据加载和展示逻辑

**验收标准**:
- ✅ 所有图表正确渲染
- ✅ 数据加载流畅
- ✅ 支持数据刷新
- ✅ 支持图表导出

**子任务**:

#### T16.1: 集成心率折线图
- 在心率卡片中集成LineChart
- 加载心率历史数据
- 实现数据刷新

#### T16.2: 集成血压仪表盘
- 在血压卡片中集成GaugeChart
- 显示当前血压值
- 标识正常/警告/危险区域

#### T16.3: 集成健康评分雷达图
- 在健康评分卡片中集成RadarChart
- 显示多维度评分
- 支持点击查看详情

#### T16.4: 集成活动热力图
- 在活动分布卡片中集成HeatmapChart
- 显示活动强度分布
- 支持悬停查看详情

**预计工时**: 3-4小时

---

### T17: 风险评估页面集成 【P1】

**任务描述**: 在风险评估页面集成图表组件，展示综合评分、历史趋势、风险对比等。

**输入**:
- 图表组件库
- ChartService服务
- 风险评估数据API

**输出**:
- 更新后的RiskAssessmentPage
- 数据加载和展示逻辑

**验收标准**:
- ✅ 综合评分雷达图正确展示
- ✅ 历史趋势折线图正确展示
- ✅ 风险对比柱状图正确展示
- ✅ 支持数据导出

**子任务**:

#### T17.1: 集成综合评分雷达图
- 在综合评分区域集成RadarChart
- 显示多维度风险评分
- 支持悬停查看详情

#### T17.2: 集成历史趋势折线图
- 在历史趋势区域集成LineChart
- 显示风险评分历史变化
- 支持时间范围选择

#### T17.3: 集成风险对比柱状图
- 在风险对比区域集成BarChart
- 显示不同风险维度对比
- 支持点击查看详情

**预计工时**: 2-3小时

---

### T18: 最终测试和验收 【P2】

**任务描述**: 进行最终的功能测试、性能测试和验收，确保所有需求满足。

**输入**:
- 已完成的所有功能

**输出**:
- 测试报告
- 性能报告
- 验收报告

**验收标准**:
- ✅ 所有功能需求满足
- ✅ 所有非功能需求满足
- ✅ 性能指标达标
- ✅ 无严重Bug

**子任务**:

#### T18.1: 功能验收测试
- 测试所有无障碍功能
- 测试所有图表功能
- 测试所有交互功能
- 记录测试结果

#### T18.2: 性能验收测试
- 测试图表渲染性能
- 测试内存占用
- 测试滚动流畅度
- 生成性能报告

#### T18.3: 兼容性测试
- 测试不同设备适配
- 测试不同屏幕尺寸
- 测试屏幕阅读器兼容
- 记录兼容性问题

#### T18.4: 生成验收报告
- 汇总测试结果
- 列出已满足需求
- 列出遗留问题
- 提出改进建议

**预计工时**: 2-3小时

---

## 任务执行建议

### 执行顺序

建议按照以下顺序执行任务：

**第一阶段（基础建设）**:
1. T01: 无障碍配置基础模块
2. T03: 无障碍工具函数库
3. T04: 图表基础框架搭建

**第二阶段（核心组件）**:
4. T02: 无障碍UI组件库
5. T11: ChartService服务层开发

**第三阶段（图表组件）**:
6. T05: 折线图组件开发
7. T06: 柱状图组件开发
8. T07: 雷达图组件开发
9. T08: 仪表盘组件开发
10. T09: 热力图组件开发

**第四阶段（功能完善）**:
11. T10: 图表交互功能完善
12. T12: 性能优化实施

**第五阶段（页面集成）**:
13. T15: 无障碍设置页面开发
14. T16: 健康数据页面集成
15. T17: 风险评估页面集成

**第六阶段（测试验收）**:
16. T13: 测试用例编写
17. T14: 文档完善
18. T18: 最终测试和验收

### 风险提示

1. **性能风险**: Canvas自绘可能存在性能瓶颈，需要充分测试和优化
2. **兼容性风险**: 不同设备的Canvas性能差异，需要适配测试
3. **内存风险**: 图表组件可能存在内存泄漏，需要严格检查
4. **无障碍风险**: 屏幕阅读器兼容性需要真机测试验证

### 交付物清单

- [ ] 源代码文件（约4300行）
- [ ] 单元测试文件（覆盖率>80%）
- [ ] API文档
- [ ] 使用指南
- [ ] 性能测试报告
- [ ] 验收报告

---

## 变更历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|---------|
| v1.0 | 2026-04-27 | AI Assistant | 初始版本，定义18个主任务和42个子任务 |
