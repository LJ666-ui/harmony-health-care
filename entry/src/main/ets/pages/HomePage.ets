import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

@Entry
@Component
struct HomePage {
  @State clickedCard: number = -1;

  build() {
    Column() {
      Header({ title: '首页', showBack: true })

      Column({ space: 20 }) {
        Text('首页')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ bottom: 16 });

        Text('欢迎使用星云医疗助手')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 32 });

        Row() {
          Column() {
            Text('📋')
              .fontSize(32)
              .fontColor('#1677FF');
          }
          .width(64)
          .height(64)
          .backgroundColor(this.clickedCard === 0 ? '#1677FF' : '#1677FF20')
          .borderRadius(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('健康记录')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 4 });
            Text(this.clickedCard === 0 ? '>>> 点击已触发！<<<' : '查看和管理您的健康数据')
              .fontSize(14)
              .fontColor(this.clickedCard === 0 ? '#1677FF' : '#666666');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 });
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.clickedCard === 0 ? '#E6F4FF' : '#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: this.clickedCard === 0 ? '#1677FF' : '#f0f0f0' })
        .onClick(() => {
          this.clickedCard = 0;
          try {
            router.pushUrl({ url: 'pages/HealthRecords' });
          } catch (e) {
            console.error('路由跳转失败:', e);
          }
        })

        Row() {
          Column() {
            Text('📅')
              .fontSize(32)
              .fontColor('#1677FF');
          }
          .width(64)
          .height(64)
          .backgroundColor(this.clickedCard === 1 ? '#1677FF' : '#1677FF20')
          .borderRadius(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('预约管理')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 4 });
            Text(this.clickedCard === 1 ? '>>> 点击已触发！<<<' : '管理您的医疗预约')
              .fontSize(14)
              .fontColor(this.clickedCard === 1 ? '#1677FF' : '#666666');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 });
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.clickedCard === 1 ? '#E6F4FF' : '#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: this.clickedCard === 1 ? '#1677FF' : '#f0f0f0' })
        .onClick(() => {
          this.clickedCard = 1;
          try {
            router.pushUrl({ url: 'pages/Appointments' });
          } catch (e) {
            console.error('路由跳转失败:', e);
          }
        })

        Row() {
          Column() {
            Text('💊')
              .fontSize(32)
              .fontColor('#1677FF');
          }
          .width(64)
          .height(64)
          .backgroundColor(this.clickedCard === 2 ? '#1677FF' : '#1677FF20')
          .borderRadius(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('用药管理')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 4 });
            Text(this.clickedCard === 2 ? '>>> 点击已触发！<<<' : '跟踪您的用药情况')
              .fontSize(14)
              .fontColor(this.clickedCard === 2 ? '#1677FF' : '#666666');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 });
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.clickedCard === 2 ? '#E6F4FF' : '#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: this.clickedCard === 2 ? '#1677FF' : '#f0f0f0' })
        .onClick(() => {
          this.clickedCard = 2;
          try {
            router.pushUrl({ url: 'pages/Medications' });
          } catch (e) {
            console.error('路由跳转失败:', e);
          }
        })
      }
      .flexGrow(1)
      .width('80%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Footer({ activeIndex: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
