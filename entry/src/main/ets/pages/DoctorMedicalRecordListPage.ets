import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import http from '@ohos.net.http';
import { MedicalRecordFormData, MedicalRecordFormDataHelper } from '../models/DoctorPatientModels';

@Entry
@Component
struct DoctorMedicalRecordListPage {
  @State records: MedicalRecordFormData[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.loadRecords();
  }

  private async loadRecords(): Promise<void> {
    try {
      hilog.info(0x0000, 'DoctorMedicalRecordListPage', '开始加载病历列表');
      this.isLoading = true;

      const serverUrl: string = 'http://192.168.108.1:8080';

      const response = await http.createHttp().request(
        `${serverUrl}/medical/record/my?userId=21`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      hilog.info(0x0000, 'DoctorMedicalRecordListPage', `响应状态: ${response.responseCode}`);

      if (response.responseCode === 200) {
        const result: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        hilog.info(0x0000, 'DoctorMedicalRecordListPage', `API响应: ${JSON.stringify(result)}`);

        if (result['success'] === true && result['data']) {
          const rawData: Object[] = result['data'] as Object[];
          const list: MedicalRecordFormData[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const record: MedicalRecordFormData = new MedicalRecordFormData();
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            if (raw['id'] !== undefined) { record.id = raw['id'] as number; }
            if (raw['user_id'] !== undefined || raw['userId'] !== undefined) { record.patientId = (raw['user_id'] || raw['userId']) as number; }
            if (raw['doctor_id'] !== undefined || raw['doctorId'] !== undefined) { record.doctorId = (raw['doctor_id'] || raw['doctorId']) as number; }
            if (raw['diagnosis'] !== undefined) { record.diagnosis = raw['diagnosis'] as string; }
            if (raw['treatment'] !== undefined) { record.treatmentPlan = raw['treatment'] as string; }
            if (raw['recordTime'] !== undefined) { record.visitDate = (raw['recordTime'] as string).substring(0, 10); }
            list.push(record);
          }
          this.records = list;
          hilog.info(0x0000, 'DoctorMedicalRecordListPage', `加载到 ${list.length} 条病历记录`);
        } else {
          this.errorMessage = result['message'] !== undefined ? (result['message'] as string) : '加载失败';
        }
      } else {
        this.errorMessage = `网络请求失败 (${response.responseCode})`;
      }
    } catch (error) {
      hilog.error(0x0000, 'DoctorMedicalRecordListPage', `loadRecords error: ${JSON.stringify(error)}`);
      this.errorMessage = '加载病历列表失败';
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

        Text('病历管理')
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
          Text('📋')
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
      } else if (this.records.length === 0) {
        Column() {
          Text('📋')
            .fontSize(56)
            .margin({ bottom: 16 });
          Text('暂无病历')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 });
          Text('为患者开具的病历将在此显示')
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
            ForEach(this.records, (record: MedicalRecordFormData) => {
              Column() {
                Row() {
                  Text(record.patientName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333');

                  Blank();

                  Text(record.diagnosis?.substring(0, 20) + '...')
                    .fontSize(13)
                    .fontColor('#888888')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .width('100%')
                .alignItems(VerticalAlign.Center);

                Row() {
                  Text(record.visitDate)
                    .fontSize(12)
                    .fontColor('#999999');

                  Blank();

                  Text(record.chiefComplaint?.substring(0, 20) + '...')
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
                    patientId: record.patientId,
                    patientName: record.patientName
                  }
                });
              });
            }, (record: MedicalRecordFormData) => record.id?.toString() || '');
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
