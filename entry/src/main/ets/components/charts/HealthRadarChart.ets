/**
 * 健康评分雷达图组件
 * Health Radar Chart - 展示多维度健康评分
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

/**
 * 雷达图维度
 */
export interface RadarDimension {
  name: string;       // 维度名称
  value: number;      // 当前值
  maxValue: number;   // 最大值
  unit?: string;      // 单位
}

/**
 * 健康评分雷达图
 */
@Component
export struct HealthRadarChart {
  @Prop dimensions: RadarDimension[] = [];
  @Prop title: string = '';
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /**
   * 获取维度数量
   */
  private getDimensionCount(): number {
    return this.dimensions.length || 6;
  }

  /**
   * 计算维度角度
   */
  private getAngle(index: number): number {
    return (index * 2 * Math.PI) / this.getDimensionCount() - Math.PI / 2;
  }

  build() {
    Column() {
      // 标题
      if (this.title) {
        Text(this.title)
          .fontSize(this.isElderMode ? 20 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 16 })
      }

      // 雷达图
      Stack() {
        Canvas(this.context)
          .width(250)
          .height(250)
          .onReady(() => {
            this.drawRadar();
          })
      }
      .width(250)
      .height(250)

      // 维度标签
      if (this.dimensions.length > 0) {
        this.buildDimensionLabels()
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  /**
   * 构建维度标签
   */
  @Builder buildDimensionLabels(): void {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(this.dimensions, (dim: RadarDimension) => {
        Row() {
          Row()
            .width(8)
            .height(8)
            .backgroundColor('#1677FF')
            .borderRadius(4)

          Text(`${dim.name}: ${dim.value}/${dim.maxValue}`)
            .fontSize(this.isElderMode ? 16 : 12)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
        .margin({ right: 12, bottom: 8 })
      })
    }
    .width('100%')
    .margin({ top: 16 })
  }

  /**
   * 绘制雷达图
   */
  private drawRadar(): void {
    const centerX = 125;
    const centerY = 125;
    const maxRadius = 100;
    const levels = 5;  // 网格层数

    // 清空画布
    this.context.clearRect(0, 0, 250, 250);

    // 绘制背景网格
    this.drawRadarGrid(centerX, centerY, maxRadius, levels);

    // 绘制数据区域
    this.drawRadarData(centerX, centerY, maxRadius);

    // 绘制维度标签
    this.drawDimensionLabelsOnChart(centerX, centerY, maxRadius);
  }

  /**
   * 绘制雷达网格
   */
  private drawRadarGrid(
    centerX: number,
    centerY: number,
    maxRadius: number,
    levels: number
  ): void {
    this.context.strokeStyle = '#E0E0E0';
    this.context.lineWidth = 1;

    // 绘制同心多边形
    for (let level = 1; level <= levels; level++) {
      const radius = (maxRadius * level) / levels;
      this.context.beginPath();

      for (let i = 0; i < this.getDimensionCount(); i++) {
        const angle = this.getAngle(i);
        const x = centerX + radius * Math.cos(angle);
        const y = centerY + radius * Math.sin(angle);

        if (i === 0) {
          this.context.moveTo(x, y);
        } else {
          this.context.lineTo(x, y);
        }
      }

      this.context.closePath();
      this.context.stroke();
    }

    // 绘制轴线
    for (let i = 0; i < this.getDimensionCount(); i++) {
      const angle = this.getAngle(i);
      const x = centerX + maxRadius * Math.cos(angle);
      const y = centerY + maxRadius * Math.sin(angle);

      this.context.beginPath();
      this.context.moveTo(centerX, centerY);
      this.context.lineTo(x, y);
      this.context.stroke();
    }
  }

  /**
   * 绘制雷达数据
   */
  private drawRadarData(
    centerX: number,
    centerY: number,
    maxRadius: number
  ): void {
    if (this.dimensions.length === 0) {
      return;
    }

    // 绘制数据多边形
    this.context.beginPath();

    for (let i = 0; i < this.dimensions.length; i++) {
      const dim = this.dimensions[i];
      const angle = this.getAngle(i);
      const radius = (dim.value / dim.maxValue) * maxRadius;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      if (i === 0) {
        this.context.moveTo(x, y);
      } else {
        this.context.lineTo(x, y);
      }
    }

    this.context.closePath();

    // 填充
    this.context.fillStyle = 'rgba(22, 119, 255, 0.2)';
    this.context.fill();

    // 边框
    this.context.strokeStyle = '#1677FF';
    this.context.lineWidth = 2;
    this.context.stroke();

    // 绘制数据点
    this.context.fillStyle = '#1677FF';
    for (let i = 0; i < this.dimensions.length; i++) {
      const dim = this.dimensions[i];
      const angle = this.getAngle(i);
      const radius = (dim.value / dim.maxValue) * maxRadius;
      const x = centerX + radius * Math.cos(angle);
      const y = centerY + radius * Math.sin(angle);

      this.context.beginPath();
      this.context.arc(x, y, 4, 0, 2 * Math.PI);
      this.context.fill();
    }
  }

  /**
   * 在图表上绘制维度标签
   */
  private drawDimensionLabelsOnChart(
    centerX: number,
    centerY: number,
    maxRadius: number
  ): void {
    this.context.fillStyle = '#666666';
    this.context.font = '12px sans-serif';
    this.context.textAlign = 'center';
    this.context.textBaseline = 'middle';

    for (let i = 0; i < this.dimensions.length; i++) {
      const dim = this.dimensions[i];
      const angle = this.getAngle(i);
      const labelRadius = maxRadius + 20;
      const x = centerX + labelRadius * Math.cos(angle);
      const y = centerY + labelRadius * Math.sin(angle);

      this.context.fillText(dim.name, x, y);
    }
  }
}
