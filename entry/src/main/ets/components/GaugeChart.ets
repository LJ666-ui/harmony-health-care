export interface GaugeSegment {
  start: number;
  end: number;
  color: string;
}

@Component
export struct GaugeChart {
  @Prop value: number = 0;
  @Prop chartSize: number = 200;
  @Prop title: string = '风险评分';
  @Prop showLabel: boolean = true;
  
  animationProgress: number = 0;

  gaugeContext: CanvasRenderingContext2D = new CanvasRenderingContext2D();

  aboutToAppear(): void {
    this.animateValue();
  }

  animateValue(): void {
    const duration = 1000;
    const startTime = Date.now();
    
    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      this.animationProgress = this.easeOutBack(progress);
      
      if (progress < 1) {
        setTimeout(animate, 16);
      }
    };
    
    setTimeout(animate, 200);
  }

  easeOutBack(t: number): number {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
  }

  build() {
    Column({ space: 8 }) {
      Canvas(this.gaugeContext)
        .width(this.chartSize)
        .height(this.chartSize * 0.65)
        .onReady(() => {
          const width = this.chartSize;
          const height = this.chartSize * 0.65;
          const centerX = width / 2;
          const centerY = height - 10;
          const radius = Math.min(width, height) * 0.4;

          this.gaugeContext.clearRect(0, 0, width, height);

          this.drawBackgroundArc(this.gaugeContext, centerX, centerY, radius);

          if (this.value > 0) {
            this.drawValueArc(this.gaugeContext, centerX, centerY, radius);
            this.drawNeedle(this.gaugeContext, centerX, centerY, radius);
          }

          this.drawCenterText(this.gaugeContext, centerX, centerY, radius);
        })

      if (this.showLabel) {
        Text(this.getRiskLevelText())
          .fontSize(14)
          .fontColor(this.getRiskColor())
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  drawBackgroundArc(
    context: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number
  ): void {
    const startAngle = Math.PI * 0.75;
    const endAngle = Math.PI * 2.25;
    
    const segments: GaugeSegment[] = [
      { start: 0, end: 0.35, color: '#52C41A' },
      { start: 0.35, end: 0.6, color: '#FAAD14' },
      { start: 0.6, end: 0.8, color: '#FF4D4F' },
      { start: 0.8, end: 1.0, color: '#CF1322' }
    ];

    for (const segment of segments) {
      const segStart = startAngle + (endAngle - startAngle) * segment.start;
      const segEnd = startAngle + (endAngle - startAngle) * segment.end;

      context.beginPath();
      context.arc(centerX, centerY, radius, segStart, segEnd, false);
      context.strokeStyle = segment.color;
      context.lineWidth = 20;
      context.lineCap = 'round';
      context.stroke();
    }

    context.beginPath();
    context.arc(centerX, centerY, radius - 15, startAngle, endAngle, false);
    context.strokeStyle = 'rgba(0, 0, 0, 0.05)';
    context.lineWidth = 2;
    context.stroke();

    context.beginPath();
    context.arc(centerX, centerY, radius + 15, startAngle, endAngle, false);
    context.strokeStyle = 'rgba(0, 0, 0, 0.03)';
    context.lineWidth = 2;
    context.stroke();
  }

  drawValueArc(
    context: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number
  ): void {
    const startAngle = Math.PI * 0.75;
    const endAngle = Math.PI * 2.25;
    const valueAngle = startAngle + (endAngle - startAngle) * 
                       Math.min(this.value, 1) * this.animationProgress;

    context.beginPath();
    context.arc(centerX, centerY, radius, startAngle, valueAngle, false);

    const gradient = context.createLinearGradient(
      centerX - radius, centerY,
      centerX + radius, centerY
    );
    gradient.addColorStop(0, '#52C41A');
    gradient.addColorStop(0.5, '#FAAD14');
    gradient.addColorStop(0.8, '#FF4D4F');
    gradient.addColorStop(1, '#CF1322');

    context.strokeStyle = gradient;
    context.lineWidth = 18;
    context.lineCap = 'round';
    context.shadowColor = 'rgba(255, 77, 79, 0.4)';
    context.shadowBlur = 10;
    context.stroke();
    context.shadowBlur = 0;
  }

  drawNeedle(
    context: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number
  ): void {
    const startAngle = Math.PI * 0.75;
    const endAngle = Math.PI * 2.25;
    const needleAngle = startAngle + (endAngle - startAngle) * 
                        Math.min(this.value, 1) * this.animationProgress;

    const needleLength = radius * 0.7;
    const needleX = centerX + needleLength * Math.cos(needleAngle);
    const needleY = centerY + needleLength * Math.sin(needleAngle);

    context.beginPath();
    context.moveTo(centerX, centerY);
    context.lineTo(needleX, needleY);
    context.strokeStyle = '#333333';
    context.lineWidth = 3;
    context.lineCap = 'round';
    context.stroke();

    context.beginPath();
    context.arc(centerX, centerY, 8, 0, Math.PI * 2);
    context.fillStyle = '#333333';
    context.fill();
    context.strokeStyle = '#FFFFFF';
    context.lineWidth = 2;
    context.stroke();
  }

  drawCenterText(
    context: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number
  ): void {
    const displayValue = Math.round(Math.min(this.value, 1) * 100 * this.animationProgress);

    context.font = 'bold 32px sans-serif';
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    context.fillStyle = this.getRiskColor();
    context.fillText(displayValue.toString(), centerX, centerY - 10);

    context.font = '12px sans-serif';
    context.fillStyle = '#666666';
    context.fillText('分', centerX + displayValue.toString().length * 8 + 5, centerY - 10);

    context.font = '11px sans-serif';
    context.fillStyle = '#999999';
    context.fillText('满分100', centerX, centerY + 12);
  }

  getRiskColor(): string {
    if (this.value < 0.35) return '#52C41A';
    if (this.value < 0.55) return '#FAAD14';
    if (this.value < 0.75) return '#FF4D4F';
    return '#CF1322';
  }

  getRiskLevelText(): string {
    if (this.value < 0.35) return '🟢 低风险';
    if (this.value < 0.55) return '🟡 中等风险';
    if (this.value < 0.75) return '🔴 高风险';
    return '⛔ 极高风险';
  }
}
