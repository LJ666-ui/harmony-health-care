import promptAction from '@ohos.promptAction';
import http from '@ohos.net.http';
import connection from '@ohos.net.connection';
import { getBaseUrl } from '../constants/ApiConstants';
import { SettingsUtil } from '../../utils/SettingsUtil';

export class BaseResponse<T> {
  success: boolean = false;
  message: string = '';
  data?: T = undefined;
  code?: number = undefined;

  constructor(success?: boolean, message?: string, data?: T, code?: number) {
    if (success !== undefined) this.success = success;
    if (message !== undefined) this.message = message;
    if (data !== undefined) this.data = data;
    if (code !== undefined) this.code = code;
  }
}

interface BackendResult {
  code: number;
  msg: string;
  data?: Object;
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

export enum HttpMethod {
  GET = 'GET',
  POST = 'POST',
  PUT = 'PUT',
  DELETE = 'DELETE'
}

export interface RequestOptions {
  showLoading?: boolean;
  loadingText?: string;
  retryCount?: number;
  skipAuth?: boolean;
  timeout?: number;
}

interface FormDataItem {
  name: string;
  value: string | number;
  contentType: string;
}

const DEFAULT_OPTIONS: RequestOptions = {
  showLoading: false,
  loadingText: '加载中...',
  retryCount: 1,
  skipAuth: false,
  timeout: 15000
};

let loadingCount: number = 0;

export class HttpUtil {
  private static readonly TIMEOUT: number = 15000;

  static async request<T>(
    method: HttpMethod,
    url: string,
    data?: object,
    params?: Object,
    options?: RequestOptions
  ): Promise<BaseResponse<T>> {
    const opts: RequestOptions = {
      showLoading: DEFAULT_OPTIONS.showLoading,
      loadingText: DEFAULT_OPTIONS.loadingText,
      retryCount: DEFAULT_OPTIONS.retryCount,
      skipAuth: DEFAULT_OPTIONS.skipAuth,
      timeout: DEFAULT_OPTIONS.timeout
    };
    if (options) {
      if (options.showLoading !== undefined) {
        opts.showLoading = options.showLoading;
      }
      if (options.loadingText !== undefined) {
        opts.loadingText = options.loadingText;
      }
      if (options.retryCount !== undefined) {
        opts.retryCount = options.retryCount;
      }
      if (options.skipAuth !== undefined) {
        opts.skipAuth = options.skipAuth;
      }
      if (options.timeout !== undefined) {
        opts.timeout = options.timeout;
      }
    }

    if (opts.showLoading) {
      HttpUtil.showLoading(opts.loadingText);
    }

    const isOnline: boolean = await HttpUtil.checkNetwork();
    if (!isOnline) {
      HttpUtil.hideLoading();
      return new BaseResponse<T>(false, '网络不可用，请检查网络连接', undefined, -1);
    }

    const retryMax: number = opts.retryCount || 1;
    for (let attempt: number = 0; attempt <= retryMax; attempt++) {
      try {
        const result: BaseResponse<T> = await HttpUtil.executeRequest<T>(method, url, data, params, opts);
        HttpUtil.hideLoading();
        return result;
      } catch (error) {
        console.error('[HttpUtil] 请求失败(第' + (attempt + 1) + '次):', error);
        if (attempt >= retryMax) {
          HttpUtil.hideLoading();
          return HttpUtil.handleError<T>(error);
        }
      }
    }

    HttpUtil.hideLoading();
    return new BaseResponse<T>(false, '请求失败');
  }

  private static async executeRequest<T>(
    method: HttpMethod,
    url: string,
    data?: object,
    params?: Object,
    options?: RequestOptions
  ): Promise<BaseResponse<T>> {
    let fullUrl: string = getBaseUrl() + url;
    if (params) {
      const qs: string = HttpUtil.buildQueryParams(params);
      if (qs.length > 0) {
        fullUrl = fullUrl + '?' + qs;
      }
    }

    console.log('[HttpUtil] ' + method + ' ' + fullUrl, data ? JSON.stringify(data) : '');

    const token: string | null = HttpUtil.getToken();
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (token && !(options && options.skipAuth)) {
      headers['Token'] = token;
    }

    const requestOptions: HttpRequestOptions = {
      method: HttpUtil.mapMethod(method),
      headers: headers,
      body: data ? JSON.stringify(data) : undefined
    };

    const response: HttpResponse = await HttpUtil.fetch(fullUrl, requestOptions, (options && options.timeout) || HttpUtil.TIMEOUT);
    return HttpUtil.handleResponse<T>(response);
  }

  static async get<T>(
    url: string,
    params?: Object,
    options?: RequestOptions
  ): Promise<BaseResponse<T>> {
    return HttpUtil.request<T>(HttpMethod.GET, url, undefined, params, options);
  }

  static async post<T>(
    url: string,
    data?: object,
    options?: RequestOptions
  ): Promise<BaseResponse<T>> {
    return HttpUtil.request<T>(HttpMethod.POST, url, data, undefined, options);
  }

  static async put<T>(
    url: string,
    data?: object,
    options?: RequestOptions
  ): Promise<BaseResponse<T>> {
    return HttpUtil.request<T>(HttpMethod.PUT, url, data, undefined, options);
  }

  static async delete<T>(
    url: string,
    data?: object,
    options?: RequestOptions
  ): Promise<BaseResponse<T>> {
    return HttpUtil.request<T>(HttpMethod.DELETE, url, data, undefined, options);
  }

  static async upload<T>(
    url: string,
    formData: FormDataItem[],
    options?: RequestOptions
  ): Promise<BaseResponse<T>> {
    if (options && options.showLoading) {
      HttpUtil.showLoading(options.loadingText || '上传中...');
    }

    const fullUrl: string = getBaseUrl() + url;
    const token: string | null = HttpUtil.getToken();

    try {
      const httpRequest = http.createHttp();
      const response: http.HttpResponse = await new Promise((resolve, reject) => {
        const reqHeaders: Record<string, string> = {
          'Content-Type': 'multipart/form-data'
        };
        if (token) {
          reqHeaders['Token'] = token;
        }
        httpRequest.request(fullUrl, {
          method: http.RequestMethod.POST,
          header: reqHeaders,
          multiFormDataList: formData,
          connectTimeout: HttpUtil.TIMEOUT * 2,
          readTimeout: HttpUtil.TIMEOUT * 2
        }, (err, data) => {
          httpRequest.destroy();
          if (err) {
            reject(err);
          } else {
            resolve(data);
          }
        });
      });

      const result: HttpResponse = {
        responseCode: response.responseCode,
        result: response.result as ApiResponseData,
        header: response.header as Record<string, string>
      };

      HttpUtil.hideLoading();
      return HttpUtil.handleResponse<T>(result);
    } catch (error) {
      HttpUtil.hideLoading();
      return HttpUtil.handleError<T>(error);
    }
  }

  private static mapMethod(method: HttpMethod): http.RequestMethod {
    switch (method) {
      case HttpMethod.POST:
        return http.RequestMethod.POST;
      case HttpMethod.PUT:
        return http.RequestMethod.PUT;
      case HttpMethod.DELETE:
        return http.RequestMethod.DELETE;
      default:
        return http.RequestMethod.GET;
    }
  }

  private static buildQueryParams(params: Object): string {
    const parts: string[] = [];
    const keys: string[] = Object.keys(params);
    for (let i: number = 0; i < keys.length; i++) {
      const key: string = keys[i];
      const value = (params as Record<string, Object>)[key];
      parts.push(encodeURIComponent(key) + '=' + encodeURIComponent(String(value)));
    }
    return parts.join('&');
  }

  private static async fetch(
    url: string,
    options: HttpRequestOptions,
    timeout?: number
  ): Promise<HttpResponse> {
    return new Promise((resolve, reject) => {
      const request = http.createHttp();
      const actualTimeout: number = timeout || HttpUtil.TIMEOUT;
      const timeoutId = setTimeout(() => {
        reject(new Error('请求超时，请稍后重试'));
        request.destroy();
      }, actualTimeout);

      request.request(url, {
        method: options.method,
        header: options.headers,
        extraData: options.body,
        connectTimeout: actualTimeout,
        readTimeout: actualTimeout
      }, (err, data) => {
        clearTimeout(timeoutId);
        request.destroy();
        if (err) {
          reject(err);
        } else {
          resolve({
            responseCode: data.responseCode,
            result: data.result as ApiResponseData,
            header: data.header as Record<string, string>
          });
        }
      });
    });
  }

  private static handleResponse<T>(response: HttpResponse): BaseResponse<T> {
    let raw: Object = response.result;

    if (typeof raw === 'string') {
      try {
        raw = JSON.parse(raw as string);
      } catch (error) {
        console.error('[HttpUtil] 解析响应JSON失败:', error);
        return new BaseResponse<T>(false, '服务器响应格式错误', undefined, response.responseCode);
      }
    }

    if (response.responseCode === 401) {
      HttpUtil.clearToken();
      HttpUtil.showToast('登录已过期，请重新登录');
      return new BaseResponse<T>(false, '登录已过期，请重新登录', undefined, 401);
    }

    if (response.responseCode >= 500) {
      HttpUtil.showToast('服务器繁忙，请稍后重试');
      return new BaseResponse<T>(false, '服务器错误(' + response.responseCode + ')', undefined, response.responseCode);
    }

    if (response.responseCode !== 200 && response.responseCode !== 201 && response.responseCode !== 204) {
      const br = raw as BackendResult;
      return new BaseResponse<T>(false, (br && br.msg) ? br.msg : '请求失败', undefined, response.responseCode);
    }

    const backendResult = raw as BackendResult;
    const isSuccess = backendResult && backendResult.code === 200;

    let msg: string = '请求失败';
    if (backendResult && backendResult.msg) {
      msg = backendResult.msg;
    } else if (isSuccess) {
      msg = '请求成功';
    }

    return new BaseResponse<T>(isSuccess, msg, backendResult ? backendResult.data as T : undefined,
      (backendResult && backendResult.code) ? backendResult.code : response.responseCode);
  }

  private static handleError<T>(error: Object): BaseResponse<T> {
    let message: string = '网络请求失败';
    const err = error as Error;
    if (err && err.message) {
      message = err.message;
    }

    HttpUtil.showToast(message);

    return new BaseResponse<T>(false, message);
  }

  private static showToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  static showLoading(message: string = '加载中...'): void {
    loadingCount++;
    if (loadingCount === 1) {
      promptAction.showToast({
        message: message,
        duration: 10000
      });
    }
  }

  static hideLoading(): void {
    if (loadingCount > 0) {
      loadingCount--;
    }
  }

  static isLoading(): boolean {
    return loadingCount > 0;
  }

  private static checkNetwork(): Promise<boolean> {
    return new Promise((resolve) => {
      resolve(true);
    });
  }

  static getToken(): string | null {
    try {
      const tokenFromAppStorage: string | undefined = AppStorage.get<string>('token');
      if (tokenFromAppStorage && tokenFromAppStorage.length > 0) {
        return tokenFromAppStorage;
      }
      const settings: SettingsUtil = SettingsUtil.getInstance();
      const tokenFromPrefs: string = settings.getTokenSync();
      if (tokenFromPrefs && tokenFromPrefs.length > 0) {
        AppStorage.setOrCreate<string>('token', tokenFromPrefs);
        return tokenFromPrefs;
      }
      return null;
    } catch (error) {
      console.error('[HttpUtil] 获取Token失败:', error);
      return null;
    }
  }

  static async saveToken(token: string): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('token', token);
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.saveToken(token);
    } catch (error) {
      console.error('[HttpUtil] 保存Token失败:', error);
    }
  }

  static async clearToken(): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('token', '');
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.clearToken();
    } catch (error) {
      console.error('[HttpUtil] 清除Token失败:', error);
    }
  }

  static hasToken(): boolean {
    const token = HttpUtil.getToken();
    return !!token && token.length > 0;
  }
}
