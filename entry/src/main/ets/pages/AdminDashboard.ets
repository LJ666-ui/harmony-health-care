import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminMock, AdminInfo, UserInfo } from '../mock/adminMock';

@Entry
@Component
struct AdminDashboard {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentAdmin: AdminInfo | null = null;
  @State selectedTab: number = 0;
  @State showSidebar: boolean = false;

  private tabs: string[] = ['仪表盘', '用户管理', '家属管理', '管理员管理'];
  private tabIcons: string[] = ['📊', '👥', '👨‍👩‍👧', '🛡️'];
  private tabRoutes: string[] = [
    'pages/AdminDashboard',
    'pages/AdminUsers',
    'pages/AdminFamily',
    'pages/AdminManage'
  ];

  aboutToAppear(): void {
    this.currentAdmin = AppStorage.get<AdminInfo>('currentAdmin') || null;
  }

  build() {
    Stack() {
      Column() {
        this.TitleBar();
        this.StatsSection();
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
        Text(this.currentAdmin ? this.currentAdmin.real_name : '管理员')
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
        this.StatCard('👥', AdminMock.users.length, '注册用户', '#1677FF');
        this.StatCard('👨‍👩‍👧', AdminMock.familyMembers.length, '家属记录', '#52C41A');
        this.StatCard('🏥', AdminMock.users.filter(u => u.user_type === 1).length, '医生用户', '#FAAD14');
        this.StatCard('🛡️', AdminMock.admins.length, '管理员', '#8B5CF6');
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

      ForEach(AdminMock.users.slice(-5).reverse(), (user: UserInfo) => {
        Row() {
          Column({ space: 2 }) {
            Text(user.username)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium);
            Text(user.phone)
              .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_HINT);
          }
          .alignItems(HorizontalAlign.Start);

          Blank();

          Text(AdminMock.getUserTypeName(user.user_type))
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(AdminMock.getUserTypeColor(user.user_type))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(AdminMock.getUserTypeColor(user.user_type) + '15')
            .borderRadius(6);
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#F8FAFC')
        .borderRadius(8);
      }, (user: UserInfo) => `${user.id}`);
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
            Text(this.currentAdmin ? this.currentAdmin.real_name : '管理员')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
            Text(this.currentAdmin ? AdminMock.getRoleName(this.currentAdmin.role) : '')
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
          .onClick(() => {
            this.showSidebar = false;
            AppStorage.setOrCreate<AdminInfo | null>('currentAdmin', null);
            router.replaceUrl({ url: 'pages/AdminLogin' });
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
