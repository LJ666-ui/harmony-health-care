import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface BleDevice {
  id: string;
  name: string;
  icon: string;
  type: string;
  signal: string;
  isConnected: boolean;
}

@Entry
@Component
struct DeviceDiscoveryPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State devices: BleDevice[] = [
    { id: '1', name: '华为手环 8', icon: '⌚', type: '智能手环', signal: '信号强', isConnected: true },
    { id: '2', name: '欧姆龙血压计', icon: '🩺', type: '血压监测仪', signal: '信号强', isConnected: false },
    { id: '3', name: '鱼跃血糖仪', icon: '💉', type: '血糖监测仪', signal: '信号中', isConnected: false },
    { id: '4', name: '小米体脂秤', icon: '⚖️', type: '体重秤', signal: '信号强', isConnected: true },
    { id: '5', name: '飞利浦血氧仪', icon: '🩸', type: '血氧监测仪', signal: '信号弱', isConnected: false },
    { id: '6', name: '欧姆龙体温计', icon: '🌡️', type: '体温计', signal: '信号强', isConnected: true },
    { id: '7', name: '乐心睡眠监测器', icon: '😴', type: '睡眠监测器', signal: '信号中', isConnected: false },
    { id: '8', name: '九安心电仪', icon: '❤️', type: '心电图机', signal: '信号弱', isConnected: false }
  ];

  @State isScanning: boolean = false;
  @State isRefreshing: boolean = false;

  handleRefresh(): void {
    this.isRefreshing = true;

    setTimeout(() => {
      this.isRefreshing = false;

      ToastUtil.refreshSuccess();
    }, 1500);
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  getConnectedCount(): number {
    let count: number = 0;
    for (let i: number = 0; i < this.devices.length; i++) {
      if (this.devices[i].isConnected) {
        count++;
      }
    }
    return count;
  }

  toggleDevice(deviceId: string): void {
    const newDevices: BleDevice[] = [];
    for (let i: number = 0; i < this.devices.length; i++) {
      const device: BleDevice = this.devices[i];
      if (device.id === deviceId) {
        newDevices.push({ id: device.id, name: device.name, icon: device.icon, type: device.type, signal: device.signal, isConnected: !device.isConnected });
      } else {
        newDevices.push(device);
      }
    }
    this.devices = newDevices;
  }

  handleRescan(): void {
    this.isScanning = true;
    const resetDevices: BleDevice[] = [];
    for (let i: number = 0; i < this.devices.length; i++) {
      const device: BleDevice = this.devices[i];
      resetDevices.push({ id: device.id, name: device.name, icon: device.icon, type: device.type, signal: device.signal, isConnected: false });
    }
    this.devices = resetDevices;
    setTimeout(() => {
      this.isScanning = false;
    }, 1500);
  }

  build() {
    Column() {
      Header({ title: '设备绑定', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Column({
            space: GlobalTheme.getSpacingSM(this.isElderMode)
          }) {
            Text('附近设备')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ bottom: GlobalTheme.getSpacingXS(this.isElderMode) });

            Text('请选择要绑定的健康设备，点击按钮切换连接状态')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY);
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start);

          Row() {
            Button(this.isScanning ? '🔍 扫描中...' : '🔍 重新扫描')
              .height(this.isElderMode ? 44 : 38)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(this.isScanning ? GlobalTheme.THEME_COLOR : '#FFFFFF')
              .backgroundColor(this.isScanning ? GlobalTheme.THEME_COLOR + '15' : GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_LG)
              .border(this.isScanning ? { width: 1, color: GlobalTheme.THEME_COLOR } : { width: 0 })
              .onClick(() => this.handleRescan());

            Text('已发现 ' + this.devices.length + ' 台')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_HINT)
              .margin({ left: GlobalTheme.getSpacingSM(this.isElderMode) });

            Blank();

            Text(this.getConnectedCount() + '/' + this.devices.length + ' 已连接')
              .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
              .fontColor(GlobalTheme.SUCCESS_COLOR)
              .backgroundColor('#F6FFED')
              .padding({ left: GlobalTheme.getSpacingSM(this.isElderMode), right: GlobalTheme.getSpacingSM(this.isElderMode), top: GlobalTheme.getSpacingXS(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) })
              .borderRadius(GlobalTheme.RADIUS_MD)
              .border({ width: 1, color: '#B7EB8F' });
          }
          .width('100%')
          .padding({ left: GlobalTheme.getSpacingXS(this.isElderMode), right: GlobalTheme.getSpacingXS(this.isElderMode) });

          List({
            space: GlobalTheme.getSpacingMD(this.isElderMode)
          }) {
            ForEach(this.devices, (device: BleDevice) => {
              ListItem() {
                Row({
                  space: GlobalTheme.getSpacingMD(this.isElderMode)
                }) {
                  Column({
                    space: GlobalTheme.getSpacingXS(this.isElderMode)
                  }) {
                    Text(device.icon)
                      .fontSize(36);

                    Text(device.signal)
                      .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                      .fontColor(device.signal === '信号强' ? GlobalTheme.SUCCESS_COLOR : GlobalTheme.WARNING_COLOR);
                  }
                  .width(64)
                  .height(64)
                  .backgroundColor(device.isConnected ? '#F6FFED' : GlobalTheme.THEME_COLOR + '15')
                  .borderRadius(GlobalTheme.RADIUS_LG)
                  .justifyContent(FlexAlign.Center)
                  .border(device.isConnected ? { width: 1.5, color: GlobalTheme.SUCCESS_COLOR } : { width: 1, color: GlobalTheme.BORDER_COLOR });

                  Column({
                    space: GlobalTheme.getSpacingXS(this.isElderMode)
                  }) {
                    Text(device.name)
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontWeight('bold')
                      .fontColor(GlobalTheme.TEXT_PRIMARY)
                      .maxLines(1);

                    Row({
                      space: GlobalTheme.getSpacingSM(this.isElderMode)
                    }) {
                      Text(device.type)
                        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                        .fontColor(GlobalTheme.THEME_COLOR)
                        .backgroundColor(GlobalTheme.THEME_COLOR + '15')
                        .padding({ left: GlobalTheme.getSpacingSM(this.isElderMode), right: GlobalTheme.getSpacingSM(this.isElderMode), top: GlobalTheme.getSpacingXS(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) })
                        .borderRadius(GlobalTheme.RADIUS_SM);

                      if (device.isConnected) {
                        Text('● 已连接')
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.SUCCESS_COLOR)
                          .fontWeight('bold');
                      } else {
                        Text('未连接')
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.TEXT_HINT);
                      }
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);

                  Button(device.isConnected ? '断开' : '连接')
                    .width(this.isElderMode ? 76 : 68)
                    .height(this.isElderMode ? 38 : 34)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(device.isConnected ? GlobalTheme.ERROR_COLOR : '#FFFFFF')
                    .backgroundColor(device.isConnected ? '#FFF1F0' : GlobalTheme.THEME_COLOR)
                    .borderRadius(GlobalTheme.RADIUS_LG)
                    .border(device.isConnected ? { width: 1, color: '#FFCCC7' } : { width: 0 })
                    .onClick(() => this.toggleDevice(device.id));
                }
                .width('100%')
                .padding(GlobalTheme.getSpacingMD(this.isElderMode))
                .backgroundColor(GlobalTheme.CARD_BG)
                .borderRadius(GlobalTheme.RADIUS_MD)
                .border({
                  width: device.isConnected ? 1.5 : 1,
                  color: device.isConnected ? GlobalTheme.SUCCESS_COLOR + '50' : GlobalTheme.BORDER_COLOR
                })
                .shadow(device.isConnected ? {
                  radius: 8,
                  color: GlobalTheme.SUCCESS_COLOR + '18',
                  offsetX: 0,
                  offsetY: 2
                } : undefined);
              }
            }, (device: BleDevice) => device.id);
          }
          .width('100%')
          .layoutWeight(1);
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) * 2 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
