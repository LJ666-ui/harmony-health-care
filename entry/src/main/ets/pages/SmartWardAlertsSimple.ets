/**
 * 告警中心页面（简化版）
 * 用于测试页面是否能正常加载
 */

import { router } from '@kit.ArkUI';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct SmartWardAlertsSimple {
  @State message: string = '告警中心';
  @State aiAlertSummary: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    console.log('SmartWardAlertsSimple: aboutToAppear');
  }

  async getAlertSummaryFromAI(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '请总结当前病房警报情况'
        }
      });
      this.aiAlertSummary = response.output.content as string;
    } catch (error) {
      console.error('[SmartWardAlertsSimple] AI警报摘要失败:', error);
      this.aiAlertSummary = '';
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.message)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      // 主内容区
      Column() {
        Text('实时告警与处理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('功能开发中...')
          .fontSize(16)
          .fontColor('#999')
          .margin({ bottom: 40 })

        // 告警列表
        Column() {
          this.AlertItem('🔴', '急救', '心率异常', '301病房')
          this.AlertItem('🟠', '紧急', '血压异常', '302病房')
          this.AlertItem('🟡', '警告', '体温异常', '303病房')
          this.AlertItem('🔵', '信息', '护理提醒', '304病房')
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

  @Builder AlertItem(levelIcon: string, levelName: string, message: string, room: string) {
    Row() {
      Text(levelIcon)
        .fontSize(16)
        .margin({ right: 8 })

      Column() {
        Text(message)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)

        Text(`${levelName} - ${room}`)
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('确认')
        .fontSize(12)
        .height(28)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 10 })
  }
}
