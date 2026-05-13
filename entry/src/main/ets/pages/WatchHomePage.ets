/**
 * 手环手表专用主页面
 * 精简版健康护理应用，只保留核心功能
 */
import { router } from '@kit.ArkUI';
import { DeviceTypeUtil, DeviceType } from '../utils/DeviceTypeUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface QuickAction {
  id: string;
  icon: string;
  title: string;
  pageUrl: string;
  color: string;
}

@Entry
@Component
struct WatchHomePage {
  @State currentTime: string = '';
  @State currentDeviceType: DeviceType = DeviceType.UNKNOWN;
  @State aiHealthSummary: string = '';
  @State aiSmartRecommendation: string = '';
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  // 快捷功能列表
  quickActions: QuickAction[] = [
    { id: 'health', icon: '❤️', title: '健康监测', pageUrl: 'pages/WatchHealthMonitorPage', color: '#E74C3C' },
    { id: 'medication', icon: '💊', title: '用药提醒', pageUrl: 'pages/WatchMedicationPage', color: '#3498DB' },
    { id: 'emergency', icon: '🆘', title: '紧急呼叫', pageUrl: 'pages/WatchEmergencyPage', color: '#E67E22' },
    { id: 'sport', icon: '🏃', title: '运动记录', pageUrl: 'pages/WatchSportPage', color: '#2ECC71' },
    { id: 'sleep', icon: '😴', title: '睡眠监测', pageUrl: 'pages/WatchSleepPage', color: '#9B59B6' },
    { id: 'message', icon: '💬', title: '消息通知', pageUrl: 'pages/WatchMessagePage', color: '#F39C12' }
  ];

  aboutToAppear(): void {
    this.currentDeviceType = this.deviceUtil.getDeviceType();
    this.updateTime();
    // 每分钟更新一次时间
    setInterval(() => {
      this.updateTime();
    }, 60000);
  }

  updateTime(): void {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    this.currentTime = `${hours}:${minutes}`;
  }

  async generateHealthSummary(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '请生成今日健康数据摘要和关键指标'
        }
      });
      this.aiHealthSummary = response.output.content as string;
    } catch (error) {
      console.error('[WatchHomePage] AI健康摘要生成失败:', error);
      this.aiHealthSummary = '';
    }
  }

  async getSmartRecommendation(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '基于当前时间和用户习惯，给出智能功能推荐'
        }
      });
      this.aiSmartRecommendation = response.output.content as string;
    } catch (error) {
      console.error('[WatchHomePage] AI智能推荐失败:', error);
      this.aiSmartRecommendation = '';
    }
  }

  build() {
    Column() {
      // 顶部时间显示
      Column() {
        Text(this.currentTime)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(32))
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text(this.getDateString())
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .margin({ top: 4 })
      }
      .width('100%')
      .height(this.deviceUtil.getAdaptiveSpacing(80))
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        angle: 135,
        colors: [['#667eea', 0], ['#764ba2', 1]]
      })

      // 快捷功能网格
      Grid() {
        ForEach(this.quickActions, (action: QuickAction) => {
          GridItem() {
            this.buildQuickActionItem(action)
          }
        }, (action: QuickAction) => action.id)
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr')
      .columnsGap(this.deviceUtil.getAdaptiveSpacing(8))
      .rowsGap(this.deviceUtil.getAdaptiveSpacing(8))
      .width('95%')
      .layoutWeight(1)
      .padding(this.deviceUtil.getAdaptiveSpacing(12))
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildQuickActionItem(action: QuickAction) {
    Column() {
      Text(action.icon)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(28))

      Text(action.title)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
        .fontColor('#333333')
        .margin({ top: this.deviceUtil.getAdaptiveSpacing(4) })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      router.pushUrl({ url: action.pageUrl }).catch((error: Error) => {
        console.error(`[WatchHomePage] 跳转失败: ${error.message}`);
      });
    })
  }

  getDateString(): string {
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekDay = weekDays[now.getDay()];
    return `${month}月${day}日 ${weekDay}`;
  }
}
