import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminAuthService, AdminLoginResponse } from '../services/AdminAuthService';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct AdminDashboard {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: AdminLoginResponse | null = null;
  @State selectedTab: number = 0;
  @State showSidebar: boolean = false;
  @State hasAccess: boolean = false;

  private tabs: string[] = ['仪表盘', '数据大屏', '用户管理', '家属管理', '管理员管理'];
  private tabIcons: string[] = ['📊', '🖥️', '👥', '👨‍👩‍👧', '🛡️'];
  private tabRoutes: string[] = [
    'pages/AdminDashboard',
    'pages/AdminDataDashboard',
    'pages/AdminUsers',
    'pages/AdminFamily',
    'pages/AdminManage'
  ];

  aboutToAppear(): void {
    this.checkAccess();
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
          .fontSize(22)
          .fontColor('#FFFFFF');
      }
      .width(40)
      .height(40)
      .backgroundColor('#334155')
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

      Row({ space: 6 }) {
        Text('👤')
          .fontSize(16);
        Text(this.currentAdmin ? this.currentAdmin.realName : '管理员')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#FFFFFFCC');
      }
      .onClick(() => {
        this.showSidebar = true;
      });
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#1E293B')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }

  @Builder
  StatsSection() {
    Column({ space: 12 }) {
      Text('数据概览')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%');

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        this.StatCard('👥', 0, '注册用户', '#1677FF');
        this.StatCard('👨‍👩‍👧', 0, '家属记录', '#52C41A');
        this.StatCard('🏥', 0, '医生用户', '#FAAD14');
        this.StatCard('🛡️', 0, '管理员', '#8B5CF6');
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 12, right: 12 });
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
  StatCard(icon: string, value: number, label: string, color: string) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(28);
      Text(value.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color);
      Text(label)
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY);
    }
    .width('47%')
    .padding(16)
    .backgroundColor('#F8FAFC')
    .borderRadius(12)
    .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
    .margin({ bottom: 8 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
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
            Column({ space: 6 }) {
              Text(this.tabIcons[index])
                .fontSize(24);
              Text(tab)
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
            }
            .width('47%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Solid })
            .margin({ bottom: 8 })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
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
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 12, right: 12 });
  }

  @Builder
  RecentSection() {
    Column({ space: 12 }) {
      Text('最近注册用户')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%');

      Text('暂无数据')
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_HINT)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding(20);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 12, right: 12, bottom: 24 });
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
