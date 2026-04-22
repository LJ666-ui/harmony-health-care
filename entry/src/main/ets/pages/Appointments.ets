import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { GlobalTheme } from '../global';

class AppointmentItem {
  id: string = '';
  appointmentNo: string = '';
  hospitalName: string = '';
  departmentName: string = '';
  appointmentDate: string = '';
  timeSlot: string = '';
  status: string = '';
  createTime: string = '';

  constructor(id: string = '', appointmentNo: string = '', hospitalName: string = '', departmentName: string = '',
    appointmentDate: string = '', timeSlot: string = '', status: string = '', createTime: string = '') {
    this.id = id;
    this.appointmentNo = appointmentNo;
    this.hospitalName = hospitalName;
    this.departmentName = departmentName;
    this.appointmentDate = appointmentDate;
    this.timeSlot = timeSlot;
    this.status = status;
    this.createTime = createTime;
  }
}

@Entry
@Component
struct Appointments {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State appointments: AppointmentItem[] = [];
  @State filteredAppointments: AppointmentItem[] = [];
  @State selectedStatus: string = '全部';
  @State showCancelDialog: boolean = false;
  @State selectedAppointment: AppointmentItem | null = null;
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = false;

  private statusOptions: string[] = ['全部', '待确认', '已确认', '已完成', '已取消'];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    this.loadAppointments();
  }

  async loadAppointments(): Promise<void> {
    this.isLoading = true;
    try {
      const response: BaseResponse<Object> = await HttpUtil.get<Object>(ApiConstants.APPOINTMENT_MY);
      if (response.success && response.data && Array.isArray(response.data)) {
        const dataArr = response.data as Object[];
        const list: AppointmentItem[] = [];
        for (let i = 0; i < dataArr.length; i++) {
          const item = dataArr[i] as Record<string, Object>;
          if (item && typeof item === 'object') {
            list.push(new AppointmentItem(
              String(item['id'] || ''),
              String(item['appointment_no'] || item['appointmentNo'] || ''),
              String(item['hospital_name'] || item['hospitalName'] || ''),
              String(item['department_name'] || item['departmentName'] || ''),
              String(item['appointment_date'] || item['appointmentDate'] || ''),
              String(item['time_slot'] || item['timeSlot'] || ''),
              String(item['status'] || 'pending'),
              String(item['create_time'] || item['createTime'] || '')
            ));
          }
        }
        this.appointments = list;
        this.applyStatusFilter();
      } else {
        console.error('[预约列表] 加载失败:', response.message);
        this.appointments = [];
        this.filteredAppointments = [];
      }
    } catch (e) {
      console.error('[预约列表] 加载异常:', e);
      this.appointments = [];
      this.filteredAppointments = [];
      ToastUtil.showError('网络异常，请检查后端服务是否启动');
    } finally {
      this.isLoading = false;
    }
  }

  applyStatusFilter(): void {
    if (this.selectedStatus === '全部') {
      this.filteredAppointments = this.appointments.slice();
    } else {
      const statusMap: Record<string, string> = {
        '待确认': 'pending',
        '已确认': 'confirmed',
        '已完成': 'completed',
        '已取消': 'cancelled'
      };
      const targetStatus = statusMap[this.selectedStatus];
      this.filteredAppointments = this.appointments.filter(a => a.status === targetStatus);
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

  handleCancelClick(appointment: AppointmentItem): void {
    if (appointment.status !== 'confirmed' && appointment.status !== 'pending') {
      ToastUtil.showWarning('该预约无法取消');
      return;
    }

    this.selectedAppointment = appointment;
    this.showCancelDialog = true;
  }

  async confirmCancel(): Promise<void> {
    if (!this.selectedAppointment) return;

    try {
      const cancelData: Record<string, string> = { 'id': this.selectedAppointment.id };
      const response: BaseResponse<Object> = await HttpUtil.post<Object>(ApiConstants.APPOINTMENT_CANCEL, cancelData);

      if (response.success) {
        ToastUtil.cancelSuccess();
        this.showCancelDialog = false;
        this.selectedAppointment = null;
        this.loadAppointments();
      } else {
        ToastUtil.showError(response.message || '取消失败');
      }
    } catch (e) {
      console.error('[预约] 取消异常:', e);
      ToastUtil.showError('网络异常，请重试');
    }
  }

  cancelCancel(): void {
    this.showCancelDialog = false;
    this.selectedAppointment = null;
  }

  handleRefresh(): void {
    this.isRefreshing = true;
    this.loadAppointments();
    setTimeout(() => {
      this.isRefreshing = false;
      ToastUtil.refreshSuccess();
    }, 1000);
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

        Text('确定要取消该预约吗？')
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
    if (this.isLoading) {
      Column({ space: 20 }) {
        LoadingProgress()
          .width(36)
          .height(36)
          .color('#1677FF')
          .margin({ top: 40 });
        Text('加载中...')
          .fontSize(14)
          .fontColor('#999999');
      }
      .width('100%')
      .height(350)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    } else if (this.filteredAppointments.length === 0) {
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
          .onClick(() => {
            try {
              router.pushUrl({ url: 'pages/AddAppointmentPage' });
            } catch (e) {
              console.error('跳转失败:', e);
            }
          });
      }
      .width('100%')
      .height(350)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    } else {
      List() {
        ForEach(this.filteredAppointments, (item: AppointmentItem) => {
          ListItem() {
            Column() {
              Column() {
                Row() {
                  Text(item.hospitalName)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight('bold')
                    .fontColor(GlobalTheme.TEXT_PRIMARY);

                  Blank();

                  Text(this.getStatusText(item.status))
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(GlobalTheme.THEME_COLOR);
                }
                .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

                Text(item.departmentName)
                  .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor(GlobalTheme.TEXT_PRIMARY)
                  .margin({ bottom: 4 });

                Text(item.appointmentDate + ' ' + item.timeSlot)
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY);

                if (item.appointmentNo) {
                  Text('预约号：' + item.appointmentNo)
                    .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                    .fontColor('#1677FF')
                    .margin({ top: 4 });
                }
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FFFFFF')
              .borderRadius(GlobalTheme.RADIUS_MD)
              .border({ width: 1, color: GlobalTheme.BORDER_COLOR });

              Row() {
                Text('📋 预约详情')
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
            }
            .width('100%');
          }
        }, (item: AppointmentItem) => item.id);
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
              try {
                router.pushUrl({ url: 'pages/AddAppointmentPage' });
              } catch (e) {
                console.error('跳转失败:', e);
              }
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
