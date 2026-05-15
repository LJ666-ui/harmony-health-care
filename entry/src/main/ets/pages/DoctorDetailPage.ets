import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { webview } from '@kit.ArkWeb';
import { common } from '@kit.AbilityKit';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { HttpUtil, BaseResponse, HttpMethod, RequestOptions } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';
import { Appointment } from '../models/HealthData';
import { GlobalTheme } from '../global';

const TAG = 'DoctorDetailPage';

interface TimeSlot {
  name: string;
  timeRange: string;
}

@Entry
@Component
struct DoctorDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State doctorId: number = 0;
  @State hospitalId: number = 0;
  @State hospitalName: string = '';
  @State departmentId: number = 0;
  @State departmentName: string = '';
  @State departmentLocation: string = '';
  @State doctorInfo: DoctorInfo | null = null;
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State errorMessage: string = '';

  @State showAppointmentDialog: boolean = false;
  @State selectedDate: string = '';
  @State selectedTime: string = '';
  @State selectedDayIndex: number = 0;
  @State selectedTimeSlot: string = '上午';
  @State scheduleId: number = 0;
  @State remainingStock: number = 0;
  @State doctorName: string = '';
  @State showPayDialog: boolean = false;
  @State payUrl: string = '';
  @State currentOutTradeNo: string = '';
  @State payDialogReady: boolean = false;
  @State payLoadError: boolean = false;

  private dates: string[] = [];
  private weekDays: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private timeSlots: TimeSlot[] = [
    { name: '上午', timeRange: '08:00 - 12:00' },
    { name: '下午', timeRange: '14:00 - 17:00' },
    { name: '晚上', timeRange: '18:00 - 20:00' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    try {
      const params = router.getParams() as Record<string, Object> | undefined;
      if (params) {
        if (params['doctorId'] !== undefined) {
          this.doctorId = typeof params['doctorId'] === 'number' ? params['doctorId'] : Number(params['doctorId']);
        }
        if (params['hospitalId'] !== undefined) {
          this.hospitalId = typeof params['hospitalId'] === 'number' ? params['hospitalId'] : Number(params['hospitalId']);
        }
        if (params['hospitalName'] !== undefined && params['hospitalName'] !== '') {
          this.hospitalName = String(params['hospitalName']);
        }
        if (params['departmentId'] !== undefined) {
          this.departmentId = typeof params['departmentId'] === 'number' ? params['departmentId'] : Number(params['departmentId']);
        }
        if (params['departmentName'] !== undefined && params['departmentName'] !== '') {
          this.departmentName = String(params['departmentName']);
        }
        if (params['departmentLocation'] !== undefined && params['departmentLocation'] !== '') {
          this.departmentLocation = String(params['departmentLocation']);
        }
        if (params['scheduleId'] !== undefined) {
          this.scheduleId = typeof params['scheduleId'] === 'number' ? params['scheduleId'] : Number(params['scheduleId']);
        }
        if (params['remainingStock'] !== undefined) {
          this.remainingStock = typeof params['remainingStock'] === 'number' ? params['remainingStock'] : Number(params['remainingStock']);
        }
        if (params['doctorName'] !== undefined && params['doctorName'] !== '') {
          this.doctorName = String(params['doctorName']);
        }
      }
    } catch (error) {
      hilog.error(0x0000, TAG, '获取路由参数失败: %{public}s', JSON.stringify(error));
    }

    hilog.info(0x0000, TAG, '医生参数: doctorId=%{public}d, deptName=%{public}s', this.doctorId, this.departmentName);

    this.initDates();
    this.loadDoctorDetail();
  }

  initDates(): void {
    const today = new Date();
    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      this.dates.push(`${year}-${month}-${day}`);
    }
    if (this.dates.length > 0) {
      this.selectedDate = this.dates[0];
    }
    if (this.timeSlots.length > 0) {
      this.selectedTimeSlot = this.timeSlots[0].name;
    }
  }

  async loadDoctorDetail(): Promise<void> {
    hilog.info(0x0000, TAG, '开始加载医生详情, doctorId=%{public}d', this.doctorId);

    this.isLoading = true;
    this.hasError = false;

    if (!this.doctorId || this.doctorId <= 0) {
      this.hasError = true;
      this.errorMessage = '无效的医生ID';
      this.isLoading = false;
      return;
    }

    try {
      const url = `${ApiConstants.DOCTOR_DETAIL}${this.doctorId}`;
      hilog.info(0x0000, TAG, '请求URL: %{public}s', url);

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        url,
        undefined,
        undefined,
        { showLoading: true, loadingText: '加载医生信息...' }
      );

      hilog.info(0x0000, TAG, '医生详情响应: success=%{public}s', response.success ? 'true' : 'false');

      if (response.success && response.data) {
        const raw = response.data as Record<string, Object>;
        this.doctorInfo = DoctorInfoHelper.fromJson(raw);
        hilog.info(0x0000, TAG, '医生详情加载成功: name=%{public}s', DoctorInfoHelper.getDisplayName(this.doctorInfo));
        
        this.loadRealTimeStock();
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '医生不存在或已被删除';
        hilog.error(0x0000, TAG, '医生详情加载失败: %{public}s', this.errorMessage);
      }
    } catch (error) {
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
      hilog.error(0x0000, TAG, '加载医生详情异常: %{public}s', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  async loadRealTimeStock(): Promise<void> {
    if (!this.doctorId || !this.selectedDate || !this.selectedTimeSlot) {
      return;
    }

    try {
      let schedulePeriod = 1;
      if (this.selectedTimeSlot === '下午') {
        schedulePeriod = 2;
      } else if (this.selectedTimeSlot === '晚上') {
        schedulePeriod = 3;
      }

      const queryParams = `doctorId=${this.doctorId}&scheduleDate=${this.selectedDate}&schedulePeriod=${schedulePeriod}`;
      
      const stockRes: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.SCHEDULE_STOCK_QUERY + '?' + queryParams,
        undefined,
        undefined,
        { showLoading: false }
      );

      if (stockRes.success && stockRes.data) {
        const stockData = stockRes.data as Record<string, Object>;
        const newStock = Number(stockData['remainingStock'] || 0);
        
        hilog.info(0x0000, TAG, '实时库存查询成功: doctorId=%{public}d date=%{public}s period=%{public}d remaining=%{public}d', 
          this.doctorId, this.selectedDate, schedulePeriod, newStock);
        
        this.remainingStock = newStock;
      } else {
        hilog.warn(0x0000, TAG, '实时库存查询失败: %{public}s', String(stockRes.message));
      }
    } catch (error) {
      hilog.error(0x0000, TAG, '实时库存查询异常: %{public}s', String(error));
    }
  }

  onBookAppointment(): void {
    if (!this.doctorInfo) {
      ToastUtil.showError('医生信息异常，请重试', 1500);
      return;
    }

    this.showAppointmentDialog = true;
  }

  async confirmAppointment(payNow: boolean = true): Promise<void> {
    if (!this.selectedDate || !this.selectedTimeSlot) {
      ToastUtil.showError('请选择预约时间', 1500);
      return;
    }

    const currentUserId: number | undefined = AppStorage.get<number>('userId');
    if (currentUserId === undefined || currentUserId === null || currentUserId <= 0) {
      ToastUtil.showError('请先登录', 1500);
      return;
    }

    try {
      ToastUtil.showInfo('正在创建预约...');

      let schedulePeriod = 1;
      if (this.selectedTimeSlot === '下午') {
        schedulePeriod = 2;
      } else if (this.selectedTimeSlot === '晚上') {
        schedulePeriod = 3;
      }

      const appointmentData: Record<string, Object> = {
        'userId': currentUserId,
        'doctorId': this.doctorId,
        'scheduleDate': this.selectedDate,
        'schedulePeriod': schedulePeriod,
        'fee': 10.00
      };

      const appointmentRes: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.APPOINTMENT_CREATE,
        appointmentData as Object,
        undefined,
        { showLoading: false }
      );

      if (appointmentRes.success && appointmentRes.data) {
        const appointmentRecord = appointmentRes.data as Record<string, Object>;
        const traceId = String(appointmentRecord['traceId'] || '');

        hilog.info(0x0000, TAG, '预约请求已提交: traceId=%{public}s', traceId);

        ToastUtil.showInfo('正在创建支付订单...');

        const scheduleDateForPay = this.selectedDate.replace(/-/g, '');

        const payData: Record<string, Object> = {
          'userId': currentUserId,
          'doctorId': this.doctorId,
          'scheduleDate': scheduleDateForPay,
          'schedulePeriod': schedulePeriod,
          'fee': 10.00
        };

        hilog.info(0x0000, TAG, '支付参数: userId=%{public}d, doctorId=%{public}d, date=%{public}s, period=%{public}d',
          currentUserId, this.doctorId, scheduleDateForPay, schedulePeriod);

        const payRes: BaseResponse<Object> = await HttpUtil.request<Object>(
          HttpMethod.POST,
          ApiConstants.PAY_CREATE,
          payData as Object,
          undefined,
          { showLoading: false }
        );

        if (payRes.success) {
          this.showAppointmentDialog = false;
          
          const payDataResult = payRes.data as Record<string, Object>;
          this.currentOutTradeNo = String(payDataResult['outTradeNo'] || '');
          
          this.loadRealTimeStock();
          
          if (payNow && payDataResult['payUrl']) {
            this.payUrl = String(payDataResult['payUrl']);
            this.showPayDialog = true;
            
            hilog.info(0x0000, TAG, '显示支付页面: outTradeNo=%{public}s, payUrl长度=%{public}d',
              this.currentOutTradeNo, this.payUrl.length);

            setTimeout(() => {
              if (this.payDialogReady) {
                this.loadPayUrlToWebView();
              }
            }, 300);
          } else {
            ToastUtil.showSuccess('挂号成功！订单已保留20分钟，请尽快完成支付', 3000);
            
            hilog.info(0x0000, TAG, '稍后支付: outTradeNo=%{public}s', this.currentOutTradeNo);

            setTimeout(() => {
              router.back();
            }, 1000);
          }
        } else {
          ToastUtil.showError('订单创建失败：' + String(payRes.message || '未知错误'), 2000);
          hilog.error(0x0000, TAG, '订单创建失败: %{public}s', String(payRes.message));
        }
      } else {
        ToastUtil.showError('预约失败：' + String(appointmentRes.message || '未知错误'), 2000);
        hilog.error(0x0000, TAG, '预约创建失败: %{public}s', String(appointmentRes.message));
      }
    } catch (error) {
      ToastUtil.showError('网络错误，请稍后重试', 1500);
      console.error('预约流程异常:', error);
      hilog.error(0x0000, TAG, '预约异常: %{public}s', String(error));
    }
  }

  closePayDialog(): void {
    this.showPayDialog = false;
    this.payUrl = '';
    this.payDialogReady = false;
    this.payLoadError = false;
    
    ToastUtil.showSuccess('订单已保留，您可以稍后在"我的预约"中完成支付', 2500);
    
    setTimeout(() => {
      router.back();
    }, 1200);
  }

  private loadPayUrlToWebView(): void {
    if (this.payUrl && this.payUrl.length > 0) {
      try {
        this.webController.loadUrl(this.payUrl);
        hilog.info(0x0000, TAG, 'loadPayUrlToWebView: 已加载支付URL, 长度=%{public}d', this.payUrl.length);
      } catch (error) {
        hilog.error(0x0000, TAG, 'loadPayUrlToWebView: 加载失败 %{public}s', String(error));
      }
    } else {
      hilog.warn(0x0000, TAG, 'loadPayUrlToWebView: payUrl为空');
    }
  }

  private async mockPayment(): Promise<void> {
    if (!this.currentOutTradeNo) {
      ToastUtil.showError('订单号不存在', 1500);
      return;
    }

    try {
      hilog.info(0x0000, TAG, '模拟支付: outTradeNo=%{public}s', this.currentOutTradeNo);

      const mockBody: Record<string, string> = { 'outTradeNo': this.currentOutTradeNo };

      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.PAY_MOCK,
        mockBody as Object,
        undefined,
        { showLoading: true, loadingText: '正在处理模拟支付...' } as RequestOptions
      );

      if (res.success) {
        ToastUtil.showSuccess('模拟支付成功！', 2000);
        this.showPayDialog = false;
        this.payUrl = '';
        this.payLoadError = false;
        this.loadRealTimeStock();
        setTimeout(() => {
          router.back();
        }, 1000);
      } else {
        ToastUtil.showError('模拟支付失败：' + String(res.message || '未知错误'), 2000);
      }
    } catch (error) {
      ToastUtil.showError('网络错误，请稍后重试', 1500);
      hilog.error(0x0000, TAG, '模拟支付异常: %{public}s', String(error));
    }
  }

  async confirmPayment(): Promise<void> {
    if (!this.currentOutTradeNo) {
      ToastUtil.showError('订单号不存在', 1500);
      return;
    }

    try {
      ToastUtil.showInfo('正在确认支付状态...');

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
          
          setTimeout(() => {
            router.back();
          }, 1200);
        } else if (payStatus === 0) {
          ToastUtil.showError('⚠️ 未检测到支付，请完成支付宝支付后重试', 2500);
          hilog.warn(0x0000, TAG, '支付状态仍为待支付: outTradeNo=%{public}s', this.currentOutTradeNo);
        } else if (payStatus === 2) {
          ToastUtil.showWarning('该订单已退款', 2000);
        } else if (payStatus === 3) {
          ToastUtil.showError('该订单已过期，请重新预约', 2000);
          this.showPayDialog = false;
          
          setTimeout(() => {
            router.back();
          }, 1000);
        }
      } else {
        ToastUtil.showError('查询失败：' + String(payStatusRes.message || '未知错误'), 2000);
        hilog.error(0x0000, TAG, '支付状态查询失败: %{public}s', String(payStatusRes.message));
      }
    } catch (error) {
      ToastUtil.showError('网络错误，请稍后重试', 1500);
      console.error('确认支付异常:', error);
      hilog.error(0x0000, TAG, '确认支付异常: %{public}s', String(error));
    }
  }

  build() {
    Column() {
      Header({ title: '医生详情' })

      if (this.isLoading) {
        Loading({ text: '加载中...' })
      } else if (this.hasError) {
        Column() {
          EmptyState({
            title: '加载失败',
            description: this.errorMessage,
            buttonText: '返回',
            showButton: true
          })
        }
        .width('100%')
        .layoutWeight(1)
        .onClick(() => {
          router.back();
        })
      } else if (this.doctorInfo) {
        Scroll() {
          Column({ space: 12 }) {
            this.DoctorProfileCard()
            this.DoctorIntroCard()
            this.DepartmentInfoCard()
            this.AppointmentActionCard()
          }
          .padding({ left: 16, right: 16, top: 12, bottom: 100 })
        }
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
      }

      if (this.showAppointmentDialog) {
        this.AppointmentDialog()
      }

      if (this.showPayDialog) {
        this.PayDialog()
      }
    }
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }

  @Builder
  DoctorProfileCard() {
    Column({ space: 16 }) {
      Row({ space: 16 }) {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(70)
            .height(70)
            .fill(GlobalTheme.THEME_COLOR);

          Text(DoctorInfoHelper.getDisplayName(this.doctorInfo!).charAt(0))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF');
        }

        Column({ space: 8 }) {
          Row({ space: 10 }) {
            Text(DoctorInfoHelper.getDisplayName(this.doctorInfo!))
              .fontSize(this.isElderMode ? 22 : 19)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.TEXT_PRIMARY);

            if (this.doctorInfo!.title && this.doctorInfo!.title.trim() !== '') {
              Text(this.doctorInfo!.title)
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#FFFFFF')
                .backgroundColor('#52C41A')
                .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                .borderRadius(6);
            }
          }

          Row({ space: 8 }) {
            if (this.doctorInfo!.department && this.doctorInfo!.department.trim() !== '') {
              Text(this.doctorInfo!.department)
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor(GlobalTheme.TEXT_SECONDARY);
            }

            if (this.doctorInfo!.rating && this.doctorInfo!.rating > 0) {
              Row({ space: 4 }) {
                Text('⭐')
                  .fontSize(14);
                Text(`${this.doctorInfo!.rating.toFixed(1)}分`)
                  .fontSize(this.isElderMode ? 15 : 13)
                  .fontColor('#F39C12');
              }
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.doctorInfo!.specialty && this.doctorInfo!.specialty.trim() !== '') {
        Column({ space: 8 }) {
          Text('擅长领域')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontWeight(FontWeight.Medium)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .alignSelf(ItemAlign.Start)

          Text(this.doctorInfo!.specialty)
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%')
            .lineHeight(20)
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding(18)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  DoctorIntroCard() {
    if (this.doctorInfo!.description && this.doctorInfo!.description.trim() !== '') {
      Column({ space: 10 }) {
        Text('医生简介')
          .fontSize(this.isElderMode ? 17 : 15)
          .fontWeight(FontWeight.Medium)
          .fontColor(GlobalTheme.TEXT_PRIMARY)
          .width('100%')
          .alignSelf(ItemAlign.Start)

        Text(this.doctorInfo!.description)
          .fontSize(this.isElderMode ? 15 : 14)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .width('100%')
          .lineHeight(22)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(GlobalTheme.CARD_BG)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  DepartmentInfoCard() {
    Column({ space: 12 }) {
      Text('就诊信息')
        .fontSize(this.isElderMode ? 17 : 15)
        .fontWeight(FontWeight.Medium)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .alignSelf(ItemAlign.Start)

      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('🏥')
            .fontSize(16);
          Column({ space: 4 }) {
            Text('所属医院')
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#999999');
            Text(this.hospitalName)
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(GlobalTheme.TEXT_PRIMARY);
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        Row({ space: 8 }) {
          Text('🏢')
            .fontSize(16);
          Column({ space: 4 }) {
            Text('所属科室')
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#999999');
            Text(this.departmentName)
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(GlobalTheme.TEXT_PRIMARY);
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        if (this.departmentLocation) {
          Row({ space: 8 }) {
            Text('📍')
              .fontSize(16);
            Column({ space: 4 }) {
              Text('科室位置')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#999999');
              Text(this.departmentLocation)
                .fontSize(this.isElderMode ? 16 : 14)
                .fontColor(GlobalTheme.TEXT_PRIMARY);
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#F8F9FA')
      .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AppointmentActionCard() {
    Column({ space: 16 }) {
      Text('预约挂号')
        .fontSize(this.isElderMode ? 17 : 15)
        .fontWeight(FontWeight.Medium)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .alignSelf(ItemAlign.Start)

      Row({ space: 8 }) {
        Text('💡')
          .fontSize(16);
        Text(`预约 ${DoctorInfoHelper.getDisplayName(this.doctorInfo!)} 医生的号源，选择合适的时间进行挂号`)
          .fontSize(this.isElderMode ? 15 : 13)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .layoutWeight(1)
      }
      .width('100%')

      Button('立即预约')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(GlobalTheme.THEME_COLOR)
        .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
        .width('100%')
        .height(this.isElderMode ? 50 : 44)
        .borderRadius(8)
        .onClick(() => {
          this.onBookAppointment();
        })
    }
    .width('100%')
    .padding(18)
    .backgroundColor(GlobalTheme.CARD_BG)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  AppointmentDialog() {
    Column() {
      Text('选择就诊信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1677FF')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 12 }) {
            Row({ space: 12 }) {
              Text('👨‍⚕️')
                .fontSize(18);
              Text('医生')
                .fontSize(14)
                .fontColor('#666666')
                .width(60);
              Text(DoctorInfoHelper.getDisplayName(this.doctorInfo!))
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .layoutWeight(1)
                .textAlign(TextAlign.End);
            }
            .width('100%')

            Row({ space: 12 }) {
              Text('💰')
                .fontSize(18);
              Text('挂号费')
                .fontSize(14)
                .fontColor('#666666')
                .width(60);
              Text('¥10.00')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF4D4F')
                .layoutWeight(1)
                .textAlign(TextAlign.End);
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)

          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Text('📅')
                .fontSize(16);
              Text('选择日期')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.dates, (date: string, index: number) => {
                Column({ space: 4 }) {
                  Text(this.formatDateToDisplay(date))
                    .fontSize(14)
                    .fontWeight(this.selectedDate === date ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(this.selectedDate === date ? '#FFFFFF' : '#333333');
                  Text(this.getWeekDay(date))
                    .fontSize(11)
                    .fontColor(this.selectedDate === date ? '#FFFFFF' : '#999999');
                }
                .backgroundColor(this.selectedDate === date ? '#1677FF' : '#F5F5F5')
                .padding({ left: 18, right: 18, top: 10, bottom: 10 })
                .borderRadius(8)
                .margin({ right: 10, bottom: 8 })
                .onClick(() => {
                  this.selectedDate = date;
                  this.loadRealTimeStock();
                })
              }, (date: string, index: number) => `${date}_${index}`)
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)

          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Text('🕐')
                .fontSize(16);
              Text('选择时段')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');
            }
            .width('100%')

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.timeSlots, (slot: TimeSlot, index: number) => {
                Column({ space: 4 }) {
                  Text(slot.name)
                    .fontSize(14)
                    .fontWeight(this.selectedTimeSlot === slot.name ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(this.selectedTimeSlot === slot.name ? '#FFFFFF' : '#333333');
                  Text(slot.timeRange)
                    .fontSize(11)
                    .fontColor(this.selectedTimeSlot === slot.name ? '#FFFFFF' : '#999999');
                }
                .backgroundColor(this.selectedTimeSlot === slot.name ? '#1677FF' : '#FFFFFF')
                .border({
                  width: this.selectedTimeSlot === slot.name ? 0 : 1,
                  color: '#E5E5E5'
                })
                .padding({ left: 24, right: 24, top: 12, bottom: 12 })
                .borderRadius(10)
                .margin({ right: 12, bottom: 8 })
                .onClick(() => {
                  this.selectedTimeSlot = slot.name;
                  this.loadRealTimeStock();
                })
              }, (slot: TimeSlot, index: number) => `${slot.name}_${index}`)
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)

          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Text('📊')
                .fontSize(16);
              Text('号源情况')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');
              Blank();
              Text(this.remainingStock > 0 ? `剩余${this.remainingStock}个号` : '已约满')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.remainingStock > 0 ? '#52C41A' : '#FF4D4F');
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)

          Row({ space: 12 }) {
            Button('立即支付')
              .layoutWeight(1)
              .height(48)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor(this.remainingStock > 0 ? '#1677FF' : '#CCCCCC')
              .borderRadius(24)
              .enabled(this.remainingStock > 0)
              .onClick(() => {
                if (this.remainingStock > 0) {
                  this.confirmAppointment(true);
                } else {
                  ToastUtil.showError('该时段号源已约满', 1500);
                }
              });

            Button('稍后支付')
              .layoutWeight(1)
              .height(48)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1677FF')
              .backgroundColor(this.remainingStock > 0 ? '#E6F4FF' : '#F5F5F5')
              .borderRadius(24)
              .enabled(this.remainingStock > 0)
              .onClick(() => {
                if (this.remainingStock > 0) {
                  this.confirmAppointment(false);
                } else {
                  ToastUtil.showError('该时段号源已约满', 1500);
                }
              });
          }
          .width('100%')
          .margin({ top: 8 });
        }
        .padding({ left: 20, right: 20, bottom: 20 });
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder
  PayDialog() {
    Column() {
      Text('完成支付')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1677FF')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 16 })

      Column({ space: 12 }) {
        Row({ space: 12 }) {
          Text('💳')
            .fontSize(18);
          Text('订单号')
            .fontSize(14)
            .fontColor('#666666')
            .width(60);
          Text(this.currentOutTradeNo)
            .fontSize(13)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.End);
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)

        Text('请在下方完成支付宝支付，支付成功后预约即生效。')
          .fontSize(13)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 8, bottom: 16 })

        if (this.payLoadError) {
          Column() {
            Text('⚠️ 支付宝沙箱暂不可用')
              .fontSize(16)
              .fontColor('#FF4D4F')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })

            Text('支付宝沙箱环境不稳定，可能返回错误。您可以使用模拟支付完成测试。')
              .fontSize(13)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 16 })

            Text('订单号: ' + this.currentOutTradeNo)
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .padding({ left: 20, right: 20 })
        } else if (this.payUrl) {
          Web({ src: '', controller: this.webController })
            .width('100%')
            .height(400)
            .borderRadius(10)
            .backgroundColor('#F5F5F5')
            .domStorageAccess(true)
            .fileAccess(true)
            .javaScriptAccess(true)
            .mixedMode(MixedMode.All)
            .zoomAccess(true)
            .onControllerAttached(() => {
              hilog.info(0x0000, TAG, 'WebView onControllerAttached 触发');
              this.payDialogReady = true;
              this.loadPayUrlToWebView();
            })
            .onAppear(() => {
              hilog.info(0x0000, TAG, 'WebView onAppear 触发, payDialogReady=%{public}b, payUrl长度=%{public}d',
                this.payDialogReady, this.payUrl.length);
              if (this.payDialogReady && this.payUrl) {
                setTimeout(() => {
                  this.loadPayUrlToWebView();
                }, 100);
              }
            })
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

              if (url && url.includes('alipaydev.com/error')) {
                hilog.error(0x0000, TAG, '检测到支付宝沙箱错误页面');
                this.payLoadError = true;
                return;
              }
              
              if (url && (url.includes('return_url') || url.includes('success') || url.includes('payresult'))) {
                hilog.info(0x0000, TAG, '检测到支付返回页面');
                ToastUtil.showSuccess('支付完成，请确认支付状态', 2000);
              }
            })
            .onErrorReceive((event) => {
              const errorMsg = event?.error ? JSON.stringify(event.error) : 'unknown';
              const requestUrl: string = (event?.request as Object)?.toString() || 'unknown';
              hilog.error(0x0000, TAG, 'WebView加载错误 url=%{public}s error=%{public}s', 
                requestUrl, errorMsg);
              
              if ((requestUrl as string).includes('alipay.com')) {
                this.payLoadError = true;
              }
            })
            .onUrlLoadIntercept((data) => {
              const url: string = typeof data === 'string' ? data : '';
              hilog.info(0x0000, TAG, 'URL拦截 url=%{public}s', url);
              
              if (url.includes('alipay://') || url.includes('alipays://')) {
                hilog.info(0x0000, TAG, '检测到支付宝APP跳转协议');
                
                try {
                  const context = getContext(this) as common.UIAbilityContext;
                  context.startAbility({
                    uri: url,
                    action: 'ohos.want.action.viewData'
                  });
                  
                  return true;
                } catch (error) {
                  hilog.error(0x0000, TAG, '启动支付宝APP失败 error=%{public}s', String(error));
                  return false;
                }
              }
              
              return false;
            })
        } else {
          Column() {
            Text('⏳ 正在加载支付页面...')
              .fontSize(14)
              .fontColor('#999999')
            
            Loading({ text: '加载中...' })
          }
          .width('100%')
          .height(350)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
        }
      }

      Row({ space: 12 }) {
        Button('稍后支付')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .borderRadius(22)
          .onClick(() => {
            this.closePayDialog();
          });

        if (this.payLoadError) {
          Button('模拟支付')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#1890FF')
            .borderRadius(22)
            .onClick(() => {
              this.mockPayment();
            });
        } else {
          Button('我已支付')
            .layoutWeight(1)
            .height(44)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#52C41A')
            .borderRadius(22)
            .onClick(() => {
              this.confirmPayment();
            });
        }
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
  }

  private webController: webview.WebviewController = new webview.WebviewController();

  formatDateToDisplay(dateStr: string): string {
    try {
      const date = new Date(dateStr);
      const month = date.getMonth() + 1;
      const day = date.getDate();
      return `${month}/${day}`;
    } catch (error) {
      return dateStr.slice(5, 10).replace('-', '/');
    }
  }

  getWeekDay(dateStr: string): string {
    try {
      const date = new Date(dateStr);
      const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return weekDays[date.getDay()];
    } catch (error) {
      return '';
    }
  }

  formatDateDisplay(dateStr: string): string {
    try {
      const date = new Date(dateStr);
      const month = date.getMonth() + 1;
      const day = date.getDate();
      const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      const weekDay = weekDays[date.getDay()];
      return `${month}/${day} ${weekDay}`;
    } catch (error) {
      return dateStr.slice(5);
    }
  }
}
