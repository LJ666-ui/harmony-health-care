import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface PatientInfo {
  id: number;
  name: string;
  phone: string;
  age: number;
  gender: number;
  bedNumber?: string;
  department?: string;
  diagnosis?: string;
}

@Entry
@Component
struct NursePatientList {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @State patients: PatientInfo[] = [];
  @State isLoading: boolean = true;

  async aboutToAppear(): Promise<void> {
    await this.loadPatients();
  }

  private async loadPatients(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<PatientInfo[]>('/nurse/patients');
      if (response.success && response.data) {
        this.patients = response.data;
      } else {
        ToastUtil.showError(response.message || '加载患者列表失败');
      }
    } catch (error) {
      console.error('加载患者列表失败:', error);
      ToastUtil.showError('加载患者列表失败');
    } finally {
      this.isLoading = false;
    }
  }

  private handlePatientClick(patient: PatientInfo): void {
    router.pushUrl({
      url: 'pages/NurseChatPage',
      params: {
        nurseId: this.currentUserId,
        nurseName: '护士',
        currentUserId: this.currentUserId,
        patientId: patient.id,
        patientName: patient.name
      }
    });
  }

  build() {
    Column() {
      Header({ title: '选择患者' })

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.patients.length === 0) {
        Column() {
          Text('暂无患者')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.patients, (patient: PatientInfo) => {
            ListItem() {
              Row() {
                Column() {
                  Text(patient.name)
                    .fontSize(this.isElderMode ? 20 : 18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)

                  Row() {
                    Text(`年龄: ${patient.age}岁`)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)

                    Text(`性别: ${patient.gender === 1 ? '男' : '女'}`)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ left: 12 })
                  }
                  .margin({ top: 4 })

                  if (patient.bedNumber) {
                    Text(`床位: ${patient.bedNumber}`)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ top: 4 })
                  }

                  if (patient.diagnosis) {
                    Text(`诊断: ${patient.diagnosis}`)
                      .fontSize(14)
                      .fontColor(GlobalTheme.TEXT_SECONDARY)
                      .margin({ top: 4 })
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('>')
                  .fontSize(20)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                this.handlePatientClick(patient);
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
