import { PatientDetail, GenderDisplayText, PatientStatusText, PatientGender, PatientStatus } from '../model/PatientModel';
import { LoadingState } from '../model/StateModel';
import { PatientDetailViewModel } from '../viewmodel/PatientDetailViewModel';
import { StateComponent } from '../components/CommonComponents';
import { RouterUtil } from '../utils/RouterUtil';
import { AuditLogger } from '../utils/AuditLogger';
import { SimplePatientData } from '../utils/PatientDataCache';

@Entry
@Component
struct PatientDetailPage {
  @State viewModel: PatientDetailViewModel | null = null;
  @State loadingState: LoadingState = LoadingState.IDLE;
  @State errorMessage: string = '';
  @State patientName: string = '';
  @State displayDetail: PatientDetail | null = null;
  @State simplePatientData: SimplePatientData | null = null;
  private auditLogger: AuditLogger = AuditLogger.getInstance();

  async aboutToAppear() {
    const params = RouterUtil.getParams();
    const patientId = params['patientId'] as string;
    const patientName = params['patientName'] as string;
    const patientDataJson = params['patientDataJson'] as string;
    
    console.log('========== PatientDetailPage START ==========');
    console.log('PatientDetailPage - aboutToAppear');
    console.log('PatientDetailPage - patientId:', patientId);
    console.log('PatientDetailPage - patientName:', patientName);
    console.log('PatientDetailPage - patientDataJson:', patientDataJson);
    console.log('PatientDetailPage - All params:', JSON.stringify(params));
    
    if (patientId) {
      this.patientName = patientName || '';
      
      let patientData: SimplePatientData | null = null;
      
      if (patientDataJson && patientDataJson.length > 0) {
        try {
          console.log('PatientDetailPage - Parsing JSON data...');
          patientData = JSON.parse(patientDataJson) as SimplePatientData;
          console.log('PatientDetailPage - ✅ Parsed successfully, ID:', patientData.id);
        } catch (e) {
          console.error('PatientDetailPage - Failed to parse JSON:', e);
        }
      }
      
      if (patientData && patientData.id > 0) {
        console.log('PatientDetailPage - ✅ Using parsed data, no API call');
        this.simplePatientData = patientData;
        this.displayDetail = this.convertSimpleToDetail(patientData);
        this.loadingState = LoadingState.SUCCESS;
        console.log('========== PatientDetailPage SUCCESS ==========');
        return;
      }
      
      console.log('PatientDetailPage - ⚠️ No valid data from JSON');
      
      if (params['patientData']) {
        console.log('PatientDetailPage - Trying to read patientData object...');
        try {
          const rawData = params['patientData'];
          console.log('PatientDetailPage - rawData type:', typeof rawData);
          console.log('PatientDetailPage - rawData value:', JSON.stringify(rawData));
          
          if (typeof rawData === 'object' && rawData !== null) {
            const dataObj = rawData as Record<string, Object>;
            patientData = {
              id: Number(dataObj['id']) || 0,
              username: String(dataObj['username'] || ''),
              realName: String(dataObj['realName'] || ''),
              phone: String(dataObj['phone'] || ''),
              age: Number(dataObj['age']) || 0,
              gender: Number(dataObj['gender']) || 0,
              idCard: String(dataObj['idCard'] || ''),
              hospital: String(dataObj['hospital'] || ''),
              department: String(dataObj['department'] || ''),
              bedNumber: String(dataObj['bedNumber'] || ''),
              diagnosis: String(dataObj['diagnosis'] || '')
            };
            
            if (patientData.id > 0) {
              console.log('PatientDetailPage - ✅ Got data from object, ID:', patientData.id);
              this.displayDetail = this.convertSimpleToDetail(patientData);
              this.loadingState = LoadingState.SUCCESS;
              console.log('========== PatientDetailPage SUCCESS FROM OBJECT ==========');
              return;
            }
          }
        } catch (e) {
          console.error('PatientDetailPage - Failed to read object:', e);
        }
      }
      
      console.log('PatientDetailPage - ❌ All methods failed, using API');
      this.viewModel = new PatientDetailViewModel(patientId);
      await this.loadPatientDetail();
    } else {
      console.error('PatientDetailPage - No patientId provided');
      this.loadingState = LoadingState.ERROR;
      this.errorMessage = '未提供患者ID';
    }
  }

  private convertSimpleToDetail(data: SimplePatientData): PatientDetail {
    return {
      patientId: String(data.id),
      patientName: data.realName || data.username || '未知',
      gender: data.gender === 1 ? PatientGender.MALE : (data.gender === 2 ? PatientGender.FEMALE : PatientGender.UNKNOWN),
      age: data.age || 0,
      phoneNumber: data.phone,
      idCardNumber: data.idCard,
      department: data.department,
      bedNumber: data.bedNumber,
      diagnosis: data.diagnosis,
      status: PatientStatus.IN_HOSPITAL,
      updateTime: Date.now()
    };
  }

  async loadPatientDetail() {
    if (this.viewModel) {
      await this.viewModel.loadPatientDetail();
      this.updateState();
    }
  }

  updateState() {
    if (this.viewModel) {
      const state = this.viewModel.getState();
      this.loadingState = state.loadingState;
      this.errorMessage = state.errorMessage || '';
      this.patientName = this.viewModel.getPatientName();
      this.displayDetail = state.displayDetail;
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            RouterUtil.back();
          })

        Text('患者基本信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 40 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      if (this.loadingState === LoadingState.LOADING ||
          this.loadingState === LoadingState.ERROR ||
          this.loadingState === LoadingState.EMPTY) {
        StateComponent({
          state: this.loadingState,
          errorMessage: this.errorMessage,
          onRetry: () => {
            this.loadPatientDetail();
          }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column() {
            if (this.viewModel && this.viewModel.getState().isFromCache) {
              Row() {
                Image($r('app.media.startIcon'))
                  .width(16)
                  .height(16)
                  .margin({ right: 8 })

                Text('数据可能不是最新')
                  .fontSize(12)
                  .fontColor('#FF9800')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor('#FFF3E0')
              .margin({ bottom: 12 })
            }

            if (this.displayDetail) {
              this.BasicInfoCard()
              this.ContactInfoCard()
              
              if (this.displayDetail.emergencyContact) {
                this.EmergencyContactCard()
              }
              
              if (this.displayDetail.hospitalizationInfo) {
                this.HospitalizationCard()
              }
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 16 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  BasicInfoCard() {
    Column() {
      Text('基本信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Row() {
        Text('姓名:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(this.displayDetail?.patientName || '')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('性别:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(GenderDisplayText[this.displayDetail?.gender || 'UNKNOWN'])
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('年龄:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(`${this.displayDetail?.age || 0}岁`)
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.displayDetail?.birthDate) {
        Row() {
          Text('出生日期:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          Text(new Date(this.displayDetail.birthDate).toLocaleDateString())
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      if (this.displayDetail?.status) {
        Row() {
          Text('状态:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          Text(PatientStatusText[this.displayDetail.status])
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  @Builder
  ContactInfoCard() {
    Column() {
      Text('联系方式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      if (this.displayDetail?.phoneNumber) {
        Row() {
          Text('手机号:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          Text(this.displayDetail.phoneNumber)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      if (this.displayDetail?.idCardNumber) {
        Row() {
          Text('身份证号:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          Text(this.displayDetail.idCardNumber)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      if (this.displayDetail?.medicalRecordNumber) {
        Row() {
          Text('病历号:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          Text(this.displayDetail.medicalRecordNumber)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      if (this.displayDetail?.address) {
        Row() {
          Text('地址:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          Text(this.displayDetail.address)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  @Builder
  EmergencyContactCard() {
    Column() {
      Text('紧急联系人')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Row() {
        Text('姓名:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(this.displayDetail?.emergencyContact?.name || '')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('电话:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(this.displayDetail?.emergencyContact?.phone || '')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('关系:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(this.displayDetail?.emergencyContact?.relationship || '')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  @Builder
  HospitalizationCard() {
    Column() {
      Text('住院信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Row() {
        Text('医院:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(this.displayDetail?.hospitalizationInfo?.hospital || '')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('科室:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(this.displayDetail?.hospitalizationInfo?.department || '')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('床位号:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(this.displayDetail?.hospitalizationInfo?.bedNumber || '')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      Row() {
        Text('入院日期:')
          .fontSize(14)
          .fontColor('#666666')
          .width(80)

        Text(new Date(this.displayDetail?.hospitalizationInfo?.admissionDate || 0).toLocaleDateString())
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.displayDetail?.hospitalizationInfo?.primaryDiagnosis) {
        Row() {
          Text('诊断:')
            .fontSize(14)
            .fontColor('#666666')
            .width(80)

          Text(this.displayDetail.hospitalizationInfo.primaryDiagnosis)
            .fontSize(14)
            .fontColor('#FF6B6B')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}
