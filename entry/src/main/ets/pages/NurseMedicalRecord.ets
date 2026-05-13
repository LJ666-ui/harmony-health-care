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
  recordType: string;
  recordContent: string;
  recordTime: string;
  vitalSigns?: string;
  notes?: string;
  createTime: string;
}

interface NurseInfoForRecord {
  name: string;
}

interface CreateNursingRecordRequest {
  nurseId: number;
  nurseName: string;
  recordType: string;
  recordContent: string;
  recordTime: string;
  notes: string;
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
  @State newRecordType: string = '';
  @State newRecordContent: string = '';
  @State newNotes: string = '';

  async aboutToAppear(): Promise<void> {
    const settings = SettingsUtil.getInstance();
    const isLoggedIn = await settings.isNurseLoggedIn();
    if (!isLoggedIn) {
      ToastUtil.showError('请先登录');
      router.replaceUrl({ url: 'pages/NurseLogin' });
      return;
    }

    await this.loadRecords();
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<NursingRecord[]>(
        `${ApiConstants.MEDICAL_RECORD_PAGE}?nurseId=${this.currentUserId}`
      );

      if (response.success && response.data !== null && response.data !== undefined) {
        this.records = response.data.sort((a: NursingRecord, b: NursingRecord) =>
          new Date(b.recordTime).getTime() - new Date(a.recordTime).getTime()
        );
      } else {
        this.records = [];
      }
    } catch (error) {
      console.error('加载护理记录失败:', error);
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  private async addRecord(): Promise<void> {
    if (!this.newRecordType || !this.newRecordContent) {
      ToastUtil.showError('请填写记录类型和内容');
      return;
    }

    try {
      const nurseName = this.nurseInfo !== null ? this.nurseInfo.name : '护士';
      const requestBody: CreateNursingRecordRequest = {
        nurseId: this.currentUserId,
        nurseName: nurseName,
        recordType: this.newRecordType,
        recordContent: this.newRecordContent,
        recordTime: new Date().toISOString(),
        notes: this.newNotes
      };

      const response = await HttpUtil.post<NursingRecord>(
        ApiConstants.MEDICAL_RECORD_CREATE,
        requestBody
      );

      if (response.success) {
        ToastUtil.showSuccess('记录添加成功');
        this.showAddDialog = false;
        this.newRecordType = '';
        this.newRecordContent = '';
        this.newNotes = '';
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

  private getRecordTypeColor(type: string): string {
    const colors: Record<string, string> = {
      '生命体征监测': '#3498DB',
      '用药护理': '#27AE60',
      '伤口护理': '#E74C3C',
      '康复训练': '#9B59B6',
      '日常护理': '#F39C12',
      '其他': '#95A5A6'
    };
    return colors[type] || '#95A5A6';
  }

  @Builder
  addRecordSheetContent(): void {
    Column({ space: 16 }) {
      Text('新增护理记录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Column({ space: 12 }) {
        Text('记录类型')
          .fontSize(14)
          .width('100%')

        Row({ space: 8 }) {
          ForEach(['生命体征监测', '用药护理', '伤口护理', '日常护理'], (type: string) => {
            Button(type)
              .fontSize(12)
              .height(32)
              .fontColor(this.newRecordType === type ? '#FFFFFF' : '#3498DB')
              .backgroundColor(this.newRecordType === type ? '#3498DB' : '#EBF5FB')
              .borderRadius(6)
              .onClick(() => {
                this.newRecordType = type;
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

        TextInput({ placeholder: '备注信息', text: this.newNotes })
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.newNotes = value;
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
                    Text(record.recordType)
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.getRecordTypeColor(record.recordType))
                      .borderRadius(4)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })

                    Blank()

                    Text(this.formatDate(record.recordTime))
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

                  if (record.notes) {
                    Text(`备注：${record.notes}`)
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
