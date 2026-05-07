import { SessionInfo, SessionInfoHelper, UserType } from '../models/SessionInfo';
import { AdminInfo, AdminRole } from '../models/AdminInfo';
import { PermissionInfoHelper, PAGE_PERMISSIONS } from '../models/PermissionInfo';

export enum UserRole {
  GUEST = 'guest',
  USER = 'user',
  DOCTOR = 'doctor',
  FAMILY = 'family',  // 家属角色
  NURSE = 'nurse',     // 护士角色
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
    // 检查家属登录状态
    const isFamilyLoggedIn: boolean = AppStorage.get<boolean>('isFamilyLoggedIn') || false;
    if (isFamilyLoggedIn) {
      return UserRole.FAMILY;
    }

    // 检查护士登录状态
    const isNurseLoggedIn: boolean = AppStorage.get<boolean>('isNurseLoggedIn') || false;
    if (isNurseLoggedIn) {
      return UserRole.NURSE;
    }

    // 检查管理员登录状态
    const adminSession: SessionInfo | null = this.getAdminSession();
    if (adminSession && SessionInfoHelper.isValid(adminSession)) {
      const adminInfo: AdminInfo | null = this.getAdminInfo();
      if (adminInfo) {
        return adminInfo.role === AdminRole.SUPER_ADMIN ? UserRole.SUPER_ADMIN : UserRole.ADMIN;
      }
    }

    // 检查普通用户登录状态
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
    const session: SessionInfo | null | undefined = AppStorage.get<SessionInfo | null>('adminSession');
    return session !== undefined ? session : null;
  }

  private getUserSession(): SessionInfo | null {
    const token: string | undefined = AppStorage.get<string>('token');
    const userId: number | undefined = AppStorage.get<number>('userId');
    const username: string | undefined = AppStorage.get<string>('username');
    const isLoggedIn: boolean | undefined = AppStorage.get<boolean>('isLoggedIn');

    if (!isLoggedIn || !token || token.length === 0 || !userId || userId === 0) {
      return null;
    }

    if (!isLoggedIn || !token || token.length === 0 || !userId || userId === 0) {
      return null;
    }

    const session: SessionInfo = new SessionInfo();
    session.sessionId = 'user_session';
    session.userId = userId;
    session.userType = UserType.USER;
    session.username = username || '';
    session.token = token;
    session.loginTime = Date.now() - 3600000;
    session.expireTime = Date.now() + 3600000;

    return session;
  }

  private getAdminInfo(): AdminInfo | null {
    const admin: AdminInfo | null | undefined = AppStorage.get<AdminInfo | null>('currentAdmin');
    return admin !== undefined ? admin : null;
  }
}
