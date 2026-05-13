import { HealthTrend, TrendPoint } from '../services/HealthService';

@Component
export struct HealthTrendChart {
  @Prop trendData: HealthTrend | null = null;
  @Prop dataType: string = '';
  @Prop title: string = '';
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State selectedRange: number = 7;

  private chartWidth: number = 320;
  private chartHeight: number = 180;
  private padding: number = 35;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.title)
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1);

        Row({ space: 6 }) {
          ForEach([7, 30, 90], (days: number) => {
            Text(days === 7 ? '7天' : days === 30 ? '30天' : '3月')
              .fontSize(this.isElderMode ? 13 : 11)
              .fontColor(this.selectedRange === days ? '#FFFFFF' : '#666')
              .backgroundColor(this.selectedRange === days ? '#3498DB' : '#F0F0F0')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(12)
              .onClick(() => {
                this.selectedRange = days;
              });
          });
        }
      }
      .width('100%');

      if (this.trendData && this.trendData.dataPoints.length > 0) {
        Column() {
          Canvas(this.context)
            .width(this.chartWidth)
            .height(this.chartHeight)
            .onReady(() => {
              this.drawChart();
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);

        this.buildStatistics();
      } else {
        Column() {
          Text('📊')
            .fontSize(40);
          Text('暂无数据')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 8 });
        }
        .width('100%')
        .height(this.chartHeight)
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8);
  }

  @Builder buildStatistics(): void {
    Row() {
      Column() {
        Text('平均')
          .fontSize(this.isElderMode ? 12 : 10)
          .fontColor('#999');
        Text(this.trendData!.average.toFixed(1))
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor('#333')
          .fontWeight(FontWeight.Bold);
      }
      .layoutWeight(1);

      Column() {
        Text('最低')
          .fontSize(this.isElderMode ? 12 : 10)
          .fontColor('#999');
        Text(this.trendData!.min.toFixed(1))
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor('#27AE60')
          .fontWeight(FontWeight.Bold);
      }
      .layoutWeight(1);

      Column() {
        Text('最高')
          .fontSize(this.isElderMode ? 12 : 10)
          .fontColor('#999');
        Text(this.trendData!.max.toFixed(1))
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor('#E74C3C')
          .fontWeight(FontWeight.Bold);
      }
      .layoutWeight(1);

      Column() {
        Text('趋势')
          .fontSize(this.isElderMode ? 12 : 10)
          .fontColor('#999');
        Row() {
          Text(this.getTrendIcon())
            .fontSize(this.isElderMode ? 18 : 16)
            .fontColor(this.getTrendColor());
        }
      }
      .layoutWeight(1);
    }
    .width('100%');
  }

  private drawChart(): void {
    if (!this.trendData || this.trendData.dataPoints.length === 0) return;

    const points = this.trendData.dataPoints;
    const ctx = this.context;

    ctx.clearRect(0, 0, this.chartWidth, this.chartHeight);

    ctx.strokeStyle = '#E0E0E0';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(this.padding, this.padding);
    ctx.lineTo(this.padding, this.chartHeight - this.padding);
    ctx.lineTo(this.chartWidth - this.padding, this.chartHeight - this.padding);
    ctx.stroke();

    const yRange = this.trendData.max - this.trendData.min;
    const yScale = (this.chartHeight - 2 * this.padding) / (yRange || 1);

    ctx.strokeStyle = '#F0F0F0';
    ctx.lineWidth = 0.5;
    for (let i = 0; i <= 4; i++) {
      const y = this.padding + (i * (this.chartHeight - 2 * this.padding) / 4);
      ctx.beginPath();
      ctx.moveTo(this.padding, y);
      ctx.lineTo(this.chartWidth - this.padding, y);
      ctx.stroke();
    }

    ctx.strokeStyle = '#3498DB';
    ctx.lineWidth = 2;
    ctx.beginPath();

    const xStep = (this.chartWidth - 2 * this.padding) / Math.max(points.length - 1, 1);

    points.forEach((point, index) => {
      const x = this.padding + index * xStep;
      const y = this.chartHeight - this.padding - (point.value - this.trendData!.min) * yScale;

      if (index === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    });

    ctx.stroke();

    ctx.fillStyle = '#3498DB';
    points.forEach((point, index) => {
      const x = this.padding + index * xStep;
      const y = this.chartHeight - this.padding - (point.value - this.trendData!.min) * yScale;
      ctx.beginPath();
      ctx.arc(x, y, 3, 0, 2 * Math.PI);
      ctx.fill();
    });

    ctx.fillStyle = '#666';
    ctx.font = '10px sans-serif';
    ctx.textAlign = 'center';

    if (points.length > 0) {
      const firstDate = points[0].date;
      const lastDate = points[points.length - 1].date;
      ctx.fillText(firstDate, this.padding, this.chartHeight - 10);
      ctx.fillText(lastDate, this.chartWidth - this.padding, this.chartHeight - 10);
    }

    ctx.textAlign = 'right';
    ctx.fillText(this.trendData.max.toFixed(0), this.padding - 5, this.padding + 5);
    ctx.fillText(this.trendData.min.toFixed(0), this.padding - 5, this.chartHeight - this.padding + 5);
  }

  private getTrendIcon(): string {
    if (!this.trendData) return '→';
    switch (this.trendData.trend) {
      case 'rising':
        return '↑';
      case 'falling':
        return '↓';
      default:
        return '→';
    }
  }

  private getTrendColor(): string {
    if (!this.trendData) return '#666';
    switch (this.trendData.trend) {
      case 'rising':
        return '#E74C3C';
      case 'falling':
        return '#27AE60';
      default:
        return '#666';
    }
  }
}
