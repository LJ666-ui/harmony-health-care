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
  status: 'active' | 'expired' | 'revoked';
  authStartTime: string;
  authEndTime: string;
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

  @State authRecords: DataShareAuth[] = [];
  @State accessLogs: DataAccessLog[] = [];
  @State isLoadingAuths: boolean = true;
  @State isLoadingLogs: boolean = true;
  @State showNewAuthDialog: boolean = false;

  private getActiveAuthCount(): number {
    let count = 0;
    for (let i = 0; i < this.authRecords.length; i++) {
      if (this.authRecords[i].status === 'active') {
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

    this.loadAuthList();
    this.loadAccessLogs();
  }

  async loadAuthList(): Promise<void> {
    this.isLoadingAuths = true;
    try {
      const response: BaseResponse<DataShareAuth[]> = await HttpUtil.get<DataShareAuth[]>(ApiConstants.PRIVACY_AUTH_LIST);
      if (response.success && response.data) {
        const list: DataShareAuth[] = response.data;
        this.authRecords = [];
        for (let i = 0; i < list.length; i++) {
          this.authRecords.push(list[i]);
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
      const response: BaseResponse<DataAccessLog[]> = await HttpUtil.get<DataAccessLog[]>(ApiConstants.PRIVACY_ACCESS_LOGS);
      if (response.success && response.data) {
        const list: DataAccessLog[] = response.data;
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

  async revokeAuth(record: DataShareAuth): Promise<void> {
    promptAction.showDialog({
      title: '\u64A4\u9500\u6388\u6743',
      message: '\u786E\u5B9A\u8981\u64A4\u9500\u5BF9 ' + record.authUserName + ' \u7684\u6570\u636E\u6388\u6743\u5417?',
      buttons: [{ text: '\u53D6\u6D88', color: '#999999' }, { text: '\u786E\u5B9A\u64A4\u9500', color: '#FF4D4F' }]
    }).then(async (result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        try {
          const url: string = ApiConstants.PRIVACY_REVOKE_AUTH + '?authId=' + record.id;
          const response: BaseResponse<Record<string, Object>> = await HttpUtil.post<Record<string, Object>>(url, {} as Record<string, Object>);
          if (response.success) {
            record.status = 'revoked';
            ToastUtil.operationSuccess('\u5DF2\u64A4\u9500\u6388\u6743');
            this.loadAccessLogs();
          } else {
            ToastUtil.showSuccess(response.message ? response.message : '\u64A4\u9500\u5931\u8D25');
          }
        } catch (e) {
          console.error('\u64A4\u9500\u6388\u6743\u5931\u8D25:', e);
          ToastUtil.showSuccess('\u64A4\u9502\u6388\u6743\u5931\u8D25');
        }
      }
    }).catch((error: Error) => {
      console.error('显示撤销授权对话框失败:', error.message);
    });
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'active': return '#52C41A';
      case 'expired': return '#999999';
      case 'revoked': return '#FF4D4F';
      default: return '#999999';
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'active': return '\u6709\u6548';
      case 'expired': return '\u5DF2\u8FC7\u671F';
      case 'revoked': return '\u5DF2\u64A4\u9500';
      default: return '\u672A\u77E5';
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

  getDoctorAvatar(name: string): string {
    const hash: number = name.charCodeAt(0) % 4;
    const avatars: string[] = ['\uD83E\uDDD1\u200D\u2642\uFE0F', '\uD83E\uDDD1\u200D\u2640\uFE0F', '\uD83E\uDDD1\u200D\u2642\uFE0F', '\uD83E\uDDD1\u200D\u2640\uFE0F'];
    return avatars[hash];
  }

  getActionColor(action: string): string {
    switch (action) {
      case '\u8BFB\u53D6': return '#1677FF';
      case '\u5199\u5165': return '#52C41A';
      case '\u5220\u9664': return '#FF4D4F';
      case '\u5224\u65AD': return '#FAAD14';
      default: return '#666666';
    }
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '\u6570\u636E\u6388\u6743\u7BA1\u7406', showBack: true });

        Scroll() {
          Column({ space: 16 }) {

            Column({ space: 12 }) {
              Row() {
                Text('\uD83D\uDCDB \u6211\u7684\u6388\u6743\u5217\u8868')
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
                  LoadingProgress().width(32).height(32).color('#1677FF');
                  Text('\u52A0\u8F7D\u4E2D...').fontSize(14).fontColor('#666666').margin({ top: 10 });
                }.width('100%').height(150).justifyContent(FlexAlign.Center);
              } else if (this.authRecords.length === 0) {
                Column({ space: 12 }) {
                  Text('\uD83D\uDD12')
                    .fontSize(48);
                  Text('\u6682\u65E0\u6388\u6743\u8BB0\u5F55')
                    .fontSize(15)
                    .fontColor('#999999');
                  Text('\u60A8\u53EF\u4EE5\u5728\u6B64\u7BA1\u7406\u5BF9\u533B\u751F\u7684\u6570\u636E\u6388\u6743')
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

            Column({ space: 12 }) {
              Row() {
                Text('\uD83D\uDCDE \u64CD\u4F5BA5BA\u8BA1\u65E5\u5FD7')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .layoutWeight(1);

                Text('\u5171 ' + this.accessLogs.length + ' \u6761')
                  .fontSize(12)
                  .fontColor('#999999')
                  .backgroundColor('#F5F5F5')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(12);
              }
              .width('100%');

              if (this.isLoadingLogs) {
                Column() {
                  LoadingProgress().width(32).height(32).color('#1677FF');
                  Text('\u52A0\u8F7D\u4E2D...').fontSize(14).fontColor('#666666').margin({ top: 10 });
                }.width('100%').height(120).justifyContent(FlexAlign.Center);
              } else if (this.accessLogs.length === 0) {
                Text('\u6682\u65E0\u8BBF\u95EE\u8BB0\u5F55')
                  .fontSize(14)
                  .fontColor('#BBBBBB')
                  .padding(30)
                  .width('100%')
                  .textAlign(TextAlign.Center);
              } else {
                ForEach(this.accessLogs.slice(0, 15), (log: DataAccessLog) => {
                  Row({ space: 10 }) {
                    Column() {
                      Text(log.action.charAt(0))
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                        .width(26)
                        .height(26)
                        .borderRadius(13)
                        .backgroundColor(this.getActionColor(log.action))
                        .textAlign(TextAlign.Center);
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
                }, (log: DataAccessLog) => String(log.id));
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

            Column({ space: 10 }) {
              Text('\uD83D\uDCCA \u6388\u6743\u8BF4\u660E')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              ForEach([
                '\u6388\u6743\u540E\uFF0C\u9009\u5B9A\u7684\u533B\u751F\u53EF\u67E5\u770B\u60A8\u6307\u5B9A\u7684\u5065\u5EBB\u6570\u636E\u7C7B\u578B',
                '\u60A8\u53EF\u4EE5\u968F\u65F6\u64A4\u9500\u5DF2\u6388\u4E88\u7684\u6388\u6743',
                '\u6388\u6743\u5230\u671F\u540E\uFF0C\u533B\u751F\u5C06\u65E0\u6CD5\u7EE7\u7EED\u8BBF\u95EE\u60A8\u7684\u6570\u636E',
                '\u6240\u6709\u6388\u6743\u64CD\u4F5C\u90FD\u4F1A\u88AB\u8BB0\u5F55\u5728\u8BBF\u95EE\u65E5\u5FD7\u4E2D'
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
            Text('\u5269\u4F59 ' + this.getRemainingDays(record.authEndTime) + ' \u5929')
              .fontSize(10)
              .fontColor(this.getRemainingDays(record.authEndTime) <= 3 ? '#FAAD14' : '#52C41A');
          }
        }
        .alignItems(HorizontalAlign.End);
      }
      .width('100%');

      Row({ space: 6 }) {
        Text('\uD83D\uDCC1 \u6388\u6743\u6570\u636E\uFF1A')
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
          Button('\u64A4\u9500')
            .height(28)
            .fontSize(11)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF1F0')
            .borderRadius(14)
            .border({ width: 1, color: '#FFCCC7' })
            .onClick(() => {
              this.revokeAuth(record);
            });
        }
      }
      .width('100%');
    }
    .width('100%')
    .padding(14)
    .backgroundColor(record.status === 'revoked' ? '#FFF7F7' : record.status === 'expired' ? '#FAFAFA' : '#FFFFFF')
    .borderRadius(10)
    .border({ width: 1, color: record.status === 'active' ? '#D6E4FF' : '#F0F0F0' });
  }
}