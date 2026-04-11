import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';

@Component
export struct Footer {
  @Prop activeIndex: number = 0;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Row() {
      Column() {
        Text('🏠')
          .fontSize(this.isElderMode ? 32 : 24)
          .fontColor(this.activeIndex === 0 ? GlobalTheme.THEME_COLOR : '#999999')
        Text('首页')
          .fontSize(this.isElderMode ? 16 : 12)
          .fontColor(this.activeIndex === 0 ? GlobalTheme.THEME_COLOR : '#999999')
          .margin({ top: this.isElderMode ? 6 : 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/HomePage' });
      })

      Column() {
        Text('🏥')
          .fontSize(this.isElderMode ? 32 : 24)
          .fontColor(this.activeIndex === 1 ? GlobalTheme.THEME_COLOR : '#999999')
        Text('就医')
          .fontSize(this.isElderMode ? 16 : 12)
          .fontColor(this.activeIndex === 1 ? GlobalTheme.THEME_COLOR : '#999999')
          .margin({ top: this.isElderMode ? 6 : 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/MedicalPage' });
      })

      Column() {
        Text('🧘')
          .fontSize(this.isElderMode ? 32 : 24)
          .fontColor(this.activeIndex === 2 ? GlobalTheme.THEME_COLOR : '#999999')
        Text('康复')
          .fontSize(this.isElderMode ? 16 : 12)
          .fontColor(this.activeIndex === 2 ? GlobalTheme.THEME_COLOR : '#999999')
          .margin({ top: this.isElderMode ? 6 : 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/RehabPage' });
      })

      Column() {
        Text('📚')
          .fontSize(this.isElderMode ? 32 : 24)
          .fontColor(this.activeIndex === 3 ? GlobalTheme.THEME_COLOR : '#999999')
        Text('科普')
          .fontSize(this.isElderMode ? 16 : 12)
          .fontColor(this.activeIndex === 3 ? GlobalTheme.THEME_COLOR : '#999999')
          .margin({ top: this.isElderMode ? 6 : 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/SciencePage' });
      })

      Column() {
        Text('👤')
          .fontSize(this.isElderMode ? 32 : 24)
          .fontColor(this.activeIndex === 4 ? GlobalTheme.THEME_COLOR : '#999999')
        Text('我的')
          .fontSize(this.isElderMode ? 16 : 12)
          .fontColor(this.activeIndex === 4 ? GlobalTheme.THEME_COLOR : '#999999')
          .margin({ top: this.isElderMode ? 6 : 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/Profile' });
      })
    }
    .width('100%')
    .height(this.isElderMode ? 75 : 60)
    .backgroundColor('#FFFFFF')
    .padding({ left: this.isElderMode ? 20 : 16, right: this.isElderMode ? 20 : 16 })
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetX: 0,
      offsetY: -2
    });
  }
}
