import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';

/**
 * 用户登录请求接口
 */
export interface UserLoginRequest {
  phone: string;
  password: string;
}

/**
 * 用户注册请求接口
 */
export interface UserRegisterRequest {
  phone: string;
  password: string;
  verificationCode: string;
  agreedToTerms: boolean;
}

/**
 * 登录响应接口
 */
export interface LoginResponse {
  token: string;
  userId?: number;
  username?: string;
  userType?: number;
  userInfo?: PersistedUserInfo;
}

/**
 * 用户信息接口
 */
export interface UserInfo {
  userId: number;
  username: string;
  avatar?: string;
  userType?: number;
}

/**
 * 认证服务类
 * 封装用户认证相关的API调用和状态管理
 */
export class AuthService {
  private static readonly BASE_URL = '/user';

  /**
   * 用户登录
   * @param request 登录请求参数
   * @returns 登录响应
   */
  static async login(request: UserLoginRequest): Promise<BaseResponse<LoginResponse>> {
    const loginData = {
      username: request.phone,
      password: request.password
    };
    return await HttpUtil.post<LoginResponse>(`${this.BASE_URL}/login`, loginData);
  }

  /**
   * 用户注册
   * @param request 注册请求参数
   * @returns 注册响应
   */
  static async register(request: UserRegisterRequest): Promise<BaseResponse<{ userId: number }>> {
    const registerData = {
      username: request.phone,
      password: request.password,
      verificationCode: request.verificationCode,
      agreedToTerms: request.agreedToTerms
    };
    return await HttpUtil.post<{ userId: number }>(`${this.BASE_URL}/register`, registerData);
  }

  /**
   * 发送验证码
   * @param phone 手机号
   * @returns 发送结果
   */
  static async sendVerificationCode(phone: string): Promise<BaseResponse<void>> {
    return await HttpUtil.post<void>(`${this.BASE_URL}/send-code`, { phone });
  }

  /**
   * 用户登出
   * 清除本地存储的认证信息并跳转到登录页
   */
  static async logout(): Promise<void> {
    try {
      const settings = SettingsUtil.getInstance();
      await settings.clearAll();
      AppStorage.delete('userToken');
      AppStorage.delete('userInfo');
      AppStorage.delete('isLoggedIn');
      AppStorage.delete('username');
      AppStorage.delete('userId');
      router.replaceUrl({ url: 'pages/Login' });
    } catch (error) {
      console.error('登出失败:', error);
    }
  }

  /**
   * 检查Token是否有效
   * @returns Token是否有效
   */
  static async isTokenValid(): Promise<boolean> {
    try {
      const settings = SettingsUtil.getInstance();
      const token = await settings.getToken();
      return token && token.length > 0;
    } catch (error) {
      console.error('检查Token失败:', error);
      return false;
    }
  }

  /**
   * 获取当前用户信息
   * @returns 用户信息
   */
  static async getCurrentUser(): Promise<PersistedUserInfo | null> {
    try {
      const settings = SettingsUtil.getInstance();
      return await settings.getUserInfo();
    } catch (error) {
      console.error('获取用户信息失败:', error);
      return null;
    }
  }

  /**
   * 保存认证信息到本地
   * @param token JWT Token
   * @param userInfo 用户信息
   */
  static async saveAuthInfo(token: string, userInfo: PersistedUserInfo): Promise<void> {
    try {
      await HttpUtil.saveToken(token);
      const settings = SettingsUtil.getInstance();
      await settings.saveUserInfo(userInfo);
      AppStorage.setOrCreate<string>('userToken', token);
      AppStorage.setOrCreate<PersistedUserInfo>('userInfo', userInfo);
      AppStorage.setOrCreate<boolean>('isLoggedIn', true);
      AppStorage.setOrCreate<string>('username', userInfo.username || '');
      if (userInfo.userId) {
        AppStorage.setOrCreate<number>('userId', userInfo.userId);
      }
    } catch (error) {
      console.error('保存认证信息失败:', error);
    }
  }
}
