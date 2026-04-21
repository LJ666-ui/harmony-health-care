import { Alert } from '../monitoring/AnomalyDetector';
import { AlertManager } from '../monitoring/AlertManager';
import { AlertBadge } from '../components/AlertBadge';
import { NavigationTitleBar } from '../components/NavigationTitleBar';

@Entry
@Component
struct AlertHistoryPage {
  @State alerts: Alert[] = [];
  @State selectedFilter: 'ALL' | 'CRITICAL' | 'DANGER' | 'WARNING' | 'INFO' = 'ALL';
  @State selectedType: string = 'ALL';
  @State isLoading: boolean = true;
  @State showDetailDialog: boolean = false;
  @State selectedAlert: Alert | null = null;

  private alertManager: AlertManager = AlertManager.getInstance();

  aboutToAppear(): void {
    console.log('[AlertHistoryPage] 页面加载');
    this.loadAlerts();
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '🚨 预警历史', 
        showBack: true 
      })

      this.buildFilterBar()

      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.alerts.length === 0) {
        this.buildEmptyView()
      } else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.getFilteredAlerts(), (alert: Object) => {
              const alertItem = alert as Alert;
              
              AlertBadge({
                alert: alertItem,
                showDetails: false,
                onAlertClick: (selectedAlert: Alert) => this.handleAlertClick(selectedAlert)
              })
            })
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }

      if (this.showDetailDialog && this.selectedAlert) {
        this.buildDetailDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildFilterBar() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        this.buildFilterChip('全部', 'ALL')
        this.buildFilterChip('极危', 'CRITICAL')
        this.buildFilterChip('危险', 'DANGER')
        this.buildFilterChip('警告', 'WARNING')
        this.buildFilterChip('提示', 'INFO')
      }
      .width('100%')

      Row({ space: 8 }) {
        Text('类型筛选：')
          .fontSize(14)
          .fontColor('#666666')

        Select([
          { value: '全部类型' },
          { value: '血压' },
          { value: '血糖' },
          { value: '心率' },
          { value: '体温' },
          { value: '其他' }
        ])
          .value(this.selectedType === 'ALL' ? '全部类型' : this.selectedType)
          .selected(0)
          .font({ size: 14 })
          .onChange((index: number, value: string) => {
            const typeMap: Record<string, string> = {
              '全部类型': 'ALL',
              '血压': 'blood_pressure',
              '血糖': 'blood_sugar',
              '心率': 'heart_rate',
              '体温': 'temperature',
              '其他': 'other'
            };
            
            this.selectedType = typeMap[value] || 'ALL';
          })
      }
      .width('100%')

      Row({ space: 8 }) {
        Text(`共 ${this.getFilteredAlerts().length} 条预警`)
          .fontSize(13)
          .fontColor('#999999')

        Blank()

        Button('标记全部已读')
          .height(30)
          .fontSize(12)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(15)
          .onClick(() => this.markAllAsRead())
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }

  @Builder buildFilterChip(label: string, filter: string) {
    Button(label)
      .height(32)
      .fontSize(13)
      .fontColor(
        this.selectedFilter === filter ? '#FFFFFF' : 
        filter === 'CRITICAL' ? '#CF1322' :
        filter === 'DANGER' ? '#FF4D4F' :
        filter === 'WARNING' ? '#FAAD14' : '#1677FF'
      )
      .backgroundColor(
        this.selectedFilter === filter ? 
        (filter === 'CRITICAL' ? '#CF1322' :
         filter === 'DANGER' ? '#FF4D4F' :
         filter === 'WARNING' ? '#FAAD14' : '#1677FF') :
        (filter === 'CRITICAL' ? '#FFF1F0' :
         filter === 'DANGER' ? '#FFF2F0' :
         filter === 'WARNING' ? '#FFFBE6' : '#E6F4FF')
      )
      .borderRadius(16)
      .onClick(() => {
        this.selectedFilter = filter as any;
      })
  }

  @Builder buildLoadingView() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(60)
        .height(60)
        .color('#1677FF')
      
      Text('正在加载预警记录...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildEmptyView() {
    Column({ space: 20 }) {
      Text('✅')
        .fontSize(48)

      Text('暂无预警记录')
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Text('您的各项指标都在正常范围内')
        .fontSize(14)
        .fontColor('#999999')

      Button('返回监控主页')
        .height(40)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(20)
        .margin({ top: 16 })
        .onClick(() => router.back())
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildDetailDialog() {
    Column() {
      Row() {
        Text('预警详情')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('✕')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => {
            this.showDetailDialog = false;
            this.selectedAlert = null;
          })
      }
      .width('100%')
      .padding(16)

      Divider()
        .color('#EEEEEE')

      if (this.selectedAlert) {
        Scroll() {
          Column({ space: 16 }) {
            this.buildDetailHeader(this.selectedAlert)
            this.buildDetailContent(this.selectedAlert)
            this.buildDetectionDetails(this.selectedAlert)
            this.buildActionButtons(this.selectedAlert)
          }
          .padding(16)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('90%')
    .maxHeight('80%')
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.2)',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder buildDetailHeader(alert: Alert) {
    Column({ space: 10 }) {
      Row({ space: 12 }) {
        Text(this.getSeverityIcon(alert.severity))
          .fontSize(28)

        Column({ space: 4 }) {
          Text(alert.title)
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)

          Row({ space: 8 }) {
            Text(this.getSeverityLabel(alert.severity))
              .fontSize(13)
              .fontColor(this.getSeverityColor(alert.severity))
              .fontWeight(FontWeight.Bold)
              .padding({ horizontal: 8, vertical: 3 })
              .backgroundColor(
                alert.severity === 'CRITICAL' ? '#FFF1F0' :
                alert.severity === 'DANGER' ? '#FFF2F0' :
                alert.severity === 'WARNING' ? '#FFFBE6' : '#E6F4FF'
              )
              .borderRadius(10)

            Text(alert.riskLevel)
              .fontSize(13)
              .fontColor('#666666')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Text(new Date(alert.timestamp).toLocaleString('zh-CN'))
        .fontSize(13)
        .fontColor('#BBBBBB')
    }
    .width('100%')
  }

  @Builder buildDetailContent(alert: Alert) {
    Column({ space: 8 }) {
      Text('预警内容')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      Text(alert.message)
        .fontSize(15)
        .fontColor('#555555')
        .lineHeight(22)
        .width('100%')
        .padding(12)
        .backgroundColor('#FAFAFA')
        .borderRadius(10)
    }
    .width('100%')
  }

  @Builder buildDetectionDetails(alert: Alert) {
    if (alert.detectionDetails && Object.keys(alert.detectionDetails).length > 0) {
      Column({ space: 8 }) {
        Text('检测详情')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontSize.Medium)

        Column({ space: 8 }) {
          ForEach(Object.entries(alert.detectionDetails), (entry: [string, any]) => {
            const [key, value] = entry;
            
            Row({ space: 8 }) {
              Text(key)
                .fontSize(14)
                .fontColor('#666666')
              
              Blank()
              
              Text(String(value))
                .fontSize(14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .padding({ vertical: 6, horizontal: 12 })
            .backgroundColor('#F9F9F9')
            .borderRadius(6)
          })
        }
        .width('100%')
      }
      .width('100%')
    }
  }

  @Builder buildActionButtons(alert: Alert) {
    Row({ space: 12 }) {
      if (!alert.isHandled) {
        Button('标记已处理')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(22)
          .onClick(() => this.markAsHandled(alert))
      }

      Button('关闭')
        .layoutWeight(1)
        .height(44)
        .fontSize(15)
        .fontColor('#666666')
        .backgroundColor('#F5F5F5')
        .borderRadius(22)
        .onClick(() => {
          this.showDetailDialog = false;
          this.selectedAlert = null;
        })
    }
    .width('100%')
  }

  private async loadAlerts(): Promise<void> {
    this.isLoading = true;

    try {
      await new Promise(resolve => setTimeout(resolve, 500));

      try {
        const mockModule = await import('../mock/monitoringMock');
        
        if (mockModule && mockModule.monitoringMock) {
          this.alerts = mockModule.monitoringMock.getSampleAlerts();
          
          const criticalAlerts = mockModule.monitoringMock.getCriticalAlerts();
          this.alerts = [...criticalAlerts, ...this.alerts];
          
          console.log(`[AlertHistoryPage] 加载了 ${this.alerts.length} 条预警`);
        }
      } catch (error) {
        console.warn('[AlertHistoryPage] Mock加载失败:', error instanceof Error ? error.message : String(error));
        
        this.alerts = [];
      }

    } catch (error) {
      console.error('[AlertHistoryPage] 加载失败:', error instanceof Error ? error.message : String(error));
      
      this.alerts = [];
    } finally {
      this.isLoading = false;
    }
  }

  private getFilteredAlerts(): Alert[] {
    let filtered = [...this.alerts];

    if (this.selectedFilter !== 'ALL') {
      filtered = filtered.filter(a => a.severity === this.selectedFilter);
    }

    if (this.selectedType !== 'ALL') {
      filtered = filtered.filter(a => a.type === this.selectedType);
    }

    return filtered.sort((a, b) => 
      new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
    );
  }

  private handleAlertClick(alert: Alert): void {
    console.log(`[AlertHistoryPage] 点击预警: ${alert.alertId}`);
    
    this.selectedAlert = alert;
    this.showDetailDialog = true;

    this.alertManager.markAsRead(alert.alertId);
    
    const index = this.alerts.findIndex(a => a.alertId === alert.alertId);
    
    if (index > -1) {
      this.alerts[index].isRead = true;
    }
  }

  private markAsHandled(alert: Alert): void {
    console.log(`[AlertHistoryPage] 标记已处理: ${alert.alertId}`);
    
    this.alertManager.markAsHandled(alert.alertId);
    
    const index = this.alerts.findIndex(a => a.alertId === alert.alertId);
    
    if (index > -1) {
      this.alerts[index].isHandled = true;
    }

    this.showDetailDialog = false;
    this.selectedAlert = null;

    AlertDialog.show({
      title: '✅ 已处理',
      message: '该预警已标记为已处理',
      primaryText: '确定'
    });
  }

  private markAllAsRead(): void {
    console.log('[AlertHistoryPage] 标记全部已读');

    for (const alert of this.alerts) {
      if (!alert.isRead) {
        this.alertManager.markAsRead(alert.alertId);
        alert.isRead = true;
      }
    }

    AlertDialog.show({
      title: '✅ 完成',
      message: `已将 ${this.alerts.length} 条预警标记为已读`,
      primaryText: '确定'
    });
  }

  private getSeverityIcon(severity: string): string {
    switch (severity) {
      case 'CRITICAL':
        return '⛔';
      case 'DANGER':
        return '🔴';
      case 'WARNING':
        return '⚠️';
      case 'INFO':
        return 'ℹ️';
      default:
        return '📋';
    }
  }

  private getSeverityLabel(severity: string): string {
    switch (severity) {
      case 'CRITICAL':
        return '极危';
      case 'DANGER':
        return '危险';
      case 'WARNING':
        return '警告';
      case 'INFO':
        return '提示';
      default:
        return '未知';
    }
  }

  private getSeverityColor(severity: string): string {
    switch (severity) {
      case 'CRITICAL':
        return '#CF1322';
      case 'DANGER':
        return '#FF4D4F';
      case 'WARNING':
        return '#FAAD14';
      case 'INFO':
        return '#1677FF';
      default:
        return '#999999';
    }
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;

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
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
