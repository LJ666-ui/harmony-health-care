import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PatientInfoView } from '../components/PatientInfoView.ets';
import { MedicalRecordEditor } from '../components/MedicalRecordEditor.ets';
import { PrescriptionEditor } from '../components/PrescriptionEditor.ets';
import { ConsultationChatView } from '../components/ConsultationChatView.ets';
import { PatientService } from '../services/PatientService';
import { MedicalRecordService } from '../services/MedicalRecordService';
import { PrescriptionService } from '../services/PrescriptionService';

@Entry
@Component
struct DoctorPatientManagementPage {
  @StorageLink('userId') currentUserId: number = 0;
  @State patientId: number = 0;
  @State doctorId: number = 0;
  @State patientName: string = '';
  @State doctorName: string = '';
  @State currentTab: number = 0;
  @State patientData: ESObject | null = null;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    hilog.info(0x0000, 'DoctorPatientManagementPage', `aboutToAppear params=${JSON.stringify(params)}`);
    if (params) {
      this.patientId = params.patientId as number;
      this.doctorId = params.doctorId as number;
      this.patientName = params.patientName as string;
      this.doctorName = params.doctorName as string;
      this.patientData = params.patientData as ESObject || null;
    }
  }

  build() {
    Column() {
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#333333');
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        });

        Text(this.patientName)
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 });

      Tabs({ index: this.currentTab }) {
        TabContent() {
          PatientInfoView({ patientId: this.patientId, patientData: this.patientData });
        }
        .tabBar('患者信息');

        TabContent() {
          MedicalRecordEditor({
            patientId: this.patientId,
            doctorId: this.doctorId,
            patientName: this.patientName,
            doctorName: this.doctorName
          });
        }
        .tabBar('病历');

        TabContent() {
          PrescriptionEditor({
            patientId: this.patientId,
            patientName: this.patientName,
            doctorId: this.doctorId,
            doctorName: this.doctorName
          });
        }
        .tabBar('处方');

        TabContent() {
          ConsultationChatView({
            patientId: this.patientId,
            patientName: this.patientName,
            doctorId: this.doctorId,
            doctorName: this.doctorName
          });
        }
        .tabBar('对话');
      }
      .width('100%')
      .height('100%')
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTab = index;
      });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }
}
