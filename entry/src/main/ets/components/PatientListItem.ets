import { PatientInfo, GenderDisplayText, PatientStatusText } from '../model/PatientModel';

@Component
export struct PatientListItem {
  @Prop patient: PatientInfo;
  @Prop isViewed: boolean = false;
  onItemClick?: (patient: PatientInfo) => void;

  build() {
    Row() {
      Column() {
        Row() {
          Text(this.patient.patientName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()
            .width(8)

          Text(GenderDisplayText[this.patient.gender])
            .fontSize(12)
            .fontColor('#666666')

          Blank()
            .width(8)

          Text(`${this.patient.age}岁`)
            .fontSize(12)
            .fontColor('#666666')

          if (this.patient.status) {
            Blank()
              .width(8)

            Text(PatientStatusText[this.patient.status])
              .fontSize(12)
              .fontColor('#007DFF')
              .backgroundColor('#E3F2FD')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
          }
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          if (this.patient.department) {
            Text(`科室: ${this.patient.department}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ right: 16 })
          }

          if (this.patient.bedNumber) {
            Text(`床位: ${this.patient.bedNumber}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ right: 16 })
          }

          if (this.patient.medicalRecordNumber) {
            Text(`病历号: ${this.patient.medicalRecordNumber}`)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .width('100%')

        if (this.patient.diagnosis) {
          Text(`诊断: ${this.patient.diagnosis}`)
            .fontSize(12)
            .fontColor('#FF6B6B')
            .margin({ top: 6 })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.isViewed) {
        Text('已查看')
          .fontSize(10)
          .fontColor('#CCCCCC')
          .margin({ right: 8 })
      }

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(16)
        .height(16)
        .margin({ right: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.isViewed ? '#F9F9F9' : '#FFFFFF')
    .borderRadius(8)
    .margin({ left: 16, right: 16, top: 8, bottom: 8 })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.patient);
      }
    })
  }
}
