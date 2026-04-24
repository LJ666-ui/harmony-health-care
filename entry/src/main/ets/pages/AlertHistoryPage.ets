/**
 * 预警历史页面 - 简化版
 */

import router from '@ohos.router';

@Entry
@Component
struct AlertHistoryPage {
  @State selectedLevel: string = 'all';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('← 返回')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor('#1677FF')
          .onClick(() => {
            router.back();
          })
        
        Text('预警历史')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('  ')
          .width(60)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 筛选栏
      Row() {
        Text('等级:')
          .fontSize(14)
          .fontColor('#666666')
        
        Button('全部')
          .fontSize(12)
          .height(28)
          .type(ButtonType.Normal)
          .backgroundColor(this.selectedLevel === 'all' ? '#1677FF' : '#F0F0F0')
          .fontColor(this.selectedLevel === 'all' ? '#FFFFFF' : '#666666')
          .margin({ left: 8 })
          .onClick(() => {
            this.selectedLevel = 'all';
          })
        
        Button('危险')
          .fontSize(12)
          .height(28)
          .type(ButtonType.Normal)
          .backgroundColor(this.selectedLevel === 'danger' ? '#FF4D4F' : '#F0F0F0')
          .fontColor(this.selectedLevel === 'danger' ? '#FFFFFF' : '#666666')
          .margin({ left: 4 })
          .onClick(() => {
            this.selectedLevel = 'danger';
          })
        
        Button('警告')
          .fontSize(12)
          .height(28)
          .type(ButtonType.Normal)
          .backgroundColor(this.selectedLevel === 'warning' ? '#FAAD14' : '#F0F0F0')
          .fontColor(this.selectedLevel === 'warning' ? '#FFFFFF' : '#666666')
          .margin({ left: 4 })
          .onClick(() => {
            this.selectedLevel = 'warning';
          })
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .margin({ bottom: 8 })

      // 预警列表
      Scroll() {
        Column() {
          this.buildAlertCard('🚨', '心率危险', '心率严重异常: 125bpm, 需立即就医', '昨天 14:30', '#FF4D4F')
          this.buildAlertCard('🔶', '血压警告', '血压偏高: 145/92mmHg, 存在高血压风险', '今天 14:30', '#FAAD14')
          this.buildAlertCard('⚠️', '血糖注意', '血糖轻度偏离: 6.8mmol/L', '今天 09:15', '#1890FF')
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildAlertCard(
    icon: string,
    title: string,
    desc: string,
    time: string,
    color: string
  ) {
    Row() {
      Text(icon).fontSize(24)
      
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Text(desc)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      
      Text(time)
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(16)
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: color })
    .margin({ bottom: 12 })
    .onClick(() => {
      AlertDialog.show({
        title: title,
        message: desc,
        buttons: [
          { value: '标记已读', action: () => {} },
          { value: '关闭', action: () => {} }
        ]
      });
    })
  }
}
