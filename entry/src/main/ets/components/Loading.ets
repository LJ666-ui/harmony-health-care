@Component
export struct Loading {
  @Prop text: string = '加载中...';
  @Prop show: boolean = true;

  build() {
    if (this.show) {
      Column({ space: 16 }) {
        Progress({
          value: 0,
          total: 100,
          type: ProgressType.Ring
        })
          .width(48)
          .height(48)
          .color('#1677FF')
          .backgroundColor('#F0F0F0')
          .style({ strokeWidth: 4 });

        Text(this.text)
          .fontSize(14)
          .fontColor('#999999');
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    } else {
      Column();
    }
  }
}
