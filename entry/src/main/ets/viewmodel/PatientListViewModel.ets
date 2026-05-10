import { PatientInfo, SortField, SortOrder } from '../model/PatientModel';
import { 
  PatientListPageState, 
  LoadingState, 
  createInitialListState 
} from '../model/StateModel';
import { PatientService } from '../service/PatientService';
import { ToastUtil } from '../utils/ToastUtil';

export class PatientListViewModel {
  private state: PatientListPageState = createInitialListState();
  private patientService: PatientService;

  constructor() {
    this.patientService = PatientService.getInstance();
  }

  getState(): PatientListPageState {
    return this.state;
  }

  async loadPatientList(): Promise<void> {
    this.state.loadingState = LoadingState.LOADING;
    console.log('PatientListViewModel - loadPatientList start');
    
    try {
      const patients = await this.patientService.getPatientList(
        undefined,
        this.state.pageNumber,
        this.state.pageSize
      );
      
      console.log('PatientListViewModel - Loaded patients count:', patients.length);
      
      this.state.patients = patients;
      this.state.filteredPatients = this.applySearchAndSort(patients);
      
      if (patients.length === 0) {
        this.state.loadingState = LoadingState.EMPTY;
        console.log('PatientListViewModel - State: EMPTY');
      } else {
        this.state.loadingState = LoadingState.SUCCESS;
        console.log('PatientListViewModel - State: SUCCESS');
      }
    } catch (e) {
      console.error('PatientListViewModel - loadPatientList failed:', e);
      this.state.loadingState = LoadingState.ERROR;
      this.state.errorMessage = '加载患者列表失败';
      ToastUtil.showError('加载患者列表失败');
    }
  }

  async refreshPatientList(): Promise<void> {
    this.state.pageNumber = 1;
    
    try {
      const patients = await this.patientService.refreshPatientList(undefined);
      
      this.state.patients = patients;
      this.state.filteredPatients = this.applySearchAndSort(patients);
      
      if (patients.length === 0) {
        this.state.loadingState = LoadingState.EMPTY;
      } else {
        this.state.loadingState = LoadingState.SUCCESS;
        ToastUtil.showSuccess('刷新成功');
      }
    } catch (e) {
      console.error('PatientListViewModel - refreshPatientList failed:', e);
      ToastUtil.showError('刷新失败');
    }
  }

  searchPatient(keyword: string): void {
    this.state.searchText = keyword;
    this.state.filteredPatients = this.applySearchAndSort(this.state.patients);
    
    if (this.state.filteredPatients.length === 0 && keyword.length > 0) {
      ToastUtil.showInfo('未找到匹配的患者');
    }
  }

  async loadMorePatients(): Promise<void> {
    if (!this.state.hasMore) {
      return;
    }
    
    this.state.loadingState = LoadingState.LOADING;
    this.state.pageNumber++;
    
    try {
      const morePatients = await this.patientService.getPatientList(
        undefined,
        this.state.pageNumber,
        this.state.pageSize
      );
      
      if (morePatients.length > 0) {
        this.state.patients = [...this.state.patients, ...morePatients];
        this.state.filteredPatients = this.applySearchAndSort(this.state.patients);
        this.state.hasMore = morePatients.length === this.state.pageSize;
      } else {
        this.state.hasMore = false;
      }
      
      this.state.loadingState = LoadingState.SUCCESS;
    } catch (e) {
      console.error('PatientListViewModel - loadMorePatients failed:', e);
      this.state.pageNumber--;
      this.state.loadingState = LoadingState.ERROR;
      ToastUtil.showError('加载更多失败');
    }
  }

  markAsViewed(patientId: string): void {
    this.state.viewedPatientIds.add(patientId);
  }

  isViewed(patientId: string): boolean {
    return this.state.viewedPatientIds.has(patientId);
  }

  getPatientCount(): number {
    return this.state.patients.length;
  }

  getFilteredCount(): number {
    return this.state.filteredPatients.length;
  }

  private applySearchAndSort(patients: PatientInfo[]): PatientInfo[] {
    let result = patients;
    
    if (this.state.searchText.trim().length > 0) {
      result = this.patientService.searchPatients(result, this.state.searchText);
    }
    
    result = this.patientService.sortPatients(result, SortField.PATIENT_NAME, SortOrder.ASC);
    
    return result;
  }
}
