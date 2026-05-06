/**
 * 折线图类型定义
 */

import { BaseChartConfig, AxisConfig, LegendConfig } from '../types';

/**
 * 时间序列数据点
 */
export interface TimeSeriesDataPoint {
  // 时间戳
  timestamp: number;
  
  // 数值
  value: number;
  
  // 标签（可选）
  label?: string;
}

/**
 * 折线图数据系列
 */
export interface LineChartSeries {
  // 系列名称
  name: string;
  
  // 数据点数组
  data: TimeSeriesDataPoint[];
  
  // 线条颜色
  color: string;
  
  // 线条宽度
  lineWidth: number;
  
  // 是否显示数据点
  showPoints: boolean;
  
  // 数据点大小
  pointSize: number;
  
  // 是否填充区域
  fillArea: boolean;
  
  // 填充颜色（可选，默认使用线条颜色的透明版本）
  fillColor?: string;
  
  // 填充透明度
  fillOpacity: number;
  
  // 是否显示
  show: boolean;
}

/**
 * 折线图配置
 */
export interface LineChartConfig extends BaseChartConfig {
  // X轴配置
  xAxis: AxisConfig;
  
  // Y轴配置
  yAxis: AxisConfig;
  
  // 图例配置
  legend: LegendConfig;
  
  // 是否平滑曲线
  smooth: boolean;
  
  // 平滑度（0-1）
  smoothness: number;
  
  // 是否显示网格
  showGrid: boolean;
  
  // 是否显示坐标轴
  showAxis: boolean;
  
  // 是否显示图例
  showLegend: boolean;
  
  // 是否启用缩放
  enableZoom: boolean;
  
  // 是否启用平移
  enablePan: boolean;
  
  // 是否显示Tooltip
  showTooltip: boolean;
  
  // X轴时间格式
  timeFormat: string;
}

/**
 * 折线图数据
 */
export interface LineChartData {
  // 数据系列数组
  series: LineChartSeries[];
  
  // 元数据
  metadata?: {
    title?: string;
    unit?: string;
    [key: string]: any;
  };
}

/**
 * 折线图点击事件数据
 */
export interface LineChartClickData {
  // 系列名称
  seriesName: string;
  
  // 数据点
  point: TimeSeriesDataPoint;
  
  // 点击位置
  position: {
    x: number;
    y: number;
  };
}

/**
 * 折线图默认配置
 */
export const DEFAULT_LINE_CHART_CONFIG: Partial<LineChartConfig> = {
  padding: [40, 20, 40, 60],
  backgroundColor: '#FFFFFF',
  animation: true,
  animationDuration: 800,
  showGrid: true,
  gridColor: '#E0E0E0',
  showAxis: true,
  axisColor: '#333333',
  axisTextColor: '#666666',
  axisTextSize: 12,
  smooth: false,
  smoothness: 0.4,
  showLegend: true,
  enableZoom: true,
  enablePan: true,
  showTooltip: true,
  timeFormat: 'MM-DD HH:mm',
  xAxis: {
    show: true,
    tickCount: 6
  },
  yAxis: {
    show: true,
    tickCount: 5
  },
  legend: {
    show: true,
    position: 'top',
    align: 'center',
    itemGap: 16,
    textSize: 12,
    textColor: '#333333'
  }
};

/**
 * 折线图默认系列配置
 */
export const DEFAULT_LINE_SERIES_CONFIG: Partial<LineChartSeries> = {
  lineWidth: 2,
  showPoints: true,
  pointSize: 4,
  fillArea: false,
  fillOpacity: 0.2,
  show: true
};
