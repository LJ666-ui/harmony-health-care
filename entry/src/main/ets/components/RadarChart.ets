import { RadarDataItem } from '../models/AIModels';

@Component
export struct RadarChart {
  @Prop data: RadarDataItem[] = [];
  @Prop sizeValue: number = 300;
  @Prop showValue: boolean = true;
  @Prop animated: boolean = true;
  @State animationProgress: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private animationTimer: number = -1;

  aboutToAppear(): void {
    if (this.animated) {
      this.startAnimation();
    } else {
      this.animationProgress = 1;
    }
  }

  aboutToDisappear(): void {
    this.clearAnimationTimer();
  }

  private clearAnimationTimer(): void {
    if (this.animationTimer !== -1) {
      try {
        clearInterval(this.animationTimer);
      } catch (e) {
      }
      this.animationTimer = -1;
    }
  }

  private startAnimation(): void {
    let progress: number = 0;
    this.animationTimer = setInterval(() => {
      progress += 0.04;
      if (progress >= 1) {
        progress = 1;
        this.clearAnimationTimer();
      }
      this.animationProgress = this.easeOutCubic(progress);
    }, 25);
  }

  private easeOutCubic(t: number): number {
    return 1 - Math.pow(1 - t, 3);
  }

  private getOverallColor(): string {
    if (this.data.length === 0) {
      return '#52C41A';
    }
    let maxVal: number = 0;
    for (let i: number = 0; i < this.data.length; i++) {
      if (this.data[i].value > maxVal) {
        maxVal = this.data[i].value;
      }
    }
    if (maxVal >= 0.6) {
      return '#FF4D4F';
    }
    if (maxVal >= 0.3) {
      return '#FAAD14';
    }
    return '#52C41A';
  }

  build() {
    Column() {
      Canvas(this.context)
        .width(this.sizeValue)
        .height(this.sizeValue)
        .onReady(() => {
          this.drawRadar();
        });
    }
  }

  private drawRadar(): void {
    const ctx: CanvasRenderingContext2D = this.context;
    const cx: number = this.sizeValue / 2;
    const cy: number = this.sizeValue / 2;
    const maxRadius: number = this.sizeValue * 0.38;
    const sides: number = this.data.length > 0 ? this.data.length : 5;
    const angleStep: number = (2 * Math.PI) / sides;
    const startAngle: number = -Math.PI / 2;
    const gridLevels: number = 5;

    ctx.clearRect(0, 0, this.sizeValue, this.sizeValue);

    for (let level: number = 1; level <= gridLevels; level++) {
      const r: number = maxRadius * (level / gridLevels);
      ctx.beginPath();
      for (let i: number = 0; i <= sides; i++) {
        const angle: number = startAngle + i * angleStep;
        const x: number = cx + r * Math.cos(angle);
        const y: number = cy + r * Math.sin(angle);
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.closePath();
      ctx.strokeStyle = '#E8E8E8';
      ctx.lineWidth = 1;
      ctx.stroke();
    }

    for (let i: number = 0; i < sides; i++) {
      const angle: number = startAngle + i * angleStep;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.lineTo(cx + maxRadius * Math.cos(angle), cy + maxRadius * Math.sin(angle));
      ctx.strokeStyle = '#E0E0E0';
      ctx.lineWidth = 1;
      ctx.stroke();
    }

    if (this.data.length > 0) {
      const overallColor: string = this.getOverallColor();
      ctx.beginPath();
      for (let i: number = 0; i <= sides; i++) {
        const idx: number = i % sides;
        const angle: number = startAngle + idx * angleStep;
        const value: number = this.data[idx].value * this.animationProgress;
        const r: number = maxRadius * Math.max(0.05, value);
        const x: number = cx + r * Math.cos(angle);
        const y: number = cy + r * Math.sin(angle);
        if (i === 0) {
          ctx.moveTo(x, y);
        } else {
          ctx.lineTo(x, y);
        }
      }
      ctx.closePath();
      ctx.fillStyle = overallColor + '30';
      ctx.fill();
      ctx.strokeStyle = overallColor + 'CC';
      ctx.lineWidth = 2.5;
      ctx.stroke();

      for (let i: number = 0; i < sides; i++) {
        const angle: number = startAngle + i * angleStep;
        const value: number = this.data[i].value * this.animationProgress;
        const r: number = maxRadius * Math.max(0.05, value);
        const x: number = cx + r * Math.cos(angle);
        const y: number = cy + r * Math.sin(angle);

        ctx.beginPath();
        ctx.arc(x, y, 5, 0, 2 * Math.PI);
        ctx.fillStyle = this.data[i].color;
        ctx.fill();
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.stroke();
      }
    }

    for (let i: number = 0; i < sides; i++) {
      const angle: number = startAngle + i * angleStep;
      const labelR: number = maxRadius + 28;
      const lx: number = cx + labelR * Math.cos(angle);
      const ly: number = cy + labelR * Math.sin(angle);

      ctx.fillStyle = '#333333';
      ctx.font = '13px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(this.data[i].label, lx, ly - 8);

      if (this.showValue) {
        const percent: number = Math.round(this.data[i].value * 100);
        ctx.fillStyle = this.data[i].color;
        ctx.font = 'bold 12px sans-serif';
        ctx.fillText(percent + '%', lx, ly + 8);
      }
    }

    const gridLabels: string[] = ['20%', '40%', '60%', '80%', '100%'];
    for (let level: number = 1; level <= gridLevels; level++) {
      const r: number = maxRadius * (level / gridLevels);
      const labelAngle: number = startAngle + 0.15;
      const lx: number = cx + r * Math.cos(labelAngle) + 4;
      const ly: number = cy + r * Math.sin(labelAngle) - 4;
      ctx.fillStyle = '#BBBBBB';
      ctx.font = '9px sans-serif';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'bottom';
      ctx.fillText(gridLabels[level - 1], lx, ly);
    }
  }
}
