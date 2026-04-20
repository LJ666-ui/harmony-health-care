export interface RadarDataItem {
  label: string;
  value: number;
  color: string;
}

@Component
export struct RadarChart {
  @Prop data: RadarDataItem[] = [];
  @State chartSize: number = 300;
  @State showValue: boolean = true;
  @State animated: boolean = true;

  animationProgress: number = 0;
  animationTimerId: number | null = null;

  aboutToAppear(): void {
    if (this.animated) {
      this.startAnimation();
    } else {
      this.animationProgress = 1.0;
    }
  }

  aboutToDisappear(): void {
    this.stopAnimation();
  }

  startAnimation(): void {
    this.animationProgress = 0;
    const duration = 1000;
    const startTime = Date.now();

    const animate = () => {
      const elapsed = Date.now() - startTime;
      this.animationProgress = Math.min(elapsed / duration, 1.0);
      this.animationProgress = this.easeOutCubic(this.animationProgress);

      if (this.animationProgress < 1.0) {
        this.animationTimerId = setTimeout(animate, 16) as number;
      }
    };

    this.animationTimerId = setTimeout(animate, 16) as number;
  }

  stopAnimation(): void {
    if (this.animationTimerId !== null) {
      clearTimeout(this.animationTimerId);
      this.animationTimerId = null;
    }
  }

  easeOutCubic(t: number): number {
    return 1 - Math.pow(1 - t, 3);
  }

  build() {
    Canvas(this.context)
      .width(this.chartSize)
      .height(this.chartSize)
      .onReady(() => {
        this.drawRadarChart();
      })
  }

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D();

  drawRadarChart(): void {
    const ctx = this.context;
    const centerX = this.chartSize / 2;
    const centerY = this.chartSize / 2;
    const radius = (this.chartSize / 2) * 0.75;
    const levels = 5;
    const angleStep = (Math.PI * 2) / this.data.length;

    ctx.clearRect(0, 0, this.chartSize, this.chartSize);

    this.drawBackgroundGrid(ctx, centerX, centerY, radius, levels, angleStep);
    this.drawAxesAndLabels(ctx, centerX, centerY, radius, angleStep);
    this.drawDataArea(ctx, centerX, centerY, radius, angleStep);
    this.drawDataPoints(ctx, centerX, centerY, radius, angleStep);
  }

  drawBackgroundGrid(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    levels: number,
    angleStep: number
  ): void {
    ctx.strokeStyle = '#E8E8E8';
    ctx.lineWidth = 1;

    for (let level = 1; level <= levels; level++) {
      const levelRadius = (radius / levels) * level;
      ctx.beginPath();
      for (let i = 0; i <= this.data.length; i++) {
        const angle = i * angleStep - Math.PI / 2;
        const x = centerX + levelRadius * Math.cos(angle);
        const y = centerY + levelRadius * Math.sin(angle);
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.closePath();
      ctx.stroke();
    }

    for (let i = 0; i < this.data.length; i++) {
      const angle = i * angleStep - Math.PI / 2;
      ctx.beginPath();
      ctx.moveTo(centerX, centerY);
      ctx.lineTo(centerX + radius * Math.cos(angle), centerY + radius * Math.sin(angle));
      ctx.stroke();
    }
  }

  drawAxesAndLabels(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    angleStep: number
  ): void {
    ctx.fillStyle = '#666666';
    ctx.font = '12px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    for (let i = 0; i < this.data.length; i++) {
      const angle = i * angleStep - Math.PI / 2;
      const labelRadius = radius + 20;
      const x = centerX + labelRadius * Math.cos(angle);
      const y = centerY + labelRadius * Math.sin(angle);
      ctx.fillText(this.data[i].label, x, y);
    }
  }

  drawDataArea(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    angleStep: number
  ): void {
    if (this.data.length === 0) return;

    ctx.globalAlpha = 0.3;
    ctx.fillStyle = '#1890FF';
    ctx.strokeStyle = '#1890FF';
    ctx.lineWidth = 2;

    ctx.beginPath();
    for (let i = 0; i <= this.data.length; i++) {
      const idx = i % this.data.length;
      const angle = idx * angleStep - Math.PI / 2;
      const value = this.data[idx].value * this.animationProgress;
      const pointRadius = (value / 100) * radius;
      const x = centerX + pointRadius * Math.cos(angle);
      const y = centerY + pointRadius * Math.sin(angle);

      if (i === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    }
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
    ctx.globalAlpha = 1.0;
  }

  drawDataPoints(
    ctx: CanvasRenderingContext2D,
    centerX: number,
    centerY: number,
    radius: number,
    angleStep: number
  ): void {
    for (let i = 0; i < this.data.length; i++) {
      const angle = i * angleStep - Math.PI / 2;
      const value = this.data[i].value * this.animationProgress;
      const pointRadius = (value / 100) * radius;
      const x = centerX + pointRadius * Math.cos(angle);
      const y = centerY + pointRadius * Math.sin(angle);

      ctx.beginPath();
      ctx.arc(x, y, 4, 0, Math.PI * 2);
      ctx.fillStyle = this.data[i].color || '#1890FF';
      ctx.fill();

      if (this.showValue && this.animationProgress > 0.9) {
        ctx.fillStyle = '#333333';
        ctx.font = 'bold 11px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(Math.round(value).toString(), x, y - 10);
      }
    }
  }

  calculateOverallRisk(): number {
    if (this.data.length === 0) return 0;
    let sum = 0;
    for (let i = 0; i < this.data.length; i++) {
      sum += this.data[i].value;
    }
    return sum / this.data.length;
  }

  getBorderColor(riskLevel: number): string {
    if (riskLevel >= 80) return '#CF1322';
    if (riskLevel >= 60) return '#FA8C16';
    if (riskLevel >= 40) return '#FADB14';
    return '#52C41A';
  }
}