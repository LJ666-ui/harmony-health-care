/**
 * 柱状图类型定义
 */

import { BaseChartConfig, AxisConfig, LegendConfig } from '../types';

/**
 * 柱状图数据项
 */
export interface BarChartDataItem {
  // 类目名称
  category: string;
  
  // 数值
  value: number;
  
  // 颜色（可选）
  color?: string;
}

/**
 * 柱状图数据系列
 */
export interface BarChartSeries {
  // 系列名称
  name: string;
  
  // 数据项数组
  data: BarChartDataItem[];
  
  // 系列颜色
  color: string;
  
  // 是否显示
  show: boolean;
}

/**
 * 柱状图配置
 */
export interface BarChartConfig extends BaseChartConfig {
  // X轴配置
  xAxis: AxisConfig;
  
  // Y轴配置
  yAxis: AxisConfig;
  
  // 图例配置
  legend: LegendConfig;
  
  // 是否横向
  horizontal: boolean;
  
  // 柱子宽度比例（0-1）
  barWidth: number;
  
  // 柱子间距
  barGap: number;
  
  // 是否显示网格
  showGrid: boolean;
  
  // 是否显示坐标轴
  showAxis: boolean;
  
  // 是否显示图例
  showLegend: boolean;
  
  // 是否显示数值标签
  showLabel: boolean;
  
  // 圆角半径
  borderRadius: number;
}

/**
 * 柱状图默认配置
 */
export const DEFAULT_BAR_CHART_CONFIG: Partial<BarChartConfig> = {
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
  horizontal: false,
  barWidth: 0.6,
  barGap: 0.2,
  showLegend: true,
  showLabel: false,
  borderRadius: 4,
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
