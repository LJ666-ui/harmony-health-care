import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';

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
  @State devices: BleDevice[] = [
    { id: '1', name: '华为 WATCH GT5 Pro', icon: '⌚', type: '智能手表', signal: '信号强', isConnected: false },
    { id: '2', name: '欧姆龙智能血压计 J760', icon: '🩺', type: '血压计', signal: '信号强', isConnected: false },
    { id: '3', name: '云康宝体脂秤 CS20A', icon: '⚖️', type: '体脂秤', signal: '信号中', isConnected: false }
  ];

  @State isScanning: boolean = false;

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
        Column({ space: 16 }) {
          Column({
            space: 12
          }) {
            Text('附近设备')
              .fontSize(20)
              .fontWeight('bold')
              .fontColor('#1677FF')
              .margin({ bottom: 4 });

            Text('请选择要绑定的健康设备，点击按钮切换连接状态')
              .fontSize(13)
              .fontColor('#888888');
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start);

          Row() {
            Button(this.isScanning ? '🔍 扫描中...' : '🔍 重新扫描')
              .height(38)
              .fontSize(14)
              .fontColor(this.isScanning ? '#1677FF' : '#FFFFFF')
              .backgroundColor(this.isScanning ? '#F0F5FF' : '#1677FF')
              .borderRadius(19)
              .border(this.isScanning ? { width: 1, color: '#1677FF' } : { width: 0 })
              .onClick(() => this.handleRescan());

            Text('已发现 ' + this.devices.length + ' 台')
              .fontSize(13)
              .fontColor('#999999')
              .margin({ left: 8 });

            Blank();

            Text(this.getConnectedCount() + '/' + this.devices.length + ' 已连接')
              .fontSize(12)
              .fontColor('#52C41A')
              .backgroundColor('#F6FFED')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(10)
              .border({ width: 1, color: '#B7EB8F' });
          }
          .width('100%')
          .padding({ left: 4, right: 4 });

          List({
            space: 12
          }) {
            ForEach(this.devices, (device: BleDevice) => {
              ListItem() {
                Row({
                  space: 14
                }) {
                  Column({
                    space: 4
                  }) {
                    Text(device.icon)
                      .fontSize(36);

                    Text(device.signal)
                      .fontSize(10)
                      .fontColor(device.signal === '信号强' ? '#52C41A' : '#FAAD14');
                  }
                  .width(64)
                  .height(64)
                  .backgroundColor(device.isConnected ? '#F6FFED' : '#F0F5FF')
                  .borderRadius(12)
                  .justifyContent(FlexAlign.Center)
                  .border(device.isConnected ? { width: 1.5, color: '#52C41A' } : { width: 1, color: '#E8E8E8' });

                  Column({
                    space: 6
                  }) {
                    Text(device.name)
                      .fontSize(16)
                      .fontWeight('bold')
                      .fontColor('#333333')
                      .maxLines(1);

                    Row({
                      space: 8
                    }) {
                      Text(device.type)
                        .fontSize(12)
                        .fontColor('#1677FF')
                        .backgroundColor('#1677FF10')
                        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                        .borderRadius(4);

                      if (device.isConnected) {
                        Text('● 已连接')
                          .fontSize(12)
                          .fontColor('#52C41A')
                          .fontWeight('bold');
                      } else {
                        Text('未连接')
                          .fontSize(12)
                          .fontColor('#999999');
                      }
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);

                  Button(device.isConnected ? '断开' : '连接')
                    .width(68)
                    .height(34)
                    .fontSize(13)
                    .fontColor(device.isConnected ? '#FF4D4F' : '#FFFFFF')
                    .backgroundColor(device.isConnected ? '#FFF1F0' : '#1677FF')
                    .borderRadius(17)
                    .border(device.isConnected ? { width: 1, color: '#FFCCC7' } : { width: 0 })
                    .onClick(() => this.toggleDevice(device.id));
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .border({
                  width: device.isConnected ? 1.5 : 1,
                  color: device.isConnected ? '#52C41A50' : '#F0F0F0'
                })
                .shadow(device.isConnected ? {
                  radius: 8,
                  color: '#52C41A15',
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
        .padding({ top: 20, bottom: 32 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
