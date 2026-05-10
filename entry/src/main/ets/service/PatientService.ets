import { 
  PatientInfo, 
  PatientDetail, 
  PatientListRequest,
  PatientDetailRequest,
  QueryType,
  SortField,
  SortOrder,
  DataSource
} from '../model/PatientModel';
import { DefaultCacheConfig } from '../model/CacheModel';
import { PatientApiService } from '../api/PatientApiService';
import { CacheManager } from '../utils/CacheManager';
import { DataDesensitizer, DesensitizationConfig } from '../utils/DataDesensitizer';
import { SettingsUtil } from '../utils/SettingsUtil';

const PATIENT_LIST_CACHE_KEY = 'patient_list_cache';
const PATIENT_DETAIL_CACHE_KEY_PREFIX = 'patient_detail_';

export class PatientService {
  private static instance: PatientService | null = null;
  private apiService: PatientApiService;
  private cacheManager: CacheManager;

  private constructor() {
    this.apiService = PatientApiService.getInstance();
    this.cacheManager = CacheManager.getInstance();
  }

  static getInstance(): PatientService {
    if (PatientService.instance === null) {
      PatientService.instance = new PatientService();
    }
    return PatientService.instance;
  }

  async getPatientList(
    nurseId?: string,
    pageNumber: number = 1,
    pageSize: number = 20,
    forceRefresh: boolean = false
  ): Promise<PatientInfo[]> {
    if (!forceRefresh) {
      const cacheKey = `${PATIENT_LIST_CACHE_KEY}_${nurseId || 'all'}_${pageNumber}_${pageSize}`;
      const cached = this.cacheManager.getCache<PatientInfo[]>(cacheKey);
      if (cached) {
        return cached;
      }
    }

    const request: PatientListRequest = {
      nurseId: nurseId,
      queryType: QueryType.ALL,
      pageNumber: pageNumber,
      pageSize: pageSize,
      sortField: SortField.PATIENT_NAME,
      sortOrder: SortOrder.ASC
    };

    const response = await this.apiService.getPatientList(request);
    
    if (response.success && response.data) {
      const patients = response.data.data;
      
      if (!forceRefresh) {
        const cacheKey = `${PATIENT_LIST_CACHE_KEY}_${nurseId || 'all'}_${pageNumber}_${pageSize}`;
        this.cacheManager.saveCache(cacheKey, patients, DefaultCacheConfig.listCacheExpireTime);
      }
      
      return patients;
    }
    
    console.error('PatientService - getPatientList failed:', response.message);
    return [];
  }

  async getPatientDetail(
    patientId: string,
    dataSource: DataSource = DataSource.AUTO
  ): Promise<PatientDetail | null> {
    const cacheKey = `${PATIENT_DETAIL_CACHE_KEY_PREFIX}${patientId}`;
    
    if (dataSource === DataSource.CACHE || dataSource === DataSource.AUTO) {
      const cached = this.cacheManager.getCache<PatientDetail>(cacheKey);
      if (cached) {
        if (dataSource === DataSource.CACHE) {
          return cached;
        }
      }
    }

    const request: PatientDetailRequest = {
      patientId: patientId,
      dataSource: dataSource
    };

    const response = await this.apiService.getPatientDetail(request);
    
    if (response.success && response.data) {
      const detail = response.data;
      this.cacheManager.saveCache(cacheKey, detail, DefaultCacheConfig.detailCacheExpireTime);
      return detail;
    }
    
    console.error('PatientService - getPatientDetail failed:', response.message);
    return null;
  }

  async refreshPatientList(nurseId?: string): Promise<PatientInfo[]> {
    return this.getPatientList(nurseId, 1, 20, true);
  }

  searchPatients(patients: PatientInfo[], keyword: string): PatientInfo[] {
    if (!keyword || keyword.trim().length === 0) {
      return patients;
    }
    
    const lowerKeyword = keyword.toLowerCase().trim();
    return patients.filter(patient => 
      patient.patientName.toLowerCase().includes(lowerKeyword) ||
      (patient.medicalRecordNumber && patient.medicalRecordNumber.toLowerCase().includes(lowerKeyword)) ||
      (patient.department && patient.department.toLowerCase().includes(lowerKeyword))
    );
  }

  sortPatients(
    patients: PatientInfo[], 
    sortField: SortField = SortField.PATIENT_NAME,
    sortOrder: SortOrder = SortOrder.ASC
  ): PatientInfo[] {
    const sorted = [...patients];
    
    sorted.sort((a, b) => {
      let comparison = 0;
      
      switch (sortField) {
        case SortField.PATIENT_NAME:
          comparison = a.patientName.localeCompare(b.patientName);
          break;
        case SortField.CREATE_TIME:
          comparison = (a.createTime || 0) - (b.createTime || 0);
          break;
        case SortField.UPDATE_TIME:
          comparison = (a.updateTime || 0) - (b.updateTime || 0);
          break;
      }
      
      return sortOrder === SortOrder.ASC ? comparison : -comparison;
    });
    
    return sorted;
  }

  async desensitizePatientDetail(detail: PatientDetail): Promise<PatientDetail> {
    const config = await this.getDesensitizationConfig();
    return DataDesensitizer.desensitizePatientDetail(detail, config);
  }

  private async getDesensitizationConfig(): Promise<DesensitizationConfig> {
    return DataDesensitizer.DefaultDesensitizationConfig;
  }

  clearPatientCache(patientId?: string): void {
    if (patientId) {
      const cacheKey = `${PATIENT_DETAIL_CACHE_KEY_PREFIX}${patientId}`;
      this.cacheManager.clearCache(cacheKey);
    } else {
      this.cacheManager.clearCache();
    }
  }
}
