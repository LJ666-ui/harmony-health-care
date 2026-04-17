interface ChartData {
  type: string;
  count: number;
  color: string;
}

@Component
struct StatPieChart {
  @Prop data: ChartData[] = [];
  @Prop sizeValue: number = 200;
  @State animationProgress: number = 0;

  aboutToAppear() {
    this.animateProgress();
  }

  animateProgress(): void {
    let progress = 0;
    const interval = setInterval(() => {
      progress += 0.05;
      if (progress >= 1) {
        progress = 1;
        clearInterval(interval);
      }
      this.animationProgress = progress;
    }, 50);
  }

  calculateTotal(): number {
    return this.data.reduce((total, item) => total + item.count, 0);
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 使用简单的圆环图实现
        ForEach(this.data, (item: ChartData, index: number) => {
          Column()
            .width(this.sizeValue * 0.8)
            .height(this.sizeValue * 0.8)
            .borderRadius(this.sizeValue * 0.4)
            .backgroundColor(item.color)
            .clip(true)
            .opacity(this.animationProgress);
        });
        
        // 中心白色圆形
        Column()
          .width(this.sizeValue * 0.5)
          .height(this.sizeValue * 0.5)
          .borderRadius(this.sizeValue * 0.25)
          .backgroundColor('#ffffff');
        
        // 中心文字
        Text(this.calculateTotal().toString())
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#333333');
      }
      .width(this.sizeValue)
      .height(this.sizeValue);
      
      if (this.data.length > 0) {
        Column() {
          ForEach(this.data, (item: ChartData) => {
            Row({
              space: 8
            }) {
              Column()
                .width(12)
                .height(12)
                .backgroundColor(item.color);
              Text(`${item.type}: ${item.count}`)
                .fontSize(14)
                .fontColor('#666666');
            }
            .margin({ bottom: 8 });
          });
        }
        .margin({ top: 16 });
      }
    }
  }
}

export { StatPieChart };
