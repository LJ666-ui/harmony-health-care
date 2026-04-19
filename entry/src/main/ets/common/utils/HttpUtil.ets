import promptAction from '@ohos.promptAction';
import dataStorage from '@ohos.data.storage';
import http from '@ohos.net.http';

export interface BaseResponse<T> {
  success: boolean;
  message: string;
  data?: T;
  code?: number;
}

interface BackendResult {
  code: number;
  msg: string;
  data?: object;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  message: string;
}

export interface HttpRequestOptions {
  method: http.RequestMethod;
  headers: Record<string, string>;
  body?: string;
}

export interface ApiResponseData {
  message?: string;
  data?: object;
}

export interface HttpResponse {
  responseCode: number;
  result: ApiResponseData;
  header?: Record<string, string>;
}

export interface HttpRequestConfig {
  method: string;
  header: Record<string, string>;
  extraData?: string;
  connectTimeout: number;
  readTimeout: number;
}

export class HttpUtil {
  private static readonly BASE_URL: string = 'http://10.0.2.2:8080';
  private static readonly TIMEOUT: number = 10000;

  static async get<T>(url: string, params?: Record<string, string | number | boolean>): Promise<BaseResponse<T>> {
    try {
      let fullUrl = HttpUtil.BASE_URL + url;
      if (params) {
        const queryParams = HttpUtil.buildQueryParams(params);
        fullUrl += '?' + queryParams;
      }

      const token = HttpUtil.getToken();

      const options: HttpRequestOptions = {
        method: http.RequestMethod.GET,
        headers: {
          'Content-Type': 'application/json',
          'Token': token ? token : ''
        }
      };
      const response = await HttpUtil.fetch(fullUrl, options);

      return await HttpUtil.handleResponse<T>(response);
    } catch (error) {
      return HttpUtil.handleError<T>(error);
    }
  }

  static async post<T>(url: string, data?: object): Promise<BaseResponse<T>> {
    try {
      const fullUrl = HttpUtil.BASE_URL + url;

      const token = HttpUtil.getToken();

      const options: HttpRequestOptions = {
        method: http.RequestMethod.POST,
        headers: {
          'Content-Type': 'application/json',
          'Token': token ? token : ''
        },
        body: JSON.stringify(data)
      };
      const response = await HttpUtil.fetch(fullUrl, options);

      return await HttpUtil.handleResponse<T>(response);
    } catch (error) {
      return HttpUtil.handleError<T>(error);
    }
  }

  static async delete<T>(url: string): Promise<BaseResponse<T>> {
    try {
      const fullUrl = HttpUtil.BASE_URL + url;

      const token = HttpUtil.getToken();

      const options: HttpRequestOptions = {
        method: http.RequestMethod.DELETE,
        headers: {
          'Content-Type': 'application/json',
          'Token': token ? token : ''
        }
      };
      const response = await HttpUtil.fetch(fullUrl, options);

      return await HttpUtil.handleResponse<T>(response);
    } catch (error) {
      return HttpUtil.handleError<T>(error);
    }
  }

  private static buildQueryParams(params: Record<string, string | number | boolean>): string {
    const parts: string[] = [];
    Object.entries(params).forEach((entry) => {
      const key = entry[0];
      const value = entry[1];
      parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`);
    });
    return parts.join('&');
  }

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

  private static async handleResponse<T>(response: HttpResponse): Promise<BaseResponse<T>> {
    let raw: Object = response.result;

    if (typeof raw === 'string') {
      try {
        raw = JSON.parse(raw as string);
      } catch (error) {
        console.error('解析响应JSON失败:', error);
        return {
          success: false,
          message: '服务器响应格式错误',
          code: response.responseCode as number
        };
      }
    }

    if (response.responseCode !== 200) {
      if (response.responseCode === 401) {
        HttpUtil.clearToken();
        try {
          promptAction.showToast({
            message: '登录已过期，请重新登录',
            duration: 2000
          });
        } catch (error) {
          console.error('显示提示失败:', error);
        }
        return {
          success: false,
          message: '登录已过期，请重新登录',
          code: 401
        };
      }

      return {
        success: false,
        message: (raw as BackendResult)?.msg || '请求失败',
        code: response.responseCode as number
      };
    }

    const backendResult = raw as BackendResult;
    const isSuccess = backendResult && backendResult.code === 200;

    return {
      success: isSuccess,
      message: backendResult?.msg || (isSuccess ? '请求成功' : '请求失败'),
      data: backendResult?.data as T,
      code: backendResult?.code || (response.responseCode as number)
    };
  }

  private static handleError<T>(error: Object): BaseResponse<T> {
    let message = '网络请求失败';
    const err = error as Error;
    if (err && err.message) {
      message = err.message;
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

  static saveToken(token: string): void {
    try {
      const storage = dataStorage.getStorageSync('token_storage');
      storage.putSync('token', token);
      storage.flushSync();
    } catch (error) {
      console.error('保存Token失败:', error);
    }
  }

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
