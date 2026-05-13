import promptAction from '@ohos.promptAction';
import http from '@ohos.net.http';
import connection from '@ohos.net.connection';
import { router } from '@kit.ArkUI';
import { getBaseUrl } from '../constants/ApiConstants';
import { SettingsUtil } from '../../utils/SettingsUtil';
import { selectTimeout, TimeoutConfig } from '../constants/TimeoutConfig';

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
  isAdmin?: boolean;  // 标识是否为管理员请求
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
  timeout: TimeoutConfig.NORMAL,
  isAdmin: false
};

let loadingCount: number = 0;
let isHandling401: boolean = false;  // 防止重复处理401

export class HttpUtil {
  private static readonly TIMEOUT: number = TimeoutConfig.NORMAL;

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
      timeout: DEFAULT_OPTIONS.timeout,
      isAdmin: DEFAULT_OPTIONS.isAdmin
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
      if (options.isAdmin !== undefined) {
        opts.isAdmin = options.isAdmin;
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

    const timeoutValue: number = (options && options.timeout) || selectTimeout(url);
    console.log('[HttpUtil] ' + method + ' ' + fullUrl + ' (timeout: ' + timeoutValue + 'ms)', data ? JSON.stringify(data) : '');

    // 自动检测当前登录角色并选择对应的Token
    // 优先级：家属 > 护士 > 医生 > 管理员 > 普通用户
    let token: string | null = null;

    if (options && options.skipAuth) {
      // 跳过认证，不添加Token
      token = null;
      console.log('[HttpUtil] 跳过认证,不添加Token');
    } else if (options && options.isAdmin) {
      // 明确指定为管理员请求
      token = HttpUtil.getAdminToken();
      console.log('[HttpUtil] 使用管理员Token:', token ? '已获取' : '未获取');
    } else {
      // 自动检测当前登录角色
      const isFamilyLoggedIn: boolean = AppStorage.get<boolean>('isFamilyLoggedIn') || false;
      const isNurseLoggedIn: boolean = AppStorage.get<boolean>('isNurseLoggedIn') || false;
      const isDoctorLoggedIn: boolean = AppStorage.get<boolean>('isDoctorLoggedIn') || false;
      const isAdminLoggedIn: boolean = AppStorage.get<boolean>('isAdminLoggedIn') || false;
      const isLoggedIn: boolean = AppStorage.get<boolean>('isLoggedIn') || false;

      console.log('[HttpUtil] 登录状态检测: 家属=' + isFamilyLoggedIn + ', 护士=' + isNurseLoggedIn + ', 医生=' + isDoctorLoggedIn + ', 管理员=' + isAdminLoggedIn + ', 用户=' + isLoggedIn);

      if (isFamilyLoggedIn) {
        token = HttpUtil.getFamilyToken();
        console.log('[HttpUtil] 使用家属Token:', token ? (token.substring(0, 20) + '...') : '未获取');
      } else if (isNurseLoggedIn) {
        token = HttpUtil.getNurseToken();
        console.log('[HttpUtil] 使用护士Token:', token ? '已获取' : '未获取');
      } else if (isDoctorLoggedIn) {
        token = HttpUtil.getDoctorToken();
        console.log('[HttpUtil] 使用医生Token:', token ? '已获取' : '未获取');
      } else if (isAdminLoggedIn) {
        token = HttpUtil.getAdminToken();
        console.log('[HttpUtil] 使用管理员Token:', token ? '已获取' : '未获取');
      } else if (isLoggedIn) {
        token = HttpUtil.getToken();
        console.log('[HttpUtil] 使用用户Token:', token ? '已获取' : '未获取');
      } else {
        // 如果所有登录状态都为false，尝试从存储中获取各个Token
        const nurseToken = HttpUtil.getNurseToken();
        const doctorToken = HttpUtil.getDoctorToken();
        const familyToken = HttpUtil.getFamilyToken();
        const userToken = HttpUtil.getToken();
        
        if (nurseToken) {
          token = nurseToken;
          AppStorage.setOrCreate<boolean>('isNurseLoggedIn', true);
          console.log('[HttpUtil] 检测到护士Token，自动设置登录状态');
        } else if (doctorToken) {
          token = doctorToken;
          AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', true);
          console.log('[HttpUtil] 检测到医生Token，自动设置登录状态');
        } else if (familyToken) {
          token = familyToken;
          AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', true);
          console.log('[HttpUtil] 检测到家属Token，自动设置登录状态');
        } else if (userToken) {
          token = userToken;
          AppStorage.setOrCreate<boolean>('isLoggedIn', true);
          console.log('[HttpUtil] 检测到用户Token，自动设置登录状态');
        }
      }
    }
    
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };
    if (token) {
      headers['Token'] = token;
    }

    const requestOptions: HttpRequestOptions = {
      method: HttpUtil.mapMethod(method),
      headers: headers,
      body: data ? JSON.stringify(data) : undefined
    };

    const response: HttpResponse = await HttpUtil.fetch(fullUrl, requestOptions, timeoutValue);
    return HttpUtil.handleResponse<T>(response, url);
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

  private static handleResponse<T>(response: HttpResponse, url: string = ''): BaseResponse<T> {
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
      // 检查是否是需要忽略401的API（不跳转登录页）
      const isNursingRecordApi: boolean = url.includes('/api/nursing-record');
      const isMessageApi: boolean = url.includes('/message/') || url.includes('message/history') || url.includes('message/send');
      const isFamiliesApi: boolean = url.includes('/nurse/families') || url.includes('/family/nurses');
      
      if (isNursingRecordApi || isMessageApi || isFamiliesApi) {
        const apiType: string = isNursingRecordApi ? '护理记录' : (isMessageApi ? '消息' : '家属/护士');
        console.warn('[HttpUtil] ⚠️ ' + apiType + 'API返回401，不跳转登录页，仅返回错误');
        return new BaseResponse<T>(false, apiType + '操作失败（可能需要重新登录）', undefined, 401);
      }
      
      console.error('[HttpUtil] 🔒 检测到401未授权错误，准备跳转登录页 URL:', url);
      
      // 防止重复处理
      if (!isHandling401) {
        isHandling401 = true;
        
        // 检测当前登录角色（优先级：家属 > 护士 > 医生 > 管理员 > 普通用户）
        const isFamilyLoggedIn: boolean = AppStorage.get<boolean>('isFamilyLoggedIn') || false;
        const isNurseLoggedIn: boolean = AppStorage.get<boolean>('isNurseLoggedIn') || false;
        const isDoctorLoggedIn: boolean = AppStorage.get<boolean>('isDoctorLoggedIn') || false;
        const isAdminLoggedIn: boolean = AppStorage.get<boolean>('isAdminLoggedIn') || false;
        const isLoggedIn: boolean = AppStorage.get<boolean>('isLoggedIn') || false;
        
        console.log('[HttpUtil] 当前登录状态: 家属=' + isFamilyLoggedIn + ', 护士=' + isNurseLoggedIn + ', 医生=' + isDoctorLoggedIn + ', 管理员=' + isAdminLoggedIn + ', 用户=' + isLoggedIn);
        
        if (isFamilyLoggedIn) {
          // 家属Token过期，先清除状态再跳转
          HttpUtil.clearFamilyToken();
          AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
          console.warn('[HttpUtil] 清除家属Token，500ms后跳转到家属登录页');
          setTimeout(() => {
            router.replaceUrl({ url: 'pages/FamilyLogin' });
            isHandling401 = false;
          }, 500);
        } else if (isNurseLoggedIn) {
          // 护士Token过期，先清除状态再跳转
          HttpUtil.clearNurseToken();
          AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
          console.warn('[HttpUtil] 清除护士Token，500ms后跳转到护士登录页');
          setTimeout(() => {
            router.replaceUrl({ url: 'pages/NurseLogin' });
            isHandling401 = false;
          }, 500);
        } else if (isDoctorLoggedIn) {
          // 医生Token过期，先清除状态再跳转
          HttpUtil.clearDoctorToken();
          AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', false);
          setTimeout(() => {
            router.replaceUrl({ url: 'pages/DoctorLogin' });
            isHandling401 = false;
          }, 500);
        } else if (isAdminLoggedIn) {
          // 管理员Token过期，先清除状态再跳转
          HttpUtil.clearAdminToken();
          AppStorage.setOrCreate<boolean>('isAdminLoggedIn', false);
          setTimeout(() => {
            router.replaceUrl({ url: 'pages/AdminLogin' });
            isHandling401 = false;
          }, 500);
        } else if (isLoggedIn) {
          // 普通用户Token过期，先清除状态再跳转
          HttpUtil.clearToken();
          AppStorage.setOrCreate<boolean>('isLoggedIn', false);
          setTimeout(() => {
            router.replaceUrl({ url: 'pages/Login' });
            isHandling401 = false;
          }, 500);
        } else {
          // 未登录状态，不做处理
          console.warn('[HttpUtil] 未检测到任何登录状态，不执行跳转');
          isHandling401 = false;
        }
      } else {
        console.warn('[HttpUtil] 正在处理401跳转，避免重复执行');
      }
      return new BaseResponse<T>(false, '请先登录', undefined, 401);
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

  /**
   * 获取管理员Token
   * 管理员使用独立的Token存储，避免与普通用户Token混淆
   */
  static getAdminToken(): string | null {
    try {
      const tokenFromAppStorage: string | undefined = AppStorage.get<string>('adminToken');
      if (tokenFromAppStorage && tokenFromAppStorage.length > 0) {
        return tokenFromAppStorage;
      }
      return null;
    } catch (error) {
      console.error('[HttpUtil] 获取管理员Token失败:', error);
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

  /**
   * 保存管理员Token
   * 管理员Token独立存储，不与普通用户Token混淆
   */
  static async saveAdminToken(token: string): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('adminToken', token);
    } catch (error) {
      console.error('[HttpUtil] 保存管理员Token失败:', error);
    }
  }

  /**
   * 清除管理员Token
   */
  static async clearAdminToken(): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('adminToken', '');
    } catch (error) {
      console.error('[HttpUtil] 清除管理员Token失败:', error);
    }
  }

  static hasToken(): boolean {
    const token = HttpUtil.getToken();
    return !!token && token.length > 0;
  }

  // ==================== 家属相关方法 ====================

  /**
   * 获取家属Token
   */
  static getFamilyToken(): string | null {
    try {
      const tokenFromAppStorage: string | undefined = AppStorage.get<string>('familyToken');
      if (tokenFromAppStorage && tokenFromAppStorage.length > 0) {
        return tokenFromAppStorage;
      }
      const settings: SettingsUtil = SettingsUtil.getInstance();
      const tokenFromPrefs: string = settings.getFamilyTokenSync();
      if (tokenFromPrefs && tokenFromPrefs.length > 0) {
        AppStorage.setOrCreate<string>('familyToken', tokenFromPrefs);
        return tokenFromPrefs;
      }
      return null;
    } catch (error) {
      console.error('[HttpUtil] 获取家属Token失败:', error);
      return null;
    }
  }

  /**
   * 保存家属Token
   */
  static async saveFamilyToken(token: string): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('familyToken', token);
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.saveFamilyToken(token);
    } catch (error) {
      console.error('[HttpUtil] 保存家属Token失败:', error);
    }
  }

  /**
   * 清除家属Token
   */
  static async clearFamilyToken(): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('familyToken', '');
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.clearFamilyAuth();
    } catch (error) {
      console.error('[HttpUtil] 清除家属Token失败:', error);
    }
  }

  // ==================== 护士相关方法 ====================

  /**
   * 获取护士Token
   */
  static getNurseToken(): string | null {
    try {
      const tokenFromAppStorage: string | undefined = AppStorage.get<string>('nurseToken');
      if (tokenFromAppStorage && tokenFromAppStorage.length > 0) {
        return tokenFromAppStorage;
      }
      const settings: SettingsUtil = SettingsUtil.getInstance();
      const tokenFromPrefs: string = settings.getNurseTokenSync();
      if (tokenFromPrefs && tokenFromPrefs.length > 0) {
        AppStorage.setOrCreate<string>('nurseToken', tokenFromPrefs);
        return tokenFromPrefs;
      }
      return null;
    } catch (error) {
      console.error('[HttpUtil] 获取护士Token失败:', error);
      return null;
    }
  }

  /**
   * 保存护士Token
   */
  static async saveNurseToken(token: string): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('nurseToken', token);
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.saveNurseToken(token);
    } catch (error) {
      console.error('[HttpUtil] 保存护士Token失败:', error);
    }
  }

  /**
   * 清除护士Token
   */
  static async clearNurseToken(): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('nurseToken', '');
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.clearNurseAuth();
    } catch (error) {
      console.error('[HttpUtil] 清除护士Token失败:', error);
    }
  }

  // ==================== 医生相关方法 ====================

  /**
   * 获取医生Token
   */
  static getDoctorToken(): string | null {
    try {
      const tokenFromAppStorage: string | undefined = AppStorage.get<string>('doctorToken');
      if (tokenFromAppStorage && tokenFromAppStorage.length > 0) {
        return tokenFromAppStorage;
      }
      const settings: SettingsUtil = SettingsUtil.getInstance();
      const tokenFromPrefs: string = settings.getDoctorTokenSync();
      if (tokenFromPrefs && tokenFromPrefs.length > 0) {
        AppStorage.setOrCreate<string>('doctorToken', tokenFromPrefs);
        return tokenFromPrefs;
      }
      return null;
    } catch (error) {
      console.error('[HttpUtil] 获取医生Token失败:', error);
      return null;
    }
  }

  /**
   * 保存医生Token
   */
  static async saveDoctorToken(token: string): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('doctorToken', token);
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.saveDoctorToken(token);
    } catch (error) {
      console.error('[HttpUtil] 保存医生Token失败:', error);
    }
  }

  /**
   * 清除医生Token
   */
  static async clearDoctorToken(): Promise<void> {
    try {
      AppStorage.setOrCreate<string>('doctorToken', '');
      AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', false);
      const settings: SettingsUtil = SettingsUtil.getInstance();
      await settings.clearDoctorAuth();
    } catch (error) {
      console.error('[HttpUtil] 清除医生Token失败:', error);
    }
  }
}
