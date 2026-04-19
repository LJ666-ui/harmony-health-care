import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';

export interface FoodItem {
  id: number;
  foodId: string;
  foodName: string;
  dietTherapy: string;
  applicableDisease: string;
  efficacy: string;
  dietaryTaboo: string;
}

interface PageResultData<T> {
  records: T[];
  total: number;
}

@Entry
@Component
struct FoodEncyclopediaPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State foods: FoodItem[] = [];
  @State searchText: string = '';
  @State selectedCategory: string = '全部';
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State currentPage: number = 1;
  @State pageSize: number = 20;
  @State hasMore: boolean = true;

  private categories: string[] = ['全部', '降血压', '降血糖', '降血脂', '健脾', '养胃', '清热', '补钙', '美容'];
  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    BrowseTracker.recordStart('FOOD_LIST', 'PAGE', 1, '\u98DF\u7597\u98DF\u8C31\u5217\u8868').then(id => {
      this.recordId = id;
    });

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    this.loadFoods();
  }

  aboutToDisappear(): void {
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async loadFoods(isRefresh: boolean = false): Promise<void> {
    if (this.isLoading) return;

    this.isLoading = true;

    if (isRefresh) {
      this.currentPage = 1;
      this.hasMore = true;
    }

    try {
      let url: string = ApiConstants.FOOD_PAGE + '?page=' + this.currentPage + '&size=' + this.pageSize;

      if (this.searchText.trim()) {
        url = url + '&foodName=' + encodeURIComponent(this.searchText.trim());
      }

      if (this.selectedCategory !== '全部') {
        url = url + '&efficacy=' + encodeURIComponent(this.selectedCategory);
      }

      const response: BaseResponse<PageResultData<FoodItem>> = await HttpUtil.get<PageResultData<FoodItem>>(url);

      if (response.success && response.data) {
        const data: PageResultData<FoodItem> = response.data;
        const list: FoodItem[] = data.records || [];

        if (isRefresh) {
          this.foods = list;
        } else {
          this.foods = this.foods.concat(list);
        }

        const total: number = data.total ? data.total : 0;
        this.hasMore = this.foods.length < total;
      }
    } catch (e) {
      console.error('\u52A0\u8F7D\u98DF\u6750\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u52A0\u8F7D\u5931\u8D25\uFF0C\u8BF7\u91CD\u8BD5');
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  handleSearch(): void {
    this.currentPage = 1;
    this.hasMore = true;
    this.foods = [];
    this.loadFoods();
  }

  handleClearSearch(): void {
    this.searchText = '';
    this.currentPage = 1;
    this.hasMore = true;
    this.foods = [];
    this.loadFoods();
  }

  onCategoryChange(category: string): void {
    this.selectedCategory = category;
    this.currentPage = 1;
    this.hasMore = true;
    this.foods = [];
    this.loadFoods();
  }

  handleRefresh(): void {
    this.isRefreshing = true;
    this.loadFoods(true).then(() => {
      ToastUtil.refreshSuccess();
    });
  }

  loadMore(): void {
    if (!this.hasMore || this.isLoading) return;
    this.currentPage++;
    this.loadFoods();
  }

  getFoodEmoji(foodName: string): string {
    const nameMap: Record<string, string> = {
      '\u897F\u7EA2\u67FF': '\u{1F345}',
      '\u80E1\u841D\u535C': '\u{1F955}',
      '\u767D\u841D\u535C': '\u{1F954}',
      '\u5357\u74DC': '\u{1F956}',
      '\u571F\u8C46': '\u{1FAD4}',
      '\u7EA2\u67A3': '\u{1F349}',
      '\u84B8\u7C89': '\u{1F95C}',
      '\u84DD\u83DC': '\u{1F96C}',
      '\u82BD\u83DC': '\u{1F96D}',
      '\u9999\u8549': '\u{1F34C}',
      '\u860B\u679C': '\u{1F34E}',
      '\u68A8': '\u{1F34D}',
      '\u8461\u8404': '\u{1F347}',
      '\u897F\u74DC': '\u{1F349}',
      '\u867D\u4EC1': '\u{1F990}',
      '\u9E2D\u8089': '\u{1F386}',
      '\u9E21\u8089': '\u{1F357}',
      '\u725B\u8089': '\u{1F969}',
      '\u732A\u8089': '\u{1F437}',
      '\u7CA5': '\u{1F37A}',
      '\u6C64': '\u{1F373}'
    };
    const nameKeys: string[] = Object.keys(nameMap);
    for (let k = 0; k < nameKeys.length; k++) {
      if (foodName.indexOf(nameKeys[k]) >= 0) {
        return nameMap[nameKeys[k]];
      }
    }
    return '\u{1F37D}';
  }

  getShortSummary(food: FoodItem): string {
    let summary: string = '';
    if (food.efficacy && food.efficacy.length > 0) {
      const parts: string[] = food.efficacy.split('\u3001');
      summary = parts[0] ? parts[0] : '';
    }
    if (!summary && food.applicableDisease && food.applicableDisease.length > 0) {
      const diseaseParts: string[] = food.applicableDisease.split('\u3001');
      summary = '\u9002\u5408' + (diseaseParts[0] ? diseaseParts[0] : '');
    }
    if (!summary) {
      summary = '\u5065\u5EBB\u98DF\u7597';
    }
    if (summary.length > 20) {
      return summary.substring(0, 20) + '...';
    }
    return summary;
  }

  getRecipeCount(dietTherapy: string): number {
    if (!dietTherapy || dietTherapy.length === 0) return 0;
    let count: number = 0;
    for (let i = 0; i < dietTherapy.length; i++) {
      if (dietTherapy.charAt(i) === '\u3010') {
        count++;
      }
    }
    return count > 0 ? count : 1;
  }

  navigateToFoodDetail(food: FoodItem): void {
    router.pushUrl({
      url: 'pages/FoodDetailPage',
      params: { foodId: food.id.toString(), foodName: food.foodName }
    });
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
        Text('\u98DF\u7597\u98DF\u8C31')
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
              Text(this.searchText ? '\u{1F50D}' : '\u{1F50E}')
                .fontSize(16)
              TextInput({ text: this.searchText, placeholder: '\u641C\u7D22\u98DF\u6750...' })
                .layoutWeight(1)
                .height(36)
                .fontSize(this.isElderMode ? 16 : 14)
                .backgroundColor('transparent')
                .border({ width: 0 })
                .onChange((value: string) => {
                  this.searchText = value;
                })
                .onSubmit(() => {
                  this.handleSearch();
                })
              if (this.searchText) {
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

          Button('\u641C\u7D22')
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

        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.categories, (category: string) => {
              Text(category)
                .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
                .backgroundColor(this.selectedCategory === category ? '#1677FF' : '#F5F7FA')
                .borderRadius(18)
                .onClick(() => this.onCategoryChange(category));
            }, (category: string) => category);
          }
          .width('100%')
          .padding({ left: 14, right: 14, bottom: 6 })
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
      }
      .width('100%')
      .backgroundColor('#F5F7FA')

      Scroll() {
        Column() {
          if (this.isLoading && this.foods.length === 0) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#1677FF');
              Text('\u6B63\u5728\u52A0\u8F7D...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 });
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center);
          } else if (this.foods.length === 0) {
            Column() {
              Text('\u{1F360}')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text(this.searchText ? '\u672A\u627E\u5230\u76F8\u5173\u98DF\u6750' : '\u6682\u65E0\u98DF\u6750\u6570\u636E')
                .fontSize(15)
                .fontColor('#999999');
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center);
          } else {
            List() {
              ForEach(this.foods, (food: FoodItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(this.getFoodEmoji(food.foodName))
                        .fontSize(36)
                    }
                    .width(64)
                    .height(64)
                    .backgroundColor('#FFF7E6')
                    .borderRadius(12)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)

                    Column() {
                      Text(food.foodName)
                        .fontSize(this.isElderMode ? 19 : 16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')
                        .maxLines(1)

                      Text(this.getShortSummary(food))
                        .fontSize(this.isElderMode ? 15 : 12)
                        .fontColor('#999999')
                        .maxLines(1)
                        .margin({ top: 4 })

                      Row() {
                        Text('\u{1F373} ' + this.getRecipeCount(food.dietTherapy).toString() + '\u9053\u98DF\u7597\u65B9')
                          .fontSize(11)
                          .fontColor('#FA8C16')
                          .backgroundColor('#FFF7E6')
                          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                          .borderRadius(4)

                        if (food.efficacy && food.efficacy.length > 0) {
                          Text(food.efficacy.substring(0, 4))
                            .fontSize(11)
                            .fontColor('#52C41A')
                            .backgroundColor('#F6FFED')
                            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                            .borderRadius(4)
                            .margin({ left: 8 })
                        }
                      }
                      .width('100%')
                      .margin({ top: 6 })
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
                .onClick(() => this.navigateToFoodDetail(food));
              }, (food: FoodItem) => food.id.toString());

              if (this.hasMore && this.foods.length > 0) {
                ListItem() {
                  Row() {
                    if (this.isLoading) {
                      LoadingProgress()
                        .width(20)
                        .height(20)
                        .color('#1677FF');
                      Text('\u52A0\u8F7D\u4E2D...')
                        .fontSize(13)
                        .fontColor('#666666')
                        .margin({ left: 8 });
                    } else {
                      Text('- \u4E0A\u62C9\u52A0\u8F7D\u66F4\u591A -')
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

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}