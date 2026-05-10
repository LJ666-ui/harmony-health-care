/**
 * 柱状图组件
 * 支持数据对比、横向/纵向切换、点击查看详情等功能
 */

import { BarChartConfig, BarChartSeries, DEFAULT_BAR_CHART_CONFIG } from './bar/types';
import { ChartService } from '../../service/ChartService';

/**
 * 柱状图组件
 */
@Component
export struct BarChart {
  @Prop config: Partial<BarChartConfig> = {};
  @Prop series: BarChartSeries[] = [];
  
  @State private width: number = 400;
  @State private height: number = 300;
  
  private settings: CanvasRenderingContext2D = new CanvasRenderingContext2D(new Settings());
  private chartService: ChartService = ChartService.getInstance();
  
  private getFullConfig(): BarChartConfig {
    return {
      ...DEFAULT_BAR_CHART_CONFIG,
      ...this.config,
      width: this.width,
      height: this.height
    } as BarChartConfig;
  }
  
  private onCanvasReady(): void {
    const fullConfig = this.getFullConfig();
    this.drawBarChart(fullConfig);
  }
  
  private drawBarChart(config: BarChartConfig): void {
    const ctx = this.settings;
    const top = config.padding[0];
    const right = config.padding[1];
    const bottom = config.padding[2];
    const left = config.padding[3];
    
    const plotArea = {
      x: left,
      y: top,
      width: config.width - left - right,
      height: config.height - top - bottom
    };
    
    // 绘制背景
    ctx.fillStyle = config.backgroundColor;
    ctx.fillRect(0, 0, config.width, config.height);
    
    // 计算Y轴范围
    const allValues: number[] = [];
    this.series.forEach(s => {
      s.data.forEach(item => {
        allValues.push(item.value);
      });
    });
    
    const yRange = this.chartService.calculateAxisRange(allValues, {
      tickCount: config.yAxis.tickCount ?? 5,
      nice: true,
      includeZero: true
    });
    
    // 绘制网格
    if (config.showGrid) {
      ctx.strokeStyle = config.gridColor;
      ctx.lineWidth = 1;
      
      yRange.ticks.forEach(tick => {
        const y = plotArea.y + plotArea.height - 
          ((tick - yRange.min) / (yRange.max - yRange.min)) * plotArea.height;
        
        ctx.beginPath();
        ctx.moveTo(plotArea.x, y);
        ctx.lineTo(plotArea.x + plotArea.width, y);
        ctx.stroke();
      });
    }
    
    // 绘制坐标轴
    if (config.showAxis) {
      ctx.strokeStyle = config.axisColor;
      ctx.lineWidth = 2;
      
      // X轴
      ctx.beginPath();
      ctx.moveTo(plotArea.x, plotArea.y + plotArea.height);
      ctx.lineTo(plotArea.x + plotArea.width, plotArea.y + plotArea.height);
      ctx.stroke();
      
      // Y轴
      ctx.beginPath();
      ctx.moveTo(plotArea.x, plotArea.y);
      ctx.lineTo(plotArea.x, plotArea.y + plotArea.height);
      ctx.stroke();
      
      // Y轴刻度标签
      ctx.fillStyle = config.axisTextColor;
      ctx.font = `${config.axisTextSize}px sans-serif`;
      ctx.textAlign = 'right';
      ctx.textBaseline = 'middle';
      
      yRange.ticks.forEach(tick => {
        const y = plotArea.y + plotArea.height - 
          ((tick - yRange.min) / (yRange.max - yRange.min)) * plotArea.height;
        ctx.fillText(tick.toFixed(1), plotArea.x - 8, y);
      });
    }
    
    // 绘制柱子
    const visibleSeries = this.series.filter(s => s.show);
    if (visibleSeries.length === 0) return;
    
    const categories = visibleSeries[0].data.map(item => item.category);
    const categoryCount = categories.length;
    const seriesCount = visibleSeries.length;
    
    const groupWidth = plotArea.width / categoryCount;
    const barWidth = (groupWidth * config.barWidth) / seriesCount;
    const barGap = groupWidth * config.barGap;
    
    categories.forEach((category, categoryIndex) => {
      const groupX = plotArea.x + categoryIndex * groupWidth + barGap / 2;
      
      visibleSeries.forEach((s, seriesIndex) => {
        const item = s.data[categoryIndex];
        const barX = groupX + seriesIndex * barWidth;
        
        const barHeight = ((item.value - yRange.min) / (yRange.max - yRange.min)) * plotArea.height;
        const barY = plotArea.y + plotArea.height - barHeight;
        
        // 绘制柱子
        ctx.fillStyle = item.color ?? s.color;
        
        if (config.borderRadius > 0) {
          // 圆角矩形
          this.drawRoundedRect(
            ctx,
            barX,
            barY,
            barWidth,
            barHeight,
            config.borderRadius
          );
        } else {
          ctx.fillRect(barX, barY, barWidth, barHeight);
        }
        
        // 绘制数值标签
        if (config.showLabel) {
          ctx.fillStyle = '#333333';
          ctx.font = '12px sans-serif';
          ctx.textAlign = 'center';
          ctx.textBaseline = 'bottom';
          ctx.fillText(item.value.toFixed(1), barX + barWidth / 2, barY - 4);
        }
      });
      
      // 绘制类目标签
      ctx.fillStyle = config.axisTextColor;
      ctx.font = `${config.axisTextSize}px sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'top';
      ctx.fillText(
        category,
        groupX + (seriesCount * barWidth) / 2,
        plotArea.y + plotArea.height + 8
      );
    });
  }
  
  private drawRoundedRect(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    width: number,
    height: number,
    radius: number
  ): void {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height);
    ctx.lineTo(x, y + height);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
    ctx.fill();
  }
  
  build() {
    Canvas(this.settings)
      .width('100%')
      .height('100%')
      .onReady(() => {
        this.onCanvasReady();
      })
      .onAreaChange((oldValue, newValue) => {
        this.width = newValue.width as number;
        this.height = newValue.height as number;
        this.onCanvasReady();
      })
  }
}
