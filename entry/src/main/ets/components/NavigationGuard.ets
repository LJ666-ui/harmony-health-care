import router from '@ohos.router';
import { AuthManager, UserRole } from '../utils/AuthManager';
import { PAGE_PERMISSIONS } from '../models/PermissionInfo';

export class NavigationGuard {
  static checkPermission(routeName: string): boolean {
    const authManager: AuthManager = AuthManager.getInstance();
    return authManager.hasRoutePermission(routeName);
  }

  static async navigateTo(routeName: string, params?: Record<string, Object>): Promise<void> {
    const hasPermission: boolean = this.checkPermission(routeName);
    
    if (!hasPermission) {
      const authManager: AuthManager = AuthManager.getInstance();
      const currentRole: UserRole = authManager.getCurrentRole();
      
      if (currentRole === UserRole.GUEST) {
        await router.pushUrl({
          url: 'pages/Login'
        });
      } else {
        console.error(`No permission to access ${routeName}`);
      }
      return;
    }

    try {
      const routeConfig: Record<string, Object> = {
        url: `pages/${routeName}`
      };
      
      if (params) {
        routeConfig['params'] = params;
      }
      
      await router.pushUrl(routeConfig);
    } catch (e) {
      console.error(`Navigation to ${routeName} failed:`, e);
    }
  }

  static async replaceTo(routeName: string, params?: Record<string, Object>): Promise<void> {
    const hasPermission: boolean = this.checkPermission(routeName);
    
    if (!hasPermission) {
      const authManager: AuthManager = AuthManager.getInstance();
      const currentRole: UserRole = authManager.getCurrentRole();
      
      if (currentRole === UserRole.GUEST) {
        await router.replaceUrl({
          url: 'pages/Login'
        });
      } else {
        console.error(`No permission to access ${routeName}`);
      }
      return;
    }

    try {
      const routeConfig: Record<string, Object> = {
        url: `pages/${routeName}`
      };
      
      if (params) {
        routeConfig['params'] = params;
      }
      
      await router.replaceUrl(routeConfig);
    } catch (e) {
      console.error(`Navigation replace to ${routeName} failed:`, e);
    }
  }

  static async goBack(): Promise<void> {
    try {
      await router.back();
    } catch (e) {
      console.error('Navigation go back failed:', e);
    }
  }

  static getPagePermissions(): Record<string, string[]> {
    return PAGE_PERMISSIONS;
  }
}
