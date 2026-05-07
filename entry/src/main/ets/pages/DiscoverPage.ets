import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { BrowseTracker } from '../utils/BrowseTracker';
import EventPersistenceManager from '../utils/EventPersistenceManager';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { router } from '@kit.ArkUI';
import { SearchBar } from '../components/SearchBar';
import { SearchHistory } from '../components/SearchHistory';
import { CarouselBanner, BannerItem, GradientColorStop } from '../components/CarouselBanner';
import { CategoryGrid, CategoryItem } from '../components/CategoryGrid';
import { ArticleList, ScienceArticle } from '../components/ArticleList';
import { AIToolBox } from '../components/AIToolBox';
import { Footer } from '../components/Footer';

@Entry
@Component
export struct DiscoverPage {
  // 搜索相关
  @State searchText: string = '';
  @State searchHistory: string[] = [];
  @State showSearchHistory: boolean = false;

  // 页面数据
  @State banners: BannerItem[] = [];
  @State categories: CategoryItem[] = [];
  @State articles: ScienceArticle[] = [];

  // 分页
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State hasMore: boolean = true;
  @State isLoading: boolean = false;

  // 全局状态
  @State recordId: number | undefined = undefined;
  @StorageLink('isOldModeEnabled') isOldModeEnabled: boolean = false;

  // 组件引用
  private articleListRef?: ArticleList;

  // 生命周期
  aboutToAppear(): void {
    this.loadAllData();
    this.recordId = BrowseTracker.recordStart('DiscoverPage', '发现页');
    this.loadSearchHistoryFromDB();
  }

  async loadSearchHistoryFromDB(): Promise<void> {
    try {
      const items = await EventPersistenceManager.getSearchHistory('GLOBAL', 10);
      const keywords: string[] = [];
      for (let i = 0; i < items.length; i++) {
        keywords.push(items[i].keyword);
      }
      this.searchHistory = keywords;
    } catch (error) {
      console.error('[DiscoverPage] 加载搜索历史失败:', error);
    }
  }

  aboutToDisappear(): void {
    BrowseTracker.recordEnd(this.recordId);
  }

  // 统一加载数据
  loadAllData() {
    this.loadBanners();
    this.loadCategories();
    this.loadArticles();
  }

  // 加载轮播图
  loadBanners() {
    HttpUtil.get<BannerItem[]>(ApiConstants.DISCOVER_BANNER_LIST)
      .then((res: BaseResponse<BannerItem[]>) => {
        if (res.success || res.code === 200) {
          this.banners = res.data ?? [];
        } else {
          ToastUtil.showInfo(res.msg);
        }
      })
      .catch((err: Error) => {
        console.error('[DiscoverPage] 加载轮播图失败:', err.message);
        ToastUtil.showInfo('轮播图加载失败');
      });
  }

  // 加载分类
  loadCategories() {
    HttpUtil.get<CategoryItem[]>(ApiConstants.DISCOVER_CATEGORY_LIST)
      .then((res: BaseResponse<CategoryItem[]>) => {
        if (res.success || res.code === 200) {
          this.categories = res.data ?? [];
        } else {
          ToastUtil.showInfo(res.msg);
        }
      })
      .catch((err: Error) => {
        console.error('[DiscoverPage] 加载分类失败:', err.message);
        ToastUtil.showInfo('分类加载失败');
      });
  }

  // 加载文章列表
  loadArticles() {
    if (this.isLoading) return;
    this.isLoading = true;

    const params = {
      pageNo: this.currentPage,
      pageSize: this.pageSize,
      title: this.searchText.trim()
    };

    HttpUtil.get<{ records: ScienceArticle[]; total: number }>(ApiConstants.DISCOVER_ARTICLE_LIST, params)
      .then((res) => {
        if (res.success || res.code === 200) {
          const data = res.data;
          if (this.currentPage === 1) {
            this.articles = data.records;
          } else {
            this.articles = this.articles.concat(data.records);
          }
          this.articleListRef?.updateData?.(data.records, data.total);
          this.hasMore = this.articles.length < data.total;
        } else {
          ToastUtil.showInfo(res.msg);
        }
      })
      .catch((err: Error) => {
        console.error('[DiscoverPage] 加载文章失败:', err.message);
        ToastUtil.showInfo('文章加载失败');
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  // 搜索处理
  handleSearch() {
    if (!this.searchText.trim()) return;
    this.showSearchHistory = false;
    this.currentPage = 1;
    this.hasMore = true;
    this.addToSearchHistory();
    this.loadArticles();
  }

  // 添加搜索历史
  async addToSearchHistory(): Promise<void> {
    const index = this.searchHistory.indexOf(this.searchText);
    if (index !== -1) this.searchHistory.splice(index, 1);
    this.searchHistory.unshift(this.searchText);
    if (this.searchHistory.length > 10) this.searchHistory.pop();
    await EventPersistenceManager.addSearchHistory(this.searchText, 'GLOBAL');
  }

  async clearSearchHistory(): Promise<void> {
    this.searchHistory = [];
    await EventPersistenceManager.clearSearchHistory('GLOBAL');
  }

  // 选择搜索历史
  selectSearchHistory(keyword: string) {
    this.searchText = keyword;
    this.showSearchHistory = false;
    this.currentPage = 1;
    this.hasMore = true;
    this.loadArticles();
  }

  // 文本摘要提取
  extractSummary(content: string): string {
    let cleanedContent = content.replace(/\*\*/g, '');
    cleanedContent = cleanedContent.replace(/```arkts[\s\S]*?```/g, '');
    cleanedContent = cleanedContent.replace(/```[\s\S]*?```/g, '');
    cleanedContent = cleanedContent.replace(/^```arkts$/gm, '');
    cleanedContent = cleanedContent.replace(/^```$/gm, '');
    cleanedContent = cleanedContent.replace(/\n/g, '');
    return cleanedContent.slice(0, 80);
  }

  // 日期格式化
  formatDate(publishTime: string): string {
    const date = new Date(publishTime);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 加载更多
  loadMore() {
    if (this.hasMore && !this.isLoading) {
      this.currentPage++;
      this.loadArticles();
    }
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('发现')
          .fontColor('#333333')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1);
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF');

      // 搜索栏
      SearchBar({
        searchText: $searchText,
        onSearch: () => this.handleSearch(),
        onFocus: () => this.showSearchHistory = true
      });

      // 搜索历史
      if (this.showSearchHistory) {
        SearchHistory({
          history: $searchHistory,
          onClear: () => this.clearSearchHistory(),
          onSelect: (keyword) => this.selectSearchHistory(keyword)
        })
          .margin({ top: 8 })
          .zIndex(1);
      }

      // 轮播图
      CarouselBanner({ banners: this.banners })
        .margin({ top: 8 });

      Column() {
        // 分类网格
        CategoryGrid({ categories: this.categories });

        // 文章列表模块
        Column() {
          Row() {
            Text('精选文章')
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1);

            Text('查看全部')
              .fontSize(12)
              .fontColor('#999999')
              .onClick(() => router.pushUrl({ url: 'pages/SciencePage' }));
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 });

          // 文章列表组件
          ArticleList({
            articles: this.articles,
            isLoading: this.isLoading,
            hasMore: this.hasMore,
            onLoadMore: () => this.loadMore()
          });
        }
        .width('95%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 16 });

        // AI工具箱
        AIToolBox();
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ bottom: 16 })
      .layoutWeight(1);

      // 底部导航
      Footer({ activeIndex: 3 });
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F5FA');
  }
}