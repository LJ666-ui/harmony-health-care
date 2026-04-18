import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { ToastUtil } from '../common/utils/ToastUtil';
import { GlobalTheme } from '../global';
import BrowseTracker from '../utils/BrowseTracker';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { CategoryTabs } from '../components/CategoryTabs';

export interface ArticleCategory {
  id: number;
  categoryName: string;
  categoryCode: string;
}

export interface ArticleItem {
  id: number;
  title: string;
  content: string;
  coverImage: string;
  publishTime: string;
  categoryId: number;
  author: string;
  viewCount: number;
}

interface PageResultData<T> {
  records: T[];
  total: number;
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

@Entry
@Component
struct ScienceListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State articles: ScienceArticle[] = [];
  @State categories: ArticleCategory[] = [];
  @State categoryNames: string[] = ['全部'];
  @State currentCategoryIndex: number = 0;
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = false;
  @State searchKeyword: string = '';
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State hasMore: boolean = true;
  @State isSearching: boolean = false;

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    BrowseTracker.recordStart('SCIENCE_LIST', 'PAGE', 2, '健康科普列表').then(id => {
      this.recordId = id;
    });

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    this.loadCategories();
    this.loadArticles();
  }

  aboutToDisappear(): void {
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async loadCategories(): Promise<void> {
    try {
      const response: BaseResponse<ArticleCategory[]> = await HttpUtil.get<ArticleCategory[]>(ApiConstants.ARTICLE_CATEGORIES_PARENT);
      if (response.success && response.data) {
        const mappedCategories: ArticleCategory[] = [];
        for (let i = 0; i < response.data.length; i++) {
          const item = response.data[i];
          const cat: ArticleCategory = {
            id: item.id,
            categoryName: item.categoryName ? item.categoryName : item.categoryCode,
            categoryCode: item.categoryCode
          };
          mappedCategories.push(cat);
        }
        this.categories = mappedCategories;

        const names: string[] = ['全部'];
        for (let j = 0; j < this.categories.length; j++) {
          names.push(this.categories[j].categoryName);
        }
        this.categoryNames = names;
      }
    } catch (e) {
      console.error('加载分类失败:', e);
    }
  }

  async loadArticles(isRefresh: boolean = false): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;

    if (isRefresh) {
      this.currentPage = 1;
      this.hasMore = true;
    }

    try {
      let url: string = ApiConstants.ARTICLE_PAGE + '?page=' + this.currentPage + '&size=' + this.pageSize;

      if (this.isSearching && this.searchKeyword.trim()) {
        url = url + '&title=' + encodeURIComponent(this.searchKeyword.trim());
      } else if (this.currentCategoryIndex > 0 && this.categories.length > 0) {
        const selectedCategory: ArticleCategory = this.categories[this.currentCategoryIndex - 1];
        url = url + '&parentCategoryName=' + encodeURIComponent(selectedCategory.categoryName);
      }

      const response: BaseResponse<PageResultData<ArticleItem>> = await HttpUtil.get<PageResultData<ArticleItem>>(url);

      if (response.success && response.data) {
        const data: PageResultData<ArticleItem> = response.data;
        const list: ArticleItem[] = data.records || [];

        const mappedArticles: ScienceArticle[] = [];
        for (let k = 0; k < list.length; k++) {
          const item: ArticleItem = list[k];
          const article: ScienceArticle = {
            id: item.id,
            title: item.title ? item.title : '',
            coverImage: item.coverImage ? item.coverImage : '',
            summary: this.extractSummary(item.content),
            publishTime: this.formatDate(item.publishTime),
            category: this.getCategoryName(item.categoryId),
            readCount: item.viewCount ? item.viewCount : 0,
            author: item.author ? item.author : '健康专家',
            categoryId: item.categoryId
          };
          mappedArticles.push(article);
        }

        if (isRefresh) {
          this.articles = mappedArticles;
        } else {
          this.articles = this.articles.concat(mappedArticles);
        }

        const total: number = data.total ? data.total : 0;
        this.hasMore = this.articles.length < total;
      }
    } catch (e) {
      console.error('加载文章失败:', e);
      ToastUtil.showSuccess('加载失败，请重试');
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  extractSummary(content: string): string {
    if (!content) return '暂无摘要...';
    const plainText: string = content.replace(/[#*\[\]()]/g, '').replace(/\n/g, ' ').trim();
    return plainText.length > 80 ? plainText.substring(0, 80) + '...' : plainText;
  }

  formatDate(dateStr: string | Date): string {
    if (!dateStr) return '';
    const date: Date = new Date(dateStr);
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    return year + '-' + month + '-' + day;
  }

  getCategoryName(categoryId: number): string {
    for (let i = 0; i < this.categories.length; i++) {
      const cat: ArticleCategory = this.categories[i];
      if (cat.id === categoryId) {
        return cat.categoryName;
      }
    }
    return '健康科普';
  }

  handleRefresh(): void {
    this.isRefreshing = true;
    this.loadArticles(true).then(() => {
      ToastUtil.refreshSuccess();
    });
  }

  handleSearch(): void {
    if (!this.searchKeyword.trim()) {
      this.isSearching = false;
      this.loadArticles(true);
      return;
    }

    this.isSearching = true;
    this.currentPage = 1;
    this.hasMore = true;
    this.articles = [];
    this.loadArticles();
  }

  handleClearSearch(): void {
    this.searchKeyword = '';
    this.isSearching = false;
    this.loadArticles(true);
  }

  onCategoryChange(index: number, category: string): void {
    this.currentCategoryIndex = index;
    this.isSearching = false;
    this.searchKeyword = '';
    this.loadArticles(true);
  }

  loadMore(): void {
    if (!this.hasMore || this.isLoading) return;
    this.currentPage++;
    this.loadArticles();
  }

  build() {
    Column() {
      Row() {
        Text('←')
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
        Text('健康科普')
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

      Column({ space: 10 }) {
        Row({ space: 10 }) {
          Column() {
            Row({ space: 6 }) {
              Text(this.isSearching ? '\u{1F50D}' : '\u{1F50E}')
                .fontSize(16)
              TextInput({ text: this.searchKeyword, placeholder: '搜索健康知识...' })
                .layoutWeight(1)
                .height(36)
                .fontSize(this.isElderMode ? 16 : 14)
                .backgroundColor('transparent')
                .border({ width: 0 })
                .onChange((value: string) => {
                  this.searchKeyword = value;
                })
                .onSubmit(() => {
                  this.handleSearch();
                })
              if (this.searchKeyword) {
                Text('\u2715')
                  .fontSize(14)
                  .fontColor('#999999')
                  .padding(6)
                  .onClick(() => {
                    this.handleClearSearch();
                  })
              }
            }
            .width('100%')
            .padding({ left: 12, right: 8 })
          }
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F7FA')
          .borderRadius(20)

          Button('搜索')
            .height(36)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(18)
            .onClick(() => {
              this.handleSearch();
            });
        }
        .width('100%')
        .padding({ left: 14, right: 14 })

        CategoryTabs({
          categories: this.categoryNames,
          currentIndex: this.currentCategoryIndex,
          onTabChange: (index: number, category: string) => {
            this.onCategoryChange(index, category);
          }
        });
      }
      .width('100%')
      .backgroundColor('#F5F7FA')

      Scroll() {
        Column() {
          if (this.isLoading && this.articles.length === 0) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#1677FF');
              Text('正在加载...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 });
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center);
          } else if (this.articles.length === 0) {
            Column() {
              Text('\u{1F4ED}')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text(this.isSearching ? '未找到相关文章' : '暂无文章内容')
                .fontSize(15)
                .fontColor('#999999');
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center);
          } else {
            List() {
              ForEach(this.articles, (article: ScienceArticle, index: number) => {
                ListItem() {
                  Row() {
                    if (article.coverImage.length > 0 && article.coverImage.indexOf('http') === 0) {
                      Image(article.coverImage)
                        .width(64)
                        .height(64)
                        .objectFit(ImageFit.Cover)
                        .borderRadius(12)
                        .alt('\u{1F4F0}')
                    } else {
                      Column() {
                        Text('\u{1F4F0}').fontSize(28)
                      }
                      .width(64)
                      .height(64)
                      .backgroundColor('#F0F5FF')
                      .borderRadius(12)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Center)
                    }

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
                        Text(article.category)
                          .fontSize(11)
                          .fontColor('#1677FF')
                          .backgroundColor('#E6F4FF')
                          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                          .borderRadius(4)

                        Text('\u{1F441} ' + (article.readCount >= 1000 ? (article.readCount / 1000).toFixed(1) + 'k' : article.readCount.toString()))
                          .fontSize(11)
                          .fontColor('#999999')
                          .margin({ left: 12 })

                        Text(article.publishTime)
                          .fontSize(11)
                          .fontColor('#BBBBBB')
                      }
                      .width('100%')
                      .margin({ top: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                  }
                }
                .width('100%')
                .margin({ bottom: 10 })
                .padding(14)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .border({ width: 1, color: '#F0F0F0' })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ScienceDetailPage',
                    params: { articleId: article.id.toString(), articleTitle: article.title }
                  });
                });
              }, (article: ScienceArticle) => article.id.toString() + '_' + article.title);

              if (this.hasMore && this.articles.length > 0) {
                ListItem() {
                  Row() {
                    if (this.isLoading) {
                      LoadingProgress()
                        .width(20)
                        .height(20)
                        .color('#1677FF');
                      Text('加载中...')
                        .fontSize(13)
                        .fontColor('#666666')
                        .margin({ left: 8 });
                    } else {
                      Text('- 上拉加载更多 -')
                        .fontSize(13)
                        .fontColor('#999999')
                        .onClick(() => {
                          this.loadMore();
                        });
                    }
                  }
                  .width('100%')
                  .height(50)
                  .justifyContent(FlexAlign.Center);
                }
              }
            }
            .width('100%')
            .height(0)
            .layoutWeight(1)
            .onReachEnd(() => {
              this.loadMore();
            });
          }
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}