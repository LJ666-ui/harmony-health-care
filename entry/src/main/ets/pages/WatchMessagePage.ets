/**
 * 手环手表消息通知页面
 * 显示来自手机的消息通知
 */
import { router } from '@kit.ArkUI';
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface MessageNotification {
  id: string;
  type: string;
  icon: string;
  title: string;
  content: string;
  time: string;
  isRead: boolean;
  source: string;
}

@Entry
@Component
struct WatchMessagePage {
  @State messages: MessageNotification[] = [];
  @State filterType: string = 'all';
  @State aiSmartSummary: string = '';
  @State aiUrgencyAssessment: string = '';
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    this.loadMessages();
  }

  loadMessages(): void {
    // 模拟加载消息通知
    this.messages = [
      {
        id: '1',
        type: 'health',
        icon: '❤️',
        title: '心率异常提醒',
        content: '您的心率已超过100bpm，请注意休息',
        time: '10分钟前',
        isRead: false,
        source: '健康监测'
      },
      {
        id: '2',
        type: 'medication',
        icon: '💊',
        title: '用药提醒',
        content: '该服用降压药了，请按时服药',
        time: '30分钟前',
        isRead: false,
        source: '用药助手'
      },
      {
        id: '3',
        type: 'appointment',
        icon: '📅',
        title: '预约提醒',
        content: '明天上午10点有医生预约',
        time: '1小时前',
        isRead: true,
        source: '医疗服务'
      },
      {
        id: '4',
        type: 'sport',
        icon: '🏃',
        title: '运动目标达成',
        content: '恭喜！今日步数已达到10000步',
        time: '2小时前',
        isRead: true,
        source: '运动助手'
      },
      {
        id: '5',
        type: 'system',
        icon: '🔔',
        title: '系统通知',
        content: '手环固件有新版本可更新',
        time: '昨天',
        isRead: true,
        source: '系统'
      }
    ];
  }

  markAsRead(messageId: string): void {
    const message = this.messages.find(m => m.id === messageId);
    if (message) {
      message.isRead = true;
    }
  }

  deleteMessage(messageId: string): void {
    const index = this.messages.findIndex(m => m.id === messageId);
    if (index !== -1) {
      this.messages.splice(index, 1);
    }
  }

  getFilteredMessages(): MessageNotification[] {
    if (this.filterType === 'all') {
      return this.messages;
    }
    return this.messages.filter(m => m.type === this.filterType);
  }

  getUnreadCount(): number {
    return this.messages.filter(m => !m.isRead).length;
  }

  async generateMessageSummary(): Promise<void> {
    const unreadMessages = this.messages.filter(m => !m.isRead);
    const messageSummary = unreadMessages.map(m =>
      `[${m.type}] ${m.title}: ${m.content}`
    ).join('\n');
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `未读消息摘要：\n${messageSummary}\n请总结关键信息`
        }
      });
      this.aiSmartSummary = response.output.content as string;
    } catch (error) {
      console.error('[WatchMessagePage] AI消息摘要失败:', error);
      this.aiSmartSummary = '';
    }
  }

  async assessUrgency(): Promise<void> {
    const healthMessages = this.messages.filter(m => m.type === 'health' || m.type === 'emergency');
    if (healthMessages.length === 0) return;
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `健康相关消息：${healthMessages.map(m => m.content).join('；')}，请评估紧急程度`
        }
      });
      this.aiUrgencyAssessment = response.output.content as string;
    } catch (error) {
      console.error('[WatchMessagePage] AI紧急评估失败:', error);
      this.aiUrgencyAssessment = '';
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('←')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
          .fontColor('#FFFFFF')
          .onClick(() => {
            router.back();
          })

        Text('消息通知')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(this.getUnreadCount() > 0 ? `${this.getUnreadCount()}` : ' ')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(this.deviceUtil.getAdaptiveSpacing(50))
      .padding({ left: 12, right: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#F39C12', 0], ['#E67E22', 1]]
      })

      // 消息类型筛选
      Scroll() {
        Row({ space: this.deviceUtil.getAdaptiveSpacing(8) }) {
          this.buildFilterChip('全部', 'all')
          this.buildFilterChip('健康', 'health')
          this.buildFilterChip('用药', 'medication')
          this.buildFilterChip('预约', 'appointment')
        }
        .padding({ left: 12, right: 12 })
      }
      .width('100%')
      .height(this.deviceUtil.getAdaptiveSpacing(40))
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .margin({ top: this.deviceUtil.getAdaptiveSpacing(8) })

      // 消息列表
      Scroll() {
        Column({ space: this.deviceUtil.getAdaptiveSpacing(8) }) {
          if (this.getFilteredMessages().length === 0) {
            Column() {
              Text('📭')
                .fontSize(this.deviceUtil.getAdaptiveFontSize(40))
                .margin({ bottom: 8 })

              Text('暂无消息')
                .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
                .fontColor('#999999')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          } else {
            ForEach(this.getFilteredMessages(), (message: MessageNotification) => {
              this.buildMessageItem(message)
            }, (message: MessageNotification) => message.id)
          }
        }
        .width('95%')
        .padding(this.deviceUtil.getAdaptiveSpacing(8))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildFilterChip(label: string, type: string) {
    Text(label)
      .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
      .fontColor(this.filterType === type ? '#FFFFFF' : '#666666')
      .backgroundColor(this.filterType === type ? '#F39C12' : '#FFFFFF')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(15)
      .onClick(() => {
        this.filterType = type;
      })
  }

  @Builder buildMessageItem(message: MessageNotification) {
    Column() {
      Row() {
        Text(message.icon)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

        Column() {
          Row() {
            Text(message.title)
              .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
              .fontColor(message.isRead ? '#999999' : '#333333')
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)

            if (!message.isRead) {
              Text('●')
                .fontSize(this.deviceUtil.getAdaptiveFontSize(10))
                .fontColor('#E74C3C')
            }
          }
          .width('100%')

          Text(message.content)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
            .fontColor('#666666')
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Text(message.source)
              .fontSize(this.deviceUtil.getAdaptiveFontSize(10))
              .fontColor('#999999')

            Text(message.time)
              .fontSize(this.deviceUtil.getAdaptiveFontSize(10))
              .fontColor('#999999')
              .margin({ left: 8 })
          }
          .width('100%')
          .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 8 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(12))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(10))
    .opacity(message.isRead ? 0.7 : 1)
    .onClick(() => {
      this.markAsRead(message.id);
    })
  }
}
