import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

export interface DataShareAuth {
  id: number;
  authUserId: number;
  authUserName: string;
  authUserHospital: string;
  dataType: string;
  status: 'active' | 'expired' | 'revoked' | 'pending';
  authStartTime: string;
  authEndTime: string;
  applyReason?: string;
}

export interface PendingAuthRequest {
  id: number;
  applicantName: string;
  applicantType: string;
  applicantHospital?: string;
  dataType: string;
  applyTime: string;
  reason: string;
}

export interface DataAccessLog {
  id: number;
  accessUserId: number;
  accessUserName: string;
  dataType: string;
  action: string;
  accessTime: string;
  detail: string;
}

@Entry
@Component
struct DataAuthPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentTab: number = 0;
  @State authRecords: DataShareAuth[] = [];
  @State pendingRequests: PendingAuthRequest[] = [];
  @State accessLogs: DataAccessLog[] = [];
  @State isLoadingAuths: boolean = true;
  @State isLoadingPending: boolean = true;
  @State isLoadingLogs: boolean = true;

  private getActiveAuthCount(): number {
    let count = 0;
    for (let i = 0; i < this.authRecords.length; i++) {
      if (this.authRecords[i].status === 'active') {
        count++;
      }
    }
    return count;
  }

  private getPendingCount(): number {
    return this.pendingRequests.length;
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    console.info('[DataAuth] 页面初始化，开始加载数据...');
    this.loadAuthList();
    this.loadPendingRequests();
    this.loadAccessLogs();
  }

  async loadAuthList(): Promise<void> {
    this.isLoadingAuths = true;
    try {
      console.info('[DataAuth] 开始请求 GET /api/privacy/auth-list ...');
      const response: BaseResponse<DataShareAuth[]> = await HttpUtil.get<DataShareAuth[]>(ApiConstants.PRIVACY_AUTH_LIST);
      console.info('[DataAuth] /api/privacy/auth-list 响应: success=' + response.success +
        ' dataLength=' + (Array.isArray(response.data) ? response.data.length : 0));

      if (response.success && response.data) {
        const list: DataShareAuth[] = response.data;
        this.authRecords = [];
        for (let i = 0; i < list.length; i++) {
          this.authRecords.push(list[i]);
          console.info('[DataAuth] 授权记录[' + i + ']: name=' + list[i].authUserName +
            ' status=' + list[i].status + ' dataType=' + list[i].dataType);
        }
      }
    } catch (e) {
      console.error('[DataAuth] 加载授权列表失败:', JSON.stringify(e));
    } finally {
      this.isLoadingAuths = false;
    }
  }

  async loadPendingRequests(): Promise<void> {
    this.isLoadingPending = true;
    try {
      console.info('[DataAuth] 开始请求待审批列表...');

      const pendingList: PendingAuthRequest[] = [
        {
          id: 1,
          applicantName: '赵医师',
          applicantType: 'DOCTOR',
          applicantHospital: '协和医院',
          dataType: '血压记录,血糖记录',
          applyTime: '2026-04-20 09:30:00',
          reason: '需要查看患者近期血压血糖数据以调整治疗方案'
        },
        {
          id: 2,
          applicantName: '智能手环Pro',
          applicantType: 'DEVICE',
          dataType: '运动数据,睡眠数据',
          applyTime: '2026-04-19 16:20:00',
          reason: '设备需要同步健康数据进行智能分析'
        }
      ];

      this.pendingRequests = [];
      for (let i = 0; i < pendingList.length; i++) {
        this.pendingRequests.push(pendingList[i]);
      }
      console.info('[DataAuth] 待审批请求数: ' + this.pendingRequests.length);
    } catch (e) {
      console.error('[DataAuth] 加载待审批请求失败:', JSON.stringify(e));
    } finally {
      this.isLoadingPending = false;
    }
  }

  async loadAccessLogs(): Promise<void> {
    this.isLoadingLogs = true;
    try {
      console.info('[DataAuth] 开始请求 GET /api/privacy/logs ...');
      const response: BaseResponse<DataAccessLog[]> = await HttpUtil.get<DataAccessLog[]>(ApiConstants.PRIVACY_LOGS);
      console.info('[DataAuth] /api/privacy/logs 响应: success=' + response.success +
        ' dataLength=' + (Array.isArray(response.data) ? response.data.length : 0));

      if (response.success && response.data) {
        const list: DataAccessLog[] = response.data;
        this.accessLogs = [];
        for (let i = 0; i < list.length; i++) {
          this.accessLogs.push(list[i]);
        }
      }
    } catch (e) {
      console.error('[DataAuth] 加载访问日志失败:', JSON.stringify(e));
    } finally {
      this.isLoadingLogs = false;
    }
  }

  async approveAuth(request: PendingAuthRequest): Promise<void> {
    promptAction.showDialog({
      title: '批准授权申请',
      message: '确定要批准 ' + request.applicantName + ' 的数据访问申请吗?\n\n授权数据类型: ' + request.dataType + '\n申请理由: ' + request.reason,
      buttons: [{ text: '拒绝', color: '#999999' }, { text: '批准', color: '#52C41A' }]
    }).then(async (result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        try {
          console.info('[DataAuth] 开始请求 POST /api/privacy/approve ...');
          const approveData: Record<string, Object> = {};
          approveData['requestId'] = request.id;
          approveData['applicantName'] = request.applicantName;
          approveData['dataType'] = request.dataType;

          const response: BaseResponse<Record<string, Object>> = await HttpUtil.post<Record<string, Object>>(ApiConstants.PRIVACY_APPROVE, approveData);
          console.info('[DataAuth] POST /api/privacy/approve 响应: success=' + response.success);

          if (response.success) {
            console.info('[DataAuth] ✓ 批准授权成功');
            ToastUtil.showSuccess('已批准 ' + request.applicantName + ' 的授权申请');

            const filtered: PendingAuthRequest[] = [];
            for (let i = 0; i < this.pendingRequests.length; i++) {
              if (this.pendingRequests[i].id !== request.id) {
                filtered.push(this.pendingRequests[i]);
              }
            }
            this.pendingRequests = filtered;

            this.loadAuthList();
            this.loadAccessLogs();
          } else {
            console.warn('[DataAuth] 批准授权失败: ' + response.message);
            ToastUtil.showError(response.message ? response.message : '批准失败，请重试');
          }
        } catch (e) {
          console.error('[DataAuth] 批准授权异常:', JSON.stringify(e));
          ToastUtil.showError('网络错误，请检查连接后重试');
        }
      } else if (result.index === 0) {
        this.rejectAuth(request);
      }
    }).catch((error: Error) => {
      console.error('[DataAuth] 显示批准对话框失败:', error.message);
    });
  }

  async rejectAuth(request: PendingAuthRequest): Promise<void> {
    try {
      console.info('[DataAuth] 拒绝授权申请: ' + request.applicantName);

      const filtered: PendingAuthRequest[] = [];
      for (let i = 0; i < this.pendingRequests.length; i++) {
        if (this.pendingRequests[i].id !== request.id) {
          filtered.push(this.pendingRequests[i]);
        }
      }
      this.pendingRequests = filtered;

      ToastUtil.showInfo('已拒绝 ' + request.applicantName + ' 的申请');
    } catch (e) {
      console.error('[DataAuth] 拒绝授权失败:', e);
    }
  }

  async revokeAuth(record: DataShareAuth): Promise<void> {
    promptAction.showDialog({
      title: '撤销授权',
      message: '确定要撤销对 ' + record.authUserName + ' 的数据授权吗?\n\n撤销后将无法继续访问您的: ' + record.dataType,
      buttons: [{ text: '取消', color: '#999999' }, { text: '确定撤销', color: '#FF4D4F' }]
    }).then(async (result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        try {
          console.info('[DataAuth] 开始请求 POST /api/privacy/revoke ...');
          const url: string = ApiConstants.PRIVACY_REVOKE + '?authId=' + record.id;
          const response: BaseResponse<Record<string, Object>> = await HttpUtil.post<Record<string, Object>>(url, {} as Record<string, Object>);
          console.info('[DataAuth] POST /api/privacy/revoke 响应: success=' + response.success);

          if (response.success) {
            record.status = 'revoked';
            console.info('[DataAuth] ✓ 撤销授权成功');
            ToastUtil.showSuccess('已撤销 ' + record.authUserName + ' 的数据授权');
            this.loadAccessLogs();
          } else {
            console.warn('[DataAuth] 撤销授权失败: ' + response.message);
            ToastUtil.showError(response.message ? response.message : '撤销失败，请重试');
          }
        } catch (e) {
          console.error('[DataAuth] 撤销授权异常:', JSON.stringify(e));
          ToastUtil.showError('网络错误，请检查连接后重试');
        }
      }
    }).catch((error: Error) => {
      console.error('[DataAuth] 显示撤销对话框失败:', error.message);
    });
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'active': return '#52C41A';
      case 'pending': return '#FAAD14';
      case 'expired': return '#999999';
      case 'revoked': return '#FF4D4F';
      default: return '#999999';
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'active': return '有效';
      case 'pending': return '待审批';
      case 'expired': return '已过期';
      case 'revoked': return '已撤销';
      default: return '未知';
    }
  }

  getRemainingDays(endDateStr: string): number {
    if (!endDateStr) return 0;
    try {
      let fixedDateStr = endDateStr.replace(/-/g, '/');
      const endDate: Date = new Date(fixedDateStr);
      const now: Date = new Date();
      const diffMs: number = endDate.getTime() - now.getTime();
      return Math.ceil(diffMs / (1000 * 60 * 60 * 24));
    } catch (e) {
      return 0;
    }
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '';
    let result = dateStr.substring(0, 10);
    result = result.replace(/-/g, '-');
    return result;
  }

  formatDateTime(dateStr: string): string {
    if (!dateStr) return '';
    return dateStr.substring(5, 16).replace(/-/g, '-');
  }

  getDoctorAvatar(name: string): string {
    const hash: number = name.charCodeAt(0) % 4;
    const avatars: string[] = ['\uD83E\uDDD1\u200D\u2642\uFE0F', '\uD83E\uDDD1\u200D\u2640\uFE0F', '\uD83E\uDDD1\u200D\u2642\uFE0F', '\uD83E\uDDD1\u200D\u2640\uFE0F'];
    return avatars[hash];
  }

  getActionColor(action: string): string {
    switch (action) {
      case '读取': return '#1677FF';
      case '写入': return '#52C41A';
      case '删除': return '#FF4D4F';
      case '判断': return '#FAAD14';
      default: return '#666666';
    }
  }

  getApplicantTypeIcon(type: string): string {
    switch (type) {
      case 'DOCTOR': return '\uD83D\uDC68\u200D⚕️';
      case 'DEVICE': return '\uD83D\uDCBB';
      case 'APP': return '\uD83D\uDCF2';
      case 'REHAB_CENTER': return '\uD83C\uDFE5';
      default: return '\uD83D\uDCDC';
    }
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '数据授权管理', showBack: true });

        Row({ space: 8 }) {
          Button('\uD83D\uDCDB 授权列表')
            .height(36)
            .fontSize(12)
            .fontColor(this.currentTab === 0 ? '#FFFFFF' : '#666666')
            .backgroundColor(this.currentTab === 0 ? '#1677FF' : '#F5F5F5')
            .borderRadius(18)
            .layoutWeight(1)
            .onClick(() => { this.currentTab = 0; });

          Button('\u{1F504} 审计日志')
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
        .backgroundColor('#FFFFFF');

        Scroll() {
          Column({ space: 16 }) {

            if (this.currentTab === 0) {

              if (this.getPendingCount() > 0) {
                Column({ space: 12 }) {
                  Row({ space: 10 }) {
                    Text('\u{1F514} 待审批申请')
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FAAD14')
                      .layoutWeight(1);

                    Text('' + this.getPendingCount() + ' 条待处理')
                      .fontSize(12)
                      .fontColor('#FAAD14')
                      .backgroundColor('#FFFBE6')
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .borderRadius(12)
                      .border({ width: 1, color: '#FFE58F' });
                  }
                  .width('100%');

                  if (this.isLoadingPending) {
                    Column() {
                      LoadingProgress().width(32).height(32).color('#FAAD14').margin({ bottom: 10 });
                      Text('加载待审批申请...').fontSize(13).fontColor('#666666');
                    }.width('100%').height(120).justifyContent(FlexAlign.Center).backgroundColor('#FFFBE6').borderRadius(8);
                  } else {
                    ForEach(this.pendingRequests, (request: PendingAuthRequest) => {
                      this.buildPendingCard(request);
                    }, (request: PendingAuthRequest) => String(request.id));
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFBE6')
                .borderRadius(12)
                .border({ width: 1, color: '#FFE58F' })
                .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
              }

              Column({ space: 12 }) {
                Row() {
                  Text('\uD83D\uDCDB 我的授权列表')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .layoutWeight(1);

                  Text('' + this.getActiveAuthCount() + ' 个有效')
                    .fontSize(12)
                    .fontColor('#52C41A')
                    .backgroundColor('#F6FFED')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .borderRadius(12);
                }
                .width('100%');

                if (this.isLoadingAuths) {
                  Column() {
                    LoadingProgress().width(32).height(32).color('#1677FF').margin({ bottom: 10 });
                    Text('加载授权列表...').fontSize(14).fontColor('#666666').margin({ top: 8 });
                  }.width('100%').height(150).justifyContent(FlexAlign.Center);
                } else if (this.authRecords.length === 0) {
                  Column({ space: 12 }) {
                    Text('\uD83D\uDD12').fontSize(48);
                    Text('暂无授权记录')
                      .fontSize(15)
                      .fontColor('#999999');
                    Text('您可以在此管理对医生的数据授权')
                      .fontSize(13)
                      .fontColor('#BBBBBB');
                  }.width('100%').height(220).justifyContent(FlexAlign.Center);
                } else {
                  ForEach(this.authRecords, (record: DataShareAuth) => {
                    this.buildAuthCard(record);
                  }, (record: DataShareAuth) => String(record.id));
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

              Column({ space: 10 }) {
                Text('\uD83D\uDCCA 授权说明')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%');

                ForEach([
                  '授权后，选定的医生可查看您指定的健康数据类型',
                  '您可以随时撤销已授予的授权',
                  '授权到期后，医生将无法继续访问您的数据',
                  '所有授权操作都会被记录在审计日志中'
                ], (tip: string, index: number) => {
                  Row({ space: 8 }) {
                    Text(String(index + 1) + '.')
                      .fontSize(13)
                      .fontColor('#1677FF')
                      .fontWeight(FontWeight.Medium);
                    Text(tip)
                      .fontSize(13)
                      .fontColor('#666666')
                      .lineHeight(20)
                      .layoutWeight(1);
                  }
                  .width('100%');
                }, (tip: string, index: number) => 'tip_' + index);
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#E6F7FF')
              .borderRadius(12);
            } else {

              Column({ space: 12 }) {
                Row() {
                  Text('\uD83D\uDCDE 操作审计日志')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .layoutWeight(1);

                  Text('\u{1F504}').fontSize(18).onClick(() => this.loadAccessLogs());

                  Text('共 ' + this.accessLogs.length + ' 条')
                    .fontSize(12)
                    .fontColor('#999999')
                    .backgroundColor('#F5F5F5')
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .borderRadius(12);
                }
                .width('100%');

                Text('时间线显示谁在什么时候访问了什么数据')
                  .fontSize(12)
                  .fontColor('#999999')
                  .width('100%')
                  .margin({ bottom: 8 });

                if (this.isLoadingLogs) {
                  Column() {
                    LoadingProgress().width(32).height(32).color('#1677FF').margin({ bottom: 10 });
                    Text('加载审计日志...').fontSize(14).fontColor('#666666').margin({ top: 8 });
                  }.width('100%').height(120).justifyContent(FlexAlign.Center);
                } else if (this.accessLogs.length === 0) {
                  Column({ space: 12 }) {
                    Text('\uD83D\uDCDD').fontSize(48);
                    Text('暂无访问记录')
                      .fontSize(15)
                      .fontColor('#999999');
                    Text('当有人访问您的数据时，会在此显示')
                      .fontSize(13)
                      .fontColor('#BBBBBB');
                  }.width('100%').height(180).justifyContent(FlexAlign.Center);
                } else {
                  ForEach(this.accessLogs.slice(0, 20), (log: DataAccessLog) => {
                    this.buildLogItem(log);
                  }, (log: DataAccessLog) => String(log.id));
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
            }
          }
          .width('85%')
          .padding({ top: 16, bottom: 100 });
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
    .width('100%')
    .height('100%');
  }

  @Builder
  buildPendingCard(request: PendingAuthRequest) {
    Column({ space: 10 }) {
      Row({ space: 12 }) {
        Text(this.getApplicantTypeIcon(request.applicantType))
          .fontSize(32);

        Column({ space: 3 }) {
          Text(request.applicantName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');

          Row({ space: 6 }) {
            Text(request.applicantType === 'DOCTOR' ? '医生' :
                 request.applicantType === 'DEVICE' ? '设备' :
                 request.applicantType === 'APP' ? '应用' : '机构')
              .fontSize(11)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4);

            if (request.applicantHospital) {
              Text(request.applicantHospital)
                .fontSize(11)
                .fontColor('#999999');
            }
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Text('\u{1F514}')
          .fontSize(24);
      }
      .width('100%');

      Column({ space: 6 }) {
        Row({ space: 6 }) {
          Text('\uD83D\uDCC1 申请数据:')
            .fontSize(12)
            .fontColor('#999999');

          Flex({ wrap: FlexWrap.Wrap }) {
            if (request.dataType) {
              ForEach(request.dataType.split(','), (type: string) => {
                Text(type.trim())
                  .fontSize(10)
                  .fontColor('#FAAD14')
                  .backgroundColor('#FFFBE6')
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .borderRadius(8)
                  .margin(2);
              }, (type: string) => type.trim());
            }
          }
          .layoutWeight(1);
        }
        .width('100%');

        Row({ space: 6 }) {
          Text('\uD83D\uDCAC 申请理由:')
            .fontSize(12)
            .fontColor('#999999');
          Text(request.reason)
            .fontSize(12)
            .fontColor('#666666')
            .lineHeight(18)
            .layoutWeight(1)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .width('100%');

        Text('\uD83D\uDCC5 申请时间: ' + this.formatDateTime(request.applyTime))
          .fontSize(11)
          .fontColor('#BBBBBB')
          .width('100%');
      }
      .width('100%');

      Row({ space: 12 }) {
        Button('拒绝')
          .height(32)
          .fontSize(13)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(16)
          .layoutWeight(1)
          .onClick(() => this.rejectAuth(request));

        Button('批准授权')
          .height(32)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(16)
          .layoutWeight(1)
          .onClick(() => this.approveAuth(request));
      }
      .width('100%');
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .border({ width: 2, color: '#FFE58F' });
  }

  @Builder
  buildAuthCard(record: DataShareAuth) {
    Column({ space: 10 }) {
      Row({ space: 12 }) {
        Text(this.getDoctorAvatar(record.authUserName))
          .fontSize(34);

        Column({ space: 3 }) {
          Text(record.authUserName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');

          if (record.authUserHospital) {
            Text(record.authUserHospital)
              .fontSize(12)
              .fontColor('#666666');
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Column({ space: 3 }) {
          Text(this.getStatusText(record.status))
            .fontSize(11)
            .fontColor(this.getStatusColor(record.status))
            .fontWeight(FontWeight.Medium);

          if (record.status === 'active') {
            Text('剩余 ' + this.getRemainingDays(record.authEndTime) + ' 天')
              .fontSize(10)
              .fontColor(this.getRemainingDays(record.authEndTime) <= 3 ? '#FAAD14' : '#52C41A');
          }
        }
        .alignItems(HorizontalAlign.End);
      }
      .width('100%');

      Row({ space: 6 }) {
        Text('\uD83D\uDCC1 授权数据:')
          .fontSize(12)
          .fontColor('#999999');

        Flex({ wrap: FlexWrap.Wrap }) {
          if (record.dataType) {
            ForEach(record.dataType.split(','), (type: string) => {
              Text(type.trim())
                .fontSize(10)
                .fontColor('#1677FF')
                .backgroundColor('#E6F7FF')
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .borderRadius(8)
                .margin(2);
            }, (type: string) => type.trim());
          }
        }
        .layoutWeight(1);
      }
      .width('100%');

      Row({ space: 12 }) {
        Text('\uD83D\uDCC5 ' + this.formatDate(record.authStartTime) + ' ~ ' + this.formatDate(record.authEndTime))
          .fontSize(11)
          .fontColor('#999999')
          .layoutWeight(1);

        if (record.status === 'active') {
          Button('撤销')
            .height(28)
            .fontSize(11)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF1F0')
            .borderRadius(14)
            .border({ width: 1, color: '#FFCCC7' })
            .onClick(() => {
              this.revokeAuth(record);
            });
        } else if (record.status === 'pending') {
          Button('审批')
            .height(28)
            .fontSize(11)
            .fontColor('#FAAD14')
            .backgroundColor('#FFFBE6')
            .borderRadius(14)
            .border({ width: 1, color: '#FFE58F' });
        }
      }
      .width('100%');
    }
    .width('100%')
    .padding(14)
    .backgroundColor(record.status === 'revoked' ? '#FFF7F7' : record.status === 'expired' ? '#FAFAFA' : '#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: record.status === 'active' ? '#D6E4FF' : record.status === 'pending' ? '#FFE58F' : '#F0F0F0' });
  }

  @Builder
  buildLogItem(log: DataAccessLog) {
    Row({ space: 10 }) {
      Column() {
        Text(log.action.charAt(0))
          .fontSize(14)
          .fontColor('#FFFFFF')
          .width(26)
          .height(26)
          .borderRadius(13)
          .backgroundColor(this.getActionColor(log.action))
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold);
      };

      Column({ space: 3 }) {
        Row({ space: 6 }) {
          Text(log.accessUserName)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333');

          Text(log.action)
            .fontSize(11)
            .fontColor(this.getActionColor(log.action));

          Text(log.dataType)
            .fontSize(11)
            .fontColor('#1677FF')
            .backgroundColor('#E6F7FF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(6);
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
    .padding(10)
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
    .margin({ top: 4 });
  }
}
