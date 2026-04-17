import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Appointment } from '../models/HealthData';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

@Entry
@Component
struct Appointments {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State appointments: Appointment[] = [];
  @State filteredAppointments: Appointment[] = [];
  @State selectedStatus: string = '全部';
  @State showCancelDialog: boolean = false;
  @State selectedAppointment: Appointment | null = null;
  @State isRefreshing: boolean = false;

  private statusOptions: string[] = ['全部', '待确认', '已确认', '已完成', '已取消'];

  private defaultAppointments: Appointment[] = [
    {
      id: '1',
      doctor: '张医生',
      specialty: '内科',
      hospital: '星云医院',
      date: '2026-04-15',
      time: '09:00',
      status: 'confirmed',
      location: '门诊楼3层',
      notes: '复查血压控制情况',
      avatarColor: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '2',
      doctor: '李医生',
      specialty: '外科',
      hospital: '星云医院',
      date: '2026-04-18',
      time: '14:30',
      status: 'confirmed',
      location: '门诊楼5层',
      notes: '术后拆线复查',
      avatarColor: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '3',
      doctor: '王医生',
      specialty: '骨科',
      hospital: '协和医疗中心',
      date: '2026-04-20',
      time: '10:00',
      status: 'pending',
      location: '骨科门诊2号诊室',
      notes: '膝关节疼痛检查',
      avatarColor: '#52C41A',
      createdAt: 0,
      updatedAt: 0
    }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }

    this.loadAppointments();
  }

  loadAppointments(): void {
    const storedAppointments = AppStorage.get<Appointment[]>('appointments');
    if (storedAppointments && storedAppointments.length > 0) {
      this.appointments = storedAppointments;
    } else {
      this.appointments = [...this.defaultAppointments];
    }

    this.applyStatusFilter();
  }

  applyStatusFilter(): void {
    if (this.selectedStatus === '全部') {
      this.filteredAppointments = [...this.appointments];
    } else {
      const statusMap: Record<string, string> = {
        '待确认': 'pending',
        '已确认': 'confirmed',
        '已完成': 'completed',
        '已取消': 'cancelled'
      };
      this.filteredAppointments = this.appointments.filter(item => item.status === statusMap[this.selectedStatus]);
    }
  }

  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      'pending': '待确认',
      'confirmed': '已预约',
      'completed': '已完成',
      'cancelled': '已取消'
    };
    return statusMap[status] || status;
  }

  handleStatusChange(status: string): void {
    this.selectedStatus = status;
    this.applyStatusFilter();
  }

  handleCancelClick(appointment: Appointment): void {
    if (appointment.status !== 'confirmed' && appointment.status !== 'pending') {
      ToastUtil.showWarning('该预约无法取消');
      return;
    }

    this.selectedAppointment = appointment;
    this.showCancelDialog = true;
  }

  confirmCancel(): void {
    if (!this.selectedAppointment) return;

    const index = this.appointments.findIndex(apt => apt.id === this.selectedAppointment!.id);
    if (index !== -1) {
      this.appointments[index].status = 'cancelled';
      AppStorage.setOrCreate<Appointment[]>('appointments', this.appointments);

      this.applyStatusFilter();

      ToastUtil.cancelSuccess();
    }

    this.showCancelDialog = false;
    this.selectedAppointment = null;
  }

  cancelCancel(): void {
    this.showCancelDialog = false;
    this.selectedAppointment = null;
  }

  handleRefresh(): void {
    this.isRefreshing = true;

    setTimeout(() => {
      this.loadAppointments();
      this.isRefreshing = false;

      ToastUtil.refreshSuccess();
    }, 1500);
  }

  @Builder
  buildCancelButtonDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .onClick(() => this.cancelCancel());

      Column({ space: 16 }) {
        Text('⚠️ 取消预约')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333');

        Text(`确定要取消 ${this.selectedAppointment?.hospital} 的${this.selectedAppointment?.specialty}预约吗？`)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#666666')
          .textAlign(TextAlign.Center);

        Row({ space: 12 }) {
          Button('再想想')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .onClick(() => this.cancelCancel());

          Button('确认取消')
            .layoutWeight(1)
            .height(40)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF4D4F')
            .borderRadius(20)
            .onClick(() => this.confirmCancel());
        }
        .width('100%');
      }
      .width('80%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(12);
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 });
  }

  @Builder
  buildAppointmentListContent() {
    if (this.filteredAppointments.length === 0) {
      Column({ space: 20 }) {
        Text('📅')
          .fontSize(64)
          .margin({ top: 40, bottom: 12 });

        Text('暂无预约记录')
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#333333');

        Text('点击下方按钮添加新预约')
          .fontSize(14)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .width('80%');

        Button('+ 新增预约')
          .height(44)
          .padding({ left: 28, right: 28 })
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(22)
          .margin({ top: 8 })
          .onClick(() => router.pushUrl({ url: 'pages/AddAppointmentPage' }));
      }
      .width('100%')
      .height(350)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    } else {
      List() {
        ForEach(this.filteredAppointments, (item: Appointment) => {
          ListItem() {
            Column() {
              Column() {
                Row() {
                  Text(item.hospital)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight('bold')
                    .fontColor(GlobalTheme.TEXT_PRIMARY);

                  Blank();

                  Text(this.getStatusText(item.status))
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(GlobalTheme.THEME_COLOR);
                }
                .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

                Text(item.specialty + ' · ' + item.doctor)
                  .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor(GlobalTheme.TEXT_PRIMARY)
                  .margin({ bottom: 4 });

                Text(item.date + ' ' + item.time)
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY);
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FFFFFF')
              .borderRadius(GlobalTheme.RADIUS_MD)
              .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
              .onClick(() => {
                console.log('预约项被点击:', item.id);
              });

              Row() {
                Text(`📍 ${item.location}`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#999999');

                Blank();

                if (item.status === 'confirmed' || item.status === 'pending') {
                  Button('取消预约')
                    .height(32)
                    .fontSize(12)
                    .fontColor('#1677FF')
                    .backgroundColor('#FFFFFF')
                    .border({ width: 1, color: '#1677FF' })
                    .borderRadius(16)
                    .onClick(() => this.handleCancelClick(item));
                }
              }
              .width('100%')
              .padding({ top: 8 });

              if (item.notes) {
                Text(`备注：${item.notes}`)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#666666')
                  .width('100%')
                  .padding({ top: 4 });
              }
            }
            .width('100%');
          }
        }, (item: Appointment) => item.id);
      }
      .width('100%')
      .height(0)
      .layoutWeight(1);
    }
  }

  build() {
    Column() {
      Header({ title: '预约管理', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('预约管理')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Scroll() {
              Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
                ForEach(this.statusOptions, (status: string) => {
                  Text(status)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(this.selectedStatus === status ? '#FFFFFF' : '#666666')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.selectedStatus === status ? '#1677FF' : '#F0F0F0')
                    .borderRadius(16)
                    .onClick(() => this.handleStatusChange(status));
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)

            this.buildAppointmentListContent()

            Button('新增预约')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(24)
              .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) })
              .onClick(() => {
                router.pushUrl({ url: 'pages/AddAppointmentPage' });
              });
          }
          .width('85%')
          .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Stack() {
        if (this.showCancelDialog && this.selectedAppointment) {
          this.buildCancelButtonDialog();
        }
      }
      .width('100%')
      .height(0)
      .layoutWeight(1);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
