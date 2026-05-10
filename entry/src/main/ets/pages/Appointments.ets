import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AppointmentItem } from '../models/AppointmentModel';
import { GlobalTheme } from '../global';

interface StatusOption {
  label: string;
  value: number;
}

@Entry
@Component
struct Appointments {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State appointments: AppointmentItem[] = [];
  @State filteredAppointments: AppointmentItem[] = [];
  @State selectedStatus: number = -1;
  @State showCancelDialog: boolean = false;
  @State selectedAppointment: AppointmentItem | null = null;
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';

  private statusOptions: StatusOption[] = [
    { label: '全部', value: -1 },
    { label: '待就诊', value: 0 },
    { label: '已就诊', value: 1 },
    { label: '已取消', value: 2 }
  ];

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
    this.hasError = false;

    if (!this.currentUserId || this.currentUserId <= 0) {
      this.appointments = [];
      this.filteredAppointments = [];
      this.errorMessage = '请先登录';
      this.hasError = false;
      this.isLoading = false;
      return;
    }

    try {
      const params: Record<string, string> = { 'userId': this.currentUserId.toString() };
      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.APPOINTMENT_LIST,
         undefined,
        params as Object,
        { showLoading: true, loadingText: '加载挂号记录...' }
      );

      if (res.code === 200 && res.data) {
        const data: Record<string, Object> = res.data as Record<string, Object>;
        const rawList: Object[] = (data['records'] !== undefined)
          ? (data['records'] as Object[])
          : (res.data as Object[]);
        const list: AppointmentItem[] = [];
        for (let i = 0; i < rawList.length; i++) {
          const raw: Record<string, Object> = rawList[i] as Record<string, Object>;
          const item: AppointmentItem = new AppointmentItem();
          if (raw['id'] !== undefined) item.id = Number(raw['id']);
          if (raw['doctorId'] !== undefined) item.doctorId = Number(raw['doctorId']);
          if (raw['userId'] !== undefined) item.userId = Number(raw['userId']);
          if (raw['scheduleDate'] !== undefined) item.scheduleDate = String(raw['scheduleDate']);
          if (raw['schedulePeriod'] !== undefined) item.schedulePeriod = Number(raw['schedulePeriod']);
          if (raw['fee'] !== undefined) item.fee = Number(raw['fee']);
          if (raw['status'] !== undefined) item.status = Number(raw['status']);
          if (raw['reason'] !== undefined) item.reason = String(raw['reason']);
          if (raw['createTime'] !== undefined) item.createTime = String(raw['createTime']);
          if (raw['updateTime'] !== undefined) item.updateTime = String(raw['updateTime']);
          if (raw['appointmentNo'] !== undefined) item.appointmentNo = String(raw['appointmentNo']);
          if (raw['doctorName'] !== undefined) item.doctorName = String(raw['doctorName']);
          if (raw['hospitalName'] !== undefined) item.hospitalName = String(raw['hospitalName']);
          if (raw['departmentName'] !== undefined) item.departmentName = String(raw['departmentName']);
          if (raw['title'] !== undefined) item.title = String(raw['title']);
          if (raw['payStatus'] !== undefined) item.payStatus = Number(raw['payStatus']);
          list.push(item);
        }
        this.appointments = list;
      } else {
        this.appointments = [];
      }

      this.applyStatusFilter();

      if (this.appointments.length === 0) {
        this.errorMessage = '暂无挂号记录';
      }
    } catch (e) {
      console.error('加载挂号记录失败:', e);
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
      ToastUtil.showError(this.errorMessage, 2000);
    } finally {
      this.isLoading = false;
    }
  }

  applyStatusFilter(): void {
    if (this.selectedStatus === -1) {
      const result: AppointmentItem[] = [];
      for (let i = 0; i < this.appointments.length; i++) {
        result.push(this.appointments[i]);
      }
      this.filteredAppointments = result;
    } else {
      const filtered: AppointmentItem[] = [];
      for (let j = 0; j < this.appointments.length; j++) {
        if (this.appointments[j].status === this.selectedStatus) {
          filtered.push(this.appointments[j]);
        }
      }
      this.filteredAppointments = filtered;
    }
  }

  handleStatusChange(option: StatusOption): void {
    this.selectedStatus = option.value;
    this.applyStatusFilter();
  }

  handleCancelClick(appointment: AppointmentItem): void {
    if (appointment.status !== 0) {
      ToastUtil.showWarning('只有"待就诊"状态才能退号');
      return;
    }
    this.selectedAppointment = appointment;
    this.showCancelDialog = true;
  }

  async confirmCancel(): Promise<void> {
    if (!this.selectedAppointment || !this.selectedAppointment.id) return;

    try {
      const body: Record<string, Object> = {
        'status': 2
      };
      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.PUT,
        ApiConstants.APPOINTMENT_CANCEL + this.selectedAppointment.id.toString() + '/status',
        undefined,
        body,
        { showLoading: true, loadingText: '正在退号...' }
      );

      if (res.code === 200) {
        ToastUtil.cancelSuccess();
        this.loadAppointments();
      } else {
        ToastUtil.showError(res.message || '退号失败');
      }
    } catch (e) {
      console.error('退号失败:', e);
      ToastUtil.showError('网络异常，请重试');
    }

    this.showCancelDialog = false;
    this.selectedAppointment = null;
  }

  cancelCancel(): void {
    this.showCancelDialog = false;
    this.selectedAppointment = null;
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '';
    if (dateStr.includes('-')) return dateStr;
    if (dateStr.length === 8) {
      return dateStr.substring(0, 4) + '-' + dateStr.substring(4, 6) + '-' + dateStr.substring(6, 8);
    }
    return dateStr;
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
        Text('⚠️ 确认退号')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('bold')
          .fontColor('#333333');

        Text('确定要取消 ' + (this.selectedAppointment ? this.selectedAppointment.doctorName : '') +
          ' 医生在 ' + (this.selectedAppointment ? this.formatDate(this.selectedAppointment.scheduleDate) : '') +
          ' 的挂号吗？')
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

          Button('确认退号')
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
  buildAppointmentCard(item: AppointmentItem) {
    Column() {
      Column({ space: 10 }) {
        Row() {
          Column() {
            Text(item.doctorName || '未知医生')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            if (item.departmentName || item.title) {
              Text((item.departmentName ? item.departmentName : '') + (item.title ? ' · ' + item.title : ''))
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#999999')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 2 })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(AppointmentItem.getStatusText(item.status))
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontWeight(FontWeight.Medium)
            .fontColor(AppointmentItem.getStatusColor(item.status))
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(AppointmentItem.getStatusColor(item.status) + '18')
            .borderRadius(12)

          if (item.payStatus !== undefined && item.payStatus >= 0) {
            Text(AppointmentItem.getPayStatusText(item.payStatus))
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontWeight(FontWeight.Medium)
              .fontColor(AppointmentItem.getPayStatusColor(item.payStatus))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(AppointmentItem.getPayStatusColor(item.payStatus) + '18')
              .borderRadius(12)
              .margin({ left: 6 })
          }
        }
        .width('100%')

        Divider().color('#F0F0F0').strokeWidth(1)

        Row() {
          Text('📅 就诊日期')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#999999')
          Blank()
          Text(this.formatDate(item.scheduleDate))
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')

        Row() {
          Text('🕐 就诊时段')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#999999')
          Blank()
          Text(AppointmentItem.getPeriodText(item.schedulePeriod) +
            ' (' + AppointmentItem.getPeriodTimeRange(item.schedulePeriod) + ')')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')

        Row() {
          Text('🏥 医院')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#999999')
          Blank()
          Text(item.hospitalName || '-')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontColor('#333333')
        }
        .width('100%')

        Row() {
          Text('💰 挂号费')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor('#999999')
          Blank()
          Text('¥' + (item.fee > 0 ? item.fee.toFixed(2) : '0.00'))
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4D4F')
        }
        .width('100%')

        if (item.appointmentNo) {
          Row() {
            Text('📋 挂号单号')
              .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
              .fontColor('#CCCCCC')
            Blank()
            Text(item.appointmentNo)
              .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
              .fontColor('#CCCCCC')
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)

      if (item.status === 0) {
        Button('申请退号')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#FF4D4F')
          .backgroundColor('#FFF1F0')
          .borderRadius(8)
          .onClick(() => this.handleCancelClick(item))
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '我的挂号', showBack: true });

        Scroll() {
          Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
            Text('挂号管理')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Scroll() {
              Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
                ForEach(this.statusOptions, (option: StatusOption) => {
                  Text(option.label)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(this.selectedStatus === option.value ? '#FFFFFF' : '#666666')
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .backgroundColor(this.selectedStatus === option.value ? '#1677FF' : '#F0F0F0')
                    .borderRadius(18)
                    .onClick(() => this.handleStatusChange(option));
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)

            if (this.isLoading) {
              Loading({ text: '加载中...' });
            } else if (this.hasError) {
              EmptyState({
                title: '加载失败',
                description: this.errorMessage,
                buttonText: '重新加载',
                onAdd: () => this.loadAppointments()
              });
            } else if (this.filteredAppointments.length === 0) {
              EmptyState({
                icon: '📋',
                title: '暂无挂号记录',
                description: '去预约挂号吧'
              }).height(300).margin({ top: 24 });
            } else {
              List({ space: 12 }) {
                ForEach(this.filteredAppointments, (item: AppointmentItem) => {
                  ListItem() {
                    this.buildAppointmentCard(item);
                  }
                }, (item: AppointmentItem) => '' + item.id);
              }
              .width('100%')
              .layoutWeight(1)
              .padding({ left: 16, right: 16, top: 12 })

              Button('去挂号')
                .width('80%')
                .height(44)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(22)
                .margin({ top: 16, bottom: 24 })
                .onClick(() => {
                  router.back();
                });
            }
          }
          .width('95%')
          .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
        }
        .height('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }
      .width('100%')
      .height('100%')
      .backgroundColor(GlobalTheme.BG_COLOR);

      if (this.showCancelDialog && this.selectedAppointment) {
        this.buildCancelButtonDialog();
      }
    }
    .width('100%')
    .height('100%');
  }
}
