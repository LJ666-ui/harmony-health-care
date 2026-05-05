/**
 * 图表基础类型定义
 */

/**
 * 基础图表配置接口
 */
export interface BaseChartConfig {
  // 图表宽度
  width: number;
  
  // 图表高度
  height: number;
  
  // 内边距 [上, 右, 下, 左]
  padding: [number, number, number, number];
  
  // 背景颜色
  backgroundColor: string;
  
  // 是否启用动画
  animation: boolean;
  
  // 动画持续时间（毫秒）
  animationDuration: number;
  
  // 是否显示网格
  showGrid: boolean;
  
  // 网格颜色
  gridColor: string;
  
  // 是否显示坐标轴
  showAxis: boolean;
  
  // 坐标轴颜色
  axisColor: string;
  
  // 坐标轴文字颜色
  axisTextColor: string;
  
  // 坐标轴文字大小
  axisTextSize: number;
}

/**
 * 图表数据接口（泛型）
 */
export interface ChartData<T> {
  // 数据数组
  data: T[];
  
  // 元数据（可选）
  metadata?: Record<string, string | number>;
}

/**
 * 图表事件接口
 */
export interface ChartEvent {
  // 事件类型
  type: 'click' | 'longPress' | 'zoom' | 'pan' | 'hover';
  
  // 数据点（可选）
  dataPoint?: any;
  
  // 位置坐标（可选）
  position?: [number, number];
  
  // 事件时间戳
  timestamp: number;
}

/**
 * 配置变更监听器类型
 */
export type ChartConfigChangeListener = (config: BaseChartConfig) => void;

/**
 * 数据变更监听器类型
 */
export type ChartDataChangeListener<T> = (data: ChartData<T>) => void;

/**
 * 图表事件监听器类型
 */
export type ChartEventListener = (event: ChartEvent) => void;

/**
 * 坐标轴配置接口
 */
export interface AxisConfig {
  // 是否显示
  show: boolean;
  
  // 最小值（可选，自动计算）
  min?: number;
  
  // 最大值（可选，自动计算）
  max?: number;
  
  // 刻度数量
  tickCount: number;
  
  // 刻度格式化函数
  tickFormat?: (value: number) => string;
  
  // 轴标签
  label?: string;
  
  // 是否反转
  reverse?: boolean;
}

/**
 * 图例配置接口
 */
export interface LegendConfig {
  // 是否显示
  show: boolean;
  
  // 位置：top, bottom, left, right
  position: 'top' | 'bottom' | 'left' | 'right';
  
  // 对齐方式：start, center, end
  align: 'start' | 'center' | 'end';
  
  // 图例项间距
  itemGap: number;
  
  // 文字大小
  textSize: number;
  
  // 文字颜色
  textColor: string;
}

/**
 * Tooltip配置接口
 */
export interface TooltipConfig {
  // 是否启用
  enable: boolean;
  
  // 背景颜色
  backgroundColor: string;
  
  // 文字颜色
  textColor: string;
  
  // 边框颜色
  borderColor: string;
  
  // 边框宽度
  borderWidth: number;
  
  // 圆角半径
  borderRadius: number;
  
  // 内边距
  padding: number;
  
  // 自定义格式化函数
  formatter?: (data: any) => string;
}

/**
 * 网格配置接口
 */
export interface GridConfig {
  // 是否显示
  show: boolean;
  
  // 网格线颜色
  color: string;
  
  // 网格线宽度
  lineWidth: number;
  
  // 是否显示水平网格线
  showHorizontal: boolean;
  
  // 是否显示垂直网格线
  showVertical: boolean;
  
  // 网格线类型：solid, dashed, dotted
  lineType: 'solid' | 'dashed' | 'dotted';
}

/**
 * 动画配置接口
 */
export interface AnimationConfig {
  // 是否启用
  enable: boolean;
  
  // 持续时间（毫秒）
  duration: number;
  
  // 缓动函数
  easing: 'linear' | 'easeIn' | 'easeOut' | 'easeInOut';
  
  // 延迟（毫秒）
  delay: number;
}

/**
 * 数据点接口
 */
export interface DataPoint {
  // X坐标
  x: number;
  
  // Y坐标
  y: number;
  
  // 值
  value: any;
  
  // 标签（可选）
  label?: string;
  
  // 颜色（可选）
  color?: string;
}

/**
 * 数据系列接口
 */
export interface DataSeries {
  // 系列名称
  name: string;
  
  // 数据点数组
  data: DataPoint[];
  
  // 系列颜色
  color: string;
  
  // 是否显示
  show: boolean;
}

/**
 * 坐标范围接口
 */
export interface AxisRange {
  // 最小值
  min: number;
  
  // 最大值
  max: number;
  
  // 刻度值数组
  ticks: number[];
}

/**
 * 交互状态接口
 */
export interface InteractionState {
  // 缩放比例
  zoom: number;
  
  // 平移X偏移
  panX: number;
  
  // 平移Y偏移
  panY: number;
  
  // 是否正在交互
  isInteracting: boolean;
}

/**
 * 图表渲染上下文接口
 */
export interface ChartRenderContext {
  // Canvas上下文
  ctx: CanvasRenderingContext2D;
  
  // 图表宽度
  width: number;
  
  // 图表高度
  height: number;
  
  // 绘图区域（去除padding后的区域）
  plotArea: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  
  // 动画进度（0-1）
  animationProgress: number;
  
  // 交互状态
  interaction: InteractionState;
}
