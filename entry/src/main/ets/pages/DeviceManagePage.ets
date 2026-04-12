import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface HarmonyDevice {
  id: string;
  name: string;
  icon: string;
  type: 'phone' | 'watch' | 'tablet' | 'tv' | 'other';
  model: string;
  version: string;
  isOnline: boolean;
  isBound: boolean;
  lastSyncTime: string | null;
  syncStatus: 'success' | 'syncing' | 'failed' | 'pending';
  batteryLevel: number;
  signalStrength: number;
  bindDate: string;
}

interface SyncLogItem {
  id: string;
  deviceId: string;
  deviceName: string;
  action: string;
  dataType: string;
  timestamp: string;
  status: 'success' | 'failed';
  detail: string;
}

interface DiscoveredDevice {
  id: string;
  name: string;
  icon: string;
  type: string;
  distance: string;
}

@Entry
@Component
struct DeviceManagePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentTab: number = 0;
  @State showAddDeviceDialog: boolean = false;
  @State showDeviceDetail: boolean = false;
  @State showUnbindConfirm: boolean = false;
  @State selectedDevice: HarmonyDevice | undefined = undefined;

  @State boundDevices: HarmonyDevice[] = [
    {
      id: 'dev001',
      name: '我的华为手机',
      icon: '📱',
      type: 'phone',
      model: 'Mate 60 Pro+',
      version: 'HarmonyOS 4.2',
      isOnline: true,
      isBound: true,
      lastSyncTime: this.formatTime(new Date()),
      syncStatus: 'success',
      batteryLevel: 85,
      signalStrength: 100,
      bindDate: '2024-01-15'
    },
    {
      id: 'dev002',
      name: '华为手表GT4',
      icon: '⌚',
      type: 'watch',
      model: 'Watch GT4 Pro',
      version: 'HarmonyOS 4.0',
      isOnline: true,
      isBound: true,
      lastSyncTime: this.formatTime(new Date(Date.now() - 5 * 60000)),
      syncStatus: 'success',
      batteryLevel: 62,
      signalStrength: 95,
      bindDate: '2024-02-20'
    },
    {
      id: 'dev003',
      name: '华为平板MATEPAD',
      icon: '📲',
      type: 'tablet',
      model: 'MatePad Pro 13.2',
      version: 'HarmonyOS 4.1',
      isOnline: false,
      isBound: true,
      lastSyncTime: this.formatTime(new Date(Date.now() - 3600000 * 3)),
      syncStatus: 'pending',
      batteryLevel: 0,
      signalStrength: 0,
      bindDate: '2024-03-10'
    }
  ];

  @State discoveredDevices: DiscoveredDevice[] = [];
  @State isScanning: boolean = false;

  @State syncEnabled: boolean = true;
  @State healthDataSync: boolean = true;
  @State medicationSync: boolean = true;
  @State appointmentSync: boolean = true;

  @State syncLogs: SyncLogItem[] = [
    {
      id: 'log001',
      deviceId: 'dev002',
      deviceName: '华为手表GT4',
      action: '数据上传',
      dataType: '心率/血压/步数',
      timestamp: this.formatTime(new Date()),
      status: 'success',
      detail: '成功同步3条健康数据'
    },
    {
      id: 'log002',
      deviceId: 'dev001',
      deviceName: '我的华为手机',
      action: '数据接收',
      dataType: '用药提醒',
      timestamp: this.formatTime(new Date(Date.now() - 10 * 60000)),
      status: 'success',
      detail: '收到用药计划更新'
    },
    {
      id: 'log003',
      deviceId: 'dev003',
      deviceName: '华为平板MATEPAD',
      action: '数据同步',
      dataType: '健康档案',
      timestamp: this.formatTime(new Date(Date.now() - 1800000)),
      status: 'failed',
      detail: '设备离线，同步失败'
    }
  ];

  @State collaborationExamples: CollaborationExample[] = [
    {
      id: 'col001',
      title: '手机录入健康数据',
      description: '在手机上录入血压、血糖等数据',
      fromDevice: '📱 手机',
      toDevice: '📲 平板',
      status: 'ready',
      icon: '📝'
    },
    {
      id: 'col002',
      title: '平板查看分析报告',
      description: '平板实时显示大屏健康报告',
      fromDevice: '📱 手机',
      toDevice: '📲 平板',
      status: 'active',
      icon: '📊'
    },
    {
      id: 'col003',
      title: '手表异常预警推送',
      description: '心率异常时自动推送到手机',
      fromDevice: '⌚ 手表',
      toDevice: '📱 手机',
      status: 'alert',
      icon: '⚠️'
    },
    {
      id: 'col004',
      title: '跨设备用药提醒',
      description: '所有绑定的设备同时响铃提醒',
      fromDevice: '☁️ 云端',
      toDevice: '📱📲⌚ 全部设备',
      status: 'pending',
      icon: '💊'
    }
  ];

  private scroller: Scroller = new Scroller();

  formatTime(date: Date): string {
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    const hours: string = String(date.getHours()).padStart(2, '0');
    const minutes: string = String(date.getMinutes()).padStart(2, '0');

    return `${year}-${month}-${day} ${hours}:${minutes}`;
  }

  getRelativeTime(timeStr: string): string {
    if (!timeStr) return '从未同步';

    try {
      const targetTime: number = new Date(timeStr).getTime();
      const now: number = Date.now();
      const diffMs: number = now - targetTime;
      const diffMin: number = Math.floor(diffMs / 60000);

      if (diffMin < 1) return '刚刚';
      if (diffMin < 60) return `${diffMin}分钟前`;

      const diffHour: number = Math.floor(diffMin / 60);
      if (diffHour < 24) return `${diffHour}小时前`;

      const diffDay: number = Math.floor(diffHour / 24);
      if (diffDay < 7) return `${diffDay}天前`;

      return timeStr.substring(5);
    } catch (e) {
      return timeStr;
    }
  }

  getOnlineCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.boundDevices.length; i++) {
      if (this.boundDevices[i].isOnline) {
        count++;
      }
    }
    return count;
  }

  getBoundCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.boundDevices.length; i++) {
      if (this.boundDevices[i].isBound) {
        count++;
      }
    }
    return count;
  }

  startScanDevices(): void {
    this.isScanning = true;
    this.discoveredDevices = [];

    setTimeout(() => {
      this.discoveredDevices = [
        { id: 'disc001', name: '华为智慧屏V5', icon: '🖥️', type: '智慧屏', distance: '附近' },
        { id: 'disc002', name: '华为耳机FreeBuds', icon: '🎧', type: '音频设备', distance: '很近' },
        { id: 'disc003', name: '华为体脂秤3', icon: '⚖️', type: '健康设备', distance: '附近' }
      ];
      this.isScanning = false;
    }, 2000);
  }

  bindDevice(device: DiscoveredDevice): void {
    const newDevice: HarmonyDevice = {
      id: device.id,
      name: device.name,
      icon: device.icon,
      type: 'other',
      model: device.name,
      version: 'HarmonyOS 4.x',
      isOnline: true,
      isBound: true,
      lastSyncTime: this.formatTime(new Date()),
      syncStatus: 'success',
      batteryLevel: 80,
      signalStrength: 90,
      bindDate: this.formatTime(new Date()).substring(0, 10)
    };

    const updatedDevices: HarmonyDevice[] = [...this.boundDevices, newDevice];
    this.boundDevices = updatedDevices;

    const newLog: SyncLogItem = {
      id: `log${Date.now()}`,
      deviceId: newDevice.id,
      deviceName: newDevice.name,
      action: '设备绑定',
      dataType: '-',
      timestamp: this.formatTime(new Date()),
      status: 'success',
      detail: `成功绑定${device.name}`
    };
    const updatedLogs: SyncLogItem[] = [newLog, ...this.syncLogs];
    this.syncLogs = updatedLogs;

    ToastUtil.operationSuccess('设备绑定');

    this.showAddDeviceDialog = false;
  }

  unbindDevice(deviceId: string): void {
    const filteredDevices: HarmonyDevice[] = [];
    for (let i: number = 0; i < this.boundDevices.length; i++) {
      if (this.boundDevices[i].id !== deviceId) {
        filteredDevices.push(this.boundDevices[i]);
      }
    }
    this.boundDevices = filteredDevices;

    ToastUtil.operationSuccess('设备解绑');
    this.showUnbindConfirm = false;
    this.showDeviceDetail = false;
  }

  openDeviceDetail(device: HarmonyDevice): void {
    this.selectedDevice = device;
    this.showDeviceDetail = true;
  }

  triggerSync(deviceId: string): void {
    const updatedDevices: HarmonyDevice[] = [];
    for (let i: number = 0; i < this.boundDevices.length; i++) {
      const device: HarmonyDevice = this.boundDevices[i];
      if (device.id === deviceId && device.isOnline) {
        updatedDevices.push({
          id: device.id,
          name: device.name,
          icon: device.icon,
          type: device.type,
          model: device.model,
          version: device.version,
          isOnline: device.isOnline,
          isBound: device.isBound,
          lastSyncTime: this.formatTime(new Date()),
          syncStatus: 'syncing',
          batteryLevel: device.batteryLevel,
          signalStrength: device.signalStrength,
          bindDate: device.bindDate
        });
      } else {
        updatedDevices.push(device);
      }
    }
    this.boundDevices = updatedDevices;

    setTimeout(() => {
      const finalDevices: HarmonyDevice[] = [];
      for (let j: number = 0; j < this.boundDevices.length; j++) {
        const dev: HarmonyDevice = this.boundDevices[j];
        if (dev.id === deviceId) {
          finalDevices.push({
            id: dev.id,
            name: dev.name,
            icon: dev.icon,
            type: dev.type,
            model: dev.model,
            version: dev.version,
            isOnline: dev.isOnline,
            isBound: dev.isBound,
            lastSyncTime: this.formatTime(new Date()),
            syncStatus: 'success',
            batteryLevel: dev.batteryLevel,
            signalStrength: dev.signalStrength,
            bindDate: dev.bindDate
          });
        } else {
          finalDevices.push(dev);
        }
      }
      this.boundDevices = finalDevices;
    }, 2000);
  }

  retryFailedSync(): void {
    for (let i: number = 0; i < this.boundDevices.length; i++) {
      if (this.boundDevices[i].syncStatus === 'failed' || this.boundDevices[i].syncStatus === 'pending') {
        if (this.boundDevices[i].isOnline) {
          this.triggerSync(this.boundDevices[i].id);
        }
      }
    }
    ToastUtil.showInfo('正在重试同步...');
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('←')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          });

        Text('设备管理')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text('+')
          .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
          .fontColor('#1677FF')
          .fontWeight('bold')
          .margin({ right: 16 })
          .onClick(() => {
            this.showAddDeviceDialog = true;
            this.startScanDevices();
          });
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.Center);

      Row({ space: 8 }) {
        Button('📱 已绑定')
          .height(36)
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor(this.currentTab === 0 ? '#FFFFFF' : '#666666')
          .backgroundColor(this.currentTab === 0 ? '#1677FF' : '#F5F5F5')
          .borderRadius(18)
          .layoutWeight(1)
          .onClick(() => {
            this.currentTab = 0;
          });

        Button('🔄 同步状态')
          .height(36)
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor(this.currentTab === 1 ? '#FFFFFF' : '#666666')
          .backgroundColor(this.currentTab === 1 ? '#1677FF' : '#F5F5F5')
          .borderRadius(18)
          .layoutWeight(1)
          .onClick(() => {
            this.currentTab = 1;
          });

        Button('🔗 协同示例')
          .height(36)
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor(this.currentTab === 2 ? '#FFFFFF' : '#666666')
          .backgroundColor(this.currentTab === 2 ? '#1677FF' : '#F5F5F5')
          .borderRadius(18)
          .layoutWeight(1)
          .onClick(() => {
            this.currentTab = 2;
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF');

      if (this.currentTab === 0) {
        Scroll(this.scroller) {
          Column({ space: 16 }) {
            Column({ space: 12 }) {
              Row({ space: 8 }) {
                Text(`已绑定 ${this.getBoundCount()} 台设备`)
                  .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor('#333333');

                Blank();

                Text(`${this.getOnlineCount()} 在线`)
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#52C41A')
                  .backgroundColor('#F6FFED')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(12)
                  .border({ width: 1, color: '#B7EB8F' });
              }
              .width('100%');

              ForEach(this.boundDevices.filter((d: HarmonyDevice) => d.isBound), (device: HarmonyDevice) => {
                Row({ space: 12 }) {
                  Stack({ alignContent: Alignment.BottomEnd }) {
                    Column() {
                      Text(device.icon)
                        .fontSize(32);
                    }
                    .width(64)
                    .height(64)
                    .backgroundColor(device.isOnline ? '#E6F7FF' : '#F5F5F5')
                    .borderRadius(16)
                    .justifyContent(FlexAlign.Center)
                    .border({ width: 1, color: device.isOnline ? '#91D5FF' : '#D9D9D9' });

                    Circle()
                      .width(12)
                      .height(12)
                      .fill(device.isOnline ? '#52C41A' : '#D9D9D9')
                      .border({ width: 2, color: '#FFFFFF' });
                  }
                  .width(64)
                  .height(64);

                  Column({ space: 6 }) {
                    Row({ space: 8 }) {
                      Text(device.name)
                        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                        .fontWeight('bold')
                        .fontColor('#333333')
                        .maxLines(1)
                        .layoutWeight(1);

                      if (device.isOnline) {
                        Text('在线')
                          .fontSize(10)
                          .fontColor('#FFFFFF')
                          .backgroundColor('#52C41A')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(8);
                      } else {
                        Text('离线')
                          .fontSize(10)
                          .fontColor('#999999')
                          .backgroundColor('#F0F0F0')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(8);
                      }
                    }

                    Text(`${device.model} · ${device.version}`)
                      .fontSize(this.isElderMode ? 12 : 11)
                      .fontColor('#999999');

                    Row({ space: 12 }) {
                      if (device.lastSyncTime) {
                        Text(`上次同步: ${this.getRelativeTime(device.lastSyncTime)}`)
                          .fontSize(this.isElderMode ? 11 : 10)
                          .fontColor('#666666');
                      }

                      if (device.syncStatus === 'syncing') {
                        Text('同步中...')
                          .fontSize(this.isElderMode ? 11 : 10)
                          .fontColor('#1677FF')
                          .fontWeight(FontWeight.Medium);
                      } else if (device.syncStatus === 'failed') {
                        Text('❌ 失败')
                          .fontSize(this.isElderMode ? 11 : 10)
                          .fontColor('#FF4D4F');
                      }
                    }

                    if (device.type !== 'other' && device.isOnline) {
                      Row({ space: 8 }) {
                        if (device.batteryLevel > 0) {
                          Text(`🔋 ${device.batteryLevel}%`)
                            .fontSize(10)
                            .fontColor('#666666');
                        }

                        Text(`📶 ${device.signalStrength}%`)
                          .fontSize(10)
                          .fontColor('#666666');
                      }
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);

                  Column({ space: 8 }) {
                    Button('详情')
                      .width(60)
                      .height(30)
                      .fontSize(12)
                      .fontColor('#1677FF')
                      .backgroundColor('#FFFFFF')
                      .border({ width: 1, color: '#1677FF' })
                      .borderRadius(15)
                      .onClick(() => {
                        this.openDeviceDetail(device);
                      });

                    if (device.isOnline) {
                      Button('同步')
                        .width(60)
                        .height(30)
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#1677FF')
                        .borderRadius(15)
                        .onClick(() => {
                          this.triggerSync(device.id);
                        });
                    }
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })
                .border({ width: device.isOnline ? 1.5 : 1, color: device.isOnline ? '#91D5FF50' : '#F0F0F0' });
              }, (device: HarmonyDevice) => device.id);
            }
            .width('100%')
            .padding(16);
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#F5F7FA');
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      } else if (this.currentTab === 1) {
        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 16 }) {
              Text('🔄 数据同步设置')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight('bold')
                .fontColor('#333333');

              Column({ space: 12 }) {
                Row() {
                  Text('总开关')
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontColor('#333333')
                    .layoutWeight(1);

                  Toggle({ type: ToggleType.Switch, isOn: this.syncEnabled })
                    .onChange((isOn: boolean) => {
                      this.syncEnabled = isOn;
                      ToastUtil.showInfo(isOn ? '同步功能已开启' : '同步功能已关闭');
                    });
                }
                .width('100%');

                Divider().color('#F0F0F0');

                Row() {
                  Column({ space: 4 }) {
                    Text('健康数据同步')
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontColor('#333333');

                    Text('血压、血糖、心率、步数等')
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1);

                  Toggle({ type: ToggleType.Switch, isOn: this.healthDataSync && this.syncEnabled })
                    .enabled(this.syncEnabled)
                    .onChange((isOn: boolean) => {
                      this.healthDataSync = isOn;
                    });
                }
                .width('100%');

                Divider().color('#F0F0F0');

                Row() {
                  Column({ space: 4 }) {
                    Text('用药记录同步')
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontColor('#333333');

                    Text('用药计划、服药记录')
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1);

                  Toggle({ type: ToggleType.Switch, isOn: this.medicationSync && this.syncEnabled })
                    .enabled(this.syncEnabled)
                    .onChange((isOn: boolean) => {
                      this.medicationSync = isOn;
                    });
                }
                .width('100%');

                Divider().color('#F0F0F0');

                Row() {
                  Column({ space: 4 }) {
                    Text('预约信息同步')
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontColor('#333333');

                    Text('医疗预约、就诊记录')
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1);

                  Toggle({ type: ToggleType.Switch, isOn: this.appointmentSync && this.syncEnabled })
                    .enabled(this.syncEnabled)
                    .onChange((isOn: boolean) => {
                      this.appointmentSync = isOn;
                    });
                }
                .width('100%');
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12);
            }
            .width('100%')
            .padding({ left: 16, right: 16 });

            Column({ space: 12 }) {
              Row({ space: 8 }) {
                Text('📋 同步日志')
                  .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor('#333333');

                Blank();

                Button('重试失败项')
                  .height(28)
                  .fontSize(12)
                  .fontColor('#1677FF')
                  .backgroundColor('#FFFFFF')
                  .border({ width: 1, color: '#1677FF' })
                  .borderRadius(14)
                  .onClick(() => {
                    this.retryFailedSync();
                  });
              }
              .width('100%');

              ForEach(this.syncLogs.slice(0, 10), (log: SyncLogItem) => {
                Row({ space: 12 }) {
                  Column() {
                    Text(log.status === 'success' ? '✅' : '❌')
                      .fontSize(20);
                  }
                  .width(40)
                  .height(40)
                  .backgroundColor(log.status === 'success' ? '#F6FFED' : '#FFF1F0')
                  .borderRadius(20)
                  .justifyContent(FlexAlign.Center);

                  Column({ space: 4 }) {
                    Row({ space: 8 }) {
                      Text(log.deviceName)
                        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                        .fontWeight('bold')
                        .fontColor('#333333');

                      Text(log.action)
                        .fontSize(12)
                        .fontColor('#1677FF')
                        .backgroundColor('#E6F7FF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(8);
                    }

                    Text(`${log.dataType} · ${log.detail}`)
                      .fontSize(11)
                      .fontColor('#666666')
                      .maxLines(1);

                    Text(log.timestamp)
                      .fontSize(10)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(8);
              }, (log: SyncLogItem) => log.id);
            }
            .width('100%')
            .padding(16);
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#F5F7FA');
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 12 }) {
              Text('🔗 跨设备协同示例')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              Text('体验鸿蒙分布式能力，多设备无缝协作')
                .fontSize(13)
                .fontColor('#666666')
                .width('100%');

              ForEach(this.collaborationExamples, (example: CollaborationExample) => {
                Column({ space: 12 }) {
                  Row({ space: 12 }) {
                    Text(example.icon)
                      .fontSize(28);

                    Column({ space: 4 }) {
                      Text(example.title)
                        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                        .fontWeight('bold')
                        .fontColor('#333333');

                      Text(example.description)
                        .fontSize(12)
                        .fontColor('#666666');
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start);

                    if (example.status === 'ready') {
                      Text('准备就绪')
                        .fontSize(11)
                        .fontColor('#52C41A')
                        .backgroundColor('#F6FFED')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .borderRadius(10);
                    } else if (example.status === 'active') {
                      Text('运行中')
                        .fontSize(11)
                        .fontColor('#1677FF')
                        .backgroundColor('#E6F7FF')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .borderRadius(10);
                    } else if (example.status === 'alert') {
                      Text('预警模式')
                        .fontSize(11)
                        .fontColor('#FF4D4F')
                        .backgroundColor('#FFF1F0')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .borderRadius(10);
                    } else {
                      Text('待激活')
                        .fontSize(11)
                        .fontColor('#999999')
                        .backgroundColor('#F5F5F5')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .borderRadius(10);
                    }
                  }
                  .width('100%');

                  Row({ space: 8 }) {
                    Text(example.fromDevice)
                      .fontSize(13)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#1677FF')
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .borderRadius(8);

                    Text('→')
                      .fontSize(18)
                      .fontColor('#1677FF');

                    Text(example.toDevice)
                      .fontSize(13)
                      .fontColor('#1677FF')
                      .backgroundColor('#E6F7FF')
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .borderRadius(8);
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center);

                  Button(example.status === 'pending' ? '启用此功能' : '查看详情')
                    .width('100%')
                    .height(40)
                    .fontSize(14)
                    .fontColor(example.status === 'pending' ? '#FFFFFF' : '#1677FF')
                    .backgroundColor(example.status === 'pending' ? '#1677FF' : '#FFFFFF')
                    .border({ width: example.status === 'pending' ? 0 : 1, color: '#1677FF' })
                    .borderRadius(20)
                    .onClick(() => {
                      if (example.status === 'pending') {
                        ToastUtil.showInfo('功能开发中，敬请期待！');
                      } else {
                        ToastUtil.showInfo('演示模式：跨设备协同正常工作');
                      }
                    });
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 8, color: '#00000006', offsetX: 0, offsetY: 2 });
              }, (example: CollaborationExample) => example.id);
            }
            .width('100%')
            .padding(16);

            Column({ space: 12 }) {
              Text('💡 分布式技术说明')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              ForEach([
                { title: '分布式软总线', desc: '自动发现和连接附近的鸿蒙设备，无需配对' },
                { title: '分布式数据管理', desc: '多设备间数据自动同步，保持一致性' },
                { title: '分布式任务调度', desc: '任务可在任意设备上无缝流转执行' },
                { title: '硬件能力互助', desc: '调用其他设备的摄像头、传感器等能力' }
              ], (item: Record<string, string>) => {
                Row({ space: 12 }) {
                  Text('✨')
                    .fontSize(20);

                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(14)
                      .fontWeight('bold')
                      .fontColor('#333333');

                    Text(item.desc)
                      .fontSize(12)
                      .fontColor('#666666');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FAFBFC')
                .borderRadius(8);
              }, (item: Record<string, string>) => item.title);
            }
            .width('100%')
            .padding(16);
          }
          .width('100%')
          .height('100%')
          .backgroundColor('#F5F7FA');
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');

    if (this.showAddDeviceDialog) {
      Column() {
        Blank();

        Column({ space: 16 }) {
          Row() {
            Text('添加新设备')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .layoutWeight(1);

            Text('✕')
              .fontSize(20)
              .fontColor('#999999')
              .onClick(() => {
                this.showAddDeviceDialog = false;
              });
          }
          .width('100%');

          Column({ space: 12 }) {
            if (this.isScanning) {
              Column({ space: 12 }) {
                Text('🔍 正在扫描附近的鸿蒙设备...')
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .textAlign(TextAlign.Center);

                LoadingProgress()
                  .width(48)
                  .height(48)
                  .color('#1677FF');
              }
              .width('100%')
              .padding(24)
              .backgroundColor('#E6F7FF')
              .borderRadius(12);
            } else if (this.discoveredDevices.length > 0) {
              Text(`发现 ${this.discoveredDevices.length} 台设备`)
                .fontSize(14)
                .fontColor('#666666')
                .width('100%');

              ForEach(this.discoveredDevices, (device: DiscoveredDevice) => {
                Row({ space: 12 }) {
                  Text(device.icon)
                    .fontSize(28);

                  Column({ space: 4 }) {
                    Text(device.name)
                      .fontSize(14)
                      .fontWeight('bold')
                      .fontColor('#333333');

                    Row({ space: 8 }) {
                      Text(device.type)
                        .fontSize(11)
                        .fontColor('#1677FF')
                        .backgroundColor('#E6F7FF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(6);

                      Text(device.distance)
                        .fontSize(11)
                        .fontColor('#999999');
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);

                  Button('绑定')
                    .height(32)
                    .fontSize(13)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#1677FF')
                    .borderRadius(16)
                    .onClick(() => {
                      this.bindDevice(device);
                    });
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#F9F9F9')
                .borderRadius(8)
                .border({ width: 1, color: '#F0F0F0' });
              }, (device: DiscoveredDevice) => device.id);
            } else {
              Column({ space: 12 }) {
                Text('未发现新设备')
                  .fontSize(14)
                  .fontColor('#999999');

                Text('请确保目标设备：\n• 已开启蓝牙\n• 已连接同一网络\n• 已登录同一华为账号')
                  .fontSize(12)
                  .fontColor('#666666')
                  .textAlign(TextAlign.Center)
                  .lineHeight(18);
              }
              .width('100%')
              .padding(24)
              .backgroundColor('#F5F5F5')
              .borderRadius(12);
            }

            Button(this.isScanning ? '扫描中...' : '重新扫描')
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontColor(this.isScanning ? '#999999' : '#1677FF')
              .backgroundColor(this.isScanning ? '#F5F5F5' : '#FFFFFF')
              .border({ width: 1, color: this.isScanning ? '#E0E0E0' : '#1677FF' })
              .borderRadius(22)
              .enabled(!this.isScanning)
              .onClick(() => {
                this.startScanDevices();
              });
          }
          .width('100%');
        }
        .width('85%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 20, color: '#00000025', offsetX: 0, offsetY: 8 });

        Blank();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000050')
      .justifyContent(FlexAlign.Center);
    }

    if (this.showDeviceDetail && this.selectedDevice !== undefined) {
      Column() {
        Blank();

        Scroll() {
          Column({ space: 16 }) {
            Row() {
              Text('设备详情')
                .fontSize(18)
                .fontWeight('bold')
                .fontColor('#333333')
                .layoutWeight(1);

              Text('✕')
                .fontSize(20)
                .fontColor('#999999')
                .onClick(() => {
                  this.showDeviceDetail = false;
                });
            }
            .width('100%');

            Column({ space: 16 }) {
              Stack({ alignContent: Alignment.BottomEnd }) {
                Column() {
                  Text(this.selectedDevice!.icon)
                    .fontSize(48);
                }
                .width(80)
                .height(80)
                .backgroundColor(this.selectedDevice!.isOnline ? '#E6F7FF' : '#F5F5F5')
                .borderRadius(20)
                .justifyContent(FlexAlign.Center);

                Circle()
                  .width(14)
                  .height(14)
                  .fill(this.selectedDevice!.isOnline ? '#52C41A' : '#D9D9D9')
                  .border({ width: 2, color: '#FFFFFF' });
              }
              .width(80)
              .height(80)
              .alignSelf(ItemAlign.Center);

              Text(this.selectedDevice!.name)
                .fontSize(18)
                .fontWeight('bold')
                .fontColor('#333333')
                .textAlign(TextAlign.Center)
                .width('100%');

              Text(this.selectedDevice!.isOnline ? '● 在线' : '○ 离线')
                .fontSize(14)
                .fontColor(this.selectedDevice!.isOnline ? '#52C41A' : '#999999')
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFBFC')
            .borderRadius(12);

            Column({ space: 12 }) {
              Text('📋 基本信息')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              ForEach([
                { label: '设备型号', value: this.selectedDevice!.model },
                { label: '系统版本', value: this.selectedDevice!.version },
                { label: '绑定日期', value: this.selectedDevice!.bindDate },
                { label: '设备ID', value: this.selectedDevice!.id }
              ], (info: Record<string, string>) => {
                Row() {
                  Text(info.label)
                    .fontSize(13)
                    .fontColor('#666666')
                    .width(80);

                  Text(info.value)
                    .fontSize(13)
                    .fontColor('#333333')
                    .layoutWeight(1)
                    .textAlign(TextAlign.End);
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 });
              }, (info: Record<string, string>) => info.label);

              Divider().color('#F0F0F0').width('100%');

              if (this.selectedDevice!.type !== 'other' && this.selectedDevice!.isOnline) {
                ForEach([
                  { label: '电池电量', value: `🔋 ${this.selectedDevice!.batteryLevel}%` },
                  { label: '信号强度', value: `📶 ${this.selectedDevice!.signalStrength}%` }
                ], (status: Record<string, string>) => {
                  Row() {
                    Text(status.label)
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(80);

                    Text(status.value)
                      .fontSize(13)
                      .fontColor('#333333')
                      .layoutWeight(1)
                      .textAlign(TextAlign.End);
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 });
                }, (status: Record<string, string>) => status.label);
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            Column({ space: 12 }) {
              Text('⚙️ 同步设置')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              Row() {
                Text('自动同步')
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1);

                Toggle({ type: ToggleType.Switch, isOn: true });
              }
              .width('100%');

              if (this.selectedDevice!.lastSyncTime) {
                Row() {
                  Text('最后同步时间')
                    .fontSize(13)
                    .fontColor('#666666')
                    .layoutWeight(1);

                  Text(this.getRelativeTime(this.selectedDevice!.lastSyncTime!))
                    .fontSize(13)
                    .fontColor('#333333');
                }
                .width('100%');
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            Column({ space: 12 }) {
              Text('📜 最近日志')
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              ForEach(
                this.syncLogs.filter((l: SyncLogItem) => l.deviceId === this.selectedDevice!.id).slice(0, 5),
                (log: SyncLogItem) => {
                  Row({ space: 8 }) {
                    Text(log.status === 'success' ? '✅' : '❌')
                      .fontSize(14);

                    Column({ space: 2 }) {
                      Text(`${log.action} - ${log.dataType}`)
                        .fontSize(12)
                        .fontColor('#333333');

                      Text(`${log.detail} (${log.timestamp})`)
                        .fontSize(11)
                        .fontColor('#999999');
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start);
                  }
                  .width('100%')
                  .padding(8)
                  .backgroundColor('#F9F9F9')
                  .borderRadius(6);
                },
                (log: SyncLogItem) => log.id
              );
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            Column({ space: 12 }) {
              Button('立即同步')
                .width('100%')
                .height(44)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(22)
                .enabled(this.selectedDevice!.isOnline)
                .onClick(() => {
                  this.triggerSync(this.selectedDevice!.id);
                  this.showDeviceDetail = false;
                });

              Button('解除绑定')
                .width('100%')
                .height(44)
                .fontSize(15)
                .fontColor('#FF4D4F')
                .backgroundColor('#FFFFFF')
                .border({ width: 1, color: '#FF4D4F' })
                .borderRadius(22)
                .onClick(() => {
                  this.showUnbindConfirm = true;
                });
            }
            .width('100%');
          }
          .width('100%')
          .padding(20);
        }
        .width('85%')
        .height('80%')
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 20, color: '#00000025', offsetX: 0, offsetY: 8 });

        Blank();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000050')
      .justifyContent(FlexAlign.Center);
    }

    if (this.showUnbindConfirm) {
      Column() {
        Blank();

        Column({ space: 20 }) {
          Text('⚠️ 确认解绑')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Center);

          Column({ space: 8 }) {
            Text('确定要解除与该设备的绑定吗？')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .width('100%');

            Text('解绑后，该设备将无法同步您的健康数据')
              .fontSize(12)
              .fontColor('#FF4D4F')
              .textAlign(TextAlign.Center)
              .width('100%');
          }
          .width('100%');

          Row({ space: 12 }) {
            Button('取消')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .borderRadius(22)
              .onClick(() => {
                this.showUnbindConfirm = false;
              });

            Button('确认解绑')
              .layoutWeight(1)
              .height(44)
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF4D4F')
              .borderRadius(22)
              .onClick(() => {
                if (this.selectedDevice !== undefined) {
                  this.unbindDevice(this.selectedDevice.id);
                }
              });
          }
          .width('100%');
        }
        .width('75%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 20, color: '#00000025', offsetX: 0, offsetY: 8 });

        Blank();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#00000050')
      .justifyContent(FlexAlign.Center);
    }
    }
  }
}

interface CollaborationExample {
  id: string;
  title: string;
  description: string;
  fromDevice: string;
  toDevice: string;
  status: 'ready' | 'active' | 'alert' | 'pending';
  icon: string;
}
