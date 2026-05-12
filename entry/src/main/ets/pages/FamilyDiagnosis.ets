import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface DiagnosisRecord {
  id: number;
  userId: number;
  hospitalName?: string;
  department?: string;
  doctorName?: string;
  diagnosis?: string;
  treatmentPlan?: string;
  visitTime?: string;
  createTime?: string;
}

@Entry
@Component
struct FamilyDiagnosis {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State records: DiagnosisRecord[] = [];
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
    this.loadDiagnoses();
  }

  private async loadDiagnoses(): Promise<void> {
    this.isLoading = true;
    try {
      console.info('正在加载患者诊断记录，userId:', this.relatedUserId.toString());
      
      const response: BaseResponse<DiagnosisRecord[]> = await HttpUtil.get<DiagnosisRecord[]>('/medical/record/my', {
        'userId': this.relatedUserId
      } as Record<string, number>);

      if (response.success && response.data) {
        console.info('成功获取到', response.data.length.toString(), '条诊断记录');
        // 只显示有诊断信息的记录
        this.records = response.data.filter((item: DiagnosisRecord) => 
          item.diagnosis && item.diagnosis.trim() !== ''
        ).map((item: DiagnosisRecord): DiagnosisRecord => ({
          id: item.id,
          userId: item.userId,
          hospitalName: item.hospitalName || '未知医院',
          department: item.department || '',
          doctorName: item.doctorName || '未知医生',
          diagnosis: item.diagnosis || '',
          treatmentPlan: item.treatmentPlan || '',
          visitTime: item.visitTime || '',
          createTime: item.createTime || ''
        }));
        
        if (this.records.length === 0) {
          ToastUtil.showInfo('暂无诊断记录');
        }
      } else {
        console.error('获取诊断失败:', response.message);
        ToastUtil.showError(response.message || '获取诊断失败');
        this.records = [];
      }
    } catch (error) {
      console.error('加载诊断异常:', error);
      ToastUtil.showError('加载诊断失败，请检查网络连接');
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  private formatDate(dateStr: string): string {
    try {
      return dateStr.substring(0, 10);
    } catch (e) {
      return dateStr;
    }
  }

  build() {
    Column() {
      Header({ title: '病情诊断', showBack: true })

      if (this.isLoading) {
        Loading()
      } else if (this.records.length === 0) {
        Column() {
          Text('🏥')
            .fontSize(64)
            .margin({ bottom: 16 })
          Text('暂无诊断记录')
            .fontSize(18)
            .fontColor('#999999')
            .margin({ bottom: 8 })
          Text('患者当前没有诊断信息')
            .fontSize(14)
            .fontColor('#BBBBBB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 12 }) {
            Text(`共 ${this.records.length} 条诊断记录`)
              .fontSize(14)
              .fontColor('#666666')
              .width('95%')
              .margin({ top: 8 })

            ForEach(this.records, (record: DiagnosisRecord) => {
              Column() {
                // 诊断标题
                Row() {
                  Text('📋 诊断记录')
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#E74C3C')

                  Blank()

                  if (record.visitTime) {
                    Text(this.formatDate(record.visitTime))
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                }
                .width('100%')

                Divider().color('#E0E0E0').margin({ top: 8, bottom: 8 })

                // 医院和医生信息
                Column({ space: 6 }) {
                  Row() {
                    Text('🏥 就诊医院:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(80)
                    Text(record.hospitalName || '未知')
                      .fontSize(13)
                      .fontColor('#333333')
                      .layoutWeight(1)
                  }
                  .width('100%')

                  if (record.department) {
                    Row() {
                      Text('🔬 科室:')
                        .fontSize(13)
                        .fontColor('#666666')
                        .width(80)
                      Text(record.department)
                        .fontSize(13)
                        .fontColor('#333333')
                    }
                    .width('100%')
                  }

                  Row() {
                    Text('👨‍⚕️ 主治医生:')
                      .fontSize(13)
                      .fontColor('#666666')
                      .width(80)
                    Text(record.doctorName || '未知')
                      .fontSize(13)
                      .fontColor('#333333')
                  }
                  .width('100%')
                }
                .width('100%')
                .margin({ bottom: 12 })

                // 诊断详情
                Column() {
                  Text('诊断结果')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1677FF')
                    .width('100%')
                    .margin({ bottom: 6 })

                  Text(record.diagnosis || '暂无诊断信息')
                    .fontSize(this.isElderMode ? 15 : 14)
                    .fontColor('#333333')
                    .width('100%')
                    .lineHeight(22)
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFF5F5')
                .borderRadius(8)

                // 治疗方案（如果有）
                if (record.treatmentPlan && record.treatmentPlan.trim() !== '') {
                  Column() {
                    Text('治疗方案')
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#27AE60')
                      .width('100%')
                      .margin({ bottom: 6 })

                    Text(record.treatmentPlan)
                      .fontSize(this.isElderMode ? 15 : 14)
                      .fontColor('#333333')
                      .width('100%')
                      .lineHeight(22)
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#F0FFF0')
                  .borderRadius(8)
                  .margin({ top: 8 })
                }
              }
              .width('95%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
            })
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
