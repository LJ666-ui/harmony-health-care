import { router } from '@kit.ArkUI';

interface Position {
  x: string;
  y: string;
}

@Entry
@Component
struct WatchHomePage {
  @State currentTime: string = '';
  @State rotationAngle: number = 0;
  @State selectedIndex: number = 0;
  private rotateTimer: number = -1;
  private buttonPositions: Position[] = [
    { x: '50%', y: '10%' },
    { x: '79%', y: '23%' },
    { x: '79%', y: '77%' },
    { x: '50%', y: '90%' },
    { x: '21%', y: '77%' },
    { x: '21%', y: '23%' },
    { x: '10%', y: '50%' },
    { x: '90%', y: '50%' }
  ];

  aboutToAppear(): void {
    this.updateTime();
    setInterval(() => { this.updateTime(); }, 1000);
    this.startRotation();
  }

  aboutToDisappear(): void {
    if (this.rotateTimer !== -1) { clearInterval(this.rotateTimer); this.rotateTimer = -1; }
  }

  startRotation(): void {
    this.rotateTimer = setInterval(() => { this.rotationAngle = (this.rotationAngle + 0.08) % 360; }, 40);
  }

  updateTime(): void {
    const now = new Date();
    const h = now.getHours().toString().padStart(2, '0');
    const m = now.getMinutes().toString().padStart(2, '0');
    this.currentTime = `${h}.${m}`;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width('96%')
        .height('96%')
        .fill('#1a1f2e')
        .stroke('#FFFFFF')
        .strokeWidth(3)

      Column() {
        Text(this.currentTime).fontSize(42).fontWeight(FontWeight.Bold).fontColor('#E8EAED').letterSpacing(2)
        Text(this.getDateString()).fontSize(12).fontColor('#9AA0A6').margin({ top: 4 })
      }

      Stack() {
        this.buildBtn('🤖', 'AI问诊', '#5B7FFF', 0, () => { router.pushUrl({ url: 'pages/WatchAIConsultPage' }) })
        this.buildBtn('🩺', '健康监测', '#3498DB', 1, () => { router.pushUrl({ url: 'pages/WatchHealthMonitorPage' }) })
        this.buildBtn('💚', '睡眠监测', '#2ECC71', 2, () => { router.pushUrl({ url: 'pages/WatchSleepPage' }) })
        this.buildBtn('🆘', 'SOS紧急', '#E74C3C', 3, () => { router.pushUrl({ url: 'pages/WatchEmergencyPage' }) })
        this.buildBtn('💊', '用药提醒', '#F59E0B', 4, () => { router.pushUrl({ url: 'pages/WatchMedicationPage' }) })
        this.buildBtn('📡', '紧急呼叫', '#16A085', 5, () => { router.pushUrl({ url: 'pages/WatchEmergencyPage' }) })
        this.buildBtn('🏃', '运动记录', '#06B6D4', 6, () => { router.pushUrl({ url: 'pages/WatchSportPage' }) })
        this.buildBtn('😴', '睡眠分析', '#A855F7', 7, () => { router.pushUrl({ url: 'pages/WatchSleepPage' }) })
      }
      .rotate({ angle: this.rotationAngle })
      .width('88%').height('88%')
    }
    .width('100%').height('100%')
    .backgroundColor('#12151f')
  }

  @Builder buildBtn(icon: string, label: string, color: string, index: number, action: () => void) {
    Stack() {
      Circle()
        .width(this.selectedIndex === index ? 50 : 46)
        .height(this.selectedIndex === index ? 50 : 46)
        .fill(undefined)
        .stroke('#FCD34D')
        .strokeWidth(2)
      
      Column() {
        Text(icon).fontSize(this.selectedIndex === index ? 16 : 14)
        Text(label).fontSize(6).fontColor('#FFFFFF').fontWeight(FontWeight.Bold).margin({ top: 1 }).maxLines(1)
      }
      .width(this.selectedIndex === index ? 44 : 40)
      .height(this.selectedIndex === index ? 44 : 40)
      .borderRadius(this.selectedIndex === index ? 22 : 20)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(color)
    }
    .position({ x: this.buttonPositions[index].x, y: this.buttonPositions[index].y })
    .markAnchor({ x: '50%', y: '50%' })
    .onClick(() => {
      this.selectedIndex = index;
      action();
    })
  }

  getDateString(): string {
    const now = new Date();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return `${now.getMonth() + 1}月 ${weekDays[now.getDay()]}`;
  }
}
