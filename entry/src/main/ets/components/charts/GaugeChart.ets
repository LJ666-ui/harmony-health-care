/**
 * 仪表盘组件
 * 支持实时监测数据展示，颜色区分正常/警告/危险区域
 */

/**
 * 仪表盘区域
 */
export interface GaugeZone {
  from: number;
  to: number;
  color: string;
  label?: string;
}

/**
 * 仪表盘配置
 */
export interface GaugeConfig {
  width: number;
  height: number;
  min: number;
  max: number;
  value: number;
  title?: string;
  unit?: string;
  zones: GaugeZone[];
  backgroundColor: string;
  textColor: string;
  pointerColor: string;
  animation: boolean;
  animationDuration: number;
  startAngle: number;
  endAngle: number;
}

/**
 * 仪表盘组件
 */
@Component
export struct GaugeChart {
  @Prop config: Partial<GaugeConfig> = {};
  
  @State private width: number = 300;
  @State private height: number = 300;
  
  private settings: CanvasRenderingContext2D = new CanvasRenderingContext2D(new Settings());
  
  private getFullConfig(): GaugeConfig {
    return {
      width: this.width,
      height: this.height,
      min: 0,
      max: 100,
      value: 0,
      zones: [
        { from: 0, to: 60, color: '#27AE60', label: '正常' },
        { from: 60, to: 80, color: '#F39C12', label: '警告' },
        { from: 80, to: 100, color: '#E74C3C', label: '危险' }
      ],
      backgroundColor: '#FFFFFF',
      textColor: '#333333',
      pointerColor: '#333333',
      animation: true,
      animationDuration: 800,
      startAngle: -Math.PI * 0.75,
      endAngle: Math.PI * 0.75,
      ...this.config
    };
  }
  
  private onCanvasReady(): void {
    const config = this.getFullConfig();
    this.drawGauge(config);
  }
  
  private drawGauge(config: GaugeConfig): void {
    const ctx = this.settings;
    
    // 计算中心和半径
    const centerX = config.width / 2;
    const centerY = config.height / 2;
    const radius = Math.min(config.width, config.height) / 2 - 40;
    
    // 绘制背景
    ctx.fillStyle = config.backgroundColor;
    ctx.fillRect(0, 0, config.width, config.height);
    
    // 绘制区域
    this.drawZones(ctx, centerX, centerY, radius, config);
    
    // 绘制指针
    this.drawPointer(ctx, centerX, centerY, radius, config);
    
    // 绘制数值
    this.drawValue(ctx, centerX, centerY, radius, config);
    
    // 绘制标题
    if (config.title) {
      this.drawTitle(ctx, centerX, centerY, radius, config);
    }
  }
  
  private drawZones(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: GaugeConfig
  ): void {
    const totalAngle = config.endAngle - config.startAngle;
    const range = config.max - config.min;
    
    config.zones.forEach(zone => {
      const startAngle = config.startAngle + 
        ((zone.from - config.min) / range) * totalAngle;
      const endAngle = config.startAngle + 
        ((zone.to - config.min) / range) * totalAngle;
      
      ctx.beginPath();
      ctx.arc(centerX, centerY, radius, startAngle, endAngle);
      ctx.strokeStyle = zone.color;
      ctx.lineWidth = 20;
      ctx.lineCap = 'butt';
      ctx.stroke();
    });
    
    // 绘制刻度
    ctx.strokeStyle = '#CCCCCC';
    ctx.lineWidth = 1;
    
    const tickCount = 10;
    for (let i = 0; i <= tickCount; i++) {
      const angle = config.startAngle + (totalAngle / tickCount) * i;
      const innerRadius = radius - 25;
      const outerRadius = radius - 15;
      
      const x1 = centerX + innerRadius * Math.cos(angle);
      const y1 = centerY + innerRadius * Math.sin(angle);
      const x2 = centerX + outerRadius * Math.cos(angle);
      const y2 = centerY + outerRadius * Math.sin(angle);
      
      ctx.beginPath();
      ctx.moveTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.stroke();
      
      // 绘制刻度值
      const value = config.min + (range / tickCount) * i;
      const labelRadius = radius - 35;
      const labelX = centerX + labelRadius * Math.cos(angle);
      const labelY = centerY + labelRadius * Math.sin(angle);
      
      ctx.fillStyle = config.textColor;
      ctx.font = '12px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(value.toFixed(0), labelX, labelY);
    }
  }
  
  private drawPointer(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: GaugeConfig
  ): void {
    const totalAngle = config.endAngle - config.startAngle;
    const range = config.max - config.min;
    const valueAngle = config.startAngle + 
      ((config.value - config.min) / range) * totalAngle;
    
    const pointerLength = radius - 30;
    const pointerX = centerX + pointerLength * Math.cos(valueAngle);
    const pointerY = centerY + pointerLength * Math.sin(valueAngle);
    
    // 绘制指针
    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.lineTo(pointerX, pointerY);
    ctx.strokeStyle = config.pointerColor;
    ctx.lineWidth = 3;
    ctx.lineCap = 'round';
    ctx.stroke();
    
    // 绘制中心圆
    ctx.beginPath();
    ctx.arc(centerX, centerY, 8, 0, 2 * Math.PI);
    ctx.fillStyle = config.pointerColor;
    ctx.fill();
  }
  
  private drawValue(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: GaugeConfig
  ): void {
    const valueY = centerY + 30;
    
    ctx.fillStyle = config.textColor;
    ctx.font = 'bold 24px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    
    let valueText = config.value.toFixed(1);
    if (config.unit) {
      valueText += config.unit;
    }
    
    ctx.fillText(valueText, centerX, valueY);
  }
  
  private drawTitle(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    config: GaugeConfig
  ): void {
    const titleY = centerY + 60;
    
    ctx.fillStyle = config.textColor;
    ctx.font = '14px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(config.title!, centerX, titleY);
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
