import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface Medication {
  id: number;
  name: string;
  dosage: string;
  frequency: string;
  time: string;
  status: string;
  remark?: string;
}

@Entry
@Component
struct FamilyMedication {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('familyInfo') familyInfo: object | null = null;
  @State isLoading: boolean = false;
  @State medications: Medication[] = [];

  async aboutToAppear(): Promise<void> {
    await this.loadMedications();
  }

  private async loadMedications(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<Medication[]>('/family/medications');
      
      if (response.success && response.data) {
        this.medications = response.data;
      } else {
        this.medications = this.getMockMedications();
      }
    } catch (error) {
      console.error('加载用药信息失败:', error);
      this.medications = this.getMockMedications();
    } finally {
      this.isLoading = false;
    }
  }

  private getMockMedications(): Medication[] {
    return [
      { id: 1, name: '降压药', dosage: '1片', frequency: '每日1次', time: '08:00', status: '已服用', remark: '早餐后服用' },
      { id: 2, name: '降糖药', dosage: '2片', frequency: '每日2次', time: '08:00, 18:00', status: '待服用', remark: '饭前30分钟' },
      { id: 3, name: '维生素D', dosage: '1粒', frequency: '每日1次', time: '12:00', status: '已服用', remark: '午餐时服用' }
    ];
  }

  build() {
    Column() {
      Header({ title: '用药管理', showBack: true })

      Column() {
        if (this.isLoading) {
          Loading()
        } else {
          List() {
            ForEach(this.medications, (med: Medication) => {
              ListItem() {
                Column() {
                  Row() {
                    Text('💊')
                      .fontSize(32)
                      .margin({ right: 15 })

                    Column() {
                      Text(med.name)
                        .fontSize(this.isElderMode ? 18 : 16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)

                      Text(`${med.dosage} | ${med.frequency}`)
                        .fontSize(this.isElderMode ? 16 : 14)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .margin({ top: 5 })

                      Text(`服用时间: ${med.time}`)
                        .fontSize(12)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .margin({ top: 3 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    // 状态标签
                    Text(med.status)
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor(med.status === '已服用' ? '#2ECC71' : '#F39C12')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(4)
                  }
                  .width('100%')

                  if (med.remark) {
                    Text(`备注: ${med.remark}`)
                      .fontSize(12)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ top: 10 })
                      .width('100%')
                  }
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
