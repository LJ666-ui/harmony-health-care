import { SettingsUtil } from './SettingsUtil';
import { RouterUtil } from './RouterUtil';

export enum UserRole {
  DOCTOR = 'DOCTOR',
  NURSE = 'NURSE',
  ADMIN = 'ADMIN',
  FAMILY = 'FAMILY'
}

export class AuthUtil {
  private static instance: AuthUtil | null = null;

  static getInstance(): AuthUtil {
    if (AuthUtil.instance === null) {
      AuthUtil.instance = new AuthUtil();
    }
    return AuthUtil.instance;
  }

  async checkLoginStatus(): Promise<boolean> {
    return await SettingsUtil.getInstance().isNurseLoggedIn();
  }

  async getToken(): Promise<string> {
    return await SettingsUtil.getInstance().getNurseToken();
  }

  getTokenSync(): string {
    return SettingsUtil.getInstance().getNurseTokenSync();
  }

  async getUserRole(): Promise<UserRole | null> {
    const userInfo = await SettingsUtil.getInstance().getNurseInfo();
    if (!userInfo) {
      return null;
    }
    
    const info = userInfo as Record<string, Object>;
    const role = info['role'] as string;
    
    switch (role?.toUpperCase()) {
      case 'DOCTOR':
        return UserRole.DOCTOR;
      case 'NURSE':
        return UserRole.NURSE;
      case 'ADMIN':
        return UserRole.ADMIN;
      case 'FAMILY':
        return UserRole.FAMILY;
      default:
        return UserRole.NURSE;
    }
  }

  async hasPermission(requiredRoles: UserRole[]): Promise<boolean> {
    const userRole = await this.getUserRole();
    if (!userRole) {
      return false;
    }
    return requiredRoles.includes(userRole);
  }

  async validatePageAccess(requiredRoles: UserRole[]): Promise<boolean> {
    const isLoggedIn = await this.checkLoginStatus();
    if (!isLoggedIn) {
      await this.redirectToLogin();
      return false;
    }

    const hasPermission = await this.hasPermission(requiredRoles);
    if (!hasPermission) {
      console.warn('AuthUtil - User does not have permission');
      return false;
    }

    return true;
  }

  async isTokenValid(): Promise<boolean> {
    const token = await this.getToken();
    if (!token || token.length === 0) {
      return false;
    }

    return true;
  }

  private async redirectToLogin(): Promise<void> {
    try {
      await RouterUtil.replaceUrl('pages/NurseLoginPage');
    } catch (e) {
      console.error('AuthUtil - redirectToLogin failed:', e);
    }
  }

  async logout(): Promise<void> {
    await SettingsUtil.getInstance().clearNurseAuth();
    await this.redirectToLogin();
  }
}
