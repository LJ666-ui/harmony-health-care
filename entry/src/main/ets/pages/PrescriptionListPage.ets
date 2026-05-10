import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { ConsultationService, Prescription } from '../services/ConsultationService';
import { ToastUtil } from '../common/utils/ToastUtil';
import { getMockPrescriptions } from '../mock/prescriptionMock';

@Entry
@Component
struct PrescriptionListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State prescriptions: Prescription[] = [];
  @State isLoading: boolean = true;

  private consultationService: ConsultationService = ConsultationService.getInstance();

  aboutToAppear(): void {
    this.loadPrescriptions();
  }

  async loadPrescriptions(): Promise<void> {
    this.isLoading = true;
    try {
      const userId = AppStorage.get<number>('userId') || 1;
      
      try {
        this.prescriptions = await this.consultationService.getUserPrescriptions(userId);
        
        if (this.prescriptions.length === 0) {
          console.log('[PrescriptionListPage] API返回空数据，使用Mock数据');
          this.prescriptions = getMockPrescriptions();
        }
      } catch (apiError) {
        console.warn('[PrescriptionListPage] API调用失败，使用Mock数据:', apiError);
        this.prescriptions = getMockPrescriptions();
      }
    } catch (error) {
      console.error('[PrescriptionListPage] 加载处方列表失败:', error);
      ToastUtil.showError('加载处方列表失败');
      this.prescriptions = getMockPrescriptions();
    } finally {
      this.isLoading = false;
    }
  }

  onPrescriptionClick(prescription: Prescription): void {
    router.pushUrl({
      url: 'pages/PrescriptionPage',
      params: {
        prescriptionId: prescription.prescriptionId
      }
    });
  }

  private getTitleFontSize(): number {
    return this.isElderMode ? 18 : 16;
  }

  private getBodyFontSize(): number {
    return this.isElderMode ? 14 : 12;
  }

  build() {
    Column() {
      Header({ title: '处方管理', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#1677FF');
          
          Text('加载中...')
            .fontSize(this.getBodyFontSize())
            .fontColor('#999999')
            .margin({ top: 16 });
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      } else if (this.prescriptions.length === 0) {
        Column() {
          Text('📋')
            .fontSize(64)
            .margin({ bottom: 16 });
          
          Text('暂无处方记录')
            .fontSize(this.getTitleFontSize())
            .fontColor('#999999');
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      } else {
        List({ space: 12 }) {
          ForEach(this.prescriptions, (prescription: Prescription) => {
            ListItem() {
              this.PrescriptionCard(prescription);
            }
            .onClick(() => {
              this.onPrescriptionClick(prescription);
            });
          });
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 16 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5');
  }

  @Builder PrescriptionCard(prescription: Prescription) {
    Column() {
      Row() {
        Text('处方单号')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666666')
          .layoutWeight(1);
        
        Text(`#${prescription.prescriptionId}`)
          .fontSize(this.getBodyFontSize())
          .fontColor('#1677FF')
          .fontWeight(FontWeight.Bold);
      }
      .width('100%')
      .margin({ bottom: 8 });

      Row() {
        Text('开具医生')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666666')
          .layoutWeight(1);
        
        Text(`医生ID: ${prescription.doctorId}`)
          .fontSize(this.getBodyFontSize())
          .fontColor('#333333');
      }
      .width('100%')
      .margin({ bottom: 8 });

      Row() {
        Text('开具时间')
          .fontSize(this.getBodyFontSize())
          .fontColor('#666666')
          .layoutWeight(1);
        
        Text(this.formatTime(prescription.createTime))
          .fontSize(this.getBodyFontSize())
          .fontColor('#333333');
      }
      .width('100%');

      Row() {
        Text('查看详情')
          .fontSize(this.getBodyFontSize())
          .fontColor('#1677FF');
        
        Text(' →')
          .fontSize(this.getBodyFontSize())
          .fontColor('#1677FF');
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 12 });
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8);
  }

  private formatTime(time: string): string {
    if (!time) return '未知';
    try {
      const date = new Date(time);
      return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
    } catch (error) {
      return time;
    }
  }
}
