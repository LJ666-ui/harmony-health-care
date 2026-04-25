/**
 * 护士站监控大屏主页面（简化版）
 * 用于测试页面是否能正常加载
 */

import { router } from '@kit.ArkUI';

@Entry
@Component
struct NurseStationDashboardSimple {
  @State message: string = '护士站监控';
  @State currentTime: string = '';

  aboutToAppear(): void {
    console.log('NurseStationDashboardSimple: aboutToAppear');
    this.updateTime();
    setInterval(() => {
      this.updateTime();
    }, 1000);
  }

  updateTime(): void {
    const now = new Date();
    this.currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(this.currentTime)
          .fontSize(16)
          .fontColor('#666')
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      // 主内容区
      Column() {
        Text('智慧病房系统')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('功能开发中...')
          .fontSize(16)
          .fontColor('#999')
          .margin({ bottom: 40 })

        // 功能列表
        Column() {
          this.FunctionItem('🏥', '病房概览', '实时显示病房状态')
          this.FunctionItem('🚨', '告警中心', '实时告警与处理')
          this.FunctionItem('📊', '护理计划', '护理任务管理')
        }
        .width('100%')

        Button('返回')
          .margin({ top: 40 })
          .onClick(() => {
            router.back();
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder FunctionItem(icon: string, title: string, description: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)

        Text(description)
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 10 })
  }
}
