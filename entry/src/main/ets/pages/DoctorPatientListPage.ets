import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import { SettingsUtil } from '../utils/SettingsUtil';

interface PatientInfo {
  patientId: number;
  name: string;
  phone: string;
  avatar: string;
  isToday: boolean;
  appointmentId?: number;
  scheduleDate?: string;
  schedulePeriod?: number;
  status?: number;
  fee?: number;
  appointmentNo?: string;
  periodText?: string;
  statusText?: string;
}

@Entry
@Component
struct DoctorPatientListPage {
  @State todayPatients: PatientInfo[] = [];
  @State historyPatients: PatientInfo[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State doctorId: number = 0;
  @State currentTab: number = 0;

  aboutToAppear(): void {
    this.loadDoctorId();
  }

  private async loadDoctorId(): Promise<void> {
    try {
      const settings = SettingsUtil.getInstance();
      const doctorInfo = await settings.getDoctorInfo();
      
      if (doctorInfo && doctorInfo['id']) {
        this.doctorId = doctorInfo['id'] as number;
        hilog.info(0x0000, 'DoctorPatientListPage', `医生ID: ${this.doctorId}`);
        this.loadPatients();
      } else {
        hilog.error(0x0000, 'DoctorPatientListPage', '未找到医生信息');
        this.errorMessage = '未找到医生信息，请重新登录';
        this.isLoading = false;
      }
    } catch (error) {
      hilog.error(0x0000, 'DoctorPatientListPage', `获取医生ID失败: ${JSON.stringify(error)}`);
      this.errorMessage = '获取医生信息失败';
      this.isLoading = false;
    }
  }

  private async loadPatients(): Promise<void> {
    try {
      hilog.info(0x0000, 'DoctorPatientListPage', `开始加载患者列表, doctorId=${this.doctorId}`);
      const serverUrl: string = 'http://192.168.108.1:8080';
      hilog.info(0x0000, 'DoctorPatientListPage', `请求URL: ${serverUrl}/api/appointment/doctor/${this.doctorId}/patients`);

      const response = await http.createHttp().request(
        `${serverUrl}/api/appointment/doctor/${this.doctorId}/patients`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      hilog.info(0x0000, 'DoctorPatientListPage', `响应状态码: ${response.responseCode}`);

      if (response.responseCode === 200) {
        const result: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
        hilog.info(0x0000, 'DoctorPatientListPage', `解析后的code: ${result['code']}, message: ${result['message']}`);

        const data: Object | undefined = result['data'];
        if (data && typeof data === 'object') {
          const dataRecord: Record<string, Object> = data as Record<string, Object>;
          const todayPatientsRaw: Object | undefined = dataRecord['todayPatients'];
          const historyPatientsRaw: Object | undefined = dataRecord['historyPatients'];

          const todayData: Record<string, Object>[] = Array.isArray(todayPatientsRaw) ? todayPatientsRaw as Record<string, Object>[] : [];
          const historyData: Record<string, Object>[] = Array.isArray(historyPatientsRaw) ? historyPatientsRaw as Record<string, Object>[] : [];

          hilog.info(0x0000, 'DoctorPatientListPage', `今日患者: ${todayData.length}位, 历史患者: ${historyData.length}位`);

          this.todayPatients = this.parsePatientArray(todayData);
          this.historyPatients = this.parsePatientArray(historyData);
        }

        this.isLoading = false;
        
        if (this.todayPatients.length > 0 || this.historyPatients.length > 0) {
          hilog.info(0x0000, 'DoctorPatientListPage', `加载完成 - 今日: ${this.todayPatients.length}, 历史: ${this.historyPatients.length}`);
        } else {
          hilog.warn(0x0000, 'DoctorPatientListPage', '患者列表为空');
        }
      } else {
        let errorDetail = '';
        if (response.result) {
          try {
            const errorResult: Record<string, Object> = JSON.parse(response.result as string) as Record<string, Object>;
            errorDetail = (errorResult['message'] as string) || (response.result as string);
          } catch (e) {
            errorDetail = response.result as string;
          }
        }

        hilog.error(0x0000, 'DoctorPatientListPage',
          `API返回错误! 状态码: ${response.responseCode}, 详情: ${errorDetail}`);

        this.errorMessage = `加载失败(${response.responseCode}): ${errorDetail}`;
        this.isLoading = false;
      }
    } catch (error) {
      let errorMsg = '未知错误';
      if (error) {
        if (typeof error === 'string') {
          errorMsg = error;
        } else {
          errorMsg = JSON.stringify(error);
        }
      }
      
      hilog.error(0x0000, 'DoctorPatientListPage', `loadPatients 异常: ${errorMsg}`);
      
      if (errorMsg.includes('timeout') || errorMsg.includes('超时')) {
        this.errorMessage = '⏰ 网络超时，请检查后端服务是否启动';
      } else if (errorMsg.includes('refused') || errorMsg.includes('ECONNREFUSED')) {
        this.errorMessage = '❌ 无法连接后端，请确认localhost:8080是否可访问';
      } else if (errorMsg.includes('ENOTFOUND')) {
        this.errorMessage = '🌐 DNS解析失败，请检查网络设置';
      } else {
        this.errorMessage = `❌ 加载失败: ${errorMsg.substring(0, 100)}`;
      }
      
      this.isLoading = false;
    }
  }

  private parsePatientArray(rawArray: Record<string, Object>[]): PatientInfo[] {
    const patients: PatientInfo[] = [];

    for (let i = 0; i < rawArray.length; i++) {
      const raw: Record<string, Object> = rawArray[i];
      if (raw == null) continue;

      const patient: PatientInfo = {} as PatientInfo;

      const patientIdVal: Object | undefined = raw['patientId'];
      patient.patientId = typeof patientIdVal === 'number' ? patientIdVal : 0;

      const nameVal: Object | undefined = raw['name'];
      patient.name = typeof nameVal === 'string' ? nameVal : '未知';

      const phoneVal: Object | undefined = raw['phone'];
      patient.phone = typeof phoneVal === 'string' ? phoneVal : '';

      const avatarVal: Object | undefined = raw['avatar'];
      patient.avatar = typeof avatarVal === 'string' ? avatarVal : '';

      const isTodayVal: Object | undefined = raw['isToday'];
      patient.isToday = isTodayVal === true;

      const appointmentIdVal: Object | undefined = raw['appointmentId'];
      if (appointmentIdVal !== undefined && appointmentIdVal !== null) {
        patient.appointmentId = typeof appointmentIdVal === 'number' ? appointmentIdVal : undefined;
      }

      const scheduleDateVal: Object | undefined = raw['scheduleDate'];
      if (scheduleDateVal !== undefined && scheduleDateVal !== null) {
        patient.scheduleDate = String(scheduleDateVal);
      }

      const schedulePeriodVal: Object | undefined = raw['schedulePeriod'];
      if (schedulePeriodVal !== undefined && schedulePeriodVal !== null) {
        patient.schedulePeriod = Number(schedulePeriodVal);
      }

      const statusVal: Object | undefined = raw['status'];
      if (statusVal !== undefined && statusVal !== null) {
        patient.status = Number(statusVal);
      }

      const feeVal: Object | undefined = raw['fee'];
      if (feeVal !== undefined && feeVal !== null) {
        patient.fee = Number(feeVal);
      }

      const appointmentNoVal: Object | undefined = raw['appointmentNo'];
      if (appointmentNoVal !== undefined && appointmentNoVal !== null) {
        patient.appointmentNo = String(appointmentNoVal);
      }

      const periodTextVal: Object | undefined = raw['periodText'];
      if (periodTextVal !== undefined && periodTextVal !== null) {
        patient.periodText = String(periodTextVal);
      }

      const statusTextVal: Object | undefined = raw['statusText'];
      if (statusTextVal !== undefined && statusTextVal !== null) {
        patient.statusText = String(statusTextVal);
      }

      patients.push(patient);
    }

    return patients;
  }

  build() {
    Column() {
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#333333');
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        });

        Text('患者管理')
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text(`${this.todayPatients.length + this.historyPatients.length}`)
          .fontSize(14)
          .fontColor('#666666')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(12)
          .backgroundColor('#F0F0F0');
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 });

      Tabs({ index: this.currentTab }) {
        TabContent() {
          if (this.isLoading) {
            Column() {
              Text('加载中...')
                .fontSize(16)
                .fontColor('#999999');
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center);
          } else if (this.todayPatients.length === 0) {
            Column() {
              Text('📅')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text('今日暂无挂号患者')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#666666')
                .margin({ bottom: 6 });
              Text('患者挂号后将在此显示')
                .fontSize(13)
                .fontColor('#999999');
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center);
          } else {
            Scroll() {
              Column() {
                ForEach(this.todayPatients, (patient: PatientInfo) => {
                  this.buildPatientCard(patient);
                }, (patient: PatientInfo) => patient.patientId.toString());
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 48 });
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off);
          }
        }
        .tabBar(`今日挂号 (${this.todayPatients.length})`);

        TabContent() {
          if (this.isLoading) {
            Column() {
              Text('加载中...')
                .fontSize(16)
                .fontColor('#999999');
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center);
          } else if (this.historyPatients.length === 0) {
            Column() {
              Text('👥')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text('暂无历史患者')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#666666')
                .margin({ bottom: 6 });
              Text('历史就诊患者将在此显示')
                .fontSize(13)
                .fontColor('#999999');
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center);
          } else {
            Scroll() {
              Column() {
                ForEach(this.historyPatients, (patient: PatientInfo) => {
                  this.buildPatientCard(patient);
                }, (patient: PatientInfo) => patient.patientId.toString());
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 48 });
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off);
          }
        }
        .tabBar(`历史患者 (${this.historyPatients.length})`);
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTab = index;
      });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildPatientCard(patient: PatientInfo) {
    Column() {
      Row({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(48)
            .height(48)
            .fill(patient.isToday ? '#1677FF' : '#52C41A');
          
          if (patient.avatar && patient.avatar.length > 0) {
            Image(patient.avatar)
              .width(48)
              .height(48)
              .borderRadius(24)
              .objectFit(ImageFit.Cover);
          } else {
            Text(patient.name.charAt(0))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
          }
        }

        Column({ space: 4 }) {
          Row({ space: 8 }) {
            Text(patient.name)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333');

            if (patient.isToday) {
              Text('今日')
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(8)
                .backgroundColor('#1677FF');
            }
          }
          .width('100%');

          if (patient.phone) {
            Text(`${patient.phone.substring(0, 3)}****${patient.phone.substring(7)}`)
              .fontSize(13)
              .fontColor('#888888');
          }

          if (patient.periodText) {
            Text(`${patient.periodText}${patient.statusText ? ' · ' + patient.statusText : ''}`)
              .fontSize(12)
              .fontColor('#666666');
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1);

        Column({ space: 6 }) {
          if (patient.statusText) {
            Text(this.getStatusBadgeText(patient.statusText))
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .backgroundColor(this.getStatusBadgeColor(patient.status));
          }

          Text('>')
            .fontSize(16)
            .fontColor('#CCCCCC');
        }
        .alignItems(HorizontalAlign.End);
      }
      .width('100%')
      .padding(12);

      if (patient.isToday && patient.appointmentNo) {
        Row() {
          Text('挂号单号: ')
            .fontSize(12)
            .fontColor('#999999');
          Text(patient.appointmentNo)
            .fontSize(12)
            .fontColor('#666666')
            .layoutWeight(1);
          
          if (patient.fee) {
            Text(`¥${patient.fee}`)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F');
          }
        }
        .width('100%')
        .padding({ left: 12, right: 12, bottom: 8 })
        .border({
          width: { top: 1 },
          color: '#F0F0F0'
        });
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
    .margin({ bottom: 10 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/DoctorPatientManagementPage',
        params: {
          patientId: patient.patientId,
          patientName: patient.name,
          doctorId: this.doctorId,
          patientData: {
            id: patient.patientId,
            name: patient.name,
            phone: patient.phone,
            avatar: patient.avatar,
            appointmentId: patient.appointmentId,
            scheduleDate: patient.scheduleDate,
            schedulePeriod: patient.schedulePeriod,
            status: patient.status,
            periodText: patient.periodText,
            statusText: patient.statusText,
            fee: patient.fee,
            appointmentNo: patient.appointmentNo
          }
        }
      });
    });
  }

  private getStatusBadgeText(statusText: string): string {
    switch (statusText) {
      case '待确认': return '待确认';
      case '已确认': return '已确认';
      case '就诊中': return '就诊中';
      case '已取消': return '已取消';
      case '已完成': return '已完成';
      default: return statusText;
    }
  }

  private getStatusBadgeColor(status: number | undefined): string {
    if (status === undefined || status === null) return '#999999';
    
    switch (status) {
      case 0: return '#FAAD14';
      case 1: return '#1677FF';
      case 2: return '#52C41A';
      case 3: return '#FF4D4F';
      case 4: return '#52C41A';
      default: return '#999999';
    }
  }
}
