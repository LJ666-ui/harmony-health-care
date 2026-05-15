import { router } from '@kit.ArkUI';
import { HttpUtil, RequestOptions } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';
import promptAction from '@ohos.promptAction';

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
  bgColor?: string;
  route: string;
  badge?: number;
  group?: string;
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
    { id: 'patients', icon: '👥', title: '患者管理', color: '#1677FF', bgColor: '#E6F4FF', route: 'pages/DoctorPatientListPage', group: '核心业务' },
    { id: 'medical_records', icon: '📋', title: '病历管理', color: '#52C41A', bgColor: '#F6FFED', route: 'pages/DoctorMedicalRecordListPage', group: '核心业务' },
    { id: 'prescriptions', icon: '💊', title: '处方管理', color: '#FA8C16', bgColor: '#FFF7E6', route: 'pages/DoctorPrescriptionListPage', group: '核心业务' },
    { id: 'follow_up', icon: '🔔', title: '复诊管理', color: '#F5222D', bgColor: '#FFF1F0', route: 'pages/DoctorFollowUpPage', group: '核心业务' },
    { id: 'consultations', icon: '💬', title: '在线问诊', color: '#13C2C2', bgColor: '#E6FFFB', route: '', badge: 0, group: '沟通服务' },
    { id: 'consultation_management', icon: '🏥', title: '会诊管理', color: '#52C41A', bgColor: '#F6FFED', route: 'pages/ConsultationManagementPage', group: '协作交流' },
    { id: 'notification', icon: '🔔', title: '通知中心', color: '#F5222D', bgColor: '#FFF1F0', route: '', group: '消息通知' },
    { id: 'settings', icon: '⚙️', title: '系统设置', color: '#8C8C8C', bgColor: '#F5F5F5', route: '', group: '系统功能' }
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

    const requestOptions: RequestOptions = {} as RequestOptions;
    const params: Record<string, Object> = {} as Record<string, Object>;
    console.log('[DoctorMainPage] Token: 存在');

    if (this.currentUserId > 0) {
      console.log('[DoctorMainPage] 从API获取最新医生信息...');
      HttpUtil.get<Record<string, Object>>(`${ApiConstants.DOCTOR_INFO.replace(/\/$/, '')}`, params, requestOptions)
        .then((response: object) => {
          console.log('[DoctorMainPage] API返回数据:', JSON.stringify(response));
          
          const res = response as Record<string, Object>;
          if (res['code'] === 200 && res['data']) {
            const data = res['data'] as Record<string, Object>;
            console.log('[DoctorMainPage] 解析医生数据:', JSON.stringify(data));
            
            this.doctorInfo = DoctorInfoHelper.fromJson(data);
            this.doctorName = this.doctorInfo.realName || '医生';
            
            AppStorage.setOrCreate<DoctorInfo>('doctorInfo', this.doctorInfo);
            console.log('[DoctorMainPage] 从API加载完成，姓名:', this.doctorName);
          } else {
            console.warn('[DoctorMainPage] API返回异常，使用本地缓存');
            this.loadFromLocalCache();
          }
        })
        .catch((error: Error) => {
          console.error('[DoctorMainPage] API调用失败:', error.message);
          this.loadFromLocalCache();
        });
    } else {
      console.warn('[DoctorMainPage] Token或userId缺失，从本地加载');
      this.loadFromLocalCache();
    }
  }

  private loadFromLocalCache(): void {
    const doctorInfoFromStorage = AppStorage.get<DoctorInfo>('doctorInfo');
    
    if (doctorInfoFromStorage) {
      if (doctorInfoFromStorage instanceof DoctorInfo) {
        this.doctorInfo = doctorInfoFromStorage;
      } else {
        this.doctorInfo = DoctorInfoHelper.fromJson(doctorInfoFromStorage as Record<string, Object>);
      }
      this.doctorName = this.doctorInfo.realName || '医生';
    } else {
      this.doctorName = '医生';
      
      const settings: SettingsUtil = SettingsUtil.getInstance();
      settings.getUserInfo().then((info: PersistedUserInfo | null) => {
        if (info && info.doctorInfo) {
          this.doctorName = info.doctorInfo.realName || info.username || '医生';
          const rawInfo = info.doctorInfo as Record<string, Object>;
          const docInfo: DoctorInfo = DoctorInfoHelper.fromJson(rawInfo);
          
          if (info.doctorInfo.id) { docInfo.id = info.doctorInfo.id as number; }
          if (info.userId) { docInfo.userId = info.userId; }
          
          this.doctorInfo = docInfo;
        } else if (info && info.username) {
          this.doctorName = info.username;
        }
      }).catch((err: Error) => {
        console.error('[DoctorMainPage] SettingsUtil读取失败:', err.message);
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

  private handleQuickActionClick(action: QuickAction): void {
    console.log('[DoctorMainPage] 快捷功能点击:', action.id, action.title);

    switch (action.id) {
      case 'consultations':
        this.currentTab = 1;
        break;

      case 'notification':
        this.showToast('通知中心功能开发中...');
        break;

      case 'statistics':
        this.showToast('统计分析功能开发中...');
        break;

      case 'settings':
        this.currentTab = 2;
        break;

      default:
        if (action.route) {
          try {
            router.pushUrl({ url: action.route });
          } catch (error) {
            console.error('导航失败:', error);
            this.showToast('页面跳转失败');
          }
        } else {
          this.showToast(action.title + '功能开发中...');
        }
        break;
    }
  }

  private showToast(message: string): void {
    console.log('[DoctorMainPage] Toast提示:', message);
  }

  build() {
    Column() {
      Column() {
        Row() {
          Column({ space: 6 }) {
            Text(`您好，${this.doctorName || '医生'}`)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');

            if (DoctorInfoHelper.getDisplayTitle(this.doctorInfo)) {
              Text(DoctorInfoHelper.getDisplayTitle(this.doctorInfo))
                .fontSize(14)
                .fontColor('#FFFFFFCC');
            } else {
              Text('医生工作台')
                .fontSize(14)
                .fontColor('#FFFFFFCC');
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Column({ space: 8 }) {
            Text('退出登录')
              .fontSize(13)
              .fontColor('#1677FF')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
              .onClick(() => {
                const settings: SettingsUtil = SettingsUtil.getInstance();
                settings.clearAllLoginData().then(() => {
                  router.replaceUrl({ url: 'pages/Login' });
                }).catch(() => {
                  router.replaceUrl({ url: 'pages/Login' });
                });
              });
          }
        }
        .width('100%')
        .padding(20)

        Row({ space: 12 }) {
          this.buildStatCard('今日患者', '28', '人')
          this.buildStatCard('待处理', '5', '项')
          this.buildStatCard('已完成', '23', '项')
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 8 })
      }
      .width('100%')
      .linearGradient({
        angle: 135,
        colors: [['#1677FF', 0], ['#0958D9', 0.5], ['#003A8C', 1]],
        direction: GradientDirection.RightBottom
      })
      .borderRadius({ bottomLeft: 24, bottomRight: 24 })

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
      .barBackgroundColor('#FFFFFF')
      .onChange((index: number) => {
        this.currentTab = index;
      });

      if (this.showDeleteDialog) {
        this.buildDeleteDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildStatCard(title: string, value: string, unit: string): void {
    Column({ space: 6 }) {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1677FF')

      Text(`${title}${unit}`)
        .fontSize(12)
        .fontColor('#666666')
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor('#E8F0FE')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildHomePage() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 0 }) {
          Row() {
            Text('医生信息')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#262626')

            Blank()

            Text('编辑资料')
              .fontSize(13)
              .fontColor('#1677FF')
              .onClick(() => {
                router.pushUrl({ url: 'pages/DoctorProfilePage' });
              })
          }
          .width('100%')
          .padding({ bottom: 12 })

          Row({ space: 12 }) {
            this.buildInfoItem('🏥', DoctorInfoHelper.getDisplayHospital(this.doctorInfo) || '未填写', '所属医院', '#1677FF')
            this.buildInfoItem('🩺', this.doctorInfo.department || '未填写', '科室', '#52C41A')
            this.buildInfoItem('⭐', this.doctorInfo.title || '未填写', '职称', '#FA8C16')
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })

        Column({ space: 16 }) {
          Row() {
            Text('快捷功能')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#262626')

            Blank()

            Text('查看全部')
              .fontSize(13)
              .fontColor('#999999')
          }
          .width('100%')

          Grid() {
            ForEach(this.quickActions, (action: QuickAction) => {
              GridItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Column({ space: 10 }) {
                    Text(action.icon)
                      .fontSize(32);

                    Text(action.title)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .textAlign(TextAlign.Center)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                  }
                  .width('100%')
                  .padding({ top: 16, bottom: 12 })
                  .backgroundColor(action.bgColor || '#F7F8FA')
                  .borderRadius(16)
                  .shadow({
                    radius: 8,
                    color: '#00000008',
                    offsetX: 0,
                    offsetY: 4
                  })
                  .border({
                    width: action.id === 'consultations' ? 2 : 0,
                    color: action.id === 'consultations' ? '#13C2C2' : 'transparent'
                  });

                  if (action.badge !== undefined && action.badge !== null && action.badge > 0) {
                    Text(action.badge > 99 ? '99+' : action.badge.toString())
                      .fontSize(10)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(10)
                      .backgroundColor('#FF4D4F')
                      .margin({ top: 8, right: 8 });
                  }
                }
                .onClick(() => {
                  this.handleQuickActionClick(action);
                });
              }
            }, (action: QuickAction) => action.id)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr')
          .rowsGap(16)
          .columnsGap(12)
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 2 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16, right: 16, top: 16, bottom: 16 });
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .padding({ bottom: 16 });
  }

  @Builder buildInfoItem(icon: string, value: string, label: string, color: string): void {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(24)

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#262626')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(label)
        .fontSize(11)
        .fontColor('#8C8C8C')
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(color + '0A')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildConversationList() {
    Column() {
      this.buildConsultationCard();

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.conversations.length === 0) {
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
              this.buildConversationCard(conv);
            }, (conv: PatientConvItem) => conv.otherUserId.toString() + '_' + (conv.lastTime || ''));
          }
          .width('100%')
          .padding({ top: 8, bottom: 48 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F5F7FA')
    .padding({ top: 0 });
  }

  @Builder
  buildConsultationCard() {
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

    Row() {
      Text('ℹ️ 对话规则：患者主动联系后，您才可回复；对话48小时后自动消失')
        .fontSize(11)
        .fontColor('#1677FF')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 10, bottom: 6 })
    .backgroundColor('#E8F0FF');
  }

  @Builder
  buildConversationCard(conv: PatientConvItem) {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(50)
            .height(50)
            .fill('#36CFC9');
          Text((conv.otherUserName && conv.otherUserName.length > 0) ? conv.otherUserName.charAt(0) : '?')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF');
        }
        .margin({ right: 14 });

        Column({ space: 4 }) {
          Row() {
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
            try {
              if (conv.otherUserType === 1) {
                router.pushUrl({
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
                if (!conv.otherUserId || conv.otherUserId <= 0) {
                  promptAction.showToast({ message: '患者信息异常，无法打开对话' });
                  return;
                }
                router.pushUrl({
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
            } catch (error) {
              console.error('[DoctorMainPage] 打开对话页面失败:', error);
              promptAction.showToast({ message: '打开对话失败，请重试' });
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
  }

  @Builder
  buildDoctorInfo() {
    Scroll() {
      Column({ space: 0 }) {
        this.buildMyProfileHeader();
        this.buildMyInfoList();
        this.buildMyMenuList();
      }
      .width('100%')
      .padding({ bottom: 40 });
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildMyProfileHeader() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width(90)
          .height(90)
          .borderRadius(45)
          .backgroundColor('#1677FF')
          .shadow({ radius: 12, color: '#1677FF33', offsetX: 0, offsetY: 6 });

        Column({ space: 4 }) {
          Row({ space: 4 }) {
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
          }

          Row({ space: 4 }) {
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
            Column()
              .width(18)
              .height(18)
              .borderRadius(4)
              .backgroundColor('#FFFFFF80')
              .opacity(0.9);
          }
        }
        .padding({ bottom: 12 });
      }
      .width(90)
      .height(90);

      Text(this.doctorInfo.realName || '未设置')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333');

      Text(`${this.doctorInfo.department || '未知科室'} | ${this.doctorInfo.title || '未设置职称'}`)
        .fontSize(14)
        .fontColor('#666666');
    }
    .width('100%')
    .padding({ top: 40, bottom: 24 })
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.Center);
  }

  @Builder
  buildMyInfoList() {
    Column() {
      this.buildMyInfoItem('工号', this.doctorInfo.employeeNo || '-');
      this.buildMyDivider();
      this.buildMyInfoItem('姓名', this.doctorInfo.realName || '-');
      this.buildMyDivider();
      this.buildMyInfoItem('手机号', this.doctorInfo.phone || '-');
      this.buildMyDivider();
      this.buildMyInfoItem('科室', this.doctorInfo.department || '-');
      this.buildMyDivider();
      this.buildMyInfoItem('职称', this.doctorInfo.title || '-');
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 });
  }

  @Builder
  buildMyInfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#333333')
        .width(80);

      Text(value)
        .fontSize(15)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.End);
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 });
  }

  @Builder
  buildMyDivider() {
    Row()
      .width('calc(100% - 40px)')
      .height(1)
      .backgroundColor('#EEEEEE')
      .margin({ left: 20, right: 20 });
  }

  @Builder
  buildMyMenuList() {
    Column() {
      this.buildMyMenuItem('编辑个人信息', () => {
        router.pushUrl({
          url: 'pages/DoctorProfilePage',
          params: { doctorId: this.currentUserId }
        });
      });

      this.buildMyMenuItem('我的排班', () => {
        router.pushUrl({
          url: 'pages/DoctorSchedulePage',
          params: { doctorId: this.currentUserId }
        });
      });

      this.buildMyMenuItem('修改密码', () => {
        promptAction.showToast({ message: '修改密码功能开发中' });
      });

      this.buildMyMenuItem('消息通知', () => {
        promptAction.showToast({ message: '消息通知设置开发中' });
      });

      this.buildMyMenuItem('帮助与反馈', () => {
        promptAction.showToast({ message: '帮助与反馈开发中' });
      });

      this.buildMyMenuItem('关于我们', () => {
        promptAction.showToast({ message: '关于我们页面开发中' });
      });
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 })
    .borderRadius({ topLeft: 12, topRight: 12 });
  }

  @Builder
  buildMyMenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#333333');

      Blank();

      Text('>')
        .fontSize(16)
        .fontColor('#CCCCCC');
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 17, bottom: 17 })
    .onClick(onClick);

    if (title !== '关于我们') {
      Row()
        .width('calc(100% - 40px)')
        .height(1)
        .backgroundColor('#F5F5F5')
        .margin({ left: 20, right: 20 });
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
