import { Finding, BoundingBox } from '../medical/ImageAnalysisService';

@Component
export struct AnnotationOverlay {
  @Prop imageWidth: number = 400;
  @Prop imageHeight: number = 300;
  @Prop findings: Finding[] = [];
  @Prop showConfidence: boolean = true;
  @Prop onSelectFinding?: (finding: Finding) => void;

  @State animationProgress: number = 0;
  @State pulseScale: number = 1.0;

  private animationTimerId: number | null = null;
  private pulseAnimationId: number | null = null;

  aboutToAppear(): void {
    this.startAnimations();
  }

  aboutToDisappear(): void {
    this.stopAnimations();
  }

  build() {
    if (this.findings.length === 0) {
      Column()
        .width(this.imageWidth)
        .height(this.imageHeight)
    } else {
      Canvas((context: CanvasRenderingContext2D) => {
        context.clearRect(0, 0, this.imageWidth, this.imageHeight);

        if (this.animationProgress > 0) {
          for (let i = 0; i < this.findings.length; i++) {
            const finding = this.findings[i];
            const delay = i * 150;
            const adjustedProgress = Math.max(0, Math.min(1, 
              (this.animationProgress * 1000 - delay) / 300
            ));

            if (adjustedProgress > 0) {
              this.drawFindingAnnotation(context, finding, adjustedProgress);
            }
          }
        }

        if (this.findings.length > 0 && this.pulseScale !== 1.0) {
          const primaryFinding = this.findings[0];
          
          if (primaryFinding.severity === 'HIGH') {
            this.drawPulsingEffect(context, primaryFinding);
          }
        }
      })
        .width(this.imageWidth)
        .height(this.imageHeight)
    }
  }

  private drawFindingAnnotation(
    context: CanvasRenderingContext2D,
    finding: Finding,
    progress: number
  ): void {
    const bbox = finding.bbox;
    const style = this.getAnnotationStyle(finding.severity);

    const scale = this.pulseScale;
    
    const centerX = bbox.x + bbox.width / 2;
    const centerY = bbox.y + bbox.height / 2;
    
    const scaledBbox: BoundingBox = {
      x: centerX - (bbox.width / 2) * scale,
      y: centerY - (bbox.height / 2) * scale,
      width: bbox.width * scale,
      height: bbox.height * scale
    };

    context.save();
    context.globalAlpha = progress;

    context.fillStyle = style.fillColor;
    context.fillRect(
      scaledBbox.x,
      scaledBbox.y,
      scaledBbox.width,
      scaledBbox.height
    );

    context.strokeStyle = style.strokeColor;
    context.lineWidth = style.lineWidth;
    context.strokeRect(
      scaledBbox.x,
      scaledBbox.y,
      scaledBbox.width,
      scaledBbox.height
    );

    this.drawLabel(context, finding, scaledBbox, style);

    context.restore();
  }

  private drawLabel(
    context: CanvasRenderingContext2D,
    finding: Finding,
    bbox: BoundingBox,
    style: { strokeColor: string; fillColor: string; lineWidth: number }
  ): void {
    let labelText = finding.label;
    
    if (this.showConfidence) {
      labelText += ` ${(finding.confidence * 100).toFixed(0)}%`;
    }

    context.font = 'bold 14px sans-serif';
    const textMetrics = context.measureText(labelText);
    const textWidth = textMetrics.width || (labelText.length * 8);
    const textHeight = 20;
    const paddingX = 8;
    const paddingY = 4;

    let labelX = bbox.x;
    let labelY = bbox.y - textHeight - paddingY * 2 - 6;

    if (labelY < 5) {
      labelY = bbox.y + bbox.height + 6;
    }

    if (labelX + textWidth + paddingX * 2 > this.imageWidth - 5) {
      labelX = this.imageWidth - textWidth - paddingX * 2 - 5;
    }

    if (labelX < 5) {
      labelX = 5;
    }

    context.fillStyle = '#FFFFFF';
    context.beginPath();
    context.roundRect(labelX, labelY, textWidth + paddingX * 2, textHeight + paddingY * 2, 4);
    context.fill();

    context.strokeStyle = style.strokeColor;
    context.lineWidth = 1.5;
    context.beginPath();
    context.roundRect(labelX, labelY, textWidth + paddingX * 2, textHeight + paddingY * 2, 4);
    context.stroke();

    context.fillStyle = '#333333';
    context.font = 'bold 13px sans-serif';
    context.textAlign = 'left';
    context.textBaseline = 'middle';
    context.fillText(
      labelText,
      labelX + paddingX,
      labelY + (textHeight + paddingY * 2) / 2
    );
  }

  private drawPulsingEffect(
    context: CanvasRenderingContext2D,
    finding: Finding
  ): void {
    const bbox = finding.bbox;
    
    const centerX = bbox.x + bbox.width / 2;
    const centerY = bbox.y + bbox.height / 2;
    const maxRadius = Math.max(bbox.width, bbox.height) / 2 * 1.3;

    const pulseRadius = maxRadius * (this.pulseScale - 1.0) * 10;

    if (pulseRadius > 5) {
      context.save();
      
      const gradient = context.createRadialGradient(
        centerX, centerY, 0,
        centerX, centerY, pulseRadius
      );
      gradient.addColorStop(0, 'rgba(255,77,79,0.15)');
      gradient.addColorStop(0.7, 'rgba(255,77,79,0.08)');
      gradient.addColorStop(1, 'rgba(255,77,79,0)');

      context.fillStyle = gradient;
      context.beginPath();
      context.arc(centerX, centerY, pulseRadius, 0, Math.PI * 2);
      context.fill();

      context.strokeStyle = 'rgba(255,77,79,0.3)';
      context.lineWidth = 2;
      context.setLineDash([5, 5]);
      context.beginPath();
      context.arc(centerX, centerY, pulseRadius, 0, Math.PI * 2);
      context.stroke();

      context.restore();
    }
  }

  private getAnnotationStyle(severity: Finding['severity']): {
    strokeColor: string;
    fillColor: string;
    lineWidth: number;
  } {
    switch (severity) {
      case 'HIGH':
        return {
          strokeColor: '#FF4D4F',
          fillColor: 'rgba(255,77,79,0.12)',
          lineWidth: 3
        };
      case 'MEDIUM':
        return {
          strokeColor: '#FAAD14',
          fillColor: 'rgba(250,173,20,0.10)',
          lineWidth: 2.5
        };
      case 'LOW':
        return {
          color: '#FFEC3D',
          fillColor: 'rgba(255,236,61,0.08)',
          lineWidth: 2
        };
      default:
        return {
          strokeColor: '#999999',
          fillColor: 'rgba(153,153,153,0.08)',
          lineWidth: 2
        };
    }
  }

  private startAnimations(): void {
    this.animationProgress = 0;
    this.pulseScale = 1.0;

    setTimeout(() => {
      const startTime = Date.now();
      const duration = 1000;

      const animate = () => {
        const elapsed = Date.now() - startTime;
        
        this.animationProgress = Math.min(1, elapsed / duration);

        if (this.animationProgress < 1) {
          this.animationTimerId = requestAnimationFrame(animate as FrameAnimationCallback);
        }
      };

      animate();
    }, 100);

    setTimeout(() => {
      const duration = 2000;
      let startTime: number;

      const pulseAnimate = () => {
        if (!startTime) startTime = Date.now();

        const elapsed = Date.now() - startTime;
        const cycle = (elapsed % duration) / duration;

        this.pulseScale = 1.0 + Math.sin(cycle * Math.PI * 2) * 0.02;

        this.pulseAnimationId = requestAnimationFrame(pulseAnimate as FrameAnimationCallback);
      };

      pulseAnimate();
    }, 1200);
  }

  private stopAnimations(): void {
    if (this.animationTimerId !== null) {
      cancelAnimationFrame(this.animationTimerId);
      this.animationTimerId = null;
    }

    if (this.pulseAnimationId !== null) {
      cancelAnimationFrame(this.pulseAnimationId);
      this.pulseAnimationId = null;
    }

    this.animationProgress = 1;
    this.pulseScale = 1.0;
  }
}
