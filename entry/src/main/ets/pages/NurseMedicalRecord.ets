import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface NursingRecord {
  id: number;
  patientId: number;
  patientName?: string;
  nurseId: number;
  nurseName?: string;
  recordType: number;
  recordContent: string;
  remark?: string;
  vitalSigns?: string;
  careTime: string;
  createTime: string;
  updateTime: string;
  isDeleted: number;
}

interface NurseInfoForRecord {
  id: number;
  name: string;
  userId?: number;
}

interface CreateNursingRecordRequest {
  patientId: number;
  recordType: number;
  recordContent: string;
  remark?: string;
  vitalSigns?: string;
}

@Entry
@Component
struct NurseMedicalRecord {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @StorageLink('nurseInfo') nurseInfo: NurseInfoForRecord | null = null;
  @State isLoading: boolean = true;
  @State records: NursingRecord[] = [];
  @State showAddDialog: boolean = false;
  @State selectedPatientId: number = 0;
  @State newRecordType: number = 1;
  @State newRecordContent: string = '';
  @State newRemark: string = '';
  @State recordTypes: string[] = ['生命体征监测', '用药护理', '伤口护理', '日常护理', '术后护理', '康复护理'];

  private getNurseId(): number {
    // 优先使用nurseInfo中的id
    if (this.nurseInfo !== null && this.nurseInfo.id !== undefined) {
      return this.nurseInfo.id;
    }
    // 其次使用userId
    return this.currentUserId;
  }

  async aboutToAppear(): Promise<void> {
    console.info('[NurseMedicalRecord] 初始化，userId:', this.currentUserId, 'nurseInfo:', JSON.stringify(this.nurseInfo));
    
    const params = router.getParams();
    if (params !== null && params !== undefined) {
      const paramRecord = params as Record<string, Object>;
      const patientIdParam = paramRecord['patientId'];
      if (patientIdParam !== null && patientIdParam !== undefined) {
        this.selectedPatientId = patientIdParam as number;
      }
    }

    await this.loadRecords();
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const nurseId = this.getNurseId();
      console.info('[NurseMedicalRecord] 查询护士ID:', nurseId);
      
      if (nurseId <= 0) {
        console.warn('NurseMedicalRecord - 护士ID无效，尝试加载所有记录');
        // 如果护士ID无效，尝试加载所有记录
        const response = await HttpUtil.get<NursingRecord[]>(
          ApiConstants.NURSING_RECORD_LIST
        );
        
        if (response.success && response.data !== null && response.data !== undefined) {
          this.records = response.data.sort((a: NursingRecord, b: NursingRecord) =>
            new Date(b.careTime).getTime() - new Date(a.careTime).getTime()
          );
        } else {
          this.records = [];
        }
      } else {
        const response = await HttpUtil.get<NursingRecord[]>(
          `${ApiConstants.NURSING_RECORD_BY_NURSE}${nurseId}`
        );

        console.info('[NurseMedicalRecord] 查询结果:', JSON.stringify(response));

        if (response.success && response.data !== null && response.data !== undefined) {
          this.records = response.data.sort((a: NursingRecord, b: NursingRecord) =>
            new Date(b.careTime).getTime() - new Date(a.careTime).getTime()
          );
        } else {
          this.records = [];
        }
      }
      
      console.info('[NurseMedicalRecord] 加载记录数:', this.records.length);
    } catch (error) {
      console.error('加载护理记录失败:', error);
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  private async addRecord(): Promise<void> {
    if (!this.newRecordContent || this.newRecordContent.trim() === '') {
      ToastUtil.showError('请填写记录内容');
      return;
    }

    if (this.selectedPatientId === 0) {
      ToastUtil.showError('请选择患者');
      return;
    }

    try {
      const requestBody: CreateNursingRecordRequest = {
        patientId: this.selectedPatientId,
        recordType: this.newRecordType,
        recordContent: this.newRecordContent,
        remark: this.newRemark
      };

      console.info('[NurseMedicalRecord] 保存护理记录，患者ID:', this.selectedPatientId, '护士ID:', this.currentUserId);

      const response = await HttpUtil.post<NursingRecord>(
        ApiConstants.NURSING_RECORD_CREATE,
        requestBody,
        { skipAuth: false }
      );

      console.info('[NurseMedicalRecord] 保存结果:', JSON.stringify(response));

      if (response.success) {
        ToastUtil.showSuccess('记录添加成功');
        this.showAddDialog = false;
        this.newRecordType = 1;
        this.newRecordContent = '';
        this.newRemark = '';
        this.selectedPatientId = 0;
        await this.loadRecords();
      } else {
        ToastUtil.showError(response.message !== undefined ? response.message : '添加失败');
      }
    } catch (error) {
      console.error('添加护理记录失败:', error);
      ToastUtil.showError('添加失败');
    }
  }

  private formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
  }

  private getRecordTypeColor(type: number): string {
    const colors: Record<number, string> = {
      1: '#3498DB',
      2: '#27AE60',
      3: '#E74C3C',
      4: '#F39C12',
      5: '#9B59B6',
      6: '#16A085'
    };
    return colors[type] || '#95A5A6';
  }

  private getRecordTypeName(type: number): string {
    return this.recordTypes[type - 1] || '其他';
  }

  @Builder
  addRecordSheetContent(): void {
    Column({ space: 16 }) {
      Text('新增护理记录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Column({ space: 8 }) {
        Text('患者ID')
          .fontSize(14)
          .width('100%')

        TextInput({ placeholder: '请输入患者ID', text: this.selectedPatientId > 0 ? String(this.selectedPatientId) : '' })
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.selectedPatientId = parseInt(value) || 0;
          })
      }
      .width('100%')

      Column({ space: 12 }) {
        Text('记录类型')
          .fontSize(14)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.recordTypes, (type: string, index: number) => {
            Button(type)
              .fontSize(12)
              .height(32)
              .margin({ right: 8, bottom: 8 })
              .fontColor(this.newRecordType === (index + 1) ? '#FFFFFF' : '#3498DB')
              .backgroundColor(this.newRecordType === (index + 1) ? '#3498DB' : '#EBF5FB')
              .borderRadius(6)
              .onClick(() => {
                this.newRecordType = index + 1;
              })
          })
        }
        .width('100%')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('记录内容')
          .fontSize(14)
          .width('100%')

        TextArea({ placeholder: '请输入护理记录内容', text: this.newRecordContent })
          .width('100%')
          .height(80)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newRecordContent = value;
          })
      }
      .width('100%')

      Column({ space: 8 }) {
        Text('备注（可选）')
          .fontSize(14)
          .width('100%')

        TextInput({ placeholder: '备注信息', text: this.newRemark })
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newRemark = value;
          })
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
          .onClick(() => {
            this.showAddDialog = false;
          })

        Button('保存')
          .layoutWeight(1)
          .height(44)
          .fontColor('#FFFFFF')
          .backgroundColor('#3498DB')
          .borderRadius(8)
          .onClick(() => {
            this.addRecord();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  build() {
    Column() {
      Header({ title: '护理记录', showBack: true })

      Column({ space: 12 }) {
        Row() {
          Text(`共 ${this.records.length} 条记录`)
            .fontSize(14)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .layoutWeight(1)

          Button('+ 新增记录')
            .fontSize(14)
            .height(36)
            .fontColor('#FFFFFF')
            .backgroundColor('#3498DB')
            .borderRadius(8)
            .onClick(() => {
              this.showAddDialog = true;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#3498DB')
            Text('加载中...')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.records.length === 0) {
          Column() {
            Text('📝')
              .fontSize(48)
            Text('暂无护理记录')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 12 })
            Text('点击右上角添加新记录')
              .fontSize(14)
              .fontColor('#CCCCCC')
              .margin({ top: 8 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.records, (record: NursingRecord) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(this.getRecordTypeName(record.recordType))
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.getRecordTypeColor(record.recordType))
                      .borderRadius(4)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })

                    Blank()

                    Text(this.formatDate(record.careTime))
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .width('100%')

                  if (record.patientName) {
                    Text(`患者：${record.patientName}`)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ top: 8 })
                  }

                  Text(record.recordContent)
                    .fontSize(this.isElderMode ? 16 : 14)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                    .margin({ top: 8 })
                    .width('100%')

                  if (record.vitalSigns) {
                    Text(`生命体征：${record.vitalSigns}`)
                      .fontSize(13)
                      .fontColor('#3498DB')
                      .margin({ top: 8 })
                  }

                  if (record.remark) {
                    Text(`备注：${record.remark}`)
                      .fontSize(13)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ top: 8 })
                  }

                  Text(`记录人：${record.nurseName || '护士'}`)
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 8 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
                .alignItems(HorizontalAlign.Start)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .bindSheet(this.showAddDialog, this.addRecordSheetContent, {
      height: 480,
      backgroundColor: Color.Transparent,
      dragBar: true,
      onDisappear: () => {
        this.showAddDialog = false;
      }
    })
  }
}
