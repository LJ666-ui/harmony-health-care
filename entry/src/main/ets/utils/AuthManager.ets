import { SessionInfo, SessionInfoHelper, UserType } from '../models/SessionInfo';
import { AdminInfo, AdminRole } from '../models/AdminInfo';
import { PermissionInfoHelper, PAGE_PERMISSIONS } from '../models/PermissionInfo';

export enum UserRole {
  GUEST = 'guest',
  USER = 'user',
  DOCTOR = 'doctor',
  ADMIN = 'admin',
  SUPER_ADMIN = 'superAdmin'
}

export interface AuthInfo {
  role: UserRole;
  userId: number;
  username: string;
  permissions: string[];
}

export class AuthManager {
  private static instance: AuthManager | null = null;

  private constructor() {}

  static getInstance(): AuthManager {
    if (AuthManager.instance === null) {
      AuthManager.instance = new AuthManager();
    }
    return AuthManager.instance;
  }

  getCurrentRole(): UserRole {
    const adminSession: SessionInfo | null = this.getAdminSession();
    if (adminSession && SessionInfoHelper.isValid(adminSession)) {
      const adminInfo: AdminInfo | null = this.getAdminInfo();
      if (adminInfo) {
        return adminInfo.role === AdminRole.SUPER_ADMIN ? UserRole.SUPER_ADMIN : UserRole.ADMIN;
      }
    }

    const userSession: SessionInfo | null = this.getUserSession();
    if (userSession && SessionInfoHelper.isValid(userSession)) {
      const userType: number | undefined = AppStorage.get<number>('userType');
      if (userType === 2) {
        return UserRole.DOCTOR;
      }
      return UserRole.USER;
    }

    return UserRole.GUEST;
  }

  getAuthInfo(): AuthInfo | null {
    const role: UserRole = this.getCurrentRole();
    
    const adminSession: SessionInfo | null = this.getAdminSession();
    if (adminSession && SessionInfoHelper.isValid(adminSession)) {
      const adminInfo: AdminInfo | null = this.getAdminInfo();
      if (adminInfo) {
        return {
          role: role,
          userId: adminInfo.id,
          username: adminInfo.username,
          permissions: PermissionInfoHelper.getPermissions(role)
        };
      }
    }

    const userSession: SessionInfo | null = this.getUserSession();
    if (userSession && SessionInfoHelper.isValid(userSession)) {
      return {
        role: role,
        userId: userSession.userId,
        username: userSession.username,
        permissions: PermissionInfoHelper.getPermissions(role)
      };
    }

    return null;
  }

  hasPermission(permission: string): boolean {
    const role: UserRole = this.getCurrentRole();
    return PermissionInfoHelper.hasPermission(role, permission);
  }

  hasRoutePermission(routeName: string): boolean {
    const role: UserRole = this.getCurrentRole();
    const allowedRoles: string[] | undefined = PAGE_PERMISSIONS[routeName];
    if (!allowedRoles) {
      return false;
    }
    return allowedRoles.includes(role);
  }

  isAdmin(): boolean {
    const role: UserRole = this.getCurrentRole();
    return role === UserRole.ADMIN || role === UserRole.SUPER_ADMIN;
  }

  isSuperAdmin(): boolean {
    const role: UserRole = this.getCurrentRole();
    return role === UserRole.SUPER_ADMIN;
  }

  clearAuth(): void {
    AppStorage.setOrCreate<SessionInfo | null>('adminSession', null);
    AppStorage.setOrCreate<AdminInfo | null>('currentAdmin', null);
  }

  private getAdminSession(): SessionInfo | null {
    return AppStorage.get<SessionInfo | null>('adminSession', null);
  }

  private getUserSession(): SessionInfo | null {
    const token: string = AppStorage.get<string>('token', '');
    const userId: number = AppStorage.get<number>('userId', 0);
    const username: string = AppStorage.get<string>('username', '');
    const isLoggedIn: boolean = AppStorage.get<boolean>('isLoggedIn', false);

    if (!isLoggedIn || token.length === 0 || userId === 0) {
      return null;
    }

    const session: SessionInfo = new SessionInfo();
    session.sessionId = 'user_session';
    session.userId = userId;
    session.userType = UserType.USER;
    session.username = username;
    session.token = token;
    session.loginTime = Date.now() - 3600000;
    session.expireTime = Date.now() + 3600000;

    return session;
  }

  private getAdminInfo(): AdminInfo | null {
    return AppStorage.get<AdminInfo | null>('currentAdmin', null);
  }
}
