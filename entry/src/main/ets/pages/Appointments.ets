import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { webview } from '@kit.ArkWeb';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AppointmentItem } from '../models/AppointmentModel';
import { GlobalTheme } from '../global';

const TAG = 'Appointments';

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
  @State showPayDialog: boolean = false;
  @State payForm: string = '';
  @State currentOutTradeNo: string = '';
  @State payingAppointmentId: number = 0;

  private webController: webview.WebviewController = new webview.WebviewController();

  private statusOptions: StatusOption[] = [
    { label: '全部', value: -1 },
    { label: '待就诊', value: 0 },
    { label: '已就诊', value: 1 },
    { label: '已取消', value: 2 },
    { label: '已过期', value: 3 }
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
      try {
        await HttpUtil.request<Object>(
          HttpMethod.POST,
          ApiConstants.APPOINTMENT_CHECK_EXPIRED,
          undefined,
          undefined,
          { showLoading: false }
        );
      } catch (e) {
        console.info('过期检查请求忽略:', e);
      }

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
      const cancelData: Record<string, Object> = {
        'status': 2
      };

      hilog.info(0x0000, TAG, '取消预约: appointmentId=%{public}d', this.selectedAppointment.id);

      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.PUT,
        ApiConstants.APPOINTMENT_CANCEL + this.selectedAppointment.id.toString() + '/status',
        cancelData as Object,
        undefined,
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

  async handleCompleteVisit(item: AppointmentItem): Promise<void> {
    if (!item.id) return;

    try {
      const completeData: Record<string, Object> = {
        'userId': this.currentUserId
      };

      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.PUT,
        ApiConstants.APPOINTMENT_COMPLETE + item.id.toString() + '/complete',
        completeData as Object,
        undefined,
        { showLoading: true, loadingText: '正在确认就诊...' }
      );

      if (res.success) {
        ToastUtil.showSuccess('✅ 就诊完成', 2000);
        this.loadAppointments();
      } else {
        ToastUtil.showError(res.message || '操作失败', 2000);
      }
    } catch (e) {
      console.error('确认就诊失败:', e);
      ToastUtil.showError('网络异常，请重试', 1500);
    }
  }

  cancelCancel(): void {
    this.showCancelDialog = false;
    this.selectedAppointment = null;
  }

  async handlePayClick(appointment: AppointmentItem): Promise<void> {
    if (appointment.payStatus === 1) {
      ToastUtil.showWarning('该订单已支付');
      return;
    }
    if (appointment.status !== 0) {
      ToastUtil.showWarning('只有"待就诊"状态的订单才能支付');
      return;
    }

    try {
      const rawDate = String(appointment.scheduleDate || '');
      const dateOnly = rawDate.substring(0, 10);
      const scheduleDateFormatted = dateOnly.replace(/-/g, '');

      hilog.info(0x0000, TAG, '原始日期=%{public}s, 格式化后=%{public}s', rawDate, scheduleDateFormatted);

      const payData: Record<string, Object> = {
        'userId': appointment.userId,
        'doctorId': appointment.doctorId,
        'scheduleDate': scheduleDateFormatted,
        'schedulePeriod': appointment.schedulePeriod,
        'fee': appointment.fee
      };

      hilog.info(0x0000, TAG, '发起支付: appointmentId=%{public}d, doctorId=%{public}d, fee=%{public}f',
        appointment.id, appointment.doctorId, appointment.fee);

      const payRes: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.PAY_CREATE,
        payData as Object,
        undefined,
        { showLoading: true, loadingText: '正在创建支付订单...' }
      );

      if (payRes.success && payRes.data) {
        const payDataResult = payRes.data as Record<string, Object>;
        this.currentOutTradeNo = String(payDataResult['outTradeNo'] || '');
        this.payingAppointmentId = appointment.id;

        if (payDataResult['payForm']) {
          this.payForm = String(payDataResult['payForm']);
          this.showPayDialog = true;

          hilog.info(0x0000, TAG, '显示支付页面: outTradeNo=%{public}s', this.currentOutTradeNo);
        } else if (String(payDataResult['payType'] || '') === 'mock') {
          ToastUtil.showSuccess('✅ 模拟支付成功！', 2000);
          this.loadAppointments();
        } else {
          ToastUtil.showError('获取支付表单失败', 2000);
        }
      } else {
        ToastUtil.showError('创建支付订单失败：' + String(payRes.message || '未知错误'), 2000);
        hilog.error(0x0000, TAG, '创建支付订单失败: %{public}s', String(payRes.message));
      }
    } catch (error) {
      ToastUtil.showError('网络错误，请稍后重试', 1500);
      hilog.error(0x0000, TAG, '支付请求异常: %{public}s', String(error));
    }
  }

  async confirmPayment(): Promise<void> {
    if (!this.currentOutTradeNo) return;

    try {
      ToastUtil.showInfo('确认支付中...');

      const payStatusRes: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.PAY_STATUS + '?outTradeNo=' + this.currentOutTradeNo,
        undefined,
        undefined,
        { showLoading: false }
      );

      if (payStatusRes.success) {
        const statusData = payStatusRes.data as Record<string, Object>;
        const payStatus = Number(statusData['status'] || 0);

        hilog.info(0x0000, TAG, '支付状态查询成功: outTradeNo=%{public}s, status=%{public}d',
          this.currentOutTradeNo, payStatus);

        if (payStatus === 1) {
          this.showPayDialog = false;
          ToastUtil.showSuccess('✅ 支付成功！预约已生效', 2500);
          this.loadAppointments();
        } else if (payStatus === 0) {
          ToastUtil.showError('⚠️ 未检测到支付，请完成支付宝支付后重试', 2500);
        } else if (payStatus === 2) {
          ToastUtil.showWarning('该订单已退款', 2000);
        } else {
          ToastUtil.showError('查询状态异常', 2000);
        }
      } else {
        ToastUtil.showError('查询失败：' + String(payStatusRes.message || '未知错误'), 2000);
      }
    } catch (error) {
      ToastUtil.showError('网络异常，请重试', 1500);
      hilog.error(0x0000, TAG, '支付状态查询异常: %{public}s', String(error));
    }
  }

  closePayDialog(): void {
    this.showPayDialog = false;
    this.payForm = '';
    this.currentOutTradeNo = '';
    this.payingAppointmentId = 0;
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
        Row({ space: 10 }) {
          if (item.payStatus === 0) {
            Button('去支付')
              .layoutWeight(1)
              .height(40)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(8)
              .onClick(() => this.handlePayClick(item))
          }

          Button('申请退号')
            .layoutWeight(item.payStatus === 0 ? 1 : 1)
            .height(40)
            .fontSize(14)
            .fontColor('#FF4D4F')
            .backgroundColor('#FFF1F0')
            .borderRadius(8)
            .onClick(() => this.handleCancelClick(item))
        }
        .width('100%')
      }

      if (item.status === 3) {
        Column() {
          Text('⚠️ ' + (item.reason || '该号已超出时效'))
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FFF2F0')
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
      }

      if (item.status === 1) {
        Row() {
          Text('✅ 就诊已完成')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#52C41A')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F6FFED')
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
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
              Column() {
                EmptyState({
                  title: '加载失败',
                  description: this.errorMessage,
                  buttonText: '重新加载',
                  showButton: true
                })
              }
              .width('100%')
              .onClick(() => this.loadAppointments())
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

      if (this.showPayDialog && this.payForm) {
        this.buildPayDialog();
      }
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildPayDialog() {
    Column() {
      Text('完成支付')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 16 })

      Web({ src: 'about:blank', controller: this.webController })
        .width('100%')
        .height('70%')
        .domStorageAccess(true)
        .javaScriptAccess(true)
        .fileAccess(true)
        .zoomAccess(true)
        .onPageBegin((event) => {
          const url = event?.url || '';
          hilog.info(0x0000, TAG, 'WebView页面开始加载 url=%{public}s', url);

          if (url && url.includes('alipay.com')) {
            hilog.info(0x0000, TAG, '检测到支付宝页面跳转');
            ToastUtil.showInfo('正在跳转到支付宝...', 1500);
          }
        })
        .onPageEnd((event) => {
          const url = event?.url || '';
          hilog.info(0x0000, TAG, 'WebView页面加载完成 url=%{public}s', url);

          if (url === 'about:blank' && this.payForm) {
            const safeForm = this.payForm
              .replace(/\\/g, '\\\\')
              .replace(/'/g, "\\'")
              .replace(/"/g, '\\"')
              .replace(/\n/g, '\\n')
              .replace(/\r/g, '\\r')
              .replace(/\t/g, '\\t');

            this.webController.runJavaScript(`
              (function() {
                try {
                  document.open();
                  document.write('${safeForm}');
                  document.close();
                  
                  setTimeout(function() {
                    var forms = document.getElementsByTagName('form');
                    if (forms.length > 0) {
                      console.log('自动提交表单...');
                      forms[0].submit();
                    }
                  }, 500);
                } catch(e) {
                  console.error('表单注入失败:', e.message);
                }
              })();
            `);

            hilog.info(0x0000, TAG, '已注入WAP支付宝表单到WebView，等待自动提交');
          }
        })
        .onErrorReceive((event) => {
          const errorMsg = event?.error ? JSON.stringify(event.error) : 'unknown';
          const requestUrl: string = (event?.request as Object)?.toString() || 'unknown';
          hilog.error(0x0000, TAG, 'WebView加载错误 url=%{public}s error=%{public}s',
            requestUrl, errorMsg);

          if ((requestUrl as string).includes('alipay.com')) {
            ToastUtil.showWarning('支付宝页面加载异常，请稍后重试', 2500);
          }
        })
        .onUrlLoadIntercept((data) => {
          const url: string = typeof data === 'string' ? data : '';
          hilog.info(0x0000, TAG, 'URL拦截 url=%{public}s', url);

          if (url.includes('alipay://') || url.includes('alipays://')) {
            hilog.info(0x0000, TAG, '检测到支付宝APP跳转协议');
            return true;
          }
          return false;
        })

      Row({ space: 12 }) {
        Button('关闭')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => this.closePayDialog())

        Button('我已支付')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(8)
          .onClick(() => this.confirmPayment())
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(20)
    .shadow({ radius: 24, color: '#00000020', offsetX: 0, offsetY: 4 });
  }
}
