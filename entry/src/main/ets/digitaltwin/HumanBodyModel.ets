import { GlobalTheme } from '../global';

export enum BodyViewType {
  FRONT = 'front',
  BACK = 'back',
  LEFT = 'left',
  RIGHT = 'right'
}

export interface OrganData {
  id: string;
  name: string;
  nameEn: string;
  x: number;
  y: number;
  radius: number;
  healthStatus: 'healthy' | 'sub_healthy' | 'high_risk' | 'diseased';
  healthScore: number;
  description: string;
}

@Component
export struct HumanBodyModel {
  @Prop viewType: BodyViewType = BodyViewType.FRONT;
  @Prop organs: OrganData[] = [];
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedOrganId: string = '';
  @State scaleFactor: number = 1.0;
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  private canvasWidth: number = 300;
  private canvasHeight: number = 560;

  getHealthColor(status: string): string {
    switch (status) {
      case 'healthy':
        return '#52C41A';
      case 'sub_healthy':
        return '#FAAD14';
      case 'high_risk':
        return '#FF7A45';
      case 'diseased':
        return '#FF4D4F';
      default:
        return '#999999';
    }
  }

  getHealthColorRGBA(status: string, alpha: number): string {
    const hex: string = this.getHealthColor(status);
    const r: number = parseInt(hex.substring(1, 3), 16);
    const g: number = parseInt(hex.substring(3, 5), 16);
    const b: number = parseInt(hex.substring(5, 7), 16);
    return `rgba(${r},${g},${b},${alpha})`;
  }

  draw3DBody(ctx: CanvasRenderingContext2D): void {
    const cx: number = this.canvasWidth / 2;

    ctx.save();
    ctx.translate(cx, 30);
    ctx.scale(this.scaleFactor, this.scaleFactor);

    if (this.viewType === BodyViewType.FRONT || this.viewType === BodyViewType.BACK) {
      this.draw3DFrontBody(ctx);
    } else {
      this.draw3DSideBody(ctx);
    }

    this.draw3DOrgans(ctx);

    ctx.restore();
  }

  draw3DFrontBody(ctx: CanvasRenderingContext2D): void {
    const headR: number = 38;
    const neckH: number = 22;
    const shoulderW: number = 85;
    const chestW: number = 78;
    const waistW: number = 62;
    const hipW: number = 75;
    const torsoH: number = 155;
    const legW: number = 24;
    const legH: number = 140;
    const armW: number = 20;
    const armL: number = 105;
    const handR: number = 13;
    const footW: number = 20;
    const footH: number = 22;

    ctx.lineJoin = 'round';

    const headGrad: CanvasGradient = ctx.createRadialGradient(-8, -8, headR * 0.2, 0, 0, headR);
    headGrad.addColorStop(0, '#FFF8F0');
    headGrad.addColorStop(0.4, '#FFE8D6');
    headGrad.addColorStop(0.8, '#F5D5B8');
    headGrad.addColorStop(1, '#E8C4A0');

    ctx.beginPath();
    ctx.ellipse(0, headR + 5, headR, headR + 4, 0, 0, Math.PI * 2);
    ctx.fillStyle = headGrad;
    ctx.fill();

    ctx.strokeStyle = '#D4A882';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    ctx.beginPath();
    ctx.ellipse(-headR * 0.35, headR - 5, 5, 7, -0.15, 0, Math.PI * 2);
    ctx.fillStyle = '#E8C4A0';
    ctx.fill();
    ctx.beginPath();
    ctx.ellipse(headR * 0.35, headR - 5, 5, 7, 0.15, 0, Math.PI * 2);
    ctx.fill();

    const neckTopY: number = headR * 2 + 8;
    const neckBotY: number = neckTopY + neckH;

    const neckGrad: CanvasGradient = ctx.createLinearGradient(-12, neckTopY, 12, neckBotY);
    neckGrad.addColorStop(0, '#F0DCC8');
    neckGrad.addColorStop(1, '#E0BC9E');
    ctx.beginPath();
    ctx.moveTo(-13, neckTopY);
    ctx.lineTo(-11, neckBotY);
    ctx.lineTo(11, neckBotY);
    ctx.lineTo(13, neckTopY);
    ctx.closePath();
    ctx.fillStyle = neckGrad;
    ctx.fill();
    ctx.strokeStyle = '#D4A882';
    ctx.lineWidth = 1;
    ctx.stroke();

    const torsoTop: number = neckBotY;
    const shoulderY: number = torsoTop + 18;
    const chestMidY: number = torsoTop + torsoH * 0.35;
    const waistY: number = torsoTop + torsoH * 0.65;
    const torsoBottom: number = torsoTop + torsoH;
    const hipBottom: number = torsoBottom + 32;

    const bodyGrad: CanvasGradient = ctx.createLinearGradient(-chestW / 2, torsoTop, chestW / 2, torsoBottom);
    bodyGrad.addColorStop(0, '#E8EEF8');
    bodyGrad.addColorStop(0.15, '#DDE8F5');
    bodyGrad.addColorStop(0.35, '#D0DEF0');
    bodyGrad.addColorStop(0.55, '#C8DCEC');
    bodyGrad.addColorStop(0.75, '#D0DEF0');
    bodyGrad.addColorStop(1, '#D8E8F2');

    ctx.beginPath();
    ctx.moveTo(-13, torsoTop);
    ctx.quadraticCurveTo(-shoulderW / 2 - 5, shoulderY - 5, -shoulderW / 2, shoulderY);
    ctx.lineTo(-chestW / 2, chestMidY);
    ctx.lineTo(-waistW / 2, waistY);
    ctx.lineTo(-hipW / 2, torsoBottom);
    ctx.quadraticCurveTo(-hipW / 2 - 3, hipBottom, -legW / 2 - 2, hipBottom);
    ctx.lineTo(legW / 2 + 2, hipBottom);
    ctx.quadraticCurveTo(hipW / 2 + 3, hipBottom, hipW / 2, torsoBottom);
    ctx.lineTo(waistW / 2, waistY);
    ctx.lineTo(chestW / 2, chestMidY);
    ctx.lineTo(shoulderW / 2, shoulderY);
    ctx.quadraticCurveTo(shoulderW / 2 + 5, shoulderY - 5, 13, torsoTop);
    ctx.closePath();
    ctx.fillStyle = bodyGrad;
    ctx.fill();

    ctx.strokeStyle = '#B8C8DA';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    const highlightGrad: CanvasGradient = ctx.createLinearGradient(-10, torsoTop, 25, torsoBottom);
    highlightGrad.addColorStop(0, 'rgba(255,255,255,0.35)');
    highlightGrad.addColorStop(0.3, 'rgba(255,255,255,0.15)');
    highlightGrad.addColorStop(0.6, 'rgba(255,255,255,0.05)');
    highlightGrad.addColorStop(1, 'rgba(255,255,255,0)');

    ctx.beginPath();
    ctx.moveTo(-shoulderW / 2 + 8, shoulderY + 5);
    ctx.quadraticCurveTo(-chestW / 2 + 5, chestMidY, -waistW / 2 + 4, waistY);
    ctx.lineTo(-waistW / 2 + 8, torsoBottom - 5);
    ctx.lineTo(-waistW / 2 + 2, torsoBottom - 5);
    ctx.lineTo(-waistW / 2 + 2, waistY);
    ctx.quadraticCurveTo(-chestW / 2 + 2, chestMidY, -shoulderW / 2 + 4, shoulderY + 5);
    ctx.closePath();
    ctx.fillStyle = highlightGrad;
    ctx.fill();

    for (let side of [-1, 1]) {
      const sx: number = side * (shoulderW / 2);
      const armOuterX: number = side * (shoulderW / 2 + 28);
      const elbowX: number = side * (shoulderW / 2 + 22);
      const handX: number = side * (shoulderW / 2 + 26);

      const armGrad: CanvasGradient = ctx.createLinearGradient(sx, shoulderY, armOuterX, shoulderY + armL);
      armGrad.addColorStop(0, '#D8E8F2');
      armGrad.addColorStop(0.4, '#CEDDEC');
      armGrad.addColorStop(0.8, '#C4D4E6');
      armGrad.addColorStop(1, '#BBCCE0');

      ctx.beginPath();
      ctx.moveTo(sx - side * 8, shoulderY + 3);
      ctx.quadraticCurveTo(armOuterX - side * 5, shoulderY + armL * 0.35, elbowX - side * 3, shoulderY + armL * 0.6);
      ctx.quadraticCurveTo(handX - side * 2, shoulderY + armL * 0.85, handX, shoulderY + armL);
      ctx.lineTo(handX + side * handR, shoulderY + armL + handR);
      ctx.arc(handX, shoulderY + armL + handR, handR, side > 0 ? Math.PI : 0, side > 0 ? 0 : Math.PI);
      ctx.lineTo(handX - side * 2, shoulderY + armL);
      ctx.quadraticCurveTo(handX - side * 6, shoulderY + armL * 0.8, elbowX + side * 5, shoulderY + armL * 0.55);
      ctx.quadraticCurveTo(armOuterX + side * 2, shoulderY + armL * 0.3, sx + side * 6, shoulderY + 3);
      ctx.closePath();
      ctx.fillStyle = armGrad;
      ctx.fill();
      ctx.strokeStyle = '#B8C8DA';
      ctx.lineWidth = 1.2;
      ctx.stroke();
    }

    for (let side of [-1, 1]) {
      const hx: number = side * (hipW / 2);
      const kneeX: number = side * (legW / 2 + 4);
      const ankleX: number = side * (legW / 2 + 2);

      const legGrad: CanvasGradient = ctx.createLinearGradient(hx - side * 8, hipBottom, hx + side * 8, hipBottom + legH);
      legGrad.addColorStop(0, '#D0DEF0');
      legGrad.addColorStop(0.3, '#C8D8EC');
      legGrad.addColorStop(0.7, '#C0D0E8');
      legGrad.addColorStop(1, '#B8CAE0');

      ctx.beginPath();
      ctx.moveTo(hx - side * (legW / 2), hipBottom);
      ctx.lineTo(kneeX - side * (legW / 2 - 2), hipBottom + legH * 0.52);
      ctx.lineTo(ankleX - side * (footW / 2 - 2), hipBottom + legH);
      ctx.lineTo(ankleX + side * (footW / 2 - 2), hipBottom + legH);
      ctx.lineTo(kneeX + side * (legW / 2 - 2), hipBottom + legH * 0.52);
      ctx.lineTo(hx + side * (legW / 2), hipBottom);
      ctx.closePath();
      ctx.fillStyle = legGrad;
      ctx.fill();
      ctx.strokeStyle = '#B8C8DA';
      ctx.lineWidth = 1.2;
      ctx.stroke();

      const footGrad: CanvasGradient = ctx.createLinearGradient(
        ankleX - side * footW / 2, hipBottom + legH,
        ankleX + side * footW / 2, hipBottom + legH + footH
      );
      footGrad.addColorStop(0, '#C8D8EC');
      footGrad.addColorStop(1, '#B0C4DC');

      ctx.beginPath();
      ctx.moveTo(ankleX - side * (footW / 2 - 3), hipBottom + legH);
      ctx.quadraticCurveTo(ankleX - side * footW / 2, hipBottom + legH + footH * 0.4,
        ankleX - side * (footW / 2 - 5), hipBottom + legH + footH);
      ctx.lineTo(ankleX + side * (footW / 2 - 5), hipBottom + legH + footH);
      ctx.quadraticCurveTo(ankleX + side * footW / 2, hipBottom + legH + footH * 0.4,
        ankleX + side * (footW / 2 - 3), hipBottom + legH);
      ctx.closePath();
      ctx.fillStyle = footGrad;
      ctx.fill();
      ctx.stroke();
    }
  }

  draw3DSideBody(ctx: CanvasRenderingContext2D): void {
    const headR: number = 36;
    const neckH: number = 20;
    const chestDepth: number = 48;
    const torsoH: number = 145;
    const armL: number = 100;
    const handR: number = 12;
    const legH: number = 130;
    const footLen: number = 24;

    const headGrad: CanvasGradient = ctx.createRadialGradient(headR - 8, -5, headR * 0.2, headR, headR, headR);
    headGrad.addColorStop(0, '#FFF8F0');
    headGrad.addColorStop(0.5, '#FFE8D6');
    headGrad.addColorStop(1, '#E0B898');

    ctx.beginPath();
    ctx.arc(headR, headR + 3, headR, 0, Math.PI * 2);
    ctx.fillStyle = headGrad;
    ctx.fill();
    ctx.strokeStyle = '#C4A082';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    const neckTop: number = headR * 2 + 5;
    const neckBot: number = neckTop + neckH;
    const torsoTop: number = neckBot;

    const bodyGrad: CanvasGradient = ctx.createLinearGradient(5, torsoTop, chestDepth, torsoTop + torsoH);
    bodyGrad.addColorStop(0, '#E0EBF5');
    bodyGrad.addColorStop(0.3, '#D4E2F0');
    bodyGrad.addColorStop(0.6, '#CAD8EC');
    bodyGrad.addColorStop(1, '#C0CEE4');

    ctx.beginPath();
    ctx.moveTo(8, torsoTop);
    ctx.lineTo(8, neckBot);
    ctx.quadraticCurveTo(chestDepth - 5, torsoTop + torsoH * 0.25, chestDepth, torsoTop + torsoH * 0.55);
    ctx.lineTo(chestDepth - 8, torsoTop + torsoH);
    ctx.lineTo(5, torsoTop + torsoH);
    ctx.closePath();
    ctx.fillStyle = bodyGrad;
    ctx.fill();
    ctx.strokeStyle = '#A8BCCC';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    const armStartX: number = chestDepth + 3;
    const armEndX: number = chestDepth + 18;

    const armGrad: CanvasGradient = ctx.createLinearGradient(chestDepth, torsoTop + 25, armEndX, torsoTop + 25 + armL);
    armGrad.addColorStop(0, '#D0DEF0');
    armGrad.addColorStop(0.5, '#C4D4E6');
    armGrad.addColorStop(1, '#B8CAE0');

    ctx.beginPath();
    ctx.moveTo(chestDepth - 3, torsoTop + 25);
    ctx.quadraticCurveTo(armStartX, torsoTop + 50, armEndX - 3, torsoTop + 25 + armL);
    ctx.arc(armEndX, torsoTop + 25 + armL + handR, handR, 0, Math.PI * 2);
    ctx.lineTo(armEndX - 5, torsoTop + 25 + armL);
    ctx.quadraticCurveTo(armStartX - 5, torsoTop + 55, chestDepth - 8, torsoTop + 30);
    ctx.closePath();
    ctx.fillStyle = armGrad;
    ctx.fill();
    ctx.strokeStyle = '#A8BCCC';
    ctx.lineWidth = 1.2;
    ctx.stroke();

    const legGrad: CanvasGradient = ctx.createLinearGradient(chestDepth - 10, torsoTop + torsoH, chestDepth - 2, torsoTop + torsoH + legH);
    legGrad.addColorStop(0, '#C8D8EC');
    legGrad.addColorStop(0.5, '#BCCEED');
    legGrad.addColorStop(1, '#B0C2DC');

    ctx.beginPath();
    ctx.moveTo(chestDepth - 10, torsoTop + torsoH);
    ctx.lineTo(chestDepth - 5, torsoTop + torsoH + legH);
    ctx.lineTo(chestDepth + footLen, torsoTop + torsoH + legH + 8);
    ctx.lineTo(chestDepth + footLen - 6, torsoTop + torsoH + legH + 6);
    ctx.lineTo(chestDepth - 10, torsoTop + torsoH + legH);
    ctx.closePath();
    ctx.fillStyle = legGrad;
    ctx.fill();
    ctx.strokeStyle = '#A8BCCC';
    ctx.lineWidth = 1.2;
    ctx.stroke();
  }

  draw3DOrgans(ctx: CanvasRenderingContext2D): void {
    for (let i = 0; i < this.organs.length; i++) {
      const organ: OrganData = this.organs[i];
      const color: string = this.getHealthColor(organ.healthStatus);
      const isSelected: boolean = organ.id === this.selectedOrganId;

      ctx.save();

      if (isSelected) {
        ctx.shadowColor = color;
        ctx.shadowBlur = 20;
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = 0;
      }

      const glowRadius: number = organ.radius + (isSelected ? 8 : 4);
      const glowGrad: CanvasGradient = ctx.createRadialGradient(
        organ.x, organ.y, organ.radius * 0.3,
        organ.x, organ.y, glowRadius
      );
      glowGrad.addColorStop(0, this.getHealthColorRGBA(organ.healthStatus, 0.5));
      glowGrad.addColorStop(0.5, this.getHealthColorRGBA(organ.healthStatus, 0.2));
      glowGrad.addColorStop(1, this.getHealthColorRGBA(organ.healthStatus, 0));

      ctx.beginPath();
      ctx.arc(organ.x, organ.y, glowRadius, 0, Math.PI * 2);
      ctx.fillStyle = glowGrad;
      ctx.fill();

      const mainGrad: CanvasGradient = ctx.createRadialGradient(
        organ.x - organ.radius * 0.3, organ.y - organ.radius * 0.3, organ.radius * 0.1,
        organ.x, organ.y, organ.radius
      );
      mainGrad.addColorStop(0, '#FFFFFF');
      mainGrad.addColorStop(0.2, this.lightenColor(color, 40));
      mainGrad.addColorStop(0.6, color);
      mainGrad.addColorStop(1, this.darkenColor(color, 20));

      ctx.beginPath();
      ctx.arc(organ.x, organ.y, organ.radius, 0, Math.PI * 2);
      ctx.fillStyle = mainGrad;
      ctx.fill();

      if (isSelected) {
        ctx.strokeStyle = '#1677FF';
        ctx.lineWidth = 2.5;
        ctx.setLineDash([]);
        ctx.stroke();

        ctx.beginPath();
        ctx.arc(organ.x, organ.y, organ.radius + 5, 0, Math.PI * 2);
        ctx.strokeStyle = 'rgba(22,119,255,0.3)';
        ctx.lineWidth = 1.5;
        ctx.setLineDash([4, 3]);
        ctx.stroke();
        ctx.setLineDash([]);
      } else {
        ctx.strokeStyle = this.darkenColor(color, 30);
        ctx.lineWidth = 1;
        ctx.globalAlpha = 0.5;
        ctx.stroke();
        ctx.globalAlpha = 1;
      }

      ctx.globalAlpha = 0.95;
      ctx.fillStyle = '#FFFFFF';
      ctx.font = `bold ${this.isElderMode ? 11 : 9}px sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';

      const displayName: string = organ.name.length > 3 ? organ.name.substring(0, 2) : organ.name;
      ctx.fillText(displayName, organ.x, organ.y);

      if (organ.healthScore !== undefined && !isSelected) {
        ctx.font = `${this.isElderMode ? 10 : 8}px sans-serif`;
        ctx.fillStyle = color;
        ctx.fillText(`${organ.healthScore}`, organ.x, organ.y + organ.radius + 10);
      }

      ctx.restore();
    }
  }

  lightenColor(hex: string, amount: number): string {
    let r: number = parseInt(hex.substring(1, 3), 16);
    let g: number = parseInt(hex.substring(3, 5), 16);
    let b: number = parseInt(hex.substring(5, 7), 16);
    r = Math.min(255, r + amount);
    g = Math.min(255, g + amount);
    b = Math.min(255, b + amount);
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
  }

  darkenColor(hex: string, amount: number): string {
    let r: number = parseInt(hex.substring(1, 3), 16);
    let g: number = parseInt(hex.substring(3, 5), 16);
    let b: number = parseInt(hex.substring(5, 7), 16);
    r = Math.max(0, r - amount);
    g = Math.max(0, g - amount);
    b = Math.max(0, b - amount);
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
  }

  handleCanvasClick(event: TouchEvent): void {
    const touch: TouchObject = event.touches[0];
    const canvasX: number = touch.x;
    const canvasY: number = touch.y;

    const centerX: number = this.canvasWidth / 2;
    const baseY: number = 30;

    const adjustedX: number = (canvasX - centerX) / this.scaleFactor;
    const adjustedY: number = (canvasY - baseY) / this.scaleFactor;

    let foundOrgan: OrganData | null = null;

    for (let i = 0; i < this.organs.length; i++) {
      const organ: OrganData = this.organs[i];
      const distance: number = Math.sqrt(
        Math.pow(adjustedX - organ.x, 2) + Math.pow(adjustedY - organ.y, 2)
      );

      if (distance <= organ.radius + 6) {
        foundOrgan = organ;
        break;
      }
    }

    if (foundOrgan) {
      this.selectedOrganId = foundOrgan.id;
    } else {
      this.selectedOrganId = '';
    }
  }

  build() {
    Column() {
      Text('人体模型')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Medium)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .margin({ bottom: 12 })

      Stack({ alignContent: Alignment.Center }) {
        Column() {
          Canvas(this.canvasContext)
            .width(this.canvasWidth)
            .height(this.canvasHeight)
            .backgroundColor('#FAFBFD')
            .borderRadius(16)
            .border({ width: 1, color: '#E8EDF3' })
            .shadow({
              radius: 16,
              color: 'rgba(100,130,180,0.08)',
              offsetX: 0,
              offsetY: 4
            })
            .onReady(() => {
              this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
              this.draw3DBody(this.canvasContext);
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.handleCanvasClick(event);
                this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
                this.draw3DBody(this.canvasContext);
              }
            })
        }
        .clip(true)
        .borderRadius(16)

        Row({ space: 8 }) {
          Button('+')
            .width(34)
            .height(34)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FFFFFF')
            .fontColor(GlobalTheme.THEME_COLOR)
            .borderRadius(17)
            .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              this.scaleFactor = Math.min(this.scaleFactor + 0.12, 1.6);
            })

          Button('-')
            .width(34)
            .height(34)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FFFFFF')
            .fontColor(GlobalTheme.THEME_COLOR)
            .borderRadius(17)
            .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              this.scaleFactor = Math.max(this.scaleFactor - 0.12, 0.55);
            })

          Button('↺')
            .width(34)
            .height(34)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FFFFFF')
            .fontColor(GlobalTheme.THEME_COLOR)
            .borderRadius(17)
            .shadow({ radius: 6, color: 'rgba(0,0,0,0.06)', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              this.selectedOrganId = '';
              this.scaleFactor = 1.0;
            })
        }
        .position({ x: 8, y: 8 })
      }
      .width(this.canvasWidth)

      Row({ space: 8 }) {
        ForEach([BodyViewType.FRONT, BodyViewType.BACK, BodyViewType.LEFT, BodyViewType.RIGHT], (type: BodyViewType) => {
          Button(type === BodyViewType.FRONT ? '正面' : type === BodyViewType.BACK ? '背面' : type === BodyViewType.LEFT ? '左侧' : '右侧')
            .fontSize(12)
            .height(28)
            .padding({ left: 10, right: 10 })
            .backgroundColor(this.viewType === type ? GlobalTheme.THEME_COLOR : '#F5F7FA')
            .fontColor(this.viewType === type ? '#FFFFFF' : GlobalTheme.TEXT_SECONDARY)
            .borderRadius(14)
            .onClick(() => {
              this.selectedOrganId = '';
            })
        }, (type: BodyViewType) => type)
      }
      .margin({ top: 12 })

      if (this.selectedOrganId !== '') {
        Row({ space: 6 }) {
          Text('📍')
            .fontSize(14)

          ForEach(this.organs, (organ: OrganData) => {
            if (organ.id === this.selectedOrganId) {
              Text(`${organ.name} · 健康评分 ${organ.healthScore}`)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getHealthColor(organ.healthStatus))
            }
          }, (organ: OrganData) => organ.id)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8, left: 14, right: 14 })
        .backgroundColor(this.getHealthColorRGBA(
          this.organs.find((o: OrganData) => o.id === this.selectedOrganId)?.healthStatus || 'healthy', 0.08
        ))
        .borderRadius(20)
        .margin({ top: 8 })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }
}
