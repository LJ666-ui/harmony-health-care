import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';

@Component
export struct Header {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Text('←')
          .fontSize(this.isElderMode ? 28 : 24)
          .fontColor(GlobalTheme.THEME_COLOR)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor(GlobalTheme.THEME_COLOR + '15')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          });
      } else {
        Blank().width(40);
      }

      Text(this.title)
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight('bold')
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);

      Blank().width(40);
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.Center)
    .shadow({
      radius: 2,
      color: '#00000008',
      offsetX: 0,
      offsetY: 1
    });
  }
}
