import { router } from '@kit.ArkUI';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

export interface ArticleCardData {
  id: number;
  title: string;
  coverImage?: string;
  summary?: string;
  publishTime: string;
  category: string;
  readCount: number;
  author: string;
}

@Component
export struct ArticleListCard {
  @Prop article: ArticleCardData;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Row({ space: 12 }) {
      if (this.article.coverImage && this.article.coverImage.indexOf('http') === 0) {
        Image(this.article.coverImage)
          .width(100)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
      } else {
        Column()
          .width(100)
          .height(80)
          .backgroundColor('#F0F5FF')
          .borderRadius(8)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center) {
          Text('📰')
            .fontSize(32)
        }
      }

      Column({ space: 6 }) {
        Text(this.article.title)
          .fontSize(this.isElderMode ? 16 : 14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row({ space: 12 }) {
          Text('阅读' + this.formatCount(this.article.readCount))
            .fontSize(this.isElderMode ? 12 : 11)
            .fontColor('#999999')

          Text(this.article.author)
            .fontSize(this.isElderMode ? 12 : 11)
            .fontColor('#999999')

          Text(this.article.publishTime)
            .fontSize(this.isElderMode ? 12 : 11)
            .fontColor('#999999')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
    .onClick(() => {
      try {
        router.pushUrl({
          url: 'pages/ScienceDetailPage',
          params: { articleId: this.article.id.toString(), articleTitle: this.article.title }
        });
      } catch (error) {
        console.error('导航失败:', error);
      }
    })
  }

  private formatCount(count: number): string {
    if (count >= 10000) {
      return (count / 10000).toFixed(1) + 'w';
    } else if (count >= 1000) {
      return (count / 1000).toFixed(1) + 'k';
    }
    return count.toString();
  }
}
