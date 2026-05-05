/**
 * 热力图组件
 * 支持时间分布数据可视化
 */

/**
 * 热力图数据点
 */
export interface HeatmapDataPoint {
  x: number;
  y: number;
  value: number;
}

/**
 * 热力图配置
 */
export interface HeatmapConfig {
  width: number;
  height: number;
  xLabels: string[];
  yLabels: string[];
  min: number;
  max: number;
  colors: string[];
  backgroundColor: string;
  textColor: string;
  showLabels: boolean;
  animation: boolean;
  animationDuration: number;
}

/**
 * 热力图组件
 */
@Component
export struct HeatmapChart {
  @Prop config: Partial<HeatmapConfig> = {};
  @Prop data: HeatmapDataPoint[] = [];
  
  @State private width: number = 400;
  @State private height: number = 300;
  
  private settings: CanvasRenderingContext2D = new CanvasRenderingContext2D(new Settings());
  
  private getFullConfig(): HeatmapConfig {
    return {
      width: this.width,
      height: this.height,
      xLabels: [],
      yLabels: [],
      min: 0,
      max: 100,
      colors: ['#EBEDF0', '#9BE9A8', '#40C463', '#30A14E', '#216E39'],
      backgroundColor: '#FFFFFF',
      textColor: '#333333',
      showLabels: true,
      animation: true,
      animationDuration: 800,
      ...this.config
    };
  }
  
  private onCanvasReady(): void {
    const config = this.getFullConfig();
    this.drawHeatmap(config);
  }
  
  private drawHeatmap(config: HeatmapConfig): void {
    const ctx = this.settings;
    
    // 绘制背景
    ctx.fillStyle = config.backgroundColor;
    ctx.fillRect(0, 0, config.width, config.height);
    
    if (config.xLabels.length === 0 || config.yLabels.length === 0) return;
    
    // 计算单元格大小
    const leftPadding = 60;
    const topPadding = 40;
    const rightPadding = 20;
    const bottomPadding = 40;
    
    const gridWidth = config.width - leftPadding - rightPadding;
    const gridHeight = config.height - topPadding - bottomPadding;
    
    const cellWidth = gridWidth / config.xLabels.length;
    const cellHeight = gridHeight / config.yLabels.length;
    
    // 绘制单元格
    this.data.forEach(point => {
      const x = leftPadding + point.x * cellWidth;
      const y = topPadding + point.y * cellHeight;
      
      const color = this.getColor(point.value, config);
      
      ctx.fillStyle = color;
      ctx.fillRect(x, y, cellWidth - 2, cellHeight - 2);
    });
    
    // 绘制X轴标签
    if (config.showLabels) {
      ctx.fillStyle = config.textColor;
      ctx.font = '12px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'top';
      
      config.xLabels.forEach((label, i) => {
        const x = leftPadding + (i + 0.5) * cellWidth;
        const y = config.height - bottomPadding + 10;
        ctx.fillText(label, x, y);
      });
      
      // 绘制Y轴标签
      ctx.textAlign = 'right';
      ctx.textBaseline = 'middle';
      
      config.yLabels.forEach((label, i) => {
        const x = leftPadding - 10;
        const y = topPadding + (i + 0.5) * cellHeight;
        ctx.fillText(label, x, y);
      });
    }
    
    // 绘制图例
    this.drawLegend(ctx, config);
  }
  
  private getColor(value: number, config: HeatmapConfig): string {
    const ratio = (value - config.min) / (config.max - config.min);
    const index = Math.floor(ratio * (config.colors.length - 1));
    return config.colors[Math.min(index, config.colors.length - 1)];
  }
  
  private drawLegend(ctx: CanvasRenderingContext2D, config: HeatmapConfig): void {
    const legendX = config.width - 100;
    const legendY = 20;
    const legendWidth = 80;
    const legendHeight = 15;
    
    // 绘制渐变条
    const step = legendWidth / (config.colors.length - 1);
    
    config.colors.forEach((color, i) => {
      if (i < config.colors.length - 1) {
        const x = legendX + i * step;
        
        ctx.fillStyle = color;
        ctx.fillRect(x, legendY, step, legendHeight);
      }
    });
    
    // 绘制最小值和最大值标签
    ctx.fillStyle = config.textColor;
    ctx.font = '10px sans-serif';
    ctx.textAlign = 'left';
    ctx.textBaseline = 'top';
    ctx.fillText(config.min.toFixed(0), legendX, legendY + legendHeight + 5);
    
    ctx.textAlign = 'right';
    ctx.fillText(config.max.toFixed(0), legendX + legendWidth, legendY + legendHeight + 5);
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
