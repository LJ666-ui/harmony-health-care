import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { MedicalRecordFormData } from '../models/DoctorPatientModels';
import { MedicalRecordFormDataHelper } from '../models/DoctorPatientModels';

export class MedicalRecordService {
  private static instance: MedicalRecordService | null = null;

  private constructor() {}

  static getInstance(): MedicalRecordService {
    if (!MedicalRecordService.instance) {
      MedicalRecordService.instance = new MedicalRecordService();
    }
    return MedicalRecordService.instance;
  }

  async createRecord(data: MedicalRecordFormData): Promise<number> {
    try {
      const map: Record<string, Object> = MedicalRecordFormDataHelper.toJson(data);
      hilog.info(0x0000, 'MedicalRecordService', `createRecord data: ${JSON.stringify(map)}`);
      const response = await HttpUtil.post<number>(ApiConstants.MEDICAL_RECORD_CREATE, map);
      if (response.success && response.data !== undefined) {
        hilog.info(0x0000, 'MedicalRecordService', `createRecord success: ${response.data}`);
        return response.data;
      } else {
        hilog.error(0x0000, 'MedicalRecordService', `createRecord error: ${response.message}`);
        return 0;
      }
    } catch (error) {
      hilog.error(0x0000, 'MedicalRecordService', `createRecord error: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  async updateRecord(id: number, data: MedicalRecordFormData): Promise<boolean> {
    try {
      const map: Record<string, Object> = MedicalRecordFormDataHelper.toJson(data);
      map['id'] = id;
      hilog.info(0x0000, 'MedicalRecordService', `updateRecord data: ${JSON.stringify(map)}`);
      const response = await HttpUtil.post<BaseResponse<boolean>>(ApiConstants.MEDICAL_RECORD_UPDATE, map);
      if (response.success) {
        hilog.info(0x0000, 'MedicalRecordService', `updateRecord success`);
        return true;
      } else {
        hilog.error(0x0000, 'MedicalRecordService', `updateRecord error: ${response.message}`);
        return false;
      }
    } catch (error) {
      hilog.error(0x0000, 'MedicalRecordService', `updateRecord error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  async getRecord(id: number): Promise<MedicalRecordFormData> {
    try {
      const url = ApiConstants.MEDICAL_RECORD_DETAIL + `?id=${id}`;
      hilog.info(0x0000, 'MedicalRecordService', `getRecord url: ${url}`);
      const response = await HttpUtil.get<MedicalRecordFormData>(url);
      if (response.success && response.data !== undefined) {
        return MedicalRecordFormDataHelper.fromJson(response.data);
      } else {
        hilog.error(0x0000, 'MedicalRecordService', `getRecord error: ${response.message}`);
        return new MedicalRecordFormData();
      }
    } catch (error) {
      hilog.error(0x0000, 'MedicalRecordService', `getRecord error: ${JSON.stringify(error)}`);
      return new MedicalRecordFormData();
    }
  }

  async getPatientRecords(patientId: number): Promise<MedicalRecordFormData[]> {
    try {
      const url = ApiConstants.MEDICAL_RECORD_PAGE + `?patientId=${patientId}`;
      hilog.info(0x0000, 'MedicalRecordService', `getPatientRecords url: ${url}`);
      const response = await HttpUtil.get<MedicalRecordFormData[]>(url);
      if (response.success && response.data !== undefined) {
        return MedicalRecordFormDataHelper.fromJsonArray(response.data);
      } else {
        hilog.error(0x0000, 'MedicalRecordService', `getPatientRecords error: ${response.message}`);
        return [];
      }
    } catch (error) {
      hilog.error(0x0000, 'MedicalRecordService', `getPatientRecords error: ${JSON.stringify(error)}`);
      return [];
    }
  }
}
