import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Appointment } from '../models/HealthData';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

@Entry
@Component
struct AppointmentTimeSelectPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State hospitalName: string = '';
  @State departmentName: string = '';
  @State departmentLocation: string = '';
  @State selectedDate: string = '';
  @State selectedTime: string = '';
  @State dates: string[] = [];
  @State dateLabels: string[] = [];
  @State timeSlots: string[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    console.log('AppointmentTimeSelectPage aboutToAppear 开始');

    try {
      if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
        AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
      } else {
        this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
      }

      const params = router.getParams() as Record<string, Object> | undefined;

      if (params) {
        console.log('接收到参数:', JSON.stringify(params));

        if (params['hospitalName']) {
          this.hospitalName = String(params['hospitalName']);
          console.log('设置医院名称:', this.hospitalName);
        }
        if (params['departmentName']) {
          this.departmentName = String(params['departmentName']);
          console.log('设置科室名称:', this.departmentName);
        }
        if (params['departmentLocation']) {
          this.departmentLocation = String(params['departmentLocation']);
          console.log('设置科室位置:', this.departmentLocation);
        }
      }

      this.initDates();
      this.initTimeSlots();

      if (this.dates.length > 0) {
        this.selectedDate = this.dates[0];
      }
      if (this.timeSlots.length > 0) {
        this.selectedTime = this.timeSlots[0];
      }

      this.isLoading = false;
      console.log('AppointmentTimeSelectPage 初始化完成');
    } catch (error) {
      console.error('初始化失败:', error);
      this.isLoading = false;
    }
  }

  initDates(): void {
    const today = new Date();
    const weekDays: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);

      const dateStr = '' + date.getFullYear() + '-' +
                      this.padZero(date.getMonth() + 1) + '-' +
                      this.padZero(date.getDate());

      const weekDay = weekDays[date.getDay()];
      let label: string = '';

      if (i === 0) {
        label = '今天';
      } else if (i === 1) {
        label = '明天';
      } else {
        label = weekDay;
      }

      this.dates.push(dateStr);
      this.dateLabels.push(label);
    }

    console.log('日期列表初始化完成，共', this.dates.length, '天');
  }

  initTimeSlots(): void {
    this.timeSlots = [
      '08:00', '08:30', '09:00', '09:30',
      '10:00', '10:30', '11:00', '11:30',
      '14:00', '14:30', '15:00', '15:30',
      '16:00', '16:30'
    ];

    console.log('时间段列表初始化完成，共', this.timeSlots.length, '个时段');
  }

  confirmAppointment(): void {
    console.log('确认预约');

    if (!this.selectedDate || !this.selectedTime) {
      ToastUtil.showError('请选择完整的预约时间', 2000);
      return;
    }

    try {
      const storedAppointments = AppStorage.get<Appointment[]>('appointments');
      const appointments: Appointment[] = [];

      if (storedAppointments) {
        for (let i = 0; i < storedAppointments.length; i++) {
          appointments.push(storedAppointments[i]);
        }
      }

      const newAppointment: Appointment = {
        id: Date.now().toString(),
        doctor: '待分配',
        specialty: this.departmentName,
        hospital: this.hospitalName,
        date: this.selectedDate,
        time: this.selectedTime,
        status: 'pending',
        location: this.departmentLocation || `${this.departmentName}诊室`,
        notes: '',
        avatarColor: '#1677FF',
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      appointments.unshift(newAppointment);
      AppStorage.setOrCreate<Appointment[]>('appointments', appointments);

      console.log('预约创建成功');

      ToastUtil.showSuccess(`预约 ${this.departmentName} 成功！`, 2000);

      setTimeout(() => {
        router.back();
      }, 800);
    } catch (error) {
      console.error('预约失败:', error);
      ToastUtil.showError('预约失败，请重试', 2000);
    }
  }

  getSelectedDateLabel(): string {
    const index = this.dates.indexOf(this.selectedDate);
    if (index >= 0 && index < this.dateLabels.length) {
      return this.dateLabels[index];
    }
    return '';
  }

  formatDateDisplay(dateStr: string): string {
    if (!dateStr) return '';
    const parts = dateStr.split('-');
    if (parts.length === 3) {
      return `${parts[1]}月${parts[2]}日`;
    }
    return dateStr;
  }

  build() {
    Column() {
      Header({ title: '选择预约时间', showBack: true });

      if (this.isLoading) {
        Column() {
          Text('加载中...')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_HINT)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
            Column() {
              Text('🏥 预约信息')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight(FontWeight.Bold)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .width('100%')
                .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) })

              Row() {
                Column() {
                  Text(this.hospitalName || '未知医院')
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(GlobalTheme.THEME_COLOR)

                  Text(this.departmentName || '未知科室')
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_SECONDARY)
                    .margin({ top: 4 })

                  if (this.departmentLocation) {
                    Text(`📍 ${this.departmentLocation}`)
                      .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                      .fontColor(GlobalTheme.TEXT_HINT)
                      .margin({ top: 2 })
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(GlobalTheme.RADIUS_LG)

            Column() {
              Text('📅 选择日期')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight(FontWeight.Bold)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .width('100%')
                .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) })

              Scroll() {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.dates, (date: string, index: number) => {
                    Column() {
                      Text(this.dateLabels[index] || '')
                        .fontSize(this.isElderMode ? 14 : 12)
                        .fontColor(this.selectedDate === date ? '#FFFFFF' : GlobalTheme.TEXT_SECONDARY)

                      Text(this.formatDateDisplay(date))
                        .fontSize(this.isElderMode ? 17 : 15)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.selectedDate === date ? '#FFFFFF' : GlobalTheme.TEXT_PRIMARY)
                        .margin({ top: 4 })
                    }
                    .width(this.isElderMode ? 85 : 75)
                    .height(this.isElderMode ? 70 : 60)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(this.selectedDate === date ? GlobalTheme.THEME_COLOR : '#F5F5F5')
                    .borderRadius(GlobalTheme.RADIUS_MD)
                    .border({
                      width: this.selectedDate === date ? 2 : 1,
                      color: this.selectedDate === date ? GlobalTheme.THEME_COLOR : '#E0E0E0'
                    })
                    .onClick(() => {
                      this.selectedDate = date;
                    })
                  }, (date: string, index: number) => `date_${index}`)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(GlobalTheme.RADIUS_LG)

            Column() {
              Text('🕐 选择时间')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight(FontWeight.Bold)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .width('100%')
                .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.timeSlots, (time: string, index: number) => {
                  Text(time)
                    .fontSize(this.isElderMode ? 16 : 14)
                    .fontColor(this.selectedTime === time ? '#FFFFFF' : GlobalTheme.TEXT_PRIMARY)
                    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                    .backgroundColor(this.selectedTime === time ? GlobalTheme.THEME_COLOR : '#F5F5F5')
                    .borderRadius(GlobalTheme.RADIUS_MD)
                    .border({
                      width: this.selectedTime === time ? 2 : 1,
                      color: this.selectedTime === time ? GlobalTheme.THEME_COLOR : '#E0E0E0'
                    })
                    .onClick(() => {
                      this.selectedTime = time;
                    })
                }, (time: string, index: number) => `time_${index}`)
              }
              .width('100%')
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(GlobalTheme.RADIUS_LG)

            if (this.selectedDate && this.selectedTime) {
              Column() {
                Text('✅ 预约确认')
                  .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.SUCCESS_COLOR)
                  .width('100%')
                  .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) })

                Row() {
                  Text('📅 日期：')
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_SECONDARY)

                  Text(`${this.selectedDate} (${this.getSelectedDateLabel()})`)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                }
                .width('100%')

                Row() {
                  Text('🕐 时间：')
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_SECONDARY)

                  Text(this.selectedTime)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#F6FFED')
              .borderRadius(GlobalTheme.RADIUS_LG)
              .border({ width: 1, color: '#B7EB8F' })
            }

            Button('确认预约')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_LG)
              .onClick(() => {
                this.confirmAppointment();
              })

            Button('取消')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .backgroundColor('#F5F5F5')
              .borderRadius(GlobalTheme.RADIUS_LG)
              .margin({ top: 8 })
              .onClick(() => {
                router.back();
              })
          }
          .width('90%')
          .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }

  private padZero(num: number): string {
    return num < 10 ? '0' + num : '' + num;
  }
}
