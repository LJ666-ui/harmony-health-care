import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { ToastUtil } from '../common/utils/ToastUtil';
import { DoctorInfo } from '../models/DoctorModel';
import { AppointmentItem, ScheduleInfo } from '../models/AppointmentModel';
import { GlobalTheme } from '../global';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct BookingPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State doctorId: number = 0;
  @State doctorName: string = '';
  @State fee: number = 0;
  @State selectedDate: string = '';
  @State selectedPeriod: number = 1;
  @State remainingStock: number = 0;
  @State isSubmitting: boolean = false;
  @State isLoading: boolean = true;
  @State dates: string[] = [];
  @State periodOptions: number[] = [1, 2, 3];
  @State showPayWeb: boolean = false;
  @State payFormHtml: string = '';
  @State outTradeNo: string = '';

  private scroller: Scroller = new Scroller();
  private payWebController: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    const params: Object | undefined = router.getParams();
    if (params) {
      const p: Record<string, Object> = params as Record<string, Object>;
      this.doctorId = Number(p['doctorId']) || 0;
      this.doctorName = String(p['doctorName'] || '');
      this.fee = Number(p['fee'] || '0');
    }

    this.initDates();
    if (this.dates.length > 0) {
      this.selectedDate = this.dates[0];
    }
    this.checkAvailability();
  }

  initDates(): void {
    const today = new Date();
    for (let i = 0; i < 7; i++) {
      const d = new Date(today);
      d.setDate(today.getDate() + i);
      const y = d.getFullYear();
      const m = d.getMonth() + 1;
      const day = d.getDate();
      this.dates.push(y + '' + (m < 10 ? '0' : '') + m + '' + (day < 10 ? '0' : '') + day);
    }
  }

  formatDateDisplay(dateStr: string): string {
    if (dateStr.length === 8) {
      return dateStr.substring(0, 4) + '-' + dateStr.substring(4, 6) + '-' + dateStr.substring(6, 8);
    }
    return dateStr;
  }

  getWeekDay(dateStr: string): string {
    if (dateStr.length !== 8) return '';
    const d = new Date(
      Number(dateStr.substring(0, 4)),
      Number(dateStr.substring(4, 6)) - 1,
      Number(dateStr.substring(6, 8))
    );
    const days: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return days[d.getDay()];
  }

  async checkAvailability(): Promise<void> {
    if (!this.doctorId || !this.selectedDate) {
      this.remainingStock = 0;
      return;
    }

    this.isLoading = true;
    try {
      const params: Record<string, string> = {
        'doctorId': this.doctorId.toString(),
        'date': this.formatDateDisplay(this.selectedDate),
        'period': this.selectedPeriod.toString()
      };
      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.APPOINTMENT_CHECK_AVAILABILITY,
        undefined,
        params as Object,
        { showLoading: false }
      );

      if (res.code === 200 && res.data) {
        const data: Record<string, Object> = res.data as Record<string, Object>;
        this.remainingStock = Number(data['remaining'] || '0');
      } else {
        this.remainingStock = 0;
      }
    } catch (e) {
      console.error('查询余号失败:', e);
      this.remainingStock = 0;
    } finally {
      this.isLoading = false;
    }
  }

  onDateChange(date: string): void {
    this.selectedDate = date;
    this.checkAvailability();
  }

  onPeriodChange(period: number): void {
    this.selectedPeriod = period;
    this.checkAvailability();
  }

  async onSubmit(): Promise<void> {
    if (!this.currentUserId) {
      ToastUtil.showError('请先登录');
      return;
    }
    if (!this.doctorId) {
      ToastUtil.showError('请选择医生');
      return;
    }
    if (this.remainingStock <= 0) {
      ToastUtil.showError('该时段暂无号源');
      return;
    }

    this.isSubmitting = true;
    try {
      const body: Record<string, Object> = {
        'userId': this.currentUserId,
        'doctorId': this.doctorId,
        'scheduleDate': this.selectedDate,
        'schedulePeriod': this.selectedPeriod,
        'fee': this.fee
      };

      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.PAY_CREATE,
        body,
        undefined,
        { showLoading: true, loadingText: '正在创建支付订单...' }
      );

      if (res.code === 200 && res.data) {
        const data: Record<string, Object> = res.data as Record<string, Object>;
        this.outTradeNo = String(data['outTradeNo'] || '');
        this.payFormHtml = String(data['payForm'] || '');
        if (this.payFormHtml.length > 0) {
          this.showPayWeb = true;
        } else {
          ToastUtil.showError('获取支付页面失败');
        }
      } else {
        ToastUtil.showError(res.message || '创建支付订单失败');
      }
    } catch (e) {
      console.error('创建支付订单失败:', e);
      ToastUtil.showError('网络异常，请重试');
    } finally {
      this.isSubmitting = false;
    }
  }

  async checkPayStatus(): Promise<void> {
    if (!this.outTradeNo) {
      return;
    }
    try {
      const params: Record<string, string> = {
        'outTradeNo': this.outTradeNo
      };
      const res: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.PAY_STATUS,
        undefined,
        params as Object,
        { showLoading: true, loadingText: '查询支付结果...' }
      );

      if (res.code === 200 && res.data) {
        const data: Record<string, Object> = res.data as Record<string, Object>;
        const status: number = Number(data['status'] || '0');
        if (status === 1) {
          this.showPayWeb = false;
          ToastUtil.showSuccess('支付成功，挂号已确认');
          setTimeout(() => {
            router.back();
          }, 1000);
        } else {
          ToastUtil.showError('支付尚未完成，请稍后再试');
        }
      } else {
        ToastUtil.showError('查询支付状态失败');
      }
    } catch (e) {
      console.error('查询支付状态失败:', e);
      ToastUtil.showError('网络异常');
    }
  }

  build() {
    Column() {
      Header({ title: '预约挂号', showBack: true });

      Scroll() {
        Column({ space: 16 }) {
          Text('选择就诊信息')
            .fontSize(this.isElderMode ? 22 : 18)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: 16 })

          Column() {
            Row() {
              Text('👨‍⚕️ 医生')
                .fontSize(this.isElderMode ? 18 : 15)
                .fontColor('#666666')
              Blank()
              Text(this.doctorName || '未知医生')
                .fontSize(this.isElderMode ? 20 : 16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .width('100%')
            .padding({ top: 12, bottom: 12 })
            .borderRadius(8)

            if (this.fee > 0) {
              Row() {
                Text('💰 挂号费')
                  .fontSize(this.isElderMode ? 18 : 15)
                  .fontColor('#666666')
                Blank()
                Text('¥' + this.fee.toFixed(2))
                  .fontSize(this.isElderMode ? 20 : 16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF4D4F')
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
            }
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)

          Column() {
            Text('📅 选择日期')
              .fontSize(this.isElderMode ? 18 : 15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 12 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.dates, (date: string) => {
                Text(this.getWeekDay(date))
                  .fontSize(this.isElderMode ? 16 : 13)
                  .fontColor(this.selectedDate === date ? '#FFFFFF' : '#333333')
                  .textAlign(TextAlign.Center)
                  .padding({ top: 8, bottom: 8, left: 14, right: 14 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.selectedDate === date ? '#1677FF' : '#F5F5F5')
                  .borderRadius(20)
                  .onClick(() => this.onDateChange(date))
              })
            }
            .width('100%')

            if (this.isLoading) {
              Text('查询中...')
                .fontSize(this.isElderMode ? 16 : 13)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)

          Column() {
            Text('🕐 选择时段')
              .fontSize(this.isElderMode ? 18 : 15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 12 })

            Row({ space: 12 }) {
              ForEach([1, 2, 3], (period: number) => {
                Column() {
                  Text(AppointmentItem.getPeriodText(period))
                    .fontSize(this.isElderMode ? 17 : 14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.selectedPeriod === period ? '#FFFFFF' : '#333333')
                  Text(AppointmentItem.getPeriodTimeRange(period))
                    .fontSize(this.isElderMode ? 14 : 11)
                    .fontColor(this.selectedPeriod === period ? '#FFFFFF' : '#999999')
                    .margin({ top: 2 })
                }
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .layoutWeight(1)
                .height(64)
                .backgroundColor(this.selectedPeriod === period ? '#1677FF' : '#F5F5F5')
                .borderRadius(10)
                .onClick(() => this.onPeriodChange(period))
              })
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)

          Column() {
            Row() {
              Text('📊 号源情况')
                .fontSize(this.isElderMode ? 18 : 15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
              if (this.remainingStock > 0) {
                Text('剩余 ' + this.remainingStock + ' 个号源')
                  .fontSize(this.isElderMode ? 18 : 15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#52C41A')
              } else {
                Text('已约满')
                  .fontSize(this.isElderMode ? 18 : 15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF4D4F')
              }
            }
            .width('100%')

            Progress({ value: Math.max(0, this.remainingStock), total: 20, type: ProgressType.Ring })
              .width(60)
              .height(60)
              .color(this.remainingStock > 5 ? '#52C41A' : this.remainingStock > 0 ? '#FAAD14' : '#FF4D4F')
              .margin({ top: 12 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .padding(16)
          .alignItems(HorizontalAlign.Center)

          Button(this.isSubmitting ? '抢号中...' : '确认挂号并支付')
            .width('100%')
            .height(48)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor((this.remainingStock > 0 && !this.isSubmitting) ? '#1677FF' : '#CCCCCC')
            .borderRadius(24)
            .enabled(this.remainingStock > 0 && !this.isSubmitting)
            .onClick(() => this.onSubmit())
        }
        .width('92%')
        .padding({ bottom: 24 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)

      if (this.showPayWeb) {
        Stack() {
          Column() {
            Row() {
              Text('支付宝支付')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1)
              Text('✕')
                .fontSize(22)
                .fontColor('#999999')
                .padding({ left: 12, right: 12 })
                .onClick(() => {
                  this.showPayWeb = false;
                })
            }
            .width('100%')
            .padding({ left: 16, right: 8, top: 12, bottom: 8 })

            Web({ src: '', controller: this.payWebController })
              .width('100%')
              .layoutWeight(1)
              .javaScriptAccess(true)
              .domStorageAccess(true)
              .onControllerAttached(() => {
                if (this.payFormHtml.length > 0) {
                  this.payWebController.loadData(
                    this.payFormHtml,
                    'text/html',
                    'UTF-8'
                  );
                }
              })
              .onPageEnd(() => {
                console.info('[支付] 页面加载完成');
              })

            Row({ space: 12 }) {
              Button('取消支付')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(22)
                .onClick(() => {
                  this.showPayWeb = false;
                })

              Button('已完成支付')
                .layoutWeight(1)
                .height(44)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(22)
                .onClick(() => {
                  this.checkPayStatus();
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 16 })
          }
          .width('100%')
          .height('85%')
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 16, topRight: 16 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
