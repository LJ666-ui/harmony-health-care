interface ParkingTimerProps {
  startTime: number;  // 停车开始时间戳
  hourlyRate: number;  // 每小时费率（元）
  freeMinutes?: number;  // 免费时长（分钟）
  dailyCap?: number;  // 每日封顶费用（元）
  onTimeUpdate?: (time: string, fee: number) => void;  // 时间更新回调
}

@Component
export struct ParkingTimer {
  @Prop startTime: number = Date.now();
  @Prop hourlyRate: number = 5;
  @Prop freeMinutes: number = 60;
  @Prop dailyCap: number = 50;
  @State elapsedTime: number = 0;
  @State displayTime: string = '00:00:00';
  @State currentFee: number = 0;
  private timerId: number | null = null;
  private onTimeUpdateCallback?: (time: string, fee: number) => void;

  aboutToAppear(): void {
    this.startTimer();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  startTimer(): void {
    this.updateTime();
    this.timerId = setInterval(() => {
      this.updateTime();
    }, 1000);
  }

  stopTimer(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
  }

  updateTime(): void {
    const now = Date.now();
    this.elapsedTime = Math.max(0, now - this.startTime);
    
    this.displayTime = this.formatTime(this.elapsedTime);
    this.currentFee = this.calculateFee(this.elapsedTime);
    
    if (this.onTimeUpdateCallback) {
      this.onTimeUpdateCallback(this.displayTime, this.currentFee);
    }
  }

  formatTime(milliseconds: number): string {
    const totalSeconds = Math.floor(milliseconds / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    
    return `${this.padZero(hours)}:${this.padZero(minutes)}:${this.padZero(seconds)}`;
  }

  padZero(num: number): string {
    return num < 10 ? `0${num}` : `${num}`;
  }

  calculateFee(milliseconds: number): number {
    const totalMinutes = milliseconds / (1000 * 60);
    const chargeableMinutes = Math.max(0, totalMinutes - this.freeMinutes);
    
    if (chargeableMinutes <= 0) {
      return 0;
    }
    
    const hours = chargeableMinutes / 60;
    const fee = hours * this.hourlyRate;
    
    const days = Math.ceil(hours / 24);
    const cappedFee = Math.min(fee, days * this.dailyCap);
    
    return Math.round(cappedFee * 100) / 100;
  }

  build() {
    Column() {
      Row({ space: 20 }) {
        Column({
          space: 4
        }) {
          Text('停车时长')
            .fontSize(14)
            .fontColor('#666666')
          Text(this.displayTime)
            .fontSize(24)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
        }
        
        Divider()
          .width(1)
          .height(60)
          .backgroundColor('#E8E8E8')
        
        Column({
          space: 4
        }) {
          Text('预计费用')
            .fontSize(14)
            .fontColor('#666666')
          Text(`¥${this.currentFee.toFixed(2)}`)
            .fontSize(24)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('100%')
      .padding({ horizontal: 20, vertical: 15 })
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }
}
