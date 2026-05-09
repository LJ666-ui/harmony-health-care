import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { PrescriptionFormData, PrescriptionFormDataHelper, PrescriptionMedication } from '../models/DoctorPatientModels';

@Entry
@Component
struct PrescriptionListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State prescriptions: PrescriptionFormData[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.loadPrescriptions();
  }

  private async loadPrescriptions(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      const params: Record<string, string> = {
        'patientId': this.currentUserId.toString()
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
      } else {
        this.errorMessage = response.message || '加载处方失败';
      }
    } catch (error) {
      console.error('[PrescriptionListPage] 加载处方失败:', error);
      this.errorMessage = '网络错误，请稍后重试';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Header({ title: '我的处方' })

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
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 });
          Text('医生开具的处方将在此显示')
            .fontSize(14)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .width('75%')
            .lineHeight(20);
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
                  Text(prescription.doctorName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333');

                  Blank();

                  Text(prescription.createTime?.split(' ')[0] || '')
                    .fontSize(12)
                    .fontColor('#999999');
                }
                .width('100%')
                .alignItems(VerticalAlign.Center);

                if (prescription.diagnosis) {
                  Text('诊断：' + prescription.diagnosis)
                    .fontSize(13)
                    .fontColor('#666666')
                    .margin({ top: 8 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }

                if (prescription.medications && prescription.medications.length > 0) {
                  Column({ space: 8 }) {
                    Text('处方药品：')
                      .fontSize(13)
                      .fontColor('#999999')
                      .width('100%');

                    ForEach(prescription.medications.slice(0, 3), (med: PrescriptionMedication) => {
                      Row() {
                        Text('•')
                          .fontSize(12)
                          .fontColor('#13C2C2')
                          .margin({ right: 4 });
                        Text(med.medicineName || '未知药品')
                          .fontSize(13)
                          .fontColor('#333333')
                          .layoutWeight(1)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis });
                      }
                      .width('100%');
                    }, (med: PrescriptionMedication, index: number) => index.toString());

                    if (prescription.medications.length > 3) {
                      Text(`等 ${prescription.medications.length} 味药`)
                        .fontSize(12)
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
                      .fontSize(12)
                      .fontColor('#999999');
                    Text(prescription.remarks)
                      .fontSize(12)
                      .fontColor('#333333')
                      .layoutWeight(1);
                  }
                  .width('100%')
                  .margin({ top: 8 });
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 12 })
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/PrescriptionDetailPage',
                  params: { prescriptionId: prescription.id }
                });
              });
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
