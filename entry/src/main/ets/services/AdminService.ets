import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { AdminInfo, AdminInfoHelper, AdminLoginRequest, AdminLoginResponse, CreateAdminRequest, UpdateAdminRequest, QueryAdminParams } from '../models/AdminInfo';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';
import { SessionManager } from '../utils/SessionManager';

const BASE_URL: string = '/admin';

export class AdminService {
  static async login(request: AdminLoginRequest): Promise<BaseResponse<AdminLoginResponse>> {
    const response: BaseResponse<Object> = await HttpUtil.post<Object>(`${BASE_URL}/login`, request as Object);
    
    if (response.success && response.data) {
      const data: Record<string, Object> = response.data as Record<string, Object>;
      const loginResponse: AdminLoginResponse = {
        success: data['success'] as boolean,
        message: data['message'] as string,
        admin: data['admin'] ? AdminInfoHelper.fromJson(data['admin'] as Record<string, Object>) : undefined,
        token: data['token'] as string
      };
      
      const result: BaseResponse<AdminLoginResponse> = new BaseResponse<AdminLoginResponse>();
      result.success = true;
      result.message = response.message;
      result.data = loginResponse;
      return result;
    }
    
    const result: BaseResponse<AdminLoginResponse> = new BaseResponse<AdminLoginResponse>();
    result.success = false;
    result.message = response.message;
    const loginResponse: AdminLoginResponse = {
      success: false,
      message: response.message
    };
    result.data = loginResponse;
    return result;
  }

  static async getAllUsers(params?: Record<string, Object>): Promise<BaseResponse<PersistedUserInfo[]>> {
    let url: string = `${BASE_URL}/users`;
    if (params) {
      const queryParts: string[] = [];
      if (params['page']) queryParts.push(`page=${params['page']}`);
      if (params['pageSize']) queryParts.push(`pageSize=${params['pageSize']}`);
      if (params['keyword']) queryParts.push(`keyword=${encodeURIComponent(params['keyword'] as string)}`);
      if (queryParts.length > 0) {
        url += '?' + queryParts.join('&');
      }
    }
    
    const response: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(url);
    if (response.success && response.data) {
      const users: PersistedUserInfo[] = response.data.map((item: Object) => 
        item as PersistedUserInfo
      );
      const result: BaseResponse<PersistedUserInfo[]> = new BaseResponse<PersistedUserInfo[]>();
      result.success = true;
      result.message = response.message;
      result.data = users;
      return result;
    }
    const result: BaseResponse<PersistedUserInfo[]> = new BaseResponse<PersistedUserInfo[]>();
    result.success = false;
    result.message = response.message;
    result.data = [];
    return result;
  }

  static async getUserById(userId: number): Promise<BaseResponse<PersistedUserInfo>> {
    const response: BaseResponse<Object> = await HttpUtil.get<Object>(`${BASE_URL}/user/${userId}`);
    if (response.success && response.data) {
      const result: BaseResponse<PersistedUserInfo> = new BaseResponse<PersistedUserInfo>();
      result.success = true;
      result.message = response.message;
      result.data = response.data as PersistedUserInfo;
      return result;
    }
    const result: BaseResponse<PersistedUserInfo> = new BaseResponse<PersistedUserInfo>();
    result.success = false;
    result.message = response.message;
    return result;
  }

  static async deleteUser(userId: number): Promise<BaseResponse<void>> {
    return await HttpUtil.delete<void>(`${BASE_URL}/user/${userId}`);
  }

  static async getAllAdmins(params?: QueryAdminParams): Promise<BaseResponse<AdminInfo[]>> {
    let url: string = `${BASE_URL}/all`;
    if (params) {
      const queryParts: string[] = [];
      if (params.page) queryParts.push(`page=${params.page}`);
      if (params.pageSize) queryParts.push(`pageSize=${params.pageSize}`);
      if (params.keyword) queryParts.push(`keyword=${encodeURIComponent(params.keyword)}`);
      if (queryParts.length > 0) {
        url += '?' + queryParts.join('&');
      }
    }
    
    const response: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(url);
    if (response.success && response.data) {
      const admins: AdminInfo[] = response.data.map((item: Object) => 
        AdminInfoHelper.fromJson(item as Record<string, Object>)
      );
      const result: BaseResponse<AdminInfo[]> = new BaseResponse<AdminInfo[]>();
      result.success = true;
      result.message = response.message;
      result.data = admins;
      return result;
    }
    const result: BaseResponse<AdminInfo[]> = new BaseResponse<AdminInfo[]>();
    result.success = false;
    result.message = response.message;
    result.data = [];
    return result;
  }

  static async addAdmin(request: CreateAdminRequest): Promise<BaseResponse<AdminInfo>> {
    const response: BaseResponse<Object> = await HttpUtil.post<Object>(`${BASE_URL}/add`, request as Object);
    if (response.success && response.data) {
      const result: BaseResponse<AdminInfo> = new BaseResponse<AdminInfo>();
      result.success = true;
      result.message = response.message;
      result.data = AdminInfoHelper.fromJson(response.data as Record<string, Object>);
      return result;
    }
    const result: BaseResponse<AdminInfo> = new BaseResponse<AdminInfo>();
    result.success = false;
    result.message = response.message;
    return result;
  }

  static async updateAdmin(request: UpdateAdminRequest): Promise<BaseResponse<AdminInfo>> {
    const response: BaseResponse<Object> = await HttpUtil.put<Object>(`${BASE_URL}/update`, request as Object);
    if (response.success && response.data) {
      const result: BaseResponse<AdminInfo> = new BaseResponse<AdminInfo>();
      result.success = true;
      result.message = response.message;
      result.data = AdminInfoHelper.fromJson(response.data as Record<string, Object>);
      return result;
    }
    const result: BaseResponse<AdminInfo> = new BaseResponse<AdminInfo>();
    result.success = false;
    result.message = response.message;
    return result;
  }

  static async deleteAdmin(id: number): Promise<BaseResponse<void>> {
    return await HttpUtil.delete<void>(`${BASE_URL}/delete/${id}`);
  }

  static async getDashboardStats(): Promise<BaseResponse<Record<string, number>> {
    const response: BaseResponse<Object> = await HttpUtil.get<Object>(`${BASE_URL}/dashboard/stats`);
    if (response.success && response.data) {
      const result: BaseResponse<Record<string, number>> = new BaseResponse<Record<string, number>>();
      result.success = true;
      result.message = response.message;
      result.data = response.data as Record<string, number>;
      return result;
    }
    const result: BaseResponse<Record<string, number>> = new BaseResponse<Record<string, number>>();
    result.success = false;
    result.message = response.message;
    result.data = {};
    return result;
  }
}
