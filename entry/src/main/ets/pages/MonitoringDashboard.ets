import { RealtimeMonitor, VitalSignsSnapshot } from '../monitoring/RealtimeMonitor';
import { Alert } from '../monitoring/AnomalyDetector';
import { AlertManager } from '../monitoring/AlertManager';
import { ReminderScheduler, Reminder } from '../monitoring/ReminderScheduler';
import { VitalSignsCard } from '../components/VitalSignsCard';
import { AlertBadge } from '../components/AlertBadge';
import { ReminderListItem } from '../components/ReminderListItem';
import { NavigationTitleBar } from '../components/NavigationTitleBar';

@Entry
@Component
struct MonitoringDashboard {
  @State vitalSigns: VitalSignsSnapshot = this.getEmptyVitalSigns();
  @State activeAlerts: Alert[] = [];
  @State upcomingReminders: Reminder[] = [];
  @State isMonitoring: boolean = false;
  @State lastUpdateTime: string = '';
  @State isLoading: boolean = true;
  @State showAddRecordDialog: boolean = false;

  private monitorService: RealtimeMonitor = RealtimeMonitor.getInstance();
  private alertManager: AlertManager = AlertManager.getInstance();
  private reminderService: ReminderScheduler = ReminderScheduler.getInstance();

  aboutToAppear(): void {
    console.log('[MonitoringDashboard] 页面加载完成');
    this.initializeServices();
    this.loadInitialData();
  }

  aboutToDisappear(): void {
    console.log('[MonitoringDashboard] 页面卸载');
    this.cleanup();
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '🏥 健康监控', 
        showBack: true,
        onSettingsClick: () => this.navigateToSettings()
      })

      if (this.isLoading) {
        this.buildLoadingView()
      } else {
        Scroll() {
          Column({ space: 16 }) {
            this.buildStatusHeader()

            this.buildVitalSignsSection()

            this.buildLatestAlertSection()

            this.buildUpcomingRemindersSection()

            this.buildQuickActionsBar()
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildLoadingView() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(60)
        .height(60)
        .color('#1677FF')
      
      Text('正在加载健康数据...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildStatusHeader() {
    Row({ space: 12 }) {
      Row({ space: 8 }) {
        Text(this.isMonitoring ? '●' : '○')
          .fontSize(14)
          .fontColor(this.isMonitoring ? '#52C41A' : '#999999')
        
        Text(this.isMonitoring ? '监控中' : '已停止')
          .fontSize(14)
          .fontColor(this.isMonitoring ? '#52C41A' : '#999999')
          .fontWeight(FontWeight.Medium)
      }
      .padding({ horizontal: 10, vertical: 5 })
      .backgroundColor(
        this.isMonitoring ? '#F6FFED20' : '#F5F5F5'
      )
      .borderRadius(15)

      Blank()

      Text(`更新于 ${this.lastUpdateTime}`)
        .fontSize(12)
        .fontColor('#BBBBBB')

      Button(this.isMonitoring ? '停止' : '启动')
        .height(32)
        .fontSize(13)
        .fontColor(this.isMonitoring ? '#FF4D4F' : '#FFFFFF')
        .backgroundColor(this.isMonitoring ? '#FFF2F0' : '#52C41A')
        .borderRadius(16)
        .onClick(() => this.toggleMonitoring())
    }
    .width('100%')
    .padding({ horizontal: 8 })
  }

  @Builder buildVitalSignsSection() {
    Column({ space: 12 }) {
      Text('生命体征')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      if (this.vitalSigns.bloodPressure) {
        VitalSignsCard({
          type: 'blood_pressure',
          value: `${this.vitalSigns.bloodPressure.systolic} / ${this.vitalSigns.bloodPressure.diastolic}`,
          unit: 'mmHg',
          status: this.getBloodPressureStatus(),
          trend: 'up',
          trendData: [130, 135, 132, 138, 140, 142, this.vitalSigns.bloodPressure.systolic],
          lastUpdateTime: this.formatTime(this.vitalSigns.bloodPressure.timestamp),
          onClick: () => console.log('查看血压详情')
        })
      }

      Row({ space: 12 }) {
        if (this.vitalSigns.bloodSugar) {
          VitalSignsCard({
            type: 'blood_sugar',
            value: `${this.vitalSigns.bloodSugar.value.toFixed(1)}`,
            unit: 'mmol/L',
            status: this.getBloodSugarStatus(),
            trendData: [5.8, 6.0, 5.9, 6.1, 6.3, 6.0, this.vitalSigns.bloodSugar.value],
            lastUpdateTime: this.formatTime(this.vitalSigns.bloodSugar.timestamp),
            layoutWeight: 1,
            onClick: () => console.log('查看血糖详情')
          })
        }

        if (this.vitalSigns.heartRate) {
          VitalSignsCard({
            type: 'heart_rate',
            value: `${this.vitalSigns.heartRate.value}`,
            unit: 'bpm',
            status: this.getHeartRateStatus(),
            trendData: [72, 75, 70, 74, 76, 73, this.vitalSigns.heartRate.value],
            lastUpdateTime: this.formatTime(this.vitalSigns.heartRate.timestamp),
            layoutWeight: 1,
            onClick: () => console.log('查看心率详情')
          })
        }
      }
      .width('100%')

      Row({ space: 12 }) {
        if (this.vitalSigns.weight) {
          VitalSignsCard({
            type: 'weight',
            value: `${this.vitalSigns.weight.value.toFixed(1)}`,
            unit: 'kg',
            status: 'normal',
            lastUpdateTime: this.formatTime(this.vitalSigns.weight.timestamp),
            layoutWeight: 1,
            onClick: () => console.log('查看体重详情')
          })
        }

        if (this.vitalSigns.temperature) {
          VitalSignsCard({
            type: 'temperature',
            value: `${this.vitalSigns.temperature.value.toFixed(1)}`,
            unit: '°C',
            status: this.getTemperatureStatus(),
            lastUpdateTime: this.formatTime(this.vitalSigns.temperature.timestamp),
            layoutWeight: 1,
            onClick: () => console.log('查看体温详情')
          })
        }
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder buildLatestAlertSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('🚨 最新预警')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        if (this.activeAlerts.length > 0) {
          Text(`${this.activeAlerts.length}`)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .width(22)
            .height(22)
            .borderRadius(11)
            .textAlign(TextAlign.Center)
            .backgroundColor('#FF4D4F')
        }

        Blank()

        Button('查看全部')
          .height(30)
          .fontSize(12)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(15)
          .onClick(() => this.navigateToAlertHistory())
      }
      .width('100%')

      if (this.activeAlerts.length > 0) {
        ForEach(this.activeAlerts.slice(0, 3), (alert: Object) => {
          const alertItem = alert as Alert;
          
          AlertBadge({
            alert: alertItem,
            showDetails: true,
            onAlertClick: (selectedAlert: Alert) => this.handleAlertClick(selectedAlert)
          })
        })
      } else {
        Column({ space: 12 }) {
          Text('✅')
            .fontSize(40)
          
          Text('暂无预警信息')
            .fontSize(15)
            .fontColor('#666666')
          
          Text('所有指标正常，继续保持！')
            .fontSize(13)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(24)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
      }
    }
    .width('100%')
  }

  @Builder buildUpcomingRemindersSection() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('⏰ 即将到来的提醒')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        if (this.upcomingReminders.length > 0) {
          Text(`${this.upcomingReminders.length}`)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .width(22)
            .height(22)
            .borderRadius(11)
            .textAlign(TextAlign.Center)
            .backgroundColor('#FAAD14')
        }

        Blank()

        Button('设置提醒')
          .height(30)
          .fontSize(12)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(15)
          .onClick(() => this.navigateToReminderSettings())
      }
      .width('100%')

      if (this.upcomingReminders.length > 0) {
        ForEach(this.upcomingReminders.slice(0, 3), (reminder: Object) => {
          const reminderItem = reminder as Reminder;
          
          ReminderListItem({
            reminder: reminderItem,
            onComplete: (reminderId: string) => this.handleCompleteReminder(reminderId),
            onSnooze: (reminderId: string, minutes: number) => this.handleSnoozeReminder(reminderId, minutes)
          })
        })
      } else {
        Column({ space: 12 }) {
          Text('📅')
            .fontSize(40)
          
          Text('暂无即将到来的提醒')
            .fontSize(15)
            .fontColor('#666666')
          
          Button('添加新提醒')
            .height(36)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(18)
            .margin({ top: 8 })
            .onClick(() => this.navigateToReminderSettings())
        }
        .width('100%')
        .padding(24)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
      }
    }
    .width('100%')
  }

  @Builder buildQuickActionsBar() {
    Row({ space: 12 }) {
      Button('立即测量血压')
        .layoutWeight(1)
        .height(48)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(24)
        .onClick(() => this.showAddRecordDialog = true)

      Button('添加记录')
        .layoutWeight(1)
        .height(48)
        .fontSize(15)
        .fontColor('#1677FF')
        .backgroundColor('#E6F4FF')
        .borderRadius(24)
        .onClick(() => this.showAddRecordDialog = true)
    }
    .width('100%')
  }

  private initializeServices(): void {
    try {
      this.monitorService.subscribeToAlerts((alert: Alert) => {
        this.onNewAlert(alert);
      });

      this.reminderService.subscribeToReminders((reminder: Reminder) => {
        this.onNewReminder(reminder);
      });

      console.log('[MonitoringDashboard] 服务初始化完成');

    } catch (error) {
      console.error('[MonitoringDashboard] 服务初始化失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private async loadInitialData(): Promise<void> {
    this.isLoading = true;

    try {
      await this.loadMockData();
      
      this.isMonitoring = this.monitorService.getMonitoringStatus().isActive;
      this.lastUpdateTime = new Date().toLocaleTimeString('zh-CN', { 
        hour: '2-digit', 
        minute: '2-digit' 
      });

      setTimeout(() => {
        this.isLoading = false;
      }, 800);

    } catch (error) {
      console.error('[MonitoringDashboard] 数据加载失败:', error instanceof Error ? error.message : String(error));
      this.isLoading = false;
    }
  }

  private async loadMockData(): Promise<void> {
    try {
      const mockModule = await import('../mock/monitoringMock');
      
      if (mockModule && mockModule.monitoringMock) {
        this.vitalSigns = mockModule.monitoringMock.getSampleVitalSigns();
        this.activeAlerts = mockModule.monitoringMock.getSampleAlerts();
        this.upcomingReminders = mockModule.monitoringMock.getUpcomingReminders();

        console.log('[MonitoringDashboard] Mock数据加载成功');
      }
    } catch (error) {
      console.warn('[MonitoringDashboard] Mock加载失败，使用默认数据:', error instanceof Error ? error.message : String(error));
      
      this.vitalSigns = this.getDefaultVitalSigns();
    }
  }

  private toggleMonitoring(): void {
    if (this.isMonitoring) {
      this.monitorService.stopMonitoring();
      this.isMonitoring = false;
      console.log('[MonitoringDashboard] 监控已停止');
    } else {
      this.monitorService.startMonitoring();
      this.isMonitoring = true;
      console.log('[MonitoringDashboard] 监控已启动');
    }
  }

  private onNewAlert(alert: Alert): void {
    console.log(`[MonitoringDashboard] 收到新预警: ${alert.title}`);
    
    this.activeAlerts.unshift(alert);
    
    if (this.activeAlerts.length > 10) {
      this.activeAlerts = this.activeAlerts.slice(0, 10);
    }
  }

  private onNewReminder(reminder: Reminder): void {
    console.log(`[MonitoringDashboard] 收到新提醒: ${reminder.title}`);
    
    const exists = this.upcomingReminders.find(r => r.id === reminder.id);
    
    if (!exists) {
      this.upcomingReminders.push(reminder);
      
      this.upcomingReminders.sort((a, b) => 
        new Date(a.scheduledTime).getTime() - new Date(b.scheduledTime).getTime()
      );
    }
  }

  private handleAlertClick(alert: Alert): void {
    console.log(`[MonitoringDashboard] 点击预警: ${alert.alertId}`);
    
    this.alertManager.markAsRead(alert.alertId);
    
    router.pushUrl({
      url: 'pages/AlertHistoryPage'
    });
  }

  private handleCompleteReminder(reminderId: string): void {
    console.log(`[MonitoringDashboard] 完成提醒: ${reminderId}`);
    
    this.reminderService.completeReminder(reminderId);
    
    this.upcomingReminders = this.upcomingReminders.filter(r => r.id !== reminderId);
  }

  private handleSnoozeReminder(reminderId: string, minutes: number): void {
    console.log(`[MonitoringDashboard] 延迟提醒 ${minutes} 分钟: ${reminderId}`);
    
    this.reminderService.snoozeReminder(reminderId, minutes);
  }

  private navigateToSettings(): void {
    router.pushUrl({
      url: 'pages/ReminderSettingsPage'
    });
  }

  private navigateToAlertHistory(): void {
    router.pushUrl({
      url: 'pages/AlertHistoryPage'
    });
  }

  private navigateToReminderSettings(): void {
    router.pushUrl({
      url: 'pages/ReminderSettingsPage'
    });
  }

  private getBloodPressureStatus(): 'normal' | 'warning' | 'danger' {
    if (!this.vitalSigns.bloodPressure) return 'normal';
    
    const { systolic, diastolic } = this.vitalSigns.bloodPressure;

    if (systolic >= 180 || systolic <= 90 || diastolic >= 110 || diastolic <= 60) {
      return 'danger';
    } else if (systolic >= 140 || diastolic >= 90) {
      return 'warning';
    }

    return 'normal';
  }

  private getBloodSugarStatus(): 'normal' | 'warning' | 'danger' {
    if (!this.vitalSigns.bloodSugar) return 'normal';

    const value = this.vitalSigns.bloodSugar.value;

    if (value >= 11.0 || value <= 3.9) {
      return 'danger';
    } else if (value >= 7.0 || value <= 4.5) {
      return 'warning';
    }

    return 'normal';
  }

  private getHeartRateStatus(): 'normal' | 'warning' | 'danger' {
    if (!this.vitalSigns.heartRate) return 'normal';

    const value = this.vitalSigns.heartRate.value;

    if (value >= 120 || value <= 50) {
      return 'danger';
    } else if (value >= 100 || value <= 55) {
      return 'warning';
    }

    return 'normal';
  }

  private getTemperatureStatus(): 'normal' | 'warning' | 'danger' {
    if (!this.vitalSigns.temperature) return 'normal';

    const value = this.vitalSigns.temperature.value;

    if (value >= 39.5 || value <= 35.0) {
      return 'danger';
    } else if (value >= 38.5 || value <= 35.5) {
      return 'warning';
    }

    return 'normal';
  }

  private formatTime(timestamp: string): string {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('zh-CN', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  }

  private getEmptyVitalSigns(): VitalSignsSnapshot {
    return {
      bloodPressure: null,
      bloodSugar: null,
      heartRate: null,
      weight: null,
      temperature: null,
      lastUpdateTime: ''
    };
  }

  private getDefaultVitalSigns(): VitalSignsSnapshot {
    const now = new Date().toISOString();
    
    return {
      bloodPressure: {
        systolic: 135,
        diastolic: 85,
        timestamp: now
      },
      bloodSugar: {
        value: 6.2,
        type: 'fasting',
        timestamp: now
      },
      heartRate: {
        value: 72,
        timestamp: now
      },
      weight: {
        value: 65.5,
        timestamp: now
      },
      temperature: {
        value: 36.5,
        timestamp: now
      },
      lastUpdateTime: now
    };
  }

  private cleanup(): void {
    console.log('[MonitoringDashboard] 清理资源');
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @Prop onSettingsClick?: () => void;

  build() {
    Row() {
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Text('⚙️')
        .fontSize(22)
        .onClick(() => {
          if (this.onSettingsClick) {
            this.onSettingsClick();
          }
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
