import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import http from '@ohos.net.http';

const TAG: string = 'NurseHealthRecords';

interface MedicalRecord {
  id: number;
  userId: number;
  hospitalId?: number;
  doctorId?: number;
  diagnosis: string;
  treatment: string;
  recordTime: string;
  isDesensitized?: number;
  createTime: string;
  updateTime: string;
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
  diagnosis?: string;
}

interface NursePatientResponse {
  code?: number;
  success?: boolean;
  msg?: string;
  message?: string;
  data?: PatientInfo[];
}

@Entry
@Component
struct NurseHealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = true;
  @State patientId: number = 0;
  @State patientName: string = '';
  @State records: MedicalRecord[] = [];
  @State selectedTab: number = 0;
  @State patients: PatientInfo[] = [];
  @State isLoadingPatients: boolean = false;

  async aboutToAppear(): Promise<void> {
    const settings = SettingsUtil.getInstance();
    const isLoggedIn = await settings.isNurseLoggedIn();
    if (!isLoggedIn) {
      ToastUtil.showError('请先登录');
      router.replaceUrl({ url: 'pages/NurseLogin' });
      return;
    }

    const params = router.getParams();
    hilog.info(0x0000, TAG, 'aboutToAppear - params: %{public}s', JSON.stringify(params));
    
    if (params !== null && params !== undefined) {
      const paramRecord = params as Record<string, Object>;
      const patientIdParam = paramRecord['patientId'];
      const patientNameParam = paramRecord['patientName'];
      hilog.info(0x0000, TAG, 'patientIdParam type=%{public}s, value=%{public}s', typeof patientIdParam, String(patientIdParam));
      
      this.patientId = patientIdParam !== null && patientIdParam !== undefined ? (patientIdParam as number) : 0;
      this.patientName = patientNameParam !== null && patientNameParam !== undefined ? (patientNameParam as string) : '患者';
      hilog.info(0x0000, TAG, '最终 patientId=%{public}d, patientName=%{public}s', this.patientId, this.patientName);
    }

    if (this.patientId > 0) {
      await this.loadHealthRecords();
    } else {
      this.isLoading = false;
      await this.loadPatients();
    }
  }

  private async loadPatients(): Promise<void> {
    this.isLoadingPatients = true;
    try {
      const url: string = `${ApiConstants.BASE_URL}/user/nurse/patients`;
      hilog.info(0x0000, TAG, 'loadPatients - 请求URL: %{public}s', url);

      const nurseToken: string | undefined = AppStorage.get<string>('nurseToken');
      hilog.info(0x0000, TAG, 'loadPatients - nurseToken exists: %{public}b', nurseToken !== undefined && nurseToken.length > 0);

      let response: BaseResponse<PatientInfo[]>;

      if (nurseToken && nurseToken.length > 0) {
        const httpRequest = http.createHttp();
        const httpResponse: http.HttpResponse = await httpRequest.request(url, {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Token': nurseToken
          },
          connectTimeout: 30000,
          readTimeout: 30000
        });
        httpRequest.destroy();

        const resultStr: string = httpResponse.result as string;
        hilog.info(0x0000, TAG, 'loadPatients - 响应状态码: %{public}d', httpResponse.responseCode);
        hilog.info(0x0000, TAG, 'loadPatients - 响应内容: %{public}s', resultStr.substring(0, Math.min(200, resultStr.length)));

        const resultData: NursePatientResponse = JSON.parse(resultStr) as NursePatientResponse;
        const isSuccess: boolean = resultData.code === 200 || resultData.success === true;
        const message: string = resultData.msg !== undefined ? resultData.msg : (resultData.message !== undefined ? resultData.message : '');
        response = new BaseResponse<PatientInfo[]>(isSuccess, message, resultData.data, resultData.code);
      } else {
        hilog.warn(0x0000, TAG, 'loadPatients - 无护士Token，尝试使用HttpUtil');
        response = await HttpUtil.get<PatientInfo[]>(ApiConstants.NURSE_PATIENTS);
      }

      hilog.info(0x0000, TAG, 'loadPatients - 响应: success=%{public}b, data长度=%{public}d',
        response.success, response.data !== null && response.data !== undefined ? response.data.length : -1);

      if (response.success && response.data !== null && response.data !== undefined) {
        this.patients = response.data;
        hilog.info(0x0000, TAG, 'loadPatients - 加载成功，共%{public}d个患者', this.patients.length);
      } else {
        this.patients = [];
        hilog.error(0x0000, TAG, 'loadPatients - 加载失败: %{public}s', response.message || '未知错误');
      }
    } catch (error) {
      console.error('加载患者列表失败:', error);
      this.patients = [];
      hilog.error(0x0000, TAG, 'loadPatients - 异常: %{public}s', String(error));
    } finally {
      this.isLoadingPatients = false;
    }
  }

  private selectPatient(patient: PatientInfo): void {
    const name = patient.realName !== undefined && patient.realName !== null ? patient.realName : patient.username;
    hilog.info(0x0000, TAG, 'selectPatient - patient对象: id=%{public}d, userId=%{public}d, name=%{public}s', 
      patient.id, patient.userId, name);
    
    const targetId: number = patient.userId || patient.id;
    hilog.info(0x0000, TAG, 'selectPatient - 使用targetId=%{public}d', targetId);
    
    this.patientId = targetId;
    this.patientName = name;
    this.loadHealthRecords();
  }

  private async loadHealthRecords(): Promise<void> {
    this.isLoading = true;
    hilog.info(0x0000, TAG, 'loadHealthRecords - 开始加载病历, patientId=%{public}d', this.patientId);
    
    try {
      const url: string = `${ApiConstants.MEDICAL_RECORD_PAGE}?userId=${this.patientId}&pageSize=100`;
      hilog.info(0x0000, TAG, '请求URL: %{public}s', url);
      
      const response = await HttpUtil.get<Object>(url);
      hilog.info(0x0000, TAG, '响应: success=%{public}b, data类型=%{public}s',
        response.success, typeof response.data);

      let medicalRecordList: MedicalRecord[] = [];
      const data = response.data;

      if (Array.isArray(data)) {
        medicalRecordList = data as MedicalRecord[];
        hilog.info(0x0000, TAG, '数据是数组格式，长度=%{public}d', medicalRecordList.length);
      } else if (data && typeof data === 'object') {
        const pageData = data as Record<string, Object>;
        if (pageData.records && Array.isArray(pageData.records)) {
          medicalRecordList = pageData.records as MedicalRecord[];
          hilog.info(0x0000, TAG, '数据是分页对象格式，records长度=%{public}d', medicalRecordList.length);
        } else {
          hilog.info(0x0000, TAG, '分页对象中没有records字段，原始data=%{public}s', JSON.stringify(data));
        }
      }

      if (medicalRecordList.length > 0) {
        this.records = medicalRecordList.sort((a: MedicalRecord, b: MedicalRecord) =>
          new Date(b.recordTime).getTime() - new Date(a.recordTime).getTime()
        );
        hilog.info(0x0000, TAG, '加载成功，共%{public}d条病历', this.records.length);
        
        if (this.records.length > 0) {
          const firstRecord = this.records[0];
          hilog.info(0x0000, TAG, '第一条病历：id=%{public}d, diagnosis=%{public}s', 
            firstRecord.id, firstRecord.diagnosis);
        }
      } else {
        this.records = [];
        hilog.info(0x0000, TAG, '没有病历数据');
      }
    } catch (error) {
      console.error('加载病历数据失败:', error);
      this.records = [];
    } finally {
      this.isLoading = false;
    }
  }

  private formatDateTime(dateStr: string): string {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Column() {
          Text('←')
            .fontSize(18)
            .fontColor('#3498DB');
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#3498DB15')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (this.patientId > 0) {
            this.patientId = 0;
            this.patientName = '';
            this.records = [];
            this.loadPatients();
          } else {
            router.back();
          }
        });

        Text(this.patientId > 0 ? `${this.patientName}的健康档案` : '健康档案')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        if (this.patientId > 0) {
          Column() {
            Text('📋')
              .fontSize(18);
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.patientId = 0;
            this.patientName = '';
            this.records = [];
            this.loadPatients();
          });
        } else {
          Blank().width(40);
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .shadow({
        radius: 2,
        color: '#1A00000020',
        offsetX: 0,
        offsetY: 1
      });

      if (this.patientId === 0) {
        Column() {
          Text('📋')
            .fontSize(48)
            .margin({ bottom: 16 })

          Text('请选择患者查看健康档案')
            .fontSize(16)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: 20 })

          if (this.isLoadingPatients) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#3498DB')
              Text('加载患者列表...')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 12 })
            }
            .width('100%')
            .padding(20)
          } else if (this.patients.length === 0) {
            Text('暂无患者数据')
              .fontSize(14)
              .fontColor('#999999')

            Button('返回工作台')
              .margin({ top: 20 })
              .onClick(() => {
                router.back();
              })
          } else {
            List({ space: 10 }) {
              ForEach(this.patients, (patient: PatientInfo) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(patient.realName !== undefined && patient.realName !== null ? patient.realName : patient.username)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)

                      if (patient.department || patient.bedNumber) {
                        Text(`${patient.department || '-'} | 床位：${patient.bedNumber || '-'}`)
                          .fontSize(12)
                          .fontColor('#666666')
                          .margin({ top: 4 })
                      }

                      if (patient.diagnosis) {
                        Text(`诊断：${patient.diagnosis}`)
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ top: 2 })
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text('查看档案')
                      .fontSize(14)
                      .fontColor('#3498DB')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .shadow({ radius: 3, color: '#1A000000', offsetX: 0, offsetY: 1 })
                  .onClick(() => {
                    this.selectPatient(patient);
                  })
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: 16, right: 16 })

            Button('返回工作台')
              .margin({ top: 16 })
              .onClick(() => {
                router.back();
              })
          }
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .padding({ top: 20, bottom: 20 })
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
              Text('暂无病历记录')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 12 })
            }
            .layoutWeight(1)
            .width('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            List({ space: 12 }) {
              ForEach(this.selectedTab === 0 ? this.records : this.records.slice(0, 5), (record: MedicalRecord) => {
                ListItem() {
                  Column() {
                    Row() {
                      Text(`病历 #${record.id}`)
                        .fontSize(this.isElderMode ? 18 : 16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)

                      Blank()

                      Text(record.recordTime ? this.formatDateTime(record.recordTime) : '')
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    .width('100%')
                    .margin({ bottom: 12 })

                    Column({ space: 10 }) {
                      Row() {
                        Text('诊断：')
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#E74C3C')
                        Text(record.diagnosis || '暂无诊断信息')
                          .fontSize(14)
                          .fontColor(GlobalTheme.TEXT_PRIMARY)
                          .layoutWeight(1)
                      }
                      .width('100%')

                      Row() {
                        Text('治疗：')
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#3498DB')
                        Text(record.treatment || '暂无治疗方案')
                          .fontSize(14)
                          .fontColor(GlobalTheme.TEXT_SECONDARY)
                          .layoutWeight(1)
                      }
                      .width('100%')

                      if (record.createTime) {
                        Row() {
                          Text('创建时间：')
                            .fontSize(12)
                            .fontColor('#999999')
                          Text(this.formatDateTime(record.createTime))
                            .fontSize(12)
                            .fontColor('#666666')
                        }
                        .width('100%')
                      }
                    }
                    .width('100%')
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/MedicalRecordDetailPage',
                      params: {
                        record: record
                      }
                    });
                  })
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
