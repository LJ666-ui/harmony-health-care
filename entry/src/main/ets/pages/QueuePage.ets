import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface QueueItem {
  appointmentId: number;
  appointmentNo: string;
  scheduleDate: string;
  schedulePeriod: number;
  periodText: string;
  fee: number;
  status: number;
  myPosition: number;
  totalAhead: number;
  totalInSlot: number;
  doctorName: string;
  hospitalName: string;
  departmentName: string;
  title: string;
  isCheckedIn: boolean;
  checkInTime: string;
}

interface RealTimeQueueItem {
  position: number;
  appointmentId: number;
  patientName: string;
  checkInTime: string;
  isSelf: boolean;
}

@Entry
@Component
struct QueuePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State queueList: QueueItem[] = [];
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State totalPending: number = 0;

  @State showRealTimeView: boolean = false;
  @State realtimeList: RealTimeQueueItem[] = [];
  @State myRealtimePosition: number = 0;
  @State totalInQueue: number = 0;
  @State currentViewAppointmentId: number = 0;
  @State realtimeLoading: boolean = false;

  private scroller: Scroller = new Scroller();
  private refreshTimer: number = -1;
  private realtimeTimer: number = -1;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadQueueInfo();
  }

  aboutToDisappear(): void {
    this.stopTimers();
  }

  stopTimers(): void {
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
    }
    if (this.realtimeTimer !== -1) {
      clearInterval(this.realtimeTimer);
      this.realtimeTimer = -1;
    }
  }

  startNormalRefresh(): void {
    this.stopTimers();
    this.refreshTimer = setInterval(() => {
      this.loadQueueInfo();
    }, 30000);
  }

  startRealtimeRefresh(): void {
    this.stopTimers();
    this.realtimeTimer = setInterval(() => {
      this.loadRealTimeQueue(this.currentViewAppointmentId);
    }, 10000);
  }

  async loadQueueInfo(): Promise<void> {
    if (!this.currentUserId || this.currentUserId <= 0) {
      this.errorMessage = '请先登录';
      this.hasError = true;
      return;
    }

    this.isLoading = true;
    this.hasError = false;

    try {
      const params: Record<string, string> = {
        'userId': this.currentUserId.toString()
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.APPOINTMENT_QUEUE_INFO,
        undefined,
        params as Object,
        { showLoading: false }
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        this.totalPending = Number(data['totalPending'] || 0);

        const rawList = data['queueList'] as Object[];
        if (rawList && Array.isArray(rawList)) {
          const list: QueueItem[] = [];
          for (let i = 0; i < rawList.length; i++) {
            const raw = rawList[i] as Record<string, Object>;
            const item: QueueItem = {
              appointmentId: Number(raw['appointmentId'] || 0),
              appointmentNo: String(raw['appointmentNo'] || ''),
              scheduleDate: String(raw['scheduleDate'] || ''),
              schedulePeriod: Number(raw['schedulePeriod'] || 0),
              periodText: String(raw['periodText'] || ''),
              fee: Number(raw['fee'] || 0),
              status: Number(raw['status'] || 0),
              myPosition: Number(raw['myPosition'] || 0),
              totalAhead: Number(raw['totalAhead'] || 0),
              totalInSlot: Number(raw['totalInSlot'] || 0),
              doctorName: String(raw['doctorName'] || '未知医生'),
              hospitalName: String(raw['hospitalName'] || '-'),
              departmentName: String(raw['departmentName'] || ''),
              title: String(raw['title'] || ''),
              isCheckedIn: Boolean(raw['isCheckedIn']),
              checkInTime: raw['checkInTime'] ? String(raw['checkInTime']) : ''
            };
            list.push(item);
          }
          this.queueList = list;
        } else {
          this.queueList = [];
        }
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载失败';
      }
    } catch (error) {
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }

  async handleCheckIn(item: QueueItem): Promise<void> {
    if (!item.appointmentId) return;

    try {
      const checkInData: Record<string, Object> = {
        'userId': this.currentUserId
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.PUT,
        ApiConstants.APPOINTMENT_CHECK_IN + item.appointmentId.toString() + '/check-in',
        checkInData as Object,
        undefined,
        { showLoading: true, loadingText: '正在报到...' }
      );

      if (response.success) {
        ToastUtil.showSuccess('✅ 报到成功！', 2000);
        this.currentViewAppointmentId = item.appointmentId;
        this.showRealTimeView = true;
        this.loadRealTimeQueue(item.appointmentId);
      } else {
        ToastUtil.showError(response.message || '报到失败', 2000);
      }
    } catch (error) {
      ToastUtil.showError('网络异常，请重试', 1500);
    }
  }

  async loadRealTimeQueue(appointmentId: number): Promise<void> {
    this.realtimeLoading = true;

    try {
      const params: Record<string, string> = {
        'appointmentId': appointmentId.toString()
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.APPOINTMENT_QUEUE_REALTIME,
        undefined,
        params as Object,
        { showLoading: false }
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        this.myRealtimePosition = Number(data['myPosition'] || 0);
        this.totalInQueue = Number(data['totalInQueue'] || 0);

        const rawList = data['queueList'] as Object[];
        if (rawList && Array.isArray(rawList)) {
          const list: RealTimeQueueItem[] = [];
          for (let i = 0; i < rawList.length; i++) {
            const raw = rawList[i] as Record<string, Object>;
            list.push({
              position: Number(raw['position'] || 0),
              appointmentId: Number(raw['appointmentId'] || 0),
              patientName: String(raw['patientName'] || '患者'),
              checkInTime: String(raw['checkInTime'] || ''),
              isSelf: Boolean(raw['isSelf'])
            });
          }
          this.realtimeList = list;
        } else {
          this.realtimeList = [];
        }

        setTimeout(() => {
          this.scrollToSelf();
        }, 100);
      }
    } catch (error) {
      console.error('加载实时排队失败:', error);
    } finally {
      this.realtimeLoading = false;
    }
  }

  scrollToSelf(): void {
    const selfIndex = this.realtimeList.findIndex((item: RealTimeQueueItem) => item.isSelf);
    if (selfIndex >= 0) {
      const targetOffset = Math.max(0, (selfIndex - 1) * 72);
      this.scroller.scrollTo({ xOffset: 0, yOffset: targetOffset, animation: { duration: 300 } });
    }
  }

  exitRealtimeView(): void {
    this.showRealTimeView = false;
    this.realtimeList = [];
    this.startNormalRefresh();
    this.loadQueueInfo();
  }

  async handleCompleteVisit(item: QueueItem): Promise<void> {
    if (!item.appointmentId) return;

    try {
      const completeData: Record<string, Object> = {
        'userId': this.currentUserId
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.PUT,
        ApiConstants.APPOINTMENT_COMPLETE + item.appointmentId.toString() + '/complete',
        completeData as Object,
        undefined,
        { showLoading: true, loadingText: '正在确认就诊...' }
      );

      if (response.success) {
        ToastUtil.showSuccess('✅ 就诊完成', 2000);
        this.loadQueueInfo();
      } else {
        ToastUtil.showError(response.message || '操作失败', 2000);
      }
    } catch (error) {
      ToastUtil.showError('网络异常，请重试', 1500);
    }
  }

  getQueueStatusText(item: QueueItem): string {
    if (!item.isCheckedIn) return '未报到';
    if (item.totalAhead === 0) return '即将叫号';
    if (item.totalAhead <= 3) return '即将就诊';
    return '排队等候中';
  }

  getQueueStatusColor(item: QueueItem): string {
    if (!item.isCheckedIn) return '#999999';
    if (item.totalAhead === 0) return '#52C41A';
    if (item.totalAhead <= 3) return '#FAAD14';
    return '#1677FF';
  }

  getEstimatedWaitTime(item: QueueItem): string {
    if (!item.isCheckedIn) return '请先报到';
    if (item.totalAhead === 0) return '马上到您';
    const minutes = item.totalAhead * 10;
    if (minutes < 60) return '约' + minutes + '分钟';
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    return '约' + hours + '小时' + (mins > 0 ? mins + '分钟' : '');
  }

  @Builder
  QueueCard(item: QueueItem) {
    Column() {
      Row() {
        Column() {
          Text(item.doctorName)
            .fontSize(this.isElderMode ? 20 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          if (item.departmentName || item.title) {
            Text((item.departmentName ? item.departmentName : '') + (item.title ? ' · ' + item.title : ''))
              .fontSize(this.isElderMode ? 15 : 12)
              .fontColor('#999999')
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column() {
          Text(this.getQueueStatusText(item))
            .fontSize(this.isElderMode ? 16 : 13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getQueueStatusColor(item))
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.getQueueStatusColor(item) + '18')
            .borderRadius(12)

          if (item.isCheckedIn) {
            Text('查看排名')
              .fontSize(11)
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: 4 })
              .onClick(() => {
                this.currentViewAppointmentId = item.appointmentId;
                this.showRealTimeView = true;
                this.loadRealTimeQueue(item.appointmentId);
              });
          }
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 12, bottom: 12 })

      Row() {
        Column() {
          Text('报到顺序')
            .fontSize(this.isElderMode ? 14 : 11)
            .fontColor('#999999')
          Text(item.myPosition.toString())
            .fontSize(this.isElderMode ? 28 : 22)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.isCheckedIn ? GlobalTheme.THEME_COLOR : '#CCCCCC')
            .margin({ top: 4 })

          if (item.checkInTime) {
            Text('已报 ' + item.checkInTime.substring(11))
              .fontSize(11)
              .fontColor('#52C41A')
              .margin({ top: 2 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('前方等候')
            .fontSize(this.isElderMode ? 14 : 11)
            .fontColor('#999999')
          Text((item.isCheckedIn ? item.totalAhead : '-').toString() + '人')
            .fontSize(this.isElderMode ? 28 : 22)
            .fontWeight(FontWeight.Bold)
            .fontColor(!item.isCheckedIn ? '#CCCCCC' :
              (item.totalAhead === 0 ? '#52C41A' : (item.totalAhead <= 3 ? '#FAAD14' : '#FF4D4F')))
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('预计等待')
            .fontSize(this.isElderMode ? 14 : 11)
            .fontColor('#999999')
          Text(this.getEstimatedWaitTime(item))
            .fontSize(this.isElderMode ? 16 : 13)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.isCheckedIn ? '#333333' : '#CCCCCC')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 12, bottom: 12 })

      Row() {
        Text('📅 ' + item.scheduleDate)
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor('#666666')
        Blank()
        Text(item.periodText)
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor('#666666')
      }
      .width('100%')

      Row() {
        Text('🏥 ' + item.hospitalName)
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ top: 4 })

      if (!item.isCheckedIn) {
        Button('📍 现场报到')
          .width('100%')
          .height(44)
          .fontSize(this.isElderMode ? 17 : 15)
          .fontColor('#FFFFFF')
          .backgroundColor(GlobalTheme.THEME_COLOR)
          .borderRadius(22)
          .margin({ top: 12 })
          .onClick(() => {
            this.handleCheckIn(item);
          });
      }

      if (item.isCheckedIn && item.status === 0) {
        Row({ space: 10 }) {
          Button('确认就诊')
            .layoutWeight(1)
            .height(44)
            .fontSize(this.isElderMode ? 17 : 15)
            .fontColor('#FFFFFF')
            .backgroundColor('#52C41A')
            .borderRadius(22)
            .onClick(() => {
              this.handleCompleteVisit(item);
            });

          Button('查看排名')
            .layoutWeight(1)
            .height(44)
            .fontSize(this.isElderMode ? 17 : 15)
            .fontColor(GlobalTheme.THEME_COLOR)
            .backgroundColor(GlobalTheme.THEME_COLOR + '15')
            .borderRadius(22)
            .onClick(() => {
              this.currentViewAppointmentId = item.appointmentId;
              this.showRealTimeView = true;
              this.loadRealTimeQueue(item.appointmentId);
            });
        }
        .width('100%')
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder
  RealTimeRankRow(item: RealTimeQueueItem) {
    Row() {
      Column() {
        Text(item.position.toString())
          .fontSize(this.isElderMode ? 24 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.isSelf ? '#FFFFFF' : GlobalTheme.THEME_COLOR)
      }
      .width(44)
      .height(44)
      .backgroundColor(item.isSelf ? GlobalTheme.THEME_COLOR : (GlobalTheme.THEME_COLOR + '15'))
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(item.patientName)
            .fontSize(this.isElderMode ? 18 : 15)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.isSelf ? GlobalTheme.THEME_COLOR : '#333333')

          if (item.isSelf) {
            Text('（我）')
              .fontSize(this.isElderMode ? 15 : 12)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.THEME_COLOR)
          }
        }
        .alignItems(VerticalAlign.Bottom)

        Text('报到时间: ' + (item.checkInTime.substring(11) || '--:--'))
          .fontSize(this.isElderMode ? 14 : 11)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      if (item.position <= 3 && item.isSelf) {
        Text('即将到您')
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor('#52C41A')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F6FFED')
          .borderRadius(12)
      } else if (item.isSelf) {
        Text('第' + item.position + '位')
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor(GlobalTheme.THEME_COLOR)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor(GlobalTheme.THEME_COLOR + '10')
          .borderRadius(12)
      }
    }
    .width('100%')
    .height(64)
    .padding({ left: 16, right: 12 })
    .backgroundColor(item.isSelf ? '#FFFBE6' : '#FFFFFF')
    .borderRadius(12)
    .border({ width: item.isSelf ? 2 : 1, color: item.isSelf ? GlobalTheme.THEME_COLOR : '#F0F0F0' })
  }

  build() {
    Column() {
      Header({ title: '排队叫号', showBack: !this.showRealTimeView });

      if (this.showRealTimeView) {
        this.buildRealTimeView();
      } else {
        this.buildNormalView();
      }

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }

  @Builder
  buildNormalView() {
    Scroll() {
      Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
        Row() {
          Text('实时排队信息')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.THEME_COLOR)

          Blank()

          Text('🔄 刷新')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor(GlobalTheme.THEME_COLOR)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(GlobalTheme.THEME_COLOR + '15')
            .borderRadius(16)
            .onClick(() => {
              this.loadQueueInfo();
              ToastUtil.showInfo('已刷新');
            })
        }
        .width('100%')
        .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode) })

        Row() {
          Text('待就诊: ' + this.totalPending + ' 个预约')
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor('#666666')
          Blank()
          Text('按报到时间排序')
            .fontSize(this.isElderMode ? 13 : 11)
            .fontColor('#999999')
        }
        .width('100%')

        if (this.isLoading && this.queueList.length === 0) {
          Column() {
            LoadingProgress().width(50).height(50).color(GlobalTheme.THEME_COLOR);
            Text('正在加载排队信息...')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .margin({ top: 10 });
          }.width('100%').height(200).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
        } else if (this.hasError) {
          Column() {
            Text('\u{1F4ED}').fontSize(48).margin({ bottom: 12 });
            Text(this.errorMessage)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode)).fontColor('#FF6B6B').textAlign(TextAlign.Center);
            Button('重新加载')
              .type(ButtonType.Normal).borderRadius(20).backgroundColor(GlobalTheme.THEME_COLOR)
              .width(150).height(40).margin({ top: 15 }).onClick(() => this.loadQueueInfo());
          }.width('100%').padding(20);
        } else if (this.queueList.length === 0) {
          Column() {
            Text('\u{1F4ED}').fontSize(48).margin({ bottom: 12 });
            Text('暂无排队信息')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode)).fontColor(GlobalTheme.TEXT_SECONDARY);
            Text('请先预约挂号，到达医院后现场报到')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode)).fontColor(GlobalTheme.TEXT_HINT).margin({ top: 8 });
            Button('去预约挂号')
              .type(ButtonType.Normal).borderRadius(20).backgroundColor(GlobalTheme.THEME_COLOR)
              .width(150).height(40).margin({ top: 15 })
              .onClick(() => { router.pushUrl({ url: 'pages/AppointmentManagementPage' }); });
          }.width('100%').height(300).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
        } else {
          List({ space: 12 }) {
            ForEach(this.queueList, (item: QueueItem) => {
              ListItem() { this.QueueCard(item); }
            }, (item: QueueItem) => '' + item.appointmentId)
          }.width('100%')

          Text('\u{2139} 已报到的患者按报到时间排序，未报到者排在最后 | 每30秒自动刷新')
            .fontSize(this.isElderMode ? 13 : 11).fontColor('#CCCCCC').margin({ top: 8 });
        }
      }
      .width('85%')
      .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
    }
    .height(0)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .align(Alignment.Top);
  }

  @Builder
  buildRealTimeView() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(this.isElderMode ? 17 : 15)
          .fontColor(GlobalTheme.THEME_COLOR)
          .fontWeight(FontWeight.Medium)
          .onClick(() => { this.exitRealtimeView(); })

        Blank()

        Text('🔄 刷新')
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor(GlobalTheme.THEME_COLOR)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(GlobalTheme.THEME_COLOR + '15')
          .borderRadius(16)
          .onClick(() => {
            this.loadRealTimeQueue(this.currentViewAppointmentId);
            ToastUtil.showInfo('已刷新');
          })
      }
      .width('85%')
      .padding({ top: 12, bottom: 8 })

      Column() {
        Text('实时排队排名')
          .fontSize(this.isElderMode ? 24 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.THEME_COLOR)
          .margin({ top: 8, bottom: 8 })

        Row() {
          Column() {
            Text('我的位置')
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#999999')
            Text(this.myRealtimePosition.toString())
              .fontSize(this.isElderMode ? 40 : 32)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.THEME_COLOR)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('队列人数')
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#999999')
            Text(this.totalInQueue.toString() + '人')
              .fontSize(this.isElderMode ? 40 : 32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('前方等待')
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#999999')
            Text(Math.max(0, this.myRealtimePosition - 1).toString() + '人')
              .fontSize(this.isElderMode ? 40 : 32)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.myRealtimePosition <= 1 ? '#52C41A' : '#FF4D4F')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .margin({ bottom: 12 })

        if (this.realtimeLoading && this.realtimeList.length === 0) {
          LoadingProgress().width(40).height(40).color(GlobalTheme.THEME_COLOR);
          Text('加载中...')
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor('#999999')
            .margin({ top: 8 });
        } else if (this.realtimeList.length === 0) {
          Column() {
            Text('暂无其他已报到患者')
              .fontSize(this.isElderMode ? 15 : 13)
              .fontColor('#999999');
            Text('您是第一个报到的！')
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor(GlobalTheme.THEME_COLOR)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 6 });
          }.height(150).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
        } else {
          Scroll(this.scroller) {
            Column({ space: 8 }) {
              ForEach(this.realtimeList, (item: RealTimeQueueItem) => {
                this.RealTimeRankRow(item);
              }, (item: RealTimeQueueItem) => '' + item.appointmentId)
            }
            .width('100%')
            .padding({ bottom: 20 });
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .width('100%')
          .edgeEffect(EdgeEffect.Spring)
        }

        Text('⏱ 每10秒自动更新 · 绿色高亮为您的位置')
          .fontSize(this.isElderMode ? 13 : 11)
          .fontColor('#CCCCCC')
          .margin({ top: 8, bottom: 8 })
      }
      .width('85%')
      .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(GlobalTheme.BG_COLOR)
  }
}
