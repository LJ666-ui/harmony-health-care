import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';
import RdbHelper from '../utils/RdbHelper';
import {
  TABLE_DEVICE_CACHE,
  COLUMN_ID,
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

export interface BoundDevice {
  id: number;
  deviceId: string;
  deviceName: string;
  deviceType: string;
  deviceModel: string;
  isPaired: boolean;
  lastConnectTime: number;
  isOnline: boolean;
  syncStatus: 'success' | 'syncing' | 'failed' | 'pending';
  dataPermission: 'allowed' | 'denied';
  permissionTypes: string[];
  signalStrength: number;
  distance: number;
}

export interface SyncLogItem {
  id: string;
  deviceId: string;
  deviceName: string;
  action: string;
  dataType: string;
  timestamp: string;
  status: 'success' | 'failed';
  detail: string;
}

@Entry
@Component
struct DeviceManagePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentTab: number = 0;
  @State boundDevices: BoundDevice[] = [];
  @State syncLogs: SyncLogItem[] = [];
  @State isLoadingDevices: boolean = true;

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    BrowseTracker.recordStart('DEVICE_MANAGE', 'PAGE', 3, '\u8BBE\u5907\u7BA1\u7406').then(id => {
      this.recordId = id;
    });

    this.loadBoundDevices();
  }

  aboutToDisappear(): void {
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async loadBoundDevices(): Promise<void> {
    this.isLoadingDevices = true;
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_DEVICE_CACHE);
      predicates.equalTo(COLUMN_PAIRED, 1);
      const result = await RdbHelper.queryByPredicates(predicates, [
        COLUMN_ID, COLUMN_DEVICE_ID, COLUMN_DEVICE_NAME, COLUMN_DEVICE_TYPE, COLUMN_DEVICE_MODEL,
        COLUMN_LAST_CONNECT_TIME, COLUMN_DATA_PERMISSION, COLUMN_PERMISSION_TYPES,
        COLUMN_SIGNAL_STRENGTH, COLUMN_DISTANCE
      ]);

      const localDeviceMap: Record<string, BoundDevice> = {};

      if (result && result.rowCount > 0) {
        console.info('[DeviceManage] 本地缓存找到 ' + result.rowCount + ' 条设备记录');
        while (result.goToNextRow()) {
          const rowId: number = result.getLong(0);
          const devId: string = result.getString(1);
          const devName: string = result.getString(2);
          const devType: string = result.getString(3);
          const devModel: string = result.getString(4);
          const lastConnect: number = result.getLong(5);
          const dataPermission: string = result.getString(6) || 'allowed';
          const permissionTypesStr: string = result.getString(7) || '[]';
          const signalStrength: number = result.getLong(8);
          const distance: number = result.getLong(9);

          let permissionTypes: string[] = [];
          try {
            permissionTypes = JSON.parse(permissionTypesStr);
          } catch (e) {
            permissionTypes = [];
          }

          localDeviceMap[devId] = {
            id: rowId,
            deviceId: devId,
            deviceName: devName,
            deviceType: devType,
            deviceModel: devModel,
            isPaired: true,
            lastConnectTime: lastConnect,
            isOnline: true,
            syncStatus: 'success',
            dataPermission: dataPermission as 'allowed' | 'denied',
            permissionTypes: permissionTypes,
            signalStrength: signalStrength,
            distance: distance
          };
        }
        result.close();
      } else {
        console.info('[DeviceManage] 本地缓存无设备记录，尝试从后端加载');
        if (result) result.close();
      }

      console.info('[DeviceManage] 开始请求后端 /device/list ...');
      let apiSuccess: boolean = false;
      try {
        const listResponse: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(ApiConstants.DEVICE_LIST);
        console.info('[DeviceManage] /device/list 响应: success=' + listResponse.success +
          ' code=' + listResponse.code + ' msg=' + listResponse.message +
          ' dataType=' + typeof listResponse.data +
          ' dataLength=' + (Array.isArray(listResponse.data) ? listResponse.data.length : 'N/A'));

        if (listResponse.success && Array.isArray(listResponse.data) && listResponse.data.length > 0) {
          apiSuccess = true;
          console.info('[DeviceManage] 后端返回 ' + listResponse.data.length + ' 条设备，开始解析...');
          const rawItems: Object[] = listResponse.data;

          for (let i = 0; i < rawItems.length; i++) {
            const item: Record<string, Object> = rawItems[i] as Record<string, Object>;
            const allKeys: string = Object.keys(item).join(',');
            console.info('[DeviceManage] 后端设备[' + i + '] keys=[' + allKeys + '] raw=' + JSON.stringify(item));

            const devId: string = String(item['deviceId'] || item['device_id'] || '');
            if (!devId) {
              console.warn('[DeviceManage] 设备[' + i + '] 无 deviceId，跳过');
              continue;
            }
            if (localDeviceMap[devId]) {
              console.info('[DeviceManage] 设备[' + i + '] ' + devId + ' 已存在于本地缓存，跳过');
              continue;
            }

            let lastConnectTime: number = Date.now();
            const lastSyncVal = item['lastSyncTime'] || item['last_sync_time'];
            if (lastSyncVal) {
              try { lastConnectTime = new Date(String(lastSyncVal)).getTime(); } catch (e) { /* ignore */ }
            }
            const bindTimeVal = item['bindTime'] || item['bind_time'];
            if (bindTimeVal && !lastSyncVal) {
              try { lastConnectTime = new Date(String(bindTimeVal)).getTime(); } catch (e) { /* ignore */ }
            }

            let permTypes: string[] = ['血压数据', '心率数据', '血氧数据'];
            const permVal = item['permissionTypes'] || item['permission_types'];
            if (permVal instanceof Array && (permVal as Array<Object>).length > 0) {
              permTypes = permVal as string[];
            }

            const statusVal = item['status'];
            const isOnline: boolean = statusVal != null &&
              ((statusVal === 1) || (statusVal === '1') ||
                (statusVal === 'online') || (String(statusVal) === '1'));

            localDeviceMap[devId] = {
              id: 0,
              deviceId: devId,
              deviceName: String(item['deviceName'] || item['device_name'] || '未知设备'),
              deviceType: String(item['deviceType'] || item['device_type'] || ''),
              deviceModel: String(item['deviceModel'] || item['device_model'] || ''),
              isPaired: true,
              lastConnectTime: lastConnectTime,
              isOnline: isOnline,
              syncStatus: 'success',
              dataPermission: 'allowed',
              permissionTypes: permTypes,
              signalStrength: 80,
              distance: 0
            };
            console.info('[DeviceManage] ✓ 添加设备: ' + devId +
              ' name=' + (item['deviceName'] || item['device_name']) +
              ' online=' + isOnline);
          }
        } else {
          console.warn('[DeviceManage] /device/list 无有效数据: success=' + listResponse.success +
            ' isArray=' + Array.isArray(listResponse.data) +
            ' len=' + (Array.isArray(listResponse.data) ? listResponse.data.length : '-') +
            ' msg=' + listResponse.message +
            ' code=' + listResponse.code);
        }
      } catch (apiError) {
        console.error('[DeviceManage] /device/list 请求异常:', JSON.stringify(apiError));
      }

      if (!apiSuccess && Object.keys(localDeviceMap).length === 0) {
        console.warn('[DeviceManage] 本地和后端均无设备数据，检查: 1.是否已登录 2.后端服务状态 3.数据库user_id匹配');
      }

      const devices: BoundDevice[] = [];
      const keys: string[] = Object.keys(localDeviceMap);
      for (let k = 0; k < keys.length; k++) {
        devices.push(localDeviceMap[keys[k]]);
      }
      this.boundDevices = devices;
      console.info('[DeviceManage] 最终渲染设备数: ' + this.boundDevices.length);

      try {
        const onlineResponse: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(ApiConstants.DEVICE_ONLINE);
        if (onlineResponse.success && Array.isArray(onlineResponse.data)) {
          const onlineList: Object[] = onlineResponse.data;
          const onlineIds: Record<string, boolean> = {};
          for (let j = 0; j < onlineList.length; j++) {
            const ol = onlineList[j] as Record<string, Object>;
            const olDevId = String(ol['deviceId'] || ol['device_id'] || '');
            if (olDevId) {
              onlineIds[olDevId] = true;
            }
          }
          for (let i = 0; i < this.boundDevices.length; i++) {
            this.boundDevices[i].isOnline = !!onlineIds[this.boundDevices[i].deviceId];
          }
        }
      } catch (e) {
        console.error('[DeviceManage] 检查在线状态失败:', e);
      }
    } catch (e) {
      console.error('[DeviceManage] loadBoundDevices 总体异常:', JSON.stringify(e));
    } finally {
      this.isLoadingDevices = false;
    }
  }

  async unbindDevice(device: BoundDevice): Promise<void> {
    try {
      const url: string = ApiConstants.DEVICE_UNBIND + '?deviceId=' + encodeURIComponent(device.deviceId);
      const response: BaseResponse<Object> = await HttpUtil.delete<Object>(url);

      if (response.success) {
        const predicates = new relationalStore.RdbPredicates(TABLE_DEVICE_CACHE);
        predicates.equalTo(COLUMN_DEVICE_ID, device.deviceId);
        await RdbHelper.delete(predicates);

        const filtered: BoundDevice[] = [];
        for (let i = 0; i < this.boundDevices.length; i++) {
          if (this.boundDevices[i].deviceId !== device.deviceId) {
            filtered.push(this.boundDevices[i]);
          }
        }
        this.boundDevices = filtered;

        ToastUtil.showSuccess('\u89E3\u7ED1\u6210\u529F');
      } else {
        ToastUtil.showSuccess(response.message ? response.message : '\u89E3\u7ED1\u5931\u8D25');
      }
    } catch (e) {
      console.error('\u89E3\u7ED1\u8BBE\u5907\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u89E3\u7ED1\u5931\u8D25');
    }
  }

  async triggerSync(device: BoundDevice): Promise<void> {
    if (!device.isOnline) {
      ToastUtil.showSuccess('设备离线，无法同步');
      return;
    }

    device.syncStatus = 'syncing';

    try {
      const syncData: Record<string, string> = {};
      syncData['deviceId'] = device.deviceId;
      syncData['syncData'] = JSON.stringify({ timestamp: Date.now(), type: 'full' });

      const response: BaseResponse<Object> = await HttpUtil.post<Object>(ApiConstants.DEVICE_SYNC, syncData);

      if (response.success) {
        device.syncStatus = 'success';
        device.lastConnectTime = Date.now();

        const log: SyncLogItem = {
          id: 'log' + Date.now(),
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          action: '数据同步',
          dataType: '健康数据',
          timestamp: this.formatTime(new Date()),
          status: 'success',
          detail: '成功同步'
        };
        this.syncLogs.unshift(log);

        ToastUtil.showSuccess('同步成功');
      } else {
        device.syncStatus = 'failed';
        ToastUtil.showSuccess('同步失败');
      }
    } catch (e) {
      device.syncStatus = 'failed';
      console.error('同步失败:', e);
      ToastUtil.showSuccess('同步失败');
    }
  }

  async setDataPermission(device: BoundDevice, permission: 'allowed' | 'denied'): Promise<void> {
    try {
      const permissionData: Record<string, Object> = {};
      permissionData['deviceId'] = device.deviceId;
      permissionData['permission'] = permission;

      const response: BaseResponse<Object> = await HttpUtil.post<Object>('/device/permission/set', permissionData);

      if (response.success) {
        device.dataPermission = permission;

        const predicates = new relationalStore.RdbPredicates(TABLE_DEVICE_CACHE);
        predicates.equalTo(COLUMN_DEVICE_ID, device.deviceId);
        const updateValues: relationalStore.ValuesBucket = {};
        updateValues[COLUMN_DATA_PERMISSION] = permission;
        await RdbHelper.update(TABLE_DEVICE_CACHE, updateValues, predicates);

        ToastUtil.showSuccess(permission === 'allowed' ? '已允许设备访问健康数据' : '已禁止设备访问健康数据');
      } else {
        ToastUtil.showSuccess(response.message ? response.message : '权限设置失败');
      }
    } catch (e) {
      console.error('设置数据权限失败:', e);
      ToastUtil.showSuccess('权限设置失败');
    }
  }

  formatTime(date: Date): string {
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    const hours: string = String(date.getHours()).padStart(2, '0');
    const minutes: string = String(date.getMinutes()).padStart(2, '0');
    return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes;
  }

  getRelativeTime(timestamp: number): string {
    if (!timestamp) return '\u4ECE\u672A\u540C\u6B65';

    const diffMs: number = Date.now() - timestamp;
    const diffMin: number = Math.floor(diffMs / 60000);

    if (diffMin < 1) return '\u521A\u521A';
    if (diffMin < 60) return diffMin.toString() + '\u5206\u949F\u524D';

    const diffHour: number = Math.floor(diffMin / 60);
    if (diffHour < 24) return diffHour.toString() + '\u5C0F\u65F6\u524D';

    const diffDay: number = Math.floor(diffHour / 24);
    if (diffDay < 7) return diffDay.toString() + '\u5929\u524D';

    return this.formatTime(new Date(timestamp)).substring(5);
  }

  getOnlineCount(): number {
    let count: number = 0;
    for (let i = 0; i < this.boundDevices.length; i++) {
      if (this.boundDevices[i].isOnline) count++;
    }
    return count;
  }

  getDeviceIcon(deviceType: string): string {
    const typeMap: Record<string, string> = {
      '\u667A\u80FD\u624B\u73AF': '\u{231A}',
      '\u8840\u538B\u76D1\u6D4B\u4EEA': '\u{1FA7A}',
      '\u8840\u7CD6\u76D1\u6D4B\u4EEA': '\uD83D\uDC89',
      '\u4F53\u91CD\u79C0': '\u2696',
      '\u8840\u6C27\u76D1\u6D4B\u4EEA': '\uD83D\uDCA5',
      '\u4F53\u6E29\u8BA1': '\u{1F921}',
      '\u624B\u673A': '\uD83D\uDCF1',
      '\u624B\u8868': '\u{231A}',
      '\u5E73\u677F': '\uD83D\uDCF2'
    };
    const typeKeys: string[] = Object.keys(typeMap);
    for (let k = 0; k < typeKeys.length; k++) {
      if (deviceType.indexOf(typeKeys[k]) >= 0) return typeMap[typeKeys[k]];
    }
    return '\uD83D\uDCF5';
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

        Text('\u8BBE\u5907\u7BA1\u7406')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('+')
          .fontSize(20)
          .fontColor('#1677FF')
          .fontWeight(FontWeight.Bold)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DeviceDiscoveryPage' });
          });
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Row({ space: 8 }) {
        Button('\uD83D\uDCBB \u5DF2\u7ED1\u5B9A')
          .height(36)
          .fontSize(12)
          .fontColor(this.currentTab === 0 ? '#FFFFFF' : '#666666')
          .backgroundColor(this.currentTab === 0 ? '#1677FF' : '#F5F5F5')
          .borderRadius(18)
          .layoutWeight(1)
          .onClick(() => { this.currentTab = 0; });

        Button('\u{1F504} \u540C\u6B65\u72B6\u6001')
          .height(36)
          .fontSize(12)
          .fontColor(this.currentTab === 1 ? '#FFFFFF' : '#666666')
          .backgroundColor(this.currentTab === 1 ? '#1677FF' : '#F5F5F5')
          .borderRadius(18)
          .layoutWeight(1)
          .onClick(() => { this.currentTab = 1; });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')

      if (this.currentTab === 0) {
        Scroll() {
          Column({ space: 14 }) {
            Row({ space: 8 }) {
              Text('\u5DF2\u7ED1\u5B9A ' + this.boundDevices.length + ' \u53F0\u8BBE\u5907')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333');
              Blank();
              Text(this.getOnlineCount() + ' \u5728\u7EBF')
                .fontSize(12)
                .fontColor('#52C41A')
                .backgroundColor('#F6FFED')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(12)
                .border({ width: 1, color: '#B7EB8F' });
            }
            .width('100%');

            if (this.isLoadingDevices) {
              Column() {
                LoadingProgress().width(40).height(40).color('#1677FF');
                Text('\u52A0\u8F7D\u4E2D...').fontSize(14).fontColor('#666666').margin({ top: 12 });
              }.width('100%').height(200).justifyContent(FlexAlign.Center);
            } else if (this.boundDevices.length === 0) {
              Column() {
                Text('\uD83D\uDCBB').fontSize(48).margin({ bottom: 12 });
                Text('\u6682\u65E0\u5DF2\u7ED1\u5B9A\u8BBE\u5907').fontSize(15).fontColor('#999999');
                Text('\u70B9\u51FB\u53F3\u4E0A\u89D2 + \u53BB\u6DFB\u52A0\u8BBE\u5907').fontSize(12).fontColor('#BBBBBB').margin({ top: 8 });
              }.width('100%').height(250).justifyContent(FlexAlign.Center);
            } else {
              ForEach(this.boundDevices, (device: BoundDevice) => {
                Column({ space: 10 }) {
                  Row({ space: 12 }) {
                    Stack({ alignContent: Alignment.BottomEnd }) {
                      Column() {
                        Text(this.getDeviceIcon(device.deviceType)).fontSize(30);
                      }
                      .width(58)
                      .height(58)
                      .backgroundColor(device.isOnline ? '#E6F7FF' : '#F5F5F5')
                      .borderRadius(14)
                      .justifyContent(FlexAlign.Center)
                      .border({ width: 1, color: device.isOnline ? '#91D5FF' : '#D9D9D9' });

                      Circle()
                        .width(10)
                        .height(10)
                        .fill(device.isOnline ? '#52C41A' : '#D9D9D9')
                        .border({ width: 2, color: '#FFFFFF' });
                    }
                    .width(58)
                    .height(58);

                    Column({ space: 5 }) {
                      Row({ space: 6 }) {
                        Text(device.deviceName)
                          .fontSize(this.isElderMode ? 17 : 15)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#333333')
                          .maxLines(1)
                          .layoutWeight(1);

                        Text(device.isOnline ? '在线' : '离线')
                          .fontSize(10)
                          .fontColor(device.isOnline ? '#FFFFFF' : '#999999')
                          .backgroundColor(device.isOnline ? '#52C41A' : '#F0F0F0')
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .borderRadius(8);
                      }

                      Text((device.deviceModel ? device.deviceModel : '') + ' · ' + device.deviceType)
                        .fontSize(11)
                        .fontColor('#999999');

                      Row({ space: 10 }) {
                        Text('上次同步: ' + this.getRelativeTime(device.lastConnectTime))
                          .fontSize(10)
                          .fontColor('#666666');

                        if (device.syncStatus === 'syncing') {
                          Text('同步中...').fontSize(10).fontColor('#1677FF').fontWeight(FontWeight.Medium);
                        } else if (device.syncStatus === 'failed') {
                          Text('❌ 失败').fontSize(10).fontColor('#FF4D4F');
                        }
                      }

                      Row({ space: 8 }) {
                        if (device.dataPermission === 'allowed') {
                          Text('✅ 允许访问数据')
                            .fontSize(10)
                            .fontColor('#52C41A')
                            .backgroundColor('#F6FFED')
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .borderRadius(8);
                        } else {
                          Text('🚫 禁止访问数据')
                            .fontSize(10)
                            .fontColor('#FF4D4F')
                            .backgroundColor('#FFF1F0')
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .borderRadius(8);
                        }

                        if (device.permissionTypes && device.permissionTypes.length > 0) {
                          Text('权限: ' + device.permissionTypes.join(', '))
                            .fontSize(9)
                            .fontColor('#888888')
                            .maxLines(1);
                        }
                      }
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start);

                    Column({ space: 6 }) {
                      if (device.isOnline) {
                        Button('同步')
                          .width(54)
                          .height(28)
                          .fontSize(11)
                          .fontColor('#FFFFFF')
                          .backgroundColor('#1677FF')
                          .borderRadius(14)
                          .onClick(() => { this.triggerSync(device); });
                      }
                      Button('解绑')
                        .width(54)
                        .height(28)
                        .fontSize(11)
                        .fontColor('#FF4D4F')
                        .backgroundColor('#FFF1F0')
                        .borderRadius(14)
                        .border({ width: 1, color: '#FFCCC7' })
                        .onClick(() => { this.unbindDevice(device); });
                    }
                  }
                  .width('100%');

                  Row({ space: 8 }) {
                    Text('🔐 数据权限设置:')
                      .fontSize(12)
                      .fontColor('#666666')
                      .layoutWeight(1);

                    Button(device.dataPermission === 'allowed' ? '禁止访问' : '允许访问')
                      .height(28)
                      .fontSize(11)
                      .fontColor(device.dataPermission === 'allowed' ? '#FF4D4F' : '#52C41A')
                      .backgroundColor(device.dataPermission === 'allowed' ? '#FFF1F0' : '#F6FFED')
                      .borderRadius(14)
                      .border({ width: 1, color: device.dataPermission === 'allowed' ? '#FFCCC7' : '#B7EB8F' })
                      .onClick(() => {
                        const newPermission = device.dataPermission === 'allowed' ? 'denied' : 'allowed';
                        this.setDataPermission(device, newPermission);
                      });
                  }
                  .width('100%')
                  .padding({ left: 70, right: 12 })
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
                .border({ width: device.isOnline ? 1.5 : 1, color: device.isOnline ? '#91D5FF50' : '#F0F0F0' });
              }, (device: BoundDevice) => String(device.id));
            }
          }
          .width('85%')
          .padding({ top: 14, bottom: 120 });
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Text('\u{1F504} \u540C\u6B65\u65E5\u5FD7')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%');

            if (this.syncLogs.length === 0) {
              Column() {
                Text('\u{1F4CB}').fontSize(48).margin({ bottom: 12 });
                Text('\u6682\u65E0\u540C\u6B65\u8BB0\u5F55').fontSize(15).fontColor('#999999');
                Text('\u70B9\u51FB\u201C\u540C\u6B9D\u201D\u6309\u94AE\u5373\u53EF\u5F00\u59CB\u540C\u6B65').fontSize(12).fontColor('#BBBBBB').margin({ top: 8 });
              }.width('100%').height(250).justifyContent(FlexAlign.Center);
            } else {
              ForEach(this.syncLogs, (log: SyncLogItem) => {
                Row({ space: 10 }) {
                  Circle()
                    .width(10)
                    .height(10)
                    .fill(log.status === 'success' ? '#52C41A' : '#FF4D4F');

                  Column({ space: 4 }) {
                    Row({ space: 8 }) {
                      Text(log.deviceName)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333');
                      Text(log.action)
                        .fontSize(12)
                        .fontColor('#1677FF');
                    }
                    .width('100%');

                    Text(log.detail + ' (' + log.dataType + ')')
                      .fontSize(12)
                      .fontColor('#666666');

                    Text(log.timestamp)
                      .fontSize(11)
                      .fontColor('#BBBBBB');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .border({ width: 1, color: '#F0F0F0' });
              }, (log: SyncLogItem) => log.id);
            }
          }
          .width('85%')
          .padding({ top: 14, bottom: 120 });
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}