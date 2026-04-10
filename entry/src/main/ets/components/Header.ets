import { router } from '@kit.ArkUI';

@Component
export struct Header {
  @Prop title: string = '';
  @Prop showBack: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Text('←')
          .fontSize(24)
          .fontColor('#1677FF')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          });
      } else {
        Blank().width(40);
      }
      
      Text(this.title)
        .fontSize(18)
        .fontWeight('bold')
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);
      
      Blank().width(40);
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center);
  }
}
