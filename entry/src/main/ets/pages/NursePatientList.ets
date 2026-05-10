import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'NursePatientList';

interface PatientInfo {
  id: number;
  userId: number;
  username: string;
  realName: string;
  phone: string;
  age: number;
  gender: number;
  idCard?: string;
  hospital?: string;
  department?: string;
  bedNumber?: string;
  diagnosis?: string;
  createTime?: string;
}

interface NurseInfo {
  id: number;
  name: string;
}

@Entry
@Component
struct NursePatientList {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;
  @StorageLink('nurseInfo') nurseInfo: NurseInfo | null = null;
  @State patients: PatientInfo[] = [];
  @State isLoading: boolean = true;
  @State searchText: string = '';
  @State hasError: boolean = false;

  async aboutToAppear(): Promise<void> {
    hilog.info(0x0000, TAG, 'aboutToAppear start');
    try {
      const settings = SettingsUtil.getInstance();
      const isLoggedIn = await settings.isNurseLoggedIn();
      hilog.info(0x0000, TAG, 'isLoggedIn=%{public}b', isLoggedIn);
      
      if (!isLoggedIn) {
        ToastUtil.showError('请先登录');
        router.replaceUrl({ url: 'pages/NurseLogin' });
        return;
      }

      await this.loadPatients();
    } catch (error) {
      hilog.error(0x0000, TAG, 'aboutToAppear error: %{public}s', String(error));
      this.hasError = true;
      this.isLoading = false;
    }
  }

  private async loadPatients(): Promise<void> {
    hilog.info(0x0000, TAG, 'loadPatients start');
    this.isLoading = true;
    try {
      let nurseId: number = this.currentUserId;
      if (this.nurseInfo !== null && this.nurseInfo !== undefined) {
        nurseId = this.nurseInfo.id;
      }
      hilog.info(0x0000, TAG, 'nurseId=%{public}d', nurseId);
      
      const url = `${ApiConstants.NURSE_PATIENTS}?nurseId=${nurseId}`;
      hilog.info(0x0000, TAG, 'request url=%{public}s', url);
      
      const response = await HttpUtil.get<PatientInfo[]>(url);
      hilog.info(0x0000, TAG, 'response success=%{public}b', response.success);
      
      if (response.success && response.data !== null && response.data !== undefined) {
        this.patients = response.data;
        hilog.info(0x0000, TAG, '加载患者列表成功，共%{public}d个患者', this.patients.length);
      } else {
        this.patients = [];
        const message = response.message !== undefined ? response.message : '暂无分配的患者';
        ToastUtil.showError(message);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, '加载患者列表失败: %{public}s', String(error));
      this.patients = [];
      this.hasError = true;
      ToastUtil.showError('加载失败，请稍后重试');
    } finally {
      this.isLoading = false;
    }
  }

  private handlePatientClick(patient: PatientInfo): void {
    let nurseName: string = '护士';
    if (this.nurseInfo !== null && this.nurseInfo !== undefined) {
      nurseName = this.nurseInfo.name;
    }
    const patientName = patient.realName !== undefined ? patient.realName : patient.username;
    router.pushUrl({
      url: 'pages/NurseChatPage',
      params: {
        nurseId: this.currentUserId,
        nurseName: nurseName,
        currentUserId: this.currentUserId,
        patientId: patient.id,
        patientName: patientName
      }
    });
  }

  private handleViewHealthRecord(patient: PatientInfo): void {
    const patientName = patient.realName !== undefined ? patient.realName : patient.username;
    router.pushUrl({
      url: 'pages/NurseHealthRecords',
      params: {
        patientId: patient.id,
        patientName: patientName
      }
    });
  }

  private get filteredPatients(): PatientInfo[] {
    if (!this.searchText || this.searchText.trim() === '') {
      return this.patients;
    }
    const searchLower = this.searchText.toLowerCase();
    return this.patients.filter((patient: PatientInfo) => {
      try {
        const name = patient.realName !== undefined && patient.realName !== null 
          ? patient.realName : patient.username;
        const phone = patient.phone !== undefined && patient.phone !== null 
          ? patient.phone : '';
        const department = patient.department !== undefined && patient.department !== null 
          ? patient.department : '';
        
        return name.toLowerCase().includes(searchLower) || 
               phone.includes(this.searchText) || 
               department.toLowerCase().includes(searchLower);
      } catch (e) {
        return false;
      }
    });
  }

  build() {
    Column() {
      Header({ title: '患者列表' })

      Column({ space: 12 }) {
        TextInput({ placeholder: '搜索患者姓名、手机号或科室', text: this.searchText })
          .width('100%')
          .height(40)
          .fontSize(this.isElderMode ? 18 : 16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.searchText = value;
          })

        if (this.hasError) {
          Column() {
            Text('⚠️')
              .fontSize(48)
            
            Text('加载失败')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 12 })
            
            Button('重试')
              .margin({ top: 16 })
              .onClick(async () => {
                this.hasError = false;
                await this.loadPatients();
              })
          }
          .width('100%')
          .layoutWeight(1)
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
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.filteredPatients.length === 0) {
          Column() {
            Text('👥')
              .fontSize(48)
            
            Text(this.searchText !== '' ? '未找到匹配的患者' : '暂无分配的患者')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 12 })
            
            if (this.searchText === '') {
              Text('请联系医生分配患者')
                .fontSize(14)
                .fontColor('#CCCCCC')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.filteredPatients, (patient: PatientInfo) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(patient.realName !== undefined && patient.realName !== null ? patient.realName : patient.username)
                        .fontSize(this.isElderMode ? 20 : 18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)

                      Row() {
                        Text(`${patient.gender === 1 ? '男' : '女'}`)
                          .fontSize(14)
                          .fontColor(GlobalTheme.TEXT_SECONDARY)

                        Text(`${patient.age}岁`)
                          .fontSize(14)
                          .fontColor(GlobalTheme.TEXT_SECONDARY)
                          .margin({ left: 8 })

                        if (patient.department !== undefined && patient.department !== null) {
                          Text(patient.department)
                            .fontSize(14)
                            .fontColor('#3498DB')
                            .margin({ left: 8 })
                        }
                      }
                      .margin({ top: 4 })

                      Row() {
                        Text(`📱 ${patient.phone}`)
                          .fontSize(14)
                          .fontColor(GlobalTheme.TEXT_SECONDARY)
                      }
                      .margin({ top: 4 })

                      if (patient.bedNumber !== undefined && patient.bedNumber !== null) {
                        Text(`床位: ${patient.bedNumber}`)
                          .fontSize(14)
                          .fontColor('#E74C3C')
                          .margin({ top: 4 })
                      }

                      if (patient.diagnosis !== undefined && patient.diagnosis !== null) {
                        Text(`诊断: ${patient.diagnosis}`)
                          .fontSize(14)
                          .fontColor(GlobalTheme.TEXT_SECONDARY)
                          .margin({ top: 4 })
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                  }
                  .width('100%')

                  Row({ space: 12 }) {
                    Button('💬 聊天')
                      .fontSize(14)
                      .height(36)
                      .fontColor('#3498DB')
                      .backgroundColor('#EBF5FB')
                      .borderRadius(8)
                      .layoutWeight(1)
                      .onClick(() => {
                        this.handlePatientClick(patient);
                      })

                    Button('📋 档案')
                      .fontSize(14)
                      .height(36)
                      .fontColor('#2ECC71')
                      .backgroundColor('#E8F8F5')
                      .borderRadius(8)
                      .layoutWeight(1)
                      .onClick(() => {
                        this.handleViewHealthRecord(patient);
                      })
                  }
                  .width('100%')
                  .margin({ top: 12 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
              }
            }, (patient: PatientInfo) => patient.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
