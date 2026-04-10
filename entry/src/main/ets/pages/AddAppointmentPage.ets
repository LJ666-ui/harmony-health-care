import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

@Entry
@Component
struct AddAppointmentPage {
  @State selectedHospital: string = '星云综合医院';
  @State selectedDepartment: string = '内科';
  @State selectedDate: string = '';
  @State selectedTime: string = '';

  private hospitals: string[] = ['星云综合医院', '协和医疗中心', '仁爱专科医院', '康宁中医医院'];
  private departments: string[] = ['内科', '外科', '骨科', '康复科', '老年病科'];
  private dates: string[] = [];
  private times: string[] = ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30'];

  aboutToAppear(): void {
    const today = new Date();
    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      this.dates.push(`${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`);
    }
    if (this.dates.length > 0) {
      this.selectedDate = this.dates[0];
    }
    this.selectedTime = this.times[0];
  }

  build() {
    Column() {
      Header({ title: '新增预约', showBack: true });

      Scroll() {
        Column({ space: 20 }) {
          Text('填写预约信息')
            .fontSize(20)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 16, bottom: 8 });

          Column({ space: 12 }) {
            Text('选择医院')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedHospital)
                .fontSize(15)
                .fontColor('#1677FF');
              Blank();
              Text('▼')
                .fontSize(12)
                .fontColor('#999999');
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#e0e0e0' })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectedHospital = this.hospitals[(this.hospitals.indexOf(this.selectedHospital) + 1) % this.hospitals.length];
            });

            Text('选择科室')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedDepartment)
                .fontSize(15)
                .fontColor('#1677FF');
              Blank();
              Text('▼')
                .fontSize(12)
                .fontColor('#999999');
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#e0e0e0' })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectedDepartment = this.departments[(this.departments.indexOf(this.selectedDepartment) + 1) % this.departments.length];
            });

            Text('选择日期')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedDate)
                .fontSize(15)
                .fontColor('#1677FF');
              Blank();
              Text('▼')
                .fontSize(12)
                .fontColor('#999999');
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#e0e0e0' })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectedDate = this.dates[(this.dates.indexOf(this.selectedDate) + 1) % this.dates.length];
            });

            Text('选择时间')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedTime)
                .fontSize(15)
                .fontColor('#1677FF');
              Blank();
              Text('▼')
                .fontSize(12)
                .fontColor('#999999');
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#e0e0e0' })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectedTime = this.times[(this.times.indexOf(this.selectedTime) + 1) % this.times.length];
            });
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12);

          Button('提交预约')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(8)
            .onClick(() => {
              router.back();
            });
        }
        .width('85%')
        .padding({ bottom: 24 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
