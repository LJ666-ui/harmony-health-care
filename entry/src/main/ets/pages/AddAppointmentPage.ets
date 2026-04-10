import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { ButtonWithFeedback } from '../components/ClickFeedback';
import { Appointment } from '../models/HealthData';
import { GlobalTheme } from '../global';

@Entry
@Component
struct AddAppointmentPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedHospital: string = '';
  @State selectedDepartment: string = '';
  @State selectedDate: string = '';
  @State selectedTime: string = '';
  @State errorMessage: string = '';

  private hospitals: string[] = ['星云综合医院', '协和医疗中心', '仁爱专科医院', '康宁中医医院'];
  private departments: string[] = ['内科', '外科', '骨科', '康复科', '老年病科'];
  private dates: string[] = [];
  private times: string[] = ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30'];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }

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

  validateForm(): boolean {
    this.errorMessage = '';

    if (!this.selectedHospital) {
      this.errorMessage = '请选择医院';
      return false;
    }

    if (!this.selectedDepartment) {
      this.errorMessage = '请选择科室';
      return false;
    }

    if (!this.selectedDate) {
      this.errorMessage = '请选择日期';
      return false;
    }

    if (!this.selectedTime) {
      this.errorMessage = '请选择时间';
      return false;
    }

    const selectedDateObj = new Date(this.selectedDate);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (selectedDateObj < today) {
      this.errorMessage = '预约日期不能早于今天';
      return false;
    }

    return true;
  }

  handleSubmit(): void {
    if (!this.validateForm()) {
      promptAction.showToast({
        message: this.errorMessage,
        duration: 2000
      });
      return;
    }

    const storedAppointments = AppStorage.get<Appointment[]>('appointments');
    const appointments: Appointment[] = storedAppointments ? [...storedAppointments] : [];

    const newAppointment: Appointment = {
      id: Date.now().toString(),
      doctor: this.getDoctorByDepartment(),
      specialty: this.selectedDepartment,
      hospital: this.selectedHospital,
      date: this.selectedDate,
      time: this.selectedTime,
      status: 'pending',
      location: `${this.selectedDepartment}门诊`,
      notes: '',
      avatarColor: '#1677FF',
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    appointments.unshift(newAppointment);
    AppStorage.setOrCreate<Appointment[]>('appointments', appointments);

    promptAction.showToast({
      message: '预约提交成功',
      duration: 1500
    });

    setTimeout(() => {
      router.back();
    }, 500);
  }

  getDoctorByDepartment(): string {
    const doctorMap: Record<string, string> = {
      '内科': '张医生',
      '外科': '李医生',
      '骨科': '王医生',
      '康复科': '赵医生',
      '老年病科': '刘医生'
    };
    return doctorMap[this.selectedDepartment] || '医生';
  }

  build() {
    Column() {
      Header({ title: '新增预约', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('填写预约信息')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('选择医院 *')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedHospital || '请选择')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(this.selectedHospital ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
              Blank();
              Text('▼')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT);
            }
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
            .backgroundColor(GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              const currentIndex = this.hospitals.indexOf(this.selectedHospital);
              const nextIndex = (currentIndex + 1) % this.hospitals.length;
              this.selectedHospital = this.hospitals[nextIndex];
            });

            Text('选择科室 *')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedDepartment || '请选择')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(this.selectedDepartment ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
              Blank();
              Text('▼')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT);
            }
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
            .backgroundColor(GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              const currentIndex = this.departments.indexOf(this.selectedDepartment);
              const nextIndex = (currentIndex + 1) % this.departments.length;
              this.selectedDepartment = this.departments[nextIndex];
            });

            Text('选择日期 *')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedDate || '请选择')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(this.selectedDate ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
              Blank();
              Text('▼')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT);
            }
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
            .backgroundColor(GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              const currentIndex = this.dates.indexOf(this.selectedDate);
              const nextIndex = (currentIndex + 1) % this.dates.length;
              this.selectedDate = this.dates[nextIndex];
            });

            Text('选择时间 *')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .alignSelf(ItemAlign.Start);

            Row() {
              Text(this.selectedTime || '请选择')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(this.selectedTime ? GlobalTheme.THEME_COLOR : GlobalTheme.TEXT_HINT);
              Blank();
              Text('▼')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT);
            }
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .padding({ left: GlobalTheme.getSpacingMD(this.isElderMode), right: GlobalTheme.getSpacingMD(this.isElderMode) })
            .backgroundColor(GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              const currentIndex = this.times.indexOf(this.selectedTime);
              const nextIndex = (currentIndex + 1) % this.times.length;
              this.selectedTime = this.times[nextIndex];
            });
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor(GlobalTheme.CARD_BG)
          .borderRadius(GlobalTheme.RADIUS_LG);

          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#FF4D4F')
              .width('100%')
              .padding(8)
              .backgroundColor('#FFF2F0')
              .borderRadius(8)
              .textAlign(TextAlign.Center);
          }

          ButtonWithFeedback({
            text: '提交预约',
            type: 'primary',
            btnSize: 'large',
            onItemClick: () => this.handleSubmit()
          })
            .width('100%');

          ButtonWithFeedback({
            text: '取消',
            type: 'secondary',
            btnSize: 'large',
            onItemClick: () => router.back()
          })
            .width('100%')
            .margin({ top: 8 });
        }
        .width('85%')
        .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
