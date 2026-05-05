/**
 * 折线图组件
 * 支持时间序列数据展示、多系列、缩放拖拽等功能
 */

import { LineChartConfig, LineChartSeries, LineChartData, DEFAULT_LINE_CHART_CONFIG } from './line/types';
import { LineChartRenderer } from './line/LineChartRenderer';
import { BaseChartConfig } from './types';

/**
 * 折线图组件
 */
@Component
export struct LineChart {
  // 配置
  @Prop config: Partial<LineChartConfig> = {};
  
  // 数据系列
  @Prop series: LineChartSeries[] = [];
  
  // 组件尺寸
  @State private width: number = 400;
  @State private height: number = 300;
  
  // Canvas上下文
  private settings: CanvasRenderingContext2D = new CanvasRenderingContext2D(new Settings());
  private renderer: LineChartRenderer | null = null;
  
  // 交互状态
  @State private isInteracting: boolean = false;
  @State private tooltipData: { x: number; y: number; content: string } | null = null;
  
  // 触摸状态
  private lastTouchX: number = 0;
  private lastTouchY: number = 0;
  private lastPinchDistance: number = 0;
  
  /**
   * 获取完整配置
   */
  private getFullConfig(): LineChartConfig {
    return {
      ...DEFAULT_LINE_CHART_CONFIG,
      ...this.config,
      width: this.width,
      height: this.height
    } as LineChartConfig;
  }
  
  /**
   * Canvas准备就绪
   */
  private onCanvasReady(): void {
    const fullConfig = this.getFullConfig();
    
    this.renderer = new LineChartRenderer(
      this.settings,
      fullConfig,
      this.series
    );
    
    this.renderer.draw();
  }
  
  /**
   * 处理点击事件
   */
  private handleCanvasClick(x: number, y: number): void {
    if (!this.renderer) return;
    
    const dataPoint = this.renderer.getDataPointAt(x, y);
    
    if (dataPoint) {
      // 显示Tooltip
      this.tooltipData = {
        x,
        y,
        content: `${dataPoint.series.name}\n${new Date(dataPoint.point.timestamp).toLocaleString()}\n值: ${dataPoint.point.value.toFixed(2)}`
      };
    } else {
      // 隐藏Tooltip
      this.tooltipData = null;
    }
  }
  
  /**
   * 处理触摸事件
   */
  private handleTouch(event: TouchEvent): void {
    const touches = event.touches;
    
    if (touches.length === 1) {
      // 单指触摸 - 平移
      const touch = touches[0];
      const deltaX = touch.x - this.lastTouchX;
      const deltaY = touch.y - this.lastTouchY;
      
      this.lastTouchX = touch.x;
      this.lastTouchY = touch.y;
      
      // TODO: 实现平移逻辑
    } else if (touches.length === 2) {
      // 双指触摸 - 缩放
      const distance = Math.sqrt(
        Math.pow(touches[0].x - touches[1].x, 2) +
        Math.pow(touches[0].y - touches[1].y, 2)
      );
      
      if (this.lastPinchDistance > 0) {
        const scale = distance / this.lastPinchDistance;
        // TODO: 实现缩放逻辑
      }
      
      this.lastPinchDistance = distance;
    }
  }
  
  build() {
    Stack() {
      // Canvas图层
      Canvas(this.settings)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.onCanvasReady();
        })
        .onClick((event) => {
          this.handleCanvasClick(event.x, event.y);
        })
        .onTouch((event) => {
          this.handleTouch(event);
        })
      
      // Tooltip图层
      if (this.tooltipData) {
        Column() {
          Text(this.tooltipData.content)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding(8)
        }
        .backgroundColor('#CC000000')
        .borderRadius(4)
        .position({
          x: this.tooltipData.x + 10,
          y: this.tooltipData.y - 60
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldValue, newValue) => {
      // 更新组件尺寸
      this.width = newValue.width as number;
      this.height = newValue.height as number;
      
      // 重新绘制
      if (this.renderer) {
        this.onCanvasReady();
      }
    })
  }
}

/**
 * 创建折线图的便捷函数
 */
export function createLineChart(
  series: LineChartSeries[],
  options?: Partial<LineChartConfig>
): LineChart {
  // 注意：这个函数主要用于类型提示
  throw new Error('Use the component directly in build() method.');
}
