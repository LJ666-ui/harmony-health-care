import { Reminder } from '../monitoring/ReminderScheduler';

@Component
export struct ReminderListItem {
  @Prop reminder: Reminder;
  @Prop showActions: boolean = true;
  @Prop onComplete?: (reminderId: string) => void;
  @Prop onSnooze?: (reminderId: string, minutes: number) => void;
  @Prop onToggle?: (reminderId: string, active: boolean) => void;

  private getTypeIcon(): string {
    const icons: Record<string, string> = {
      'MEDICATION': '💊',
      'MEASUREMENT': '📊',
      'EXERCISE': '🏃',
      'APPOINTMENT': '🏥',
      'CUSTOM': '📝'
    };
    return icons[this.reminder.type] || '📋';
  }

  private getTypeColor(): string {
    const colors: Record<string, string> = {
      'MEDICATION': '#1677FF',
      'MEASUREMENT': '#FF4D4F',
      'EXERCISE': '#52C41A',
      'APPOINTMENT': '#722ED1',
      'CUSTOM': '#999999'
    };
    return colors[this.reminder.type] || '#999999';
  }

  private getTypeLabel(): string {
    const labels: Record<string, string> = {
      'MEDICATION': '服药',
      'MEASUREMENT': '测量',
      'EXERCISE': '运动',
      'APPOINTMENT': '复诊',
      'CUSTOM': '自定义'
    };
    return labels[this.reminder.type] || '其他';
  }

  private getPriorityColor(): string {
    switch (this.reminder.priority) {
      case 'HIGH':
        return '#FF4D4F';
      case 'MEDIUM':
        return '#FAAD14';
      case 'LOW':
        return '#52C41A';
      default:
        return '#999999';
    }
  }

  private getPriorityLabel(): string {
    switch (this.reminder.priority) {
      case 'HIGH':
        return '高优先级';
      case 'MEDIUM':
        return '中优先级';
      case 'LOW':
        return '低优先级';
      default:
        return '';
    }
  }

  private formatScheduledTime(time: string): string {
    const date = new Date(time);
    
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const scheduledDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());

    let datePrefix = '';

    if (scheduledDate.getTime() === today.getTime()) {
      datePrefix = '今天';
    } else if (scheduledDate.getTime() === today.getTime() + 24 * 60 * 60 * 1000) {
      datePrefix = '明天';
    } else if (scheduledDate.getTime() === today.getTime() - 24 * 60 * 60 * 1000) {
      datePrefix = '昨天';
    } else {
      datePrefix = `${date.getMonth() + 1}月${date.getDate()}日`;
    }

    const timeStr = `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;

    return `${datePrefix} ${timeStr}`;
  }

  private getTimeUntilScheduled(): { text: string; isUrgent: boolean; isOverdue: boolean } {
    const now = new Date();
    const scheduled = new Date(this.reminder.scheduledTime);
    const diffMs = scheduled.getTime() - now.getTime();

    if (diffMs < 0) {
      const overdueMinutes = Math.floor(Math.abs(diffMs) / (1000 * 60));
      
      if (overdueMinutes < 60) {
        return { text: `已过期${overdueMinutes}分钟`, isUrgent: true, isOverdue: true };
      } else {
        const hours = Math.floor(overdueMinutes / 60);
        return { text: `已过期${hours}小时`, isUrgent: true, isOverdue: true };
      }
    } else if (diffMs < 30 * 60 * 1000) {
      const minutes = Math.floor(diffMs / (1000 * 60));
      return { text: `${minutes}分钟后`, isUrgent: false, isOverdue: false };
    } else if (diffMs < 60 * 60 * 1000) {
      const minutes = Math.floor(diffMs / (1000 * 60));
      return { text: `${minutes}分钟内`, isUrgent: false, isOverdue: false };
    } else {
      const hours = Math.floor(diffMs / (1000 * 60 * 60));
      return { text: `${hours}小时后`, isUrgent: false, isOverdue: false };
    }
  }

  build() {
    Row({ space: 12 }) {
      Column({ space: 6 }) {
        Text(this.getTypeIcon())
          .fontSize(28)
        
        Text(this.getTypeLabel())
          .fontSize(10)
          .fontColor(this.getTypeColor())
          .fontWeight(FontWeight.Medium)
          .padding({ horizontal: 5, vertical: 2 })
          .backgroundColor(this.getTypeColor() + '15')
          .borderRadius(8)
      }
      .alignItems(HorizontalAlign.Center)

      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(this.reminder.title)
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (!this.reminder.isActive) {
            Text('已禁用')
              .fontSize(11)
              .fontColor('#999999')
              .backgroundColor('#F5F5F5')
              .padding({ horizontal: 6, vertical: 3 })
              .borderRadius(8)
          }
        }
        .width('100%')

        Text(this.reminder.description)
          .fontSize(13)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row({ space: 10 }) {
          Row({ space: 4 }) {
            Text('⏰')
              .fontSize(14)

            Text(this.formatScheduledTime(this.reminder.scheduledTime))
              .fontSize(13)
              .fontColor('#1677FF')
              .fontWeight(FontWeight.Medium)
          }

          const timeInfo = this.getTimeUntilScheduled();
          
          Text(timeInfo.text)
            .fontSize(12)
            .fontColor(
              timeInfo.isOverdue ? '#FF4D4F' :
              timeInfo.isUrgent ? '#FAAD14' : '#999999'
            )
            .fontWeight(timeInfo.isOverdue ? FontWeight.Bold : FontWeight.Normal)

          Text(`[${this.getPriorityLabel()}]`)
            .fontSize(11)
            .fontColor(this.getPriorityColor())
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        if (this.showActions && !this.reminder.isCompleted) {
          Row({ space: 8 }) {
            Button('完成')
              .height(32)
              .fontSize(13)
              .fontColor('#FFFFFF')
              .backgroundColor('#52C41A')
              .borderRadius(16)
              .onClick(() => {
                if (this.onComplete) {
                  this.onComplete(this.reminder.id);
                }
              })

            Button('延迟5分钟')
              .height(32)
              .fontSize(13)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .borderRadius(16)
              .onClick(() => {
                if (this.onSnooze) {
                  this.onSnooze(this.reminder.id, 5);
                }
              })

            Button('延迟30分钟')
              .height(32)
              .fontSize(13)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .borderRadius(16)
              .onClick(() => {
                if (this.onSnooze) {
                  this.onSnooze(this.reminder.id, 30);
                }
              })
          }
          .width('100%')
          .margin({ top: 4 })
        }

        if (this.reminder.isCompleted) {
          Row({ space: 6 }) {
            Text('✅')
              .fontSize(16)

            Text('已完成')
              .fontSize(13)
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Medium)

            if (this.reminder.completedAt) {
              Text(`${new Date(this.reminder.completedAt).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })}`)
                .fontSize(12)
                .fontColor('#999999')
            }
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .padding({ right: 4 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(
      this.reminder.isCompleted ? '#F6FFED' :
      !this.reminder.isActive ? '#F5F5F5' : 
      this.getTimeUntilScheduled().isOverdue ? '#FFF2F0' : '#FFFFFF'
    )
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: this.getTimeUntilScheduled().isOverdue ? 
             'rgba(255,77,79,0.08)' : 'rgba(0,0,0,0.04)',
      offsetX: 0,
      offsetY: 2
    })
    .border({
      width: this.reminder.isCompleted ? 1 : 0,
      color: '#52C41A40',
      style: BorderStyle.Solid
    })
  }
}
