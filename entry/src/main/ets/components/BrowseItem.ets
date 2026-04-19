import { BrowseHistoryItem } from '../models/LocalModels';

@Component
export struct BrowseItem {
  @Prop record: BrowseHistoryItem = {
    browse_type: '',
    target_id: 0,
    target_title: '',
    browse_duration: 0,
    source_page: '',
    create_time: 0
  } as BrowseHistoryItem;
  onItemClick?: (record: BrowseHistoryItem) => void;

  private getTypeIcon(type: string): string {
    const iconMap: Record<string, string> = {
      'ARTICLE': '\uD83D\uDCDD',
      'HERBAL': '\uD83C\uDF3F',
      'HOSPITAL': '\uD83C\uDFE5',
      'AI_CHAT': '\uD83E\uDDE0',
      'FOOD': '\uD83C\uDF73',
      'KNOWLEDGE': '\uD83D\uDCCA',
      'REHAB': '\uD83C\uDFCB',
      'PAGE': '\uD83D\uDCCC',
      'VOICE_ASSISTANT': '\uD83C\uDFA4',
      'ANCIENT_IMAGE': '\uD83D\uDCDC',
      'HOME': '\uD83C\uDFE0'
    };
    return iconMap[type] || '\uD83D\uDCCB';
  }

  private getTypeColor(type: string): string {
    const colorMap: Record<string, string> = {
      'ARTICLE': '#3498db',
      'HERBAL': '#27ae60',
      'HOSPITAL': '#e67e22',
      'AI_CHAT': '#9b59b6',
      'FOOD': '#f1c40f',
      'KNOWLEDGE': '#1abc9c',
      'REHAB': '#e74c3c',
      'PAGE': '#34495e',
      'VOICE_ASSISTANT': '#16a085',
      'ANCIENT_IMAGE': '#722ed1',
      'HOME': '#95a5a6'
    };
    return colorMap[type] || '#95a5a6';
  }

  private formatDuration(ms: number): string {
    if (!ms || ms <= 0) return '0秒';
    const seconds: number = Math.floor(ms / 1000);
    if (seconds < 60) return seconds + '秒';
    const minutes: number = Math.floor(seconds / 60);
    if (minutes < 60) return minutes + '分' + (seconds % 60) + '秒';
    const hours: number = Math.floor(minutes / 60);
    return hours + '小时' + (minutes % 60) + '分';
  }

  private formatTime(timestamp: number): string {
    if (!timestamp) return '--:--';
    const date = new Date(timestamp);
    return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
  }

  build() {
    Column() {
      Row({ space: 16 }) {
        Column()
          .width(40)
          .height(40)
          .backgroundColor(this.getTypeColor(this.record.browse_type) + '15')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center);

        Text(this.getTypeIcon(this.record.browse_type))
          .fontSize(18);

        Column({ space: 4 }) {
          Text(this.record.target_title || '未知')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });

          Row({ space: 6 }) {
            Text(this.formatTime(this.record.create_time || 0))
              .fontSize(12)
              .fontColor('#999999');

            Text('\u00B7')
              .fontSize(12)
              .fontColor('#CCCCCC');

            Text(this.formatDuration(this.record.browse_duration || 0))
              .fontSize(12)
              .fontColor('#999999');
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .padding(14);
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .shadow({ radius: 2, color: '#00000008' })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.record);
      }
    });
  }
}
