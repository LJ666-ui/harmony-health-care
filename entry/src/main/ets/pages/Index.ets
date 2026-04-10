import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  build() {
    Column() {
      Column() {
        Text('星云医疗助手')
          .fontSize(32)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ bottom: 16 })

        Text('守护健康，从这里开始')
          .fontSize(18)
          .fontColor('#666666')
          .margin({ bottom: 48 })

        Button('去登录')
          .width('80%')
          .height(48)
          .fontSize(16)
          .fontWeight('medium')
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Login'
            });
          })
      }
      .flexGrow(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Footer({ activeIndex: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
