@Component
export struct EmptyState {
  @Prop icon: string = '📭';
  @Prop title: string = '暂无数据';
  @Prop description: string = '点击下方按钮添加内容';
  @Prop buttonText: string = '添加';
  @Prop onAdd: () => void = () => {};

  build() {
    Column({ space: 20 }) {
      Text(this.icon)
        .fontSize(64)
        .margin({ top: 40, bottom: 12 });

      Text(this.title)
        .fontSize(18)
        .fontWeight('bold')
        .fontColor('#333333');

      Text(this.description)
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .width('80%');

      Button(this.buttonText)
        .height(44)
        .padding({ left: 28, right: 28 })
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .margin({ top: 8 })
        .onClick(() => this.onAdd());
    }
    .width('100%')
    .height(350)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
