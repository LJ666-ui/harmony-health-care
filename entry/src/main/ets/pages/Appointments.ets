import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { EmptyState } from '../components/EmptyState';
import { ClickFeedback, ButtonWithFeedback } from '../components/ClickFeedback';
import { Appointment } from '../models/HealthData';
import { GlobalTheme } from '../global';

@Entry
@Component
struct Appointments {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State appointments: Appointment[] = [];
  @State filteredAppointments: Appointment[] = [];
  @State selectedStatus: string = '全部';
  @State showCancelDialog: boolean = false;
  @State selectedAppointment: Appointment | null = null;

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
      promptAction.showToast({
        message: '该预约无法取消',
        duration: 1500
      });
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

      promptAction.showToast({
        message: '取消成功',
        duration: 1500
      });
    }

    this.showCancelDialog = false;
    this.selectedAppointment = null;
  }

  cancelCancel(): void {
    this.showCancelDialog = false;
    this.selectedAppointment = null;
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
          .width('100%');

          if (this.filteredAppointments.length === 0) {
            EmptyState({
              icon: '📅',
              title: '暂无预约记录',
              description: '点击下方按钮添加新预约',
              buttonText: '+ 新增预约',
              onAdd: () => {
                router.pushUrl({ url: 'pages/AddAppointmentPage' });
              }
            });
          } else {
            List() {
              ForEach(this.filteredAppointments, (item: Appointment) => {
                ListItem() {
                  Column() {
                    ClickFeedback({
                      onItemClick: () => {
                        console.log('预约项被点击:', item.id);
                      },
                      content: () => {
                        Card({
                          title: item.hospital,
                          value: item.specialty + ' · ' + item.doctor,
                          description: item.date + ' ' + item.time,
                          status: this.getStatusText(item.status)
                        });
                      }
                    });

                    Row() {
                      Text(`📍 ${item.location}`)
                        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                        .fontColor('#999999');

                      Blank();

                      if (item.status === 'confirmed' || item.status === 'pending') {
                        ButtonWithFeedback({
                          text: '取消预约',
                          type: 'outline',
                          btnSize: 'small',
                          onItemClick: () => this.handleCancelClick(item)
                        });
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
            .layoutWeight(1);
          }

          ButtonWithFeedback({
            text: '新增预约',
            type: 'primary',
            btnSize: 'large',
            onItemClick: () => {
              router.pushUrl({ url: 'pages/AddAppointmentPage' });
            }
          })
            .width('100%')
            .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) });
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      if (this.showCancelDialog && this.selectedAppointment) {
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

            Text(`确定要取消 ${this.selectedAppointment.hospital} 的${this.selectedAppointment.specialty}预约吗？`)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666')
              .textAlign(TextAlign.Center);

            Row({ space: 12 }) {
              ButtonWithFeedback({
                text: '再想想',
                type: 'secondary',
                btnSize: 'medium',
                onItemClick: () => this.cancelCancel()
              })
                .layoutWeight(1);

              ButtonWithFeedback({
                text: '确认取消',
                type: 'danger',
                btnSize: 'medium',
                onItemClick: () => this.confirmCancel()
              })
                .layoutWeight(1);
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

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
