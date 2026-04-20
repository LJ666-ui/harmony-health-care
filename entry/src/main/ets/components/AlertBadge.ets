import { Alert } from '../monitoring/AnomalyDetector';

@Component
export struct AlertBadge {
  @Prop alert: Alert;
  @Prop showDetails: boolean = false;
  @Prop onClick?: (alert: Alert) => void;

  private getSeverityColor(): string {
    switch (this.alert.severity) {
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

  private getSeverityBgColor(): string {
    switch (this.alert.severity) {
      case 'CRITICAL':
        return '#FFF1F0';
      case 'DANGER':
        return '#FFF2F0';
      case 'WARNING':
        return '#FFFBE6';
      case 'INFO':
        return '#E6F4FF';
      default:
        return '#F5F5F5';
    }
  }

  private getSeverityIcon(): string {
    switch (this.alert.severity) {
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

  private getSeverityLabel(): string {
    switch (this.alert.severity) {
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

  private formatTime(timestamp: string): string {
    const date = new Date(timestamp);
    const now = new Date();
    
    const diffMs = now.getTime() - date.getTime();
    const diffMinutes = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));

    if (diffMinutes < 1) {
      return '刚刚';
    } else if (diffMinutes < 60) {
      return `${diffMinutes}分钟前`;
    } else if (diffHours < 24) {
      return `${diffHours}小时前`;
    } else {
      return `${date.getMonth() + 1}/${date.getDate()} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`;
    }
  }

  build() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Text(this.getSeverityIcon())
          .fontSize(20)

        Column({ space: 3 }) {
          Row({ space: 6 }) {
            Text(this.alert.title)
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.getSeverityLabel())
              .fontSize(11)
              .fontColor(this.getSeverityColor())
              .fontWeight(FontWeight.Bold)
              .padding({ horizontal: 5, vertical: 2 })
              .backgroundColor(this.getSeverityBgColor())
              .borderRadius(8)

            Blank()

            Text(this.formatTime(this.alert.timestamp))
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')

          if (!this.alert.isRead && !this.alert.isHandled) {
            Row({ space: 4 }) {
              Text('●')
                .fontSize(8)
                .fontColor('#FF4D4F')

              Text('未读')
                .fontSize(11)
                .fontColor('#FF4D4F')
            }
          }

          if (this.showDetails) {
            Text(this.alert.message.substring(0, 150) + (this.alert.message.length > 150 ? '...' : ''))
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(18)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      if (!this.alert.isHandled) {
        Row({ space: 8 }) {
          Button('查看详情')
            .layoutWeight(1)
            .height(32)
            .fontSize(13)
            .fontColor('#1677FF')
            .backgroundColor('#E6F4FF')
            .borderRadius(16)
            .onClick(() => this.handleClick())

          Button('标记已处理')
            .layoutWeight(1)
            .height(32)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('#52C41A')
            .borderRadius(16)
            .onClick(() => this.handleMarkAsHandled())
        }
        .width('100%')
      } else {
        if (this.alert.handlingNotes) {
          Text(`处理备注：${this.alert.handlingNotes}`)
            .fontSize(12)
            .fontColor('#52C41A')
            .backgroundColor('#F6FFED'
            .padding(8)
            .borderRadius(6)
            .width('100%')
        }
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(
      this.alert.isRead ? '#FAFAFA' : 
      this.alert.severity === 'CRITICAL' || this.alert.severity === 'DANGER' ? '#FFF2F0' :
      this.alert.severity === 'WARNING' ? '#FFFBE6' : '#FFFFFF'
    )
    .borderRadius(12)
    .border({
      width: 1,
      color: !this.alert.isRead ? this.getSeverityColor() + '40' : 'transparent',
      style: BorderStyle.Solid
    })
    .shadow({
      radius: 4,
      color: this.alert.severity === 'CRITICAL' || this.alert.severity === 'DANGER' ? 
             `rgba(255,77,79,${!this.alert.isRead ? '0.15' : '0.05'})` : 'rgba(0,0,0,0.04)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.handleClick())
  }

  private handleClick(): void {
    if (this.onClick) {
      this.onClick(this.alert);
    }
  }

  private handleMarkAsHandled(): void {
    console.log(`[AlertBadge] 标记预警已处理: ${this.alert.alertId}`);
  }
}
