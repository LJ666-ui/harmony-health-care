/**
 * 智慧病房设备控制页面
 * 提供病房设备的统一控制管理功能
 */

import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { DeviceManager } from '../core/DeviceManager';
import { DeviceType } from '../models/SmartWardEnums';
import { DeviceInfo } from '../models/SmartWardDeviceModels';

@Entry
@Component
struct SmartWardDevices {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State deviceCount: number = 0;
  @State devices: DeviceInfo[] = [];
  @State isLoading: boolean = true;
  @State selectedDevice: DeviceStatus | null = null;

  private deviceManager = DeviceManager.getInstance();

  aboutToAppear(): void {
    this.loadDevices();
  }

  loadDevices(): void {
    this.isLoading = true;
    // 模拟加载设备数据
    setTimeout(() => {
      this.devices = this.deviceManager.getAllDevices();
      this.deviceCount = this.devices.length;
      this.isLoading = false;
    }, 500);
  }

  handleBack(): void {
    router.back();
  }

  getDeviceIcon(deviceType: DeviceType): string {
    const iconMap: Record<DeviceType, string> = {
      [DeviceType.HOSPITAL_BED]: '🛏️',
      [DeviceType.PATIENT_MONITOR]: '💓',
      [DeviceType.SMART_LIGHT]: '💡',
      [DeviceType.SMART_CURTAIN]: '🪟',
      [DeviceType.SMART_TV]: '📺',
      [DeviceType.AIR_CONDITIONER]: '❄️',
      [DeviceType.CALL_BUTTON]: '🔔',
      [DeviceType.INFUSION_PUMP]: '💉'
    };
    return iconMap[deviceType] || '📱';
  }

  getDeviceTypeName(deviceType: DeviceType): string {
    const nameMap: Record<DeviceType, string> = {
      [DeviceType.HOSPITAL_BED]: '智能病床',
      [DeviceType.PATIENT_MONITOR]: '患者监护仪',
      [DeviceType.SMART_LIGHT]: '智能灯光',
      [DeviceType.SMART_CURTAIN]: '智能窗帘',
      [DeviceType.SMART_TV]: '智能电视',
      [DeviceType.AIR_CONDITIONER]: '空调',
      [DeviceType.CALL_BUTTON]: '呼叫按钮',
      [DeviceType.INFUSION_PUMP]: '输液泵'
    };
    return nameMap[deviceType] || '未知设备';
  }

  build() {
    Column() {
      Header({ title: '病房设备', showBack: true, onBack: () => this.handleBack() });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 设备统计
            Row() {
              Text(`设备总数: ${this.deviceCount}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ right: 20 })
              
              Text(`在线: ${this.devices.filter(d => d.status === 'online').length}`)
                .fontSize(14)
                .fontColor('#4CAF50')
            }
            .width('100%')
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)

            // 设备列表
            Column() {
              ForEach(this.devices, (device: DeviceInfo) => {
                Row() {
                  Text(this.getDeviceIcon(device.deviceType))
                    .fontSize(24)
                    .margin({ right: 12 })

                  Column() {
                    Text(device.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)

                    Text(this.getDeviceTypeName(device.deviceType))
                      .fontSize(12)
                      .fontColor('#666')
                      .margin({ top: 4 })

                    Text(`设备ID: ${device.deviceId}`)
                      .fontSize(10)
                      .fontColor('#999')
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text(device.status === 'online' ? '在线' : '离线')
                    .fontSize(12)
                    .fontColor(device.status === 'online' ? '#4CAF50' : '#F44336')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(device.status === 'online' ? '#E8F5E9' : '#FFEBEE')
                    .borderRadius(4)
                }
                .width('100%')
                .padding(15)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({ bottom: 10 })
                .shadow({ radius: 2, color: '#00000010' })
              })
            }
          }
          .padding(15)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
