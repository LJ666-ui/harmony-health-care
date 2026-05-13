import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface MedicationPlan {
  id: number;
  patientId: number;
  patientName?: string;
  medicineName: string;
  dosage: string;
  frequency: string;
  startTime: string;
  endTime?: string;
  status: number;
  notes?: string;
  lastTakenTime?: string;
  nextTakeTime?: string;
}

interface ConfirmMedicationRequest {
  nurseId: number;
}

@Entry
@Component
struct NurseMedicationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @State isLoading: boolean = true;
  @State medications: MedicationPlan[] = [];
  @State selectedStatus: number = -1;

  async aboutToAppear(): Promise<void> {
    const settings = SettingsUtil.getInstance();
    const isLoggedIn = await settings.isNurseLoggedIn();
    if (!isLoggedIn) {
      ToastUtil.showError('请先登录');
      router.replaceUrl({ url: 'pages/NurseLogin' });
      return;
    }

    await this.loadMedications();
  }

  private async loadMedications(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<MedicationPlan[]>(
        `${ApiConstants.MEDICINE_LIST}?nurseId=${this.currentUserId}`
      );

      if (response.success && response.data !== null && response.data !== undefined) {
        this.medications = response.data;
      } else {
        this.medications = [];
      }
    } catch (error) {
      console.error('加载用药计划失败:', error);
      this.medications = [];
    } finally {
      this.isLoading = false;
    }
  }

  private async confirmMedication(medId: number): Promise<void> {
    try {
      const requestBody: ConfirmMedicationRequest = { nurseId: this.currentUserId };
      const response = await HttpUtil.post<void>(
        `${ApiConstants.MEDICINE_DETAIL}${medId}/confirm`,
        requestBody
      );

      if (response.success) {
        ToastUtil.showSuccess('已确认用药');
        await this.loadMedications();
      } else {
        ToastUtil.showError(response.message !== undefined ? response.message : '确认失败');
      }
    } catch (error) {
      console.error('确认用药失败:', error);
      ToastUtil.showError('确认失败');
    }
  }

  private getStatusText(status: number): string {
    switch (status) {
      case 0: return '待执行';
      case 1: return '进行中';
      case 2: return '已完成';
      case 3: return '已取消';
      default: return '未知';
    }
  }

  private getStatusColor(status: number): string {
    switch (status) {
      case 0: return '#F39C12';
      case 1: return '#3498DB';
      case 2: return '#27AE60';
      case 3: return '#95A5A6';
      default: return '#999999';
    }
  }

  build() {
    Column() {
      Header({ title: '用药管理', showBack: true })

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Button('全部')
            .fontSize(13)
            .height(32)
            .fontColor(this.selectedStatus === -1 ? '#FFFFFF' : '#3498DB')
            .backgroundColor(this.selectedStatus === -1 ? '#3498DB' : '#EBF5FB')
            .borderRadius(6)
            .onClick(() => {
              this.selectedStatus = -1;
            })

          ForEach([0, 1, 2], (status: number) => {
            Button(this.getStatusText(status))
              .fontSize(13)
              .height(32)
              .fontColor(this.selectedStatus === status ? '#FFFFFF' : '#3498DB')
              .backgroundColor(this.selectedStatus === status ? '#3498DB' : '#EBF5FB')
              .borderRadius(6)
              .onClick(() => {
                this.selectedStatus = status;
              })
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
        } else if (this.medications.length === 0) {
          Column() {
            Text('💊')
              .fontSize(48)
            Text('暂无用药计划')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 12 })
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(
              this.selectedStatus === -1
                ? this.medications
                : this.medications.filter(m => m.status === this.selectedStatus),
              (med: MedicationPlan) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text(med.medicineName)
                        .fontSize(this.isElderMode ? 18 : 16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)
                        .layoutWeight(1)

                      Text(this.getStatusText(med.status))
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .backgroundColor(this.getStatusColor(med.status))
                        .borderRadius(4)
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    }
                    .width('100%')

                    if (med.patientName) {
                      Text(`患者：${med.patientName}`)
                        .fontSize(14)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .margin({ top: 8 })
                    }

                    Row() {
                      Text(`剂量：${med.dosage}`)
                        .fontSize(14)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)

                      Text(`频次：${med.frequency}`)
                        .fontSize(14)
                        .fontColor(GlobalTheme.TEXT_SECONDARY)
                        .margin({ left: 16 })
                    }
                    .width('100%')
                    .margin({ top: 8 })

                    Row() {
                      Text(`开始：${med.startTime}`)
                        .fontSize(13)
                        .fontColor('#999999')

                      if (med.endTime) {
                        Text(`结束：${med.endTime}`)
                          .fontSize(13)
                          .fontColor('#999999')
                          .margin({ left: 16 })
                      }
                    }
                    .width('100%')
                    .margin({ top: 8 })

                    if (med.nextTakeTime) {
                      Text(`下次用药：${med.nextTakeTime}`)
                        .fontSize(14)
                        .fontColor('#E74C3C')
                        .fontWeight(FontWeight.Medium)
                        .margin({ top: 8 })
                    }

                    if (med.status === 1 || med.status === 0) {
                      Button('确认用药')
                        .width('100%')
                        .height(36)
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#27AE60')
                        .borderRadius(8)
                        .margin({ top: 12 })
                        .onClick(() => {
                          this.confirmMedication(med.id);
                        })
                    }
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
                }
              }
            )
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
  }
}
