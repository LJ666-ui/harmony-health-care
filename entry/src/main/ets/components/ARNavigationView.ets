import { ParkingConstants, NavigationEngine } from '../parking/ParkingConstants';

interface SimulatedARProps {
  navigationData: {
    distanceRemaining: number;
    bearing: number;
    instruction: string;
    isArrived: boolean;
  };
  isNavigating: boolean;
  onStopNavigation?: () => void;
}

@Component
export struct ARNavigationView {
  @Prop navigationData: SimulatedARProps['navigationData'] = {
    distanceRemaining: 100,
    bearing: 0,
    instruction: '向前直行',
    isArrived: false
  };
  @Prop isNavigating: boolean = false;
  private onStopNavigationCallback?: () => void;

  aboutToAppear(): void {
    console.log('[ARNavigationView] 组件初始化完成（无摄像头版本）');
  }

  buildArrowPath(ctx: CanvasRenderingContext2D, centerX: number, centerY: number, size: number): void {
    const arrowSize = size * 0.4;
    
    ctx.beginPath();
    ctx.moveTo(centerX, centerY - arrowSize);
    ctx.lineTo(centerX + arrowSize * 0.7, centerY);
    ctx.lineTo(centerX + arrowSize * 0.3, centerY);
    ctx.lineTo(centerX + arrowSize * 0.3, centerY + arrowSize);
    ctx.lineTo(centerX - arrowSize * 0.3, centerY + arrowSize);
    ctx.lineTo(centerX - arrowSize * 0.3, centerY);
    ctx.lineTo(centerX - arrowSize * 0.7, centerY);
    ctx.closePath();
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            ['#1a1a2e', 0],
            ['#16213e', 0.5],
            ['#0f3460', 1]
          ],
          repeating: false
        })

      if (this.navigationData.isArrived) {
        this.buildArrivedView()
      } else {
        this.buildNavigationView()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder buildNavigationView() {
    Column({ space: 20 }) {
      Text(this.navigationData.instruction)
        .fontSize(20)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .margin({ top: 40 })

      Canvas((context: CanvasRenderingContext2D) => {
        const width = 250;
        const height = 250;
        const centerX = width / 2;
        const centerY = height / 2;

        context.clearRect(0, 0, width, height);

        context.save();
        context.translate(centerX, centerY);
        context.rotate((this.navigationData.bearing * Math.PI) / 180);
        context.translate(-centerX, -centerY);

        context.shadowColor = 'rgba(22, 119, 255, 0.8)';
        context.shadowBlur = 15;
        context.shadowOffsetX = 0;
        context.shadowOffsetY = 0;

        context.fillStyle = '#FFFFFF';
        context.strokeStyle = '#1677FF';
        context.lineWidth = 4;

        this.buildArrowPath(context, centerX, centerY, 150);

        context.fill();
        context.stroke();

        context.restore();

        context.fillStyle = 'rgba(255, 255, 255, 0.9)';
        context.font = 'bold 16px sans-serif';
        context.textAlign = 'center';
        context.textBaseline = 'middle';
        
        const distanceText = Math.round(this.navigationData.distanceRemaining) + '米';
        context.fillText(distanceText, centerX, centerY + 180);
      })
        .width(250)
        .height(250)

      Text('距离车位还有 ' + Math.round(this.navigationData.distanceRemaining) + ' 米')
        .fontSize(18)
        .fontColor('#FFFFFF')

      Text('方位：' + this.getBearingDescription(this.navigationData.bearing))
        .fontSize(14)
        .fontColor('rgba(255, 255, 255, 0.7)')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildArrivedView() {
    Column({ space: 30 }) {
      Text('✅')
        .fontSize(80)
      
      Text('您已到达停车位')
        .fontSize(24)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
      
      Button('结束导航')
        .width(200)
        .height(45)
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .onClick(() => {
          if (this.onStopNavigationCallback) {
            this.onStopNavigationCallback();
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  getBearingDescription(bearing: number): string {
    if (bearing >= 337.5 || bearing < 22.5) {
      return '正北方向';
    } else if (bearing >= 22.5 && bearing < 67.5) {
      return '东北方向';
    } else if (bearing >= 67.5 && bearing < 112.5) {
      return '正东方向';
    } else if (bearing >= 112.5 && bearing < 157.5) {
      return '东南方向';
    } else if (bearing >= 157.5 && bearing < 202.5) {
      return '正南方向';
    } else if (bearing >= 202.5 && bearing < 247.5) {
      return '西南方向';
    } else if (bearing >= 247.5 && bearing < 292.5) {
      return '正西方向';
    } else {
      return '西北方向';
    }
  }
}
