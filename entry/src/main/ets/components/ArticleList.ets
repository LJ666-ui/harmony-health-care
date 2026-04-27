import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { router } from '@kit.ArkUI';

@Component
export struct ArticleList {
  @State articles: ScienceArticle[] = [];
  @State isLoading: boolean = false;
  @State hasMore: boolean = true;
  onLoadMore: () => void = () => {};
  @StorageLink('isOldModeEnabled') isOldModeEnabled: boolean = false;
  @State pageNo: number = 1;
  @State pageSize: number = 20;
  @State total: number = 0;

  build() {
    Column() {
      List({ space: 16 }) {
        ForEach(this.articles, (item: ScienceArticle) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.title)
                  .fontSize(this.isOldModeEnabled ? 20 : 16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .lineHeight(this.isOldModeEnabled ? 28 : 22)
                  .width('100%');

                Text(item.summary)
                  .fontSize(this.isOldModeEnabled ? 16 : 13)
                  .fontColor('#999999')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .lineHeight(this.isOldModeEnabled ? 24 : 20)
                  .margin({ top: 4 })
                  .width('100%');

                Row({ space: 4 }) {
                  Text(item.category)
                    .fontSize(10)
                    .fontColor('#1677FF')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#F0F5FF')
                    .borderRadius(4);

                  Text(item.publishTime)
                    .fontSize(10)
                    .fontColor('#999999');

                  Text(item.author)
                    .fontSize(10)
                    .fontColor('#999999');

                  Text(item.readCount >= 1000 ? (item.readCount / 1000).toFixed(1) + 'k' : item.readCount.toString())
                    .fontSize(10)
                    .fontColor('#999999');
                }
                .margin({ top: 8 });
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ right: 8 });

              Image(item.coverImage)
                .width(64)
                .height(64)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .backgroundColor('#F5F5FA');
            }
            .width('90%')
            .padding(12)
            .borderRadius(12)
            .borderWidth(1)
            .borderColor('#F0F0F0')
            .alignItems(VerticalAlign.Top)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/ScienceDetailPage',
                params: {
                  articleId: item.id,
                  articleTitle: item.title
                }
              });
            });
          }
        }, (item: ScienceArticle) => item.id.toString());

        if (this.isLoading) {
          ListItem() {
            Row() {
              LoadingProgress()
                .width(24)
                .height(24)
                .color('#1677FF');

              Text('加载中...')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 8 });
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(12);
          }
        }

        if (!this.hasMore && this.articles.length > 0) {
          ListItem() {
            Row() {
              Text('没有更多数据了')
                .fontSize(12)
                .fontColor('#999999');
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(12);
          }
        }

        if (!this.isLoading && this.articles.length === 0) {
          ListItem() {
            Row() {
              Column() {
                Text('暂无数据')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 8 });
              }
              .justifyContent(FlexAlign.Center);
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center);
          }
        }
      }
      .width('100%')
      .height('100%')
      .alignListItem(ListItemAlign.Center)
      .onReachEnd(() => {
        if (this.hasMore && !this.isLoading) {
          this.onLoadMore();
        }
      });
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}

export interface ScienceArticle {
  id: number;
  title: string;
  coverImage: string;
  summary: string;
  publishTime: string;
  category: string;
  readCount: number;
  author: string;
  categoryId: number;
}
