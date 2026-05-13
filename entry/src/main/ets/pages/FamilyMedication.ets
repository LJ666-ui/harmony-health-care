import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface MedicationReminder {
  id: number;
  patientId: number;
  medicationName: string;
  dosage: string;
  frequency: string;
  timeOfDay: string;
  status: string;
  startDate?: string;
  endDate?: string;
  notes?: string;
}

@Entry
@Component
struct FamilyMedication {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('familyInfo') familyInfo: object | null = null;
  @State isLoading: boolean = false;
  @State medications: MedicationReminder[] = [];
  @State relatedUserId: number = 0;

  async aboutToAppear(): Promise<void> {
    const familyInfo: Object | undefined = AppStorage.get('familyInfo');
    if (familyInfo) {
      const info: Record<string, Object> = familyInfo as Record<string, Object>;
      this.relatedUserId = info['userId'] as number || 0;
    }
    
    await this.loadMedications();
  }

  private async loadMedications(): Promise<void> {
    this.isLoading = true;
    try {
      console.info('正在加载患者用药信息，userId:', this.relatedUserId.toString());
      
      const response: BaseResponse<MedicationReminder[]> = await HttpUtil.get<MedicationReminder[]>('/family/medications');

      if (response.success && response.data) {
        if (Array.isArray(response.data)) {
          this.medications = response.data.map((item: MedicationReminder): MedicationReminder => ({
            id: item.id || 0,
            patientId: item.patientId || this.relatedUserId,
            medicationName: item.medicationName || '未知药品',
            dosage: item.dosage || '未设置',
            frequency: item.frequency || '每日1次',
            timeOfDay: item.timeOfDay || '08:00',
            status: item.status || '待服用',
            startDate: item.startDate || '',
            endDate: item.endDate || '',
            notes: item.notes || ''
          }));

          console.info('成功获取到', this.medications.length.toString(), '条用药记录');
        } else if (response.data && Array.isArray((response.data as Record<string, Object>).list)) {
          this.medications = (response.data as Record<string, Object>).list as MedicationReminder[];
        } else {
          this.medications = [];
        }
        
        if (this.medications.length === 0) {
          ToastUtil.showInfo('暂无用药记录');
        }
      } else {
        console.error('获取用药信息失败:', response.message);
        ToastUtil.showError(response.message || '获取用药信息失败');
        this.medications = [];
      }
    } catch (error) {
      console.error('加载用药信息异常:', error);
      ToastUtil.showError('加载用药信息失败，请检查网络连接');
      this.medications = [];
    } finally {
      this.isLoading = false;
    }
  }

  private getStatusColor(status: string): string {
    switch (status) {
      case '已服用':
      case 'CONFIRMED':
        return '#2ECC71';
      case '待服用':
      case 'PENDING':
        return '#F39C12';
      case '已跳过':
      case 'SKIPPED':
        return '#95A5A6';
      default:
        return '#F39C12';
    }
  }

  private getStatusText(status: string): string {
    switch (status) {
      case 'CONFIRMED':
        return '已服用';
      case 'PENDING':
        return '待服用';
      case 'SKIPPED':
        return '已跳过';
      default:
        return status || '待服用';
    }
  }

  build() {
    Column() {
      Header({ title: '用药管理', showBack: true })

      Text(`正在查看关联患者的用药信息（ID: ${this.relatedUserId}）`)
        .fontSize(12)
        .fontColor('#666666')
        .width('95%')
        .margin({ top: 10 })

      Column() {
        if (this.isLoading) {
          Loading()
        } else if (this.medications.length === 0) {
          Column() {
            Text('💊')
              .fontSize(48)
              .margin({ bottom: 12 })
            Text('暂无用药记录')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ bottom: 8 })
            Text('患者当前没有用药安排')
              .fontSize(14)
              .fontColor('#BBBBBB')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.medications, (med: MedicationReminder) => {
              ListItem() {
                Column() {
                  Row() {
                    Text('💊')
                      .fontSize(32)
                      .margin({ right: 15 })

                    Column() {
                      Text(med.medicationName)
                        .fontSize(this.isElderMode ? 18 : 16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)

                      Text(`${med.dosage} | ${med.frequency}`)
                        .fontSize(this.isElderMode ? 16 : 14)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .margin({ top: 5 })

                      Text(`服用时间: ${med.timeOfDay}`)
                        .fontSize(12)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .margin({ top: 3 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text(this.getStatusText(med.status))
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor(this.getStatusColor(med.status))
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(4)
                  }
                  .width('100%')

                  if (med.notes) {
                    Text(`备注: ${med.notes}`)
                      .fontSize(12)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ top: 10 })
                      .width('100%')
                  }

                  if (med.startDate) {
                    Row() {
                      Text(`开始日期: ${med.startDate}`)
                        .fontSize(11)
                      .fontColor('#999999')
                      
                      if (med.endDate) {
                        Text(`  结束日期: ${med.endDate}`)
                          .fontSize(11)
                          .fontColor('#999999')
                      }
                    }
                    .width('100%')
                    .margin({ top: 5 })
                  }
                }
                .width('100%')
                .padding(15)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
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
