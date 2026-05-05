/**
 * 健康指标仪表盘组件
 * Health Gauge - 展示健康指标状态
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

/**
 * 仪表盘配置
 */
export interface GaugeConfig {
  minValue: number;
  maxValue: number;
  warningThreshold: number;
  dangerThreshold: number;
}

/**
 * 健康指标仪表盘
 */
@Component
export struct HealthGauge {
  @Prop value: number = 0;
  @Prop maxValue: number = 100;
  @Prop minValue: number = 0;
  @Prop title: string = '';
  @Prop unit: string = '';
  @Prop warningThreshold: number = 70;
  @Prop dangerThreshold: number = 90;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /**
   * 获取状态颜色
   */
  private getStatusColor(): string {
    const percentage = (this.value - this.minValue) / (this.maxValue - this.minValue) * 100;

    if (percentage >= this.dangerThreshold) {
      return '#FF4D4F';  // 危险：红色
    } else if (percentage >= this.warningThreshold) {
      return '#FAAD14';  // 警告：黄色
    } else {
      return '#52C41A';  // 正常：绿色
    }
  }

  /**
   * 获取状态文字
   */
  private getStatusText(): string {
    const percentage = (this.value - this.minValue) / (this.maxValue - this.minValue) * 100;

    if (percentage >= this.dangerThreshold) {
      return '危险';
    } else if (percentage >= this.warningThreshold) {
      return '警告';
    } else {
      return '正常';
    }
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

      // 仪表盘
      Stack() {
        Canvas(this.context)
          .width(200)
          .height(200)
          .onReady(() => {
            this.drawGauge();
          })

        // 中心数值
        Column() {
          Text(this.value.toFixed(1))
            .fontSize(this.isElderMode ? 36 : 32)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getStatusColor())

          if (this.unit) {
            Text(this.unit)
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
        }
      }
      .width(200)
      .height(200)

      // 状态说明
      Row() {
        Row()
          .width(12)
          .height(12)
          .backgroundColor(this.getStatusColor())
          .borderRadius(6)

        Text(this.getStatusText())
          .fontSize(this.isElderMode ? 18 : 16)
          .fontColor(this.getStatusColor())
          .margin({ left: 8 })
      }
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 绘制仪表盘
   */
  private drawGauge(): void {
    const centerX = 100;
    const centerY = 100;
    const radius = 80;
    const lineWidth = 12;

    // 清空画布
    this.context.clearRect(0, 0, 200, 200);

    // 绘制背景圆环
    this.context.strokeStyle = '#F0F0F0';
    this.context.lineWidth = lineWidth;
    this.context.beginPath();
    this.context.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    this.context.stroke();

    // 绘制进度圆环
    const percentage = (this.value - this.minValue) / (this.maxValue - this.minValue);
    const angle = percentage * 2 * Math.PI;

    this.context.strokeStyle = this.getStatusColor();
    this.context.lineWidth = lineWidth;
    this.context.lineCap = 'round';
    this.context.beginPath();
    this.context.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + angle);
    this.context.stroke();
  }
}
