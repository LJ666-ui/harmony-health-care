@Component
export struct TrendMiniChart {
  @Prop data: number[] = [];
  @Prop height: number = 50;
  @Prop color: string = '#1677FF';
  @Prop fillColor?: string;
  @Prop lineWidth: number = 2;
  @Prop showPoints: boolean = true;
  @Prop pointRadius: number = 3;
  @Prop animated: boolean = true;

  private animationProgress: number = 0;

  aboutToAppear(): void {
    if (this.animated) {
      this.animationProgress = 0;
      
      setTimeout(() => {
        this.animationProgress = 1;
      }, 100);
    } else {
      this.animationProgress = 1;
    }
  }

  build() {
    if (this.data.length < 2) {
      Text('数据不足')
        .fontSize(12)
        .fontColor('#999999')
        .height(this.height)
        .textAlign(TextAlign.Center)
    } else {
      Canvas((context: CanvasRenderingContext2D) => {
        const width = '100%';
        const chartHeight = this.height;
        
        context.clearRect(0, 0, width as number, chartHeight);
        
        const padding = { top: 5, right: 5, bottom: 5, left: 5 };
        const chartWidth = (width as number) - padding.left - padding.right;
        const drawHeight = chartHeight - padding.top - padding.bottom;

        const minValue = Math.min(...this.data);
        const maxValue = Math.max(...this.data);
        const range = maxValue - minValue || 1;

        const points: { x: number; y: number }[] = [];

        for (let i = 0; i < this.data.length; i++) {
          const x = padding.left + (i / (this.data.length - 1)) * chartWidth;
          const normalizedValue = (this.data[i] - minValue) / range;
          const y = padding.top + drawHeight * (1 - normalizedValue * this.animationProgress);

          points.push({ x, y });
        }

        if (this.fillColor && points.length > 1) {
          context.beginPath();
          context.moveTo(points[0].x, padding.top + drawHeight);

          for (const point of points) {
            context.lineTo(point.x, point.y);
          }

          context.lineTo(points[points.length - 1].x, padding.top + drawHeight);
          context.closePath();

          context.fillStyle = this.fillColor + '30';
          context.fill();
        }

        context.beginPath();
        context.moveTo(points[0].x, points[0].y);

        for (let i = 1; i < points.length; i++) {
          const xc = (points[i - 1].x + points[i].x) / 2;
          const yc = (points[i - 1].y + points[i].y) / 2;
          context.quadraticCurveTo(points[i - 1].x, points[i - 1].y, xc, yc);
        }

        context.lineTo(points[points.length - 1].x, points[points.length - 1].y);

        context.strokeStyle = this.color;
        context.lineWidth = this.lineWidth;
        context.lineCap = 'round';
        context.lineJoin = 'round';
        context.stroke();

        if (this.showPoints && points.length > 0) {
          for (const point of points) {
            context.beginPath();
            context.arc(point.x, point.y, this.pointRadius, 0, Math.PI * 2);
            context.fillStyle = this.color;
            context.fill();
            
            context.beginPath();
            context.arc(point.x, point.y, this.pointRadius - 1, 0, Math.PI * 2);
            context.fillStyle = '#FFFFFF';
            context.fill();
          }
        }

        if (points.length >= 2 && this.animationProgress === 1) {
          const lastPoint = points[points.length - 1];
          
          context.beginPath();
          context.arc(lastPoint.x, lastPoint.y, this.pointRadius + 2, 0, Math.PI * 2);
          context.fillStyle = this.color + '40';
          context.fill();

          context.beginPath();
          context.arc(lastPoint.x, lastPoint.y, this.pointRadius + 1, 0, Math.PI * 2);
          context.fillStyle = this.color;
          context.fill();
        }
      })
        .width('100%')
        .height(this.height)
    }
  }
}
