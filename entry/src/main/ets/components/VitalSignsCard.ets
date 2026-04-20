import { TrendMiniChart } from './TrendMiniChart';

@Component
export struct VitalSignsCard {
  @Prop type: 'blood_pressure' | 'blood_sugar' | 'heart_rate' | 'weight' | 'temperature' = 'blood_pressure';
  @Prop value: string = '--';
  @Prop unit: string = '';
  @Prop status: 'normal' | 'warning' | 'danger' = 'normal';
  @Prop trend?: 'up' | 'down' | 'stable' = 'stable';
  @Prop trendData?: number[] = [];
  @Prop lastUpdateTime: string = '';
  @Prop onClick?: () => void;

  private getIcon(): string {
    const icons: Record<string, string> = {
      'blood_pressure': '🩸',
      'blood_sugar': '🍬',
      'heart_rate': '❤️',
      'weight': '⚖️',
      'temperature': '🌡️'
    };
    return icons[this.type] || '📊';
  }

  private getTitle(): string {
    const titles: Record<string, string> = {
      'blood_pressure': '血压',
      'blood_sugar': '血糖',
      'heart_rate': '心率',
      'weight': '体重',
      'temperature': '体温'
    };
    return titles[this.type] || '未知';
  }

  private getStatusColor(): string {
    switch (this.status) {
      case 'normal':
        return '#F6FFED';
      case 'warning':
        return '#FFFBE6';
      case 'danger':
        return '#FFF2F0';
      default:
        return '#FFFFFF';
    }
  }

  private getStatusTextColor(): string {
    switch (this.status) {
      case 'normal':
        return '#52C41A';
      case 'warning':
        return '#FAAD14';
      case 'danger':
        return '#FF4D4F';
      default:
        return '#999999';
    }
  }

  private getStatusLabel(): string {
    switch (this.status) {
      case 'normal':
        return '正常 ✅';
      case 'warning':
        return '偏高 ⚠️';
      case 'danger':
        return '危险 ⛔';
      default:
        return '';
    }
  }

  private getTrendIcon(): string {
    switch (this.trend) {
      case 'up':
        return '↑';
      case 'down':
        return '↓';
      case 'stable':
        return '→';
      default:
        return '';
    }
  }

  private getTrendColor(): string {
    switch (this.trend) {
      case 'up':
        return this.type === 'weight' || this.type === 'heart_rate' ? '#FF4D4F' : 
               this.type === 'blood_pressure' ? '#FF4D4F' : '#52C41A';
      case 'down':
        return this.type === 'weight' || this.type === 'heart_rate' ? '#52C41A' :
               this.type === 'blood_pressure' ? '#52C41A' : '#FF4D4F';
      default:
        return '#999999';
    }
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text(this.getIcon())
          .fontSize(28)
        
        Column({ space: 2 }) {
          Text(this.getTitle())
            .fontSize(15)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)

          if (this.lastUpdateTime) {
            Text(`更新于 ${this.lastUpdateTime}`)
              .fontSize(11)
              .fontColor('#BBBBBB')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.trend && this.trend !== 'stable') {
          Text(this.getTrendIcon())
            .fontSize(20)
            .fontColor(this.getTrendColor())
        }
      }
      .width('100%')

      Column({ space: 6 }) {
        Text(this.value)
          .fontSize(this.type === 'blood_pressure' ? 32 : 36)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
        
        if (this.unit) {
          Text(this.unit)
            .fontSize(14)
            .fontColor('#999999')
        }

        Row({ space: 6 }) {
          Text(this.getStatusLabel())
            .fontSize(13)
            .fontColor(this.getStatusTextColor())
            .fontWeight(FontWeight.Medium)
            .padding({ horizontal: 8, vertical: 3 })
            .backgroundColor(
              this.status === 'normal' ? '#F6FFED30' :
              this.status === 'warning' ? '#FFFBE630' : '#FFF2F030'
            )
            .borderRadius(10)
        }
      }
      .width('100%')
      .margin({ top: 12 })

      if (this.trendData && this.trendData.length > 1) {
        TrendMiniChart({
          data: this.trendData,
          height: 50,
          color: this.getStatusTextColor(),
          showPoints: false
        })
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.getStatusColor())
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      if (this.onClick) {
        this.onClick();
      }
    })
  }
}
