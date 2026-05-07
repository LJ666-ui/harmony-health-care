import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { FamilyMember, FamilyMemberHelper, CreateFamilyRequest, UpdateFamilyRequest, QueryFamilyParams } from '../models/FamilyMember';

const BASE_URL: string = '/family';

export class FamilyService {
  static async getMyFamily(): Promise<BaseResponse<FamilyMember[]>> {
    const response: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(`${BASE_URL}/my`);
    if (response.success && response.data) {
      const familyMembers: FamilyMember[] = response.data.map((item: Object) => 
        FamilyMemberHelper.fromJson(item as Record<string, Object>)
      );
      const result: BaseResponse<FamilyMember[]> = new BaseResponse<FamilyMember[]>();
      result.success = true;
      result.message = response.message;
      result.data = familyMembers;
      return result;
    }
    const result: BaseResponse<FamilyMember[]> = new BaseResponse<FamilyMember[]>();
    result.success = false;
    result.message = response.message;
    result.data = [];
    return result;
  }

  static async getAllFamily(params?: QueryFamilyParams): Promise<BaseResponse<FamilyMember[]>> {
    let url: string = `${BASE_URL}/all`;
    if (params) {
      const queryParts: string[] = [];
      if (params.userId) queryParts.push(`userId=${params.userId}`);
      if (params.page) queryParts.push(`page=${params.page}`);
      if (params.pageSize) queryParts.push(`pageSize=${params.pageSize}`);
      if (params.keyword) queryParts.push(`keyword=${encodeURIComponent(params.keyword)}`);
      if (queryParts.length > 0) {
        url += '?' + queryParts.join('&');
      }
    }
    
    const response: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(url);
    if (response.success && response.data) {
      const familyMembers: FamilyMember[] = response.data.map((item: Object) => 
        FamilyMemberHelper.fromJson(item as Record<string, Object>)
      );
      const result: BaseResponse<FamilyMember[]> = new BaseResponse<FamilyMember[]>();
      result.success = true;
      result.message = response.message;
      result.data = familyMembers;
      return result;
    }
    const result: BaseResponse<FamilyMember[]> = new BaseResponse<FamilyMember[]>();
    result.success = false;
    result.message = response.message;
    result.data = [];
    return result;
  }

  static async addFamily(request: CreateFamilyRequest): Promise<BaseResponse<FamilyMember>> {
    const response: BaseResponse<Object> = await HttpUtil.post<Object>(`${BASE_URL}/add`, request as Object);
    if (response.success && response.data) {
      const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
      result.success = true;
      result.message = response.message;
      result.data = FamilyMemberHelper.fromJson(response.data as Record<string, Object>);
      return result;
    }
    const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
    result.success = false;
    result.message = response.message;
    return result;
  }

  static async updateFamily(request: UpdateFamilyRequest): Promise<BaseResponse<FamilyMember>> {
    const response: BaseResponse<Object> = await HttpUtil.put<Object>(`${BASE_URL}/update`, request as Object);
    if (response.success && response.data) {
      const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
      result.success = true;
      result.message = response.message;
      result.data = FamilyMemberHelper.fromJson(response.data as Record<string, Object>);
      return result;
    }
    const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
    result.success = false;
    result.message = response.message;
    return result;
  }

  static async deleteFamily(id: number): Promise<BaseResponse<void>> {
    return await HttpUtil.delete<void>(`${BASE_URL}/delete/${id}`);
  }

  static async setEmergencyContact(id: number, isEmergency: boolean): Promise<BaseResponse<FamilyMember>> {
    const requestBody: Record<string, Object> = {
      'isEmergencyContact': isEmergency
    };
    const response: BaseResponse<Object> = await HttpUtil.put<Object>(
      `${BASE_URL}/emergency/${id}`,
      requestBody
    );
    if (response.success && response.data) {
      const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
      result.success = true;
      result.message = response.message;
      result.data = FamilyMemberHelper.fromJson(response.data as Record<string, Object>);
      return result;
    }
    const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
    result.success = false;
    result.message = response.message;
    return result;
  }

  static async getFamilyById(id: number): Promise<BaseResponse<FamilyMember>> {
    const response: BaseResponse<Object> = await HttpUtil.get<Object>(`${BASE_URL}/${id}`);
    if (response.success && response.data) {
      const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
      result.success = true;
      result.message = response.message;
      result.data = FamilyMemberHelper.fromJson(response.data as Record<string, Object>);
      return result;
    }
    const result: BaseResponse<FamilyMember> = new BaseResponse<FamilyMember>();
    result.success = false;
    result.message = response.message;
    return result;
  }

  static async deleteUserWithFamily(userId: number): Promise<BaseResponse<void>> {
    return await HttpUtil.delete<void>(`${BASE_URL}/user/${userId}`);
  }
}
