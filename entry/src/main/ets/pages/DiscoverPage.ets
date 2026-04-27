import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { BrowseTracker } from '../utils/BrowseTracker';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { router } from '@kit.ArkUI';
import { SearchBar } from '../components/SearchBar';
import { SearchHistory } from '../components/SearchHistory';
import { CarouselBanner } from '../components/CarouselBanner';
import { CategoryGrid, CategoryItem } from '../components/CategoryGrid';
import { ArticleList, ScienceArticle } from '../components/ArticleList';
import { AIToolBox, AIToolItem } from '../components/AIToolBox';
import { Footer } from '../components/Footer';
import { BannerItem, GradientColorStop } from '../components/CarouselBanner';

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
  @State recordId: number | undefined = undefined;
  @StorageLink('isOldModeEnabled') isOldModeEnabled: boolean = false;
  private articleListRef?: ArticleList;

  aboutToAppear(): void {
    this.loadAllData();
    this.recordId = BrowseTracker.recordStart('DiscoverPage', '发现页');
  }

  aboutToDisappear(): void {
    BrowseTracker.recordEnd(this.recordId);
  }

  loadAllData() {
    this.loadBanners();
    this.loadCategories();
    this.loadArticles();
  }

  loadBanners() {
    HttpUtil.get(ApiConstants.DISCOVER_BANNER_LIST).then((res: BaseResponse<BannerItem[]>) => {
      if (res.code === 200) {
        this.banners = res.data;
      } else {
        ToastUtil.showInfo(res.msg);
      }
    }).catch((err: Error) => {
      ToastUtil.showInfo(err.message);
    });
  }

  loadCategories() {
    HttpUtil.get(ApiConstants.DISCOVER_CATEGORY_LIST).then((res: BaseResponse<CategoryItem[]>) => {
      if (res.code === 200) {
        this.categories = res.data;
      } else {
        ToastUtil.showInfo(res.msg);
      }
    }).catch((err: Error) => {
      ToastUtil.showInfo(err.message);
    });
  }

  loadArticles() {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    HttpUtil.get(ApiConstants.DISCOVER_ARTICLE_LIST, {
      pageNo: this.currentPage,
      pageSize: this.pageSize,
      title: this.searchText
    }).then((res: BaseResponse<{
      records: ScienceArticle[];
      total: number;
    }>) => {
      if (res.code === 200) {
        if (this.currentPage === 1) {
          this.articles = res.data.records;
        } else {
          this.articles = this.articles.concat(res.data.records);
        }

        this.articleListRef?.updateData(res.data.records, res.data.total);
        this.hasMore = this.articles.length < res.data.total;
      } else {
        ToastUtil.showInfo(res.msg);
      }
    }).catch((err: Error) => {
      ToastUtil.showInfo(err.message);
    }).finally(() => {
      this.isLoading = false;
    });
  }

  handleSearch() {
    if (!this.searchText) {
      return;
    }

    this.showSearchHistory = false;
    this.currentPage = 1;
    this.hasMore = true;
    this.addToSearchHistory();
    this.loadArticles();
  }

  addToSearchHistory() {
    const index = this.searchHistory.indexOf(this.searchText);
    if (index !== -1) {
      this.searchHistory.splice(index, 1);
    }

    this.searchHistory.unshift(this.searchText);
    if (this.searchHistory.length > 10) {
      this.searchHistory.pop();
    }
  }

  clearSearchHistory() {
    this.searchHistory = [];
  }

  selectSearchHistory(keyword: string) {
    this.searchText = keyword;
    this.showSearchHistory = false;
    this.currentPage = 1;
    this.hasMore = true;
    this.loadArticles();
  }

  extractSummary(content: string): string {
    let cleanedContent = content.replace(/\*\*/g, '');
    cleanedContent = cleanedContent.replace(/```arkts[\s\S]*?```/g, '');
    cleanedContent = cleanedContent.replace(/```[\s\S]*?```/g, '');
    cleanedContent = cleanedContent.replace(/^```arkts$/gm, '');
    cleanedContent = cleanedContent.replace(/^```$/gm, '');
    cleanedContent = cleanedContent.replace(/\n/g, '');
    return cleanedContent.slice(0, 80);
  }

  formatDate(publishTime: string): string {
    const date = new Date(publishTime);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  loadMore() {
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

      SearchBar({ searchText: $searchText, onSearch: () => {
        this.handleSearch();
      }, onFocus: () => {
        this.showSearchHistory = true;
      } });

      if (this.showSearchHistory) {
        SearchHistory({ history: $searchHistory, onClear: () => {
          this.clearSearchHistory();
        }, onSelect: (keyword: string) => {
          this.selectSearchHistory(keyword);
        } })
          .margin({ top: 8 })
          .zIndex(1);
      }

      CarouselBanner({ banners: $banners })
        .margin({ top: 8 });

      Column() {
        CategoryGrid();

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
            isLoading: $isLoading,
            hasMore: $hasMore,
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
