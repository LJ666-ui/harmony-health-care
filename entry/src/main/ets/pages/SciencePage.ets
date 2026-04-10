import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';

@Entry
@Component
struct SciencePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  build(): void {
    Column() {
      Text('健康科普')
        .width('100%')
        .height(56)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .backgroundColor('#FFFFFF')
        .textAlign(TextAlign.Center)

      Column() {
        Text('健康知识')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1677FF')

        Text('了解健康知识，守护家人健康')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 8 })

        Text('科普文章')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 24 })
          .width('100%')
          .height(80)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .textAlign(TextAlign.Center)
          .padding({ top: 28 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ScienceListPage' });
          })
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .padding({ top: 32 })

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
