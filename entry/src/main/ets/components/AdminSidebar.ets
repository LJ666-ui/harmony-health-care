import router from '@ohos.router';
import { AuthManager, UserRole } from '../utils/AuthManager';
import { AdminRole } from '../models/AdminInfo';

interface MenuItem {
  name: string;
  icon: string;
  route: string;
  requiredRole: UserRole;
}

@Component
export struct AdminSidebar {
  @StorageLink('currentAdmin') currentAdmin: AdminInfo | null = null;
  @Prop activeRoute: string = 'AdminDashboard';

  private menuItems: MenuItem[] = [
    { name: '仪表盘', icon: $r('sys.symbol.chart_bar'), route: 'AdminDashboard', requiredRole: UserRole.ADMIN },
    { name: '用户管理', icon: $r('sys.symbol.person_3'), route: 'AdminUsers', requiredRole: UserRole.ADMIN },
    { name: '家属管理', icon: $r('sys.symbol.person_2'), route: 'AdminFamily', requiredRole: UserRole.ADMIN },
    { name: '管理员管理', icon: $r('sys.symbol.person_badge_key'), route: 'AdminManage', requiredRole: UserRole.SUPER_ADMIN }
  ];

  private hasPermission(requiredRole: UserRole): boolean {
    const authManager: AuthManager = AuthManager.getInstance();
    const currentRole: UserRole = authManager.getCurrentRole();
    
    if (requiredRole === UserRole.SUPER_ADMIN) {
      return currentRole === UserRole.SUPER_ADMIN;
    }
    
    return currentRole === UserRole.ADMIN || currentRole === UserRole.SUPER_ADMIN;
  }

  private async navigateTo(route: string): Promise<void> {
    try {
      await router.pushUrl({ url: `pages/${route}` });
    } catch (e) {
      console.error(`Navigate to ${route} failed:`, e);
    }
  }

  private async goToUserSide(): Promise<void> {
    try {
      await router.pushUrl({ url: 'pages/HomePage' });
    } catch (e) {
      console.error('Navigate to user side failed:', e);
    }
  }

  build() {
    Column() {
      Text('管理后台')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })
        .width('100%')
        .textAlign(TextAlign.Center)

      Divider().margin({ bottom: 10 })

      ForEach(this.menuItems, (item: MenuItem) => {
        if (this.hasPermission(item.requiredRole)) {
          Row() {
            SymbolGlyph(item.icon)
              .fontSize(20)
              .fontColor([this.activeRoute === item.route ? $r('sys.color.accent_color') : $r('sys.color.on_surface')])
              .margin({ right: 12 })

            Text(item.name)
              .fontSize(16)
              .fontColor(this.activeRoute === item.route ? $r('sys.color.accent_color') : $r('sys.color.on_surface'))
          }
          .width('100%')
          .height(50)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.activeRoute === item.route ? $r('sys.color.surface_variant') : Color.Transparent)
          .borderRadius(8)
          .onClick(() => {
            this.navigateTo(item.route);
          })
          .margin({ bottom: 4 })
        }
      })

      Blank()

      Divider().margin({ bottom: 10 })

      Button('返回用户端')
        .width('90%')
        .height(40)
        .onClick(() => {
          this.goToUserSide();
        })
        .margin({ bottom: 20 })
    }
    .width(200)
    .height('100%')
    .backgroundColor($r('sys.color.surface'))
    .border({ width: { right: 1 }, color: $r('sys.color.outline_variant') })
  }
}
