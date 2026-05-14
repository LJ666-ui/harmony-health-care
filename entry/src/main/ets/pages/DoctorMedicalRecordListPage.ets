import { router } from '@kit.ArkUI';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { MedicalRecordFormData, MedicalRecordFormDataHelper } from '../models/DoctorPatientModels';

interface AppointmentPatient {
  appointmentId: number;
  userId: number;
  userName: string;
  scheduleDate: string;
  schedulePeriod: number;
  periodText: string;
  status: number;
}

interface MedicalRecordItem {
  id: number;
  patientId: number;
  patientName: string;
  diagnosis: string;
  visitDate: string;
  chiefComplaint: string;
  createTime: string;
}

@Entry
@Component
struct DoctorMedicalRecordListPage {
  @StorageLink('userId') currentUserId: number = 0;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State patients: AppointmentPatient[] = [];
  @State records: MedicalRecordItem[] = [];
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State selectedPatientId: number = 0;
  @State selectedPatientName: string = '';
  @State showCreateDialog: boolean = false;
  @State currentView: 'patients' | 'records' = 'patients';

  private newRecord: MedicalRecordFormData = new MedicalRecordFormData();

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
        const today = new Date();
        const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;

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

  async loadRecordsForPatient(patientId: number): Promise<void> {
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
        ApiConstants.MEDICAL_RECORD_PAGE,
        undefined,
        params as Object,
        { showLoading: false }
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        const rawRecords: Object[] = data['records'] as Object[] || data['list'] as Object[] || [];
        const arr: Object[] = Array.isArray(rawRecords) ? rawRecords : [data];
        const list: MedicalRecordItem[] = [];

        for (let i = 0; i < arr.length; i++) {
          const raw = arr[i] as Record<string, Object>;
          let dateStr = String(raw['visitDate'] || raw['recordTime'] || raw['createTime'] || '');
          if (dateStr && dateStr.length > 10) dateStr = dateStr.substring(0, 10);

          list.push({
            id: Number(raw['id'] || 0),
            patientId: Number(raw['patientId'] || raw['user_id'] || raw['userId'] || 0),
            patientName: String(raw['patientName'] || ''),
            diagnosis: String(raw['diagnosis'] || ''),
            visitDate: dateStr,
            chiefComplaint: String(raw['chiefComplaint'] || ''),
            createTime: String(raw['createTime'] || '')
          });
        }
        this.records = list;
      }
    } catch (error) {
      console.error('[病历管理] 加载病历失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  selectPatient(patient: AppointmentPatient): void {
    this.selectedPatientId = patient.userId;
    this.selectedPatientName = patient.userName;
    this.currentView = 'records';
    this.loadRecordsForPatient(patient.userId);
  }

  backToPatients(): void {
    this.currentView = 'patients';
    this.records = [];
    this.selectedPatientId = 0;
    this.selectedPatientName = '';
  }

  openCreateDialog(): void {
    this.newRecord = new MedicalRecordFormData();
    this.newRecord.patientId = this.selectedPatientId;
    this.newRecord.patientName = this.selectedPatientName;
    this.newRecord.doctorId = this.currentUserId;
    const today = new Date();
    this.newRecord.visitDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
    this.showCreateDialog = true;
  }

  async submitRecord(): Promise<void> {
    if (!this.newRecord.chiefComplaint) {
      ToastUtil.showError('请填写主诉');
      return;
    }
    if (!this.newRecord.diagnosis) {
      ToastUtil.showError('请填写诊断');
      return;
    }

    try {
      const recordData = MedicalRecordFormDataHelper.toJson(this.newRecord);
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.MEDICAL_RECORD_CREATE,
        recordData as Object,
        undefined,
        { showLoading: true, loadingText: '正在保存...' }
      );

      if (response.success) {
        ToastUtil.showSuccess('病历创建成功');
        this.showCreateDialog = false;
        this.loadRecordsForPatient(this.selectedPatientId);
      } else {
        ToastUtil.showError(response.message || '创建失败');
      }
    } catch (error) {
      ToastUtil.showError('网络异常，请重试');
    }
  }

  viewRecordDetail(record: MedicalRecordItem): void {
    router.pushUrl({
      url: 'pages/MedicalRecord',
      params: {
        recordId: record.id,
        patientId: record.patientId,
        patientName: record.patientName,
        fromDoctor: true
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
            if (this.currentView === 'records') {
              this.backToPatients();
            } else {
              router.back();
            }
          });

          Text(this.currentView === 'records' ? `${this.selectedPatientName} 的病历` : '病历管理')
            .fontSize(this.isElderMode ? 20 : 18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);

          if (this.currentView === 'records') {
            Text('+ 开具')
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor('#1677FF')
              .fontWeight(FontWeight.Medium)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#E6F4FF')
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
          this.buildRecordsView();
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
            .type(ButtonType.Normal).borderRadius(20).backgroundColor('#1677FF')
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
          Text('有患者挂号后可在此开具新病历')
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
                      .fontColor('#1677FF')
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor('#E6F4FF')
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
                  Text('\u{1F4BC} 查看并开具新病历')
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#1677FF');
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
  buildRecordsView() {
    Column() {
      Row() {
        Text(`共 ${this.records.length} 条病历`)
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

      if (this.isLoading && this.records.length === 0) {
        Column() { Text('加载中...').fontSize(16).fontColor('#999999'); }
          .layoutWeight(1).justifyContent(FlexAlign.Center);
      } else if (this.records.length === 0) {
        Column() {
          Text('\u{1F4DD}').fontSize(52).margin({ bottom: 12 });
          Text('暂无病历记录')
            .fontSize(this.isElderMode ? 18 : 16)
            .fontWeight(FontWeight.Bold).fontColor('#333333');
          Text('点击右上角「+ 开具」为该患者创建新病历')
            .fontSize(13).fontColor('#999999').textAlign(TextAlign.Center).width('75%').margin({ top: 8 });
        }.layoutWeight(1).justifyContent(FlexAlign.Center);
      } else {
        List({ space: 10 }) {
          ForEach(this.records, (record: MedicalRecordItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(record.diagnosis || '未填诊断')
                    .fontSize(this.isElderMode ? 17 : 15)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis });
                  Blank();
                  Text(record.visitDate)
                    .fontSize(13).fontColor('#999999');
                }
                .width('100%')

                if (record.chiefComplaint) {
                  Text('主诉：' + record.chiefComplaint)
                    .fontSize(13).fontColor('#666666')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 6 })
                    .width('100%');
                }

                Row() {
                  Text('\u{1F441} 查看详情')
                    .fontSize(this.isElderMode ? 14 : 12).fontColor('#1677FF');
                  Blank();
                  Text('>').fontSize(16).fontColor('#CCCCCC');
                }
                .width('100%').margin({ top: 8 }).padding({ top: 8 })
                .border({ width: { top: 1 }, color: '#F0F0F0' })
              }
              .width('100%').padding(16)
              .backgroundColor('#FFFFFF').borderRadius(12)
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => { this.viewRecordDetail(record); });
            }
          }, (r: MedicalRecordItem) => '' + r.id)
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

      Column({ space: 14 }) {
        Text('开具新病历')
          .fontSize(this.isElderMode ? 20 : 18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Center)

        Text(`患者：${this.newRecord.patientName}`)
          .fontSize(14).fontColor('#666666').alignSelf(ItemAlign.Start)

        TextInput({ text: this.newRecord.chiefComplaint, placeholder: '请输入主诉（必填）' })
          .width('100%').height(44)
          .fontSize(this.isElderMode ? 16 : 14)
          .onChange((v: string) => { this.newRecord.chiefComplaint = v; })

        TextArea({ text: this.newRecord.presentIllness, placeholder: '现病史' })
          .width('100%').height(70)
          .fontSize(this.isElderMode ? 15 : 13)
          .onChange((v: string) => { this.newRecord.presentIllness = v; })

        TextInput({ text: this.newRecord.pastHistory, placeholder: '既往史' })
          .width('100%').height(42)
          .fontSize(this.isElderMode ? 15 : 13)
          .onChange((v: string) => { this.newRecord.pastHistory = v; })

        TextInput({ text: this.newRecord.diagnosis, placeholder: '诊断（必填）' })
          .width('100%').height(44)
          .fontSize(this.isElderMode ? 16 : 14)
          .onChange((v: string) => { this.newRecord.diagnosis = v; })

        TextArea({ text: this.newRecord.treatmentPlan, placeholder: '治疗方案' })
          .width('100%').height(70)
          .fontSize(this.isElderMode ? 15 : 13)
          .onChange((v: string) => { this.newRecord.treatmentPlan = v; })

        TextArea({ text: this.newRecord.advice, placeholder: '医嘱' })
          .width('100%').height(60)
          .fontSize(this.isElderMode ? 15 : 13)
          .onChange((v: string) => { this.newRecord.advice = v; })

        Row({ space: 12 }) {
          Button('取消')
            .type(ButtonType.Normal).layoutWeight(1).height(42)
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#666666').backgroundColor('#F5F5F5').borderRadius(21)
            .onClick(() => { this.showCreateDialog = false; });

          Button('提交病历')
            .type(ButtonType.Normal).layoutWeight(1).height(42)
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#FFFFFF').backgroundColor('#1677FF').borderRadius(21)
            .onClick(() => { this.submitRecord(); });
        }
        .width('100%')
      }
      .width('88%')
      .height('85%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .shadow({ radius: 20, color: '#00000030', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
  }
}
