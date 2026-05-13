/**
 * 病房设备控制页面（简化版）
 * 用于测试页面是否能正常加载
 */

import { router } from '@kit.ArkUI';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

@Entry
@Component
struct SmartWardDevicesSimple {
  @State message: string = '病房设备管理';
  @State aiDeviceStatus: string = '';
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    console.log('SmartWardDevicesSimple: aboutToAppear');
  }

  async checkDeviceStatusWithAI(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '检查病房设备运行状态'
        }
      });
      this.aiDeviceStatus = response.output.content as string;
    } catch (error) {
      console.error('[SmartWardDevicesSimple] AI设备状态失败:', error);
      this.aiDeviceStatus = '';
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
        Text('智能病房设备控制')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        Text('功能开发中...')
          .fontSize(16)
          .fontColor('#999')
          .margin({ bottom: 40 })

        // 设备列表
        Column() {
          this.DeviceItem('💡', '智能灯光', '亮度和色温控制')
          this.DeviceItem('🛏️', '智能病床', '升降和翻身控制')
          this.DeviceItem('💓', '患者监护仪', '生命体征监测')
          this.DeviceItem('🪟', '智能窗帘', '开合控制')
          this.DeviceItem('📺', '智能电视', '频道和音量控制')
          this.DeviceItem('❄️', '空调', '温度和模式控制')
          this.DeviceItem('🔔', '呼叫按钮', '患者呼叫')
          this.DeviceItem('💉', '输液泵', '流速和状态控制')
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

  @Builder DeviceItem(icon: string, name: string, description: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .margin({ right: 12 })

      Column() {
        Text(name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)

        Text(description)
          .fontSize(12)
          .fontColor('#666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('在线')
        .fontSize(12)
        .fontColor('#4CAF50')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#E8F5E9')
        .borderRadius(4)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 10 })
  }
}
