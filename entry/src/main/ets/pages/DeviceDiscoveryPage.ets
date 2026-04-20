import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';
import RdbHelper from '../utils/RdbHelper';
import {
  TABLE_DEVICE_CACHE,
  COLUMN_DEVICE_ID,
  COLUMN_DEVICE_NAME,
  COLUMN_DEVICE_TYPE,
  COLUMN_DEVICE_MODEL,
  COLUMN_PAIRED,
  COLUMN_LAST_CONNECT_TIME,
  COLUMN_DATA_PERMISSION,
  COLUMN_PERMISSION_TYPES,
  COLUMN_SIGNAL_STRENGTH,
  COLUMN_DISTANCE
} from '../utils/DatabaseConstants';
import relationalStore from '@ohos.data.relationalStore';

export interface DeviceInfo {
  id: string;
  deviceId: string;
  deviceName: string;
  deviceType: string;
  deviceModel: string;
  isOnline: boolean;
  signalStrength: number;
  distance: number;
  rssi: number;
  bindTime: string | null;
}

@Entry
@Component
struct DeviceDiscoveryPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State devices: DeviceInfo[] = [];
  @State isScanning: boolean = false;
  @State isLoading: boolean = false;

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    BrowseTracker.recordStart('DEVICE_DISCOVER', 'PAGE', 3, '\u8BBE\u5907\u53D1\u73B0').then(id => {
      this.recordId = id;
    });

    this.discoverDevices();
  }

  aboutToDisappear(): void {
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async discoverDevices(): Promise<void> {
    this.isScanning = true;
    this.isLoading = true;

    try {
      const response: BaseResponse<DeviceInfo[]> = await HttpUtil.get<DeviceInfo[]>(ApiConstants.DEVICE_DISCOVER);

      if (response.success && response.data) {
        const list: DeviceInfo[] = response.data;
        this.devices = [];

        for (let i = 0; i < list.length; i++) {
          const item: DeviceInfo = list[i];
          const device: DeviceInfo = {
            id: item.deviceId ? item.deviceId : String(item.id),
            deviceId: item.deviceId ? item.deviceId : String(item.id),
            deviceName: item.deviceName ? item.deviceName : '未知设备',
            deviceType: item.deviceType ? item.deviceType : '健身设备',
            deviceModel: item.deviceModel ? item.deviceModel : '',
            isOnline: item.isOnline !== undefined ? item.isOnline : true,
            signalStrength: item.signalStrength ? item.signalStrength : 80,
            distance: item.distance !== undefined ? item.distance : 0,
            rssi: item.rssi !== undefined ? item.rssi : -60,
            bindTime: item.bindTime
          };
          this.devices.push(device);
        }
      }
    } catch (e) {
      console.error('发现设备失败:', e);
      ToastUtil.showSuccess('连接失败，请检查网络');
    } finally {
      this.isScanning = false;
      this.isLoading = false;
    }
  }

  async handleBind(device: DeviceInfo): Promise<void> {
    try {
      const bindData: Record<string, Object> = {};
      bindData['deviceId'] = device.deviceId;
      bindData['deviceName'] = device.deviceName;
      bindData['deviceType'] = device.deviceType;
      bindData['deviceModel'] = device.deviceModel;

      const response: BaseResponse<Object> = await HttpUtil.post<Object>(ApiConstants.DEVICE_BIND, bindData);

      if (response.success) {
        ToastUtil.showSuccess('设备绑定成功');

        const cacheValues: relationalStore.ValuesBucket = {};
        cacheValues[COLUMN_DEVICE_ID] = device.deviceId;
        cacheValues[COLUMN_DEVICE_NAME] = device.deviceName;
        cacheValues[COLUMN_DEVICE_TYPE] = device.deviceType;
        cacheValues[COLUMN_DEVICE_MODEL] = device.deviceModel;
        cacheValues[COLUMN_PAIRED] = 1;
        cacheValues[COLUMN_LAST_CONNECT_TIME] = Date.now();
        cacheValues[COLUMN_DATA_PERMISSION] = 'allowed';
        cacheValues[COLUMN_PERMISSION_TYPES] = JSON.stringify(['血压数据', '心率数据', '血氧数据']);
        cacheValues[COLUMN_SIGNAL_STRENGTH] = device.signalStrength;
        cacheValues[COLUMN_DISTANCE] = device.distance;

        try {
          await RdbHelper.insert(TABLE_DEVICE_CACHE, cacheValues);
          console.log('写入本地设备缓存成功, deviceId:', device.deviceId);
        } catch (dbError) {
          console.error('写入本地设备缓存失败:', dbError);
        }

        router.back();
      } else {
        ToastUtil.showSuccess(response.message ? response.message : '绑定失败');
      }
    } catch (e) {
      console.error('绑定设备失败:', e);
      ToastUtil.showSuccess('绑定失败，请检查网络');
    }
  }

  async handleUnbind(device: DeviceInfo): Promise<void> {
    try {
      const url: string = ApiConstants.DEVICE_UNBIND + '?deviceId=' + encodeURIComponent(device.deviceId);
      const response: BaseResponse<Object> = await HttpUtil.delete<Object>(url);

      if (response.success) {
        ToastUtil.showSuccess('\u89E3\u7ED1\u6210\u529F');

        const predicates = new relationalStore.RdbPredicates(TABLE_DEVICE_CACHE);
        predicates.equalTo(COLUMN_DEVICE_ID, device.deviceId);
        await RdbHelper.delete(predicates);
      } else {
        ToastUtil.showSuccess(response.message ? response.message : '\u89E3\u7ED1\u5931\u8D25');
      }
    } catch (e) {
      console.error('\u89E3\u7ED1\u8BBE\u5907\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u89E3\u7ED1\u5931\u8D25');
    }
  }

  getDeviceIcon(deviceType: string): string {
    const typeMap: Record<string, string> = {
      '\u667A\u80FD\u624B\u73AF': '\u{231A}',
      '\u8840\u538B\u76D1\u6D4B\u4EEA': '\u{1FA7A}',
      '\u8840\u7CD6\u76D1\u6D4B\u4EEA': '\uD83D\uDC89',
      '\u4F53\u91CD\u79C0': '\u2696',
      '\u8840\u6C27\u76D1\u6D4B\u4EEA': '\uD83D\uDCA5',
      '\u4F53\u6E29\u8BA1': '\u{1F921}',
      '\u7761\u7720\u76D1\u6D4B\u5668': '\uD83D\uDE34',
      '\u5FC3\u7535\u56FE\u673A': '\u2764',
      '\u5065\u5EBB\u8BBE\u5907': '\u{1F396}'
    };

    const typeKeys: string[] = Object.keys(typeMap);
    for (let k = 0; k < typeKeys.length; k++) {
      if (deviceType.indexOf(typeKeys[k]) >= 0) {
        return typeMap[typeKeys[k]];
      }
    }
    return '\u{1F4BB}';
  }

  getSignalText(signal: number): string {
    if (signal >= 80) return '\u4FE1\u53F7\u5F3A';
    if (signal >= 50) return '\u4FE1\u53F7\u4E2D';
    return '\u4FE1\u53F1\u5F31';
  }

  getSignalColor(signal: number): string {
    if (signal >= 80) return '#52C41A';
    if (signal >= 50) return '#FAAD14';
    return '#FF4D4F';
  }

  build() {
    Column() {
      Row() {
        Text('\u2190')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })
        Text('\u8BBE\u5907\u53D1\u73B0')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('').width(40)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Column({ space: 12 }) {
        Row({ space: 10 }) {
          Button(this.isScanning ? '\u{1F50D} \u626B\u63CF\u4E2D...' : '\u{1F50D} \u91CD\u65B0\u626B\u63CF')
            .height(38)
            .fontSize(14)
            .fontColor(this.isScanning ? '#1677FF' : '#FFFFFF')
            .backgroundColor(this.isScanning ? '#E6F4FF' : '#1677FF')
            .borderRadius(19)
            .onClick(() => {
              this.discoverDevices();
            });
          Blank();

          Text('\u5DF2\u53D1\u73B0 ' + this.devices.length + ' \u53F0')
            .fontSize(13)
            .fontColor('#999999')
            .backgroundColor('#F5F7FA')
            .padding({ left: 12, right: 12, top: 5, bottom: 5 })
            .borderRadius(12);
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          if (this.isLoading && this.devices.length === 0) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#1677FF');
              Text('\u6B63\u5728\u641C\u7D22\u9644\u8FD1\u8BBE\u5907...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 });
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center);
          } else if (this.devices.length === 0) {
            Column() {
              Text('\u{1F4BB}')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text('\u672A\u53D1\u73B0\u9644\u8FD1\u8BBE\u5907')
                .fontSize(15)
                .fontColor('#999999');
              Text('\u8BF7\u786E\u4FDD\u84DD\u7259/\u534E\u4E3AHiLink\u5DF2\u5F00\u542F')
                .fontSize(12)
                .fontColor('#BBBBBB')
                .margin({ top: 8 });
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center);
          } else {
            List({
              space: GlobalTheme.getSpacingMD(this.isElderMode)
            }) {
              ForEach(this.devices, (device: DeviceInfo) => {
                ListItem() {
                  Row({
                    space: GlobalTheme.getSpacingMD(this.isElderMode)
                  }) {
                    Column() {
                      Text(this.getDeviceIcon(device.deviceType))
                        .fontSize(36);
                    }
                    .width(64)
                    .height(64)
                    .backgroundColor(device.isOnline ? '#E6F7FF' : '#F5F5F5')
                    .borderRadius(GlobalTheme.RADIUS_LG)
                    .justifyContent(FlexAlign.Center)
                    .border({ width: 1, color: device.isOnline ? '#91D5FF' : '#D9D9D9' });

                    Column({
                      space: GlobalTheme.getSpacingXS(this.isElderMode)
                    }) {
                      Text(device.deviceName)
                        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)
                        .maxLines(1);

                      Row({
                        space: GlobalTheme.getSpacingSM(this.isElderMode)
                      }) {
                        Text(device.deviceType)
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.THEME_COLOR)
                          .backgroundColor(GlobalTheme.THEME_COLOR + '15')
                          .padding({ left: GlobalTheme.getSpacingSM(this.isElderMode), right: GlobalTheme.getSpacingSM(this.isElderMode), top: GlobalTheme.getSpacingXS(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) })
                          .borderRadius(GlobalTheme.RADIUS_SM);

                        if (device.deviceModel) {
                          Text(device.deviceModel)
                            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                            .fontColor('#666666')
                            .backgroundColor('#F5F5F5')
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .borderRadius(GlobalTheme.RADIUS_SM);
                        }

                        if (device.isOnline) {
                          Text('● 在线')
                            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                            .fontColor(GlobalTheme.SUCCESS_COLOR)
                            .fontWeight(FontWeight.Bold);
                        } else {
                          Text('离线')
                            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                            .fontColor(GlobalTheme.TEXT_HINT);
                        }
                      }

                      Row({
                        space: GlobalTheme.getSpacingSM(this.isElderMode)
                      }) {
                        if (device.distance > 0) {
                          Text('📍 ' + device.distance.toFixed(1) + 'm')
                            .fontSize(10)
                            .fontColor('#999999');
                        }

                        Text('📶 ' + this.getSignalText(device.signalStrength) + ' (' + device.signalStrength + '%)')
                          .fontSize(10)
                          .fontColor(this.getSignalColor(device.signalStrength));

                        if (device.rssi !== undefined && device.rssi !== 0) {
                          Text('RSSI: ' + device.rssi + ' dBm')
                            .fontSize(10)
                            .fontColor('#BBBBBB');
                        }
                      }
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start);

                    Column({
                      space: 6
                    }) {
                      Text(this.getSignalText(device.signalStrength))
                        .fontSize(11)
                        .fontColor(this.getSignalColor(device.signalStrength));

                      Button('\u7ED1\u5B9A')
                        .width(this.isElderMode ? 70 : 60)
                        .height(this.isElderMode ? 36 : 32)
                        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                        .fontColor('#FFFFFF')
                        .backgroundColor('#1677FF')
                        .borderRadius(GlobalTheme.RADIUS_LG)
                        .onClick(() => {
                          this.handleBind(device);
                        });
                    }
                  }
                  .width('100%')
                  .padding(GlobalTheme.getSpacingMD(this.isElderMode))
                  .backgroundColor(GlobalTheme.CARD_BG)
                  .borderRadius(GlobalTheme.RADIUS_MD)
                  .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
                  .border({ width: device.isOnline ? 1.5 : 1, color: device.isOnline ? '#91D5FF50' : GlobalTheme.BORDER_COLOR });
                }
              }, (device: DeviceInfo) => device.deviceId);
            }
            .width('100%')
            .layoutWeight(1);
          }
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