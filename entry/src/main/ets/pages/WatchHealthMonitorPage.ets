/**
 * 手环手表健康数据实时监测页面
 * 显示心率、血压、血氧、步数等核心健康数据
 */
import { router } from '@kit.ArkUI';
import { DeviceTypeUtil } from '../utils/DeviceTypeUtil';

interface HealthData {
  type: string;
  icon: string;
  value: string;
  unit: string;
  status: string;
  statusColor: string;
  updateTime: string;
}

@Entry
@Component
struct WatchHealthMonitorPage {
  @State healthDataList: HealthData[] = [];
  @State isRefreshing: boolean = false;
  private deviceUtil: DeviceTypeUtil = DeviceTypeUtil.getInstance();
  private refreshInterval: number = -1;

  aboutToAppear(): void {
    this.loadHealthData();
    // 每5秒自动刷新一次数据
    this.refreshInterval = setInterval(() => {
      this.refreshHealthData();
    }, 5000);
  }

  aboutToDisappear(): void {
    if (this.refreshInterval !== -1) {
      clearInterval(this.refreshInterval);
    }
  }

  loadHealthData(): void {
    // 模拟加载健康数据
    this.healthDataList = [
      {
        type: '心率',
        icon: '❤️',
        value: '72',
        unit: 'bpm',
        status: '正常',
        statusColor: '#4CAF50',
        updateTime: '刚刚'
      },
      {
        type: '血压',
        icon: '🩺',
        value: '120/80',
        unit: 'mmHg',
        status: '正常',
        statusColor: '#4CAF50',
        updateTime: '2分钟前'
      },
      {
        type: '血氧',
        icon: '💧',
        value: '98',
        unit: '%',
        status: '正常',
        statusColor: '#4CAF50',
        updateTime: '刚刚'
      },
      {
        type: '步数',
        icon: '👟',
        value: '8,542',
        unit: '步',
        status: '进行中',
        statusColor: '#2196F3',
        updateTime: '今天'
      }
    ];
  }

  refreshHealthData(): void {
    // 模拟刷新数据（实际应从传感器获取）
    const newDataList: HealthData[] = [];
    for (let i = 0; i < this.healthDataList.length; i++) {
      const item = this.healthDataList[i];
      // 随机波动心率
      if (item.type === '心率') {
        const newHeartRate = 70 + Math.floor(Math.random() * 10);
        const newItem: HealthData = {
          type: item.type,
          icon: item.icon,
          value: newHeartRate.toString(),
          unit: item.unit,
          status: item.status,
          statusColor: item.statusColor,
          updateTime: '刚刚'
        };
        newDataList.push(newItem);
      } else if (item.type === '血氧') {
        // 随机波动血氧
        const newOxygen = 97 + Math.floor(Math.random() * 3);
        const newItem: HealthData = {
          type: item.type,
          icon: item.icon,
          value: newOxygen.toString(),
          unit: item.unit,
          status: item.status,
          statusColor: item.statusColor,
          updateTime: '刚刚'
        };
        newDataList.push(newItem);
      } else {
        const newItem: HealthData = {
          type: item.type,
          icon: item.icon,
          value: item.value,
          unit: item.unit,
          status: item.status,
          statusColor: item.statusColor,
          updateTime: '刚刚'
        };
        newDataList.push(newItem);
      }
    }
    this.healthDataList = newDataList;
  }

  manualRefresh(): void {
    this.isRefreshing = true;
    setTimeout(() => {
      this.refreshHealthData();
      this.isRefreshing = false;
    }, 1000);
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

        Text('健康监测')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(16))
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(this.isRefreshing ? '⟳' : '↻')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(20))
          .fontColor('#FFFFFF')
          .onClick(() => {
            if (!this.isRefreshing) {
              this.manualRefresh();
            }
          })
      }
      .width('100%')
      .height(this.deviceUtil.getAdaptiveSpacing(50))
      .padding({ left: 12, right: 12 })
      .linearGradient({
        angle: 135,
        colors: [['#E74C3C', 0], ['#C0392B', 1]]
      })

      // 健康数据列表
      Scroll() {
        Column({ space: this.deviceUtil.getAdaptiveSpacing(10) }) {
          ForEach(this.healthDataList, (item: HealthData) => {
            this.buildHealthDataCard(item)
          }, (item: HealthData) => item.type)
        }
        .width('95%')
        .padding(this.deviceUtil.getAdaptiveSpacing(12))
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildHealthDataCard(item: HealthData) {
    Column() {
      Row() {
        Text(item.icon)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(24))

        Text(item.type)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(14))
          .fontColor('#666666')
          .margin({ left: 8 })
          .layoutWeight(1)

        Text(item.updateTime)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(10))
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(8) })

      Row() {
        Text(item.value)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(28))
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(item.unit)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(12))
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .width('100%')
      .margin({ bottom: this.deviceUtil.getAdaptiveSpacing(6) })

      Row() {
        Text('●')
          .fontSize(this.deviceUtil.getAdaptiveFontSize(10))
          .fontColor(item.statusColor)

        Text(item.status)
          .fontSize(this.deviceUtil.getAdaptiveFontSize(11))
          .fontColor(item.statusColor)
          .margin({ left: 4 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(this.deviceUtil.getAdaptiveSpacing(16))
    .backgroundColor('#FFFFFF')
    .borderRadius(this.deviceUtil.getAdaptiveSpacing(12))
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }
}
