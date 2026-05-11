import { PatientInfo } from '../model/PatientModel';
import { LoadingState } from '../model/StateModel';
import { PatientListViewModel } from '../viewmodel/PatientListViewModel';
import { SearchBar, StateComponent } from '../components/CommonComponents';
import { PatientListItem } from '../components/PatientListItem';
import { RouterUtil } from '../utils/RouterUtil';
import { AuditLogger } from '../utils/AuditLogger';
import { SimplePatientData } from '../utils/PatientDataCache';

@Entry
@Component
struct PatientListPage {
  @State viewModel: PatientListViewModel = new PatientListViewModel();
  @State searchText: string = '';
  @State loadingState: LoadingState = LoadingState.IDLE;
  @State errorMessage: string = '';
  @State patients: PatientInfo[] = [];
  private auditLogger: AuditLogger = AuditLogger.getInstance();

  async aboutToAppear() {
    console.log('PatientListPage - aboutToAppear start');
    await this.auditLogger.logPatientListView();
    await this.loadPatientList();
  }

  async loadPatientList() {
    await this.viewModel.loadPatientList();
    this.updateState();
  }

  updateState() {
    const state = this.viewModel.getState();
    this.loadingState = state.loadingState;
    this.errorMessage = state.errorMessage || '';
    this.patients = [...state.filteredPatients];
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            RouterUtil.back();
          })

        Text('患者列表')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      SearchBar({
        searchText: $searchText,
        onSearch: (keyword: string) => {
          this.viewModel.searchPatient(keyword);
          this.updateState();
          if (keyword.length > 0) {
            this.auditLogger.logSearchAction(keyword);
          }
        }
      })

      if (this.loadingState === LoadingState.LOADING ||
          this.loadingState === LoadingState.ERROR ||
          this.loadingState === LoadingState.EMPTY) {
        StateComponent({
          state: this.loadingState,
          errorMessage: this.errorMessage,
          onRetry: () => {
            this.loadPatientList();
          }
        })
          .layoutWeight(1)
      } else {
        Refresh({ refreshing: false }) {
          List() {
            ForEach(this.patients, (patient: PatientInfo) => {
              ListItem() {
                PatientListItem({
                  patient: patient,
                  isViewed: this.viewModel.isViewed(patient.patientId),
                  onItemClick: (p: PatientInfo) => {
                    console.log('PatientListPage - onItemClick:', p.patientId, p.patientName);
                    this.viewModel.markAsViewed(p.patientId);
                    
                    const patientDataObj: SimplePatientData = {
                      id: Number(p.patientId) || 0,
                      username: p.patientName || '',
                      realName: p.patientName || '',
                      phone: p.phoneNumber || '',
                      age: p.age || 0,
                      gender: (p.gender as string) === 'MALE' ? 1 : ((p.gender as string) === 'FEMALE' ? 2 : 0),
                      idCard: p.idCardNumber || '',
                      hospital: '',
                      department: p.department || '',
                      bedNumber: p.bedNumber || '',
                      diagnosis: p.diagnosis || ''
                    };
                    
                    const dataJson = JSON.stringify(patientDataObj);
                    console.log('PatientListPage - Sending dataJson length:', dataJson.length);
                    
                    const params: Record<string, Object> = {
                      'patientId': p.patientId,
                      'patientName': p.patientName,
                      'patientDataJson': dataJson
                    };
                    RouterUtil.pushUrlSync('pages/PatientDetailPage', params);
                  }
                })
              }
            }, (patient: PatientInfo) => patient.patientId)
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .margin({ top: 12 })
        }
        .onRefreshing(async () => {
          await this.viewModel.refreshPatientList();
          await this.auditLogger.logRefreshAction('patient_list');
          this.updateState();
        })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
