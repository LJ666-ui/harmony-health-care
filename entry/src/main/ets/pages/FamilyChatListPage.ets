import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AuthManager, UserRole } from '../utils/AuthManager';
import promptAction from '@ohos.promptAction';

interface ChatSession {
  id: number;
  targetUserId: number;
  targetUserName: string;
  targetUserRole: string;
  lastMessage: string;
  lastMessageTime: string;
  unreadCount: number;
  avatar?: string;
  relatedPatientName?: string;
}

@Entry
@Component
struct FamilyChatListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  
  @State currentTab: number = 0;
  @State doctorSessions: ChatSession[] = [];
  @State nurseSessions: ChatSession[] = [];
  @State isLoading: boolean = true;
  @State hasAccess: boolean = false;
  @State hasRelatedPatient: boolean = true;

  async aboutToAppear(): Promise<void> {
    this.checkAccess();
  }

  private checkAccess(): void {
    const authManager: AuthManager = AuthManager.getInstance();
    const currentRole: UserRole = authManager.getCurrentRole();

    if (currentRole === UserRole.GUEST) {
      promptAction.showToast({ message: '请先登录' });
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }

    if (currentRole !== UserRole.FAMILY) {
      promptAction.showToast({ message: '只有家属可以访问此页面' });
      router.back();
      return;
    }

    this.hasAccess = true;
    this.loadChatSessions();
  }

  private async loadChatSessions(): Promise<void> {
    this.isLoading = true;
    try {
      const doctorPromise = HttpUtil.get<ChatSession[]>(`/chat/sessions?userId=${this.currentUserId}&targetRole=DOCTOR`);
      const nursePromise = HttpUtil.get<ChatSession[]>(`/chat/sessions?userId=${this.currentUserId}&targetRole=NURSE`);

      const results = await Promise.all([doctorPromise, nursePromise]);
      const doctorRes = results[0];
      const nurseRes = results[1];

      if (doctorRes.success && doctorRes.data) {
        this.doctorSessions = doctorRes.data;
      }

      if (nurseRes.success && nurseRes.data) {
        this.nurseSessions = nurseRes.data;
      }
    } catch (error) {
      console.error('加载会话列表失败:', error);
      ToastUtil.showError('加载会话列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  private navigateToDoctorChat(session: ChatSession): void {
    router.pushUrl({
      url: 'pages/FamilyDoctorChatPage',
      params: {
        familyId: this.currentUserId,
        doctorId: session.targetUserId,
        doctorName: session.targetUserName,
        relatedPatientName: session.relatedPatientName || ''
      }
    });
  }

  private navigateToNurseChat(session: ChatSession): void {
    router.pushUrl({
      url: 'pages/FamilyNurseChatPage',
      params: {
        familyId: this.currentUserId,
        nurseId: session.targetUserId,
        nurseName: session.targetUserName,
        relatedPatientName: session.relatedPatientName || ''
      }
    });
  }

  private formatTime(timeStr: string): string {
    if (!timeStr) return '';
    const date = new Date(timeStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) {
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    } else if (diffDays === 1) {
      return '昨天';
    } else if (diffDays < 7) {
      return `${diffDays}天前`;
    } else {
      return `${date.getMonth() + 1}/${date.getDate()}`;
    }
  }

  build() {
    Column() {
      Header({ title: '咨询聊天' })

      if (!this.hasRelatedPatient) {
        Column() {
          Text('⚠️')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('您尚未关联患者')
            .fontSize(16)
            .fontColor('#333333')
            .margin({ bottom: 8 })
          Text('请先在个人中心添加就诊关系')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          Row() {
            Text('医生')
              .fontSize(this.isElderMode ? 20 : 18)
              .fontColor(this.currentTab === 0 ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_SECONDARY)
              .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .onClick(() => {
                this.currentTab = 0;
              })

            Text('护士')
              .fontSize(this.isElderMode ? 20 : 18)
              .fontColor(this.currentTab === 1 ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_SECONDARY)
              .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 20, right: 20, top: 12, bottom: 12 })
              .onClick(() => {
                this.currentTab = 1;
              })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .justifyContent(FlexAlign.Center)

          Divider().color('#EEEEEE')

          if (this.isLoading) {
            Column() {
              Text('加载中...')
                .fontSize(16)
                .fontColor('#999999')
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else if (this.currentTab === 0) {
            if (this.doctorSessions.length === 0) {
              Column() {
                Text('💬')
                  .fontSize(48)
                  .margin({ bottom: 12 })
                Text('暂无关联医生')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('100%')
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
            } else {
              List({ space: 1 }) {
                ForEach(this.doctorSessions, (session: ChatSession) => {
                  ListItem() {
                    Row() {
                      Image(session.avatar || $r('app.media.startIcon'))
                        .width(50)
                        .height(50)
                        .borderRadius(25)
                        .backgroundColor('#E0E0E0')

                      Column() {
                        Row() {
                          Text(session.targetUserName)
                            .fontSize(this.isElderMode ? 18 : 16)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(GlobalTheme.TEXT_PRIMARY)
                            .layoutWeight(1)

                          Text(this.formatTime(session.lastMessageTime))
                            .fontSize(12)
                            .fontColor('#999999')
                        }
                        .width('100%')

                        if (session.relatedPatientName) {
                          Text('患者: ' + session.relatedPatientName)
                            .fontSize(12)
                            .fontColor('#13C2C2')
                            .margin({ top: 2 })
                        }

                        Row() {
                          Text(session.lastMessage || '暂无消息')
                            .fontSize(14)
                            .fontColor('#999999')
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .layoutWeight(1)

                          if (session.unreadCount > 0) {
                            Text(session.unreadCount > 99 ? '99+' : session.unreadCount.toString())
                              .fontSize(12)
                              .fontColor('#FFFFFF')
                              .backgroundColor('#FF4D4F')
                              .borderRadius(10)
                              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          }
                        }
                        .width('100%')
                        .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      .margin({ left: 12 })
                    }
                    .width('100%')
                    .padding(16)
                    .backgroundColor('#FFFFFF')
                    .onClick(() => {
                      this.navigateToDoctorChat(session);
                    })
                  }
                })
              }
              .width('100%')
              .layoutWeight(1)
              .backgroundColor('#F5F5F5')
            }
          } else {
            if (this.nurseSessions.length === 0) {
              Column() {
                Text('💬')
                  .fontSize(48)
                  .margin({ bottom: 12 })
                Text('暂无关联护士')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('100%')
              .layoutWeight(1)
              .justifyContent(FlexAlign.Center)
            } else {
              List({ space: 1 }) {
                ForEach(this.nurseSessions, (session: ChatSession) => {
                  ListItem() {
                    Row() {
                      Image(session.avatar || $r('app.media.startIcon'))
                        .width(50)
                        .height(50)
                        .borderRadius(25)
                        .backgroundColor('#E0E0E0')

                      Column() {
                        Row() {
                          Text(session.targetUserName)
                            .fontSize(this.isElderMode ? 18 : 16)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(GlobalTheme.TEXT_PRIMARY)
                            .layoutWeight(1)

                          Text(this.formatTime(session.lastMessageTime))
                            .fontSize(12)
                            .fontColor('#999999')
                        }
                        .width('100%')

                        if (session.relatedPatientName) {
                          Text('患者: ' + session.relatedPatientName)
                            .fontSize(12)
                            .fontColor('#13C2C2')
                            .margin({ top: 2 })
                        }

                        Row() {
                          Text(session.lastMessage || '暂无消息')
                            .fontSize(14)
                            .fontColor('#999999')
                            .maxLines(1)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .layoutWeight(1)

                          if (session.unreadCount > 0) {
                            Text(session.unreadCount > 99 ? '99+' : session.unreadCount.toString())
                              .fontSize(12)
                              .fontColor('#FFFFFF')
                              .backgroundColor('#FF4D4F')
                              .borderRadius(10)
                              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          }
                        }
                        .width('100%')
                        .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      .margin({ left: 12 })
                    }
                    .width('100%')
                    .padding(16)
                    .backgroundColor('#FFFFFF')
                    .onClick(() => {
                      this.navigateToNurseChat(session);
                    })
                  }
                })
              }
              .width('100%')
              .layoutWeight(1)
              .backgroundColor('#F5F5F5')
            }
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
