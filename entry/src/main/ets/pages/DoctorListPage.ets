import { router } from '@kit.ArkUI';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';

class ConversationItem {
  otherUserId: number = 0;
  otherUserName: string = '';
  lastMessage: string = '';
  lastTime: string = '';
  unreadCount: number = 0;
  remainHours: number = 0;
  expireTime: string = '';
}

@Entry
@Component
struct DoctorListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State conversations: ConversationItem[] = [];
  @State doctors: DoctorInfo[] = [];
  @State isLoading: boolean = true;
  @State activeTab: number = 0;
  @State searchKeyword: string = '';
  @State showDeleteDialog: boolean = false;
  @State deleteTarget: ConversationItem | null = null;
  @State shareMessage: string = '';
  @State fromFamily: boolean = false;
  @State familyId: number = 0;

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const params: Object | undefined = router.getParams();
    if (params) {
      const p: Record<string, Object> = params as Record<string, Object>;
      const shareMsg: string = p['shareMessage'] as string || '';
      if (shareMsg && shareMsg.trim() !== '') {
        this.shareMessage = shareMsg;
      }
      
      const fromFam: boolean = p['fromFamily'] as boolean || false;
      if (fromFam) {
        this.fromFamily = true;
        this.familyId = p['familyId'] as number || 0;
      }
    }
    this.loadData();
  }

  private loadData(): void {
    if (this.activeTab === 0) {
      this.loadConversations();
    } else {
      this.loadDoctors();
    }
  }

  private loadConversations(): void {
    this.isLoading = true;
    const params: Record<string, string> = {
      'userId': this.currentUserId.toString()
    };
    HttpUtil.get<ConversationItem[]>(ApiConstants.MESSAGE_CONVERSATIONS, params as Object)
      .then((response) => {
        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          const list: ConversationItem[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const item: ConversationItem = new ConversationItem();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['otherUserId'] !== undefined) { item.otherUserId = raw['otherUserId'] as number; }
            if (raw['otherUserName'] !== undefined) { item.otherUserName = raw['otherUserName'] as string; }
            if (raw['lastMessage'] !== undefined) { item.lastMessage = raw['lastMessage'] as string; }
            if (raw['lastTime'] !== undefined) { item.lastTime = raw['lastTime'] as string; }
            if (raw['unreadCount'] !== undefined) { item.unreadCount = raw['unreadCount'] as number; }
            if (raw['remainHours'] !== undefined) { item.remainHours = raw['remainHours'] as number; }
            if (raw['expireTime'] !== undefined) { item.expireTime = raw['expireTime'] as string; }
            list.push(item);
          }
          this.conversations = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorListPage] 加载会话列表失败:', err.message);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  private loadDoctors(keyword?: string): void {
    this.isLoading = true;
    const params: Record<string, string> = {};
    if (keyword && keyword.trim() !== '') {
      params['keyword'] = keyword.trim();
    }
    HttpUtil.get<DoctorInfo[]>(ApiConstants.DOCTOR_LIST, params as Object)
      .then((response) => {
        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          const list: DoctorInfo[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            list.push(DoctorInfoHelper.fromJson(raw));
          }
          this.doctors = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorListPage] 加载医生列表失败:', err.message);
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
          const list: ConversationItem[] = [];
          for (let i: number = 0; i < this.conversations.length; i++) {
            if (this.conversations[i].otherUserId !== this.deleteTarget!.otherUserId) {
              list.push(this.conversations[i]);
            }
          }
          this.conversations = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorListPage] 删除对话失败:', err.message);
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
    if (diffDay < 7) { return diffDay + '天前'; }
    const m: number = date.getMonth() + 1;
    const d: number = date.getDate();
    return m + '/' + d;
  }

  private formatRemainHours(hours: number): string {
    if (hours <= 0) { return '即将过期'; }
    if (hours < 1) { return '不足1小时'; }
    if (hours < 24) { return '剩余' + hours + '小时'; }
    const days: number = Math.floor(hours / 24);
    const remainH: number = hours % 24;
    return '剩余' + days + '天' + (remainH > 0 ? remainH + '小时' : '');
  }

  private maskPhone(phone: string): string {
    if (!phone || phone.length < 7) { return phone; }
    return phone.substring(0, 3) + '****' + phone.substring(phone.length - 4);
  }

  private navigateToDoctorChat(doctorId: number, doctorName: string): void {
    if (this.fromFamily) {
      router.push({
        url: 'pages/FamilyDoctorChatPage',
        params: {
          familyId: this.familyId || this.currentUserId,
          doctorId: doctorId,
          doctorName: doctorName,
          relatedPatientName: ''
        }
      });
    } else {
      if (this.shareMessage && this.shareMessage.trim() !== '') {
        router.push({
          url: 'pages/DoctorChatPage',
          params: {
            doctorId: doctorId,
            doctorName: doctorName,
            currentUserId: this.currentUserId,
            prefillMessage: this.shareMessage
          }
        });
      } else {
        router.push({
          url: 'pages/DoctorChatPage',
          params: {
            doctorId: doctorId,
            doctorName: doctorName,
            currentUserId: this.currentUserId
          }
        });
      }
    }
  }

  build() {
    Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.back();
          });
        Text('医患对话')
          .fontSize(18)
          .fontWeight('bold')
          .flexGrow(1)
          .textAlign(TextAlign.Center);
        Text('')
          .fontSize(16)
          .padding(12);
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      Column() {
        Text('💬 医患对话中心')
          .fontSize(22)
          .fontWeight('bold')
          .fontColor('#FFFFFF')
          .margin({ bottom: 4 });
        Text('与医生实时沟通，管理您的健康对话')
          .fontSize(13)
          .fontColor('#FFFFFFBB');
      }
      .width('100%')
      .padding(20)
      .linearGradient({
        angle: 135,
        colors: [['#1677FF', 0], ['#36CFC9', 1]]
      })
      .borderRadius({ bottomLeft: 24, bottomRight: 24 });

      Row() {
        Text('对话记录')
          .fontSize(15)
          .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.activeTab === 0 ? '#1677FF' : '#666666')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .borderRadius(8)
          .backgroundColor(this.activeTab === 0 ? '#E8F0FF' : '#FFFFFF')
          .onClick(() => {
            this.activeTab = 0;
            this.loadData();
          });

        Text('咨询医生')
          .fontSize(15)
          .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.activeTab === 1 ? '#1677FF' : '#666666')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .borderRadius(8)
          .backgroundColor(this.activeTab === 1 ? '#E8F0FF' : '#FFFFFF')
          .onClick(() => {
            this.activeTab = 1;
            this.loadData();
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF');

      if (this.activeTab === 1) {
        Row() {
          TextInput({ placeholder: '搜索医生姓名或手机号' })
            .layoutWeight(1)
            .height(42)
            .padding({ left: 16, right: 12 })
            .backgroundColor('#F5F5F5')
            .borderRadius(21)
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
            .onSubmit(() => {
              this.loadDoctors(this.searchKeyword);
            });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('#FFFFFF');
      }

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.activeTab === 0) {
        this.buildConversationList();
      } else {
        this.buildDoctorList();
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
        Text('💬')
          .fontSize(56)
          .margin({ bottom: 16 });
        Text('暂无对话记录')
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333')
          .margin({ bottom: 8 });
        Text('选择医生开始咨询，对话记录将在此显示')
          .fontSize(13)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .width('75%')
          .lineHeight(20);

        Button('去咨询医生')
          .height(40)
          .padding({ left: 24, right: 24 })
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(20)
          .margin({ top: 20 })
          .onClick(() => {
            this.activeTab = 1;
            this.loadData();
          });
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center);
    } else {
      Scroll(this.scroller) {
        Column() {
          ForEach(this.conversations, (conv: ConversationItem) => {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                Circle()
                  .width(50)
                  .height(50)
                  .fill('#1677FF');
                Text(conv.otherUserName.charAt(0))
                  .fontSize(20)
                  .fontWeight('bold')
                  .fontColor('#FFFFFF');
              }
              .margin({ right: 14 });

              Column({ space: 4 }) {
                Row() {
                  Text(conv.otherUserName + ' 医生')
                    .fontSize(16)
                    .fontWeight('bold')
                    .fontColor('#333333')
                    .layoutWeight(1);

                  Text(this.formatTime(conv.lastTime))
                    .fontSize(11)
                    .fontColor('#BBBBBB');
                }
                .width('100%');

                Row() {
                  Text(conv.lastMessage.length > 25 ? conv.lastMessage.substring(0, 25) + '...' : conv.lastMessage)
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
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: 10 })
            .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 })
            .onClick(() => {
              this.navigateToDoctorChat(conv.otherUserId, conv.otherUserName);
            });
          }, (conv: ConversationItem) => conv.otherUserId.toString());
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
  buildDoctorList() {
    if (this.doctors.length === 0) {
      Column() {
        Text('👨‍⚕️')
          .fontSize(56)
          .margin({ bottom: 16 });
        Text('暂无医生数据')
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333')
          .margin({ bottom: 8 });
        Text('请稍后再试或联系管理员添加医生账号')
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
          ForEach(this.doctors, (doctor: DoctorInfo) => {
            Column() {
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  Circle()
                    .width(52)
                    .height(52)
                    .fill('#1677FF');
                  Text(DoctorInfoHelper.getDisplayName(doctor).charAt(0))
                    .fontSize(22)
                    .fontWeight('bold')
                    .fontColor('#FFFFFF');
                }
                .margin({ right: 14 });

                Column({ space: 6 }) {
                  Row() {
                    Text(DoctorInfoHelper.getDisplayName(doctor))
                      .fontSize(16)
                      .fontWeight('bold')
                      .fontColor('#333333');
                    Text(doctor.title || '执业医师')
                      .fontSize(11)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor('#52C41A')
                      .borderRadius(4)
                      .margin({ left: 10 });
                  }

                  Row() {
                    if (doctor.hospital && doctor.hospital.trim() !== '') {
                      Text(doctor.hospital + ' · ')
                        .fontSize(12)
                        .fontColor('#888888');
                    }
                    if (doctor.department && doctor.department.trim() !== '') {
                      Text(doctor.department)
                        .fontSize(12)
                        .fontColor('#888888');
                    }
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);

                Button('咨询')
                  .height(34)
                  .padding({ left: 16, right: 16 })
                  .fontSize(13)
                  .fontWeight('bold')
                  .fontColor('#1677FF')
                  .backgroundColor('#E8F0FF')
                  .borderRadius(17)
                  .onClick(() => {
                    this.navigateToDoctorChat(doctor.userId, DoctorInfoHelper.getDisplayName(doctor));
                  });
              }
              .width('100%')
              .alignItems(VerticalAlign.Top);
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: 10 })
            .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 });
          }, (doctor: DoctorInfo) => doctor.id.toString());
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
          .fontWeight('bold')
          .fontColor('#333333')
          .margin({ bottom: 12 });

        Text('确定要删除与 ' + (this.deleteTarget ? this.deleteTarget.otherUserName : '') + ' 医生的所有对话记录吗？此操作不可恢复。')
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


