import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { PrescriptionFormData } from '../models/DoctorPatientModels';
import { PrescriptionFormDataHelper } from '../models/DoctorPatientModels';

export class PrescriptionService {
  private static instance: PrescriptionService | null = null;

  private constructor() {}

  static getInstance(): PrescriptionService {
    if (!PrescriptionService.instance) {
      PrescriptionService.instance = new PrescriptionService();
    }
    return PrescriptionService.instance;
  }

  async createPrescription(data: PrescriptionFormData): Promise<number> {
    try {
      const map: Record<string, Object> = PrescriptionFormDataHelper.toJson(data);
      hilog.info(0x0000, 'PrescriptionService', `createPrescription data: ${JSON.stringify(map)}`);
      const response = await HttpUtil.post<number>(ApiConstants.PRESCRIPTION_CREATE, map);
      if (response.success && response.data !== undefined) {
        hilog.info(0x0000, 'PrescriptionService', `createPrescription success: ${response.data}`);
        return response.data;
      } else {
        hilog.error(0x0000, 'PrescriptionService', `createPrescription error: ${response.message}`);
        return 0;
      }
    } catch (error) {
      hilog.error(0x0000, 'PrescriptionService', `createPrescription error: ${JSON.stringify(error)}`);
      return 0;
    }
  }

  async getPrescription(id: number): Promise<PrescriptionFormData> {
    try {
      const url = ApiConstants.PRESCRIPTION_DETAIL + `?id=${id}`;
      hilog.info(0x0000, 'PrescriptionService', `getPrescription url: ${url}`);
      const response = await HttpUtil.get<PrescriptionFormData>(url);
      if (response.success && response.data !== undefined) {
        return response.data;
      } else {
        hilog.error(0x0000, 'PrescriptionService', `getPrescription error: ${response.message}`);
        return new PrescriptionFormData();
      }
    } catch (error) {
      hilog.error(0x0000, 'PrescriptionService', `getPrescription error: ${JSON.stringify(error)}`);
      return new PrescriptionFormData();
    }
  }

  async getPatientPrescriptions(patientId: number): Promise<PrescriptionFormData[]> {
    try {
      const url = ApiConstants.PRESCRIPTION_PAGE + `?patientId=${patientId}`;
      hilog.info(0x0000, 'PrescriptionService', `getPatientPrescriptions url: ${url}`);
      const response = await HttpUtil.get<PrescriptionFormData[]>(url);
      if (response.success && response.data !== undefined) {
        return PrescriptionFormDataHelper.fromJsonArrayFromObjectArray(response.data as Object[]);
      } else {
        hilog.error(0x0000, 'PrescriptionService', `getPatientPrescriptions error: ${response.message}`);
        return [];
      }
    } catch (error) {
      hilog.error(0x0000, 'PrescriptionService', `getPatientPrescriptions error: ${JSON.stringify(error)}`);
      return [];
    }
  }
}
