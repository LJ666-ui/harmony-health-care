import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { ToastUtil } from '../common/utils/ToastUtil';

interface FollowUpItem {
  id: number;
  patientId: number;
  type: string;
  title: string;
  hospitalName?: string;
  department?: string;
  doctorName?: string;
  followUpDate?: string;
  followUpTime?: string;
  status: string;
  notes?: string;
}

interface PatientItem {
  id: number;
  name: string;
}

@Entry
@Component
struct DoctorFollowUpPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State followUps: FollowUpItem[] = [];
  @State patients: PatientItem[] = [];
  @State selectedPatientId: number = 0;
  @State showAddDialog: boolean = false;

  @State newType: string = 'FOLLOW_UP';
  @State newTitle: string = '';
  @State newHospital: string = '';
  @State newDepartment: string = '';
  @State newDate: string = '';
  @State newTime: string = '09:00';
  @State newNotes: string = '';

  aboutToAppear(): void {
    const params: Object | undefined = router.getParams();
    if (params) {
      const p: Record<string, Object> = params as Record<string, Object>;
      if (p['patientId']) {
        this.selectedPatientId = p['patientId'] as number;
      }
      if (p['patientName']) {
        hilog.info(0x0000, 'DoctorFollowUpPage', `患者名称: ${p['patientName']}`);
      }
    }
    this.loadPatients();
    if (this.selectedPatientId > 0) {
      this.loadFollowUps();
    } else {
      this.isLoading = false;
    }
  }

  private async loadPatients(): Promise<void> {
    try {
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.DOCTOR_PATIENTS,
        undefined,
        undefined,
        { showLoading: false }
      );
      if (response.success && response.data) {
        const rawData: Object[] = Array.isArray(response.data) ? response.data as Object[] : [];
        this.patients = rawData.map((item: Object): PatientItem => {
          const raw: Record<string, Object> = item as Record<string, Object>;
          const nameValue: Object | undefined = raw['otherUserName'];
          const idValue: Object | undefined = raw['otherUserId'];
          return { id: typeof idValue === 'number' ? idValue : Number(idValue || 0), name: typeof nameValue === 'string' ? nameValue : '' };
        });
        if (this.patients.length > 0 && this.selectedPatientId === 0) {
          this.selectedPatientId = this.patients[0].id;
          this.loadFollowUps();
        }
      }
    } catch (error) {
      hilog.error(0x0000, 'DoctorFollowUpPage', `loadPatients error: ${JSON.stringify(error)}`);
    }
  }

  private async loadFollowUps(): Promise<void> {
    this.isLoading = true;
    try {
      hilog.info(0x0000, 'DoctorFollowUpPage', `加载复诊列表，patientId: ${this.selectedPatientId}`);

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        `${ApiConstants.FOLLOW_UP_LIST}?userId=${this.selectedPatientId}`,
        undefined,
        undefined,
        { showLoading: false }
      );

      if (response.success && response.data) {
        const rawData: Object[] = Array.isArray(response.data) ? response.data as Object[] : [];
        this.followUps = rawData.map((item: Object): FollowUpItem => {
          const raw: Record<string, Object> = item as Record<string, Object>;
          return {
            id: Number(raw['id'] || 0),
            patientId: Number(raw['patientId'] || 0),
            type: String(raw['type'] || 'FOLLOW_UP'),
            title: String(raw['title'] || ''),
            hospitalName: raw['hospitalName'] ? String(raw['hospitalName']) : undefined,
            department: raw['department'] ? String(raw['department']) : undefined,
            doctorName: raw['doctorName'] ? String(raw['doctorName']) : undefined,
            followUpDate: raw['followUpDate'] ? String(raw['followUpDate']) : undefined,
            followUpTime: raw['followUpTime'] ? String(raw['followUpTime']) : undefined,
            status: String(raw['status'] || 'UPCOMING'),
            notes: raw['notes'] ? String(raw['notes']) : undefined
          };
        });
        hilog.info(0x0000, 'DoctorFollowUpPage', `加载到 ${this.followUps.length} 条复诊记录`);
      } else {
        ToastUtil.showError(response.message || '加载失败');
      }
    } catch (error) {
      hilog.error(0x0000, 'DoctorFollowUpPage', `loadFollowUps error: ${JSON.stringify(error)}`);
      ToastUtil.showError('加载复诊列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  private async addFollowUp(): Promise<void> {
    if (!this.newTitle.trim()) {
      ToastUtil.showError('请输入标题');
      return;
    }
    if (!this.newDate) {
      ToastUtil.showError('请选择日期');
      return;
    }

    try {
      const body: Record<string, string | number> = {
        'patientId': this.selectedPatientId,
        'type': this.newType,
        'title': this.newTitle,
        'hospitalName': this.newHospital,
        'department': this.newDepartment,
        'doctorName': AppStorage.get('doctorName') as string || '',
        'followUpDate': this.newDate,
        'followUpTime': this.newTime,
        'notes': this.newNotes,
        'status': 'UPCOMING'
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.FOLLOW_UP_CREATE,
        body,
        undefined,
        { showLoading: true, loadingText: '正在添加...' }
      );

      if (response.success) {
        ToastUtil.showInfo('添加成功');
        this.showAddDialog = false;
        this.resetForm();
        this.loadFollowUps();
      } else {
        ToastUtil.showError(response.message || '添加失败');
      }
    } catch (error) {
      hilog.error(0x0000, 'DoctorFollowUpPage', `addFollowUp error: ${JSON.stringify(error)}`);
      ToastUtil.showError('添加失败');
    }
  }

  private async updateStatus(id: number, status: string): Promise<void> {
    try {
      const body: Record<string, string> = { 'status': status };
      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.PUT,
        `${ApiConstants.FOLLOW_UP_STATUS}/${id}/status`,
        body,
        undefined,
        { showLoading: false }
      );

      if (response.success) {
        ToastUtil.showInfo('状态已更新');
        this.loadFollowUps();
      } else {
        ToastUtil.showError(response.message || '更新失败');
      }
    } catch (error) {
      ToastUtil.showError('更新状态失败');
    }
  }

  private resetForm(): void {
    this.newType = 'FOLLOW_UP';
    this.newTitle = '';
    this.newHospital = '';
    this.newDepartment = '';
    this.newDate = '';
    this.newTime = '09:00';
    this.newNotes = '';
  }

  private getTypeText(type: string): string {
    const map: Record<string, string> = { 'FOLLOW_UP': '复诊', 'CHECKUP': '检查', 'EXAM': '体检', 'SURGERY': '手术' };
    return map[type] || type;
  }

  private getStatusText(status: string): string {
    const map: Record<string, string> = { 'UPCOMING': '待就诊', 'COMPLETED': '已完成', 'CANCELLED': '已取消', 'OVERDUE': '已过期' };
    return map[status] || status;
  }

  private getStatusColor(status: string): string {
    const map: Record<string, string> = { 'UPCOMING': '#F39C12', 'COMPLETED': '#27AE60', 'CANCELLED': '#95A5A6', 'OVERDUE': '#E74C3C' };
    return map[status] || '#95A5A6';
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Row() {
            Button() {
              Image($r('sys.media.ohos_ic_public_arrow_left')).width(24).height(24).fillColor('#333333');
            }.type(ButtonType.Normal).backgroundColor(Color.Transparent).onClick(() => { router.back(); });

            Text('复诊管理').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333').layoutWeight(1).textAlign(TextAlign.Center);

            Button('+ 添加').fontSize(14).fontColor('#1677FF').backgroundColor(Color.Transparent)
              .onClick(() => { this.showAddDialog = true; });
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 });

          if (this.patients.length > 0) {
            Row() {
              Text('选择患者：').fontSize(14).fontColor('#666666');
              List({ space: 8 }) {
                ForEach(this.patients, (patient: PatientItem) => {
                  ListItem() {
                    Text(patient.name)
                      .fontSize(13)
                      .fontColor(this.selectedPatientId === patient.id ? '#FFFFFF' : '#333333')
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .backgroundColor(this.selectedPatientId === patient.id ? '#1677FF' : '#F5F5F5')
                      .borderRadius(16)
                      .onClick(() => {
                        this.selectedPatientId = patient.id;
                        this.loadFollowUps();
                      });
                  }
                })
              }
              .listDirection(Axis.Horizontal)
              .layoutWeight(1)
              .scrollBar(BarState.Off);
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('#FFFFFF');
          }

          if (this.isLoading) {
            Loading()
          } else if (this.followUps.length === 0) {
            Column() {
              Text('📋').fontSize(64).margin({ bottom: 16 });
              Text('暂无复诊安排').fontSize(18).fontColor('#999999').margin({ bottom: 8 });
              Text('点击右上角 + 为患者添加复诊计划').fontSize(14).fontColor('#BBBBBB');
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center);
          } else {
            Scroll() {
              Column({ space: 12 }) {
                Text(`共 ${this.followUps.length} 条记录`).fontSize(14).fontColor('#666666').width('95%').margin({ top: 8 });

                ForEach(this.followUps, (item: FollowUpItem) => {
                  Column() {
                    Row() {
                      Column({ space: 4 }) {
                        Text(item.title).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#333333');
                        Row({ space: 8 }) {
                          Text(this.getTypeText(item.type)).fontSize(11).fontColor('#FFFFFF').backgroundColor('#3498DB').padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(4);
                          Text(this.getStatusText(item.status)).fontSize(11).fontColor('#FFFFFF').backgroundColor(this.getStatusColor(item.status)).padding({ left: 8, right: 8, top: 2, bottom: 2 }).borderRadius(4);
                        }
                      }.alignItems(HorizontalAlign.Start).layoutWeight(1);

                      Column({ space: 4 }) {
                        Text(item.followUpDate || '-').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#F39C12');
                        if (item.followUpTime) { Text(item.followUpTime).fontSize(12).fontColor('#666666'); }
                      }.alignItems(HorizontalAlign.End);
                    }
                    .width('100%');

                    Divider().color('#E0E0E0').margin({ top: 10, bottom: 10 });

                    Column({ space: 6 }) {
                      if (item.hospitalName) { Row() { Text('🏥 ').fontSize(12); Text(item.hospitalName).fontSize(12).fontColor('#666'); }.width('100%'); }
                      if (item.department) { Row() { Text('🔬 ').fontSize(12); Text(item.department).fontSize(12).fontColor('#666'); }.width('100%'); }
                      if (item.notes) { Row() { Text('📝 ').fontSize(12); Text(item.notes).fontSize(12).fontColor('#E74C3C').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }); }.width('100%'); }
                    }.width('100%').alignItems(HorizontalAlign.Start);

                    if (item.status === 'UPCOMING') {
                      Row({ space: 8 }) {
                        Button('标记完成').height(30).fontSize(12).fontColor('#27AE60').backgroundColor('#F0FFF0').borderRadius(6)
                          .onClick(() => { this.updateStatus(item.id, 'COMPLETED'); });
                        Button('取消').height(30).fontSize(12).fontColor('#999').backgroundColor('#F5F5F5').borderRadius(6)
                          .onClick(() => { this.updateStatus(item.id, 'CANCELLED'); });
                      }.width('100%').margin({ top: 10 });
                    }
                  }
                  .width('95%')
                  .padding(14)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
                });
              }
              .width('100%')
              .padding({ bottom: 20 });
            }
            .layoutWeight(1)
            .scrollBar(BarState.Auto);
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5');
      }
      .width('100%')
      .height('100%');

      if (this.showAddDialog) {
        Column() {
          Blank();

          Column({ space: 16 }) {
            Row() {
              Text('添加复诊安排').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#333333').layoutWeight(1);
              Button('✕').fontSize(18).fontColor('#999').backgroundColor(Color.Transparent)
                .onClick(() => { this.showAddDialog = false; this.resetForm(); });
            }
            .width('100%');

            Column({ space: 8 }) {
              Text('类型 *').fontSize(14).fontColor('#333333').width('100%');
              Row({ space: 8 }) {
                ForEach(['FOLLOW_UP', 'CHECKUP', 'EXAM'], (t: string) => {
                  Text(this.getTypeText(t)).fontSize(13).fontColor(this.newType === t ? '#FFFFFF' : '#666')
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .backgroundColor(this.newType === t ? '#1677FF' : '#F0F0F0').borderRadius(6)
                    .onClick(() => { this.newType = t; });
                });
              }
            }.width('100%').alignItems(HorizontalAlign.Start);

            TextInput({ placeholder: '标题（如：高血压复查）', text: this.newTitle }).width('100%').height(44)
              .onChange((value: string) => { this.newTitle = value; });

            TextInput({ placeholder: '医院名称（选填）', text: this.newHospital }).width('100%').height(44)
              .onChange((value: string) => { this.newHospital = value; });

            TextInput({ placeholder: '科室（选填）', text: this.newDepartment }).width('100%').height(44)
              .onChange((value: string) => { this.newDepartment = value; });

            TextInput({ placeholder: '日期（如：2026-05-20）', text: this.newDate }).width('100%').height(44)
              .onChange((value: string) => { this.newDate = value; });

            TextInput({ placeholder: '时间（如：09:00）', text: this.newTime }).width('100%').height(44)
              .onChange((value: string) => { this.newTime = value; });

            TextArea({ placeholder: '备注说明（选填）', text: this.newNotes }).width('100%').height(60)
              .onChange((value: string) => { this.newNotes = value; });

            Button('确认添加').width('100%').height(44).fontSize(16).fontColor('#FFFFFF').backgroundColor('#1677FF').borderRadius(8)
              .onClick(() => { this.addFollowUp(); });
          }
          .width('90%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 20, color: '#00000040', offsetX: 0, offsetY: -4 });

          Blank();
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .onClick(() => {});
      }
    }
    .width('100%')
    .height('100%');
  }
}
