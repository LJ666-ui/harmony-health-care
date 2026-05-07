/**
 * 手环手表睡眠监测页面
 * 显示睡眠数据和睡眠质量分析
 */
import { router } from '@kit.ArkUI';
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';

interface SleepData {
  date: string;
  totalDuration: string;
  deepSleep: string;
  lightSleep: string;
  awakeTime: string;
  quality: number;
  qualityText: string;
  qualityColor: string;
}

interface SleepStage {
  time: string;
  stage: string;
  duration: string;
  color: string;
}

@Entry
@Component
struct WatchSleepPage {
  @State lastSleepData: SleepData | null = null;
  @State sleepStages: SleepStage[] = [];
  @State isSleepTracking: boolean = false;
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();

  aboutToAppear(): void {
    this.loadSleepData();
  }

  loadSleepData(): void {
    // 模拟加载睡眠数据
    this.lastSleepData = {
      date: '昨晚',
      totalDuration: '7小时32分',
      deepSleep: '2小时15分',
      lightSleep: '4小时45分',
      awakeTime: '32分',
      quality: 85,
      qualityText: '良好',
      qualityColor: '#4CAF50'
    };

    this.sleepStages = [
      { time: '23:00', stage: '入睡', duration: '10分', color: '#9B59B6' },
      { time: '23:10', stage: '浅睡', duration: '45分', color: '#3498DB' },
      { time: '23:55', stage: '深睡', duration: '1小时20分', color: '#2C3E50' },
      { time: '01:15', stage: '浅睡', duration: '1小时30分', color: '#3498DB' },
      { time: '02:45', stage: '深睡', duration: '55分', color: '#2C3E50' },
      { time: '03:40', stage: '浅睡', duration: '2小时', color: '#3498DB' },
      { time: '05:40', stage: '清醒', duration: '32分', color: '#E74C3C' },
      { time: '06:12', stage: '浅睡', duration: '1小时20分', color: '#3498DB' }
    ];
  }

  toggleSleepTracking(): void {
    this.isSleepTracking = !this.isSleepTracking;
    // 实际应用中应调用传感器API开始/停止睡眠监测
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

        Text('睡眠监测')
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
        colors: [['#9B59B6', 0], ['#8E44AD', 1]]
      })

      Scroll() {
        Column({ space: this.deviceUtil.getAdaptiveSpacing(10) }) {
          // 睡眠追踪按钮
          this.buildTrackingButton()

          // 睡眠数据概览
          if (this.lastSleepData) {
            this.buildSleepOverview()
            this.buildSleepDetails()
            this.buildSleepStages()
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

  @Builder buildTrackingButton() {
    Column() {
      if (this.isSleepTracking) {
        Row() {
          Text('🌙')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

          Text('睡眠监测中...')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })
        }
      } else {
        Row() {
          Text('🌙')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(20))

          Text('开始睡眠监测')
            .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })
        }
      }
    }
    .width('100%')
    .height(this.deviceUtil.getAdaptiveSpacing(50))
    .justifyContent(FlexAlign.Center)
    .linearGradient({
      angle: 135,
      colors: this.isSleepTracking ? [['#E74C3C', 0], ['#C0392B', 1]] : [['#9B59B6', 0], ['#8E44AD', 1]]
    })
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
    .onClick(() => {
      this.toggleSleepTracking();
    })
  }

  @Builder buildSleepOverview() {
    Column() {
      Row() {
        Text('😴')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(24))

        Text(this.lastSleepData!.date)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor('#666666')
          .margin({ left: 8 })
          .layoutWeight(1)

        Text(this.lastSleepData!.qualityText)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .fontColor(this.lastSleepData!.qualityColor)
          .backgroundColor(this.lastSleepData!.qualityColor + '20')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10)
      }
      .width('100%')
      .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })

      Row() {
        Text(this.lastSleepData!.totalDuration)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(28))
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })

      // 睡眠质量进度条
      Column() {
        Row() {
          Row()
            .width(`${this.lastSleepData!.quality}%`)
            .height('100%')
            .backgroundColor(this.lastSleepData!.qualityColor)
            .borderRadius(4)
        }
        .width('100%')
        .height(8)
        .backgroundColor('#F0F0F0')
        .borderRadius(4)

        Text(`睡眠质量: ${this.lastSleepData!.quality}分`)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(16))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
  }

  @Builder buildSleepDetails() {
    Column() {
      Text('睡眠详情')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
        .fontColor('#666666')
        .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })

      Row() {
        this.buildDetailItem('深度睡眠', this.lastSleepData!.deepSleep, '#2C3E50')
        this.buildDetailItem('浅度睡眠', this.lastSleepData!.lightSleep, '#3498DB')
        this.buildDetailItem('清醒时间', this.lastSleepData!.awakeTime, '#E74C3C')
      }
      .width('100%')
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(12))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(10))
  }

  @Builder buildDetailItem(title: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
        .fontWeight(FontWeight.Bold)
        .fontColor(color)

      Text(title)
        .fontSize(this.deviceUtil.getAdaptiveFontSize(10))
        .fontColor('#999999')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
  }

  @Builder buildSleepStages() {
    Column() {
      Text('睡眠阶段')
        .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
        .fontColor('#666666')
        .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })

      ForEach(this.sleepStages, (stage: SleepStage) => {
        Row() {
          Text(stage.time)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
            .fontColor('#999999')
            .width(50)

          Row()
            .width(8)
            .height(8)
            .backgroundColor(stage.color)
            .borderRadius(4)
            .margin({ left: 8, right: 8 })

          Text(stage.stage)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
            .fontColor('#333333')
            .layoutWeight(1)

          Text(stage.duration)
            .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
            .fontColor('#999999')
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })
      }, (stage: SleepStage) => stage.time)
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(12))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(10))
  }
}
