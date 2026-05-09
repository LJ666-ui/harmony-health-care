import { EmergencyNotification } from '../services/WebSocketService';
import { NotificationService } from '../services/NotificationService';
import { TerminalManager } from '../services/TerminalManager';

/**
 * 紧急通知组件
 * 显示紧急通知，支持查看详情、确认处理
 */
@Component
export struct EmergencyNotificationComponent {
  @State notifications: EmergencyNotification[] = [];
  @State showDetail: boolean = false;
  @State selectedNotification: EmergencyNotification | null = null;
  @State isPlaying: boolean = false;
  
  private notificationService: NotificationService = NotificationService.getInstance();
  private terminalManager: TerminalManager = TerminalManager.getInstance();
  
  aboutToAppear() {
    this.loadNotifications();
    this.setupListeners();
  }
  
  /**
   * 加载紧急通知
   */
  private async loadNotifications() {
    try {
      this.notifications = this.notificationService.getEmergencyNotifications();
    } catch (error) {
      console.error('加载紧急通知失败:', error);
    }
  }
  
  /**
   * 设置监听器
   */
  private setupListeners() {
    // 监听新的紧急通知
    this.notificationService.onEmergencyNotification = (notification: EmergencyNotification) => {
      this.notifications.unshift(notification);
      this.showEmergencyAlert(notification);
    };
  }
  
  /**
   * 显示紧急告警
   */
  private showEmergencyAlert(notification: EmergencyNotification) {
    // 播放告警声音
    this.playAlertSound();
    
    // 震动提醒
    this.vibrate();
    
    // 显示全屏告警对话框
    this.selectedNotification = notification;
    this.showDetail = true;
  }
  
  /**
   * 播放告警声音
   */
  private playAlertSound() {
    // 这里应该播放系统告警音或自定义音频
    console.warn('播放告警声音');
    this.isPlaying = true;
    
    // 5秒后停止
    setTimeout(() => {
      this.isPlaying = false;
    }, 5000);
  }
  
  /**
   * 震动提醒
   */
  private vibrate() {
    // 这里应该调用震动API
    console.warn('震动提醒');
  }
  
  /**
   * 获取严重程度颜色
   */
  private getSeverityColor(severity: string): string {
    switch (severity) {
      case 'LOW':
        return '#4CAF50'; // 绿色
      case 'MEDIUM':
        return '#FF9800'; // 橙色
      case 'HIGH':
        return '#FF5722'; // 深橙色
      case 'CRITICAL':
        return '#F44336'; // 红色
      default:
        return '#9E9E9E';
    }
  }
  
  /**
   * 获取严重程度文本
   */
  private getSeverityText(severity: string): string {
    switch (severity) {
      case 'LOW':
        return '低';
      case 'MEDIUM':
        return '中';
      case 'HIGH':
        return '高';
      case 'CRITICAL':
        return '危急';
      default:
        return '未知';
    }
  }
  
  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${month}-${day} ${hours}:${minutes}`;
  }
  
  /**
   * 处理紧急通知
   */
  private async handleNotification(notificationId: string) {
    try {
      // 调用处理API
      console.info('处理紧急通知:', notificationId);
      
      // 关闭详情页
      this.showDetail = false;
      this.selectedNotification = null;
    } catch (error) {
      console.error('处理紧急通知失败:', error);
    }
  }
  
  build() {
    Stack() {
      // 通知列表
      Column() {
        // 标题
        Row() {
          Text('紧急通知')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Blank()
          
          if (this.notifications.length > 0) {
            Badge({
              count: this.notifications.length,
              position: BadgePosition.Right,
              style: { badgeColor: '#F44336', badgeTextColor: '#FFFFFF' }
            }) {
              Text('')
                .width(1)
                .height(1)
            }
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        
        Divider().color('#E0E0E0')
        
        // 通知列表
        if (this.notifications.length === 0) {
          Column() {
            Text('暂无紧急通知')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 48 })
          }
          .width('100%')
          .height('100%')
        } else {
          List() {
            ForEach(this.notifications, (notification: EmergencyNotification) => {
              ListItem() {
                this.NotificationItem(notification)
              }
            }, (notification: EmergencyNotification) => notification.id)
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 1, color: '#E0E0E0' })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      
      // 紧急告警详情（全屏显示）
      if (this.showDetail && this.selectedNotification) {
        this.EmergencyDetailDialog(this.selectedNotification)
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  NotificationItem(notification: EmergencyNotification) {
    Column() {
      Row() {
        // 严重程度标识
        Column() {
          Text(this.getSeverityText(notification.severity))
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .width(32)
        .height(32)
        .borderRadius(16)
        .backgroundColor(this.getSeverityColor(notification.severity))
        .justifyContent(FlexAlign.Center)
        
        // 通知内容
        Column() {
          Text(notification.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Text(notification.content)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 12 })
        
        // 时间
        Text(this.formatTime(notification.timestamp))
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .padding(16)
      
      // 患者信息
      Row() {
        Text(`患者: ${notification.patientName}`)
          .fontSize(12)
          .fontColor('#666666')
        
        if (notification.patientLocation) {
          Text(` | 位置: ${notification.patientLocation.address}`)
            .fontSize(12)
            .fontColor('#666666')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      
      // 生命体征
      if (notification.vitalSigns) {
        Row() {
          if (notification.vitalSigns.heartRate) {
            Text(`心率: ${notification.vitalSigns.heartRate} bpm`)
              .fontSize(12)
              .fontColor('#FF5722')
              .margin({ right: 16 })
          }
          
          if (notification.vitalSigns.bloodPressure) {
            Text(`血压: ${notification.vitalSigns.bloodPressure}`)
              .fontSize(12)
              .fontColor('#FF5722')
              .margin({ right: 16 })
          }
          
          if (notification.vitalSigns.temperature) {
            Text(`体温: ${notification.vitalSigns.temperature}°C`)
              .fontSize(12)
              .fontColor('#FF5722')
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })
      }
    }
    .width('100%')
    .backgroundColor(notification.severity === 'CRITICAL' ? '#FFEBEE' : '#FFFFFF')
    .onClick(() => {
      this.selectedNotification = notification;
      this.showDetail = true;
    })
  }
  
  @Builder
  EmergencyDetailDialog(notification: EmergencyNotification) {
    Column() {
      // 标题栏
      Row() {
        Text('紧急通知')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(56)
      .backgroundColor(this.getSeverityColor(notification.severity))
      .justifyContent(FlexAlign.Center)
      
      // 内容
      Column() {
        // 患者信息
        Column() {
          Text(notification.patientName)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text(`患者ID: ${notification.patientId}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .margin({ top: 24 })
        
        Divider().margin({ top: 16, bottom: 16 })
        
        // 通知详情
        Column() {
          Text(notification.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Text(notification.content)
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 24, right: 24 })
        
        // 生命体征
        if (notification.vitalSigns) {
          Column() {
            Text('生命体征')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 12 })
            
            Row() {
              if (notification.vitalSigns.heartRate) {
                this.VitalSignItem('心率', `${notification.vitalSigns.heartRate}`, 'bpm')
              }
              
              if (notification.vitalSigns.bloodPressure) {
                this.VitalSignItem('血压', notification.vitalSigns.bloodPressure, '')
              }
              
              if (notification.vitalSigns.temperature) {
                this.VitalSignItem('体温', `${notification.vitalSigns.temperature}`, '°C')
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
          }
          .width('100%')
          .padding(24)
        }
        
        // 病历摘要
        if (notification.medicalSummary) {
          Column() {
            Text('病历摘要')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 8 })
            
            Text(notification.medicalSummary)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 24, right: 24, bottom: 24 })
        }
      }
      .layoutWeight(1)
      
      // 操作按钮
      Row() {
        Button('查看详情')
          .fontSize(16)
          .backgroundColor('#2196F3')
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .onClick(() => {
            // 跳转到患者详情页
            console.info('查看患者详情');
          })
        
        Button('立即处理')
          .fontSize(16)
          .backgroundColor('#4CAF50')
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .margin({ left: 16 })
          .onClick(() => {
            this.handleNotification(notification.id);
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  @Builder
  VitalSignItem(label: string, value: string, unit: string) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#999999')
      
      Row() {
        Text(value)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF5722')
        
        Text(unit)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 4 })
      }
      .margin({ top: 4 })
    }
  }
}
