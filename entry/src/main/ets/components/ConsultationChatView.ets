import { router } from '@kit.ArkUI';

@Component
export struct ConsultationChatView {
  @Prop patientId: number = 0;
  @Prop patientName: string = '';
  @Prop doctorId: number = 0;
  @Prop doctorName: string = '';

  build() {
    Column() {
      Button('进入对话')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/DoctorChatPage',
            params: {
              doctorId: this.doctorId,
              doctorName: this.doctorName,
              currentUserId: this.doctorId,
              otherUserId: this.patientId,
              otherUserName: this.patientName,
              isDoctor: true
            }
          });
        });
    }
    .width('100%')
    .padding(16);
  }
}
