import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import http from '@ohos.net.http';
import { PrescriptionFormData, PrescriptionFormDataHelper } from '../models/DoctorPatientModels';

@Entry
@Component
struct DoctorPrescriptionListPage {
  @State prescriptions: PrescriptionFormData[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.loadPrescriptions();
  }

  private async loadPrescriptions(): Promise<void> {
    try {
      hilog.info(0x0000, 'DoctorPrescriptionListPage', '开始加载处方列表');
      this.isLoading = true;

      const serverUrl: string = 'http://192.168.108.1:8080';

      const response = await http.createHttp().request(
        `${serverUrl}/medical/prescriptions/patient/21`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      hilog.info(0x0000, 'DoctorPrescriptionListPage', `响应状态: ${response.responseCode}`);

      if (response.responseCode === 200) {
        const result: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        hilog.info(0x0000, 'DoctorPrescriptionListPage', `API响应: ${JSON.stringify(result).substring(0, 200)}...`);

        if (result['code'] === 200 && result['data']) {
          const rawData: Object[] = result['data'] as Object[];
          const list: PrescriptionFormData[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const prescription: PrescriptionFormData = new PrescriptionFormData();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['id'] !== undefined) { prescription.id = raw['id'] as number; }
            if (raw['patientId'] !== undefined) { prescription.patientId = raw['patientId'] as number; }
            if (raw['patientName'] !== undefined) { prescription.patientName = raw['patientName'] as string; }
            if (raw['doctorId'] !== undefined) { prescription.doctorId = raw['doctorId'] as number; }
            if (raw['diagnosis'] !== undefined) { prescription.diagnosis = raw['diagnosis'] as string; }
            if (raw['created_at'] !== undefined || raw['createdAt'] !== undefined || raw['create_time'] !== undefined || raw['createTime'] !== undefined) {
              prescription.createTime = (raw['created_at'] || raw['createdAt'] || raw['create_time'] || raw['createTime']) as string;
            }
            list.push(prescription);
          }
          this.prescriptions = list;
          hilog.info(0x0000, 'DoctorPrescriptionListPage', `加载到 ${list.length} 条处方记录`);
        } else {
          this.errorMessage = result['msg'] !== undefined ? (result['msg'] as string) : '加载失败';
        }
      } else {
        this.errorMessage = `网络请求失败 (${response.responseCode})`;
      }
    } catch (error) {
      hilog.error(0x0000, 'DoctorPrescriptionListPage', `loadPrescriptions error: ${JSON.stringify(error)}`);
      this.errorMessage = '加载处方列表失败';
    } finally {
      this.isLoading = false;
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

        Text('处方管理')
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.errorMessage) {
        Column() {
          Text('💊')
            .fontSize(56)
            .margin({ bottom: 16 });
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 });
          Text('请稍后重试')
            .fontSize(14)
            .fontColor('#999999');
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
          Text('为患者开具的处方将在此显示')
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
                  Text(prescription.patientName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333');

                  Blank();

                  Text(prescription.medications?.length + '味药')
                    .fontSize(13)
                    .fontColor('#888888');
                }
                .width('100%')
                .alignItems(VerticalAlign.Center);

                Row() {
                  Text(prescription.createTime)
                    .fontSize(12)
                    .fontColor('#999999');

                  Blank();

                  Text(prescription.diagnosis?.substring(0, 20) + '...')
                    .fontSize(12)
                    .fontColor('#999999')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .width('100%')
                .margin({ top: 8 });
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 10 })
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/DoctorPatientManagementPage',
                  params: {
                    patientId: prescription.patientId,
                    patientName: prescription.patientName
                  }
                });
              });
            }, (prescription: PrescriptionFormData) => prescription.id?.toString() || '');
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 48 });
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
