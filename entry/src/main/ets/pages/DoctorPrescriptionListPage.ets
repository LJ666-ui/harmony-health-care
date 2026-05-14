import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import {
  PrescriptionFormData, PrescriptionFormDataHelper,
  PrescriptionMedication, PrescriptionMedicationHelper
} from '../models/DoctorPatientModels';

interface AppointmentPatient {
  appointmentId: number;
  userId: number;
  userName: string;
  scheduleDate: string;
  schedulePeriod: number;
  periodText: string;
  status: number;
}

interface PrescriptionItem {
  id: number;
  patientId: number;
  patientName: string;
  diagnosis: string;
  medicationCount: number;
  remarks: string;
  createTime: string;
}

@Entry
@Component
struct DoctorPrescriptionListPage {
  @StorageLink('userId') currentUserId: number = 0;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State patients: AppointmentPatient[] = [];
  @State prescriptions: PrescriptionItem[] = [];
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State selectedPatientId: number = 0;
  @State selectedPatientName: string = '';
  @State showCreateDialog: boolean = false;
  @State currentView: 'patients' | 'prescriptions' = 'patients';

  private newPrescription: PrescriptionFormData = new PrescriptionFormData();
  private tempMedication: PrescriptionMedication = new PrescriptionMedication();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadTodayPatients();
  }

  async loadTodayPatients(): Promise<void> {
    this.isLoading = true;
    this.hasError = false;
    try {
      const params: Record<string, string> = {
        'doctorId': this.currentUserId.toString()
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.APPOINTMENT_LIST,
        undefined,
        params as Object,
        { showLoading: false }
      );

      if (response.success && response.data) {
        const rawData = response.data as Object[];
        const list: AppointmentPatient[] = [];

        const periodMap: Record<number, string> = { 1: '上午', 2: '下午', 3: '晚上' };

        for (let i = 0; i < rawData.length; i++) {
          const raw = rawData[i] as Record<string, Object>;
          const aptStatus = Number(raw['status'] || 0);

          if (aptStatus === 0 || aptStatus === 1) {
            const item: AppointmentPatient = {
              appointmentId: Number(raw['id'] || 0),
              userId: Number(raw['userId'] || 0),
              userName: String(raw['patientName'] || raw['userName'] || '未知患者'),
              scheduleDate: String(raw['scheduleDate'] || ''),
              schedulePeriod: Number(raw['schedulePeriod'] || 1),
              periodText: periodMap[Number(raw['schedulePeriod'] || 1)] || '上午',
              status: aptStatus
            };
            list.push(item);
          }
        }

        this.patients = list;
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载失败';
      }
    } catch (error) {
      this.hasError = true;
      this.errorMessage = '网络错误，请检查连接';
    } finally {
      this.isLoading = false;
    }
  }

  async loadPrescriptionsForPatient(patientId: number): Promise<void> {
    this.isLoading = true;
    try {
      const params: Record<string, string> = {
        'patientId': patientId.toString(),
        'doctorId': this.currentUserId.toString(),
        'page': '1',
        'size': '50'
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.PRESCRIPTION_PAGE,
        undefined,
        params as Object,
        { showLoading: false }
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        const rawRecords: Object[] = data['records'] as Object[] || data['list'] as Object[] || [];
        const arr: Object[] = Array.isArray(rawRecords) ? rawRecords : [data];
        const list: PrescriptionItem[] = [];

        for (let i = 0; i < arr.length; i++) {
          const raw = arr[i] as Record<string, Object>;
          let timeStr = String(raw['createdAt'] || raw['createTime'] || raw['created_at'] || '');
          if (timeStr && timeStr.length > 19) timeStr = timeStr.substring(0, 16);
          if (timeStr) timeStr = timeStr.replace('T', ' ');

          let medCount = 0;
          const medsRaw = raw['medications'];
          if (Array.isArray(medsRaw)) medCount = medsRaw.length;

          list.push({
            id: Number(raw['id'] || 0),
            patientId: Number(raw['patientId'] || 0),
            patientName: String(raw['patientName'] || ''),
            diagnosis: String(raw['diagnosis'] || ''),
            medicationCount: medCount,
            remarks: String(raw['remarks'] || ''),
            createTime: timeStr
          });
        }
        this.prescriptions = list;
      }
    } catch (error) {
      console.error('[处方管理] 加载处方失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  selectPatient(patient: AppointmentPatient): void {
    this.selectedPatientId = patient.userId;
    this.selectedPatientName = patient.userName;
    this.currentView = 'prescriptions';
    this.loadPrescriptionsForPatient(patient.userId);
  }

  backToPatients(): void {
    this.currentView = 'patients';
    this.prescriptions = [];
    this.selectedPatientId = 0;
    this.selectedPatientName = '';
  }

  openCreateDialog(): void {
    this.newPrescription = new PrescriptionFormData();
    this.newPrescription.patientId = this.selectedPatientId;
    this.newPrescription.patientName = this.selectedPatientName;
    this.newPrescription.doctorId = this.currentUserId;
    this.newPrescription.medications = [];
    this.showCreateDialog = true;
  }

  addMedication(): void {
    if (!this.tempMedication.medicineName) {
      ToastUtil.showError('请输入药品名称');
      return;
    }
    const med: PrescriptionMedication = new PrescriptionMedication();
    med.medicineName = this.tempMedication.medicineName;
    med.specification = this.tempMedication.specification;
    med.dosage = this.tempMedication.dosage;
    med.frequency = this.tempMedication.frequency;
    med.quantity = this.tempMedication.quantity || 1;
    this.newPrescription.medications.push(med);
    this.tempMedication = new PrescriptionMedication();
  }

  removeMedication(index: number): void {
    this.newPrescription.medications.splice(index, 1);
  }

  async submitPrescription(): Promise<void> {
    if (!this.newPrescription.diagnosis) {
      ToastUtil.showError('请填写诊断');
      return;
    }
    if (this.newPrescription.medications.length === 0) {
      ToastUtil.showError('请至少添加一种药品');
      return;
    }

    try {
      const rxData = PrescriptionFormDataHelper.toJson(this.newPrescription);
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.PRESCRIPTION_CREATE,
        rxData as Object,
        undefined,
        { showLoading: true, loadingText: '正在保存...' }
      );

      if (response.success) {
        ToastUtil.showSuccess('处方创建成功');
        this.showCreateDialog = false;
        this.loadPrescriptionsForPatient(this.selectedPatientId);
      } else {
        ToastUtil.showError(response.message || '创建失败');
      }
    } catch (error) {
      ToastUtil.showError('网络异常，请重试');
    }
  }

  viewPrescriptionDetail(rx: PrescriptionItem): void {
    router.pushUrl({
      url: 'pages/MedicalRecord',
      params: {
        prescriptionId: rx.id,
        patientId: rx.patientId,
        patientName: rx.patientName,
        fromDoctor: true,
        isPrescription: true
      }
    });
  }

  build() {
    Stack() {
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
            if (this.currentView === 'prescriptions') {
              this.backToPatients();
            } else {
              router.back();
            }
          });

          Text(this.currentView === 'prescriptions' ? `${this.selectedPatientName} 的处方` : '处方管理')
            .fontSize(this.isElderMode ? 20 : 18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);

          if (this.currentView === 'prescriptions') {
            Text('+ 开具')
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor('#FA8C16')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#FFF7E6')
              .borderRadius(16)
              .onClick(() => { this.openCreateDialog(); });
          } else {
            Text('')
              .width(60);
          }
        }
        .width('100%')
        .height(56)
        .padding({ left: 12, right: 12 });

        if (this.currentView === 'patients') {
          this.buildPatientsView();
        } else {
          this.buildPrescriptionsView();
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA');

      if (this.showCreateDialog) {
        this.buildCreateDialog();
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildPatientsView() {
    Column() {
      Text('选择就诊患者')
        .fontSize(this.isElderMode ? 17 : 15)
        .fontColor('#666666')
        .margin({ top: 8, bottom: 12 })

      if (this.isLoading && this.patients.length === 0) {
        Column() {
          Text('加载中...').fontSize(16).fontColor('#999999');
        }.layoutWeight(1).justifyContent(FlexAlign.Center);
      } else if (this.hasError) {
        Column() {
          Text('\u{1F4ED}').fontSize(48).margin({ bottom: 12 });
          Text(this.errorMessage).fontSize(15).fontColor('#FF6B6B').textAlign(TextAlign.Center);
          Button('重新加载')
            .type(ButtonType.Normal).borderRadius(20).backgroundColor('#FA8C16')
            .width(140).height(38).margin({ top: 16 })
            .onClick(() => { this.loadTodayPatients(); });
        }.layoutWeight(1).justifyContent(FlexAlign.Center);
      } else if (this.patients.length === 0) {
        Column() {
          Text('\u{1F4CB}').fontSize(56).margin({ bottom: 16 });
          Text('今日暂无就诊患者')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');
          Text('有患者挂号后可在此开具新处方')
            .fontSize(13).fontColor('#999999').margin({ top: 8 });
        }.layoutWeight(1).justifyContent(FlexAlign.Center);
      } else {
        List({ space: 10 }) {
          ForEach(this.patients, (patient: AppointmentPatient) => {
            ListItem() {
              Column() {
                Row() {
                  Column() {
                    Text(patient.userName)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333');
                    Text(patient.scheduleDate ? patient.scheduleDate.substring(5) : '')
                      .fontSize(12).fontColor('#999999').margin({ top: 2 });
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank();

                  Column() {
                    Text(patient.periodText)
                      .fontSize(this.isElderMode ? 15 : 13)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#FA8C16')
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor('#FFF7E6')
                      .borderRadius(8);
                    Text(patient.status === 0 ? '待就诊' : '已就诊')
                      .fontSize(11)
                      .fontColor(patient.status === 0 ? '#FA8C16' : '#52C41A')
                      .margin({ top: 4 });
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')

                Row() {
                  Text('\u{1F4A5} 查看并开具新处方')
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#FA8C16');
                  Blank();
                  Text('>')
                    .fontSize(16).fontColor('#CCCCCC');
                }
                .width('100%')
                .margin({ top: 10 })
                .padding({ top: 8 })
                .border({ width: { top: 1 }, color: '#F0F0F0' })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => { this.selectPatient(patient); });
            }
          }, (p: AppointmentPatient) => '' + p.appointmentId)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
    }
    .width('100%')
    .layoutWeight(1);
  }

  @Builder
  buildPrescriptionsView() {
    Column() {
      Row() {
        Text(`共 ${this.prescriptions.length} 张处方`)
          .fontSize(13).fontColor('#999999');
        Blank();
        Button('返回患者列表')
          .type(ButtonType.Normal).height(32)
          .fontSize(12).fontColor('#666666')
          .backgroundColor('#F5F5F5').borderRadius(16)
          .onClick(() => { this.backToPatients(); });
      }
      .width('85%')
      .padding({ top: 8, bottom: 8 })

      if (this.isLoading && this.prescriptions.length === 0) {
        Column() { Text('加载中...').fontSize(16).fontColor('#999999'); }
          .layoutWeight(1).justifyContent(FlexAlign.Center);
      } else if (this.prescriptions.length === 0) {
        Column() {
          Text('\u{1F4A5}').fontSize(52).margin({ bottom: 12 });
          Text('暂无处方记录')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold).fontColor('#333333');
          Text('点击右上角「+ 开具」为该患者创建新处方')
            .fontSize(13).fontColor('#999999').textAlign(TextAlign.Center).width('75%').margin({ top: 8 });
        }.layoutWeight(1).justifyContent(FlexAlign.Center);
      } else {
        List({ space: 10 }) {
          ForEach(this.prescriptions, (rx: PrescriptionItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(rx.diagnosis || '未填诊断')
                    .fontSize(this.isElderMode ? 17 : 15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Blank();
                  Text(rx.medicationCount + '味药')
                    .fontSize(13)
                    .fontColor('#FA8C16')
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .backgroundColor('#FFF7E6')
                    .borderRadius(8);
                }
                .width('100%')

                Row() {
                  Text('\u{23F0} ' + (rx.createTime || ''))
                    .fontSize(12).fontColor('#999999');
                  Blank();
                  if (rx.remarks) {
                    Text('备注：' + rx.remarks.substring(0, 15))
                      .fontSize(11).fontColor('#BBBBBB')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                  }
                }
                .width('100%').margin({ top: 6 });

                Row() {
                  Text('\u{1F441} 查看详情')
                    .fontSize(this.isElderMode ? 14 : 12).fontColor('#FA8C16');
                  Blank();
                  Text('>').fontSize(16).fontColor('#CCCCCC');
                }
                .width('100%').margin({ top: 8 }).padding({ top: 8 })
                .border({ width: { top: 1 }, color: '#F0F0F0' })
              }
              .width('100%').padding(16)
              .backgroundColor('#FFFFFF').borderRadius(12)
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => { this.viewPrescriptionDetail(rx); });
            }
          }, (r: PrescriptionItem) => '' + r.id)
        }
        .width('100%').layoutWeight(1)
        .padding({ left: 16, right: 16, top: 4, bottom: 16 })
      }
    }
    .width('100%').layoutWeight(1);
  }

  @Builder
  buildCreateDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .onClick(() => { this.showCreateDialog = false; })

      Scroll() {
        Column({ space: 14 }) {
          Text('开具新处方')
            .fontSize(this.isElderMode ? 20 : 18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .alignSelf(ItemAlign.Center)

          Text(`患者：${this.newPrescription.patientName}`)
            .fontSize(14).fontColor('#666666').alignSelf(ItemAlign.Start)

          TextInput({ text: this.newPrescription.diagnosis, placeholder: '诊断（必填）' })
            .width('100%').height(44)
            .fontSize(this.isElderMode ? 16 : 14)
            .onChange((v: string) => { this.newPrescription.diagnosis = v; })

          Text('药品列表')
            .fontSize(15).fontWeight(FontWeight.Medium).fontColor('#333333')
            .alignSelf(ItemAlign.Start)

          if (this.newPrescription.medications.length > 0) {
            ForEach(this.newPrescription.medications, (med: PrescriptionMedication, index: number) => {
              Row() {
                Column({ space: 2 }) {
                  Text(med.medicineName)
                    .fontSize(14).fontWeight(FontWeight.Medium).fontColor('#333333');
                  Row({ space: 6 }) {
                    if (med.specification) { Text(med.specification).fontSize(11).fontColor('#888888'); }
                    if (med.dosage) { Text(med.dosage).fontSize(11).fontColor('#888888'); }
                    if (med.frequency) { Text(med.frequency).fontSize(11).fontColor('#888888'); }
                    if (med.quantity > 0) { Text('x' + med.quantity).fontSize(11).fontColor('#FA8C16'); }
                  }
                }
                .alignItems(HorizontalAlign.Start).layoutWeight(1)

                Button('删除')
                  .type(ButtonType.Normal).height(28).fontSize(11)
                  .fontColor('#FF4D4F').backgroundColor('#FFF1F0').borderRadius(14)
                  .onClick(() => { this.removeMedication(index); });
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#FFFBF0')
              .borderRadius(8)
              .border({ width: 1, color: '#FFE58F' })
            }, (m: PrescriptionMedication, index: number) => '' + index + m.medicineName)
          }

          Column({ space: 8 }) {
            Text('添加药品')
              .fontSize(13).fontWeight(FontWeight.Medium).fontColor('#FA8C16')

            Row({ space: 8 }) {
              TextInput({ text: this.tempMedication.medicineName, placeholder: '药品名称*' })
                .layoutWeight(1).height(38).fontSize(13)
                .onChange((v: string) => { this.tempMedication.medicineName = v; })
              TextInput({ text: this.tempMedication.dosage, placeholder: '用法用量' })
                .layoutWeight(1).height(38).fontSize(13)
                .onChange((v: string) => { this.tempMedication.dosage = v; })
            }
            .width('100%')

            Row({ space: 8 }) {
              TextInput({ text: this.tempMedication.specification, placeholder: '规格' })
                .layoutWeight(1).height(38).fontSize(13)
                .onChange((v: string) => { this.tempMedication.specification = v; })
              TextInput({ text: this.tempMedication.frequency, placeholder: '频次' })
                .layoutWeight(1).height(38).fontSize(13)
                .onChange((v: string) => { this.tempMedication.frequency = v; })
              TextInput({ text: this.tempMedication.quantity > 0 ? this.tempMedication.quantity.toString() : '', placeholder: '数量' })
                .width(70).height(38).fontSize(13).type(InputType.Number)
                .onChange((v: string) => { this.tempMedication.quantity = parseInt(v) || 0; })
            }
            .width('100%')

            Button('+ 添加药品')
              .type(ButtonType.Normal).width('100%').height(36)
              .fontSize(13).fontColor('#FFFFFF')
              .backgroundColor('#FA8C16').borderRadius(18)
              .onClick(() => { this.addMedication(); })
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFBF0')
          .borderRadius(10)
          .border({ width: 1, color: '#FFE58F', style: BorderStyle.Dashed })

          TextArea({ text: this.newPrescription.remarks, placeholder: '处方备注' })
            .width('100%').height(56)
            .fontSize(this.isElderMode ? 15 : 13)
            .onChange((v: string) => { this.newPrescription.remarks = v; })

          Row({ space: 12 }) {
            Button('取消')
              .type(ButtonType.Normal).layoutWeight(1).height(42)
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor('#666666').backgroundColor('#F5F5F5').borderRadius(21)
              .onClick(() => { this.showCreateDialog = false; });

            Button('提交处方')
              .type(ButtonType.Normal).layoutWeight(1).height(42)
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor('#FFFFFF').backgroundColor('#FA8C16').borderRadius(21)
              .onClick(() => { this.submitPrescription(); });
          }
          .width('100%')
        }
        .width('88%')
      .height('85%')
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .shadow({ radius: 20, color: '#00000030', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
  }
}
