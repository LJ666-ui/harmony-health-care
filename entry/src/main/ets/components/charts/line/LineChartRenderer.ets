/**
 * 折线图渲染器
 * 负责折线图的绘制逻辑
 */

import { LineChartConfig, LineChartSeries, TimeSeriesDataPoint } from './types';
import { AxisRange } from '../types';
import { ChartService } from '../../../service/ChartService';

/**
 * 折线图渲染器
 */
export class LineChartRenderer {
  private ctx: CanvasRenderingContext2D;
  private config: LineChartConfig;
  private series: LineChartSeries[];
  private chartService: ChartService;
  
  // 坐标轴范围
  private xRange: AxisRange = { min: 0, max: 0, ticks: [] };
  private yRange: AxisRange = { min: 0, max: 0, ticks: [] };
  
  // 绘图区域
  private plotArea = { x: 0, y: 0, width: 0, height: 0 };
  
  // 动画进度
  private animationProgress: number = 1;
  
  /**
   * 构造函数
   */
  constructor(
    ctx: CanvasRenderingContext2D,
    config: LineChartConfig,
    series: LineChartSeries[]
  ) {
    this.ctx = ctx;
    this.config = config;
    this.series = series;
    this.chartService = ChartService.getInstance();
    
    this.calculateLayout();
  }
  
  /**
   * 设置动画进度
   */
  public setAnimationProgress(progress: number): void {
    this.animationProgress = progress;
  }
  
  /**
   * 计算布局
   */
  private calculateLayout(): void {
    // 计算绘图区域
    const top = this.config.padding[0];
    const right = this.config.padding[1];
    const bottom = this.config.padding[2];
    const left = this.config.padding[3];
    this.plotArea = {
      x: left,
      y: top,
      width: this.config.width - left - right,
      height: this.config.height - top - bottom
    };
    
    // 计算X轴范围（时间）
    const allTimestamps: number[] = [];
    this.series.forEach(s => {
      s.data.forEach(point => {
        allTimestamps.push(point.timestamp);
      });
    });
    
    if (allTimestamps.length > 0) {
      this.xRange = {
        min: Math.min(...allTimestamps),
        max: Math.max(...allTimestamps),
        ticks: []
      };
      
      // 生成时间刻度
      const tickCount = this.config.xAxis.tickCount ?? 6;
      const step = (this.xRange.max - this.xRange.min) / (tickCount - 1);
      for (let i = 0; i < tickCount; i++) {
        this.xRange.ticks.push(this.xRange.min + i * step);
      }
    }
    
    // 计算Y轴范围（数值）
    const allValues: number[] = [];
    this.series.forEach(s => {
      s.data.forEach(point => {
        allValues.push(point.value);
      });
    });
    
    if (allValues.length > 0) {
      this.yRange = this.chartService.calculateAxisRange(allValues, {
        tickCount: this.config.yAxis.tickCount ?? 5,
        nice: true
      });
    }
  }
  
  /**
   * 绘制图表
   */
  public draw(): void {
    this.drawBackground();
    
    if (this.config.showGrid) {
      this.drawGrid();
    }
    
    if (this.config.showAxis) {
      this.drawAxis();
    }
    
    this.drawData();
    
    if (this.config.showLegend) {
      this.drawLegend();
    }
  }
  
  /**
   * 绘制背景
   */
  private drawBackground(): void {
    this.ctx.fillStyle = this.config.backgroundColor;
    this.ctx.fillRect(0, 0, this.config.width, this.config.height);
  }
  
  /**
   * 绘制网格
   */
  private drawGrid(): void {
    this.ctx.strokeStyle = this.config.gridColor;
    this.ctx.lineWidth = 1;
    
    // 绘制水平网格线
    this.yRange.ticks.forEach(tick => {
      const y = this.mapY(tick);
      this.ctx.beginPath();
      this.ctx.moveTo(this.plotArea.x, y);
      this.ctx.lineTo(this.plotArea.x + this.plotArea.width, y);
      this.ctx.stroke();
    });
    
    // 绘制垂直网格线
    this.xRange.ticks.forEach(tick => {
      const x = this.mapX(tick);
      this.ctx.beginPath();
      this.ctx.moveTo(x, this.plotArea.y);
      this.ctx.lineTo(x, this.plotArea.y + this.plotArea.height);
      this.ctx.stroke();
    });
  }
  
  /**
   * 绘制坐标轴
   */
  private drawAxis(): void {
    this.ctx.strokeStyle = this.config.axisColor;
    this.ctx.fillStyle = this.config.axisTextColor;
    this.ctx.font = `${this.config.axisTextSize}px sans-serif`;
    this.ctx.lineWidth = 2;
    
    // 绘制X轴
    this.ctx.beginPath();
    this.ctx.moveTo(this.plotArea.x, this.plotArea.y + this.plotArea.height);
    this.ctx.lineTo(this.plotArea.x + this.plotArea.width, this.plotArea.y + this.plotArea.height);
    this.ctx.stroke();
    
    // 绘制Y轴
    this.ctx.beginPath();
    this.ctx.moveTo(this.plotArea.x, this.plotArea.y);
    this.ctx.lineTo(this.plotArea.x, this.plotArea.y + this.plotArea.height);
    this.ctx.stroke();
    
    // 绘制X轴刻度标签
    this.ctx.textAlign = 'center';
    this.ctx.textBaseline = 'top';
    this.xRange.ticks.forEach(tick => {
      const x = this.mapX(tick);
      const label = this.formatTime(tick);
      this.ctx.fillText(label, x, this.plotArea.y + this.plotArea.height + 8);
    });
    
    // 绘制Y轴刻度标签
    this.ctx.textAlign = 'right';
    this.ctx.textBaseline = 'middle';
    this.yRange.ticks.forEach(tick => {
      const y = this.mapY(tick);
      const label = this.formatNumber(tick);
      this.ctx.fillText(label, this.plotArea.x - 8, y);
    });
  }
  
  /**
   * 绘制数据
   */
  private drawData(): void {
    this.series.forEach(s => {
      if (!s.show) return;
      
      // 绘制填充区域
      if (s.fillArea) {
        this.drawFillArea(s);
      }
      
      // 绘制线条
      this.drawLine(s);
      
      // 绘制数据点
      if (s.showPoints) {
        this.drawPoints(s);
      }
    });
  }
  
  /**
   * 绘制线条
   */
  private drawLine(series: LineChartSeries): void {
    if (series.data.length < 2) return;
    
    this.ctx.strokeStyle = series.color;
    this.ctx.lineWidth = series.lineWidth;
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';
    
    this.ctx.beginPath();
    
    const animatedLength = Math.ceil(series.data.length * this.animationProgress);
    
    for (let i = 0; i < animatedLength; i++) {
      const point = series.data[i];
      const x = this.mapX(point.timestamp);
      const y = this.mapY(point.value);
      
      if (i === 0) {
        this.ctx.moveTo(x, y);
      } else {
        if (this.config.smooth && i > 0 && i < animatedLength - 1) {
          // 贝塞尔曲线平滑
          const prevPoint = series.data[i - 1];
          const nextPoint = series.data[Math.min(i + 1, series.data.length - 1)];
          
          const prevX = this.mapX(prevPoint.timestamp);
          const prevY = this.mapY(prevPoint.value);
          const nextX = this.mapX(nextPoint.timestamp);
          const nextY = this.mapY(nextPoint.value);
          
          const cp1x = prevX + (x - prevX) * this.config.smoothness;
          const cp1y = prevY + (y - prevY) * this.config.smoothness;
          const cp2x = x - (nextX - x) * this.config.smoothness;
          const cp2y = y - (nextY - y) * this.config.smoothness;
          
          this.ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
        } else {
          this.ctx.lineTo(x, y);
        }
      }
    }
    
    this.ctx.stroke();
  }
  
  /**
   * 绘制填充区域
   */
  private drawFillArea(series: LineChartSeries): void {
    if (series.data.length < 2) return;
    
    const fillColor = series.fillColor ?? series.color;
    const alpha = series.fillOpacity;
    
    // 设置填充颜色（带透明度）
    this.ctx.fillStyle = this.hexToRgba(fillColor, alpha);
    
    this.ctx.beginPath();
    
    // 移动到第一个点
    const firstPoint = series.data[0];
    const firstX = this.mapX(firstPoint.timestamp);
    const firstY = this.mapY(firstPoint.value);
    
    this.ctx.moveTo(firstX, this.plotArea.y + this.plotArea.height);
    this.ctx.lineTo(firstX, firstY);
    
    // 绘制线条路径
    const animatedLength = Math.ceil(series.data.length * this.animationProgress);
    
    for (let i = 1; i < animatedLength; i++) {
      const point = series.data[i];
      const x = this.mapX(point.timestamp);
      const y = this.mapY(point.value);
      
      this.ctx.lineTo(x, y);
    }
    
    // 闭合路径
    const lastPoint = series.data[animatedLength - 1];
    const lastX = this.mapX(lastPoint.timestamp);
    
    this.ctx.lineTo(lastX, this.plotArea.y + this.plotArea.height);
    this.ctx.closePath();
    
    this.ctx.fill();
  }
  
  /**
   * 绘制数据点
   */
  private drawPoints(series: LineChartSeries): void {
    const animatedLength = Math.ceil(series.data.length * this.animationProgress);
    
    series.data.slice(0, animatedLength).forEach(point => {
      const x = this.mapX(point.timestamp);
      const y = this.mapY(point.value);
      
      // 绘制点
      this.ctx.beginPath();
      this.ctx.arc(x, y, series.pointSize, 0, 2 * Math.PI);
      this.ctx.fillStyle = series.color;
      this.ctx.fill();
      
      // 绘制白色内圈
      this.ctx.beginPath();
      this.ctx.arc(x, y, series.pointSize * 0.6, 0, 2 * Math.PI);
      this.ctx.fillStyle = '#FFFFFF';
      this.ctx.fill();
    });
  }
  
  /**
   * 绘制图例
   */
  private drawLegend(): void {
    const legend = this.config.legend;
    if (!legend.show) return;
    
    this.ctx.font = `${legend.textSize}px sans-serif`;
    this.ctx.textBaseline = 'middle';
    
    const itemWidth = 80;
    const totalWidth = this.series.filter(s => s.show).length * (itemWidth + legend.itemGap);
    let startX = this.plotArea.x + (this.plotArea.width - totalWidth) / 2;
    let startY = 20;
    
    this.series.filter(s => s.show).forEach(s => {
      // 绘制颜色标记
      this.ctx.fillStyle = s.color;
      this.ctx.fillRect(startX, startY - 4, 16, 8);
      
      // 绘制文字
      this.ctx.fillStyle = legend.textColor;
      this.ctx.textAlign = 'left';
      this.ctx.fillText(s.name, startX + 20, startY);
      
      startX += itemWidth + legend.itemGap;
    });
  }
  
  /**
   * X坐标映射
   */
  private mapX(timestamp: number): number {
    if (this.xRange.max === this.xRange.min) {
      return this.plotArea.x + this.plotArea.width / 2;
    }
    
    const ratio = (timestamp - this.xRange.min) / (this.xRange.max - this.xRange.min);
    return this.plotArea.x + ratio * this.plotArea.width;
  }
  
  /**
   * Y坐标映射
   */
  private mapY(value: number): number {
    if (this.yRange.max === this.yRange.min) {
      return this.plotArea.y + this.plotArea.height / 2;
    }
    
    const ratio = (value - this.yRange.min) / (this.yRange.max - this.yRange.min);
    return this.plotArea.y + this.plotArea.height - ratio * this.plotArea.height;
  }
  
  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    
    return `${month}-${day} ${hour}:${minute}`;
  }
  
  /**
   * 格式化数字
   */
  private formatNumber(value: number): string {
    if (Math.abs(value) >= 1000000) {
      return (value / 1000000).toFixed(1) + 'M';
    } else if (Math.abs(value) >= 1000) {
      return (value / 1000).toFixed(1) + 'K';
    }
    return value.toFixed(1);
  }
  
  /**
   * HEX转RGBA
   */
  private hexToRgba(hex: string, alpha: number): string {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
  }
  
  /**
   * 获取数据点位置（用于交互）
   */
  public getDataPointAt(x: number, y: number): { series: LineChartSeries; point: TimeSeriesDataPoint } | null {
    const threshold = 10; // 点击阈值
    
    for (const s of this.series) {
      if (!s.show) continue;
      
      for (const point of s.data) {
        const px = this.mapX(point.timestamp);
        const py = this.mapY(point.value);
        
        const distance = Math.sqrt(Math.pow(x - px, 2) + Math.pow(y - py, 2));
        
        if (distance <= threshold) {
          return { series: s, point };
        }
      }
    }
    
    return null;
  }
}
