@Component
export struct Card {
  @Prop title: string = '';
  @Prop value: string = '';
  @Prop description: string = '';
  @Prop status: string = '';

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(16)
          .fontWeight('bold')
          .fontColor('#333333');
        Blank().layoutWeight(1);
        Text(this.status)
          .fontSize(14)
          .fontColor('#1677FF');
      }
      .margin({ bottom: 8 });
      
      Text(this.value)
        .fontSize(20)
        .fontWeight('bold')
        .fontColor('#333333')
        .margin({ bottom: 4 });
      
      Text(this.description)
        .fontSize(14)
        .fontColor('#666666');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 12 })
    .border({ width: 1, color: '#f0f0f0' });
  }
}

@Component
export struct IconCard {
  @Prop icon: string = '';
  @Prop iconColor: string = '';
  @Prop iconBackgroundColor: string = '';
  @Prop title: string = '';
  @Prop description: string = '';

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.icon)
            .fontSize(32)
            .fontColor(this.iconColor);
        }
        .width(64)
        .height(64)
        .backgroundColor(this.iconBackgroundColor)
        .borderRadius(32)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: 16 });

        Column() {
          Text(this.title)
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ bottom: 4 });
          Text(this.description)
            .fontSize(14)
            .fontColor('#666666');
        }
        .layoutWeight(1);
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: '#f0f0f0' });
  }
}
