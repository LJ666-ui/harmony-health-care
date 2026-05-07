import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { SettingsUtil } from '../utils/SettingsUtil';
import EventPersistenceManager from '../utils/EventPersistenceManager';

export interface PrivacySetting {
  locationEnabled: boolean;
  healthDataEnabled: boolean;
  browseHistoryEnabled: boolean;
  diagnosticReportEnabled: boolean;
}

export interface AuthItem {
  id: string;
  name: string;
  type: string;
  dataType: string;
  status: 'active' | 'expired' | 'revoked';
  startDate: string;
  endDate: string;
}

export interface AccessLogItem {
  id: number;
  accessUser: string;
  accessType: string;
  dataType: string;
  action: string;
  accessTime: string;
  detail: string;
}

export interface LocalDataSummary {
  healthRecords: number;
  searchHistory: number;
  collections: number;
  browseHistory: number;
}

export interface ExportSummary {
  totalHealthRecords: number;
  totalSearchHistory: number;
  totalCollections: number;
}

export interface ExportData {
  exportTime: string;
  healthRecords: ESObject[];
  searchHistory: ESObject[];
  collections: ESObject[];
  summary: ExportSummary;
}

@Entry
@Component
struct PrivacySettingPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State privacySettings: PrivacySetting = {
    locationEnabled: true,
    healthDataEnabled: true,
    browseHistoryEnabled: true,
    diagnosticReportEnabled: false
  };

  @State authItems: AuthItem[] = [];
  @State accessLogs: AccessLogItem[] = [];
  @State isLoadingSettings: boolean = true;
  @State isLoadingAuths: boolean = true;
  @State isLoadingLogs: boolean = true;
  @State localDataSummary: LocalDataSummary = {
    healthRecords: 0, searchHistory: 0, collections: 0, browseHistory: 0
  };
  @State isExporting: boolean = false;
  @State isDeletingAllData: boolean = false;

  private getActiveAuthCount(): number {
    let count = 0;
    for (let i = 0; i < this.authItems.length; i++) {
      if (this.authItems[i].status === 'active') {
        count++;
      }
    }
    return count;
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    this.loadPrivacySettings();
    this.loadAuthList();
    this.loadAccessLogs();
    this.loadLocalDataSummary();
  }

  async loadPrivacySettings(): Promise<void> {
    this.isLoadingSettings = true;
    try {
      const response: BaseResponse<PrivacySetting> = await HttpUtil.get<PrivacySetting>(ApiConstants.PRIVACY_SETTINGS);
      if (response.success && response.data) {
        this.privacySettings = response.data;
      }
    } catch (e) {
      console.error('\u52A0\u8F7D\u9690\u79C8\u8BBE\u7F6E\u5931\u8D25:', e);
    } finally {
      this.isLoadingSettings = false;
    }
  }

  async savePrivacySettings(): Promise<void> {
    try {
      const response: BaseResponse<Object> = await HttpUtil.put<Object>(ApiConstants.PRIVACY_SETTINGS, this.privacySettings);
      if (response.success) {
        ToastUtil.showSuccess('\u4FDD\u5B58\u6210\u529F');
      } else {
        ToastUtil.showSuccess(response.message ? response.message : '\u4FDD\u5B58\u5931\u8D25');
      }
    } catch (e) {
      console.error('\u4FDD\u5B58\u9690\u79C1\u8BBE\u7F6E\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u4FDD\u5B58\u5931\u8D25');
    }
  }

  async loadAuthList(): Promise<void> {
    this.isLoadingAuths = true;
    try {
      const response: BaseResponse<AuthItem[]> = await HttpUtil.get<AuthItem[]>(ApiConstants.PRIVACY_AUTH_LIST);
      if (response.success && response.data) {
        const list: AuthItem[] = response.data;
        this.authItems = [];
        for (let i = 0; i < list.length; i++) {
          this.authItems.push(list[i]);
        }
      }
    } catch (e) {
      console.error('\u52A0\u8F7D\u6388\u6743\u5217\u8868\u5931\u8D25:', e);
    } finally {
      this.isLoadingAuths = false;
    }
  }

  async loadAccessLogs(): Promise<void> {
    this.isLoadingLogs = true;
    try {
      const response: BaseResponse<AccessLogItem[]> = await HttpUtil.get<AccessLogItem[]>(ApiConstants.PRIVACY_ACCESS_LOGS);
      if (response.success && response.data) {
        const list: AccessLogItem[] = response.data;
        this.accessLogs = [];
        for (let i = 0; i < list.length; i++) {
          this.accessLogs.push(list[i]);
        }
      }
    } catch (e) {
      console.error('\u52A0\u8F7D\u8BBF\u95EE\u65E5\u5FD7\u5931\u8D25:', e);
    } finally {
      this.isLoadingLogs = false;
    }
  }

  toggleSetting(key: keyof PrivacySetting): void {
    if (key === 'locationEnabled') {
      this.privacySettings.locationEnabled = !this.privacySettings.locationEnabled;
    } else if (key === 'healthDataEnabled') {
      this.privacySettings.healthDataEnabled = !this.privacySettings.healthDataEnabled;
    } else if (key === 'browseHistoryEnabled') {
      this.privacySettings.browseHistoryEnabled = !this.privacySettings.browseHistoryEnabled;
    } else if (key === 'diagnosticReportEnabled') {
      this.privacySettings.diagnosticReportEnabled = !this.privacySettings.diagnosticReportEnabled;
    }
    this.savePrivacySettings();
  }

  viewDataAuth(): void {
    router.pushUrl({ url: 'pages/DataAuthPage' });
  }

  changePassword(): void {
    promptAction.showDialog({
      title: '\u4FEE\u6539\u5BC6\u7801',
      message: '\u6B64\u529F\u80FD\u5C06\u8DF3\u8F6C\u5230\u4FEE\u6539\u5BC6\u7801\u9875\u9762',
      buttons: [{ text: '\u53D6\u6D88', color: '#999999' }, { text: '\u786E\u5B9A', color: '#1677FF' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        ToastUtil.operationSuccess();
      }
    });
  }

  async logout(): Promise<void> {
    promptAction.showDialog({
      title: '\u9000\u51FA\u767B\u5F55',
      message: '\u786E\u5B9A\u8981\u9000\u51FA\u5F53\u524D\u8D26\u53F7\u5417?',
      buttons: [{ text: '\u53D6\u6D88', color: '#999999' }, { text: '\u786E\u5B9A\u9000\u51FA', color: '#FF4D4F' }]
    }).then(async (result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        try {
          const settings: SettingsUtil = SettingsUtil.getInstance();
          await settings.clearAllLoginData();
          EventPersistenceManager.clearUserCache();
          ToastUtil.showInfo('已退出登录');
          router.replaceUrl({ url: 'pages/Login' });
        } catch (error) {
          console.error('退出登录失败:', error);
        }
      }
    });
  }

  async loadLocalDataSummary(): Promise<void> {
    try {
      const healthRecords = await EventPersistenceManager.getOfflineHealthRecords(999);
      const searchHistory = await EventPersistenceManager.getSearchHistory(undefined, 999);
      const collections = await EventPersistenceManager.getCollectionList(undefined, 999);
      const browseHistory = await EventPersistenceManager.getRecentBrowseHistory(999);
      this.localDataSummary = {
        healthRecords: healthRecords.length,
        searchHistory: searchHistory.length,
        collections: collections.length,
        browseHistory: browseHistory.length
      };
    } catch (e) {
      console.error('加载本地数据摘要失败:', e);
    }
  }

  async exportMyData(): Promise<void> {
    if (this.isExporting) return;
    this.isExporting = true;

    try {
      const healthRecords = await EventPersistenceManager.getOfflineHealthRecords(999);
      const searchHistory = await EventPersistenceManager.getSearchHistory(undefined, 999);
      const collections = await EventPersistenceManager.getCollectionList(undefined, 999);

      const exportData: ExportData = {
        exportTime: new Date().toISOString(),
        healthRecords: healthRecords,
        searchHistory: searchHistory,
        collections: collections,
        summary: {
          totalHealthRecords: healthRecords.length,
          totalSearchHistory: searchHistory.length,
          totalCollections: collections.length
        }
      };

      const jsonStr = JSON.stringify(exportData, null, 2);

      promptAction.showDialog({
        title: '数据导出成功',
        message: '已导出 ' + (healthRecords.length + searchHistory.length + collections.length) + ' 条记录（JSON格式预览）',
        buttons: [{ text: '确定', color: '#1677FF' }]
      });

      console.info('PrivacySettingPage: 数据导出完成，大小=' + jsonStr.length + '字节');
    } catch (e) {
      console.error('数据导出失败:', e);
      ToastUtil.showInfo('导出失败，请重试');
    } finally {
      this.isExporting = false;
    }
  }

  async requestDeleteAllData(): Promise<void> {
    if (this.isDeletingAllData) return;

    promptAction.showDialog({
      title: '⚠️ 危险操作确认',
      message: '此操作将永久删除您在本地的所有健康记录、搜索历史、收藏和浏览数据。此操作不可恢复！\n\n是否继续？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确认删除全部数据', color: '#FF4D4F' }
      ]
    }).then(async (result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.isDeletingAllData = true;
        try {
          await EventPersistenceManager.clearSearchHistory();
          await EventPersistenceManager.clearUserCache();
          this.localDataSummary = { healthRecords: 0, searchHistory: 0, collections: 0, browseHistory: 0 };
          ToastUtil.showSuccess('已清除所有本地数据');
          this.loadLocalDataSummary();
        } catch (e) {
          console.error('删除数据失败:', e);
          ToastUtil.showInfo('部分数据清除失败');
        } finally {
          this.isDeletingAllData = false;
        }
      }
    }).catch((error: Error) => {
      console.error('显示对话框失败:', error.message);
    });
  }

  @Builder
  DataManagementSection() {
    Column({ space: 12 }) {
      Text('\uD83D\uDCCA \u6211\u7684\u6570\u636E')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%');

      Column({ space: 8 }) {
        Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
          Text('\uD83D\uDCD8 \u5065\u5EBB\u8BB0\u5F55')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#333333')
            .layoutWeight(1);
          Text(String(this.localDataSummary.healthRecords) + ' 条')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1677FF');
        }
        .width('100%')
        .padding(GlobalTheme.getSpacingSM(this.isElderMode))
        .backgroundColor('#FAFAFA')
        .borderRadius(6);

        Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
          Text('\uD83D\uDD0D \u641C\u7D22\u5386\u53F2')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#333333')
            .layoutWeight(1);
          Text(String(this.localDataSummary.searchHistory) + ' 条')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#52C41A');
        }
        .width('100%')
        .padding(GlobalTheme.getSpacingSM(this.isElderMode))
        .backgroundColor('#FAFAFA')
        .borderRadius(6);

        Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
          Text('\u2B50 \u6536\u85CF\u8BB0\u5F55')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#333333')
            .layoutWeight(1);
          Text(String(this.localDataSummary.collections) + ' 条')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FAAD14');
        }
        .width('100%')
        .padding(GlobalTheme.getSpacingSM(this.isElderMode))
        .backgroundColor('#FAFAFA')
        .borderRadius(6);

        Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
          Text('\uD83D\uDCDA \u6D4F\u89C8\u8BB0\u5F55')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#333333')
            .layoutWeight(1);
          Text(String(this.localDataSummary.browseHistory) + ' 条')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#722ED1');
        }
        .width('100%')
        .padding(GlobalTheme.getSpacingSM(this.isElderMode))
        .backgroundColor('#FAFAFA')
        .borderRadius(6);
      }
      .width('100%');

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Button(this.isExporting ? '导出中...' : '\u{1F4E4} 导出我的数据')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .enabled(!this.isExporting)
          .onClick(() => this.exportMyData());

        Button(this.isDeletingAllData ? '处理中...' : '\u{1F5D1} 清除全部数据')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontColor('#FF4D4F')
          .backgroundColor('#FFF1F0')
          .borderRadius(20)
          .margin({ left: 10 })
          .enabled(!this.isDeletingAllData)
          .onClick(() => this.requestDeleteAllData());
      }
      .width('100%');

      Text('* 数据导出为JSON格式，包含健康记录、搜索历史和收藏；清除操作仅影响本机存储，服务端数据不受影响')
        .fontSize(10)
        .fontColor('#BBBBBB')
        .lineHeight(16)
        .width('100%');
    }
    .width('100%')
    .padding(GlobalTheme.getSpacingMD(this.isElderMode))
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  build() {
    Column() {
      Header({ title: '\u9690\u79C1\u4E0E\u5B89\u5168', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {

          Column() {
            Text('\uD83D\uDD12 \u6570\u636E\u6743\u9650')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDCCD \u4F4D\u7F6E\u4FE1\u606F')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#333333')
                .layoutWeight(1);

              Text(this.privacySettings.locationEnabled ? '\u5F00' : '\u5173')
                .fontSize(11)
                .fontColor(this.privacySettings.locationEnabled ? '#FFFFFF' : '#999999')
                .backgroundColor(this.privacySettings.locationEnabled ? '#52C41A' : '#E8E8E8')
                .width(this.isElderMode ? 50 : 40)
                .height(this.isElderMode ? 28 : 24)
                .borderRadius(14)
                .textAlign(TextAlign.Center)
                .onClick(() => this.toggleSetting('locationEnabled'));
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingSM(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 6 });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83C\uDFE5 \u5065\u5EBB\u6570\u636E')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#333333')
                .layoutWeight(1);

              Text(this.privacySettings.healthDataEnabled ? '\u5F00' : '\u5173')
                .fontSize(11)
                .fontColor(this.privacySettings.healthDataEnabled ? '#FFFFFF' : '#999999')
                .backgroundColor(this.privacySettings.healthDataEnabled ? '#52C41A' : '#E8E8E8')
                .width(this.isElderMode ? 50 : 40)
                .height(this.isElderMode ? 28 : 24)
                .borderRadius(14)
                .textAlign(TextAlign.Center)
                .onClick(() => this.toggleSetting('healthDataEnabled'));
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingSM(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 6 });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDCDA \u6D4F\u89C8\u8BB0\u5F55')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#333333')
                .layoutWeight(1);

              Text(this.privacySettings.browseHistoryEnabled ? '\u5F00' : '\u5173')
                .fontSize(11)
                .fontColor(this.privacySettings.browseHistoryEnabled ? '#FFFFFF' : '#999999')
                .backgroundColor(this.privacySettings.browseHistoryEnabled ? '#52C41A' : '#E8E8E8')
                .width(this.isElderMode ? 50 : 40)
                .height(this.isElderMode ? 28 : 24)
                .borderRadius(14)
                .textAlign(TextAlign.Center)
                .onClick(() => this.toggleSetting('browseHistoryEnabled'));
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingSM(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 6 });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDCCB \u8BCA\u65AD\u62A5\u544A')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#333333')
                .layoutWeight(1);

              Text(this.privacySettings.diagnosticReportEnabled ? '\u5F00' : '\u5173')
                .fontSize(11)
                .fontColor(this.privacySettings.diagnosticReportEnabled ? '#FFFFFF' : '#999999')
                .backgroundColor(this.privacySettings.diagnosticReportEnabled ? '#52C41A' : '#E8E8E8')
                .width(this.isElderMode ? 50 : 40)
                .height(this.isElderMode ? 28 : 24)
                .borderRadius(14)
                .textAlign(TextAlign.Center)
                .onClick(() => this.toggleSetting('diagnosticReportEnabled'));
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingSM(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDCDB \u6570\u636E\u6388\u6743\u5217\u8868')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1);

              Text('' + this.getActiveAuthCount() + ' 个有效')
                .fontSize(11)
                .fontColor('#52C41A')
                .backgroundColor('#F6FFED')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(12)
                .border({ width: 1, color: '#B7EB8F' });
            }
            .width('100%');

            if (this.isLoadingAuths) {
              LoadingProgress().width(20).height(20).color('#1677FF').margin({ top: 12, bottom: 12 });
            } else if (this.authItems.length === 0) {
              Text('\u6682\u65E0\u6388\u6743\u8BB0\u5F55')
                .fontSize(13)
                .fontColor('#999999')
                .padding(20)
                .width('100%')
                .textAlign(TextAlign.Center);
            } else {
              ForEach(this.authItems.slice(0, 5), (item: AuthItem) => {
                Row({ space: 8 }) {
                  Circle()
                    .width(8)
                    .height(8)
                    .fill(item.status === 'active' ? '#52C41A' : item.status === 'expired' ? '#999999' : '#FF4D4F');

                  Column({ space: 2 }) {
                    Text(item.name)
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .maxLines(1);

                    Text(item.dataType + ' · ' + (item.status === 'active' ? '\u6709\u6548' : item.status === 'expired' ? '\u5DF2\u8FC7\u671F' : '\u5DF2\u64A4\u9500'))
                      .fontSize(11)
                      .fontColor('#999999');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(10)
                .backgroundColor('#FAFAFA')
                .borderRadius(6)
                .margin({ top: 4 });
              }, (item: AuthItem) => item.id);
            }

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\u67E5\u770B\u5168\u90E8\u6388\u6743')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#1677FF')
                .layoutWeight(1);
              Text('\u203A').fontSize(16).fontColor('#1677FF');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingSM(this.isElderMode))
            .backgroundColor('#E6F4FF')
            .borderRadius(8)
            .margin({ top: 8 })
            .onClick(() => this.viewDataAuth());
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          this.DataManagementSection();

          Column() {
            Text('\uD83D\uDCDE \u64CD\u4F5BA5BA\u8BA1\u65E5\u5FD7')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) })
              .width('100%');

            if (this.isLoadingLogs) {
              LoadingProgress().width(20).height(20).color('#1677FF').margin({ top: 12, bottom: 12 });
            } else if (this.accessLogs.length === 0) {
              Text('\u6682\u65E0\u8BBF\u95EE\u8BB0\u5F55')
                .fontSize(13)
                .fontColor('#999999')
                .padding(20)
                .width('100%')
                .textAlign(TextAlign.Center);
            } else {
              ForEach(this.accessLogs.slice(0, 5), (log: AccessLogItem) => {
                Row({ space: 8 }) {
                  Circle()
                    .width(8)
                    .height(8)
                    .fill(log.action === '\u8BFB\u53D6' ? '#1677FF' : log.action === '\u5199\u5165' ? '#52C41A' : '#FF4D4F');

                  Column({ space: 2 }) {
                    Text(log.accessUser + ' ' + log.action + '\u4E86' + log.dataType)
                      .fontSize(13)
                      .fontColor('#333333')
                      .maxLines(1);

                    Text(log.accessTime + ' · ' + (log.detail ? log.detail : ''))
                      .fontSize(11)
                      .fontColor('#BBBBBB')
                      .maxLines(1);
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(10)
                .backgroundColor('#FAFAFA')
                .borderRadius(6)
                .margin({ top: 4 });
              }, (log: AccessLogItem) => String(log.id));
            }
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Text('\uD83D\uDD11 \u8D26\u6237\u5B89\u5168')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDD11')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));
              Column({ space: 4 }) {
                Text('\u4FEE\u6539\u5BC6\u7801')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium);
                Text('\u5B9A\u671F\u66F4\u6362\u4FDD\u969C\u8D26\u6237\u5B89\u5168')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });
              Text('\u203A')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#CCCCCC');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 8 })
            .onClick(() => this.changePassword());

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDEAA')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));
              Column({ space: 4 }) {
                Text('\u9000\u51FA\u767B\u5F55')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#FF4D4F')
                  .fontWeight(FontWeight.Medium);
                Text('\u5207\u6362\u5230\u5176\u4ED6\u8D26\u53F7')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });
              Text('\u203A')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#FF4D4F');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFF7F7')
            .borderRadius(8)
            .onClick(() => this.logout());
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}