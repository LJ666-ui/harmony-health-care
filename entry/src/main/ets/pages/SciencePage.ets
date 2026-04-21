import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import BrowseTracker from '../utils/BrowseTracker';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { SettingsUtil, NotificationFrequency, SubscriptionInfo } from '../utils/SettingsUtil';

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
struct SciencePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State articles: ScienceArticle[] = [];
  @State hotArticles: ScienceArticle[] = [];
  @State categories: ArticleCategory[] = [];
  @State categoryNames: string[] = ['全部'];
  @State selectedCategoryIndex: number = 0;
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = true;
  @State searchText: string = '';
  @State searchHistory: string[] = ['高血压', '糖尿病', '颈椎病', '跌倒预防'];
  @State showSearchHistory: boolean = false;
  @State searchResults: ScienceArticle[] = [];
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State hasMore: boolean = true;
  @State currentBannerIndex: number = 0;
  @State subscribedCategories: Map<number, boolean> = new Map();
  @State notificationFreq: NotificationFrequency = 'immediate';
  @State showSubscriptionPanel: boolean = false;
  @State settingsUtil: SettingsUtil = SettingsUtil.getInstance();

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    BrowseTracker.recordStart('SCIENCE_HOME', 'PAGE', 2, '健康科普首页').then(id => {
      this.recordId = id;
    });

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    this.loadAllData();

    try {
      setInterval(() => {
        if (this.hotArticles.length > 0) {
          this.currentBannerIndex = (this.currentBannerIndex + 1) % Math.min(this.hotArticles.length, 5);
        }
      }, 3000);
    } catch (e) {
      console.error('轮播定时器设置失败', e);
    }
  }

  aboutToDisappear(): void {
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async loadAllData(): Promise<void> {
    this.isLoading = true;
    try {
      await Promise.all([
        this.loadCategories(),
        this.loadHotArticles(),
        this.loadArticles(),
        this.loadSubscriptionStatus()
      ]);
    } catch (e) {
      console.error('加载数据失败:', e);
    } finally {
      this.isLoading = false;
    }
  }

  async loadSubscriptionStatus(): Promise<void> {
    try {
      const freq: NotificationFrequency = await this.settingsUtil.getNotificationFrequency();
      this.notificationFreq = freq;

      if (this.categories.length > 0) {
        for (let i = 0; i < this.categories.length; i++) {
          const cat: ArticleCategory = this.categories[i];
          const isSub: boolean = await this.settingsUtil.isSubscribed(cat.id);
          this.subscribedCategories.set(cat.id, isSub);
        }
      }
    } catch (e) {
      console.error('加载订阅状态失败:', e);
    }
  }

  async toggleSubscription(categoryId: number, categoryName: string): Promise<void> {
    try {
      const currentStatus: boolean | undefined = this.subscribedCategories.get(categoryId);
      const newStatus: boolean = !currentStatus;

      await this.settingsUtil.setSubscription(categoryId, newStatus);
      this.subscribedCategories.set(categoryId, newStatus);

      if (newStatus) {
        ToastUtil.showSuccess('已订阅「' + categoryName + '」分类');
        this.showNotificationToast('订阅成功', '您将收到【' + categoryName + '】分类的新文章通知');
      } else {
        ToastUtil.showInfo('已取消订阅「' + categoryName + '」');
      }
    } catch (e) {
      console.error('切换订阅状态失败:', e);
      ToastUtil.showError('操作失败，请重试');
    }
  }

  async changeNotificationFrequency(freq: NotificationFrequency): Promise<void> {
    try {
      await this.settingsUtil.setNotificationFrequency(freq);
      this.notificationFreq = freq;

      let freqText: string = '';
      switch (freq) {
        case 'immediate':
          freqText = '即时推送';
          break;
        case 'daily':
          freqText = '每日汇总';
          break;
        case 'weekly':
          freqText = '每周汇总';
          break;
      }
      ToastUtil.showSuccess('推送频率已设置为：' + freqText);
    } catch (e) {
      console.error('设置推送频率失败:', e);
      ToastUtil.showError('设置失败');
    }
  }

  showNotificationToast(title: string, content: string): void {
    ToastUtil.showSuccess(title + ': ' + content);
    console.info('通知提示:', title, content);
  }

  getFrequencyLabel(freq: NotificationFrequency): string {
    switch (freq) {
      case 'immediate':
        return '即时';
      case 'daily':
        return '每日';
      case 'weekly':
        return '每周';
      default:
        return '即时';
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

  async loadHotArticles(): Promise<void> {
    try {
      const params: Record<string, number> = {};
      params['pageSize'] = 5;
      const response: BaseResponse<ArticleItem[]> = await HttpUtil.get<ArticleItem[]>(ApiConstants.ARTICLE_LIST, params);

      if (response.success && response.data) {
        const list: ArticleItem[] = response.data;
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

        this.hotArticles = mappedArticles;
      }
    } catch (e) {
      console.error('加载热门文章失败:', e);
    }
  }

  async loadArticles(isRefresh: boolean = false): Promise<void> {
    if (isRefresh) {
      this.currentPage = 1;
      this.hasMore = true;
    }

    try {
      let url: string = ApiConstants.ARTICLE_PAGE + '?page=' + this.currentPage + '&size=' + this.pageSize;

      if (this.selectedCategoryIndex > 0 && this.categories.length > 0) {
        const selectedCategory: ArticleCategory = this.categories[this.selectedCategoryIndex - 1];
        url = url + '&parentCategoryName=' + encodeURIComponent(selectedCategory.categoryName);
      }

      if (this.searchText.trim()) {
        url = url + '&title=' + encodeURIComponent(this.searchText.trim());
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
    }
  }

  extractSummary(content: string): string {
    if (!content) return '暂无摘要...';
    let plainText: string = content;
    plainText = plainText.replace(/#/g, '');
    plainText = plainText.replace(/\*/g, '');
    plainText = plainText.replace(/\[/g, '');
    plainText = plainText.replace(/\]/g, '');
    plainText = plainText.replace(/\(/g, '');
    plainText = plainText.replace(/\)/g, '');
    while (plainText.indexOf('\n') >= 0) {
      plainText = plainText.replace('\n', ' ');
    }
    plainText = plainText.trim();
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
    this.loadAllData().then(() => {
      this.isRefreshing = false;
      ToastUtil.refreshSuccess();
    });
  }

  handleSearch(): void {
    if (!this.searchText.trim()) {
      this.searchResults = [];
      this.showSearchHistory = false;
      this.loadArticles(true);
      return;
    }

    this.showSearchHistory = false;
    this.currentPage = 1;
    this.hasMore = true;
    this.articles = [];
    this.loadArticles();
  }

  handleClearSearch(): void {
    this.searchText = '';
    this.searchResults = [];
    this.showSearchHistory = false;
    this.loadArticles(true);
  }

  addToSearchHistory(keyword: string): void {
    try {
      let newHistory: string[] = [];
      for (let i = 0; i < this.searchHistory.length; i++) {
        if (this.searchHistory[i] !== keyword) {
          newHistory.push(this.searchHistory[i]);
        }
      }
      newHistory.unshift(keyword);
      if (newHistory.length > 10) {
        newHistory = newHistory.slice(0, 10);
      }
      this.searchHistory = newHistory;
    } catch (e) {
      console.error('添加搜索历史失败', e);
    }
  }

  clearSearchHistory(): void {
    try {
      this.searchHistory = [];
    } catch (e) {
      console.error('清空搜索历史失败', e);
    }
  }

  selectSearchHistory(keyword: string): void {
    this.searchText = keyword;
    this.handleSearch();
  }

  onCategoryChange(index: number): void {
    this.selectedCategoryIndex = index;
    this.searchText = '';
    this.searchResults = [];
    this.loadArticles(true);
  }

  getDisplayedArticles(): ScienceArticle[] {
    if (this.searchText.trim()) {
      return this.articles;
    }
    return this.articles;
  }

  loadMore(): void {
    if (!this.hasMore || this.isLoading) return;
    this.currentPage++;
    this.loadArticles();
  }

  build(): void {
    Column() {
      Row() {
        Text('健康科普')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Start)

        Button('+ 写文章')
          .height(32)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .borderRadius(16)
          .onClick(() => {
            try {
              router.pushUrl({
                url: 'pages/AddArticlePage'
              });
            } catch (error) {
              console.error('跳转发表文章页面失败:', error);
              ToastUtil.showError('跳转失败');
            }
          });
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column() {
          Row() {
            Row() {
              Text('🔍')
                .fontSize(16)
                .margin({ left: 12 })
              TextInput({
                placeholder: '搜索健康知识...',
                text: this.searchText
              })
                .fontSize(this.isElderMode ? 16 : 14)
                .width('100%')
                .height(40)
                .padding({ left: 8, right: 12 })
                .backgroundColor('transparent')
                .onChange((value: string) => {
                  this.searchText = value;
                  this.showSearchHistory = true;
                })
                .onSubmit(() => {
                  this.handleSearch();
                  this.addToSearchHistory(this.searchText.trim());
                })
            }
            .width('90%')
            .height(48)
            .backgroundColor('#F5F7FA')
            .borderRadius(24)
            .alignItems(VerticalAlign.Center)

            Button('搜索')
              .height(36)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(18)
              .onClick(() => {
                this.handleSearch();
                if (this.searchText.trim()) {
                  this.addToSearchHistory(this.searchText.trim());
                }
              });
          }
          .width('100%')
          .padding({ top: 16, bottom: 8, left: 16, right: 16 })

          if (this.showSearchHistory && this.searchHistory.length > 0 && !this.searchText.trim()) {
            Column() {
              Row() {
                Text('搜索历史')
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Bold)
                Button('清空')
                  .fontSize(12)
                  .fontColor('#999999')
                  .backgroundColor('transparent')
                  .border({ width: 0 })
                  .onClick(() => this.clearSearchHistory());
              }
              .width('90%')
              .margin({ left: '5%', right: '5%' })
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                ForEach(this.searchHistory, (keyword: string) => {
                  Text(keyword)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#666666')
                    .backgroundColor('#F0F5FF')
                    .borderRadius(16)
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => this.selectSearchHistory(keyword));
                }, (keyword: string) => keyword);
              }
              .width('90%')
              .margin({ left: '5%', right: '5%', top: 8, bottom: 16 })
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: '5%', right: '5%' })
            .padding({ top: 16, bottom: 16 })
            .shadow({
              radius: 4,
              color: '#00000008',
              offsetX: 0,
              offsetY: 2
            });
          }

          Column() {
            Row() {
              Text('🕸️')
                .fontSize(32)
                .margin({ right: 16 });
              Column({ space: 6 }) {
                Text('知识图谱')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF');
                Text('探索疾病、症状、药材、方剂之间的关联关系')
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#666666')
                  .maxLines(2);
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start);

              Text('>')
                .fontSize(20)
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Bold);
            }
            .width('90%')
            .padding(20)
            .backgroundColor('#E6F4FF')
            .borderRadius(12)
            .margin({ top: 8, bottom: 16, left: '5%', right: '5%' })
            .border({ width: 2, color: '#1677FF33' })
            .onClick(() => {
              try {
                router.pushUrl({
                  url: 'pages/KnowledgeGraphPage'
                });
              } catch (error) {
                console.error('Failed to navigate to KnowledgeGraphPage:', error);
              }
            });
          }

          Scroll() {
            Row({
              space: 12
            }) {
              ForEach(this.categoryNames, (category: string, index: number) => {
                Text(category)
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor(this.selectedCategoryIndex === index ? '#1677FF' : '#666666')
                  .backgroundColor(this.selectedCategoryIndex === index ? '#E6F4FF' : '#F5F7FA')
                  .borderRadius(20)
                  .onClick(() => {
                    this.onCategoryChange(index);
                  });
              }, (category: string, index: number) => '' + category + '_' + index);
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 8 })
          }
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)

          Column() {
            Row() {
              Text('🔔 订阅管理')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .layoutWeight(1);

              Button('设置频率 (' + this.getFrequencyLabel(this.notificationFreq) + ')')
                .height(32)
                .fontSize(12)
                .fontColor('#1677FF')
                .backgroundColor('#E6F4FF')
                .borderRadius(16)
                .onClick(() => {
                  this.showSubscriptionPanel = !this.showSubscriptionPanel;
                });
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 8 });

            if (this.showSubscriptionPanel) {
              Column({ space: 10 }) {
                Text('选择推送频率：')
                  .fontSize(13)
                  .fontColor('#666666')
                  .width('100%')
                  .padding({ left: 16 });

                Row({ space: 12 }) {
                  ForEach(['immediate', 'daily', 'weekly'] as NotificationFrequency[], (freq: NotificationFrequency) => {
                    Text(freq === 'immediate' ? '即时推送' : freq === 'daily' ? '每日汇总' : '每周汇总')
                      .fontSize(13)
                      .fontColor(this.notificationFreq === freq ? '#FFFFFF' : '#666666')
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .backgroundColor(this.notificationFreq === freq ? '#1677FF' : '#F5F7FA')
                      .borderRadius(16)
                      .onClick(() => this.changeNotificationFrequency(freq));
                  }, (freq: NotificationFrequency) => freq);
                }
                .width('100%')
                .padding({ left: 16 });

                Scroll() {
                  Column({ space: 8 }) {
                    ForEach(this.categories, (cat: ArticleCategory) => {
                      Row() {
                        Column({ space: 4 }) {
                          Text(cat.categoryName)
                            .fontSize(14)
                            .fontColor('#333333');

                          Text(this.subscribedCategories.get(cat.id) ? '已订阅 · 将接收新文章通知' : '未订阅')
                            .fontSize(11)
                            .fontColor(this.subscribedCategories.get(cat.id) ? '#52C41A' : '#999999');
                        }
                        .layoutWeight(1)
                        .alignItems(HorizontalAlign.Start);

                        Toggle({ type: ToggleType.Switch, isOn: this.subscribedCategories.get(cat.id) || false })
                          .width(44)
                          .height(24)
                          .selectedColor('#1677FF')
                          .switchPointColor('#FFFFFF')
                          .onChange((isOn: boolean) => {
                            this.toggleSubscription(cat.id, cat.categoryName);
                          });
                      }
                      .width('100%')
                      .padding(12)
                      .backgroundColor('#FAFAFA')
                      .borderRadius(8)
                      .alignItems(VerticalAlign.Center);
                    }, (cat: ArticleCategory) => cat.id.toString());
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16 });
                }
                .constraintSize({ maxHeight: 250 })
                .scrollBar(BarState.Off)
                .width('100%');
              }
              .width('100%')
              .padding({ bottom: 12 })
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#E6F4FF' })
              .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
            }
          }
          .width('90%')
          .margin({ left: '5%', right: '5%', bottom: 8 })

          Column() {
            Text('热门推荐')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ left: 16, top: 16, bottom: 8 })
              .width('100%')
              .textAlign(TextAlign.Start);

            if (this.hotArticles.length === 0) {
              Text('暂无热门推荐')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(20);
            } else {
              Scroll() {
                Row({
                  space: 12
                }) {
                  ForEach(this.hotArticles.slice(0, 5), (article: ScienceArticle, index: number) => {
                    Column() {
                      if (article.coverImage && article.coverImage.indexOf('http') === 0) {
                        Image(article.coverImage)
                          .width('100%')
                          .height(140)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(8)
                      } else {
                        Text('📰')
                          .fontSize(48)
                          .margin({ bottom: 8 });
                      }
                      Text(article.title)
                        .fontSize(this.isElderMode ? 16 : 14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')
                        .maxLines(2)
                        .textAlign(TextAlign.Center)
                        .margin({ top: 8 });
                      Text(article.summary)
                        .fontSize(this.isElderMode ? 14 : 12)
                        .fontColor('#999999')
                        .maxLines(2)
                        .textAlign(TextAlign.Center)
                        .margin({ top: 4 });
                    }
                    .width(200)
                    .height(240)
                    .padding(16)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(12)
                    .border({ width: 1, color: '#F0F0F0' })
                    .onClick(() => {
                      try {
                        router.pushUrl({
                          url: 'pages/ScienceDetailPage',
                          params: { articleId: article.id.toString(), articleTitle: article.title }
                        });
                      } catch (error) {
                        console.error('Failed to navigate to ScienceDetailPage:', error);
                      }
                    });
                  }, (article: ScienceArticle, index: number) => article.id.toString() + '_' + index);
                }
                .width('100%')
                .padding({ left: 16, right: 16, bottom: 16 })
              }
              .scrollBar(BarState.Off)
              .scrollable(ScrollDirection.Horizontal)
              .width('100%')
              .height(280)
              .edgeEffect(EdgeEffect.Spring)
            }
          }

          Column() {
            Text('文章列表')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ left: 16, top: 16, bottom: 8 })
              .width('100%')
              .textAlign(TextAlign.Start);

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
            } else if (this.getDisplayedArticles().length === 0) {
              Column() {
                Text('📚')
                  .fontSize(48)
                  .margin({ bottom: 16 });
                Text(this.searchText.trim() ? '未找到相关文章' : '暂无文章内容')
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor('#999999');
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);
            } else {
              List() {
                ForEach(this.getDisplayedArticles(), (article: ScienceArticle, index: number) => {
                  ListItem() {
                    Row() {
                      if (article.coverImage && article.coverImage.indexOf('http') === 0) {
                        Image(article.coverImage)
                          .width(64)
                          .height(64)
                          .objectFit(ImageFit.Cover)
                          .borderRadius(12)
                          .alt('📰')
                      } else {
                        Column() {
                          Text('📰').fontSize(28)
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

                          Text('👁 ' + (article.readCount >= 1000 ? (article.readCount / 1000).toFixed(1) + 'k' : article.readCount.toString()))
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
                  .width('90%')
                  .margin({ bottom: 10, left: '5%', right: '5%' })
                  .padding(14)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .border({ width: 1, color: '#F0F0F0' })
                  .onClick(() => {
                    try {
                      router.pushUrl({
                        url: 'pages/ScienceDetailPage',
                        params: { articleId: article.id.toString(), articleTitle: article.title }
                      });
                    } catch (error) {
                      console.error('Failed to navigate to ScienceDetailPage:', error);
                    }
                  });
                }, (article: ScienceArticle, index: number) => article.id.toString() + '_' + article.title);

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
              .layoutWeight(1)
              .onReachEnd(() => {
                this.loadMore();
              });
            }
          }
          .width('100%')
          .padding({ top: 8, bottom: 100 });
        }
      }
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
