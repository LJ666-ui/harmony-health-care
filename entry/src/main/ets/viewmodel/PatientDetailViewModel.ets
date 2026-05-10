import { PatientDetail, DataSource } from '../model/PatientModel';
import { 
  PatientDetailPageState, 
  LoadingState, 
  createInitialDetailState 
} from '../model/StateModel';
import { PatientService } from '../service/PatientService';
import { CacheManager } from '../utils/CacheManager';
import { ToastUtil } from '../utils/ToastUtil';

const PATIENT_DETAIL_CACHE_KEY_PREFIX = 'patient_detail_';

export class PatientDetailViewModel {
  private state: PatientDetailPageState = createInitialDetailState();
  private patientService: PatientService;
  private cacheManager: CacheManager;
  private patientId: string;

  constructor(patientId: string) {
    this.patientService = PatientService.getInstance();
    this.cacheManager = CacheManager.getInstance();
    this.patientId = patientId;
  }

  getState(): PatientDetailPageState {
    return this.state;
  }

  async loadPatientDetail(): Promise<void> {
    this.state.loadingState = LoadingState.LOADING;
    
    try {
      const cacheKey = `${PATIENT_DETAIL_CACHE_KEY_PREFIX}${this.patientId}`;
      const isFromCache = this.cacheManager.hasCache(cacheKey);
      
      const detail = await this.patientService.getPatientDetail(this.patientId, DataSource.AUTO);
      
      if (detail) {
        this.state.rawDetail = detail;
        this.state.displayDetail = await this.patientService.desensitizePatientDetail(detail);
        this.state.isFromCache = isFromCache;
        this.state.loadingState = LoadingState.SUCCESS;
      } else {
        this.state.loadingState = LoadingState.EMPTY;
        this.state.errorMessage = '患者信息不存在';
      }
    } catch (e) {
      console.error('PatientDetailViewModel - loadPatientDetail failed:', e);
      this.state.loadingState = LoadingState.ERROR;
      this.state.errorMessage = '加载患者详情失败';
      ToastUtil.showError('加载患者详情失败');
    }
  }

  async refreshPatientDetail(): Promise<void> {
    this.state.loadingState = LoadingState.LOADING;
    
    try {
      const detail = await this.patientService.getPatientDetail(this.patientId, DataSource.REMOTE);
      
      if (detail) {
        this.state.rawDetail = detail;
        this.state.displayDetail = await this.patientService.desensitizePatientDetail(detail);
        this.state.isFromCache = false;
        this.state.loadingState = LoadingState.SUCCESS;
        ToastUtil.showSuccess('刷新成功');
      } else {
        this.state.loadingState = LoadingState.EMPTY;
        this.state.errorMessage = '患者信息不存在';
      }
    } catch (e) {
      console.error('PatientDetailViewModel - refreshPatientDetail failed:', e);
      ToastUtil.showError('刷新失败');
    }
  }

  getPatientName(): string {
    return this.state.displayDetail?.patientName || '';
  }

  getPatientId(): string {
    return this.patientId;
  }

  isDataStale(): boolean {
    if (!this.state.isFromCache) {
      return false;
    }
    
    const now = Date.now();
    const cacheAge = now - this.state.cacheExpireTime;
    return cacheAge > 5 * 60 * 1000;
  }

  clearCache(): void {
    this.patientService.clearPatientCache(this.patientId);
  }
}
