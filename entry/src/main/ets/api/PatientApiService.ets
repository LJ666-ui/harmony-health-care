import { http } from '@kit.NetworkKit';
import { 
  PatientInfo, 
  PatientDetail, 
  PatientListRequest,
  PatientDetailRequest,
  PatientListResponse,
  PatientDetailResponse,
  PatientGender,
  PagedResponse
} from '../model/PatientModel';
import { SettingsUtil } from '../utils/SettingsUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

const TIMEOUT = 10000;

interface BackendUser {
  id: number;
  username?: string;
  password?: string;
  phone?: string;
  age?: number;
  id_card?: string;
  user_type?: number;
  real_name?: string;
  hospital?: string;
  department?: string;
  license_number?: string;
  avatar?: string;
  status?: number;
}

interface BackendResponse {
  success: boolean;
  code?: number;
  message?: string;
  data?: BackendUser[];
}

interface BackendResult {
  code: number;
  msg: string;
  message?: string;  // 可选，兼容不同的响应格式
  data?: Object | BackendUser | BackendUser[];
}

export class PatientApiService {
  private static instance: PatientApiService | null = null;

  static getInstance(): PatientApiService {
    if (PatientApiService.instance === null) {
      PatientApiService.instance = new PatientApiService();
    }
    return PatientApiService.instance;
  }

  private convertUserToPatient(user: BackendUser): PatientInfo {
    const patient: PatientInfo = {
      patientId: String(user.id),
      patientName: user.real_name || user.username || '未知',
      gender: PatientGender.UNKNOWN,
      age: user.age || 0,
      phoneNumber: user.phone,
      idCardNumber: user.id_card,
      department: user.department,
      avatar: user.avatar,
      createTime: Date.now(),
      updateTime: Date.now()
    };
    
    if (user.id_card && user.id_card.length === 18) {
      const genderCode = parseInt(user.id_card.charAt(16));
      patient.gender = genderCode % 2 === 1 ? PatientGender.MALE : PatientGender.FEMALE;
    }
    
    return patient;
  }

  async getPatientList(request: PatientListRequest): Promise<PatientListResponse> {
    try {
      const token: string = await SettingsUtil.getInstance().getNurseToken();
      const httpRequest: http.HttpRequest = http.createHttp();

      // 使用护士专属患者列表API
      const url = `${ApiConstants.BASE_URL}${ApiConstants.NURSE_PATIENTS}`;

      console.log('PatientApiService - Request URL:', url);
      console.log('PatientApiService - Token:', token ? 'exists' : 'empty');
      console.log('PatientApiService - Using nurse-specific API');

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Token': token || ''  // 使用Token头，匹配后端JwtInterceptor
        },
        connectTimeout: TIMEOUT,
        readTimeout: TIMEOUT
      });

      httpRequest.destroy();

      console.log('PatientApiService - Response Code:', response.responseCode);

      if (response.responseCode === 200) {
        const result: BackendResult = JSON.parse(response.result as string) as BackendResult;
        console.log('PatientApiService - Full Response:', JSON.stringify(result, null, 2));

        // 检查后端Result格式: { code: 200, msg: "成功", data: [...] }
        if (result.code === 200 && result.data) {
          const patientsData: BackendUser[] = result.data as BackendUser[];
          console.log('PatientApiService - Patients Data Count:', Array.isArray(patientsData) ? patientsData.length : 'not array');
          console.log('PatientApiService - First patient sample:', Array.isArray(patientsData) && patientsData.length > 0 ? JSON.stringify(patientsData[0]) : 'empty');

          if (Array.isArray(patientsData)) {
            // 后端已过滤user_type=0的患者，直接转换
            const patients = patientsData
              .map((user: BackendUser) => this.convertUserToPatient(user));

            console.log('PatientApiService - Converted Patients:', patients.length);

            const pagedData: PagedResponse<PatientInfo> = {
              data: patients,
              total: patients.length,
              pageNumber: request.pageNumber,
              pageSize: request.pageSize,
              hasMore: false
            };

            return {
              success: true,
              code: 200,
              data: pagedData
            };
          } else {
            console.error('PatientApiService - Data is not array:', typeof patientsData);
            return {
              success: false,
              code: 500,
              message: '返回数据格式错误'
            };
          }
        } else if (result.code === 401) {
          console.error('PatientApiService - Unauthorized (401)');
          return {
            success: false,
            code: 401,
            message: '登录已过期，请重新登录'
          };
        } else {
          console.error('PatientApiService - API Error:', result.code, result.msg || result.message);
          return {
            success: false,
            code: result.code || -1,
            message: result.msg || result.message || '获取数据失败'
          };
        }
      } else if (response.responseCode === 401) {
        console.error('PatientApiService - HTTP 401 Unauthorized');
        return {
          success: false,
          code: 401,
          message: '登录已过期，请重新登录'
        };
      } else {
        console.error('PatientApiService - HTTP Error:', response.responseCode);
        return this.handleErrorResponse(response.responseCode);
      }
    } catch (e) {
      console.error('PatientApiService - Exception:', e);
      return {
        success: false,
        code: -1,
        message: '网络请求失败，请检查网络连接'
      };
    }
  }

  async getPatientDetail(request: PatientDetailRequest): Promise<PatientDetailResponse> {
    try {
      const token: string = await SettingsUtil.getInstance().getNurseToken();
      const httpRequest: http.HttpRequest = http.createHttp();

      // 使用护士专属患者详情API
      const url = `${ApiConstants.BASE_URL}${ApiConstants.NURSE_PATIENT_DETAIL}${request.patientId}`;

      console.log('PatientApiService - Detail URL:', url);
      console.log('PatientApiService - Token:', token ? 'exists' : 'empty');

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Token': token || ''  // 使用Token头
        },
        connectTimeout: TIMEOUT,
        readTimeout: TIMEOUT
      });

      httpRequest.destroy();

      if (response.responseCode === 200) {
        const result: BackendResult = JSON.parse(response.result as string) as BackendResult;
        console.log('PatientApiService - Detail Response:', JSON.stringify(result));

        // 检查后端Result格式
        if (result.code === 200 && result.data) {
          const user: BackendUser = result.data as BackendUser;

          console.log('PatientApiService - Detail user_type:', user.user_type);

          const patient = this.convertUserToPatient(user);
          const detail: PatientDetail = {
            patientId: patient.patientId,
            patientName: patient.patientName,
            gender: patient.gender,
            age: patient.age,
            phoneNumber: patient.phoneNumber,
            idCardNumber: patient.idCardNumber,
            medicalRecordNumber: patient.medicalRecordNumber,
            avatar: patient.avatar,
            status: patient.status,
            department: patient.department,
            bedNumber: patient.bedNumber,
            diagnosis: patient.diagnosis,
            createTime: patient.createTime,
            updateTime: Date.now()
          };

          return {
            success: true,
            code: 200,
            data: detail
          };
        } else {
          return {
            success: false,
            code: result.code || -1,
            message: result.msg || '患者不存在'
          };
        }
      } else {
        return this.handleDetailErrorResponse(response.responseCode);
      }
    } catch (e) {
      console.error('PatientApiService - getPatientDetail failed:', e);
      return {
        success: false,
        code: -1,
        message: '网络请求失败，请检查网络连接'
      };
    }
  }

  private handleErrorResponse(code: number): PatientListResponse {
    return {
      success: false,
      code: code,
      message: this.getErrorMessage(code)
    };
  }

  private handleDetailErrorResponse(code: number): PatientDetailResponse {
    return {
      success: false,
      code: code,
      message: this.getErrorMessage(code)
    };
  }

  private getErrorMessage(code: number): string {
    switch (code) {
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '无权限访问';
      case 404:
        return '资源不存在';
      case 500:
        return '服务器内部错误';
      default:
        return `请求失败，错误码：${code}`;
    }
  }
}
