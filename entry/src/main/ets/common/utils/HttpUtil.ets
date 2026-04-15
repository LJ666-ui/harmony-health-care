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
 * HTTP请求选项接口
 */
export interface HttpRequestOptions {
  method: http.RequestMethod;
  headers: Record<string, string>;
  body?: string;
}
/**
 * API响应数据接口
 */
export interface ApiResponseData {
  message?: string;
  data?: object;
}

/**
 * HTTP响应接口
 */
export interface HttpResponse {
  responseCode: number;
  result: ApiResponseData;
  header?: Record<string, string>;
}
/**
 * HTTP请求配置接口
 */
export interface HttpRequestConfig {
  method: string;
  header: Record<string, string>;
  extraData?: string;
  connectTimeout: number;
  readTimeout: number;
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
  static async get<T>(url: string, params?: Record<string, string | number | boolean>): Promise<BaseResponse<T>> {
    try {
      // 构建完整URL
      let fullUrl = HttpUtil.BASE_URL + url;
      if (params) {
        const queryParams = HttpUtil.buildQueryParams(params);
        fullUrl += '?' + queryParams;
      }

      // 获取Token
      const token = HttpUtil.getToken();

      // 显示加载状态
      try {
        promptAction.showToast({
          message: '加载中...',
          duration: 2000
        });
      } catch (error) {
        console.error('显示提示失败:', error);
      }

      // 发送请求
      const options: HttpRequestOptions = {
        method: http.RequestMethod.GET,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : ''
        }
      };
      const response = await HttpUtil.fetch(fullUrl, options);

      // 处理响应
      return await HttpUtil.handleResponse<T>(response);
    } catch (error) {
      return HttpUtil.handleError<T>(error as Error);
    }
  }
  /**
   * POST请求
   */
  static async post<T>(url: string, data?: object): Promise<BaseResponse<T>> {
    try {
      // 构建完整URL
      const fullUrl = HttpUtil.BASE_URL + url;

      // 获取Token
      const token = HttpUtil.getToken();

      // 显示加载状态
      try {
        promptAction.showToast({
          message: '加载中...',
          duration: 2000
        });
      } catch (error) {
        console.error('显示提示失败:', error);
      }

      // 发送请求
      const options: HttpRequestOptions = {
        method: http.RequestMethod.POST,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ? `Bearer ${token}` : ''
        },
        body: JSON.stringify(data)
      };
      const response = await HttpUtil.fetch(fullUrl, options);

      // 处理响应
      return await HttpUtil.handleResponse<T>(response);
    } catch (error) {
      return HttpUtil.handleError<T>(error as Error);
    }
  }

  /**
   * 构建查询参数
   */
  private static buildQueryParams(params: Record<string, string | number | boolean>): string {
    const parts: string[] = [];
    Object.entries(params).forEach((entry) => {
      const key = entry[0];
      const value = entry[1];
      parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
    });
    return parts.join('&');
  }
  /**
   * 发送网络请求
   */
  private static async fetch(url: string, options: HttpRequestOptions): Promise<HttpResponse> {
    return new Promise((resolve, reject) => {
      const request = http.createHttp();
      const timeoutId = setTimeout(() => {
        reject(new Error('请求超时'));
        request.destroy();
      }, HttpUtil.TIMEOUT);
      request.request(url, {
        method: options.method as http.RequestMethod,
        header: options.headers,
        extraData: options.body,
        connectTimeout: HttpUtil.TIMEOUT,
        readTimeout: HttpUtil.TIMEOUT
      }, (err, data) => {
        clearTimeout(timeoutId);
        request.destroy();
        if (err) {
          reject(err);
        } else {
          // 手动构建响应对象，避免类型转换错误
          const response: HttpResponse = {
            responseCode: data.responseCode,
            result: data.result as ApiResponseData,
            header: data.header as Record<string, string>
          };
          resolve(response);
        }
      });
    });
  }
  /**
   * 处理响应
   */
  private static async handleResponse<T>(response: HttpResponse): Promise<BaseResponse<T>> {
    const data = response.result;

    if (response.responseCode !== 200) {
      if (response.responseCode === 401) {
        // Token过期，清除Token并跳转到登录页
        HttpUtil.clearToken();
        // 这里需要跳转到登录页，暂时用提示代替
        try {
          promptAction.showToast({
            message: '登录已过期，请重新登录',
            duration: 2000
          });
        } catch (error) {
          console.error('显示提示失败:', error);
        }
        // 实际项目中应该使用router.push跳转到登录页
        return {
          success: false,
          message: '登录已过期，请重新登录',
          code: 401
        };
      }

      return {
        success: false,
        message: data?.message as string || '请求失败',
        code: response.responseCode as number
      };
    }

    return {
      success: true,
      message: data?.message as string || '请求成功',
      data: data?.data as T,
      code: response.responseCode as number
    };
  }

  /**
   * 处理错误
   */
  private static handleError<T>(error: Error): BaseResponse<T> {
    let message = '网络请求失败';
    if (error && error.message) {
      message = error.message;
    }

    try {
      promptAction.showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      console.error('显示提示失败:', error);
    }

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
      const storage = dataStorage.getStorageSync('token_storage');
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
      const storage = dataStorage.getStorageSync('token_storage');
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
      const storage = dataStorage.getStorageSync('token_storage');
      storage.deleteSync('token');
      storage.flushSync();
    } catch (error) {
      console.error('清除Token失败:', error);
    }
  }
}

