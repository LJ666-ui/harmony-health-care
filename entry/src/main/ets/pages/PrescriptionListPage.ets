import { router, Color } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { ConsultationService, Prescription } from '../services/ConsultationService';
import { getMockPrescriptions } from '../mock/prescriptionMock';
import { PrescriptionFormData, PrescriptionFormDataHelper, PrescriptionMedication } from '../models/DoctorPatientModels';

@Entry
@Component
struct PrescriptionListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State prescriptions: PrescriptionFormData[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  private consultationService: ConsultationService = ConsultationService.getInstance();

  aboutToAppear(): void {
    this.loadPrescriptions();
  }

  private async loadPrescriptions(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const userId = this.currentUserId || 1;
      let dataLoaded = false;

      try {
        const params: Record<string, string> = {
          'patientId': userId.toString()
        };
        const response = await HttpUtil.get<PrescriptionFormData[]>(ApiConstants.PRESCRIPTION_PAGE, params);

        if (response.success && response.data) {
          const rawData: Object[] = response.data as Object[];
          const list: PrescriptionFormData[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const item: PrescriptionFormData = PrescriptionFormDataHelper.fromJson(rawData[i] as Record<string, Object>);
            list.push(item);
          }
          this.prescriptions = list;
          dataLoaded = true;
        }
      } catch (apiError) {
        console.warn('[PrescriptionListPage] API调用失败，尝试使用Mock数据:', apiError);
      }

      if (!dataLoaded) {
        try {
          const mockPrescriptions = await this.consultationService.getUserPrescriptions(userId);
          if (mockPrescriptions && mockPrescriptions.length > 0) {
            this.prescriptions = this.convertToFormData(mockPrescriptions);
          } else {
            this.prescriptions = this.convertToFormData(getMockPrescriptions());
          }
        } catch (mockError) {
          this.prescriptions = [];
          this.errorMessage = '加载处方失败，请稍后重试';
        }
      }

    } catch (error) {
      console.error('[PrescriptionListPage] 加载处方失败:', error);
      this.errorMessage = '网络错误，请稍后重试';
      ToastUtil.showError('加载处方列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Mock Prescription 转换为业务 PrescriptionFormData
   */
  private convertToFormData(prescriptions: Prescription[]): PrescriptionFormData[] {
    return prescriptions.map(p => {
      const data = new PrescriptionFormData();
      data.id = p.prescriptionId;
      data.doctorId = p.doctorId;
      data.doctorName = `医生 ${p.doctorId}`;
      data.createTime = p.createTime;
      data.medications = [];
      return data;
    });
  }

  onPrescriptionClick(prescription: PrescriptionFormData): void {
    router.pushUrl({
      url: 'pages/PrescriptionDetailPage',
      params: {
        prescriptionId: prescription.id
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
      Header({ title: '我的处方' })

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
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);

      } else if (this.errorMessage) {
        Column() {
          Text('💊')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text(this.errorMessage)
            .fontSize(this.getBodyFontSize())
            .fontColor('#666666')
            .margin({ bottom: 8 });
          Button('重新加载')
            .margin({ top: 16 })
            .onClick(() => {
              this.loadPrescriptions();
            });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);

      } else if (this.prescriptions.length === 0) {
        Column() {
          Text('💊')
            .fontSize(56)
            .margin({ bottom: 16 });
          Text('暂无处方')
            .fontSize(this.getTitleFontSize())
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 });
          Text('医生开具的处方将在此显示')
            .fontSize(this.getBodyFontSize())
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .width('75%');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);

      } else {
        Scroll() {
          Column() {
            ForEach(this.prescriptions, (prescription: PrescriptionFormData) => {
              Column() {
                Row() {
                  Text(prescription.doctorName || `医生 ${prescription.doctorId}`)
                    .fontSize(this.getTitleFontSize())
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333');

                  Blank();

                  Text(prescription.createTime?.split(' ')[0] || '')
                    .fontSize(this.getBodyFontSize())
                    .fontColor('#999999');
                }
                .width('100%')
                .alignItems(VerticalAlign.Center);

                if (prescription.diagnosis) {
                  Text('诊断：' + prescription.diagnosis)
                    .fontSize(this.getBodyFontSize())
                    .fontColor('#666666')
                    .margin({ top: 8 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }

                if (prescription.medications && prescription.medications.length > 0) {
                  Column({ space: 8 }) {
                    Text('处方药品：')
                      .fontSize(this.getBodyFontSize())
                      .fontColor('#999999')
                      .width('100%');

                    ForEach(prescription.medications.slice(0, 3), (med: PrescriptionMedication) => {
                      Row() {
                        Text('•')
                          .fontSize(this.getBodyFontSize())
                          .fontColor('#13C2C2')
                          .margin({ right: 4 });
                        Text(med.medicineName || '未知药品')
                          .fontSize(this.getBodyFontSize())
                          .fontColor('#333333')
                          .layoutWeight(1)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis });
                      }
                      .width('100%');
                    }, (med: PrescriptionMedication, index: number) => index.toString());

                    if (prescription.medications.length > 3) {
                      Text(`等 ${prescription.medications.length} 味药`)
                        .fontSize(this.getBodyFontSize())
                        .fontColor('#999999')
                        .width('100%');
                    }
                  }
                  .width('100%')
                  .margin({ top: 8 })
                  .padding(12)
                  .backgroundColor('#F5F7FA')
                  .borderRadius(8);
                }

                if (prescription.remarks) {
                  Row() {
                    Text('备注：')
                      .fontSize(this.getBodyFontSize())
                      .fontColor('#999999');
                    Text(prescription.remarks)
                      .fontSize(this.getBodyFontSize())
                      .fontColor('#333333')
                      .layoutWeight(1);
                  }
                  .width('100%')
                  .margin({ top: 8 });
                }

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
                .margin({ top: 8 });
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 12 })
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => this.onPrescriptionClick(prescription));
            }, (prescription: PrescriptionFormData) => prescription.id?.toString() || '');
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 100 });
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}