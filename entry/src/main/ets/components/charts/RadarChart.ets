/**
 * 雷达图组件
 * 支持多维度健康评估可视化
 */

/**
 * 雷达图维度
 */
export interface RadarDimension {
  name: string;
  max: number;
}

/**
 * 雷达图数据
 */
export interface RadarData {
  name: string;
  value: number[];
  color: string;
}

/**
 * 雷达图配置
 */
export interface RadarConfig {
  width: number;
  height: number;
  dimensions: RadarDimension[];
  levels: number;
  shape: 'polygon' | 'circle';
  backgroundColor: string;
  axisColor: string;
  axisTextColor: string;
  gridColor: string;
  animation: boolean;
  animationDuration: number;
}

/**
 * 雷达图组件
 */
@Component
export struct RadarChart {
  @Prop config: Partial<RadarConfig> = {};
  @Prop data: RadarData[] = [];
  
  @State private width: number = 400;
  @State private height: number = 400;
  
  private settings: CanvasRenderingContext2D = new CanvasRenderingContext2D(new Settings());
  
  private getFullConfig(): RadarConfig {
    return {
      width: this.width,
      height: this.height,
      dimensions: [],
      levels: 5,
      shape: 'polygon',
      backgroundColor: '#FFFFFF',
      axisColor: '#333333',
      axisTextColor: '#666666',
      gridColor: '#E0E0E0',
      animation: true,
      animationDuration: 800,
      ...this.config
    };
  }
  
  private onCanvasReady(): void {
    const config = this.getFullConfig();
    this.drawRadarChart(config);
  }
  
  private drawRadarChart(config: RadarConfig): void {
    const ctx = this.settings;
    
    // 计算中心和半径
    const centerX = config.width / 2;
    const centerY = config.height / 2;
    const radius = Math.min(config.width, config.height) / 2 - 60;
    
    // 绘制背景
    ctx.fillStyle = config.backgroundColor;
    ctx.fillRect(0, 0, config.width, config.height);
    
    const dimensions = config.dimensions;
    if (dimensions.length === 0) return;
    
    const angleStep = (2 * Math.PI) / dimensions.length;
    
    // 绘制网格
    this.drawGrid(ctx, centerX, centerY, radius, config, angleStep);
    
    // 绘制轴线
    this.drawAxes(ctx, centerX, centerY, radius, config, angleStep);
    
    // 绘制数据
    this.drawData(ctx, centerX, centerY, radius, config, angleStep);
    
    // 绘制标签
    this.drawLabels(ctx, centerX, centerY, radius, config, angleStep);
  }
  
  private drawGrid(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: RadarConfig,
    angleStep: number
  ): void {
    ctx.strokeStyle = config.gridColor;
    ctx.lineWidth = 1;
    
    for (let level = 1; level <= config.levels; level++) {
      const levelRadius = (radius / config.levels) * level;
      
      ctx.beginPath();
      
      if (config.shape === 'circle') {
        ctx.arc(centerX, centerY, levelRadius, 0, 2 * Math.PI);
      } else {
        for (let i = 0; i < config.dimensions.length; i++) {
          const angle = angleStep * i - Math.PI / 2;
          const x = centerX + levelRadius * Math.cos(angle);
          const y = centerY + levelRadius * Math.sin(angle);
          
          if (i === 0) {
            ctx.moveTo(x, y);
          } else {
            ctx.lineTo(x, y);
          }
        }
        ctx.closePath();
      }
      
      ctx.stroke();
    }
  }
  
  private drawAxes(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: RadarConfig,
    angleStep: number
  ): void {
    ctx.strokeStyle = config.axisColor;
    ctx.lineWidth = 2;
    
    for (let i = 0; i < config.dimensions.length; i++) {
      const angle = angleStep * i - Math.PI / 2;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);
      
      ctx.beginPath();
      ctx.moveTo(centerX, centerY);
      ctx.lineTo(x, y);
      ctx.stroke();
    }
  }
  
  private drawData(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: RadarConfig,
    angleStep: number
  ): void {
    this.data.forEach((dataItem, dataIndex) => {
      ctx.beginPath();
      
      dataItem.value.forEach((value, i) => {
        const angle = angleStep * i - Math.PI / 2;
        const max = config.dimensions[i].max;
        const ratio = value / max;
        const r = radius * ratio;
        
        const x = centerX + r * Math.cos(angle);
        const y = centerY + r * Math.sin(angle);
        
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      });
      
      ctx.closePath();
      
      // 填充
      ctx.fillStyle = this.hexToRgba(dataItem.color, 0.3);
      ctx.fill();
      
      // 描边
      ctx.strokeStyle = dataItem.color;
      ctx.lineWidth = 2;
      ctx.stroke();
      
      // 绘制数据点
      dataItem.value.forEach((value, i) => {
        const angle = angleStep * i - Math.PI / 2;
        const max = config.dimensions[i].max;
        const ratio = value / max;
        const r = radius * ratio;
        
        const x = centerX + r * Math.cos(angle);
        const y = centerY + r * Math.sin(angle);
        
        ctx.beginPath();
        ctx.arc(x, y, 4, 0, 2 * Math.PI);
        ctx.fillStyle = dataItem.color;
        ctx.fill();
      });
    });
  }
  
  private drawLabels(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: RadarConfig,
    angleStep: number
  ): void {
    ctx.fillStyle = config.axisTextColor;
    ctx.font = '14px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    
    config.dimensions.forEach((dim, i) => {
      const angle = angleStep * i - Math.PI / 2;
      const x = centerX + (radius + 30) * Math.cos(angle);
      const y = centerY + (radius + 30) * Math.sin(angle);
      
      ctx.fillText(dim.name, x, y);
    });
  }
  
  private hexToRgba(hex: string, alpha: number): string {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
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
