/**
 * 健康数据折线图组件
 * Health Line Chart - 展示健康数据趋势
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

/**
 * 数据点
 */
export interface ChartDataPoint {
  x: number;          // X轴值（通常是时间戳）
  y: number;          // Y轴值
  label?: string;     // 标签
}

/**
 * 折线图配置
 */
export interface LineChartConfig {
  width: number;
  height: number;
  showGrid: boolean;
  showDots: boolean;
  lineColor: string;
  gridColor: string;
}

/**
 * 范围接口
 */
export interface Range {
  min: number;
  max: number;
}

/**
 * 健康数据折线图
 */
@Component
export struct HealthLineChart {
  @Prop data: ChartDataPoint[] = [];
  @Prop title: string = '';
  @Prop unit: string = '';
  @Prop showGrid: boolean = true;
  @Prop lineColor: string = '#1677FF';
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /**
   * 获取Y轴范围
   */
  private getYRange(): Range {
    const defaultRange: Range = { min: 0, max: 100 };
    if (this.data.length === 0) {
      return defaultRange;
    }

    const values = this.data.map(d => d.y);
    const min = Math.min(...values);
    const max = Math.max(...values);
    const padding = (max - min) * 0.1;

    const result: Range = {
      min: min - padding,
      max: max + padding
    };
    return result;
  }

  /**
   * 获取X轴范围
   */
  private getXRange(): Range {
    const defaultRange: Range = { min: 0, max: 100 };
    if (this.data.length === 0) {
      return defaultRange;
    }

    const values = this.data.map(d => d.x);
    const result: Range = {
      min: Math.min(...values),
      max: Math.max(...values)
    };
    return result;
  }

  /**
   * X坐标转换
   */
  private xToPixel(x: number, width: number): number {
    const range = this.getXRange();
    return ((x - range.min) / (range.max - range.min)) * width;
  }

  /**
   * Y坐标转换
   */
  private yToPixel(y: number, height: number): number {
    const range = this.getYRange();
    return height - ((y - range.min) / (range.max - range.min)) * height;
  }

  build() {
    Column() {
      // 标题
      if (this.title) {
        Row() {
          Text(this.title)
            .fontSize(this.isElderMode ? 20 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Text(this.unit)
            .fontSize(this.isElderMode ? 16 : 12)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      // 图表
      Canvas(this.context)
        .width('100%')
        .height(200)
        .onReady(() => {
          this.drawChart();
        })

      // 图例
      Row() {
        Row() {
          Row()
            .width(20)
            .height(3)
            .backgroundColor(this.lineColor)
            .borderRadius(1.5)

          Text(this.title)
            .fontSize(this.isElderMode ? 16 : 12)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 绘制图表
   */
  private drawChart(): void {
    const width = this.context.width;
    const height = this.context.height;
    const padding = 40;

    // 清空画布
    this.context.clearRect(0, 0, width, height);

    // 绘制网格
    if (this.showGrid) {
      this.drawGrid(width, height, padding);
    }

    // 绘制折线
    this.drawLine(width, height, padding);

    // 绘制数据点
    this.drawDots(width, height, padding);
  }

  /**
   * 绘制网格
   */
  private drawGrid(width: number, height: number, padding: number): void {
    this.context.strokeStyle = '#F0F0F0';
    this.context.lineWidth = 1;

    // 横线
    for (let i = 0; i <= 4; i++) {
      const y = padding + (height - 2 * padding) * i / 4;
      this.context.beginPath();
      this.context.moveTo(padding, y);
      this.context.lineTo(width - padding, y);
      this.context.stroke();
    }

    // 竖线
    for (let i = 0; i <= 4; i++) {
      const x = padding + (width - 2 * padding) * i / 4;
      this.context.beginPath();
      this.context.moveTo(x, padding);
      this.context.lineTo(x, height - padding);
      this.context.stroke();
    }
  }

  /**
   * 绘制折线
   */
  private drawLine(width: number, height: number, padding: number): void {
    if (this.data.length < 2) {
      return;
    }

    this.context.strokeStyle = this.lineColor;
    this.context.lineWidth = 2;
    this.context.beginPath();

    const chartWidth = width - 2 * padding;
    const chartHeight = height - 2 * padding;

    for (let i = 0; i < this.data.length; i++) {
      const x = padding + this.xToPixel(this.data[i].x, chartWidth);
      const y = padding + this.yToPixel(this.data[i].y, chartHeight);

      if (i === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
    }

    this.context.stroke();
  }

  /**
   * 绘制数据点
   */
  private drawDots(width: number, height: number, padding: number): void {
    const chartWidth = width - 2 * padding;
    const chartHeight = height - 2 * padding;

    this.context.fillStyle = this.lineColor;

    for (const point of this.data) {
      const x = padding + this.xToPixel(point.x, chartWidth);
      const y = padding + this.yToPixel(point.y, chartHeight);

      this.context.beginPath();
      this.context.arc(x, y, 4, 0, 2 * Math.PI);
      this.context.fill();
    }
  }
}
