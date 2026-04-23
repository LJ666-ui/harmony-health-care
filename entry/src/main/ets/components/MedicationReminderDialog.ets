import { GlobalTheme } from '../global';

interface ReminderData {
  medicineName: string;
  dosage: string;
  time: string;
  reminderId?: string;
}

@Component
export struct MedicationReminderDialog {
  @Prop isVisible: boolean = false;
  @Prop reminderData: ReminderData | null = null;
  @State showAnimation: boolean = false;

  private onLaterCallback?: () => void;
  private onCloseCallback?: () => void;

  aboutToAppear(): void {
    if (this.isVisible) {
      setTimeout(() => {
        this.showAnimation = true;
      }, 50);
    }
  }

  setOnLater(callback: () => void): MedicationReminderDialog {
    this.onLaterCallback = callback;
    return this;
  }

  setOnClose(callback: () => void): MedicationReminderDialog {
    this.onCloseCallback = callback;
    return this;
  }

  handleLater(): void {
    console.log('[MedicationReminder] 用户选择稍后提醒');
    if (this.onLaterCallback) {
      this.onLaterCallback();
    }
    this.close();
  }

  handleClose(): void {
    console.log('[MedicationReminder] 用户选择立即关闭');
    if (this.onCloseCallback) {
      this.onCloseCallback();
    }
    this.close();
  }

  close(): void {
    this.showAnimation = false;
    setTimeout(() => {
      // 通知父组件关闭
    }, 300);
  }

  build() {
    if (this.isVisible && this.reminderData) {
      Column() {
        Text('')
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.6)')
          .onClick(() => this.handleClose());

        Column() {
          Column() {
            Row() {
              Text('⏰')
                .fontSize(40)
                .margin({ right: 12 });
              
              Column() {
                Text('用药时间到了！')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
                  .margin({ bottom: 4 });
                
                Text(this.reminderData.time)
                  .fontSize(16)
                  .fontColor('#666666');
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .margin({ bottom: 24 });

            Divider()
              .color('#F0F0F0')
              .strokeWidth(1)
              .margin({ bottom: 20 });

            Column() {
              Text('💊 药品信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);

              Row() {
                Text('药品名称：')
                  .fontSize(14)
                  .fontColor('#666666');
                Text(this.reminderData.medicineName)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF')
                  .layoutWeight(1);
              }
              .width('100%')
              .margin({ bottom: 10 });

              Row() {
                Text('服 用 量：')
                  .fontSize(14)
                  .fontColor('#666666');
                Text(this.reminderData.dosage)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                  .layoutWeight(1);
              }
              .width('100%');

              Row() {
                Text('服药时间：')
                  .fontSize(14)
                  .fontColor('#666666');
                Text(this.reminderData.time)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#52C41A')
                  .layoutWeight(1);
              }
              .width('100%')
              .margin({ top: 10 });
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .margin({ bottom: 24 });

            Column() {
              Text('📌 温馨提示')
                .fontSize(13)
                .fontColor('#999999')
                .textAlign(TextAlign.Center);
              Text('按时服药，早日康复！')
                .fontSize(13)
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Bold)
                .margin({ top: 4 })
                .textAlign(TextAlign.Center);
            }
            .width('100%')
            .margin({ bottom: 24 });

            Row({ space: 16 }) {
              Button('⏱️ 稍后提醒')
                .layoutWeight(1)
                .height(48)
                .fontSize(16)
                .backgroundColor('#FFFFFF')
                .fontColor('#1677FF')
                .borderRadius(24)
                .border({ width: 2, color: '#1677FF' })
                .onClick(() => this.handleLater());
              
              Button('✓ 立即关闭')
                .layoutWeight(1)
                .height(48)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#1677FF')
                .fontColor('#FFFFFF')
                .borderRadius(24)
                .onClick(() => this.handleClose());
            }
            .width('100%');
          }
          .width('100%')
          .padding(28)
        }
        .width('85%')
        .maxWidth(360)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .shadow({
          radius: 30,
          color: 'rgba(0, 0, 0, 0.2)',
          offsetX: 0,
          offsetY: 10
        })
        .position({ x: '7.5%', y: '25%' })
        .scale({ x: this.showAnimation ? 1 : 0.8, y: this.showAnimation ? 1 : 0.8 })
        .opacity(this.showAnimation ? 1 : 0)
        .transition({
          type: TransitionType.All,
          duration: 300,
          curve: Curve.EaseOut
        });
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 });
    } else {
      Column().width(0).height(0);
    }
  }
}
