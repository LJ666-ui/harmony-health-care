import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import BrowseTracker from '../utils/BrowseTracker';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { router } from '@kit.ArkUI';
import { SearchBar } from '../components/SearchBar';
import { SearchHistory } from '../components/SearchHistory';
import { CarouselBanner, BannerItem, GradientColorStop } from '../components/CarouselBanner';
import { CategoryGrid, CategoryItem } from '../components/CategoryGrid';
import { ArticleList, ScienceArticle } from '../components/ArticleList';
import { AIToolBox } from '../components/AIToolBox';
import { Footer } from '../components/Footer';

class ArticlePageResult {
  records: ScienceArticle[] = [];
  total: number = 0;
}

@Entry
@Component
export struct DiscoverPage {
  @State searchText: string = '';
  @State searchHistory: string[] = [];
  @State showSearchHistory: boolean = false;
  @State banners: BannerItem[] = [];
  @State categories: CategoryItem[] = [];
  @State articles: ScienceArticle[] = [];
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State hasMore: boolean = true;
  @State isLoading: boolean = false;
  @StorageLink('isOldModeEnabled') isOldModeEnabled: boolean = false;

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    this.loadAllData();
    BrowseTracker.trackPageView('DiscoverPage').then((id: number) => {
      this.recordId = id;
    }).catch(() => {});
  }

  aboutToDisappear(): void {
    if (this.recordId !== undefined) {
      BrowseTracker.recordEnd(this.recordId).catch(() => {});
    }
  }

  loadAllData(): void {
    this.loadBanners();
    this.loadCategories();
    this.loadArticles();
  }

  loadBanners(): void {
    HttpUtil.get<BannerItem[]>(ApiConstants.DISCOVER_BANNER_LIST)
      .then((res: BaseResponse<BannerItem[]>) => {
        if (res.success && res.data !== undefined && res.data !== null) {
          const rawData: Object[] = res.data as Object[];
          const list: BannerItem[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            const item: BannerItem = {} as BannerItem;
            if (raw['id'] !== undefined) { item.id = String(raw['id']); }
            if (raw['title'] !== undefined) { item.title = raw['title'] as string; }
            if (raw['icon'] !== undefined) { item.icon = raw['icon'] as string; }
            if (raw['subtitle'] !== undefined) { item.subtitle = raw['subtitle'] as string; }
            if (raw['ctaText'] !== undefined) { item.ctaText = raw['ctaText'] as string; }
            if (raw['targetUrl'] !== undefined) { item.targetUrl = raw['targetUrl'] as string; }
            if (raw['gradientColors'] !== undefined) {
              const stopsArr: GradientColorStop[] = [];
              const stopsRaw: Object[] = raw['gradientColors'] as Object[];
              for (let j: number = 0; j < stopsRaw.length; j++) {
                const sRaw: Record<string, Object> = stopsRaw[j] as Record<string, Object>;
                const stop: GradientColorStop = {} as GradientColorStop;
                if (sRaw['offset'] !== undefined) { stop.offset = sRaw['offset'] as number; }
                if (sRaw['color'] !== undefined) { stop.color = sRaw['color'] as string; }
                stopsArr.push(stop);
              }
              item.gradientColors = stopsArr;
            }
            list.push(item);
          }
          this.banners = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DiscoverPage] 加载轮播图失败:', err.message);
      });
  }

  loadCategories(): void {
    HttpUtil.get<CategoryItem[]>(ApiConstants.DISCOVER_CATEGORY_LIST)
      .then((res: BaseResponse<CategoryItem[]>) => {
        if (res.success && res.data !== undefined && res.data !== null) {
          const rawData: Object[] = res.data as Object[];
          const list: CategoryItem[] = [];
          for (let i: number = 0; i < rawData.length; i++) {
            const raw: Record<string, Object> = rawData[i] as Record<string, Object>;
            const item: CategoryItem = {} as CategoryItem;
            if (raw['id'] !== undefined) { item.id = String(raw['id']); }
            if (raw['title'] !== undefined) { item.title = raw['title'] as string; }
            if (raw['icon'] !== undefined) { item.icon = raw['icon'] as string; }
            if (raw['color'] !== undefined) { item.color = raw['color'] as string; }
            if (raw['route'] !== undefined) { item.route = raw['route'] as string; }
            list.push(item);
          }
          this.categories = list;
        }
      })
      .catch((err: Error) => {
        console.error('[DiscoverPage] 加载分类失败:', err.message);
      });
  }

  loadArticles(): void {
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;

    const params: Record<string, string> = {};
    params['pageNo'] = this.currentPage.toString();
    params['pageSize'] = this.pageSize.toString();
    if (this.searchText.trim() !== '') {
      params['title'] = this.searchText.trim();
    }

    HttpUtil.get<ArticlePageResult>(ApiConstants.DISCOVER_ARTICLE_LIST, params as Object)
      .then((res: BaseResponse<ArticlePageResult>) => {
        if (res.success && res.data !== undefined && res.data !== null) {
          const data: ArticlePageResult = res.data as ArticlePageResult;
          const records: ScienceArticle[] = data.records || [];

          if (this.currentPage === 1) {
            this.articles = records;
          } else {
            this.articles = this.articles.concat(records);
          }
          this.hasMore = this.articles.length < data.total;
        }
      })
      .catch((err: Error) => {
        console.error('[DiscoverPage] 加载文章失败:', err.message);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleSearch(text?: string): void {
    const query: string = text || this.searchText;
    if (!query || query.trim() === '') {
      return;
    }
    this.showSearchHistory = false;
    this.currentPage = 1;
    this.hasMore = true;
    this.addToSearchHistory(query);
    this.loadArticles();
  }

  addToSearchHistory(query: string): void {
    const index: number = this.searchHistory.indexOf(query);
    if (index !== -1) {
      this.searchHistory.splice(index, 1);
    }
    this.searchHistory.unshift(query);
    if (this.searchHistory.length > 10) {
      this.searchHistory.pop();
    }
  }

  clearSearchHistory(): void {
    this.searchHistory = [];
  }

  selectSearchHistory(keyword: string): void {
    this.searchText = keyword;
    this.showSearchHistory = false;
    this.currentPage = 1;
    this.hasMore = true;
    this.loadArticles();
  }

  loadMore(): void {
    if (this.hasMore && !this.isLoading) {
      this.currentPage++;
      this.loadArticles();
    }
  }

  build() {
    Column() {
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

      SearchBar({
        placeholder: '搜索健康知识、药材、食材...',
        onSearch: (text: string) => {
          this.handleSearch(text);
        }
      });

      if (this.searchHistory.length > 0 && !this.searchText) {
        SearchHistory({
          history: $searchHistory,
          onClear: () => {
            this.clearSearchHistory();
          },
          onSelect: (keyword: string) => {
            this.selectSearchHistory(keyword);
          }
        })
          .margin({ top: 8 })
          .zIndex(1);
      }

      CarouselBanner({ banners: this.banners })
        .margin({ top: 8 });

      Column() {
        CategoryGrid({ categories: this.categories });

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
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/SciencePage'
                });
              });
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 });

          ArticleList({
            articles: this.articles,
            isLoading: this.isLoading,
            hasMore: this.hasMore,
            onLoadMore: () => {
              this.loadMore();
            }
          });
        }
        .width('95%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 16 });

        AIToolBox();
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ bottom: 16 })
      .layoutWeight(1);

      Footer({ activeIndex: 3 });
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F5FA');
  }
}
