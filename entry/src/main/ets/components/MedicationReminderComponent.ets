import { WebSocketService, MessageType, MedicationReminder } from '../services/WebSocketService';
import { MedicalService } from '../services/MedicalService';
import { NotificationService } from '../services/NotificationService';
import { TerminalManager, TerminalType } from '../services/TerminalManager';

/**
 * 用药提醒组件
 * 显示用药提醒列表，支持确认服药、延迟服药、跳过服药
 */
@Component
export struct MedicationReminderComponent {
  @State reminders: MedicationReminder[] = [];
  @State isLoading: boolean = false;
  @State showDetail: boolean = false;
  @State selectedReminder: MedicationReminder | null = null;
  
  private medicalService: MedicalService = MedicalService.getInstance();
  private notificationService: NotificationService = NotificationService.getInstance();
  private terminalManager: TerminalManager = TerminalManager.getInstance();
  
  aboutToAppear() {
    this.loadReminders();
    this.setupListeners();
  }
  
  /**
   * 加载用药提醒
   */
  private async loadReminders() {
    this.isLoading = true;
    try {
      const userId = this.terminalManager.getCurrentUserId();
      if (userId) {
        this.reminders = await this.medicalService.getMedicationReminders(userId);
      }
    } catch (error) {
      console.error('加载用药提醒失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  /**
   * 设置监听器
   */
  private setupListeners() {
    // 监听新的用药提醒
    this.medicalService.onMedicationReminder = (reminder: MedicationReminder) => {
      this.reminders.unshift(reminder);
      this.showNotification(reminder);
    };
  }
  
  /**
   * 显示通知
   */
  private showNotification(reminder: MedicationReminder) {
    // 发送系统通知
    this.notificationService.sendNotification({
      type: 'MEDICATION_REMINDER',
      receiverId: reminder.patientId,
      receiverRole: 'PATIENT',
      title: '用药提醒',
      content: `请按时服用${reminder.medication.name}`,
      priority: 'HIGH',
      data: reminder
    });
  }
  
  /**
   * 确认服药
   */
  private async confirmMedication(reminderId: string, action: 'TAKEN' | 'SKIPPED' | 'DELAYED') {
    try {
      await this.medicalService.confirmMedication(reminderId, action);
      
      // 更新列表
      const index = this.reminders.findIndex(r => r.id === reminderId);
      if (index > -1) {
        this.reminders.splice(index, 1);
      }
      
      // 显示成功提示
      console.info('服药确认成功');
    } catch (error) {
      console.error('确认服药失败:', error);
    }
  }
  
  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
  
  /**
   * 获取状态颜色
   */
  private getStatusColor(status: string): string {
    switch (status) {
      case 'PENDING':
        return '#FFA500'; // 橙色
      case 'TAKEN':
        return '#4CAF50'; // 绿色
      case 'SKIPPED':
        return '#9E9E9E'; // 灰色
      case 'DELAYED':
        return '#FF5722'; // 深橙色
      default:
        return '#9E9E9E';
    }
  }
  
  build() {
    Column() {
      // 标题
      Row() {
        Text('用药提醒')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text(`${this.reminders.length} 条`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      
      Divider().color('#E0E0E0')
      
      // 提醒列表
      if (this.isLoading) {
        LoadingProgress()
          .width(48)
          .height(48)
          .margin({ top: 48 })
      } else if (this.reminders.length === 0) {
        Column() {
          Text('暂无用药提醒')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 48 })
        }
        .width('100%')
        .height('100%')
      } else {
        List() {
          ForEach(this.reminders, (reminder: MedicationReminder) => {
            ListItem() {
              this.ReminderItem(reminder)
            }
          }, (reminder: MedicationReminder) => reminder.id)
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
  }
  
  @Builder
  ReminderItem(reminder: MedicationReminder) {
    Column() {
      // 药品信息
      Row() {
        Column() {
          Text(reminder.medication.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Text(`${reminder.medication.dosage} | ${reminder.medication.instructions}`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Column() {
          Text(this.formatTime(reminder.scheduledTime))
            .fontSize(14)
            .fontColor('#333333')
          
          Text(reminder.status)
            .fontSize(12)
            .fontColor(this.getStatusColor(reminder.status))
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .padding(16)
      
      // 注意事项
      if (reminder.medication.warnings && reminder.medication.warnings.length > 0) {
        Column() {
          ForEach(reminder.medication.warnings, (warning: string) => {
            Row() {
              Text('⚠️')
                .fontSize(12)
              Text(warning)
                .fontSize(12)
                .fontColor('#FF5722')
            }
            .margin({ top: 4 })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
        .alignItems(HorizontalAlign.Start)
      }
      
      // 操作按钮（仅PENDING状态显示）
      if (reminder.status === 'PENDING') {
        Row() {
          Button('已服药')
            .fontSize(14)
            .backgroundColor('#4CAF50')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.confirmMedication(reminder.id, 'TAKEN');
            })
          
          Button('延迟')
            .fontSize(14)
            .backgroundColor('#FF9800')
            .fontColor('#FFFFFF')
            .margin({ left: 8 })
            .onClick(() => {
              // 显示延迟时间选择
              this.confirmMedication(reminder.id, 'DELAYED');
            })
          
          Button('跳过')
            .fontSize(14)
            .backgroundColor('#9E9E9E')
            .fontColor('#FFFFFF')
            .margin({ left: 8 })
            .onClick(() => {
              this.confirmMedication(reminder.id, 'SKIPPED');
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding({ left: 16, right: 16, bottom: 12 })
      }
    }
    .width('100%')
  }
}
