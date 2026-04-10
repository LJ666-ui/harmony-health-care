import { router } from '@kit.ArkUI';

@Component
export struct Footer {
  @Prop activeIndex: number = 0;

  build() {
    Row() {
      Column() {
        Text('🏠')
          .fontSize(24)
          .fontColor(this.activeIndex === 0 ? '#1677FF' : '#999999')
        Text('首页')
          .fontSize(12)
          .fontColor(this.activeIndex === 0 ? '#1677FF' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/HomePage' });
      })

      Column() {
        Text('🏥')
          .fontSize(24)
          .fontColor(this.activeIndex === 1 ? '#1677FF' : '#999999')
        Text('就医')
          .fontSize(12)
          .fontColor(this.activeIndex === 1 ? '#1677FF' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/MedicalPage' });
      })

      Column() {
        Text('🧘')
          .fontSize(24)
          .fontColor(this.activeIndex === 2 ? '#1677FF' : '#999999')
        Text('康复')
          .fontSize(12)
          .fontColor(this.activeIndex === 2 ? '#1677FF' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/RehabPage' });
      })

      Column() {
        Text('📚')
          .fontSize(24)
          .fontColor(this.activeIndex === 3 ? '#1677FF' : '#999999')
        Text('科普')
          .fontSize(12)
          .fontColor(this.activeIndex === 3 ? '#1677FF' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/ScienceListPage' });
      })

      Column() {
        Text('👤')
          .fontSize(24)
          .fontColor(this.activeIndex === 4 ? '#1677FF' : '#999999')
        Text('我的')
          .fontSize(12)
          .fontColor(this.activeIndex === 4 ? '#1677FF' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/Profile' });
      })
    }
    .width('100%')
    .height(60)
    .backgroundColor('#FFFFFF')
    .padding({ left: 16, right: 16 })
  }
}
