/**
 * 护理计划页面（简化版）
 * 用于测试页面是否能正常加载
 */

import { router } from '@kit.ArkUI';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct SmartWardCarePlanSimple {
  @State message: string = '护理计划';
  @State aiCareAdvice: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    console.log('SmartWardCarePlanSimple: aboutToAppear');
  }

  async getCareAdviceFromAI(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '请给出护理计划的建议'
        }
      });
      this.aiCareAdvice = response.output.content as string;
    } catch (error) {
      console.error('[SmartWardCarePlanSimple] AI护理建议失败:', error);
      this.aiCareAdvice = '';
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
        Text('护理任务时间线管理')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('功能开发中...')
          .fontSize(16)
          .fontColor('#999')
          .margin({ bottom: 40 })

        // 护理任务列表
        Column() {
          this.TaskItem('08:00', '测量血压', '301病房', '待处理')
          this.TaskItem('09:00', '输液更换', '302病房', '进行中')
          this.TaskItem('10:00', '协助翻身', '303病房', '已完成')
          this.TaskItem('11:00', '体温测量', '304病房', '待处理')
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

  @Builder TaskItem(time: string, taskName: string, room: string, status: string) {
    Row() {
      Text(time)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ right: 12 })
        .width(60)

      Column() {
        Text(taskName)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)

        Text(`${room} - ${status}`)
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      this.StatusBadge(status)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 10 })
  }

  @Builder StatusBadge(status: string) {
    Text(status)
      .fontSize(12)
      .fontColor('#FFFFFF')
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(4)
      .backgroundColor(status === '待处理' ? '#FF9800' : status === '进行中' ? '#2196F3' : '#4CAF50')
  }
}
