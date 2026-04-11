import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

@Entry
@Component
struct MedicalRecord {
  build() {
    Column() {
      Header({ title: '病历详情', showBack: true })

      Column({ space: 20 }) {
        // 患者信息卡片
        Column() {
          Text('患者信息')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ bottom: 16 })

          Row() {
            Text('姓名:')
              .fontSize(14)
              .fontColor('#666666')
              .width(80)
            Text('张三')
              .fontSize(14)
              .fontColor('#333333')
              .flexGrow(1)
          }

          Row() {
            Text('性别:')
              .fontSize(14)
              .fontColor('#666666')
              .width(80)
            Text('男')
              .fontSize(14)
              .fontColor('#333333')
              .flexGrow(1)
          }

          Row() {
            Text('年龄:')
              .fontSize(14)
              .fontColor('#666666')
              .width(80)
            Text('35岁')
              .fontSize(14)
              .fontColor('#333333')
              .flexGrow(1)
          }

          Row() {
            Text('就诊日期:')
              .fontSize(14)
              .fontColor('#666666')
              .width(80)
            Text('2024-03-15')
              .fontSize(14)
              .fontColor('#333333')
              .flexGrow(1)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#f0f0f0' })

        // 诊断结果卡片
        Column() {
          Text('诊断结果')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ bottom: 16 })

          Text('高血压 I 级')
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#f0f0f0' })

        // 医生建议卡片
        Column() {
          Text('医生建议')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ bottom: 16 })

          Text('1. 注意休息，避免过度劳累\n2. 低盐饮食，控制血压\n3. 定期测量血压，记录数据\n4. 按时服药，不要擅自停药')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#f0f0f0' })

        // 用药记录卡片
        Column() {
          Text('用药记录')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ bottom: 16 })

          Text('1. 阿司匹林 100mg，每日一次\n2. 降压药 5mg，每日两次')
            .fontSize(14)
            .fontColor('#333333')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#f0f0f0' })

        // 查看历史病历按钮
        Button('查看历史病历')
          .width('100%')
          .height(48)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('medium')
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(8)
          .onClick(() => {
            console.log('查看历史病历');
          })
      }
      .flexGrow(1)
      .width('80%')
      .padding({ top: 20, bottom: 20 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)

      Footer({ activeIndex: 4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}