import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

/**
 * 管理员登录请求接口
 */
export interface AdminLoginRequest {
  username: string;
  password: string;
}

/**
 * 管理员登录响应接口
 */
export interface AdminLoginResponse {
  token: string;
  adminId: number;
  username: string;
  realName: string;
  role: number;
  avatar?: string;
}

/**
 * 管理员信息接口
 */
export interface AdminInfo {
  id: number;
  username: string;
  realName: string;
  phone?: string;
  email?: string;
  avatar?: string;
  role: number;
  status: number;
  lastLoginTime?: string;
  lastLoginIp?: string;
  createTime?: string;
}

/**
 * 管理员认证服务类
 * 封装管理员认证相关的API调用和状态管理
 */
export class AdminAuthService {
  private static readonly BASE_URL = '/admin';

  /**
   * 管理员登录
   * @param request 登录请求参数
   * @returns 登录响应
   */
  static async login(request: AdminLoginRequest): Promise<BaseResponse<AdminLoginResponse>> {
    return await HttpUtil.post<AdminLoginResponse>(`${AdminAuthService.BASE_URL}/login`, request, { 
      skipAuth: true,
      isAdmin: true  // 标识为管理员请求
    });
  }

  /**
   * 获取管理员信息
   * @returns 管理员信息
   */
  static async getAdminInfo(): Promise<BaseResponse<AdminInfo>> {
    return await HttpUtil.get<AdminInfo>(`${AdminAuthService.BASE_URL}/info`, undefined, { isAdmin: true });
  }

  /**
   * 管理员登出
   * 清除本地存储的认证信息并跳转到管理员登录页
   */
  static async logout(): Promise<void> {
    try {
      AppStorage.delete('adminToken');
      AppStorage.delete('adminInfo');
      AppStorage.delete('isAdminLoggedIn');
      router.replaceUrl({ url: 'pages/AdminLogin' });
    } catch (error) {
      console.error('管理员登出失败:', error);
    }
  }

  /**
   * 检查管理员Token是否有效
   * @returns Token是否有效
   */
  static async isTokenValid(): Promise<boolean> {
    try {
      const token = AppStorage.get<string>('adminToken');
      return token !== undefined && token !== null && token.length > 0;
    } catch (error) {
      console.error('检查管理员Token失败:', error);
      return false;
    }
  }

  /**
   * 保存认证信息到本地
   * @param token JWT Token
   * @param adminInfo 管理员信息
   */
  static async saveAuthInfo(token: string, adminInfo: AdminLoginResponse): Promise<void> {
    try {
      // 使用独立的管理员Token存储
      await HttpUtil.saveAdminToken(token);
      AppStorage.setOrCreate<string>('adminToken', token);
      AppStorage.setOrCreate<AdminLoginResponse>('adminInfo', adminInfo);
      AppStorage.setOrCreate<boolean>('isAdminLoggedIn', true);
    } catch (error) {
      console.error('保存管理员认证信息失败:', error);
    }
  }

  /**
   * 获取当前管理员信息
   * @returns 管理员信息
   */
  static getCurrentAdmin(): AdminLoginResponse | null {
    try {
      const adminInfo = AppStorage.get<AdminLoginResponse>('adminInfo');
      return adminInfo !== undefined ? adminInfo : null;
    } catch (error) {
      console.error('获取管理员信息失败:', error);
      return null;
    }
  }
}
