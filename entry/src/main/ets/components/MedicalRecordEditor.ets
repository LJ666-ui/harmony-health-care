import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { MedicalRecordFormData, MedicalRecordFormDataHelper } from '../models/DoctorPatientModels';
import { MedicalRecordService } from '../services/MedicalRecordService';

@Component
export struct MedicalRecordEditor {
  @Prop patientId: number = 0;
  @Prop doctorId: number = 0;
  @Prop patientName: string = '';
  @Prop doctorName: string = '';
  @State records: MedicalRecordFormData[] = [];
  @State formData: MedicalRecordFormData = new MedicalRecordFormData();
  @State isSaving: boolean = false;
  @State showForm: boolean = false;
  @State isLoading: boolean = true;
  @State selectedRecord: MedicalRecordFormData | null = null;

  aboutToAppear(): void {
    this.formData.patientId = this.patientId;
    this.formData.patientName = this.patientName;
    this.formData.doctorId = this.doctorId;
    this.formData.doctorName = this.doctorName;
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    this.formData.visitDate = `${year}-${month}-${day}`;
    this.loadRecords();
  }

  async loadRecords(): Promise<void> {
    try {
      hilog.info(0x0000, 'MedicalRecordEditor', `加载患者${this.patientId}的病历记录`);
      
      const serverUrl: string = 'http://192.168.108.1:8080';
      const response = await http.createHttp().request(
        `${serverUrl}/medical/record/my?userId=${this.patientId}`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      if (response.responseCode === 200) {
        const result: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        hilog.info(0x0000, 'MedicalRecordEditor', `获取病历结果: code=${result['code']}, success=${result['success']}`);

        if (result['success'] === true && result['data'] !== undefined) {
          const rawData: ESObject | ESObject[] | null = result['data'];
          const recordsData: ESObject[] = Array.isArray(rawData) ? rawData : [];
          
          this.records = [];
          for (let i = 0; i < recordsData.length; i++) {
            const raw: ESObject = recordsData[i] as ESObject;
            if (raw == null) continue;
            
            const record: MedicalRecordFormData = new MedicalRecordFormData();

            const idVal: string | number | boolean | null | undefined = raw['id'];
            record.id = typeof idVal === 'number' ? idVal : 0;
            
            const diagnosisVal: string | number | boolean | null | undefined = raw['diagnosis'];
            record.diagnosis = typeof diagnosisVal === 'string' ? diagnosisVal : '';
            
            const treatmentVal: string | number | boolean | null | undefined = raw['treatment'];
            record.treatmentPlan = typeof treatmentVal === 'string' ? treatmentVal : '';
            
            const recordTimeVal: string | number | boolean | null | undefined = raw['recordTime'];
            record.visitDate = typeof recordTimeVal === 'string' ? recordTimeVal.substring(0, 10) : '';
            
            const doctorIdVal: string | number | boolean | null | undefined = raw['doctorId'];
            record.doctorId = typeof doctorIdVal === 'number' ? doctorIdVal : 0;
            
            this.records.push(record);
          }
          
          hilog.info(0x0000, 'MedicalRecordEditor', `成功加载${this.records.length}条病历记录`);
        }
      }
    } catch (error) {
      hilog.error(0x0000, 'MedicalRecordEditor', `加载病历失败: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  validateForm(): boolean {
    if (!this.formData.visitDate) {
      promptAction.showToast({ message: '请输入就诊日期' });
      return false;
    }
    if (!this.formData.chiefComplaint) {
      promptAction.showToast({ message: '请输入主诉' });
      return false;
    }
    if (!this.formData.diagnosis) {
      promptAction.showToast({ message: '请输入诊断' });
      return false;
    }
    return true;
  }

  async saveRecord(): Promise<void> {
    if (!this.validateForm()) {
      return;
    }
    this.isSaving = true;

    try {
      const serverUrl: string = 'http://192.168.108.1:8080';
      const visitTime: string = `${this.formData.visitDate}T${new Date().toTimeString().substring(0, 8)}`;
      const requestData: ESObject = {
        userId: this.patientId,
        hospitalId: 1,
        doctorId: this.doctorId,
        diagnosis: this.formData.diagnosis || '',
        treatment: this.formData.treatmentPlan || this.formData.chiefComplaint || '',
        recordTime: visitTime,
        isDesensitized: 0,
        isDeleted: 0
      };

      hilog.info(0x0000, 'MedicalRecordEditor', `保存病历数据: ${JSON.stringify(requestData)}`);

      const response = await http.createHttp().request(
        `${serverUrl}/medical/record/create`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(requestData),
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      hilog.info(0x0000, 'MedicalRecordEditor', `响应状态: ${response.responseCode}, 响应内容: ${response.result}`);

      if (response.responseCode === 200) {
        const result: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        hilog.info(0x0000, 'MedicalRecordEditor', `解析结果: success=${result['success']}, message=${result['message']}`);
        if (result['success'] === true) {
          promptAction.showToast({ message: '✅ 病历保存成功' });
          this.showForm = false;
          this.selectedRecord = null;
          await this.loadRecords();
        } else {
          const errorMsg: string = result['message'] !== undefined ? (result['message'] as string) : '未知错误';
          promptAction.showToast({ message: `❌ 保存失败: ${errorMsg}` });
        }
      } else {
        promptAction.showToast({ message: `❌ 网络请求失败 (${response.responseCode})` });
      }
    } catch (error) {
      hilog.error(0x0000, 'MedicalRecordEditor', `保存异常: ${JSON.stringify(error)}`);
      promptAction.showToast({ message: '❌ 保存异常，请检查网络连接' });
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          Text('⏳ 加载病历记录中...')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      } else if (this.showForm) {
        this.buildForm();
      } else if (this.selectedRecord !== null) {
        this.buildRecordDetail();
      } else {
        this.buildRecordList();
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildRecordList() {
    Column({ space: 16 }) {
      Row() {
        Text('历史病历')
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1);

        Button('+ 新建病历')
          .height(36)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(18)
          .onClick(() => {
            this.showForm = true;
            this.resetForm();
          });
      }
      .width('100%');

      if (this.records.length === 0) {
        Column({ space: 12 }) {
          Text('📋')
            .fontSize(56);
          Text('暂无病历记录')
            .fontSize(16)
            .fontWeight('bold')
            .fontColor('#666666');
          Text('点击上方"新建病历"为患者创建第一条病历')
            .fontSize(14)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .width('80%')
            .lineHeight(20);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.records, (record: MedicalRecordFormData, index: number) => {
              Column({ space: 12 }) {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text(`📅 ${record.visitDate}`)
                      .fontSize(13)
                      .fontColor('#1677FF')
                      .fontWeight('bold');
                    Text(`🆔 病历ID: ${record.id}`)
                      .fontSize(12)
                      .fontColor('#999999');
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1);

                  Text('查看详情 >')
                    .fontSize(13)
                    .fontColor('#1677FF')
                    .onClick(() => {
                      this.selectedRecord = record;
                    });
                }
                .width('100%');

                Divider()
                  .color('#EEEEEE');

                Row({ space: 12 }) {
                  Text('诊断：')
                    .fontSize(14)
                    .fontColor('#666666')
                    .fontWeight('bold');
                  Text(record.diagnosis)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .width('100%');

                if (record.treatmentPlan && record.treatmentPlan.trim().length > 0) {
                  Row({ space: 12 }) {
                    Text('治疗：')
                      .fontSize(13)
                      .fontColor('#666666')
                      .fontWeight('bold');
                    Text(record.treatmentPlan.substring(0, 100) + (record.treatmentPlan.length > 100 ? '...' : ''))
                      .fontSize(13)
                      .fontColor('#666666')
                      .layoutWeight(1)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                  }
                  .width('100%');
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: 2 })
              .onClick((event?: ClickEvent) => {
                if (event && event.x > 250) {
                  this.selectedRecord = record;
                }
              });
            }, (record: MedicalRecordFormData) => record.id.toString());
          }
          .width('100%')
          .padding({ bottom: 48 });
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .padding(16);
  }

  @Builder
  buildRecordDetail() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('< 返回列表')
            .height(36)
            .fontSize(14)
            .fontColor('#1677FF')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.selectedRecord = null;
            });

          Text('病历详情')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
        }
        .width('100%');

        if (this.selectedRecord) {
          Column({ space: 16 }) {
            Column({ space: 12 }) {
              Text('基本信息')
                .fontSize(16)
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              Row({ space: 12 }) {
                Text('病历ID')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(`${this.selectedRecord.id}`)
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('就诊日期')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(this.selectedRecord.visitDate)
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('医生ID')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(`${this.selectedRecord.doctorId}`)
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(12);

            Column({ space: 12 }) {
              Text('诊断信息')
                .fontSize(16)
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              Text(this.selectedRecord.diagnosis)
                .fontSize(15)
                .fontColor('#333333')
                .lineHeight(22)
                .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(12);

            if (this.selectedRecord.treatmentPlan && this.selectedRecord.treatmentPlan.trim().length > 0) {
              Column({ space: 12 }) {
                Text('治疗方案')
                  .fontSize(16)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .width('100%');

                Text(this.selectedRecord.treatmentPlan)
                  .fontSize(14)
                  .fontColor('#333333')
                  .lineHeight(20)
                  .width('100%');
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(12);
            }
          }
        }
      }.width('100%')
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .padding(16);
  }

  @Builder
  buildForm() {
    Scroll() {
      Column({ space: 12 }) {
        Row() {
          Button('< 返回')
            .height(36)
            .fontSize(14)
            .fontColor('#1677FF')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.showForm = false;
            });

          Text('新建病历')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('就诊日期')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextInput({ text: this.formData.visitDate })
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.visitDate = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('主诉')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.chiefComplaint })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.chiefComplaint = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('现病史')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.presentIllness })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.presentIllness = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('既往史')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.pastHistory })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.pastHistory = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('体格检查')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.physicalExam })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.physicalExam = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('辅助检查')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.auxiliaryExam })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.auxiliaryExam = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('诊断')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.diagnosis })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.diagnosis = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('治疗方案')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.treatmentPlan })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.treatmentPlan = value;
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('医嘱')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.advice })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.advice = value;
            });
        }
        .width('100%');

        Button(this.isSaving ? '保存中...' : '💾 保存病历')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isSaving ? '#CCCCCC' : '#52C41A')
          .borderRadius(22)
          .enabled(!this.isSaving)
          .margin({ top: 8, bottom: 48 })
          .onClick(() => {
            this.saveRecord();
          });
      }
      .width('100%')
      .padding(16);
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off);
  }

  private resetForm(): void {
    this.formData = new MedicalRecordFormData();
    this.formData.patientId = this.patientId;
    this.formData.patientName = this.patientName;
    this.formData.doctorId = this.doctorId;
    this.formData.doctorName = this.doctorName;
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    this.formData.visitDate = `${year}-${month}-${day}`;
  }
}
