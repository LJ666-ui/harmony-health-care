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

interface SimpleRect {
  left: number;
  top: number;
}

@Component
export struct HumanBodyModel {
  @Prop viewType: BodyViewType = BodyViewType.FRONT;
  @Prop organs: OrganData[] = [];
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedOrganId: string = '';
  @State scaleFactor: number = 1.0;
  @State rotationX: number = 0;
  @State rotationY: number = 0;
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));

  private canvasWidth: number = 280;
  private canvasHeight: number = 500;

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

  drawHumanBody(ctx: CanvasRenderingContext2D): void {
    const centerX: number = this.canvasWidth / 2;
    const baseY: number = 60;

    ctx.save();
    ctx.translate(centerX, baseY);
    ctx.scale(this.scaleFactor, this.scaleFactor);

    ctx.strokeStyle = '#E8E8E8';
    ctx.lineWidth = 2;
    ctx.fillStyle = '#F0F5FF';

    if (this.viewType === BodyViewType.FRONT || this.viewType === BodyViewType.BACK) {
      this.drawFrontView(ctx);
    } else {
      this.drawSideView(ctx);
    }

    this.drawOrgans(ctx);

    ctx.restore();
  }

  drawFrontView(ctx: CanvasRenderingContext2D): void {
    const headRadius: number = 35;

    ctx.beginPath();
    ctx.arc(0, headRadius, headRadius, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    const neckTop: number = headRadius * 2 + 5;
    const neckBottom: number = neckTop + 20;
    const shoulderWidth: number = 80;
    const torsoHeight: number = 140;

    ctx.beginPath();
    ctx.moveTo(-15, neckTop);
    ctx.lineTo(-15, neckBottom);
    ctx.lineTo(-shoulderWidth / 2, neckBottom + 10);
    ctx.lineTo(-shoulderWidth / 2, neckBottom + torsoHeight);
    ctx.lineTo(shoulderWidth / 2, neckBottom + torsoHeight);
    ctx.lineTo(shoulderWidth / 2, neckBottom + 10);
    ctx.lineTo(15, neckBottom);
    ctx.lineTo(15, neckTop);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    const armWidth: number = 18;
    const armLength: number = 100;
    const handSize: number = 12;

    for (let side of [-1, 1]) {
      const startX: number = side * (shoulderWidth / 2);

      ctx.beginPath();
      ctx.moveTo(startX, neckBottom + 10);
      ctx.quadraticCurveTo(
        side * (shoulderWidth / 2 + 25),
        neckBottom + 40,
        side * (shoulderWidth / 2 + 30),
        neckBottom + armLength
      );
      ctx.lineTo(side * (shoulderWidth / 2 + 30) + side * handSize, neckBottom + armLength + handSize);
      ctx.arc(side * (shoulderWidth / 2 + 30), neckBottom + armLength + handSize, handSize, 0, Math.PI * 2);
      ctx.fill();
      ctx.stroke();
    }

    const hipWidth: number = 70;
    const legWidth: number = 22;
    const legLength: number = 130;
    const footSize: number = 18;
    const torsoBottom: number = neckBottom + torsoHeight;

    ctx.beginPath();
    ctx.moveTo(-shoulderWidth / 2, torsoBottom);
    ctx.lineTo(-hipWidth / 2, torsoBottom + 35);
    ctx.lineTo(hipWidth / 2, torsoBottom + 35);
    ctx.lineTo(shoulderWidth / 2, torsoBottom);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    for (let side of [-1, 1]) {
      const hipX: number = side * (hipWidth / 2);

      ctx.beginPath();
      ctx.moveTo(hipX, torsoBottom + 35);
      ctx.lineTo(hipX, torsoBottom + 35 + legLength);
      ctx.lineTo(hipX + side * footSize / 2, torsoBottom + 35 + legLength + footSize);
      ctx.lineTo(hipX - side * footSize / 2, torsoBottom + 35 + legLength + footSize);
      ctx.closePath();
      ctx.fill();
      ctx.stroke();
    }
  }

  drawSideView(ctx: CanvasRenderingContext2D): void {
    const headRadius: number = 32;

    ctx.beginPath();
    ctx.arc(headRadius, headRadius, headRadius, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    const neckTop: number = headRadius * 2 + 3;
    const neckBottom: number = neckTop + 18;
    const chestDepth: number = 45;
    const torsoHeight: number = 135;

    ctx.beginPath();
    ctx.moveTo(8, neckTop);
    ctx.lineTo(8, neckBottom);
    ctx.lineTo(chestDepth, neckBottom + torsoHeight * 0.6);
    ctx.lineTo(chestDepth - 10, neckBottom + torsoHeight);
    ctx.lineTo(5, neckBottom + torsoHeight);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    const armStartX: number = chestDepth + 5;
    const armLength: number = 95;

    ctx.beginPath();
    ctx.moveTo(chestDepth, neckBottom + 20);
    ctx.quadraticCurveTo(armStartX, neckBottom + 50, armStartX, neckBottom + armLength);
    ctx.lineTo(armStartX + 10, neckBottom + armLength + 12);
    ctx.arc(armStartX, neckBottom + armLength + 12, 10, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();

    const legLength: number = 125;
    const torsoBottom: number = neckBottom + torsoHeight;

    ctx.beginPath();
    ctx.moveTo(chestDepth - 10, torsoBottom);
    ctx.lineTo(chestDepth - 5, torsoBottom + legLength);
    ctx.lineTo(chestDepth + 8, torsoBottom + legLength + 16);
    ctx.lineTo(chestDepth - 18, torsoBottom + legLength + 16);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
  }

  drawOrgans(ctx: CanvasRenderingContext2D): void {
    for (let i = 0; i < this.organs.length; i++) {
      const organ: OrganData = this.organs[i];
      const color: string = this.getHealthColor(organ.healthStatus);
      const isSelected: boolean = organ.id === this.selectedOrganId;

      ctx.save();

      if (isSelected) {
        ctx.shadowColor = color;
        ctx.shadowBlur = 15;
        ctx.lineWidth = 3;
        ctx.strokeStyle = '#1677FF';
      }

      ctx.fillStyle = color;
      ctx.globalAlpha = isSelected ? 1 : 0.85;

      ctx.beginPath();
      ctx.arc(organ.x, organ.y, organ.radius, 0, Math.PI * 2);
      ctx.fill();
      if (isSelected) {
        ctx.stroke();
      }

      ctx.globalAlpha = 1;
      ctx.fillStyle = '#FFFFFF';
      ctx.font = `${this.isElderMode ? 11 : 9}px sans-serif`;
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';

      const displayName: string = organ.name.length > 3 ? organ.name.substring(0, 2) : organ.name;
      ctx.fillText(displayName, organ.x, organ.y);

      ctx.restore();
    }
  }

  handleCanvasClick(event: TouchEvent): void {
    const touch: TouchObject = event.touches[0];
    let rectLeft: number = 0;
    let rectTop: number = 0;

    const canvasX: number = touch.x - rectLeft;
    const canvasY: number = touch.y - rectTop;

    const centerX: number = this.canvasWidth / 2;
    const baseY: number = 60;

    const adjustedX: number = (canvasX - centerX) / this.scaleFactor;
    const adjustedY: number = (canvasY - baseY) / this.scaleFactor;

    let foundOrgan: OrganData | null = null;

    for (let i = 0; i < this.organs.length; i++) {
      const organ: OrganData = this.organs[i];
      const distance: number = Math.sqrt(
        Math.pow(adjustedX - organ.x, 2) + Math.pow(adjustedY - organ.y, 2)
      );

      if (distance <= organ.radius + 5) {
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
        Canvas(this.canvasContext)
          .width(this.canvasWidth)
          .height(this.canvasHeight)
          .backgroundColor('#FAFBFC')
          .borderRadius(12)
          .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
          .onReady(() => {
            this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
            this.drawHumanBody(this.canvasContext);
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.handleCanvasClick(event);
              this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
              this.drawHumanBody(this.canvasContext);
            }
          })

        Row({ space: 12 }) {
          Button('+')
            .width(36)
            .height(36)
            .fontSize(18)
            .backgroundColor('#FFFFFF')
            .fontColor(GlobalTheme.THEME_COLOR)
            .borderRadius(18)
            .onClick(() => {
              this.scaleFactor = Math.min(this.scaleFactor + 0.1, 1.5);
            })

          Button('-')
            .width(36)
            .height(36)
            .fontSize(18)
            .backgroundColor('#FFFFFF')
            .fontColor(GlobalTheme.THEME_COLOR)
            .borderRadius(18)
            .onClick(() => {
              this.scaleFactor = Math.max(this.scaleFactor - 0.1, 0.6);
            })
        }
        .position({ x: 10, y: 10 })
      }
      .width(this.canvasWidth)

      Row({ space: 8 }) {
        ForEach([BodyViewType.FRONT, BodyViewType.BACK, BodyViewType.LEFT, BodyViewType.RIGHT], (type: BodyViewType) => {
          Button(type === BodyViewType.FRONT ? '正面' : type === BodyViewType.BACK ? '背面' : type === BodyViewType.LEFT ? '左侧' : '右侧')
            .fontSize(12)
            .height(28)
            .padding({ left: 10, right: 10 })
            .backgroundColor(this.viewType === type ? GlobalTheme.THEME_COLOR : '#F5F5F5')
            .fontColor(this.viewType === type ? '#FFFFFF' : GlobalTheme.TEXT_SECONDARY)
            .borderRadius(14)
            .onClick(() => {
              this.selectedOrganId = '';
            })
        }, (type: BodyViewType) => type)
      }
      .margin({ top: 12 })
    }
    .alignItems(HorizontalAlign.Center)
  }
}
