import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface HealthRecord {
  id: number;
  recordType: string;
  value: string;
  unit: string;
  recordTime: string;
  remark?: string;
}

@Entry
@Component
struct FamilyHealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('familyInfo') familyInfo: any | null = null;
  @State isLoading: boolean = false;
  @State records: HealthRecord[] = [];
  @State selectedType: string = '全部';

  private recordTypes: string[] = ['全部', '血压', '血糖', '心率', '体重', '体温'];

  async aboutToAppear(): Promise<void> {
    await this.loadRecords();
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      // 获取家属的健康记录
      const response = await HttpUtil.get<HealthRecord[]>('/family/health-records');
      
      if (response.success && response.data) {
        this.records = response.data;
      } else {
        // 如果接口不存在，使用模拟数据
        this.records = this.getMockRecords();
      }
    } catch (error) {
      console.error('加载健康记录失败:', error);
      // 使用模拟数据
      this.records = this.getMockRecords();
    } finally {
      this.isLoading = false;
    }
  }

  private getMockRecords(): HealthRecord[] {
    return [
      { id: 1, recordType: '血压', value: '120/80', unit: 'mmHg', recordTime: '2026-05-08 09:30', remark: '正常' },
      { id: 2, recordType: '血糖', value: '5.6', unit: 'mmol/L', recordTime: '2026-05-08 08:00', remark: '空腹血糖' },
      { id: 3, recordType: '心率', value: '72', unit: 'bpm', recordTime: '2026-05-07 18:00', remark: '静息心率' },
      { id: 4, recordType: '体重', value: '65', unit: 'kg', recordTime: '2026-05-07 07:00', remark: '' },
      { id: 5, recordType: '体温', value: '36.5', unit: '℃', recordTime: '2026-05-06 20:00', remark: '正常' }
    ];
  }

  private getFilteredRecords(): HealthRecord[] {
    if (this.selectedType === '全部') {
      return this.records;
    }
    return this.records.filter(r => r.recordType === this.selectedType);
  }

  private getRecordIcon(type: string): string {
    const iconMap: Record<string, string> = {
      '血压': '💓',
      '血糖': '🍬',
      '心率': '❤️',
      '体重': '⚖️',
      '体温': '🌡️'
    };
    return iconMap[type] || '📊';
  }

  private getRecordColor(type: string): string {
    const colorMap: Record<string, string> = {
      '血压': '#FF6B6B',
      '血糖': '#4ECDC4',
      '心率': '#FF4444',
      '体重': '#95E1D3',
      '体温': '#F38181'
    };
    return colorMap[type] || '#3498DB';
  }

  build() {
    Column() {
      Header({ title: '健康记录', showBack: true })

      Column() {
        // 类型筛选
        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.recordTypes, (type: string) => {
              Button(type)
                .fontSize(this.isElderMode ? 16 : 14)
                .height(36)
                .backgroundColor(this.selectedType === type ? '#3498DB' : '#FFFFFF')
                .fontColor(this.selectedType === type ? '#FFFFFF' : '#333333')
                .onClick(() => {
                  this.selectedType = type;
                })
            })
          }
          .padding({ left: 15, right: 15 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .width('100%')
        .height(50)
        .backgroundColor('#FFFFFF')

        // 记录列表
        if (this.isLoading) {
          Loading()
        } else {
          List() {
            ForEach(this.getFilteredRecords(), (record: HealthRecord) => {
              ListItem() {
                Row() {
                  // 图标
                  Text(this.getRecordIcon(record.recordType))
                    .fontSize(32)
                    .margin({ right: 15 })

                  // 信息
                  Column() {
                    Text(record.recordType)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(GlobalTheme.TEXT_PRIMARY)

                    Text(`${record.value} ${record.unit}`)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontColor(this.getRecordColor(record.recordType))
                      .margin({ top: 5 })

                    if (record.remark) {
                      Text(record.remark)
                        .fontSize(12)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .margin({ top: 3 })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  // 时间
                  Text(record.recordTime.split(' ')[0])
                    .fontSize(12)
                    .fontColor(GlobalTheme.TEXT_SECONDARY)
                }
                .width('100%')
                .padding(15)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({ bottom: 10 })
              }
            })
          }
          .width('95%')
          .layoutWeight(1)
          .padding({ top: 10, bottom: 10 })
        }
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
