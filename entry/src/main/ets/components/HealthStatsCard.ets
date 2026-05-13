@Component
export struct HealthStatsCard {
  @Prop healthRecordCount: number = 0;
  @Prop collectCount: number = 0;
  @Prop browseHistoryCount: number = 0;

  build() {
    Row() {
      Column() {
        Text((this.healthRecordCount ?? 0).toString())
          .fontSize(22)
          .fontColor('#1677FF')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 4 });

        Text('健康记录')
          .fontSize(11)
          .fontColor('#999999');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center);

      Line()
        .width(1)
        .height(32)
        .stroke('#EEEEEE');

      Column() {
        Text((this.collectCount ?? 0).toString())
          .fontSize(22)
          .fontColor('#52C41A')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 4 });

        Text('收藏文章')
          .fontSize(11)
          .fontColor('#999999');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center);

      Line()
        .width(1)
        .height(32)
        .stroke('#EEEEEE');

      Column() {
        Text((this.browseHistoryCount ?? 0).toString())
          .fontSize(22)
          .fontColor('#FAAD14')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 4 });

        Text('浏览历史')
          .fontSize(11)
          .fontColor('#999999');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center);
    }
    .width('85%')
    .height(80)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#00000006',
      offsetX: 0,
      offsetY: 3
    });
  }
}