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
      try { clearInterval(this.animationTimer); } catch (e) {}
      this.animationTimer = -1;
    }
  }

  private startAnimation(): void {
    let progress: number = 0;
    this.animationTimer = setInterval(() => {
      progress += 0.04;
      if (progress >= 1) { progress = 1; this.clearAnimationTimer(); }
      this.animationProgress = this.easeOutCubic(progress);
    }, 25);
  }

  private easeOutCubic(t: number): number {
    return 1 - Math.pow(1 - t, 3);
  }

  build() {
    Column() {
      Canvas(this.context)
        .width(this.sizeValue)
        .height(this.sizeValue)
        .onReady(() => { this.drawRadar(); });
    }
  }

  private drawRadar(): void {
    const ctx: CanvasRenderingContext2D = this.context;
    const cx: number = this.sizeValue / 2;
    const cy: number = this.sizeValue / 2;
    const maxRadius: number = this.sizeValue * 0.36;
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
        if (i === 0) { ctx.moveTo(x, y); } else { ctx.lineTo(x, y); }
      }
      ctx.closePath();
      if (level <= 2) {
        ctx.fillStyle = '#F6FFED22';
        ctx.fill();
      } else if (level === 3) {
        ctx.fillStyle = '#FFFBE615';
        ctx.fill();
      } else if (level >= 4) {
        ctx.fillStyle = '#FFF1F010';
        ctx.fill();
      }
      ctx.strokeStyle = level === gridLevels ? '#CCCCCC' : '#E8E8E8';
      ctx.lineWidth = level === gridLevels ? 1.5 : 0.8;
      ctx.stroke();
    }

    for (let i: number = 0; i < sides; i++) {
      const angle: number = startAngle + i * angleStep;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.lineTo(cx + maxRadius * Math.cos(angle), cy + maxRadius * Math.sin(angle));
      ctx.strokeStyle = '#EEEEEE';
      ctx.lineWidth = 0.8;
      ctx.setLineDash([4, 4]);
      ctx.stroke();
      ctx.setLineDash([]);
    }

    if (this.data.length > 0) {
      const overallColor: string = this.getOverallColor();
      ctx.beginPath();
      for (let i: number = 0; i <= sides; i++) {
        const idx: number = i % sides;
        const angle: number = startAngle + idx * angleStep;
        const value: number = this.data[idx].value * this.animationProgress;
        const r: number = maxRadius * Math.max(0.06, value);
        const x: number = cx + r * Math.cos(angle);
        const y: number = cy + r * Math.sin(angle);
        if (i === 0) { ctx.moveTo(x, y); } else { ctx.lineTo(x, y); }
      }
      ctx.closePath();
      ctx.fillStyle = overallColor + '28';
      ctx.fill();
      ctx.strokeStyle = overallColor;
      ctx.lineWidth = 2.5;
      ctx.stroke();

      for (let i: number = 0; i < sides; i++) {
        const angle: number = startAngle + i * angleStep;
        const value: number = this.data[i].value * this.animationProgress;
        const r: number = maxRadius * Math.max(0.06, value);
        const x: number = cx + r * Math.cos(angle);
        const y: number = cy + r * Math.sin(angle);
        const itemColor: string = this.data[i].color;

        ctx.beginPath();
        ctx.arc(x, y, 7, 0, 2 * Math.PI);
        ctx.fillStyle = itemColor;
        ctx.fill();
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2.5;
        ctx.stroke();

        ctx.beginPath();
        ctx.arc(x, y, 10, 0, 2 * Math.PI);
        ctx.strokeStyle = itemColor + '40';
        ctx.lineWidth = 1;
        ctx.stroke();
      }

      const avgVal: number = this.getAverageValue() * this.animationProgress;
      const centerR: number = maxRadius * Math.max(0.04, avgVal);
      ctx.beginPath();
      ctx.arc(cx, cy, centerR, 0, 2 * Math.PI);
      const centerGradient: CanvasGradient = ctx.createRadialGradient(cx, cy, 0, cx, cy, centerR);
      centerGradient.addColorStop(0, overallColor + '60');
      centerGradient.addColorStop(1, overallColor + '08');
      ctx.fillStyle = centerGradient;
      ctx.fill();
    }

    for (let i: number = 0; i < sides; i++) {
      const angle: number = startAngle + i * angleStep;
      const labelR: number = maxRadius + 32;
      const lx: number = cx + labelR * Math.cos(angle);
      const ly: number = cy + labelR * Math.sin(angle);

      const textW: number = ctx.measureText(this.data[i].label).width;
      const bgPadding: number = 5;
      ctx.fillStyle = '#FFFFFFEE';
      ctx.beginPath();
      ctx.roundRect(lx - textW / 2 - bgPadding, ly - 18, textW + bgPadding * 2, 18, 4);
      ctx.fill();
      ctx.strokeStyle = '#EEEEEE';
      ctx.lineWidth = 0.8;
      ctx.stroke();

      ctx.fillStyle = '#333333';
      ctx.font = 'bold 13px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(this.data[i].label, lx, ly - 9);

      if (this.showValue) {
        const percent: number = Math.round(this.data[i].value * 100 * this.animationProgress);
        const valStr: string = percent.toString() + '%';
        const valColor: string = this.data[i].color;

        const valTextW: number = ctx.measureText(valStr).width;
        ctx.fillStyle = valColor + '12';
        ctx.beginPath();
        ctx.roundRect(lx - valTextW / 2 - 4, ly + 1, valTextW + 8, 18, 9);
        ctx.fill();

        ctx.fillStyle = valColor;
        ctx.font = 'bold 13px sans-serif';
        ctx.fillText(valStr, lx, ly + 11);
      }
    }

    const gridLabels: string[] = ['20%', '40%', '60%', '80%', '100%'];
    for (let level: number = 1; level <= gridLevels; level++) {
      const r: number = maxRadius * (level / gridLevels);
      const labelAngle: number = startAngle + 0.18;
      const lx: number = cx + r * Math.cos(labelAngle) + 4;
      const ly: number = cy + r * Math.sin(labelAngle) - 3;
      ctx.fillStyle = '#AAAAAA';
      ctx.font = '9px sans-serif';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'bottom';
      ctx.fillText(gridLabels[level - 1], lx, ly);
    }
  }

  private getOverallColor(): string {
    if (this.data.length === 0) { return '#52C41A'; }
    let maxVal: number = 0;
    for (let i: number = 0; i < this.data.length; i++) {
      if (this.data[i].value > maxVal) { maxVal = this.data[i].value; }
    }
    if (maxVal >= 0.6) { return '#FF4D4F'; }
    if (maxVal >= 0.3) { return '#FAAD14'; }
    return '#52C41A';
  }

  private getAverageValue(): number {
    if (this.data.length === 0) { return 0; }
    let sum: number = 0;
    for (let i: number = 0; i < this.data.length; i++) { sum += this.data[i].value; }
    return sum / this.data.length;
  }
}
