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
  userId?: number;
}

interface FamilyInfo {
  id: number;
  name: string;
  phone: string;
  relation: string;
  userId: number;
  isEmergencyContact: number;
}

@Entry
@Component
struct FamilyHealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('familyInfo') familyInfo: object | null = null;
  @State isLoading: boolean = false;
  @State records: HealthRecord[] = [];
  @State selectedType: string = '全部';
  @State relatedUserId: number = 0;

  private recordTypes: string[] = ['全部', '血压', '血糖', '心率', '体重', '体温'];

  async aboutToAppear(): Promise<void> {
    await this.initData();
    await this.loadRecords();
  }

  private async initData(): Promise<void> {
    try {
      const storedFamilyInfo: FamilyInfo | undefined = AppStorage.get<FamilyInfo>('familyInfo');
      if (storedFamilyInfo) {
        this.relatedUserId = storedFamilyInfo.userId || 0;
        
        if (this.relatedUserId === 0) {
          console.warn('未找到关联用户ID，尝试从接口获取');
          await this.loadFamilyInfo();
        }
      } else {
        console.warn('未找到家属信息，尝试从接口获取');
        await this.loadFamilyInfo();
      }
    } catch (e) {
      console.error('初始化数据失败:', e);
    }
  }

  private async loadFamilyInfo(): Promise<void> {
    try {
      const response = await HttpUtil.get<FamilyInfo>('/family/info');
      if (response.success && response.data) {
        this.relatedUserId = response.data.userId || 0;
        AppStorage.setOrCreate<FamilyInfo>('familyInfo', response.data);
      }
    } catch (e) {
      console.error('加载家属信息失败:', e);
    }
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    try {
      if (this.relatedUserId === 0) {
        ToastUtil.showError('未找到关联患者信息');
        this.records = [];
        return;
      }

      console.info('正在加载患者健康记录，userId:', this.relatedUserId.toString());
      
      const params: Record<string, string> = {
        'userId': this.relatedUserId.toString()
      };
      const response = await HttpUtil.get<HealthRecord[]>('/healthRecord/my', params as Object);
      
      if (response.success && response.data) {
        console.info('成功获取到', response.data.length.toString(), '条健康记录');
        this.records = response.data.map((record: HealthRecord) => {
          const result: HealthRecord = {
            id: record.id || 0,
            recordType: this.mapRecordType(record.recordType || ''),
            value: record.value || '',
            unit: this.getUnitByType(record.recordType || ''),
            recordTime: record.recordTime || new Date().toISOString(),
            remark: record.remark || '',
            userId: record.userId || 0
          };
          return result;
        });
        
        if (this.records.length === 0) {
          ToastUtil.showInfo('暂无健康记录');
        }
      } else {
        console.error('获取健康记录失败:', response.message);
        ToastUtil.showError(response.message || '获取健康记录失败');
        this.records = [];
      }
    } catch (error) {
      console.error('加载健康记录异常:', error);
      ToastUtil.showError('加载健康记录失败，请检查网络连接');
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  private mapRecordType(type: string): string {
    const typeMap: Record<string, string> = {
      'BLOOD_PRESSURE': '血压',
      'BLOOD_SUGAR': '血糖',
      'HEART_RATE': '心率',
      'WEIGHT': '体重',
      'BODY_TEMPERATURE': '体温',
      '血压': '血压',
      '血糖': '血糖',
      '心率': '心率',
      '体重': '体重',
      '体温': '体温'
    };
    return typeMap[type] || type || '其他';
  }

  private getUnitByType(type: string): string {
    const unitMap: Record<string, string> = {
      '血压': 'mmHg',
      '血糖': 'mmol/L',
      '心率': 'bpm',
      '体重': 'kg',
      '体温': '℃'
    };
    return unitMap[type] || '';
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
