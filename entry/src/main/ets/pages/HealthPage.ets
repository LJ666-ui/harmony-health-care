import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

@Entry
@Component
struct HealthPage {
  build() {
    Column() {
      Header({ title: '我的健康', showBack: true })

      Column({ space: 20 }) {
        Text('我的健康')
          .fontSize(24)
          .fontWeight('bold')
          .fontColor('#1677FF')
          .margin({ top: 20, bottom: 16 })

        Text('欢迎使用健康管理功能')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 32 })

        // 用药提醒按钮
        Row() {
          Column() {
            Text('💊')
              .fontSize(32)
              .fontColor('#1677FF');
          }
          .width(64)
          .height(64)
          .backgroundColor('#1677FF20')
          .borderRadius(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('用药提醒')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 4 });
            Text('管理您的用药计划和提醒')
              .fontSize(14)
              .fontColor('#666666');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 });

          Text('›')
            .fontSize(20)
            .fontColor('#999999')
            .margin({ right: 8 });
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#f0f0f0' })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Medications' });
        })

        // 健康记录按钮
        Row() {
          Column() {
            Text('📋')
              .fontSize(32)
              .fontColor('#1677FF');
          }
          .width(64)
          .height(64)
          .backgroundColor('#1677FF20')
          .borderRadius(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('健康记录')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 4 });
            Text('查看和管理您的健康数据')
              .fontSize(14)
              .fontColor('#666666');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 });

          Text('›')
            .fontSize(20)
            .fontColor('#999999')
            .margin({ right: 8 });
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#f0f0f0' })
        .onClick(() => {
          router.pushUrl({ url: 'pages/HealthRecords' });
        })

        // 健康风险评估按钮
        Row() {
          Column() {
            Text('📊')
              .fontSize(32)
              .fontColor('#1677FF');
          }
          .width(64)
          .height(64)
          .backgroundColor('#1677FF20')
          .borderRadius(32)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('健康风险评估')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 4 });
            Text('评估您的健康风险状况')
              .fontSize(14)
              .fontColor('#666666');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 });

          Text('›')
            .fontSize(20)
            .fontColor('#999999')
            .margin({ right: 8 });
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#f0f0f0' })
        .onClick(() => {
          router.pushUrl({ url: 'pages/RiskAssessmentPage' });
        })
      }
      .flexGrow(1)
      .width('80%')
      .padding({ top: 10, bottom: 20 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)

      Footer({ activeIndex: 4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}