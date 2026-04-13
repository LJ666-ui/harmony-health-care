import promptAction from '@ohos.promptAction';
import dataStorage from '@ohos.data.storage';
import http from '@ohos.net.http';

/**
 * 基础响应接口
 */
export interface BaseResponse<T> {
  success: boolean;
  message: string;
  data?: T;
  code?: number;
}

/**
 * 登录请求数据接口
 */
export interface LoginRequest {
  username: string;
  password: string;
}

/**
 * 登录响应数据接口
 */
export interface LoginResponse {
  token: string;
  message: string;
}

/**
 * HTTP请求工具类
 */
export class HttpUtil {
  private static readonly BASE_URL: string = 'http://localhost:8080';
  private static readonly TIMEOUT: number = 10000;

  /**
   * GET请求
   */
  static async get<T>(url: string, params?: Record<string, any>): Promise<BaseResponse<T>> {
    try {
      // 构建完整URL
      let fullUrl = this.BASE_URL + url;
      if (params) {
        const queryParams = this.buildQueryParams(params);
        fullUrl += '?' + queryParams;
      }

      // 获取Token
      const token = this.getToken();

      // 显示加载状态
      promptAction.showToast({
        message: '加载中...',
        duration: 2000
      });

      // 发送请求
      const response = await this.fetch(fullUrl, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : ''
        }
      });

      // 处理响应
      return await this.handleResponse<T>(response);
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * POST请求
   */
  static async post<T>(url: string, data?: any): Promise<BaseResponse<T>> {
    try {
      // 构建完整URL
      const fullUrl = this.BASE_URL + url;

      // 获取Token
      const token = this.getToken();

      // 显示加载状态
      promptAction.showToast({
        message: '加载中...',
        duration: 2000
      });

      // 发送请求
      const response = await this.fetch(fullUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : ''
        },
        body: JSON.stringify(data)
      });

      // 处理响应
      return await this.handleResponse<T>(response);
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * 构建查询参数
   */
  private static buildQueryParams(params: Record<string, any>): string {
    const parts: string[] = [];
    Object.entries(params).forEach(([key, value]) => {
      parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
    });
    return parts.join('&');
  }

  /**
   * 发送网络请求
   */
  private static async fetch(url: string, options: any): Promise<any> {
    return new Promise((resolve, reject) => {
      const request = http.createHttp();
      const timeoutId = setTimeout(() => {
        reject(new Error('请求超时'));
        request.destroy();
      }, this.TIMEOUT);

      request.request(url, {
        method: options.method,
        header: options.headers,
        extraData: options.body,
        connectTimeout: this.TIMEOUT,
        readTimeout: this.TIMEOUT
      }, (err, data) => {
        clearTimeout(timeoutId);
        request.destroy();
        if (err) {
          reject(err);
        } else {
          resolve(data);
        }
      });
    });
  }

  /**
   * 处理响应
   */
  private static async handleResponse<T>(response: any): Promise<BaseResponse<T>> {
    const data = response.result;

    if (response.responseCode !== 200) {
      if (response.responseCode === 401) {
        // Token过期，清除Token并跳转到登录页
        this.clearToken();
        // 这里需要跳转到登录页，暂时用提示代替
        promptAction.showToast({
          message: '登录已过期，请重新登录',
          duration: 2000
        });
        // 实际项目中应该使用router.push跳转到登录页
        return {
          success: false,
          message: '登录已过期，请重新登录',
          code: 401
        };
      }

      return {
        success: false,
        message: data?.message || '请求失败',
        code: response.responseCode
      };
    }

    return {
      success: true,
      message: data?.message || '请求成功',
      data: data?.data as T,
      code: response.responseCode
    };
  }

  /**
   * 处理错误
   */
  private static handleError(error: any): BaseResponse<any> {
    let message = '网络请求失败';
    if (error && error.message) {
      message = error.message;
    }

    promptAction.showToast({
      message: message,
      duration: 2000
    });

    return {
      success: false,
      message: message
    };
  }

  /**
   * 获取Token
   */
  private static getToken(): string | null {
    try {
      const storage = dataStorage.getStorageSync(globalThis.abilityContext);
      const token = storage.getSync('token', '');
      return token as string;
    } catch (error) {
      console.error('获取Token失败:', error);
      return null;
    }
  }

  /**
   * 保存Token
   */
  static saveToken(token: string): void {
    try {
      const storage = dataStorage.getStorageSync(globalThis.abilityContext);
      storage.putSync('token', token);
      storage.flushSync();
    } catch (error) {
      console.error('保存Token失败:', error);
    }
  }

  /**
   * 清除Token
   */
  static clearToken(): void {
    try {
      const storage = dataStorage.getStorageSync(globalThis.abilityContext);
      storage.deleteSync('token');
      storage.flushSync();
    } catch (error) {
      console.error('清除Token失败:', error);
    }
  }
}

