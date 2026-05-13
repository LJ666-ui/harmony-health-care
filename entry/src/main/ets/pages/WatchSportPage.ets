/**
 * 手环手表运动数据记录页面
 * 显示今日运动数据，包括步数、距离、卡路里等
 */
import { router } from '@kit.ArkUI';
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';

interface SportData {
  type: string;
  icon: string;
  value: string;
  unit: string;
  target: string;
  progress: number;
  color: string;
}

interface SportRecord {
  id: string;
  type: string;
  icon: string;
  duration: string;
  calories: string;
  time: string;
}

@Entry
@Component
struct WatchSportPage {
  @State sportDataList: SportData[] = [];
  @State sportRecords: SportRecord[] = [];
  @State isTracking: boolean = false;
  @State trackingDuration: number = 0;
  @State aiSportAnalysis: string = '';
  @State aiTrainingAdvice: string = '';
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();
  private trackingTimer: number = -1;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    this.loadSportData();
    this.loadSportRecords();
  }

  aboutToDisappear(): void {
    if (this.trackingTimer !== -1) {
      clearInterval(this.trackingTimer);
    }
  }

  loadSportData(): void {
    // 模拟加载运动数据
    this.sportDataList = [
      {
        type: '步数',
        icon: '👟',
        value: '8,542',
        unit: '步',
        target: '10,000步',
        progress: 85,
        color: '#2ECC71'
      },
      {
        type: '距离',
        icon: '📍',
        value: '5.2',
        unit: '公里',
        target: '8公里',
        progress: 65,
        color: '#3498DB'
      },
      {
        type: '卡路里',
        icon: '🔥',
        value: '320',
        unit: '千卡',
        target: '500千卡',
        progress: 64,
        color: '#E74C3C'
      },
      {
        type: '活动时间',
        icon: '⏱️',
        value: '45',
        unit: '分钟',
        target: '60分钟',
        progress: 75,
        color: '#9B59B6'
      }
    ];
  }

  loadSportRecords(): void {
    // 模拟加载运动记录
    this.sportRecords = [
      { id: '1', type: '晨跑', icon: '🏃', duration: '30分钟', calories: '180千卡', time: '07:30' },
      { id: '2', type: '步行', icon: '🚶', duration: '15分钟', calories: '60千卡', time: '12:00' }
    ];
  }

  toggleTracking(): void {
    if (this.isTracking) {
      // 停止记录
      clearInterval(this.trackingTimer);
      this.isTracking = false;
      // 保存记录
      if (this.trackingDuration > 0) {
        const newRecord: SportRecord = {
          id: Date.now().toString(),
          type: '运动',
          icon: '🏃',
          duration: `${Math.floor(this.trackingDuration / 60)}分钟`,
          calories: `${Math.floor(this.trackingDuration * 0.1)}千卡`,
          time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
        };
        this.sportRecords = [newRecord, ...this.sportRecords];
      }
      this.trackingDuration = 0;
    } else {
      // 开始记录
      this.isTracking = true;
      this.trackingDuration = 0;
      this.trackingTimer = setInterval(() => {
        this.trackingDuration++;
      }, 1000);
    }
  }

  formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  async analyzeSportDataWithAI(): Promise<void> {
    const sportSummary = this.sportDataList.map(d =>
      `${d.type}: ${d.value}${d.unit} (目标: ${d.target}, 完成${Math.round(d.progress)}%)`
    ).join(', ');
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: `运动数据：${sportSummary}，请分析运动表现`
        }
      });
      this.aiSportAnalysis = response.output.content as string;
    } catch (error) {
      console.error('[WatchSportPage] AI运动分析失败:', error);
      this.aiSportAnalysis = 'AI分析暂时不可用';
    }
  }

  async getTrainingAdviceFromAI(): Promise<void> {
    try {
      const response = await this.orchestrator.process({
        requestId: Date.now().toString(),
        userId: AppStorage.get('userId')?.toString() || '0',
        input: {
          type: 'text',
          content: '基于当前运动数据给出个性化训练建议'
        }
      });
      this.aiTrainingAdvice = response.output.content as string;
    } catch (error) {
      console.error('[WatchSportPage] AI训练建议失败:', error);
      this.aiTrainingAdvice = '训练建议暂时不可用';
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

        Text('运动记录')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(' ')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
      }
      .width('100%')
      .height(this.deviceUtil.getAdaptiveSpacing(50))
      .padding({ left: 12, right: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#2ECC71', 0], ['#27AE60', 1]]
      })

      // 运动数据概览
      Scroll() {
        Column({ space: this.deviceUtil.getAdaptiveSpacing(10) }) {
          // 运动追踪按钮
          this.buildTrackingButton()

          // 运动数据卡片
          ForEach(this.sportDataList, (item: SportData) => {
            this.buildSportDataCard(item)
          }, (item: SportData) => item.type)

          // 运动记录列表
          this.buildSportRecordsList()
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

  @Builder buildTrackingButton() {
    Column() {
      if (this.isTracking) {
        Row() {
          Text('⏸️')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

          Text(this.formatDuration(this.trackingDuration))
            .fontSize(this.deviceUtil.getAdaptiveFontSize(24))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })

          Text('记录中...')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
            .fontColor('#FFFFFF')
            .opacity(0.8)
            .margin({ left: 8 })
        }
      } else {
        Row() {
          Text('▶️')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

          Text('开始运动')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })
        }
      }
    }
    .width('100%')
    .height(this.deviceUtil.getAdaptiveSpacing(60))
    .justifyContent(FlexAlign.Center)
    .linearGradient({
      angle: 135,
      colors: this.isTracking ? [['#E74C3C', 0], ['#C0392B', 1]] : [['#2ECC71', 0], ['#27AE60', 1]]
    })
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
    .onClick(() => {
      this.toggleTracking();
    })
  }

  @Builder buildSportDataCard(item: SportData) {
    Column() {
      Row() {
        Text(item.icon)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

        Text(item.type)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor('#666666')
          .margin({ left: 8 })
          .layoutWeight(1)

        Text(`${item.progress}%`)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .fontColor(item.color)
      }
      .width('100%')
      .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(6) })

      Row() {
        Text(item.value)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(24))
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(item.unit)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .width('100%')
      .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(6) })

      // 进度条
      Row() {
        Row()
          .width(`${item.progress}%`)
          .height('100%')
          .backgroundColor(item.color)
          .borderRadius(4)
      }
      .width('100%')
      .height(6)
      .backgroundColor('#F0F0F0')
      .borderRadius(4)

      Text(`目标: ${item.target}`)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(10))
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(12))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(10))
  }

  @Builder buildSportRecordsList() {
    Column() {
      Text('今日运动记录')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
        .fontColor('#666666')
        .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })

      if (this.sportRecords.length === 0) {
        Text('暂无运动记录')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .fontColor('#999999')
          .margin({ top: 20 })
      } else {
        ForEach(this.sportRecords, (record: SportRecord) => {
          Row() {
            Text(record.icon)
              .fontSize(this.deviceUtil.getAdaptiveFontSize(18))

            Column() {
              Text(record.type)
                .fontSize(this.deviceUtil.getAdaptiveFontSize(13))
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)

              Text(`${record.duration} · ${record.calories}`)
                .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
                .fontColor('#999999')
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 8 })

            Text(record.time)
              .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
              .fontColor('#999999')
          }
          .width('100%')
          .padding(this.deviceUtil.getAdaptiveSpacing(10))
          .backgroundColor('#FAFAFA')
          .borderRadius(this.deviceUtil.getAdaptiveSpacing(8))
          .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(6) })
        }, (record: SportRecord) => record.id)
      }
    }
    .width('100%')
    .margin({ top: this.deviceUtil.getAdaptiveSpacing(10) })
  }
}
