import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface HealthRecord {
  id: number;
  userId: number;
  recordDate: string;
  height?: number;
  weight?: number;
  bloodPressureHigh?: number;
  bloodPressureLow?: number;
  heartRate?: number;
  bloodSugar?: number;
  temperature?: number;
  notes?: string;
  createTime: string;
}

interface HealthMetricItem {
  label: string;
  value: string;
}

@Entry
@Component
struct NurseHealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State patientId: number = 0;
  @State patientName: string = '';
  @State records: HealthRecord[] = [];
  @State selectedTab: number = 0;

  async aboutToAppear(): Promise<void> {
    const settings = SettingsUtil.getInstance();
    const isLoggedIn = await settings.isNurseLoggedIn();
    if (!isLoggedIn) {
      ToastUtil.showError('请先登录');
      router.replaceUrl({ url: 'pages/NurseLogin' });
      return;
    }

    const params = router.getParams();
    if (params !== null && params !== undefined) {
      const paramRecord = params as Record<string, Object>;
      const patientIdParam = paramRecord['patientId'];
      const patientNameParam = paramRecord['patientName'];
      this.patientId = patientIdParam !== null && patientIdParam !== undefined ? (patientIdParam as number) : 0;
      this.patientName = patientNameParam !== null && patientNameParam !== undefined ? (patientNameParam as string) : '患者';
    }

    if (this.patientId > 0) {
      await this.loadHealthRecords();
    } else {
      this.isLoading = false;
    }
  }

  private async loadHealthRecords(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<HealthRecord[]>(
        `${ApiConstants.HEALTH_RECORD_MY}?userId=${this.patientId}`
      );

      if (response.success && response.data !== null && response.data !== undefined) {
        this.records = response.data.sort((a: HealthRecord, b: HealthRecord) =>
          new Date(b.recordDate).getTime() - new Date(a.recordDate).getTime()
        );
      } else {
        this.records = [];
      }
    } catch (error) {
      console.error('加载健康档案失败:', error);
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  private formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }

  build() {
    Column() {
      Header({ title: `${this.patientName}的健康档案`, showBack: true })

      if (this.patientId === 0) {
        Column() {
          Text('📋')
            .fontSize(48)
            .margin({ bottom: 16 })

          Text('请从患者列表选择患者查看档案')
            .fontSize(16)
            .fontColor(GlobalTheme.TEXT_SECONDARY)

          Button('返回患者列表')
            .margin({ top: 20 })
            .onClick(() => {
              router.back();
            })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.isLoading) {
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
      } else {
        Column({ space: 12 }) {
          Row({ space: 12 }) {
            Button('全部记录')
              .fontSize(14)
              .height(36)
              .fontColor(this.selectedTab === 0 ? '#FFFFFF' : '#3498DB')
              .backgroundColor(this.selectedTab === 0 ? '#3498DB' : '#EBF5FB')
              .borderRadius(8)
              .layoutWeight(1)
              .onClick(() => {
                this.selectedTab = 0;
              })

            Button('最近记录')
              .fontSize(14)
              .height(36)
              .fontColor(this.selectedTab === 1 ? '#FFFFFF' : '#3498DB')
              .backgroundColor(this.selectedTab === 1 ? '#3498DB' : '#EBF5FB')
              .borderRadius(8)
              .layoutWeight(1)
              .onClick(() => {
                this.selectedTab = 1;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          if (this.records.length === 0) {
            Column() {
              Text('📄')
                .fontSize(48)
              Text('暂无健康档案记录')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 12 })
            }
            .layoutWeight(1)
            .width('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            List({ space: 12 }) {
              ForEach(this.selectedTab === 0 ? this.records : this.records.slice(0, 5), (record: HealthRecord) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text(this.formatDate(record.recordDate))
                        .fontSize(this.isElderMode ? 18 : 16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)

                      Blank()

                      Text(record.createTime ? this.formatDate(record.createTime) : '')
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    .width('100%')
                    .margin({ bottom: 12 })

                    Grid() {
                      ForEach([
                        { label: '身高', value: record.height !== undefined ? `${record.height}cm` : '-' } as HealthMetricItem,
                        { label: '体重', value: record.weight !== undefined ? `${record.weight}kg` : '-' } as HealthMetricItem,
                        { label: '血压', value: record.bloodPressureHigh !== undefined && record.bloodPressureLow !== undefined ? `${record.bloodPressureHigh}/${record.bloodPressureLow}` : '-' } as HealthMetricItem,
                        { label: '心率', value: record.heartRate !== undefined ? `${record.heartRate}次/分` : '-' } as HealthMetricItem,
                        { label: '血糖', value: record.bloodSugar !== undefined ? `${record.bloodSugar}mmol/L` : '-' } as HealthMetricItem,
                        { label: '体温', value: record.temperature !== undefined ? `${record.temperature}℃` : '-' } as HealthMetricItem
                      ], (item: HealthMetricItem) => {
                        GridItem() {
                          Column() {
                            Text(item.label)
                              .fontSize(12)
                              .fontColor('#999999')
                            Text(item.value)
                              .fontSize(this.isElderMode ? 16 : 14)
                              .fontColor(GlobalTheme.TEXT_PRIMARY)
                              .fontWeight(FontWeight.Medium)
                              .margin({ top: 4 })
                          }
                          .width('100%')
                          .alignItems(HorizontalAlign.Center)
                        }
                      })
                    }
                    .columnsTemplate('1fr 1fr 1fr')
                    .rowsGap(12)
                    .width('100%')

                    if (record.notes) {
                      Column() {
                        Text('备注：')
                          .fontSize(13)
                          .fontColor('#999999')
                        Text(record.notes)
                          .fontSize(14)
                          .fontColor(GlobalTheme.TEXT_SECONDARY)
                          .margin({ top: 4 })
                      }
                      .width('100%')
                      .alignItems(HorizontalAlign.Start)
                      .margin({ top: 12 })
                      .padding(12)
                      .backgroundColor('#F8F9FA')
                      .borderRadius(6)
                    }
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
