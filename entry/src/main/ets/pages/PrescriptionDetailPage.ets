import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { PrescriptionFormData, PrescriptionFormDataHelper, PrescriptionMedication } from '../models/DoctorPatientModels';

@Entry
@Component
struct PrescriptionDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State prescriptionId: number = 0;
  @State prescription: PrescriptionFormData | null = null;
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params.prescriptionId) {
      this.prescriptionId = params.prescriptionId as number;
      this.loadPrescription();
    }
  }

  private async loadPrescription(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const params: Record<string, string> = {
        'id': this.prescriptionId.toString()
      };
      const response = await HttpUtil.get<PrescriptionFormData>(ApiConstants.PRESCRIPTION_DETAIL, params);

      if (response.success && response.data) {
        this.prescription = response.data;
      } else {
        this.errorMessage = response.message || '加载处方详情失败';
      }
    } catch (error) {
      console.error('[PrescriptionDetailPage] 加载处方详情失败:', error);
      this.errorMessage = '网络错误，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Header({ title: '处方详情', showBack: true })

      if (this.isLoading) {
        Column() {
          Text('⏳')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text('加载中...')
            .fontSize(16)
            .fontColor('#666666');
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
            .fontSize(16)
            .fontColor('#666666');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.prescription) {
        Scroll() {
          Column({ space: 16 }) {
            // 处方基本信息
            Column({ space: 12 }) {
              Text('处方信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              Row({ space: 12 }) {
                Text('开方医生')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(this.prescription.doctorName)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1);
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('开具时间')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(this.prescription.createTime)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1);
              }
              .width('100%');

              if (this.prescription.doctorName) {
                Row({ space: 12 }) {
                  Text('医生')
                    .fontSize(14)
                    .fontColor('#666666')
                    .width(80);
                  Text(this.prescription.doctorName)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1);
                }
                .width('100%');
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            // 诊断信息
            if (this.prescription.diagnosis) {
              Column({ space: 12 }) {
                Text('诊断')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%');

                Text(this.prescription.diagnosis)
                  .fontSize(14)
                  .fontColor('#333333')
                  .lineHeight(22);
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12);
            }

            // 处方药品
            Column({ space: 12 }) {
              Text('处方药品')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              if (this.prescription.medications && this.prescription.medications.length > 0) {
                ForEach(this.prescription.medications, (med: PrescriptionMedication, index: number) => {
                  Column({ space: 8 }) {
                    Row() {
                      Text(`${index + 1}.`)
                        .fontSize(14)
                        .fontColor('#13C2C2')
                        .fontWeight(FontWeight.Bold);
                      Text(med.medicineName || '未知药品')
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333');
                    }
                    .width('100%');

                    if (med.specification) {
                      Row() {
                        Text('规格：')
                          .fontSize(13)
                          .fontColor('#999999');
                        Text(med.specification)
                          .fontSize(13)
                          .fontColor('#333333');
                      }
                      .width('100%');
                    }

                    if (med.dosage) {
                      Row() {
                        Text('用量：')
                          .fontSize(13)
                          .fontColor('#999999');
                        Text(med.dosage)
                          .fontSize(13)
                          .fontColor('#333333');
                      }
                      .width('100%');
                    }

                    if (med.frequency) {
                      Row() {
                        Text('频次：')
                          .fontSize(13)
                          .fontColor('#999999');
                        Text(med.frequency)
                          .fontSize(13)
                          .fontColor('#333333');
                      }
                      .width('100%');
                    }

                    if (med.quantity) {
                      Row() {
                        Text('数量：')
                          .fontSize(13)
                          .fontColor('#999999');
                        Text(med.quantity.toString())
                          .fontSize(13)
                          .fontColor('#333333');
                      }
                      .width('100%');
                    }
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#F5F7FA')
                  .borderRadius(8);
                }, (med: PrescriptionMedication, index: number) => index.toString());
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12);

            // 备注
            if (this.prescription.remarks) {
              Column({ space: 12 }) {
                Text('备注')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%');

                Text(this.prescription.remarks)
                  .fontSize(14)
                  .fontColor('#333333')
                  .lineHeight(22);
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12);
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 32 });
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
