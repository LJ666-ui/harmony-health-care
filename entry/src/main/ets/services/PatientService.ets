import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { PatientBasicInfo, PatientHealthProfile, PatientVisitRecord } from '../models/DoctorPatientModels';
import { PatientBasicInfoHelper, PatientHealthProfileHelper, PatientVisitRecordHelper } from '../models/DoctorPatientModels';

export class PatientService {
  private static instance: PatientService | null = null;

  private constructor() {}

  static getInstance(): PatientService {
    if (!PatientService.instance) {
      PatientService.instance = new PatientService();
    }
    return PatientService.instance;
  }

  async getPatientInfo(patientId: number): Promise<PatientBasicInfo> {
    try {
      const url = ApiConstants.PATIENT_INFO + patientId;
      hilog.info(0x0000, 'PatientService', `getPatientInfo url: ${url}`);
      const response = await HttpUtil.get<PatientBasicInfo>(url);
      if (response.success && response.data !== undefined) {
        return PatientBasicInfoHelper.fromJson(response.data);
      } else {
        hilog.error(0x0000, 'PatientService', `getPatientInfo error: ${response.message}`);
        return new PatientBasicInfo();
      }
    } catch (error) {
      hilog.error(0x0000, 'PatientService', `getPatientInfo error: ${JSON.stringify(error)}`);
      return new PatientBasicInfo();
    }
  }

  async getHealthProfile(patientId: number): Promise<PatientHealthProfile> {
    try {
      const url = ApiConstants.PATIENT_HEALTH_PROFILE + patientId;
      hilog.info(0x0000, 'PatientService', `getHealthProfile url: ${url}`);
      const response = await HttpUtil.get<PatientHealthProfile>(url);
      if (response.success && response.data !== undefined) {
        return PatientHealthProfileHelper.fromJson(response.data);
      } else {
        hilog.error(0x0000, 'PatientService', `getHealthProfile error: ${response.message}`);
        return new PatientHealthProfile();
      }
    } catch (error) {
      hilog.error(0x0000, 'PatientService', `getHealthProfile error: ${JSON.stringify(error)}`);
      return new PatientHealthProfile();
    }
  }

  async getVisitRecords(patientId: number): Promise<PatientVisitRecord[]> {
    try {
      const url = ApiConstants.PATIENT_VISIT_RECORDS + patientId;
      hilog.info(0x0000, 'PatientService', `getVisitRecords url: ${url}`);
      const response = await HttpUtil.get<PatientVisitRecord[]>(url);
      if (response.success && response.data !== undefined) {
        return PatientVisitRecordHelper.fromJsonArray(response.data);
      } else {
        hilog.error(0x0000, 'PatientService', `getVisitRecords error: ${response.message}`);
        return [];
      }
    } catch (error) {
      hilog.error(0x0000, 'PatientService', `getVisitRecords error: ${JSON.stringify(error)}`);
      return [];
    }
  }
}
