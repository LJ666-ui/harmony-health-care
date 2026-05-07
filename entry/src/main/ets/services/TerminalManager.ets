import { router } from '@kit.ArkUI';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';

/**
 * 用户角色类型
 */
export enum UserRole {
  PATIENT = 'PATIENT',      // 患者
  DOCTOR = 'DOCTOR',        // 医生
  NURSE = 'NURSE',          // 护士
  FAMILY = 'FAMILY',        // 家属
  ADMIN = 'ADMIN'           // 管理员
}

/**
 * 终端类型
 */
export enum TerminalType {
  PATIENT = 'PATIENT',
  DOCTOR = 'DOCTOR',
  NURSE = 'NURSE',
  FAMILY = 'FAMILY',
  ADMIN = 'ADMIN'
}

/**
 * 终端配置
 */
export interface TerminalConfig {
  type: TerminalType;
  name: string;
  entryPage: string;
  allowedRoles: UserRole[];
  icon: string;
  theme: {
    primaryColor: string;
    secondaryColor: string;
  };
}

/**
 * 终端管理器
 * 实现多端完全隔离机制
 */
export class TerminalManager {
  private static instance: TerminalManager | null = null;
  private currentTerminal: TerminalType | null = null;
  private currentUserRole: UserRole | null = null;
  private currentUserId: string = '';
  
  // 终端配置映射
  private terminalConfigs: Map<TerminalType, TerminalConfig> = new Map([
    [TerminalType.PATIENT, {
      type: TerminalType.PATIENT,
      name: '患者端',
      entryPage: 'pages/HomePage',
      allowedRoles: [UserRole.PATIENT],
      icon: 'patient_icon',
      theme: {
        primaryColor: '#4A90E2',
        secondaryColor: '#7ED321'
      }
    }],
    [TerminalType.DOCTOR, {
      type: TerminalType.DOCTOR,
      name: '医生端',
      entryPage: 'pages/DoctorHomePage',
      allowedRoles: [UserRole.DOCTOR],
      icon: 'doctor_icon',
      theme: {
        primaryColor: '#5B7FFF',
        secondaryColor: '#00C9A7'
      }
    }],
    [TerminalType.NURSE, {
      type: TerminalType.NURSE,
      name: '护士端',
      entryPage: 'pages/NurseWorkbench',
      allowedRoles: [UserRole.NURSE],
      icon: 'nurse_icon',
      theme: {
        primaryColor: '#FF6B9D',
        secondaryColor: '#C44569'
      }
    }],
    [TerminalType.FAMILY, {
      type: TerminalType.FAMILY,
      name: '家属端',
      entryPage: 'pages/FamilyHome',
      allowedRoles: [UserRole.FAMILY],
      icon: 'family_icon',
      theme: {
        primaryColor: '#F5A623',
        secondaryColor: '#BD10E0'
      }
    }],
    [TerminalType.ADMIN, {
      type: TerminalType.ADMIN,
      name: '管理员端',
      entryPage: 'pages/AdminDashboard',
      allowedRoles: [UserRole.ADMIN],
      icon: 'admin_icon',
      theme: {
        primaryColor: '#9B59B6',
        secondaryColor: '#3498DB'
      }
    }]
  ]);
  
  // 页面访问权限映射
  private pageAccessMap: Map<string, TerminalType[]> = new Map([
    // 患者端页面
    ['pages/HomePage', [TerminalType.PATIENT]],
    ['pages/HealthPage', [TerminalType.PATIENT]],
    ['pages/MedicalPage', [TerminalType.PATIENT]],
    ['pages/MedicationPage', [TerminalType.PATIENT]],
    ['pages/HealthRecords', [TerminalType.PATIENT]],
    ['pages/EmergencyPage', [TerminalType.PATIENT]],
    
    // 医生端页面
    ['pages/DoctorHomePage', [TerminalType.DOCTOR]],
    ['pages/DoctorChatPage', [TerminalType.DOCTOR]],
    ['pages/DoctorFamilyChatPage', [TerminalType.DOCTOR]],
    
    // 护士端页面
    ['pages/NurseWorkbench', [TerminalType.NURSE]],
    ['pages/NurseStationDashboard', [TerminalType.NURSE]],
    ['pages/NurseProfile', [TerminalType.NURSE]],
    
    // 家属端页面
    ['pages/FamilyHome', [TerminalType.FAMILY]],
    ['pages/FamilyMedication', [TerminalType.FAMILY]],
    ['pages/FamilyHealthRecords', [TerminalType.FAMILY]],
    
    // 管理员端页面
    ['pages/AdminDashboard', [TerminalType.ADMIN]],
    ['pages/AdminUsers', [TerminalType.ADMIN]],
    ['pages/AdminManage', [TerminalType.ADMIN]],
    ['pages/AdminDataDashboard', [TerminalType.ADMIN]],
    
    // 公共页面（所有端都可访问）
    ['pages/Login', [TerminalType.PATIENT, TerminalType.DOCTOR, TerminalType.NURSE, TerminalType.FAMILY, TerminalType.ADMIN]],
    ['pages/Profile', [TerminalType.PATIENT, TerminalType.DOCTOR, TerminalType.NURSE, TerminalType.FAMILY, TerminalType.ADMIN]],
    ['pages/SettingsPage', [TerminalType.PATIENT, TerminalType.DOCTOR, TerminalType.NURSE, TerminalType.FAMILY, TerminalType.ADMIN]]
  ]);
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  static getInstance(): TerminalManager {
    if (!TerminalManager.instance) {
      TerminalManager.instance = new TerminalManager();
    }
    return TerminalManager.instance;
  }
  
  /**
   * 初始化终端
   * @param userInfo 用户信息
   */
  async init(userInfo: PersistedUserInfo): Promise<boolean> {
    try {
      this.currentUserId = userInfo.userId?.toString() || '';
      this.currentUserRole = this.mapUserTypeToRole(userInfo.userType || 0);
      this.currentTerminal = this.mapRoleToTerminal(this.currentUserRole);
      
      if (!this.currentTerminal) {
        console.error('无法确定终端类型');
        return false;
      }
      
      // 保存当前终端信息
      const settings = SettingsUtil.getInstance();
      await settings.saveTerminalInfo({
        terminalType: this.currentTerminal,
        userRole: this.currentUserRole
      });
      
      return true;
    } catch (error) {
      console.error('初始化终端失败:', error);
      return false;
    }
  }
  
  /**
   * 验证页面访问权限
   * @param pageUrl 页面URL
   */
  canAccessPage(pageUrl: string): boolean {
    if (!this.currentTerminal) {
      return false;
    }
    
    const allowedTerminals = this.pageAccessMap.get(pageUrl);
    if (!allowedTerminals) {
      // 未配置的页面默认不允许访问
      console.warn(`页面 ${pageUrl} 未配置访问权限`);
      return false;
    }
    
    return allowedTerminals.includes(this.currentTerminal);
  }
  
  /**
   * 导航到页面（带权限检查）
   * @param pageUrl 页面URL
   * @param params 参数（可选）
   */
  async navigateToPage(pageUrl: string, params?: Record<string, any>): Promise<boolean> {
    // 检查权限
    if (!this.canAccessPage(pageUrl)) {
      console.error(`无权访问页面: ${pageUrl}`);
      await this.showAccessDenied();
      return false;
    }
    
    try {
      await router.pushUrl({
        url: pageUrl,
        params: params
      });
      return true;
    } catch (error) {
      console.error('页面导航失败:', error);
      return false;
    }
  }
  
  /**
   * 替换当前页面（带权限检查）
   * @param pageUrl 页面URL
   * @param params 参数（可选）
   */
  async replacePage(pageUrl: string, params?: Record<string, any>): Promise<boolean> {
    // 检查权限
    if (!this.canAccessPage(pageUrl)) {
      console.error(`无权访问页面: ${pageUrl}`);
      await this.showAccessDenied();
      return false;
    }
    
    try {
      await router.replaceUrl({
        url: pageUrl,
        params: params
      });
      return true;
    } catch (error) {
      console.error('页面替换失败:', error);
      return false;
    }
  }
  
  /**
   * 返回上一页
   */
  async goBack(): Promise<boolean> {
    try {
      await router.back();
      return true;
    } catch (error) {
      console.error('返回失败:', error);
      return false;
    }
  }
  
  /**
   * 获取当前终端类型
   */
  getCurrentTerminal(): TerminalType | null {
    return this.currentTerminal;
  }
  
  /**
   * 获取当前用户角色
   */
  getCurrentUserRole(): UserRole | null {
    return this.currentUserRole;
  }
  
  /**
   * 获取当前用户ID
   */
  getCurrentUserId(): string {
    return this.currentUserId;
  }
  
  /**
   * 获取终端配置
   * @param terminalType 终端类型
   */
  getTerminalConfig(terminalType: TerminalType): TerminalConfig | undefined {
    return this.terminalConfigs.get(terminalType);
  }
  
  /**
   * 获取当前终端配置
   */
  getCurrentTerminalConfig(): TerminalConfig | undefined {
    if (!this.currentTerminal) {
      return undefined;
    }
    return this.terminalConfigs.get(this.currentTerminal);
  }
  
  /**
   * 获取所有终端配置
   */
  getAllTerminalConfigs(): TerminalConfig[] {
    return Array.from(this.terminalConfigs.values());
  }
  
  /**
   * 检查是否为特定终端
   * @param terminalType 终端类型
   */
  isTerminal(terminalType: TerminalType): boolean {
    return this.currentTerminal === terminalType;
  }
  
  /**
   * 检查是否为特定角色
   * @param role 用户角色
   */
  isRole(role: UserRole): boolean {
    return this.currentUserRole === role;
  }
  
  /**
   * 显示访问拒绝提示
   */
  private async showAccessDenied(): Promise<void> {
    // 这里可以显示一个对话框或提示
    console.error('访问被拒绝：您无权访问此页面');
    // 可以跳转到首页
    const config = this.getCurrentTerminalConfig();
    if (config) {
      await router.replaceUrl({ url: config.entryPage });
    }
  }
  
  /**
   * 映射用户类型到角色
   * @param userType 用户类型（数字）
   */
  private mapUserTypeToRole(userType: number): UserRole {
    switch (userType) {
      case 0:
        return UserRole.PATIENT;
      case 1:
        return UserRole.DOCTOR;
      case 2:
        return UserRole.NURSE;
      case 3:
        return UserRole.FAMILY;
      case 4:
        return UserRole.ADMIN;
      default:
        return UserRole.PATIENT;
    }
  }
  
  /**
   * 映射角色到终端
   * @param role 用户角色
   */
  private mapRoleToTerminal(role: UserRole): TerminalType | null {
    switch (role) {
      case UserRole.PATIENT:
        return TerminalType.PATIENT;
      case UserRole.DOCTOR:
        return TerminalType.DOCTOR;
      case UserRole.NURSE:
        return TerminalType.NURSE;
      case UserRole.FAMILY:
        return TerminalType.FAMILY;
      case UserRole.ADMIN:
        return TerminalType.ADMIN;
      default:
        return null;
    }
  }
  
  /**
   * 登出并清理
   */
  async logout(): Promise<void> {
    this.currentTerminal = null;
    this.currentUserRole = null;
    this.currentUserId = '';
    
    const settings = SettingsUtil.getInstance();
    await settings.clearAll();
    
    // 跳转到登录页
    await router.replaceUrl({ url: 'pages/Login' });
  }
  
  /**
   * 销毁单例
   */
  static destroy(): void {
    if (TerminalManager.instance) {
      TerminalManager.instance = null;
    }
  }
}
