import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import { PatientBasicInfo, PatientBasicInfoHelper } from '../models/DoctorPatientModels';
import { SettingsUtil } from '../utils/SettingsUtil';

@Entry
@Component
struct DoctorPatientListPage {
  @State patients: PatientBasicInfo[] = [];
  @State isLoading: boolean = true;
  @State errorMessage: string = '';
  @State doctorId: number = 0;

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
      hilog.info(0x0000, 'DoctorPatientListPage', `请求URL: ${serverUrl}/api/doctor/${this.doctorId}/patients`);

      // 调用新的综合API获取患者的详细信息
      const response = await http.createHttp().request(
        `${serverUrl}/api/doctor/${this.doctorId}/patients`,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          readTimeout: 10000,
          connectTimeout: 10000
        }
      );

      hilog.info(0x0000, 'DoctorPatientListPage', `响应状态码: ${response.responseCode}`);
      hilog.info(0x0000, 'DoctorPatientListPage', `响应结果: ${response.result}`);

      if (response.responseCode === 200) {
        const result: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        hilog.info(0x0000, 'DoctorPatientListPage', `解析后的code: ${result['code']}, message: ${result['message']}`);

        const rawData: ESObject | ESObject[] | null = result['data'];
        const patientsData: ESObject[] = Array.isArray(rawData) ? rawData : [];

        hilog.info(0x0000, 'DoctorPatientListPage', `获取到${patientsData.length}位患者`);

        // 解析返回的患者详细信息
        this.patients = [];
        for (let i = 0; i < patientsData.length; i++) {
          const raw: ESObject = patientsData[i] as ESObject;
          if (raw == null) {
            continue;
          }

          const patient: PatientBasicInfo = new PatientBasicInfo();

          const patientIdVal: string | number | boolean | null | undefined = raw['patientId'];
          patient.id = typeof patientIdVal === 'number' ? patientIdVal : 0;

          const usernameVal: string | number | boolean | null | undefined = raw['username'];
          patient.name = typeof usernameVal === 'string' ? usernameVal : '未知';

          const ageVal: string | number | boolean | null | undefined = raw['age'];
          patient.age = typeof ageVal === 'number' ? ageVal : 0;

          const phoneVal: string | number | boolean | null | undefined = raw['phone'];
          patient.phone = typeof phoneVal === 'string' ? phoneVal : '';

          const idCardVal: string | number | boolean | null | undefined = raw['idCard'];
          patient.idCard = typeof idCardVal === 'string' ? idCardVal : '';

          this.patients.push(patient);
        }

        this.isLoading = false;
        
        if (this.patients.length > 0) {
          hilog.info(0x0000, 'DoctorPatientListPage', `第一位患者: ${this.patients[0].name}, ${this.patients[0].age}岁`);
        } else {
          hilog.warn(0x0000, 'DoctorPatientListPage', '患者列表为空');
        }
      } else {
        let errorDetail = '';
        if (response.result) {
          try {
            const errorResult: ESObject = JSON.parse(response.result as string) as ESObject;
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
      // 捕获并显示详细的网络错误
      let errorMsg = '未知错误';
      if (error) {
        if (typeof error === 'string') {
          errorMsg = error;
        } else {
          errorMsg = JSON.stringify(error);
        }
      }
      
      hilog.error(0x0000, 'DoctorPatientListPage', `loadPatients 异常: ${errorMsg}`);
      
      // 根据错误类型给出更友好的提示
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
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.errorMessage) {
        Column() {
          Text('📋')
            .fontSize(56)
            .margin({ bottom: 16 });
          Text(this.errorMessage)
            .fontSize(16)
            .fontColor('#666666')
            .margin({ bottom: 8 });
          Text('请稍后重试')
            .fontSize(14)
            .fontColor('#999999');
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else if (this.patients.length === 0) {
        Column() {
          Text('👥')
            .fontSize(56)
            .margin({ bottom: 16 });
          Text('暂无患者')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 8 });
          Text('患者主动联系您后，将在此显示')
            .fontSize(14)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .width('75%')
            .lineHeight(20);
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        Scroll() {
          Column() {
            ForEach(this.patients, (patient: PatientBasicInfo) => {
              Row() {
                Stack({ alignContent: Alignment.Center }) {
                  Circle()
                    .width(50)
                    .height(50)
                    .fill('#1677FF');
                  Text(patient.name.charAt(0))
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF');
                }
                .margin({ right: 12 });

                Column({ space: 4 }) {
                  Text(patient.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333');

                  if (patient.age > 0) {
                    Text(`${patient.age}岁${patient.phone ? ' · ' + patient.phone.substring(0, 3) + '****' + patient.phone.substring(7) : ''}`)
                      .fontSize(13)
                      .fontColor('#888888');
                  } else {
                    Text('年龄未知')
                      .fontSize(13)
                      .fontColor('#888888');
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                Text('>')
                  .fontSize(18)
                  .fontColor('#CCCCCC');
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 10 })
              .shadow({ radius: 6, color: '#00000008', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/DoctorPatientManagementPage',
                  params: {
                    patientId: patient.id,
                    patientName: patient.name,
                    doctorId: this.doctorId,
                    patientData: {
                      id: patient.id,
                      name: patient.name,
                      age: patient.age,
                      phone: patient.phone,
                      idCard: patient.idCard
                    }
                  }
                });
              });
            }, (patient: PatientBasicInfo) => patient.id.toString());
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 48 });
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
