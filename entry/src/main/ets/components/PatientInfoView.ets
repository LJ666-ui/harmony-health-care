import { hilog } from '@kit.PerformanceAnalysisKit';
import { PatientBasicInfo, PatientHealthProfile, PatientVisitRecord } from '../models/DoctorPatientModels';
import { PatientBasicInfoHelper, PatientHealthProfileHelper, PatientVisitRecordHelper } from '../models/DoctorPatientModels';
import { PatientService } from '../services/PatientService';
import { Loading } from './Loading.ets';
import { EmptyState } from './EmptyState.ets';

@Component
export struct PatientInfoView {
  @Prop patientId: number = 0;
  @Prop patientData: ESObject | null = null;
  @State basicInfo: PatientBasicInfo | null = null;
  @State healthProfile: PatientHealthProfile | null = null;
  @State visitRecords: PatientVisitRecord[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (this.patientData) {
      this.initFromPatientData();
    } else {
      this.loadPatientInfo();
    }
  }

  private initFromPatientData(): void {
    const data: ESObject = this.patientData as ESObject;

    const info: PatientBasicInfo = new PatientBasicInfo();

    const idVal: string | number | boolean | null | undefined = data['id'];
    info.id = typeof idVal === 'number' ? idVal : 0;

    const nameVal: string | number | boolean | null | undefined = data['name'];
    info.name = typeof nameVal === 'string' ? nameVal : '未知';

    const ageVal: string | number | boolean | null | undefined = data['age'];
    info.age = typeof ageVal === 'number' ? ageVal : 0;

    const phoneVal: string | number | boolean | null | undefined = data['phone'];
    info.phone = typeof phoneVal === 'string' ? phoneVal : '';

    const idCardVal: string | number | boolean | null | undefined = data['idCard'];
    info.idCard = typeof idCardVal === 'string' ? idCardVal : '';

    const genderVal: string | number | boolean | null | undefined = data['gender'];
    info.gender = typeof genderVal === 'string' ? genderVal : (info.idCard && info.idCard.length >= 17 ? (parseInt(info.idCard.substring(16, 17)) % 2 === 0 ? '女' : '男') : '-');

    this.basicInfo = info;
    this.healthProfile = new PatientHealthProfile();
    this.visitRecords = [];
    this.isLoading = false;

    hilog.info(0x0000, 'PatientInfoView', `从传入数据初始化患者信息: ${info.name}, ${info.age}岁`);
  }

  async loadPatientInfo(): Promise<void> {
    this.basicInfo = await PatientService.getInstance().getPatientInfo(this.patientId);
    this.healthProfile = await PatientService.getInstance().getHealthProfile(this.patientId);
    this.visitRecords = await PatientService.getInstance().getVisitRecords(this.patientId);
    this.isLoading = false;
  }

  desensitizeIdCard(idCard: string): string {
    if (!idCard || idCard.length < 8) {
      return idCard;
    }
    const prefix = idCard.substring(0, 4);
    const suffix = idCard.substring(idCard.length - 4);
    const stars = '*'.repeat(idCard.length - 8);
    return prefix + stars + suffix;
  }

  build() {
    Column() {
      if (this.isLoading) {
        Loading({ show: true });
      } else {
        Column({ space: 16 }) {
          Column({ space: 12 }) {
            Text('基本信息')
              .fontSize(16)
              .fontWeight('bold')
              .fontColor('#333333')
              .width('100%');

            Column({ space: 8 }) {
              Row({ space: 12 }) {
                Text('姓名')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.basicInfo?.name || '-')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('年龄')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.basicInfo?.age.toString() || '-')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('性别')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.basicInfo?.gender || '-')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('电话')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.basicInfo?.phone || '-')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('身份证')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.desensitizeIdCard(this.basicInfo?.idCard || ''))
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');
            }
            .padding(12)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8);
          }
          .width('100%');

          Column({ space: 12 }) {
            Text('健康档案')
              .fontSize(16)
              .fontWeight('bold')
              .fontColor('#333333')
              .width('100%');

            Column({ space: 8 }) {
              Row({ space: 12 }) {
                Text('过敏史')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.healthProfile?.allergies || '无')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('既往病史')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.healthProfile?.pastHistory || '无')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');

              Row({ space: 12 }) {
                Text('家族病史')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(70);
                Text(this.healthProfile?.familyHistory || '无')
                  .fontSize(14)
                  .fontColor('#333333');
              }
              .width('100%');
            }
            .padding(12)
            .width('100%')
            .backgroundColor('#F5F5F5')
            .borderRadius(8);
          }
          .width('100%');

          Column({ space: 12 }) {
            Text('历史就诊记录')
              .fontSize(16)
              .fontWeight('bold')
              .fontColor('#333333')
              .width('100%');

            if (this.visitRecords.length > 0) {
              Column({ space: 8 }) {
                ForEach(this.visitRecords, (item: PatientVisitRecord, index: number) => {
                  Column({ space: 8 }) {
                    Row({ space: 12 }) {
                      Text('就诊时间')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width(70);
                      Text(item.visitDate)
                        .fontSize(14)
                        .fontColor('#333333');
                    }
                    .width('100%');

                    Row({ space: 12 }) {
                      Text('医院')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width(70);
                      Text(item.hospital)
                        .fontSize(14)
                        .fontColor('#333333');
                    }
                    .width('100%');

                    Row({ space: 12 }) {
                      Text('科室')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width(70);
                      Text(item.department)
                        .fontSize(14)
                        .fontColor('#333333');
                    }
                    .width('100%');

                    Row({ space: 12 }) {
                      Text('医生')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width(70);
                      Text(item.doctor)
                        .fontSize(14)
                        .fontColor('#333333');
                    }
                    .width('100%');

                    Row({ space: 12 }) {
                      Text('诊断')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width(70);
                      Text(item.diagnosis)
                        .fontSize(14)
                        .fontColor('#333333');
                    }
                    .width('100%');

                    Row({ space: 12 }) {
                      Text('主诉')
                        .fontSize(14)
                        .fontColor('#666666')
                        .width(70);
                      Text(item.chiefComplaint)
                        .fontSize(14)
                        .fontColor('#333333');
                    }
                    .width('100%');
                  }
                  .padding(12)
                  .width('100%')
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8);
                });
              }
            } else {
              EmptyState({ icon: '📋', title: '暂无就诊记录', description: '该患者暂无历史就诊记录', buttonText: '' });
            }
          }
          .width('100%');
        }
        .width('100%')
        .padding(16);
      }
    }
    .width('100%')
    .height('100%');
  }
}
