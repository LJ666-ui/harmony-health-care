import { RadarDataItem } from '../models/AIModels';

@Component
export struct RadarChart {
  @Prop data: RadarDataItem[] = [];
  @Prop sizeValue: number = 300;
  @Prop showValue: boolean = true;
  @Prop animated: boolean = true;
  @State @Watch('onProgressChange') animationProgress: number = 0;
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

  onProgressChange(): void {
    if (this.data.length > 0) {
      this.drawRadar();
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
      ctx.strokeStyle = '#D0D0D0';
      ctx.lineWidth = level === gridLevels ? 1.2 : 0.7;
      ctx.stroke();

      const levelNames: string[] = ['正常', '偏高', '中风险', '高风险', '极高'];
      if (level < gridLevels && sides > 0) {
        const labelAngle: number = startAngle + angleStep * 0.4;
        const lx: number = cx + r * Math.cos(labelAngle) + 3;
        const ly: number = cy + r * Math.sin(labelAngle) - 3;
        ctx.fillStyle = '#999999';
        ctx.font = '9px sans-serif';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'bottom';
        ctx.fillText(levelNames[level - 1], lx, ly);
      }
    }

    for (let i: number = 0; i < sides; i++) {
      const angle: number = startAngle + i * angleStep;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.lineTo(cx + maxRadius * Math.cos(angle), cy + maxRadius * Math.sin(angle));
      ctx.strokeStyle = '#CCCCCC';
      ctx.lineWidth = 0.8;
      ctx.stroke();
    }

    if (this.data.length > 0) {
      const overallColor: string = this.getOverallColor();
      ctx.beginPath();
      for (let i: number = 0; i <= sides; i++) {
        const idx: number = i % sides;
        const angle: number = startAngle + idx * angleStep;
        const pos: number = this.data[idx].getNormalizedPosition() * this.animationProgress;
        const r: number = maxRadius * Math.max(0.08, pos);
        const x: number = cx + r * Math.cos(angle);
        const y: number = cy + r * Math.sin(angle);
        if (i === 0) { ctx.moveTo(x, y); } else { ctx.lineTo(x, y); }
      }
      ctx.closePath();
      ctx.fillStyle = overallColor + '30';
      ctx.fill();
      ctx.strokeStyle = overallColor;
      ctx.lineWidth = 2;
      ctx.stroke();

      for (let i: number = 0; i < sides; i++) {
        const angle: number = startAngle + i * angleStep;
        const pos: number = this.data[i].getNormalizedPosition() * this.animationProgress;
        const r: number = maxRadius * Math.max(0.08, pos);
        const x: number = cx + r * Math.cos(angle);
        const y: number = cy + r * Math.sin(angle);

        ctx.beginPath();
        ctx.arc(x, y, 4.5, 0, 2 * Math.PI);
        ctx.fillStyle = this.data[i].color;
        ctx.fill();
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 1.5;
        ctx.stroke();

        if (this.showValue) {
          ctx.fillStyle = '#444444';
          ctx.font = 'bold 11px sans-serif';
          ctx.textAlign = 'center';
          ctx.textBaseline = 'bottom';
          const av: number = this.data[i].actualValue;
          const valText: string = (av > 0 ? av.toFixed(1).replace(/\.0$/, '') : this.data[i].value.toFixed(2)) +
            (this.data[i].unit !== '' ? this.data[i].unit : '');
          ctx.fillText(valText, x, y - 6);
        }
      }
    }

    for (let i: number = 0; i < sides; i++) {
      const angle: number = startAngle + i * angleStep;
      const tipX: number = cx + maxRadius * Math.cos(angle);
      const tipY: number = cy + maxRadius * Math.sin(angle);
      let offsetX: number = 0;
      let offsetY: number = 0;
      const margin: number = 12;

      if (Math.abs(Math.cos(angle)) > 0.85) {
        offsetY = Math.sin(angle) > 0 ? margin : -(margin + 16);
      } else if (Math.abs(Math.sin(angle)) > 0.85) {
        offsetX = Math.cos(angle) > 0 ? margin : -(margin + 40);
      } else {
        offsetX = Math.cos(angle) * margin;
        offsetY = Math.sin(angle) * margin;
      }

      ctx.fillStyle = '#333333';
      ctx.font = 'bold 13px sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(this.data[i].label, tipX + offsetX, tipY + offsetY);
    }
  }

  private getOverallColor(): string {
    if (this.data.length === 0) { return '#52C41A'; }
    let maxPos: number = 0;
    for (let i: number = 0; i < this.data.length; i++) {
      const pos: number = this.data[i].getNormalizedPosition();
      if (pos > maxPos) { maxPos = pos; }
    }
    if (maxPos >= 0.75) { return '#FF4D4F'; }
    if (maxPos >= 0.45) { return '#FAAD14'; }
    return '#52C41A';
  }
}
