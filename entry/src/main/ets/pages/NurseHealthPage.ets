import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'NurseHealthPage';

interface HealthRecord {
  id: number;
  userId: number;
  bloodPressure?: string;
  bloodSugar?: number;
  heartRate?: number;
  recordTime: string;
  weight?: number;
  height?: number;
  stepCount?: number;
  sleepDuration?: number;
  createTime: string;
}

interface PatientInfo {
  id: number;
  userId: number;
  username: string;
  realName: string;
  phone: string;
  age: number;
  gender: number;
  department?: string;
  bedNumber?: string;
}

@Entry
@Component
struct NurseHealthPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State patients: PatientInfo[] = [];
  @State selectedPatientId: number = 0;
  @State selectedPatientName: string = '';
  @State healthRecords: HealthRecord[] = [];
  @State latestRecord: HealthRecord | null = null;
  @State isLoadingRecords: boolean = false;

  async aboutToAppear(): Promise<void> {
    const settings = SettingsUtil.getInstance();
    const isLoggedIn = await settings.isNurseLoggedIn();
    if (!isLoggedIn) {
      ToastUtil.showError('请先登录');
      router.replaceUrl({ url: 'pages/NurseLogin' });
      return;
    }

    await this.loadPatients();
  }

  private async loadPatients(): Promise<void> {
    this.isLoading = true;
    try {
      const response = await HttpUtil.get<PatientInfo[]>(ApiConstants.NURSE_PATIENTS);
      if (response.success && response.data !== null && response.data !== undefined) {
        this.patients = response.data;
        hilog.info(0x0000, TAG, '加载患者列表成功，共%{public}d个患者', this.patients.length);
        
        if (this.patients.length > 0) {
          const firstPatient = this.patients[0];
          const name = firstPatient.realName !== undefined && firstPatient.realName !== null 
            ? firstPatient.realName : firstPatient.username;
          this.selectPatient(firstPatient.userId || firstPatient.id, name);
        }
      } else {
        this.patients = [];
      }
    } catch (error) {
      console.error('加载患者列表失败:', error);
      this.patients = [];
    } finally {
      this.isLoading = false;
    }
  }

  private selectPatient(patientId: number, patientName: string): void {
    hilog.info(0x0000, TAG, '选择患者：id=%{public}d, name=%{public}s', patientId, patientName);
    this.selectedPatientId = patientId;
    this.selectedPatientName = patientName;
    this.loadHealthRecords();
  }

  private async loadHealthRecords(): Promise<void> {
    this.isLoadingRecords = true;
    try {
      const url = `${ApiConstants.HEALTH_RECORD_PAGE}?page=1&size=100&userId=${this.selectedPatientId}`;
      hilog.info(0x0000, TAG, '请求URL: %{public}s', url);

      const response = await HttpUtil.get<Object>(url);
      hilog.info(0x0000, TAG, '响应: success=%{public}b', response.success);

      let recordsList: HealthRecord[] = [];
      const data = response.data;

      hilog.info(0x0000, TAG, 'data类型=%{public}s, data值=%{public}s', 
        typeof data, data !== null && data !== undefined ? JSON.stringify(data).substring(0, 200) : 'null');

      if (Array.isArray(data)) {
        recordsList = data as HealthRecord[];
        hilog.info(0x0000, TAG, '数据是数组格式，长度=%{public}d', recordsList.length);
      } else if (data && typeof data === 'object') {
        const pageData = data as Record<string, Object>;
        hilog.info(0x0000, TAG, '数据是对象格式，keys=%{public}s', JSON.stringify(Object.keys(pageData)));
        
        if (pageData.records && Array.isArray(pageData.records)) {
          recordsList = pageData.records as HealthRecord[];
          hilog.info(0x0000, TAG, '从records字段获取到%{public}d条记录', recordsList.length);
        } else if (pageData.data && Array.isArray(pageData.data)) {
          recordsList = pageData.data as HealthRecord[];
          hilog.info(0x0000, TAG, '从data字段获取到%{public}d条记录', recordsList.length);
        } else if (pageData.list && Array.isArray(pageData.list)) {
          recordsList = pageData.list as HealthRecord[];
          hilog.info(0x0000, TAG, '从list字段获取到%{public}d条记录', recordsList.length);
        } else {
          hilog.info(0x0000, TAG, '未找到数组字段，完整对象: %{public}s', 
            JSON.stringify(pageData).substring(0, 500));
          
          // 尝试直接将整个对象作为单条记录
          if (pageData.id || pageData.userId || pageData.bloodPressure) {
            const singleRecord: HealthRecord = {
              id: (pageData['id'] as number) || 0,
              userId: (pageData['userId'] as number) || 0,
              bloodPressure: pageData['bloodPressure'] as string | undefined,
              bloodSugar: pageData['bloodSugar'] as number | undefined,
              heartRate: pageData['heartRate'] as number | undefined,
              recordTime: (pageData['recordTime'] as string) || '',
              weight: pageData['weight'] as number | undefined,
              height: pageData['height'] as number | undefined,
              stepCount: pageData['stepCount'] as number | undefined,
              sleepDuration: pageData['sleepDuration'] as number | undefined,
              createTime: (pageData['createTime'] as string) || ''
            };
            recordsList = [singleRecord];
            hilog.info(0x0000, TAG, '将整个对象作为单条记录');
          }
        }
      }

      if (recordsList.length > 0) {
        this.healthRecords = recordsList.sort((a: HealthRecord, b: HealthRecord) =>
          new Date(b.recordTime).getTime() - new Date(a.recordTime).getTime()
        );
        this.latestRecord = this.healthRecords[0];
        hilog.info(0x0000, TAG, '加载成功，共%{public}条记录', this.healthRecords.length);
        
        const first = this.latestRecord;
        hilog.info(0x0000, TAG, '第一条记录：id=%{public}d, userId=%{public}d, bloodPressure=%{public}s', 
          first.id, first.userId, first.bloodPressure || '-');
      } else {
        this.healthRecords = [];
        this.latestRecord = null;
        hilog.info(0x0000, TAG, '暂无健康记录');
      }
    } catch (error) {
      console.error('加载健康记录失败:', error);
      this.healthRecords = [];
      this.latestRecord = null;
    } finally {
      this.isLoadingRecords = false;
    }
  }

  private formatDateTime(dateStr: string): string {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
  }

  build() {
    Column() {
      Header({ title: '生命体征', showBack: true })

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
      } else {
        Scroll() {
          Column({ space: 16 }) {
            Text('选择患者')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .width('100%')
              .padding({ left: 16 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.patients, (patient: PatientInfo) => {
                Button(patient.realName !== undefined && patient.realName !== null
                  ? patient.realName : patient.username)
                  .fontSize(14)
                  .height(36)
                  .margin({ right: 8, bottom: 8 })
                  .fontColor(this.selectedPatientId === (patient.userId || patient.id)
                    ? '#FFFFFF' : '#3498DB')
                  .backgroundColor(this.selectedPatientId === (patient.userId || patient.id)
                    ? '#3498DB' : '#EBF5FB')
                  .borderRadius(18)
                  .onClick(() => {
                    const name = patient.realName !== undefined && patient.realName !== null
                      ? patient.realName : patient.username;
                    this.selectPatient(patient.userId || patient.id, name);
                  })
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })

            if (this.isLoadingRecords) {
              Column() {
                LoadingProgress()
                  .width(40)
                  .height(40)
                  .color('#3498DB')
                Text('加载体征数据...')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 12 })
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
            } else if (this.latestRecord) {
              Column({ space: 12 }) {
                Text(`${this.selectedPatientName} - 最新体征数据`)
                  .fontSize(this.isElderMode ? 18 : 16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)
                  .width('100%')
                  .padding({ left: 16 })

                Text(`记录时间：${this.formatDateTime(this.latestRecord.recordTime)}`)
                  .fontSize(13)
                  .fontColor('#666666')
                  .width('100%')
                  .padding({ left: 16 })

                Grid() {
                  GridItem() {
                    this.buildMetricCard('血压', this.latestRecord.bloodPressure || '-', 'mmHg', '#E74C3C')
                  }
                  GridItem() {
                    this.buildMetricCard('血糖', 
                      this.latestRecord.bloodSugar !== undefined ? `${this.latestRecord.bloodSugar}` : '-', 
                      'mmol/L', '#F39C12')
                  }
                  GridItem() {
                    this.buildMetricCard('心率', 
                      this.latestRecord.heartRate !== undefined ? `${this.latestRecord.heartRate}` : '-', 
                      '次/分', '#3498DB')
                  }
                }
                .columnsTemplate('1fr 1fr 1fr')
                .columnsGap(12)
                .rowsGap(12)
                .width('100%')
                .padding({ left: 16, right: 16 })

                Grid() {
                  GridItem() {
                    this.buildMetricCard('体重', 
                      this.latestRecord.weight !== undefined ? `${this.latestRecord.weight}` : '-', 
                      'kg', '#9B59B6')
                  }
                  GridItem() {
                    this.buildMetricCard('身高', 
                      this.latestRecord.height !== undefined ? `${this.latestRecord.height}` : '-', 
                      'm', '#1ABC9C')
                  }
                  GridItem() {
                    this.buildMetricCard('步数', 
                      this.latestRecord.stepCount !== undefined ? `${this.latestRecord.stepCount}` : '-', 
                      '步', '#E67E22')
                  }
                }
                .columnsTemplate('1fr 1fr 1fr')
                .columnsGap(12)
                .rowsGap(12)
                .width('100%')
                .padding({ left: 16, right: 16 })

                if (this.latestRecord.sleepDuration !== undefined) {
                  Row() {
                    this.buildMetricCard('睡眠时长', 
                      `${this.latestRecord.sleepDuration}`, 
                      '小时', '#95A5A6')
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16 })
                }

                if (this.healthRecords.length > 1) {
                  Text(`历史记录（共${this.healthRecords.length}条）`)
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                    .width('100%')
                    .margin({ top: 20 })
                    .padding({ left: 16 })

                  List({ space: 10 }) {
                    ForEach(this.healthRecords.slice(1, 10), (record: HealthRecord) => {
                      ListItem() {
                        Row() {
                          Column() {
                            Text(this.formatDateTime(record.recordTime))
                              .fontSize(14)
                              .fontWeight(FontWeight.Medium)
                              .fontColor(GlobalTheme.TEXT_PRIMARY)

                            Row({ space: 16 }) {
                              if (record.bloodPressure) {
                                Text(`血压:${record.bloodPressure}`)
                                  .fontSize(12)
                                  .fontColor('#E74C3C')
                              }
                              if (record.bloodSugar !== undefined) {
                                Text(`血糖:${record.bloodSugar}`)
                                  .fontSize(12)
                                  .fontColor('#F39C12')
                              }
                              if (record.heartRate !== undefined) {
                                Text(`心率:${record.heartRate}`)
                                  .fontSize(12)
                                  .fontColor('#3498DB')
                              }
                            }
                            .margin({ top: 4 })
                          }
                          .alignItems(HorizontalAlign.Start)
                          .layoutWeight(1)

                          Text('查看详情')
                            .fontSize(13)
                            .fontColor('#3498DB')
                        }
                        .width('100%')
                        .padding(14)
                        .backgroundColor('#FFFFFF')
                        .borderRadius(8)
                        .shadow({ radius: 3, color: '#1A000000', offsetX: 0, offsetY: 1 })
                      }
                    })
                  }
                  .width('100%')
                  .layoutWeight(1)
                  .padding({ left: 16, right: 16 })
                }
              }
              .width('100%')
            } else {
              Column() {
                Text('📊')
                  .fontSize(48)
                Text('暂无生命体征数据')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ top: 12 })
                Text('该患者尚未录入体征数据')
                  .fontSize(13)
                  .fontColor('#CCCCCC')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  buildMetricCard(label: string, value: string, unit: string, color: string) {
    Column() {
      Text(value)
        .fontSize(this.isElderMode ? 24 : 20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 4 })
      
      Text(unit)
        .fontSize(10)
        .fontColor('#999999')
        .margin({ top: 2 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .justifyContent(FlexAlign.Center)
  }
}
