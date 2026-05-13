import { router } from '@kit.ArkUI';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';

class PatientConvItem {
  otherUserId: number = 0;
  otherUserName: string = '';
  otherUserType: number = 0; // 0=患者, 1=家属
  lastMessage: string = '';
  lastTime: string = '';
  unreadCount: number = 0;
  remainHours: number = 0;
  expireTime: string = '';
}

@Entry
@Component
struct DoctorHomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State doctorName: string = '医生';
  @State doctorInfo: DoctorInfo | null = null;
  @State conversations: PatientConvItem[] = [];
  @State isLoading: boolean = true;
  @State showDeleteDialog: boolean = false;
  @State deleteTarget: PatientConvItem | null = null;
  @State totalUnread: number = 0;

  private scroller: Scroller = new Scroller();
  private pollTimerId: number = -1;

  aboutToAppear(): void {
    this.loadDoctorInfo();
    this.loadConversations();
    this.startPolling();
  }

  aboutToDisappear(): void {
    this.stopPolling();
  }

  private startPolling(): void {
    this.pollTimerId = setInterval(() => {
      this.loadConversations();
    }, 5000);
  }

  private stopPolling(): void {
    if (this.pollTimerId !== -1) {
      clearInterval(this.pollTimerId);
      this.pollTimerId = -1;
    }
  }

  private loadDoctorInfo(): void {
    const settings: SettingsUtil = SettingsUtil.getInstance();
    settings.getUserInfo().then((info: PersistedUserInfo | null) => {
      if (info && info.doctorInfo) {
        this.doctorName = info.doctorInfo.realName || info.username || '医生';
        const docInfo: DoctorInfo = new DoctorInfo();
        docInfo.realName = info.doctorInfo.realName || '';
        docInfo.phone = info.doctorInfo.phone || '';
        docInfo.hospital = info.doctorInfo.hospital || '';
        docInfo.department = info.doctorInfo.department || '';
        docInfo.licenseNumber = info.doctorInfo.licenseNumber || '';
        docInfo.title = info.doctorInfo.title || '';
        docInfo.specialty = info.doctorInfo.specialty || '';
        docInfo.avatar = info.doctorInfo.avatar || '';
        docInfo.description = info.doctorInfo.description || '';
        docInfo.rating = info.doctorInfo.rating || 0;
        docInfo.status = info.doctorInfo.status || 0;
        if (info.doctorInfo.id) { docInfo.id = info.doctorInfo.id; }
        if (info.userId) { docInfo.userId = info.userId; }
        this.doctorInfo = docInfo;
      } else if (info && info.username) {
        this.doctorName = info.username;
      }
    }).catch(() => {});
  }

  private loadConversations(): void {
    const params: Record<string, string> = {
      'doctorId': this.currentUserId.toString()
    };
    HttpUtil.get<PatientConvItem[]>(ApiConstants.DOCTOR_PATIENTS, params as Object)
      .then((response) => {
        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          const list: PatientConvItem[] = [];
          let unread: number = 0;
          for (let i: number = 0; i < rawData.length; i++) {
            const item: PatientConvItem = new PatientConvItem();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['otherUserId'] !== undefined) { item.otherUserId = raw['otherUserId'] as number; }
            if (raw['otherUserName'] !== undefined) { item.otherUserName = raw['otherUserName'] as string; }
            if (raw['otherUserType'] !== undefined) { item.otherUserType = raw['otherUserType'] as number; }
            if (raw['lastMessage'] !== undefined) { item.lastMessage = raw['lastMessage'] as string; }
            if (raw['lastTime'] !== undefined) { item.lastTime = raw['lastTime'] as string; }
            if (raw['unreadCount'] !== undefined) { item.unreadCount = raw['unreadCount'] as number; }
            if (raw['remainHours'] !== undefined) { item.remainHours = raw['remainHours'] as number; }
            if (raw['expireTime'] !== undefined) { item.expireTime = raw['expireTime'] as string; }
            list.push(item);
            unread += item.unreadCount;
          }
          this.conversations = list;
          this.totalUnread = unread;
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorHomePage] 加载患者列表失败:', err.message);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  private deleteConversation(): void {
    if (!this.deleteTarget) { return; }
    const params: Record<string, string> = {
      'userA': this.currentUserId.toString(),
      'userB': this.deleteTarget.otherUserId.toString()
    };
    HttpUtil.delete<Record<string, Object>>(ApiConstants.MESSAGE_DELETE, params as Object)
      .then((response) => {
        if (response.success) {
          const list: PatientConvItem[] = [];
          for (let i: number = 0; i < this.conversations.length; i++) {
            if (this.conversations[i].otherUserId !== this.deleteTarget!.otherUserId) {
              list.push(this.conversations[i]);
            }
          }
          this.conversations = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorHomePage] 删除对话失败:', err.message);
      })
      .finally(() => {
        this.showDeleteDialog = false;
        this.deleteTarget = null;
      });
  }

  private formatTime(timeStr: string): string {
    if (!timeStr) { return ''; }
    const date: Date = new Date(timeStr);
    const now: Date = new Date();
    const diffMs: number = now.getTime() - date.getTime();
    const diffMin: number = Math.floor(diffMs / 60000);
    if (diffMin < 1) { return '刚刚'; }
    if (diffMin < 60) { return diffMin + '分钟前'; }
    const diffHour: number = Math.floor(diffMin / 60);
    if (diffHour < 24) { return diffHour + '小时前'; }
    const diffDay: number = Math.floor(diffHour / 24);
    return diffDay + '天前';
  }

  private formatRemainHours(hours: number): string {
    if (hours <= 0) { return '即将过期'; }
    if (hours < 1) { return '不足1小时'; }
    if (hours < 24) { return '剩余' + hours + '小时'; }
    const days: number = Math.floor(hours / 24);
    const remainH: number = hours % 24;
    return '剩余' + days + '天' + (remainH > 0 ? remainH + '小时' : '');
  }

  build() {
    Column() {
      Row() {
        Text('👨‍⚕️')
          .fontSize(24);
        Text(this.doctorName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ left: 8 });
        if (this.doctorInfo) {
          Text(DoctorInfoHelper.getDisplayTitle(this.doctorInfo))
            .fontSize(13)
            .fontColor('#FFFFFFCC')
            .margin({ left: 8 });
        } else {
          Text('医生工作台')
            .fontSize(13)
            .fontColor('#FFFFFFCC')
            .margin({ left: 8 });
        }
        Blank();
        Text('退出')
          .fontSize(14)
          .fontColor('#FFFFFFCC')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(14)
          .backgroundColor('#FFFFFF22')
          .onClick(() => {
            const settings: SettingsUtil = SettingsUtil.getInstance();
            settings.clearAllLoginData().then(() => {
              router.replaceUrl({ url: 'pages/Login' });
            }).catch(() => {
              router.replaceUrl({ url: 'pages/Login' });
            });
          });
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .linearGradient({ angle: 135, colors: [['#1677FF', 0], ['#0958D9', 1]] });

      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('患者咨询')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
            Text('仅可回复已联系您的患者')
              .fontSize(12)
              .fontColor('#FFFFFFAA');
          }
          .alignItems(HorizontalAlign.Start);

          Blank();

          if (this.totalUnread > 0) {
            Badge({
              value: this.totalUnread > 99 ? '99+' : this.totalUnread.toString(),
              position: BadgePosition.RightTop,
              style: { fontSize: 10, badgeSize: 18, badgeColor: '#FF4D4F' }
            }) {
              Text('💬')
                .fontSize(36);
            }
          } else {
            Text('💬')
              .fontSize(36);
          }
        }
        .width('100%')
        .padding(20);

        Row({ space: 12 }) {
          Column() {
            Text(this.conversations.length.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
            Text('活跃患者')
              .fontSize(11)
              .fontColor('#FFFFFFAA');
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(12)
          .backgroundColor('#FFFFFF15');

          Column() {
            Text(this.totalUnread.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
            Text('未读消息')
              .fontSize(11)
              .fontColor('#FFFFFFAA');
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(12)
          .backgroundColor('#FFFFFF15');

          Column() {
            Text('48h')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
            Text('对话有效期')
              .fontSize(11)
              .fontColor('#FFFFFFAA');
          }
          .layoutWeight(1)
          .padding({ top: 12, bottom: 12 })
          .borderRadius(12)
          .backgroundColor('#FFFFFF15');
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 });
      }
      .width('100%')
      .linearGradient({ angle: 135, colors: [['#1677FF', 0], ['#36CFC9', 1]] })
      .borderRadius({ bottomLeft: 24, bottomRight: 24 });

      if (this.doctorInfo) {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(DoctorInfoHelper.getDisplayHospital(this.doctorInfo) || '未填写')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333');
            Text('所属医院')
              .fontSize(11)
              .fontColor('#999999');
          }
          .layoutWeight(1)
          .padding(12)
          .borderRadius(10)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column({ space: 4 }) {
            Text(this.doctorInfo.department || '未填写')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333');
            Text('科室')
              .fontSize(11)
              .fontColor('#999999');
          }
          .layoutWeight(1)
          .padding(12)
          .borderRadius(10)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });

          Column({ space: 4 }) {
            Text(this.doctorInfo.title || '未填写')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333');
            Text('职称')
              .fontSize(11)
              .fontColor('#999999');
          }
          .layoutWeight(1)
          .padding(12)
          .borderRadius(10)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 6 });
      }

      Row() {
        Text('⚠️ 对话规则：患者主动联系后，您才可回复；对话48小时后自动消失')
          .fontSize(11)
          .fontColor('#FAAD14')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 6 })
      .backgroundColor('#FFFBE6');

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        this.buildConversationList();
      }

      if (this.showDeleteDialog) {
        this.buildDeleteDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildConversationList() {
    if (this.conversations.length === 0) {
      Column() {
        Text('🩺')
          .fontSize(56)
          .margin({ bottom: 16 });
        Text('暂无患者咨询')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 8 });
        Text('患者主动联系您后，对话将在此显示')
          .fontSize(13)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .width('75%')
          .lineHeight(20);
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center);
    } else {
      Scroll(this.scroller) {
        Column() {
          ForEach(this.conversations, (conv: PatientConvItem) => {
            Column() {
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  Circle()
                    .width(50)
                    .height(50)
                    .fill('#36CFC9');
                  Text(conv.otherUserName.charAt(0))
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF');
                }
                .margin({ right: 14 });

                Column({ space: 4 }) {
                  Row() {
                    Text(conv.otherUserName)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333');

                    Text(conv.otherUserType === 1 ? '家属' : '患者')
                      .fontSize(11)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor(conv.otherUserType === 1 ? '#FA8C16' : '#36CFC9')
                      .borderRadius(4)
                      .margin({ left: 8 });

                    Blank();

                    Text(this.formatTime(conv.lastTime))
                      .fontSize(11)
                      .fontColor('#BBBBBB');
                  }
                  .width('100%');

                  Row() {
                    Text(conv.lastMessage.length > 20 ? conv.lastMessage.substring(0, 20) + '...' : conv.lastMessage)
                      .fontSize(13)
                      .fontColor('#888888')
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });

                    if (conv.unreadCount > 0) {
                      Text(conv.unreadCount > 99 ? '99+' : conv.unreadCount.toString())
                        .fontSize(11)
                        .fontColor('#FFFFFF')
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor('#FF4D4F')
                        .borderRadius(10);
                    }
                  }
                  .width('100%');

                  Row() {
                    Text('⏱️ ' + this.formatRemainHours(conv.remainHours))
                      .fontSize(11)
                      .fontColor(conv.remainHours < 6 ? '#FF4D4F' : (conv.remainHours < 12 ? '#FAAD14' : '#52C41A'));
                  }
                  .width('100%');
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);

                Text('🗑️')
                  .fontSize(18)
                  .padding({ left: 8, right: 4, top: 4, bottom: 4 })
                  .onClick(() => {
                    this.deleteTarget = conv;
                    this.showDeleteDialog = true;
                  });
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/DoctorPatientManagementPage',
                  params: {
                    patientId: conv.otherUserId,
                    patientName: conv.otherUserName,
                    doctorId: this.currentUserId,
                    doctorName: this.doctorName
                  }
                });
              });

              Row() {
                Button(conv.otherUserType === 1 ? '回复家属' : '回复患者')
                  .height(32)
                  .padding({ left: 16, right: 16 })
                  .fontSize(13)
                  .fontColor('#1677FF')
                  .backgroundColor('#E8F0FF')
                  .borderRadius(16)
                  .onClick(() => {
                    if (conv.otherUserType === 1) {
                      router.push({
                        url: 'pages/DoctorFamilyChatPage',
                        params: {
                          doctorId: this.currentUserId,
                          doctorName: this.doctorName,
                          currentUserId: this.currentUserId,
                          otherUserId: conv.otherUserId,
                          otherUserName: conv.otherUserName,
                          otherUserType: 'family'
                        }
                      });
                    } else {
                      router.push({
                        url: 'pages/DoctorChatPage',
                        params: {
                          doctorId: this.currentUserId,
                          doctorName: this.doctorName,
                          currentUserId: this.currentUserId,
                          otherUserId: conv.otherUserId,
                          otherUserName: conv.otherUserName,
                          isDoctor: true
                        }
                      });
                    }
                  });
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
              .margin({ top: 8 });
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: 10 })
            .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 });
          }, (conv: PatientConvItem) => conv.otherUserId.toString());
        }
        .width('85%')
        .padding({ top: 8, bottom: 48 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off);
    }
  }

  @Builder
  buildDeleteDialog() {
    Column() {
      Column() {
        Text('确认删除')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 12 });

        Text('确定要删除与患者 ' + (this.deleteTarget ? this.deleteTarget.otherUserName : '') + ' 的所有对话记录吗？此操作不可恢复。')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 24 })
          .width('100%');

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(40)
            .fontSize(15)
            .fontColor('#666666')
            .backgroundColor('#F0F2F5')
            .borderRadius(20)
            .onClick(() => {
              this.showDeleteDialog = false;
              this.deleteTarget = null;
            });

          Button('删除')
            .layoutWeight(1)
            .height(40)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .onClick(() => {
              this.deleteConversation();
            });
        }
        .width('100%');
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .shadow({ radius: 20, color: '#00000020', offsetX: 0, offsetY: 10 });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#00000066')
    .position({ x: 0, y: 0 })
    .onClick(() => {
      this.showDeleteDialog = false;
      this.deleteTarget = null;
    });
  }
}
