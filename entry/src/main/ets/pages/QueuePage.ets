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
  isOnline: boolean;
  waitSeconds?: number;
  remainingSeconds?: number;
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
  @State isOnlineMode: boolean = false;
  @State onlineSelectedAppointmentId: number = 0;
  @State onlineDoctorName: string = '';
  @State onlineDepartmentName: string = '';
  @State onlineScheduleDate: string = '';
  @State onlinePeriodText: string = '';
  @State onlineCountdown: number = 0;
  @State onlineAutoStarting: boolean = false;
  @State offlineCountdown: number = 0;
  @State showGoToClinic: boolean = false;

  private scroller: Scroller = new Scroller();
  private refreshTimer: number = -1;
  private realtimeTimer: number = -1;
  private countdownTimer: number = -1;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    const params = router.getParams() as Record<string, Object> | undefined;
    if (params && params['online'] === true) {
      this.isOnlineMode = true;
      this.loadTodayAppointments();
    } else {
      this.loadQueueInfo();
    }
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
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
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

  async loadTodayAppointments(): Promise<void> {
    this.isLoading = true;
    try {
      const today = new Date();
      const year = today.getFullYear();
      const month = String(today.getMonth() + 1).padStart(2, '0');
      const day = String(today.getDate()).padStart(2, '0');
      const dateStr = `${year}-${month}-${day}`;

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

  async handleOnlineJoin(item: QueueItem): Promise<void> {
    if (!item.appointmentId) return;

    this.isLoading = true;
    try {
      const scheduleDateStr = item.scheduleDate.replace(/-/g, '');

      const onlineData: Record<string, Object> = {
        'userId': this.currentUserId,
        'appointmentId': item.appointmentId,
        'doctorId': 0,
        'scheduleDate': scheduleDateStr,
        'schedulePeriod': item.schedulePeriod,
        'fee': item.fee || 10.00
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.APPOINTMENT_ONLINE_JOIN,
        onlineData as Object,
        undefined,
        { showLoading: true, loadingText: '正在加入线上就诊排队...' }
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        const appointmentId = Number(data['appointmentId'] || item.appointmentId);
        ToastUtil.showSuccess('✅ 已加入线上就诊排队', 2000);
        this.currentViewAppointmentId = appointmentId;
        this.showRealTimeView = true;
        this.loadRealTimeQueue(appointmentId);
        this.startRealtimeRefresh();
      } else {
        ToastUtil.showError(response.message || '加入线上排队失败', 2000);
      }
    } catch (error) {
      console.error('[QueuePage] 线上就诊加入失败:', error);
      ToastUtil.showError('网络异常，请重试', 1500);
    } finally {
      this.isLoading = false;
    }
  }

  selectForOnlineQueue(item: QueueItem): void {
    this.onlineSelectedAppointmentId = item.appointmentId;
    this.onlineDoctorName = item.doctorName;
    this.onlineDepartmentName = item.departmentName + (item.title ? ' · ' + item.title : '');
    this.onlineScheduleDate = item.scheduleDate;
    this.onlinePeriodText = item.periodText;

    AlertDialog.show({
      title: '确认开始排队',
      message: `确认以「${this.onlineDoctorName}」的挂号\n进行线上就诊排队吗？`,
      primaryButton: { value: '开始排队', action: () => {
        this.handleOnlineJoin(item);
      }},
      secondaryButton: { value: '取消', action: () => {} }
    });
  }

  async handleCheckIn(item: QueueItem): Promise<void> {
    if (!item.appointmentId) return;

    try {
      const checkInData: Record<string, Object> = {
        'userId': this.currentUserId
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.PUT,
        ApiConstants.APPOINTMENT_CHECK_IN + '/' + item.appointmentId.toString() + '/check-in',
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
              isSelf: Boolean(raw['isSelf']),
              isOnline: Boolean(raw['isOnline']),
              waitSeconds: raw['waitSeconds'] !== undefined ? Number(raw['waitSeconds']) : undefined,
              remainingSeconds: raw['remainingSeconds'] !== undefined ? Number(raw['remainingSeconds']) : undefined
            });
          }
          this.realtimeList = list;
        } else {
          this.realtimeList = [];
        }

        setTimeout(() => {
          this.scrollToSelf();
        }, 100);

        if (this.isOnlineMode && this.myRealtimePosition === 1 && !this.onlineAutoStarting) {
          this.startOnlineCountdown();
        } else if (this.isOnlineMode && this.myRealtimePosition > 1) {
          this.stopOnlineCountdown();
        } else if (!this.isOnlineMode && this.myRealtimePosition === 1 && !this.showGoToClinic) {
          this.startOfflineCountdown();
        } else if (!this.isOnlineMode && this.myRealtimePosition > 1) {
          this.stopOfflineCountdown();
        }
      }
    } catch (error) {
      console.error('加载实时排队失败:', error);
    } finally {
      this.realtimeLoading = false;
    }
  }

  startOnlineCountdown(): void {
    this.stopOnlineCountdown();
    this.onlineAutoStarting = true;
    this.onlineCountdown = 5;
    this.countdownTimer = setInterval(() => {
      this.onlineCountdown--;
      if (this.onlineCountdown <= 0) {
        this.stopOnlineCountdown();
        this.enterOnlineChat();
      }
    }, 1000);
  }

  stopOnlineCountdown(): void {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
    this.onlineCountdown = 0;
    this.onlineAutoStarting = false;
  }

  startOfflineCountdown(): void {
    this.stopOfflineCountdown();
    this.offlineCountdown = 10;
    this.countdownTimer = setInterval(() => {
      this.offlineCountdown--;
      if (this.offlineCountdown <= 0) {
        this.stopOfflineCountdown();
        this.showGoToClinic = true;
      }
    }, 1000);
  }

  stopOfflineCountdown(): void {
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = -1;
    }
    this.offlineCountdown = 0;
  }

  enterOnlineChat(): void {
    const targetItem: RealTimeQueueItem | undefined = this.realtimeList.find((item: RealTimeQueueItem) => item.isSelf);
    if (!targetItem || !targetItem.appointmentId) return;

    try {
      router.pushUrl({
        url: 'pages/DoctorChatPage',
        params: {
          doctorId: 0,
          doctorName: targetItem.patientName,
          currentUserId: this.currentUserId,
          otherUserId: 0,
          otherUserName: '医生',
          appointmentId: targetItem.appointmentId,
          isPatient: true,
          fromOnlineQueue: true
        }
      });
    } catch (error) {
      console.error('[QueuePage] 进入线上问诊失败:', error);
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
    if (this.isOnlineMode) {
      router.back();
      return;
    }
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
        ApiConstants.APPOINTMENT_COMPLETE + '/' + item.appointmentId.toString() + '/complete',
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

  formatCountdown(seconds: number): string {
    if (seconds <= 0) return '00:00';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return String(mins).padStart(2, '0') + ':' + String(secs).padStart(2, '0');
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '';
    if (dateStr.includes('-') && !dateStr.includes('T')) return dateStr;
    if (dateStr.includes('T')) {
      return dateStr.substring(0, 10);
    }
    if (dateStr.length === 8) {
      return dateStr.substring(0, 4) + '-' + dateStr.substring(4, 6) + '-' + dateStr.substring(6, 8);
    }
    return dateStr;
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

          if (item.isOnline) {
            Text('线上就诊')
              .fontSize(this.isElderMode ? 13 : 11)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1890FF')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor('#E6F7FF')
              .borderRadius(8)
          }

          if (item.isSelf) {
            Text('（我）')
              .fontSize(this.isElderMode ? 15 : 12)
              .fontWeight(FontWeight.Bold)
              .fontColor(GlobalTheme.THEME_COLOR)
          }
        }
        .alignItems(VerticalAlign.Bottom)

        Row({ space: 8 }) {
          Text('报到时间: ' + (item.checkInTime.substring(11) || '--:--'))
            .fontSize(this.isElderMode ? 14 : 11)
            .fontColor('#999999')

          if (item.position === 1 && item.remainingSeconds !== undefined && item.remainingSeconds > 0) {
            Text('⏱ ' + this.formatCountdown(item.remainingSeconds))
              .fontSize(this.isElderMode ? 14 : 11)
              .fontColor('#FF4D4F')
              .fontWeight(FontWeight.Medium)
          } else if (item.position === 1 && item.remainingSeconds !== undefined && item.remainingSeconds <= 0) {
            Text('⏱ 已超时，即将降级')
              .fontSize(this.isElderMode ? 14 : 11)
              .fontColor('#FF4D4F')
              .fontWeight(FontWeight.Medium)
          }
        }
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
      Header({ title: this.isOnlineMode ? '线上就诊排队' : '排队叫号', showBack: !this.showRealTimeView });

      if (this.showRealTimeView) {
        this.buildRealTimeView();
      } else if (this.isOnlineMode) {
        this.buildOnlineEntryView();
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
  buildOnlineEntryView() {
    Scroll() {
      Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
        Row() {
          Text('📱 线上就诊')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor('#1890FF')

          Blank()

          Text('🔄 刷新')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor('#1890FF')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#E6F7FF')
            .borderRadius(16)
            .onClick(() => {
              this.loadTodayAppointments();
              ToastUtil.showInfo('已刷新');
            })
        }
        .width('85%')
        .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode) })

        Column() {
          Text('选择一个挂号，开始线上就诊排队')
            .fontSize(this.isElderMode ? 15 : 13)
            .fontColor('#666666')
            .margin({ top: 4, bottom: 12 })

          if (this.isLoading && this.queueList.length === 0) {
            Column() {
              LoadingProgress().width(50).height(50).color(GlobalTheme.THEME_COLOR);
              Text('正在加载今日挂号...')
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
                .type(ButtonType.Normal).borderRadius(20).backgroundColor('#1890FF')
                .width(150).height(40).margin({ top: 15 }).onClick(() => this.loadTodayAppointments());
            }.width('100%').padding(20);
          } else if (this.queueList.length === 0) {
            Column() {
              Text('\u{1F4CB}').fontSize(48).margin({ bottom: 12 });
              Text('暂无今日挂号')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode)).fontColor(GlobalTheme.TEXT_SECONDARY);
              Text('请先预约挂号后再进行线上问诊')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode)).fontColor(GlobalTheme.TEXT_HINT).margin({ top: 8 });
              Row({ space: 12 }) {
                Button('去预约挂号')
                  .type(ButtonType.Normal).borderRadius(20).backgroundColor(GlobalTheme.THEME_COLOR)
                  .layoutWeight(1).height(40)
                  .onClick(() => { router.pushUrl({ url: 'pages/HospitalPage' }); });
                Button('返回首页')
                  .type(ButtonType.Normal).borderRadius(20).backgroundColor('#F5F5F5')
                  .layoutWeight(1).height(40).fontColor('#666666')
                  .onClick(() => { router.back(); });
              }
              .width('100%').margin({ top: 15 });
            }.width('100%').height(300).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
          } else {
            List({ space: 12 }) {
              ForEach(this.queueList, (item: QueueItem) => {
                ListItem() { this.OnlineQueueCard(item); }
              }, (item: QueueItem) => '' + item.appointmentId)
            }.width('100%')
          }
        }
        .width('85%')
        .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .width('100%')
    }
    .height(0)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .align(Alignment.Top);
  }

  @Builder
  OnlineQueueCard(item: QueueItem) {
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

        if (item.isCheckedIn && item.status === 0) {
          Text('已排队中')
            .fontSize(this.isElderMode ? 15 : 12)
            .fontColor('#52C41A')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#F6FFED')
            .borderRadius(12)
        }
      }
      .width('100%')

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 12, bottom: 12 })

      Row() {
        Text('📅 ' + this.formatDate(item.scheduleDate))
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor('#666666')
        Blank()
        Text(item.periodText)
          .fontSize(this.isElderMode ? 15 : 12)
          .fontColor('#666666')
      }
      .width('100%')

      if (!item.isCheckedIn || (item.status !== 0 && item.status !== 1)) {
        Button('📱 开始线上排队')
          .width('100%')
          .height(44)
          .fontSize(this.isElderMode ? 17 : 15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1890FF')
          .borderRadius(22)
          .margin({ top: 12 })
          .onClick(() => {
            this.selectForOnlineQueue(item);
          });
      } else if (item.status === 0) {
        Button('查看实时排名')
          .width('100%')
          .height(44)
          .fontSize(this.isElderMode ? 17 : 15)
          .fontColor('#1890FF')
          .backgroundColor('#E6F7FF')
          .borderRadius(22)
          .margin({ top: 12 })
          .onClick(() => {
            this.currentViewAppointmentId = item.appointmentId;
            this.showRealTimeView = true;
            this.loadRealTimeQueue(item.appointmentId);
          });
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 2, color: '#1890FF30' })
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
        Row({ space: 8 }) {
          Text('实时排队排名')
            .fontSize(this.isElderMode ? 24 : 20)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.THEME_COLOR)

          if (this.isOnlineMode) {
            Text('📱 线上就诊')
              .fontSize(this.isElderMode ? 16 : 13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1890FF')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#E6F7FF')
              .borderRadius(12)
          }
        }
        .width('100%')
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

        if (this.isOnlineMode && this.myRealtimePosition === 1) {
          Column({ space: 10 }) {
            Row({ space: 8 }) {
              Text(this.onlineAutoStarting ? '⏳' : '🎉')
                .fontSize(24)
              Text(this.onlineAutoStarting ? '即将自动进入线上问诊' : '即将进入线上问诊')
                .fontSize(this.isElderMode ? 20 : 17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1890FF')
            }
            .alignItems(VerticalAlign.Center)

            Text('开启您与该医生的对话')
              .fontSize(this.isElderMode ? 15 : 13)
              .fontColor('#666666')

            if (this.onlineAutoStarting) {
              Text(this.onlineCountdown + ' 秒后自动进入对话...')
                .fontSize(this.isElderMode ? 18 : 16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1890FF')
                .margin({ top: 4 })

              Row() {
                Progress({ value: (5 - this.onlineCountdown), total: 5, type: ProgressType.Ring })
                  .width(50)
                  .height(50)
                  .color('#1890FF')
                  .backgroundColor('#E6F7FF')

                Column({ space: 2 }) {
                  Text(this.onlineCountdown.toString())
                    .fontSize(this.isElderMode ? 28 : 24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1890FF')
                  Text('秒')
                    .fontSize(this.isElderMode ? 13 : 11)
                    .fontColor('#999999')
                }
              }
              .alignItems(VerticalAlign.Center)
              .margin({ top: 8 })

              Button('取消自动进入')
                .type(ButtonType.Normal)
                .height(34)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#1890FF')
                .backgroundColor('#FFFFFF')
                .borderRadius(17)
                .border({ width: 1, color: '#91D5FF' })
                .onClick(() => { this.stopOnlineCountdown(); })
                .margin({ top: 8 })
            } else {
              Text('前方无人排队，医生接诊后即可开始视频/图文问诊')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .lineHeight(18)
                .width('80%')
            }
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .backgroundColor('#E6F7FF')
          .borderRadius(12)
          .border({ width: 1.5, color: '#91D5FF', style: BorderStyle.Dashed })
          .margin({ bottom: 12 })
        }

        if (!this.isOnlineMode && this.myRealtimePosition === 1) {
          Column({ space: 10 }) {
            if (this.showGoToClinic) {
              Row({ space: 8 }) {
                Text('🏥')
                  .fontSize(24)
                Text('请前往就诊室')
                  .fontSize(this.isElderMode ? 22 : 18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#52C41A')
              }
              .alignItems(VerticalAlign.Center)

              Text('您已排在第一位，请尽快前往诊室等候就诊')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#666666')

              Button('我知道了')
                .type(ButtonType.Normal)
                .height(36)
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#FFFFFF')
                .backgroundColor('#52C41A')
                .borderRadius(18)
                .onClick(() => { this.showGoToClinic = false; })
                .margin({ top: 8 })
            } else if (this.offlineCountdown > 0) {
              Row({ space: 8 }) {
                Text('🎯')
                  .fontSize(24)
                Text('即将轮到您就诊')
                  .fontSize(this.isElderMode ? 20 : 17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FA8C16')
              }
              .alignItems(VerticalAlign.Center)

              Text(this.offlineCountdown + ' 秒后将提示您前往就诊室')
                .fontSize(this.isElderMode ? 16 : 14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FA8C16')
                .margin({ top: 4 })

              Row() {
                Progress({ value: (10 - this.offlineCountdown), total: 10, type: ProgressType.Ring })
                  .width(44)
                  .height(44)
                  .color('#FA8C16')
                  .backgroundColor('#FFF7E6')

                Column({ space: 2 }) {
                  Text(this.offlineCountdown.toString())
                    .fontSize(this.isElderMode ? 26 : 22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FA8C16')
                  Text('秒')
                    .fontSize(this.isElderMode ? 12 : 10)
                    .fontColor('#999999')
                }
              }
              .alignItems(VerticalAlign.Center)
              .margin({ top: 8 })
            } else {
              Text('您已排在第一位，前方无人等待')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#666666')
                .textAlign(TextAlign.Center)
            }
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .backgroundColor(this.showGoToClinic ? '#F6FFED' : '#FFF7E6')
          .borderRadius(12)
          .border({
            width: 1.5,
            color: this.showGoToClinic ? '#B7EB8F' : '#FFD591',
            style: BorderStyle.Dashed
          })
          .margin({ bottom: 12 })
        }

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
