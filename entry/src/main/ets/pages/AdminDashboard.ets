import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminAuthService, AdminLoginResponse } from '../services/AdminAuthService';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import promptAction from '@ohos.promptAction';

interface SystemStatistics {
  userCount?: number;
  familyCount?: number;
  doctorCount?: number;
  adminCount?: number;
  todayNewRecords?: number;
  weeklyActiveUsers?: number;
  monthlyEvaluations?: number;
  planCompletionRate?: number;
}

interface UserInfo {
  id: number;
  username: string;
  real_name?: string;
  realName?: string;
  create_time?: string;
  createTime?: string;
}

@Entry
@Component
struct AdminDashboard {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: AdminLoginResponse | null = null;
  @State selectedTab: number = 0;
  @State showSidebar: boolean = false;
  @State hasAccess: boolean = false;
  @State userCount: number = 0;
  @State familyCount: number = 0;
  @State doctorCount: number = 0;
  @State adminCount: number = 0;
  @State recentUsers: UserInfo[] = [];
  @State isLoadingStats: boolean = false;

  private tabs: string[] = ['仪表盘', '数据大屏', '用户管理', '家属管理', '管理员管理', '数据审批', '安全监控'];
  private tabIcons: string[] = ['📊', '🖥️', '👥', '👨‍👩‍👧', '🛡️', '🔐', '⚠️'];
  private tabRoutes: string[] = [
    'pages/AdminDashboard',
    'pages/AdminDataDashboard',
    'pages/AdminUsers',
    'pages/AdminFamily',
    'pages/AdminManage',
    'pages/DataAccessApprovalPage',
    'pages/AbnormalLoginPage'
  ];

  aboutToAppear(): void {
    this.checkAccess();
    this.loadStatistics();
  }

  private async loadStatistics(): Promise<void> {
    this.isLoadingStats = true;
    try {
      console.info('[AdminDashboard] 开始加载统计数据...');
      
      const response: BaseResponse<SystemStatistics> = await HttpUtil.get<SystemStatistics>(
        '/admin/dashboard/stats',
        undefined,
        { isAdmin: true }
      );
      
      console.info('[AdminDashboard] API响应:', JSON.stringify(response));
      
      if (response.code === 200 && response.data) {
        this.userCount = response.data.userCount || 0;
        this.familyCount = response.data.familyCount || 0;
        this.doctorCount = response.data.doctorCount || 0;
        this.adminCount = response.data.adminCount || 0;
        console.info('[AdminDashboard] 数据加载成功:', 
          'userCount=', this.userCount,
          'doctorCount=', this.doctorCount,
          'adminCount=', this.adminCount);
      } else {
        console.error('[AdminDashboard] API返回错误:', response.code, response.message);
        promptAction.showToast({ message: '获取统计数据失败: ' + (response.message || '未知错误') });
      }
    } catch (error) {
      console.error('[AdminDashboard] 加载统计数据异常:', error);
      promptAction.showToast({ message: '网络错误，请检查后端服务' });
    } finally {
      this.isLoadingStats = false;
    }
  }

  private checkAccess(): void {
    const admin = AdminAuthService.getCurrentAdmin();
    if (!admin) {
      promptAction.showToast({ message: '请先登录管理员账号' });
      router.replaceUrl({ url: 'pages/AdminLogin' });
      return;
    }

    this.currentAdmin = admin;
    this.hasAccess = true;
  }

  build() {
    Stack() {
      Column() {
        this.TitleBar();
        this.StatsSection();
        this.DataDashboardBanner();
        this.QuickActions();
        this.RecentSection();
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA');

      if (this.showSidebar) {
        this.SidebarOverlay();
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  TitleBar() {
    Row() {
      Button({ type: ButtonType.Normal }) {
        Text('☰')
          .fontSize(20)
          .fontColor('#FFFFFF');
      }
      .width(40)
      .height(40)
      .backgroundColor('rgba(255,255,255,0.15)')
      .borderRadius(10)
      .onClick(() => {
        this.showSidebar = true;
      });

      Text('管理后台')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .layoutWeight(1)
        .textAlign(TextAlign.Center);

      Row({ space: 8 }) {
        Column() {
          Text(String((this.currentAdmin?.realName || '管').charAt(0)))
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF');
        }
        .width(30)
        .height(30)
        .borderRadius(15)
        .backgroundColor('rgba(255,255,255,0.25)')
        .justifyContent(FlexAlign.Center);

        Text(this.currentAdmin ? this.currentAdmin.realName : '管理员')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#FFFFFFDD');
      }
      .onClick(() => {
        this.showSidebar = true;
      });
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [['#1E293B', 0], ['#334155', 0.5], ['#1E3A5F', 1]]
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  StatsSection() {
    Column({ space: 14 }) {
      Row() {
        Text('数据概览')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E');
        Blank();
        Text('实时统计')
          .fontSize(11)
          .fontColor('#52C41A')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor('#52C41A12')
          .borderRadius(10);
      }
      .width('100%');

      if (this.isLoadingStats) {
        Row() {
          LoadingProgress().width(36).height(36).color('#1677FF');
        }
        .width('100%').height(120).justifyContent(FlexAlign.Center);
      } else {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          this.StatCard('👥', this.userCount, '注册用户', '#1677FF', '+12%', true);
          this.StatCard('👨‍👩‍👧', this.familyCount, '家属记录', '#52C41A', '+5%', false);
          this.StatCard('🏥', this.doctorCount, '医生用户', '#FAAD14', '+3', false);
          this.StatCard('🛡️', this.adminCount, '管理员', '#8B5CF6', '', false);
        }
        .width('100%');
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 14, left: 14, right: 14 })
    .shadow({ radius: 16, color: '#00000006', offsetX: 0, offsetY: 4 });
  }

  @Builder
  DataDashboardBanner() {
    Row() {
      Column({ space: 8 }) {
        Text('🖥️ 数据大屏')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#0F172A');
        Text('全局运营监控 · 实时数据可视化')
          .fontSize(11)
          .fontColor('#64748B');
      }
      .alignItems(HorizontalAlign.Start);

      Blank();

      Column({ space: 4 }) {
        Text('进入大屏 →')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1677FF');
        Text('用户/健康/预约/风险 全局视图')
          .fontSize(9)
          .fontColor('#94A3B8');
      }
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .linearGradient({
      angle: 135,
      colors: [['#E6F4FF', 0], ['#BAE7FF', 1]]
    })
    .borderRadius(12)
    .border({ width: 1.5, color: '#91D5FF', style: BorderStyle.Solid })
    .margin({ top: 12, left: 12, right: 12 })
    .onClick(() => {
      router.pushUrl({ url: 'pages/AdminDataDashboard' });
    });
  }

  @Builder
  StatCard(icon: string, value: number, label: string, color: string, trend?: string, isHot?: boolean) {
    Column({ space: 10 }) {
      Row() {
        Text(icon)
          .fontSize(26);
        Blank();
        if (trend && trend.length > 0) {
          Text(trend)
            .fontSize(11)
            .fontColor(isHot ? '#FF4D4F' : '#52C41A')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor((isHot ? '#FF4D4F' : '#52C41A') + '12')
            .borderRadius(6);
        }
      }
      .width('100%');

      Text(value.toString())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A2E');

      Row() {
        Text(label)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .fontColor('#888');
      }
    }
    .width('48%')
    .padding(16)
    .backgroundColor(color + '08')
    .borderRadius(14)
    .border({ width: { left: 3 }, color: color, style: BorderStyle.Solid })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 8 });
  }

  @Builder
  QuickActions() {
    Column({ space: 12 }) {
      Text('快捷操作')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%');

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.tabs, (tab: string, index: number) => {
          if (index > 0) {
            Row({ space: 10 }) {
              Text(this.tabIcons[index])
                .fontSize(22);
              Column({ space: 2 }) {
                Text(tab)
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333');
                Text(this.getTabDesc(index))
                  .fontSize(10)
                  .fontColor('#AAA');
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);

              Text('→')
                .fontSize(14)
                .fontColor('#CCC');
            }
            .width('48%')
            .padding({ left: 14, right: 14, top: 14, bottom: 14 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 6, color: '#00000004', offsetX: 0, offsetY: 2 })
            .margin({ bottom: 8 })
            .onClick(() => {
              if (index === 3 && this.currentAdmin && this.currentAdmin.role !== 1) {
                return;
              }
              router.pushUrl({ url: this.tabRoutes[index] });
            });
          }
        }, (tab: string, index: number) => `${index}`);
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 14, left: 14, right: 14 })
    .shadow({ radius: 12, color: '#00000005', offsetX: 0, offsetY: 3 });
  }

  getTabDesc(index: number): string {
    const descs: string[] = ['', '全局运营监控', '用户数据管理', '家属信息维护', '权限管理'];
    return descs[index] || '';
  }

  @Builder
  RecentSection() {
    Column({ space: 14 }) {
      Row() {
        Text('最近注册用户')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E');
        Blank();
        Text(`最新 ${this.recentUsers.length} 位`)
          .fontSize(11)
          .fontColor('#999')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor('#F5F5F5')
          .borderRadius(10);
      }
      .width('100%');

      if (this.recentUsers.length === 0) {
        Column({ space: 8 }) {
          Text('📭').fontSize(36);
          Text('暂无注册数据')
            .fontSize(13)
            .fontColor('#AAA');
        }
        .width('100%').height(140).justifyContent(FlexAlign.Center);
      } else {
        Column({ space: 6 }) {
          ForEach(this.recentUsers, (user: UserInfo, index: number) => {
            Row({ space: 12 }) {
              Column() {
                Text(String((user.real_name || user.realName || user.username || 'U').charAt(0)))
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width(34)
                  .height(34)
                  .borderRadius(12)
                  .backgroundColor(index % 3 === 0 ? '#1677FF' : index % 3 === 1 ? '#52C41A' : '#8B5CF6');
              }
              .width(34)
              .height(34)
              .borderRadius(12)
              .justifyContent(FlexAlign.Center);

              Column({ space: 3 }) {
                Text(user.real_name || user.realName || user.username)
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333');
                Text(user.create_time || user.createTime || '未知时间')
                  .fontSize(11)
                  .fontColor('#BBB');
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);

              Text(`${index + 1}`)
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#DDD');
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor('#FAFAFA')
            .borderRadius(10);
          }, (user: UserInfo, index: number) => `${index}`);
        }
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 14, left: 14, right: 14, bottom: 24 })
    .shadow({ radius: 12, color: '#00000005', offsetX: 0, offsetY: 3 });
  }

  @Builder
  SidebarOverlay() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
        .onClick(() => {
          this.showSidebar = false;
        });

      Column() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('🛡️')
              .fontSize(40);
            Text(this.currentAdmin ? this.currentAdmin.realName : '管理员')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
            Text(this.currentAdmin ? (this.currentAdmin.role === 1 ? '超级管理员' : '普通管理员') : '')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#94A3B8')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .backgroundColor('#334155')
              .borderRadius(6);
          }
          .width('100%')
          .padding({ top: 40, bottom: 24 })
          .alignItems(HorizontalAlign.Center);

          Divider().color('#334155');

          ForEach(this.tabs, (tab: string, index: number) => {
            Row({ space: 12 }) {
              Text(this.tabIcons[index])
                .fontSize(20);
              Text(tab)
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(this.selectedTab === index ? '#FFFFFF' : '#94A3B8')
                .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Normal);
            }
            .width('100%')
            .padding({ left: 20, top: 14, bottom: 14 })
            .borderRadius(8)
            .backgroundColor(this.selectedTab === index ? '#334155' : 'transparent')
            .onClick(() => {
              if (index === 3 && this.currentAdmin && this.currentAdmin.role !== 1) {
                return;
              }
              this.selectedTab = index;
              this.showSidebar = false;
              if (index === 0) {
                return;
              }
              router.pushUrl({ url: this.tabRoutes[index] });
            });
          }, (tab: string, index: number) => `${index}`);

          Blank();

          Row({ space: 8 }) {
            Text('🚪')
              .fontSize(18);
            Text('退出登录')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#EF4444');
          }
          .width('100%')
          .padding({ left: 20, top: 14, bottom: 14 })
          .borderRadius(8)
          .onClick(async () => {
            this.showSidebar = false;
            await AdminAuthService.logout();
          });
        }
        .width('75%')
        .height('100%')
        .padding({ left: 12, right: 12, bottom: 24 })
        .backgroundColor('#1E293B');
      }
      .align(Alignment.Start);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }
}
