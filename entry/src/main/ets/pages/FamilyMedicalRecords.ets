import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

interface MedicalRecordItem {
  id: number;
  userId: number;
  hospitalName?: string;
  department?: string;
  doctorName?: string;
  diagnosis?: string;
  treatmentPlan?: string;
  medicationAdvice?: string;
  visitTime?: string;
  createTime?: string;
}

@Entry
@Component
struct FamilyMedicalRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State records: MedicalRecordItem[] = [];
  @State relatedUserId: number = 0;

  aboutToAppear(): void {
    const familyInfo: Object | undefined = AppStorage.get('familyInfo');
    if (familyInfo) {
      const info: Record<string, Object> = familyInfo as Record<string, Object>;
      this.relatedUserId = info['userId'] as number || 0;
    }

    if (this.relatedUserId === 0) {
      ToastUtil.showError('未找到关联患者信息');
      return;
    }
    this.loadRecords();
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      console.info('正在加载患者病历，userId:', this.relatedUserId.toString());
      
      const response: BaseResponse<MedicalRecordItem[]> = await HttpUtil.get<MedicalRecordItem[]>('/medical/record/my', {
        'userId': this.relatedUserId
      } as Record<string, number>);

      if (response.success && response.data) {
        console.info('成功获取到', response.data.length.toString(), '条病历记录');
        this.records = response.data.map((item: MedicalRecordItem): MedicalRecordItem => {
          const record: MedicalRecordItem = {
            id: item.id || 0,
            userId: item.userId || 0,
            hospitalName: item.hospitalName || '未知医院',
            department: item.department || '',
            doctorName: item.doctorName || '未知医生',
            diagnosis: item.diagnosis || '待诊断',
            treatmentPlan: item.treatmentPlan || '',
            medicationAdvice: item.medicationAdvice || '',
            visitTime: item.visitTime || new Date().toISOString(),
            createTime: item.createTime || ''
          };
          return record;
        });
        
        if (this.records.length === 0) {
          ToastUtil.showInfo('暂无病历记录');
        }
      } else {
        console.error('获取病历失败:', response.message);
        ToastUtil.showError(response.message || '获取病历失败');
        this.records = [];
      }
    } catch (error) {
      console.error('加载病历异常:', error);
      ToastUtil.showError('加载病历失败，请检查网络连接');
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  private formatDate(dateStr: string): string {
    try {
      const date: Date = new Date(dateStr);
      const year: number = date.getFullYear();
      const month: number = date.getMonth() + 1;
      const day: number = date.getDate();
      return `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
    } catch (e) {
      return dateStr.substring(0, 10);
    }
  }

  private handleRecordClick(record: MedicalRecordItem): void {
    AlertDialog.show({
      title: '就诊详情',
      message:
`📅 就诊时间：${this.formatDate(record.visitTime || '')}
🏥 医院：${record.hospitalName || '未知'}
👨‍⚕️ 医生：${record.doctorName || '未知'}
🏥 科室：${record.department || '-'}

💊 诊断：
${record.diagnosis || '无'}

📋 治疗方案：
${record.treatmentPlan || '无'}

💉 用药建议：
${record.medicationAdvice || '无'}`,
      confirm: {
        value: '确定',
        action: () => {}
      }
    });
  }

  build() {
    Column() {
      Header({ title: '医疗记录', showBack: true })

      // 提示信息
      Text(`正在查看关联患者的病历（ID: ${this.relatedUserId}）`)
        .fontSize(12)
        .fontColor('#666666')
        .width('95%')
        .margin({ top: 10 })

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.records.length === 0) {
        Column() {
          Text('📋')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无病历记录')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('患者尚未有就诊记录')
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.records, (record: MedicalRecordItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(this.formatDate(record.visitTime || ''))
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#E74C3C')

                  Blank()

                  Text(`${record.hospitalName || '未知医院'}`)
                    .fontSize(13)
                    .fontColor('#3498DB')
                }
                .width('100%')

                Divider().width('100%').color('#E0E0E0').margin({ top: 8, bottom: 8 })

                Row() {
                  Text(`科室：${record.department || '-'}`)
                    .fontSize(13)
                    .fontColor('#666666')
                    .layoutWeight(1)

                  Text(`医生：${record.doctorName || '未知'}`)
                    .fontSize(13)
                    .fontColor('#666666')
                    .layoutWeight(1)
                }
                .width('100%')

                Text(`诊断：${record.diagnosis || '待诊断'}`)
                  .fontSize(14)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .margin({ top: 6 })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                this.handleRecordClick(record);
              })
            }
          })
        }
        .width('95%')
        .layoutWeight(1)
        .padding({ top: 12, bottom: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}