import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { PrescriptionFormData, PrescriptionMedication, PrescriptionFormDataHelper, PrescriptionMedicationHelper } from '../models/DoctorPatientModels';
import { PrescriptionService } from '../services/PrescriptionService';

@Component
export struct PrescriptionEditor {
  @Prop patientId: number = 0;
  @Prop patientName: string = '';
  @Prop doctorId: number = 0;
  @Prop doctorName: string = '';
  @State prescriptions: ESObject[] = [];
  @State formData: PrescriptionFormData = new PrescriptionFormData();
  @State isSaving: boolean = false;
  @State showForm: boolean = false;
  @State isLoading: boolean = true;
  @State selectedPrescription: ESObject | null = null;

  aboutToAppear(): void {
    this.formData.patientId = this.patientId;
    this.formData.patientName = this.patientName;
    this.formData.doctorId = this.doctorId;
    this.formData.doctorName = this.doctorName;
    this.loadPrescriptions();
  }

  private getMedicationCount(medicationsVal: ESObject): number {
    if (typeof medicationsVal !== 'string') {
      return 0;
    }
    const medicationsStr: string = medicationsVal as string;
    if (medicationsStr.trim().length === 0) {
      return 0;
    }
    const meds: ESObject[] = this.safeParseArray(medicationsStr);
    return meds.length;
  }

  private safeParseArray(jsonStr: string): ESObject[] {
    if (jsonStr === null || jsonStr === undefined || typeof jsonStr !== 'string') {
      return [];
    }
    const trimmedStr: string = jsonStr.trim();
    if (trimmedStr.length === 0) {
      return [];
    }
    if (trimmedStr[0] !== '[' || trimmedStr[trimmedStr.length - 1] !== ']') {
      return [];
    }
    const parsed: ESObject = JSON.parse(trimmedStr) as ESObject;
    if (Array.isArray(parsed)) {
      return parsed as ESObject[];
    }
    return [];
  }

  @Builder
  buildMedicationsList(medications: ESObject[]) {
    ForEach(medications, (med: ESObject, index: number) => {
        Column({ space: 8 }) {
          Text(`药品${index + 1}: ${typeof med['medicineName'] === 'string' ? med['medicineName'] : ''}`)
            .fontSize(15)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .width('100%');

          Row({ space: 12 }) {
            Text('规格：')
              .fontSize(13)
              .fontColor('#666666');
            Text(`${typeof med['specification'] === 'string' ? med['specification'] : '-'}`)
              .fontSize(13)
              .fontColor('#333333')
              .layoutWeight(1);
          }
          .width('100%');

          Row({ space: 12 }) {
            Text('用法用量：')
              .fontSize(13)
              .fontColor('#666666');
            Text(`${typeof med['dosage'] === 'string' ? med['dosage'] : ''} ${typeof med['frequency'] === 'string' ? med['frequency'] : ''}`)
              .fontSize(13)
              .fontColor('#333333')
              .layoutWeight(1);
          }
          .width('100%');

          Row({ space: 12 }) {
            Text('数量：')
              .fontSize(13)
              .fontColor('#666666');
            Text(`${typeof med['quantity'] === 'string' ? med['quantity'] : ''}${typeof med['unit'] === 'string' ? med['unit'] : '盒'}`)
              .fontSize(13)
              .fontColor('#333333')
              .layoutWeight(1);
          }
          .width('100%');
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .margin({ bottom: 8 });
      }, (med: ESObject, index: number) => `${index}_${med['medicineName']}`);
  }

  async loadPrescriptions(): Promise<void> {
    try {
      hilog.info(0x0000, 'PrescriptionEditor', `加载患者${this.patientId}的处方记录`);
      
      const serverUrl: string = 'http://192.168.108.1:8080';
      const response = await http.createHttp().request(
        `${serverUrl}/medical/prescriptions/patient/${this.patientId}`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      if (response.responseCode === 200) {
        const result: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        hilog.info(0x0000, 'PrescriptionEditor', `获取处方结果: code=${result['code']}`);

        if (result['code'] === 200 && result['data'] !== undefined) {
          const rawData: ESObject | ESObject[] | null = result['data'];
          this.prescriptions = Array.isArray(rawData) ? rawData : [rawData];
          
          hilog.info(0x0000, 'PrescriptionEditor', `成功加载${this.prescriptions.length}条处方记录`);
        }
      }
    } catch (error) {
      hilog.error(0x0000, 'PrescriptionEditor', `加载处方失败: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  addMedication(): void {
    const medication = new PrescriptionMedication();
    this.formData.medications.push(medication);
  }

  removeMedication(index: number): void {
    this.formData.medications.splice(index, 1);
  }

  async savePrescription(): Promise<void> {
    if (this.formData.medications.length === 0) {
      promptAction.showToast({ message: '请添加至少一种药品' });
      return;
    }
    
    if (!this.formData.diagnosis || this.formData.diagnosis.trim().length === 0) {
      promptAction.showToast({ message: '请输入诊断' });
      return;
    }
    
    this.isSaving = true;
    
    try {
      const serverUrl: string = 'http://192.168.108.1:8080';
      
      const medicationsArray: ESObject[] = [];
      for (let i = 0; i < this.formData.medications.length; i++) {
        const med = this.formData.medications[i];
        const medObj: ESObject = {};
        medObj['medicineName'] = med.medicineName;
        medObj['specification'] = med.specification;
        medObj['dosage'] = med.dosage;
        medObj['frequency'] = med.frequency;
        medObj['quantity'] = med.quantity;
        medicationsArray.push(medObj);
      }

      const requestData: ESObject = {
        patientId: this.patientId,
        patientName: this.patientName,
        doctorId: this.doctorId,
        doctorName: this.doctorName,
        medications: JSON.stringify(medicationsArray),
        diagnosis: this.formData.diagnosis,
        notes: this.formData.remarks || '',
        status: 'ACTIVE'
      };

      hilog.info(0x0000, 'PrescriptionEditor', `保存处方数据: ${JSON.stringify(requestData)}`);

      const response = await http.createHttp().request(
        `${serverUrl}/medical/prescriptions`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(requestData),
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      if (response.responseCode === 200) {
        const result: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        if (result['code'] === 200 && result['data']) {
          promptAction.showToast({ message: '✅ 处方开具成功' });
          this.showForm = false;
          this.selectedPrescription = null;
          await this.loadPrescriptions();
        } else {
          promptAction.showToast({ message: `❌ 开具失败: ${result['message']}` });
        }
      } else {
        promptAction.showToast({ message: '❌ 网络请求失败' });
      }
    } catch (error) {
      hilog.error(0x0000, 'PrescriptionEditor', `保存异常: ${JSON.stringify(error)}`);
      promptAction.showToast({ message: '❌ 保存异常，请检查网络连接' });
    } finally {
      this.isSaving = false;
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          Text('⏳ 加载处方记录中...')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      } else if (this.showForm) {
        this.buildForm();
      } else if (this.selectedPrescription !== null) {
        this.buildPrescriptionDetail();
      } else {
        this.buildPrescriptionList();
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildPrescriptionList() {
    Column({ space: 16 }) {
      Row() {
        Text('处方列表')
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1);

        Button('+ 开具新处方')
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

      if (this.prescriptions.length === 0) {
        Column({ space: 12 }) {
          Text('💊')
            .fontSize(56);
          Text('暂无处方记录')
            .fontSize(16)
            .fontWeight('bold')
            .fontColor('#666666');
          Text('点击上方"开具新处方"为患者开具第一张处方')
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
            ForEach(this.prescriptions, (prescription: ESObject, index: number) => {
              Column({ space: 12 }) {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text(`💊 处方 #${prescription['id']}`)
                      .fontSize(14)
                      .fontColor('#1677FF')
                      .fontWeight('bold');
                    Text(`📅 ${prescription['createdAt'] ? String(prescription['createdAt']).substring(0, 10) : ''}`)
                      .fontSize(12)
                      .fontColor('#999999');
                    Text(`药品数：${this.getMedicationCount(prescription['medications'])}种`)
                      .fontSize(12)
                      .fontColor('#666666');
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1);

                  Text(prescription['status'] === 'ACTIVE' ? '✅ 有效' : prescription['status'] === 'COMPLETED' ? '✓ 已完成' : '✕ 已取消')
                    .fontSize(13)
                    .fontColor(prescription['status'] === 'ACTIVE' ? '#52C41A' : '#999999')
                    .backgroundColor(prescription['status'] === 'ACTIVE' ? '#F6FFED' : '#F5F5F5')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(4)
                    .onClick(() => {
                      this.selectedPrescription = prescription;
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
                  Text(typeof prescription['diagnosis'] === 'string' ? prescription['diagnosis'] : '')
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                }
                .width('100%');

                Button('查看详情 >')
                  .width('100%')
                  .height(32)
                  .fontSize(13)
                  .fontColor('#1677FF')
                  .backgroundColor(Color.Transparent)
                  .borderColor('#1677FF')
                  .borderWidth(1)
                  .borderRadius(16)
                  .onClick(() => {
                    this.selectedPrescription = prescription;
                  });
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: 2 });
            }, (prescription: ESObject, index: number) => `${prescription['id']}_${index}`);
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
  buildPrescriptionDetail() {
    Scroll() {
      Column({ space: 16 }) {
        Row() {
          Button('< 返回列表')
            .height(36)
            .fontSize(14)
            .fontColor('#1677FF')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.selectedPrescription = null;
            });

          Text('处方详情')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
        }
        .width('100%');

        if (this.selectedPrescription) {
          Column({ space: 16 }) {
            Column({ space: 12 }) {
              Text('基本信息')
                .fontSize(16)
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              Row({ space: 12 }) {
                Text('处方ID')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(`${this.selectedPrescription['id']}`)
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('开具日期')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(this.selectedPrescription['createdAt'] ? String(this.selectedPrescription['createdAt']).substring(0, 19).replace('T', ' ') : '')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('有效期至')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(this.selectedPrescription['validUntil'] ? String(this.selectedPrescription['validUntil']).substring(0, 10) : '')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('状态')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80);
                Text(this.selectedPrescription['status'] === 'ACTIVE' ? '✅ 有效' : this.selectedPrescription['status'] === 'COMPLETED' ? '✓ 已完成' : '✕ 已取消')
                  .fontSize(14)
                  .fontColor(this.selectedPrescription['status'] === 'ACTIVE' ? '#52C41A' : '#999999');
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

              Text(typeof this.selectedPrescription['diagnosis'] === 'string' ? this.selectedPrescription['diagnosis'] : '')
                .fontSize(15)
                .fontColor('#333333')
                .lineHeight(22)
                .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(12);

            Column({ space: 12 }) {
              Text('💊 药品清单')
                .fontSize(16)
                .fontWeight('bold')
                .fontColor('#333333')
                .width('100%');

              if (typeof this.selectedPrescription['medications'] === 'string') {
                this.buildMedicationsList(this.safeParseArray(this.selectedPrescription['medications'] as string));
              } else {
                Text('暂无药品信息')
                  .fontSize(14)
                  .fontColor('#999999');
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(12);

            if (this.selectedPrescription['notes'] && typeof this.selectedPrescription['notes'] === 'string' && (this.selectedPrescription['notes'] as string).trim().length > 0) {
              Column({ space: 12 }) {
                Text('备注说明')
                  .fontSize(16)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .width('100%');

                Text(this.selectedPrescription['notes'] as string)
                  .fontSize(14)
                  .fontColor('#333333')
                  .lineHeight(20)
                  .width('100%');
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFBE6')
              .borderRadius(12)
              .border({ width: 1, color: '#FFE58F' });
            }
          }
          .width('100%')
          .padding({ bottom: 48 });
        }
      }
      .width('100%')
      .padding(16);
    }
    .layoutWeight(1)
    .scrollBar(BarState.On);
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

          Text('开具新处方')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
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

        Text(`已添加 ${this.formData.medications.length} 种药品`)
          .fontSize(14)
          .fontColor('#666666')
          .width('100%');

        Column({ space: 12 }) {
          ForEach(this.formData.medications, (medication: PrescriptionMedication, index: number) => {
            Column({ space: 12 }) {
              Row({ space: 12 }) {
                Text(`药品 ${index + 1}`)
                  .fontSize(14)
                  .fontWeight('bold')
                  .fontColor('#1677FF')
                  .layoutWeight(1);

                Button('删除')
                  .height(28)
                  .fontSize(12)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FF4D4F')
                  .borderRadius(14)
                  .onClick(() => {
                    this.removeMedication(index);
                  });
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('名称')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width(60);
                TextInput({ text: medication.medicineName, placeholder: '如：氨氯地平片' })
                  .width('100%')
                  .height(36)
                  .fontSize(13)
                  .fontColor('#333333')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(6)
                  .onChange((value: string) => {
                    medication.medicineName = value;
                  });
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('规格')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width(60);
                TextInput({ text: medication.specification, placeholder: '如：5mg*28片' })
                  .width('100%')
                  .height(36)
                  .fontSize(13)
                  .fontColor('#333333')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(6)
                  .onChange((value: string) => {
                    medication.specification = value;
                  });
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('用法')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width(60);
                TextInput({ text: medication.dosage, placeholder: '如：5mg' })
                  .width('100%')
                  .height(36)
                  .fontSize(13)
                  .fontColor('#333333')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(6)
                  .onChange((value: string) => {
                    medication.dosage = value;
                  });
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('频次')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width(60);
                TextInput({ text: medication.frequency, placeholder: '如：每日一次' })
                  .width('100%')
                  .height(36)
                  .fontSize(13)
                  .fontColor('#333333')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(6)
                  .onChange((value: string) => {
                    medication.frequency = value;
                  });
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('数量')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width(60);
                TextInput({ text: medication.quantity.toString() })
                  .type(InputType.Number)
                  .width('100%')
                  .height(36)
                  .fontSize(13)
                  .fontColor('#333333')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(6)
                  .onChange((value: string) => {
                    medication.quantity = parseInt(value) || 0;
                  });
              }
              .width('100%');
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#F9F9F9')
            .borderRadius(8)
            .border({ width: 1, color: '#E8E8E8' });
          }, (medication: PrescriptionMedication, index: number) => `${index}`);

          Button('+ 添加药品')
            .width('100%')
            .height(40)
            .fontSize(14)
            .fontColor('#1677FF')
            .backgroundColor('#E6F7FF')
            .borderRadius(20)
            .border({ width: 1, color: '#91D5FF', style: BorderStyle.Dashed })
            .onClick(() => {
              this.addMedication();
            });
        }
        .width('100%');

        Row({ space: 12 }) {
          Text('备注')
            .fontSize(14)
            .fontColor('#666666')
            .width(70)
            .textAlign(TextAlign.Start);
          TextArea({ text: this.formData.remarks })
            .width('100%')
            .height(80)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.formData.remarks = value;
            });
        }
        .width('100%');

        Button(this.isSaving ? '开具中...' : '💊 确认开具处方')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight('bold')
          .fontColor('#FFFFFF')
          .backgroundColor(this.isSaving ? '#CCCCCC' : '#1677FF')
          .borderRadius(24)
          .enabled(!this.isSaving)
          .margin({ top: 16, bottom: 48 })
          .onClick(() => {
            this.savePrescription();
          });
      }
      .width('100%')
      .padding(16);
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off);
  }

  private resetForm(): void {
    this.formData = new PrescriptionFormData();
    this.formData.patientId = this.patientId;
    this.formData.patientName = this.patientName;
    this.formData.doctorId = this.doctorId;
    this.formData.doctorName = this.doctorName;
  }
}
