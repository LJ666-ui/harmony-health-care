import { router } from '@kit.ArkUI';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';

export class PatientConvItem {
  otherUserId: number = 0;
  otherUserName: string = '';
  otherUserType: number = 0; // 0=患者, 1=家属
  lastMessage: string = '';
  lastTime: string = '';
  unreadCount: number = 0;
  remainHours: number = 0;
  expireTime: string = '';
}

interface QuickAction {
  id: string;
  icon: string;
  title: string;
  color: string;
  route: string;
}

@Entry
@Component
struct DoctorMainPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State doctorName: string = '医生';
  @State doctorInfo: DoctorInfo = new DoctorInfo();  // ✅ 改为初始化空对象，而不是 null
  @State conversations: PatientConvItem[] = [];
  @State isLoading: boolean = true;
  @State showDeleteDialog: boolean = false;
  @State deleteTarget: PatientConvItem | null = null;
  @State totalUnread: number = 0;
  @State currentTab: number = 0;

  private scroller: Scroller = new Scroller();
  private pollTimerId: number = -1;

  private quickActions: QuickAction[] = [
    { id: 'patients', icon: '👥', title: '患者管理', color: '#1677FF', route: 'pages/DoctorPatientListPage' },
    { id: 'medical_records', icon: '📋', title: '病历管理', color: '#52C41A', route: 'pages/DoctorMedicalRecordListPage' },
    { id: 'prescriptions', icon: '💊', title: '处方管理', color: '#FA8C16', route: 'pages/DoctorPrescriptionListPage' },
    { id: 'follow_up', icon: '🔔', title: '复诊管理', color: '#E74C3C', route: 'pages/DoctorFollowUpPage' },
    { id: 'consultations', icon: '💬', title: '在线问诊', color: '#13C2C2', route: '' },
    { id: 'schedule', icon: '📅', title: '排班管理', color: '#722ED1', route: 'pages/DoctorSchedulePage' },
    { id: 'consultation_management', icon: '🏥', title: '会诊管理', color: '#52C41A', route: 'pages/ConsultationManagementPage' }
  ];

  aboutToAppear(): void {
    console.log('[DoctorMainPage] ========== 页面开始加载 ==========');
    console.log('[DoctorMainPage] 初始状态 - userId:', this.currentUserId);
    console.log('[DoctorMainPage] 初始状态 - doctorName:', this.doctorName);
    
    this.loadDoctorInfo();
    this.loadConversations();
    this.startPolling();
    
    console.log('[DoctorMainPage] ========== 页面加载方法已调用 ==========');
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
    console.log('[DoctorMainPage] loadDoctorInfo 开始执行');
    
    // 从 AppStorage 中读取医生信息
    const doctorInfoFromStorage = AppStorage.get<DoctorInfo>('doctorInfo');
    console.log('[DoctorMainPage] 从AppStorage获取的doctorInfo:', doctorInfoFromStorage ? '存在' : '不存在');
    
    // ✅ 始终确保 doctorInfo 是有效的 DoctorInfo 对象
    if (doctorInfoFromStorage) {
      console.log('[DoctorMainPage] doctorInfoFromStorage 类型:', typeof doctorInfoFromStorage);
      
      // 确保是 DoctorInfo 类型，如果不是则进行转换
      if (doctorInfoFromStorage instanceof DoctorInfo) {
        console.log('[DoctorMainPage] 直接使用 DoctorInfo 实例');
        this.doctorInfo = doctorInfoFromStorage;
      } else {
        console.log('[DoctorMainPage] 需要类型转换，原始数据:', JSON.stringify(doctorInfoFromStorage));
        this.doctorInfo = DoctorInfoHelper.fromJson(doctorInfoFromStorage as Record<string, Object>);
      }
      this.doctorName = this.doctorInfo.realName || '医生';
      console.log('[DoctorMainPage] 医生姓名已设置:', this.doctorName);
    } else {
      // ✅ 如果没有存储的信息，使用空的 DoctorInfo 对象（已通过初始化保证不为 null）
      console.log('[DoctorMainPage] AppStorage中无doctorInfo，使用默认值');
      this.doctorName = '医生';
      
      // 尝试从 SettingsUtil 读取
      console.log('[DoctorMainPage] 尝试从 SettingsUtil 读取...');
      const settings: SettingsUtil = SettingsUtil.getInstance();
      settings.getUserInfo().then((info: PersistedUserInfo | null) => {
        console.log('[DoctorMainPage] SettingsUtil 返回:', info ? '有数据' : '无数据');
        
        if (info && info.doctorInfo) {
          this.doctorName = info.doctorInfo.realName || info.username || '医生';
          
          // 安全地从 PersistedDoctorInfo 转换为 DoctorInfo
          const rawInfo = info.doctorInfo as Record<string, Object>;
          console.log('[DoctorMainPage] 原始 doctorInfo 数据:', JSON.stringify(rawInfo));
          const docInfo: DoctorInfo = DoctorInfoHelper.fromJson(rawInfo);
          
          if (info.doctorInfo.id) { docInfo.id = info.doctorInfo.id as number; }
          if (info.userId) { docInfo.userId = info.userId; }
          
          this.doctorInfo = docInfo;
          console.log('[DoctorMainPage] 从SettingsUtil加载完成，姓名:', this.doctorName);
        } else if (info && info.username) {
          this.doctorName = info.username;
          console.log('[DoctorMainPage] 使用 username 作为显示名:', this.doctorName);
        }
      }).catch((err: Error) => {
        console.error('[DoctorMainPage] 从SettingsUtil读取失败:', err.message);
      });
    }
  }

  private loadConversations(): void {
    console.log('[DoctorMainPage] 开始加载患者列表, userId:', this.currentUserId);
    
    // ✅ 安全检查：确保 userId 有效
    if (!this.currentUserId || this.currentUserId <= 0) {
      console.warn('[DoctorMainPage] userId 无效:', this.currentUserId);
      this.isLoading = false;
      return;
    }
    
    const params: Record<string, string> = {
      'doctorId': this.currentUserId.toString()
    };
    
    console.log('[DoctorMainPage] 请求参数:', JSON.stringify(params));
    
    HttpUtil.get<PatientConvItem[]>(ApiConstants.DOCTOR_PATIENTS, params as Object)
      .then((response) => {
        console.log('[DoctorMainPage] API 响应成功:', response.success);
        
        if (response.success && response.data) {
          console.log('[DoctorMainPage] 原始数据类型:', typeof response.data);
          console.log('[DoctorMainPage] 原始数据:', JSON.stringify(response.data));
          
          // ✅ 安全的类型检查
          let rawData: Object[] = [];
          if (Array.isArray(response.data)) {
            rawData = response.data as Object[];
          } else if (typeof response.data === 'object') {
            // 如果不是数组，尝试包装成数组
            rawData = [response.data as Object];
            console.warn('[DoctorMainPage] 数据不是数组，已转换为单元素数组');
          } else {
            console.error('[DoctorMainPage] 数据格式异常:', typeof response.data);
            return;
          }
          
          const list: PatientConvItem[] = [];
          let unread: number = 0;
          
          for (let i: number = 0; i < rawData.length; i++) {
            try {
              const item: PatientConvItem = new PatientConvItem();
              const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
              
              console.log('[DoctorMainPage] 处理第 ' + (i+1) + ' 条数据:', JSON.stringify(raw).substring(0, 100));
              
              // ✅ 安全的字段赋值，带类型检查
              if (raw['otherUserId'] !== undefined && raw['otherUserId'] !== null) { 
                const val = Number(raw['otherUserId']);
                if (!isNaN(val)) { item.otherUserId = val; }
              }
              if (raw['otherUserName'] !== undefined && raw['otherUserName'] !== null) { 
                item.otherUserName = String(raw['otherUserName'] || '');
              }
              if (raw['otherUserType'] !== undefined && raw['otherUserType'] !== null) { 
                const val = Number(raw['otherUserType']);
                if (!isNaN(val)) { item.otherUserType = val; }
              }
              if (raw['lastMessage'] !== undefined && raw['lastMessage'] !== null) { 
                item.lastMessage = String(raw['lastMessage'] || '');
              }
              if (raw['lastTime'] !== undefined && raw['lastTime'] !== null) { 
                item.lastTime = String(raw['lastTime'] || '');
              }
              if (raw['unreadCount'] !== undefined && raw['unreadCount'] !== null) { 
                const val = Number(raw['unreadCount']);
                if (!isNaN(val)) { item.unreadCount = val; }
              }
              if (raw['remainHours'] !== undefined && raw['remainHours'] !== null) { 
                const val = Number(raw['remainHours']);
                if (!isNaN(val)) { item.remainHours = val; }
              }
              if (raw['expireTime'] !== undefined && raw['expireTime'] !== null) { 
                item.expireTime = String(raw['expireTime'] || '');
              }
              
              list.push(item);
              unread += item.unreadCount;
              
              console.log('[DoctorMainPage] 第 ' + (i+1) + ' 条数据处理完成:', 
                'userId=' + item.otherUserId + ', name=' + item.otherUserName);
                
            } catch (parseError) {
              console.error('[DoctorMainPage] 解析第 ' + (i+1) + ' 条数据失败:', parseError);
            }
          }
          
          console.log('[DoctorMainPage] 总共处理了 ' + list.length + ' 条患者数据');
          this.conversations = list;
          this.totalUnread = unread;
        } else {
          console.warn('[DoctorMainPage] API 返回失败或无数据:', response.message);
        }
      })
      .catch((err: Error) => {
        console.error('[DoctorMainPage] 加载患者列表失败:', err.message);
        console.error('[DoctorMainPage] 错误堆栈:', err.stack);
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
        console.error('[DoctorMainPage] 删除对话失败:', err.message);
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

        // ✅ doctorInfo 现在永远不为 null，直接使用
        if (DoctorInfoHelper.getDisplayTitle(this.doctorInfo)) {
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

      Tabs({ index: this.currentTab }) {
        TabContent() {
          this.buildHomePage();
        }
        .tabBar('首页');

        TabContent() {
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
        }
        .tabBar(this.totalUnread > 0 ? '对话' + ' (' + (this.totalUnread > 99 ? '99+' : this.totalUnread.toString()) + ')' : '对话');

        TabContent() {
          this.buildDoctorInfo();
        }
        .tabBar('我的');
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTab = index;
      });

      if (this.showDeleteDialog) {
        this.buildDeleteDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildHomePage() {
    Scroll() {
      Column({ space: 12 }) {
        // ✅ 医生信息卡片 - doctorInfo 现在永远不为 null
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
          .padding({ left: 16, right: 16, top: 12, bottom: 6 });
        
        // 快捷功能入口
        Column({ space: 12 }) {
          Text('快捷功能')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')
            .padding({ left: 16, right: 16 });

          Grid() {
            ForEach(this.quickActions, (action: QuickAction) => {
              GridItem() {
                Column({ space: 8 }) {
                  Text(action.icon)
                    .fontSize(28);

                  Text(action.title)
                    .fontSize(12)
                    .fontColor('#333333')
                    .textAlign(TextAlign.Center)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
                .onClick(() => {
                  if (action.id === 'consultations') {
                    // 跳转到对话Tab
                    this.currentTab = 1;
                  } else if (action.route) {
                    try {
                      router.pushUrl({ url: action.route });
                    } catch (error) {
                      console.error('导航失败:', error);
                    }
                  }
                });
              }
            }, (action: QuickAction) => action.id)
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(12)
          .columnsGap(12)
          .width('100%')
          .padding({ left: 16, right: 16 });
        }
        .width('100%');

        // 患者咨询卡片
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
        .borderRadius({ bottomLeft: 24, bottomRight: 24 })
        .padding({ left: 16, right: 16 });

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

        if (!this.isLoading && this.conversations.length > 0) {
          Column({ space: 10 }) {
            Text('最近咨询')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width('100%')
              .padding({ left: 16, right: 16 });

            ForEach(this.conversations.slice(0, 3), (conv: PatientConvItem) => {
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  Circle()
                    .width(44)
                    .height(44)
                    .fill('#36CFC9');
                  Text(conv.otherUserName.charAt(0))
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF');
                }
                .margin({ right: 12 });

                Column({ space: 4 }) {
                  Row() {
                    Text(conv.otherUserName)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333');

                    Text(conv.otherUserType === 1 ? '家属' : '患者')
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor(conv.otherUserType === 1 ? '#FA8C16' : '#36CFC9')
                      .borderRadius(4)
                      .margin({ left: 6 });

                    Blank();

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
                        .fontSize(10)
                        .fontColor('#FFFFFF')
                        .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                        .backgroundColor('#FF4D4F')
                        .borderRadius(10);
                    }
                  }
                  .width('100%');
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);
              }
              .width('100%')
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                this.currentTab = 1;
              });
            }, (conv: PatientConvItem) => conv.otherUserId.toString());
          }
          .width('100%')
          .padding({ bottom: 16 });
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({ bottom: 16 });
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
          ForEach(this.conversations, (conv: PatientConvItem, index: number) => {
            Column() {
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  Circle()
                    .width(50)
                    .height(50)
                    .fill('#36CFC9');
                  // ✅ 安全访问 otherUserName，确保不为空
                  Text((conv.otherUserName && conv.otherUserName.length > 0) ? conv.otherUserName.charAt(0) : '?')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF');
                }
                .margin({ right: 14 });

                Column({ space: 4 }) {
                  Row() {
                    // ✅ 安全显示用户名，提供默认值
                    Text(conv.otherUserName || '未知用户')
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
                    // ✅ 安全截取消息文本，防止空字符串问题（不能在 build 中使用 const）
                    Text(((conv.lastMessage || '暂无消息').length > 20) ? 
                      (conv.lastMessage || '暂无消息').substring(0, 20) + '...' : 
                      (conv.lastMessage || '暂无消息'))
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
                    // ✅ 安全格式化剩余时间
                    Text('⏱️ ' + this.formatRemainHours(conv.remainHours >= 0 ? conv.remainHours : 0))
                      .fontSize(11)
                      .fontColor((conv.remainHours >= 0 ? conv.remainHours : 0) < 6 ? '#FF4D4F' : ((conv.remainHours >= 0 ? conv.remainHours : 0) < 12 ? '#FAAD14' : '#52C41A'));
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
                    patientName: conv.otherUserName || '未知用户',
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
                          otherUserName: conv.otherUserName || '未知用户',
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
                          otherUserName: conv.otherUserName || '未知用户',
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
          }, (conv: PatientConvItem) => conv.otherUserId.toString() + '_' + (conv.lastTime || ''));
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
  buildDoctorInfo() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 16 }) {
          Text('医生信息')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%');

          // ✅ doctorInfo 现在永远不为 null，安全访问所有属性
          Column({ space: 12 }) {
            Row({ space: 12 }) {
              Text('姓名')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(this.doctorInfo.realName || '-')
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .width('100%');

            Row({ space: 12 }) {
              Text('手机号')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(this.doctorInfo.phone || '-')
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .width('100%');

            Row({ space: 12 }) {
              Text('所属医院')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(this.doctorInfo.hospital || '-')
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .width('100%');

            Row({ space: 12 }) {
              Text('科室')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(this.doctorInfo.department || '-')
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .width('100%');

            Row({ space: 12 }) {
              Text('职称')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(this.doctorInfo.title || '-')
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .width('100%');

            Row({ space: 12 }) {
              Text('执业证号')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(this.doctorInfo.licenseNumber || '-')
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .width('100%');

            Row({ space: 12 }) {
              Text('专业领域')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Text(this.doctorInfo.specialty || '-')
                .fontSize(14)
                .fontColor('#333333')
                .layoutWeight(1);
            }
            .width('100%');

            Row({ space: 12 }) {
              Text('评分')
                .fontSize(14)
                .fontColor('#666666')
                .width(80);
              Row() {
                Text('⭐')
                  .fontSize(14);
                Text((this.doctorInfo.rating > 0 ? this.doctorInfo.rating.toFixed(1) : '-'))
                  .fontSize(14)
                  .fontColor('#333333')
                  .margin({ left: 4 });
              }
              .layoutWeight(1);
            }
            .width('100%');

            if (this.doctorInfo.description) {
              Column({ space: 8 }) {
                Row() {
                  Text('个人简介')
                    .fontSize(14)
                    .fontColor('#666666');
                }
                .width('100%');
                Text(this.doctorInfo.description)
                  .fontSize(14)
                  .fontColor('#333333')
                  .lineHeight(22);
              }
              .width('100%');
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 80 });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off);
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
