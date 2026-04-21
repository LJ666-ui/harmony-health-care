import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

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
  @State isSaving: boolean = false;

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

    console.info('[PrivacySetting] 页面初始化，开始加载隐私设置...');
    this.loadPrivacySettings();
    this.loadAuthList();
    this.loadAccessLogs();
  }

  async loadPrivacySettings(): Promise<void> {
    this.isLoadingSettings = true;
    try {
      console.info('[PrivacySetting] 开始请求 GET /api/privacy/settings ...');
      const response: BaseResponse<PrivacySetting> = await HttpUtil.get<PrivacySetting>(ApiConstants.PRIVACY_SETTINGS);
      console.info('[PrivacySetting] /api/privacy/settings 响应: success=' + response.success +
        ' code=' + response.code + ' msg=' + response.message);

      if (response.success && response.data) {
        this.privacySettings = response.data;
        console.info('[PrivacySetting] 隐私设置加载成功: location=' + this.privacySettings.locationEnabled +
          ' health=' + this.privacySettings.healthDataEnabled +
          ' browse=' + this.privacySettings.browseHistoryEnabled +
          ' diagnostic=' + this.privacySettings.diagnosticReportEnabled);
      } else {
        console.warn('[PrivacySetting] 隐私设置响应异常: ' + response.message);
      }
    } catch (e) {
      console.error('[PrivacySetting] 加载隐私设置失败:', JSON.stringify(e));
    } finally {
      this.isLoadingSettings = false;
    }
  }

  async savePrivacySettings(): Promise<void> {
    if (this.isSaving) {
      console.warn('[PrivacySetting] 正在保存中，请勿重复操作');
      return;
    }

    this.isSaving = true;
    try {
      console.info('[PrivacySetting] 开始请求 PUT /api/privacy/settings ...');
      console.info('[PrivacySetting] 发送数据: ' + JSON.stringify(this.privacySettings));

      const response: BaseResponse<Object> = await HttpUtil.put<Object>(ApiConstants.PRIVACY_SETTINGS, this.privacySettings);
      console.info('[PrivacySetting] PUT /api/privacy/settings 响应: success=' + response.success +
        ' code=' + response.code + ' msg=' + response.message);

      if (response.success) {
        console.info('[PrivacySetting] ✓ 隐私设置保存成功');
        ToastUtil.showSuccess('隐私设置已保存');
      } else {
        console.warn('[PrivacySetting] 隐私设置保存失败: ' + response.message);
        ToastUtil.showError(response.message ? response.message : '保存失败，请重试');
      }
    } catch (e) {
      console.error('[PrivacySetting] 保存隐私设置异常:', JSON.stringify(e));
      ToastUtil.showError('网络错误，请检查连接后重试');
    } finally {
      this.isSaving = false;
    }
  }

  async loadAuthList(): Promise<void> {
    this.isLoadingAuths = true;
    try {
      console.info('[PrivacySetting] 开始请求 GET /api/privacy/auth-list ...');
      const response: BaseResponse<AuthItem[]> = await HttpUtil.get<AuthItem[]>(ApiConstants.PRIVACY_AUTH_LIST);
      console.info('[PrivacySetting] /api/privacy/auth-list 响应: success=' + response.success +
        ' dataLength=' + (Array.isArray(response.data) ? response.data.length : 0));

      if (response.success && response.data) {
        const list: AuthItem[] = response.data;
        this.authItems = [];
        for (let i = 0; i < list.length; i++) {
          this.authItems.push(list[i]);
          console.info('[PrivacySetting] 授权项[' + i + ']: name=' + list[i].name +
            ' type=' + list[i].type + ' status=' + list[i].status);
        }
      }
    } catch (e) {
      console.error('[PrivacySetting] 加载授权列表失败:', JSON.stringify(e));
    } finally {
      this.isLoadingAuths = false;
    }
  }

  async loadAccessLogs(): Promise<void> {
    this.isLoadingLogs = true;
    try {
      console.info('[PrivacySetting] 开始请求 GET /api/privacy/logs ...');
      const response: BaseResponse<AccessLogItem[]> = await HttpUtil.get<AccessLogItem[]>(ApiConstants.PRIVACY_LOGS);
      console.info('[PrivacySetting] /api/privacy/logs 响应: success=' + response.success +
        ' dataLength=' + (Array.isArray(response.data) ? response.data.length : 0));

      if (response.success && response.data) {
        const list: AccessLogItem[] = response.data;
        this.accessLogs = [];
        for (let i = 0; i < list.length; i++) {
          this.accessLogs.push(list[i]);
        }
      }
    } catch (e) {
      console.error('[PrivacySetting] 加载访问日志失败:', JSON.stringify(e));
    } finally {
      this.isLoadingLogs = false;
    }
  }

  toggleLocationSetting(): void {
    console.info('[PrivacySetting] 切换位置信息设置: ' + this.privacySettings.locationEnabled + ' -> ' + !this.privacySettings.locationEnabled);
    this.privacySettings.locationEnabled = !this.privacySettings.locationEnabled;
    this.savePrivacySettings();
  }

  toggleHealthDataSetting(): void {
    console.info('[PrivacySetting] 切换健康数据设置: ' + this.privacySettings.healthDataEnabled + ' -> ' + !this.privacySettings.healthDataEnabled);
    this.privacySettings.healthDataEnabled = !this.privacySettings.healthDataEnabled;
    this.savePrivacySettings();
  }

  toggleBrowseHistorySetting(): void {
    console.info('[PrivacySetting] 切换浏览记录设置: ' + this.privacySettings.browseHistoryEnabled + ' -> ' + !this.privacySettings.browseHistoryEnabled);
    this.privacySettings.browseHistoryEnabled = !this.privacySettings.browseHistoryEnabled;
    this.savePrivacySettings();
  }

  toggleDiagnosticReportSetting(): void {
    console.info('[PrivacySetting] 切换诊断报告设置: ' + this.privacySettings.diagnosticReportEnabled + ' -> ' + !this.privacySettings.diagnosticReportEnabled);
    this.privacySettings.diagnosticReportEnabled = !this.privacySettings.diagnosticReportEnabled;
    this.savePrivacySettings();
  }

  viewDataAuth(): void {
    console.info('[PrivacySetting] 跳转到数据授权管理页面');
    router.pushUrl({ url: 'pages/DataAuthPage' });
  }

  changePassword(): void {
    promptAction.showDialog({
      title: '修改密码',
      message: '此功能将跳转到修改密码页面',
      buttons: [{ text: '取消', color: '#999999' }, { text: '确定', color: '#1677FF' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        ToastUtil.operationSuccess();
      }
    }).catch((error: Error) => {
      console.error('[PrivacySetting] 显示修改密码对话框失败:', error.message);
    });
  }

  logout(): void {
    promptAction.showDialog({
      title: '退出登录',
      message: '确定要退出当前账号吗?',
      buttons: [{ text: '取消', color: '#999999' }, { text: '确定退出', color: '#FF4D4F' }]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        try {
          AppStorage.setOrCreate<boolean>('isLoggedIn', false);
          AppStorage.setOrCreate<string>('token', '');
          HttpUtil.clearToken();
          ToastUtil.showInfo('已退出登录');
          router.replaceUrl({ url: 'pages/Login' });
        } catch (error) {
          console.error('[PrivacySetting] 退出登录失败:', error);
        }
      }
    }).catch((error: Error) => {
      console.error('[PrivacySetting] 显示退出登录对话框失败:', error.message);
    });
  }

  getSettingDescription(key: string): string {
    const descriptions: Record<string, string> = {
      'location': '允许应用获取您的位置信息以推荐附近医院和服务',
      'healthData': '允许授权医生和设备访问您的健康监测数据',
      'browseHistory': '保存您的浏览记录用于个性化内容推荐',
      'diagnosticReport': '允许系统生成并存储AI诊断分析报告'
    };
    return descriptions[key] || '';
  }

  getSettingIcon(key: string): string {
    const icons: Record<string, string> = {
      'location': '\uD83D\uDCCD',
      'healthData': '\uD83C\uDFE5',
      'browseHistory': '\uD83D\uDCDA',
      'diagnosticReport': '\uD83D\uDCCB'
    };
    return icons[key] || '\uD83D\uDCCC';
  }

  build() {
    Column() {
      Header({ title: '隐私与安全', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {

          Column() {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDD12 数据权限控制')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1);

              if (this.isSaving) {
                LoadingProgress().width(16).height(16).color('#1677FF');
              }
            }
            .width('100%')
            .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

            Text('独立控制各项数据的共享权限，保护您的个人隐私')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            if (this.isLoadingSettings) {
              Column() {
                LoadingProgress().width(32).height(32).color('#1677FF').margin({ bottom: 10 });
                Text('正在加载隐私配置...').fontSize(13).fontColor('#666666');
              }.width('100%').height(120).justifyContent(FlexAlign.Center).backgroundColor('#FAFAFA').borderRadius(8);
            } else {

              this.buildSettingRow('location', '位置信息', this.privacySettings.locationEnabled, () => this.toggleLocationSetting());
              this.buildSettingRow('healthData', '健康数据', this.privacySettings.healthDataEnabled, () => this.toggleHealthDataSetting());
              this.buildSettingRow('browseHistory', '浏览记录', this.privacySettings.browseHistoryEnabled, () => this.toggleBrowseHistorySetting());
              this.buildSettingRow('diagnosticReport', '诊断报告', this.privacySettings.diagnosticReportEnabled, () => this.toggleDiagnosticReportSetting());
            }
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDCDB 数据授权列表')
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

            Text('查看和管理已授权访问您数据的第三方应用和设备')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

            if (this.isLoadingAuths) {
              Column() {
                LoadingProgress().width(24).height(24).color('#1677FF').margin({ bottom: 8 });
                Text('加载授权列表...').fontSize(13).fontColor('#666666');
              }.width('100%').height(100).justifyContent(FlexAlign.Center).backgroundColor('#FAFAFA').borderRadius(8);
            } else if (this.authItems.length === 0) {
              Row({ space: 8 }) {
                Text('\uD83D\uDD12').fontSize(20);
                Text('暂无授权记录').fontSize(13).fontColor('#999999').layoutWeight(1);
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FAFAFA')
              .borderRadius(8);
            } else {
              ForEach(this.authItems.slice(0, 5), (item: AuthItem) => {
                Row({ space: 10 }) {
                  Circle()
                    .width(8)
                    .height(8)
                    .fill(item.status === 'active' ? '#52C41A' : item.status === 'expired' ? '#999999' : '#FF4D4F')
                    .margin({ top: 3 });

                  Column({ space: 3 }) {
                    Row({ space: 6 }) {
                      Text(item.name)
                        .fontSize(13)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                        .maxLines(1)
                        .layoutWeight(1);

                      Text(item.type === 'DOCTOR' ? '\uD83D\uDC68\u200D⚕️' :
                           item.type === 'DEVICE' ? '\uD83D\uDCBB' :
                           item.type === 'APP' ? '\uD83D\uDCF2' : '\uD83D\uDCDE')
                        .fontSize(16);
                    }
                    .width('100%');

                    Row({ space: 6 }) {
                      Text(item.dataType)
                        .fontSize(11)
                        .fontColor('#1677FF')
                        .backgroundColor('#E6F7FF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4);

                      Text(item.status === 'active' ? '● 有效' : item.status === 'expired' ? '○ 已过期' : '✕ 已撤销')
                        .fontSize(11)
                        .fontColor(item.status === 'active' ? '#52C41A' : item.status === 'expired' ? '#999999' : '#FF4D4F');
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FAFAFA')
                .borderRadius(8)
                .margin({ top: 6 });
              }, (item: AuthItem) => item.id);
            }

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('查看全部授权管理')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Medium)
                .layoutWeight(1);
              Text('\u203A').fontSize(18).fontColor('#1677FF').fontWeight(FontWeight.Bold);
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingSM(this.isElderMode))
            .backgroundColor('#E6F4FF')
            .borderRadius(8)
            .margin({ top: 10 })
            .onClick(() => this.viewDataAuth());
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDCDE 操作审计日志')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1);

              Text('\u{1F504}').fontSize(16).onClick(() => this.loadAccessLogs());
            }
            .width('100%')
            .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

            Text('时间线显示谁在什么时候访问了什么数据')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

            if (this.isLoadingLogs) {
              Column() {
                LoadingProgress().width(24).height(24).color('#1677FF').margin({ bottom: 8 });
                Text('加载审计日志...').fontSize(13).fontColor('#666666');
              }.width('100%').height(100).justifyContent(FlexAlign.Center).backgroundColor('#FAFAFA').borderRadius(8);
            } else if (this.accessLogs.length === 0) {
              Row({ space: 8 }) {
                Text('\uD83D\uDCDD').fontSize(20);
                Text('暂无访问记录').fontSize(13).fontColor('#999999').layoutWeight(1);
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FAFAFA')
              .borderRadius(8);
            } else {
              ForEach(this.accessLogs.slice(0, 8), (log: AccessLogItem) => {
                Row({ space: 10 }) {
                  Column() {
                    Text(log.action.charAt(0))
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .width(24)
                      .height(24)
                      .borderRadius(12)
                      .backgroundColor(log.action === '读取' ? '#1677FF' :
                                     log.action === '写入' ? '#52C41A' :
                                     log.action === '删除' ? '#FF4D4F' : '#FAAD14')
                      .textAlign(TextAlign.Center)
                      .fontWeight(FontWeight.Bold);
                  };

                  Column({ space: 4 }) {
                    Row({ space: 6 }) {
                      Text(log.accessUser)
                        .fontSize(13)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333');

                      Text(log.action + '了')
                        .fontSize(12)
                        .fontColor(log.action === '读取' ? '#1677FF' :
                                  log.action === '写入' ? '#52C41A' :
                                  log.action === '删除' ? '#FF4D4F' : '#666666');

                      Text(log.dataType)
                        .fontSize(11)
                        .fontColor('#1677FF')
                        .backgroundColor('#E6F7FF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .borderRadius(4);
                    }
                    .width('100%');

                    Row({ space: 8 }) {
                      Text(log.accessTime)
                        .fontSize(11)
                        .fontColor('#BBBBBB');

                      if (log.detail) {
                        Text('· ' + log.detail)
                          .fontSize(11)
                          .fontColor('#999999')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis });
                      }
                    }
                    .width('100%');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FAFAFA')
                .borderRadius(8)
                .margin({ top: 6 });
              }, (log: AccessLogItem) => String(log.id));
            }
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column() {
            Text('\uD83D\uDD11 账户安全')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('\uD83D\uDD11')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode));
              Column({ space: 4 }) {
                Text('修改密码')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium);
                Text('定期更换保障账户安全')
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
                Text('退出登录')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#FF4D4F')
                  .fontWeight(FontWeight.Medium);
                Text('切换到其他账号')
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

  @Builder
  buildSettingRow(key: string, label: string, isEnabled: boolean, onToggle: () => void) {
    Column({ space: 8 }) {
      Row({ space: 12 }) {
        Text(this.getSettingIcon(key))
          .fontSize(22);

        Column({ space: 3 }) {
          Text(label)
            .fontSize(this.isElderMode ? 15 : 14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333');

          Text(this.getSettingDescription(key))
            .fontSize(11)
            .fontColor('#BBBBBB')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Toggle({ type: ToggleType.Switch, isOn: isEnabled })
          .selectedColor('#1677FF')
          .switchPointColor('#FFFFFF')
          .onChange((isOn: boolean) => {
            console.info('[PrivacySetting] ' + label + ' 开关变化: ' + isOn);
            onToggle();
          });
      }
      .width('100%')
      .padding({ left: 4, right: 4, top: 6, bottom: 6 });
    }
    .width('100%')
    .padding(12)
    .backgroundColor(isEnabled ? '#F6FFED' : '#FFF7F7')
    .borderRadius(8)
    .border({ width: 1, color: isEnabled ? '#B7EB8F' : '#FFCCC7' })
    .margin({ top: 6 });
  }
}
