import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

export interface ScienceArticle {
  id: string;
  title: string;
  coverIcon: string;
  coverImage: string;
  summary: string;
  publishTime: string;
  category: string;
  categoryName: string;
  readCount: string;
}

@Entry
@Component
struct MyCollectPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State collectedArticles: ScienceArticle[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadMyCollects();
  }

  async loadMyCollects(): Promise<void> {
    this.isLoading = true;
    try {
      const response: BaseResponse<Object[]> = await HttpUtil.get<Object[]>(ApiConstants.ARTICLE_MY_COLLECTS);
      if (response.success && response.data && Array.isArray(response.data)) {
        const articles: ScienceArticle[] = [];
        for (let i = 0; i < response.data.length; i++) {
          const item = response.data[i] as Record<string, Object>;
          articles.push({
            id: String(item['articleId'] || item['id'] || ''),
            title: item['title'] as string || '',
            coverIcon: this.getCategoryIcon(item['categoryName'] as string || ''),
            coverImage: (item['coverImage'] || '') as string,
            summary: (item['summary'] || item['content'] || '') as string,
            publishTime: this.formatDate(item['collectTime'] || item['createTime']),
            category: (item['categoryName'] || '') as string,
            categoryName: (item['categoryName'] || '') as string,
            readCount: String(item['viewCount'] || '0')
          });
        }
        this.collectedArticles = articles;
      }
    } catch (e) {
      console.error('加载我的收藏失败:', e);
    } finally {
      this.isLoading = false;
    }
  }

  getCategoryIcon(categoryName: string): string {
    const iconMap: Record<string, string> = {
      '中医养生': '🌿',
      '慢病管理': '🩺',
      '康复指导': '🏃',
      '运动健康': '💪',
      '老年健康': '👴'
    };
    return iconMap[categoryName] || '📄';
  }

  formatDate(dateValue: Object | undefined): string {
    if (!dateValue) return '';
    const dateStr = String(dateValue);
    if (dateStr.length >= 10) {
      return dateStr.substring(0, 10);
    }
    return dateStr;
  }

  async handleUncollect(articleId: string): Promise<void> {
    try {
      const url: string = ApiConstants.ARTICLE_UNCOLLECT + articleId + '/collect';
      const response: BaseResponse<Object> = await HttpUtil.delete<Object>(url);
      if (response.success) {
        let filtered: ScienceArticle[] = [];
        for (let i = 0; i < this.collectedArticles.length; i++) {
          if (this.collectedArticles[i].id !== articleId) {
            filtered.push(this.collectedArticles[i]);
          }
        }
        this.collectedArticles = filtered;
        ToastUtil.showSuccess('取消收藏成功');
      } else {
        let filtered: ScienceArticle[] = [];
        for (let i = 0; i < this.collectedArticles.length; i++) {
          if (this.collectedArticles[i].id !== articleId) {
            filtered.push(this.collectedArticles[i]);
          }
        }
        this.collectedArticles = filtered;
        ToastUtil.showSuccess('已同步收藏状态');
      }
    } catch (e) {
      console.error('取消收藏失败:', e);
      ToastUtil.showSuccess('操作失败，请重试');
    }
  }

  build() {
    Column() {
      Row() {
        Text('\u2190')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor('#1677FF')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('#E6F4FF')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })
        Text('我的收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('').width(40)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column() {
          if (this.isLoading) {
            Column() {
              Text('加载中...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#999999');
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else if (this.collectedArticles.length === 0) {
            Column() {
              Text('\u2764\ufe0f')
                .fontSize(48)
                .margin({ bottom: 16 });
              Text('暂无收藏')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#999999');
              Text('浏览文章时点击收藏按钮添加')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor('#BBBBBB')
                .margin({ top: 8 });
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else {
            ForEach(this.collectedArticles, (article: ScienceArticle) => {
              Row() {
                Column() {
                  if (article.coverImage && article.coverImage.indexOf('http') === 0) {
                    Image(article.coverImage)
                      .width(64)
                      .height(64)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(12);
                  } else {
                    Text(article.coverIcon).fontSize(36);
                  }
                }
                .width(64)
                .height(64)
                .backgroundColor('#F0F5FF')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text(article.title)
                    .fontSize(this.isElderMode ? 20 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .maxLines(2)

                  Text(article.summary)
                    .fontSize(this.isElderMode ? 16 : 13)
                    .fontColor('#999999')
                    .maxLines(2)
                    .margin({ top: 6 })

                  Row() {
                    if (article.categoryName) {
                      Text(article.categoryName)
                        .fontSize(11)
                        .fontColor('#1677FF')
                        .backgroundColor('#E6F4FF')
                        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                        .borderRadius(4);
                    }

                    Text('\ud83d\udc41 ' + article.readCount)
                      .fontSize(11)
                      .fontColor('#999999')
                      .margin({ left: 12 })

                    Text(article.publishTime)
                      .fontSize(11)
                      .fontColor('#BBBBBB')

                    Button('取消收藏')
                      .fontSize(11)
                      .fontColor('#FF4757')
                      .backgroundColor('transparent')
                      .border({ width: 1, color: '#FF4757' })
                      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                      .borderRadius(4)
                      .margin({ left: 'auto' })
                      .onClick(() => this.handleUncollect(article.id));
                  }
                  .width('100%')
                  .margin({ top: 8 });
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 });
              }
              .width('90%')
              .margin({ bottom: 10, left: '5%', right: '5%' })
              .padding(14)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/ScienceDetailPage',
                  params: { articleId: article.id }
                });
              });
            }, (article: ScienceArticle) => article.id);
          }
        }
        .width('100%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
