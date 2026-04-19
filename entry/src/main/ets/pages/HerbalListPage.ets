import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { CategoryTabs } from '../components/CategoryTabs';
import { HerbalCard } from '../components/HerbalCard';
import { HerbalFilterBar } from '../components/HerbalFilterBar';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { HERBAL_CATEGORIES, HerbalInfo as MockHerbalInfo } from '../mock/herbalMock';
import BrowseTracker from '../utils/BrowseTracker';

interface BackendHerbalItem {
  id: number;
  name: string;
  pinyin?: string;
  alias?: string;
  category?: string;
  nature?: string;
  taste?: string;
  meridian?: string;
  efficacySummary?: string;
  efficacyDetail?: string;
  indication?: string;
  usageDosage?: string;
  contraindication?: string;
  toxicity?: string;
  processingMethod?: string;
  sourceOrigin?: string;
  appearance?: string;
  imageUrl?: string;
}

type HerbalInfo = MockHerbalInfo;

@Entry
@Component
struct HerbalListPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentCategory: string = '全部';
  @State filteredList: HerbalInfo[] = [];
  @State allHerbalList: HerbalInfo[] = [];
  @State searchKey: string = '';
  @State selectedNature: string = '';
  @State selectedTaste: string = '';
  @State currentSortIndex: number = 0;
  @State isLoading: boolean = false;
  @State showBackToTop: boolean = false;
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  private scroller: Scroller = new Scroller();

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    // 记录浏览开始
    BrowseTracker.recordStart('HERBAL_LIST', 'PAGE', 3, '药材百科列表').then(id => {
      this.recordId = id;
    });

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
    this.loadData();
  }

  aboutToDisappear(): void {
    // 记录浏览结束
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      let url: string = '/herbal/page';
      const params: Record<string, string | number | boolean> = {};
      params['page'] = this.currentPage;
      params['size'] = 20;

      if (this.searchKey && this.searchKey.trim() !== '') {
        const searchParams: Record<string, string | number | boolean> = {};
        searchParams['keyword'] = this.searchKey;
        const searchRes: BaseResponse<BackendHerbalItem[]> = await HttpUtil.get<BackendHerbalItem[]>('/herbal/search', searchParams);
        if (searchRes.success && searchRes.data) {
          const dataList: BackendHerbalItem[] = searchRes.data;
          const tempList: HerbalInfo[] = [];
          for (let i: number = 0; i < dataList.length; i++) {
            const item: BackendHerbalItem = dataList[i];
            const herbalItem: MockHerbalInfo = {
              id: String(item.id),
              name: item.name,
              alias: item.alias ? item.alias.split(',') : [],
              category: item.category || '',
              nature: item.nature || '',
              taste: item.taste || '',
              meridian: item.meridian ? item.meridian.split(',') : [],
              efficacy: item.efficacySummary ? item.efficacySummary.split(',') : [],
              indications: item.indication ? item.indication.split(',') : [],
              usage: item.usageDosage || '',
              dosage: item.usageDosage || '',
              caution: item.contraindication || '',
              image: item.imageUrl || ''
            } as MockHerbalInfo;
            tempList.push(herbalItem);
          }
          this.allHerbalList = tempList;
        }
      } else {
        const response: BaseResponse<Object> = await HttpUtil.get<Object>(url, params);
        if (response.success && response.data) {
          const pageData: Record<string, Object> = response.data as Record<string, Object>;
          if (pageData['records']) {
            const records: BackendHerbalItem[] = pageData['records'] as BackendHerbalItem[];
            const tempList: HerbalInfo[] = [];
            for (let i: number = 0; i < records.length; i++) {
              const item: BackendHerbalItem = records[i];
              const herbalItem: HerbalInfo = {
                id: String(item.id),
                name: item.name,
                alias: item.alias ? item.alias.split(',') : [],
                category: item.category || '',
                nature: item.nature || '',
                taste: item.taste || '',
                meridian: item.meridian ? item.meridian.split(',') : [],
                efficacy: item.efficacySummary ? item.efficacySummary.split(',') : [],
                indications: item.indication ? item.indication.split(',') : [],
                usage: item.usageDosage || '',
                dosage: item.usageDosage || '',
                caution: item.contraindication || '',
                image: item.imageUrl || ''
              } as HerbalInfo;
              tempList.push(herbalItem);
            }
            this.allHerbalList = tempList;
            const pagesValue: Object | undefined = pageData['pages'];
            this.totalPages = typeof pagesValue === 'number' ? pagesValue : 1;
          }
        }
      }

      this.filterData();
      this.isLoading = false;
    } catch (error) {
      console.error('加载药材数据失败:', error);
      this.isLoading = false;
    }
  }

  filterData(): void {
    let result: HerbalInfo[] = [];
    for (let i: number = 0; i < this.allHerbalList.length; i++) {
      result.push(this.allHerbalList[i]);
    }

    if (this.currentCategory && this.currentCategory !== '全部') {
      const filtered: HerbalInfo[] = [];
      for (let i: number = 0; i < result.length; i++) {
        if (result[i].category === this.currentCategory) {
          filtered.push(result[i]);
        }
      }
      result = filtered;
    }

    if (this.selectedNature) {
      const filtered: HerbalInfo[] = [];
      for (let i: number = 0; i < result.length; i++) {
        if (result[i].nature.includes(this.selectedNature)) {
          filtered.push(result[i]);
        }
      }
      result = filtered;
    }

    if (this.selectedTaste) {
      const filtered: HerbalInfo[] = [];
      for (let i: number = 0; i < result.length; i++) {
        if (result[i].taste.includes(this.selectedTaste)) {
          filtered.push(result[i]);
        }
      }
      result = filtered;
    }

    if (this.currentSortIndex === 1) {
      result.sort((a: HerbalInfo, b: HerbalInfo): number => a.name.localeCompare(b.name));
    } else if (this.currentSortIndex === 2) {
      result.sort((a: HerbalInfo, b: HerbalInfo): number => b.name.localeCompare(a.name));
    }

    this.filteredList = result;
  }

  handleCategoryChange(_index: number, category: string): void {
    this.currentCategory = category;
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0, animation: { duration: 200 } });
    this.filterData();
  }

  handleSearch(value: string): void {
    this.searchKey = value;
    this.filterData();
  }

  handleNatureChange(nature: string): void {
    this.selectedNature = nature;
    this.filterData();
  }

  handleTasteChange(taste: string): void {
    this.selectedTaste = taste;
    this.filterData();
  }

  handleSortChange(sortIndex: number): void {
    this.currentSortIndex = sortIndex;
    this.filterData();
  }

  handleCardClick(herbal: HerbalInfo): void {
    router.pushUrl({
      url: 'pages/HerbalDetailPage',
      params: { herbalId: herbal.id }
    }).catch((err: Error) => {
      console.error('跳转药材详情失败:', err.message);
    });
  }

  handleScrollEvent(event: object): void {
    const scrollYOffset: number = event['yOffset'] as number;
    this.showBackToTop = scrollYOffset > 500;
  }

  scrollToTop(): void {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: { duration: 300, curve: Curve.EaseOut }
    });
  }

  resetFilters(): void {
    this.currentCategory = '全部';
    this.selectedNature = '';
    this.selectedTaste = '';
    this.currentSortIndex = 0;
    this.searchKey = '';
    this.filterData();
  }

  build() {
    Stack() {
      Column() {
        Header({ title: '药材百科', showBack: true });

        CategoryTabs({
          categories: HERBAL_CATEGORIES,
          onTabChange: (index: number, category: string) => {
            this.handleCategoryChange(index, category);
          }
        });

        HerbalFilterBar({
          onSearch: (value: string) => this.handleSearch(value),
          onNatureChange: (nature: string) => this.handleNatureChange(nature),
          onTasteChange: (taste: string) => this.handleTasteChange(taste),
          onSortChange: (sortIndex: number) => this.handleSortChange(sortIndex)
        });

        Row() {
          Text(`共找到 ${this.filteredList.length} 种药材`)
            .fontSize(12)
            .fontColor('#999999')
            .layoutWeight(1);

          if (this.searchKey || this.selectedNature || this.selectedTaste || this.currentCategory !== '全部') {
            Text('清除筛选')
              .fontSize(12)
              .fontColor('#1677FF')
              .onClick(() => this.resetFilters());
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 });

        Scroll(this.scroller) {
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(48)
                .height(48)
                .color('#1677FF');

              Text('加载中...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 });
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center);
          } else if (this.filteredList.length === 0) {
            Column({ space: 20 }) {
              Text('🌿')
                .fontSize(64);

              Text('未找到相关药材')
                .fontSize(18)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold);

              Text(`没有找到与"${this.searchKey || this.currentCategory}"相关的药材`)
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Center)
                .lineHeight(22);

              Button('重置筛选条件')
                .height(40)
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(20)
                .padding({ left: 24, right: 24 })
                .onClick(() => this.resetFilters());
            }
            .width('100%')
            .height(450)
            .justifyContent(FlexAlign.Center);
          } else {
            Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.filteredList, (herbal: HerbalInfo, index: number) => {
                HerbalCard({
                  herbal: herbal,
                  onCardClick: (herb: HerbalInfo) => this.handleCardClick(herb)
                })
                  .width('48%')
                  .margin({ bottom: index % 2 === 0 ? 8 : 0 });
              }, (herbal: HerbalInfo) => herbal.id);
            }
            .width('100%')
            .padding({ left: 12, right: 12, bottom: 80 });
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .onScrollStop(() => {
          const currentYOffset: number = this.scroller.currentOffset().yOffset;
          this.showBackToTop = currentYOffset > 500;
        });

        Footer({ activeIndex: 2 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA');

      if (this.showBackToTop) {
        Column() {
          Button('↑ 顶部')
            .width(56)
            .height(56)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(28)
            .shadow({ radius: 8, color: '#00000025', offsetX: 0, offsetY: 4 })
            .onClick(() => this.scrollToTop());
        }
        .position({ x: '85%', y: '80%' })
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .height('100%');
  }
}
