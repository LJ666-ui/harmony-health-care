import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import BrowseTracker from '../utils/BrowseTracker';
import RdbHelper from '../utils/RdbHelper';
import {
  TABLE_COLLECTION_CACHE,
  COLUMN_COLLECT_TYPE,
  COLUMN_TARGET_ID,
  COLUMN_TARGET_TITLE,
  COLUMN_TARGET_IMAGE,
  COLUMN_COLLECT_TIME,
  COLUMN_IS_SYNCED
} from '../utils/DatabaseConstants';
import relationalStore from '@ohos.data.relationalStore';

export interface FoodDetailData {
  id: number;
  foodId: string;
  foodName: string;
  dietTherapy: string;
  applicableDisease: string;
  efficacy: string;
  dietaryTaboo: string;
}

interface RecipeStep {
  title: string;
  steps: string[];
}

@Entry
@Component
struct FoodDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State foodId: string = '';
  @State foodName: string = '';
  @State foodDetail: FoodDetailData | null = null;
  @State isLoading: boolean = true;
  @State isFavorited: boolean = false;
  @State isCollecting: boolean = false;
  @State recipes: RecipeStep[] = [];
  @State isInShoppingList: boolean = false;

  private browseRecordId: number | undefined = undefined;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    const params = router.getParams() as Record<string, Object>;
    if (params && params['foodId']) {
      this.foodId = params['foodId'] as string;
    }
    if (params && params['foodName']) {
      this.foodName = params['foodName'] as string;
    }

    this.loadFoodDetail();
    this.checkCollectionStatus();
    this.checkShoppingListStatus();
  }

  aboutToDisappear(): void {
    if (this.browseRecordId) {
      BrowseTracker.recordEnd(this.browseRecordId);
    }
  }

  async loadFoodDetail(): Promise<void> {
    this.isLoading = true;
    try {
      const url: string = ApiConstants.FOOD_DETAIL + this.foodId;
      const response: BaseResponse<FoodDetailData> = await HttpUtil.get<FoodDetailData>(url);

      if (response.success && response.data) {
        this.foodDetail = response.data;
        this.recipes = this.parseRecipes(response.data.dietTherapy);

        BrowseTracker.recordStart('FOOD_DETAIL', 'FOOD', Number(this.foodId), this.foodDetail.foodName)
          .then(id => {
            this.browseRecordId = id;
          });
      } else {
        ToastUtil.showSuccess('\u52A0\u8F7D\u5931\u8D25');
      }
    } catch (e) {
      console.error('\u52A0\u8F7D\u98DF\u6750\u8BE6\u60C5\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u7F51\u7EDC\u5F02\u5E38\uFF0C\u8BF7\u68C0\u67E5\u8FDE\u63A5');
    } finally {
      this.isLoading = false;
    }
  }

  parseRecipes(dietTherapy: string): RecipeStep[] {
    if (!dietTherapy || dietTherapy.length === 0) return [];

    const result: RecipeStep[] = [];
    let dietStr = dietTherapy;
    dietStr = dietStr.replace(/【/g, ',');
    dietStr = dietStr.replace(/】/g, ',');
    const recipeBlocks: string[] = dietStr.split(',');

    let currentTitle: string = '';
    for (let i = 0; i < recipeBlocks.length; i++) {
      const block: string = recipeBlocks[i].trim();
      if (block.length === 0) continue;

      if (i % 2 === 1) {
        currentTitle = block;
      } else if (currentTitle && block.length > 0) {
        const lines: string[] = block.split('\n');
        const steps: string[] = [];
        for (let j = 0; j < lines.length; j++) {
          const line: string = lines[j].trim();
          if (line.length > 3) {
            steps.push(line);
          }
        }
        if (steps.length > 0) {
          result.push({ title: currentTitle, steps: steps });
        }
        currentTitle = '';
      }
    }

    return result;
  }

  async checkCollectionStatus(): Promise<void> {
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
      predicates.equalTo(COLUMN_COLLECT_TYPE, 'FOOD');
      predicates.equalTo(COLUMN_TARGET_ID, Number(this.foodId));

      const result = await RdbHelper.queryByPredicates(predicates, ['id']);
      if (result && result.rowCount > 0) {
        this.isFavorited = true;
        result.close();
      }
    } catch (e) {
      console.error('\u67E5\u8BE2\u6536\u85CF\u72B6\u6001\u5931\u8D25:', e);
    }
  }

  async checkShoppingListStatus(): Promise<void> {
    try {
      const storage = AppStorage.get<string[]>('shopping_list');
      if (storage) {
        for (let i = 0; i < storage.length; i++) {
          if (storage[i] === this.foodId) {
            this.isInShoppingList = true;
            break;
          }
        }
      }
    } catch (e) {
      console.error(e.toString());
    }
  }

  async handleFavorite(): Promise<void> {
    if (this.isCollecting || !this.foodDetail) return;

    this.isCollecting = true;

    try {
      if (this.isFavorited) {
        this.isFavorited = false;
        ToastUtil.showSuccess('\u53D6\u6D88\u6536\u85CF\u6210\u529F');

        const predicates = new relationalStore.RdbPredicates(TABLE_COLLECTION_CACHE);
        predicates.equalTo(COLUMN_COLLECT_TYPE, 'FOOD');
        predicates.equalTo(COLUMN_TARGET_ID, Number(this.foodId));
        await RdbHelper.delete(predicates);
      } else {
        this.isFavorited = true;
        ToastUtil.showSuccess('\u6536\u85CF\u6210\u529F');

        const collectValues: relationalStore.ValuesBucket = {};
        collectValues[COLUMN_COLLECT_TYPE] = 'FOOD';
        collectValues[COLUMN_TARGET_ID] = this.foodDetail.id;
        collectValues[COLUMN_TARGET_TITLE] = this.foodDetail.foodName;
        collectValues[COLUMN_TARGET_IMAGE] = '';
        collectValues[COLUMN_COLLECT_TIME] = Date.now();
        collectValues[COLUMN_IS_SYNCED] = 1;

        await RdbHelper.insert(TABLE_COLLECTION_CACHE, collectValues);
      }
    } catch (e) {
      console.error('\u6536\u85CF\u64CD\u4F5C\u5931\u8D25:', e);
      ToastUtil.showSuccess('\u64CD\u4F5C\u5931\u8D25\uFF0C\u8BF7\u68C0\u67E5\u7F51\u7EDC');
    } finally {
      this.isCollecting = false;
    }
  }

  addToShoppingList(): void {
    if (!this.foodDetail) return;

    try {
      let shoppingList: string[] = [];
      const stored = AppStorage.get<string[]>('shopping_list');
      if (stored) {
        shoppingList = stored;
      }

      if (this.isInShoppingList) {
        const newList: string[] = [];
        for (let i = 0; i < shoppingList.length; i++) {
          if (shoppingList[i] !== this.foodId) {
            newList.push(shoppingList[i]);
          }
        }
        shoppingList = newList;
        this.isInShoppingList = false;
        ToastUtil.showSuccess('\u5DF2\u79FB\u51FA\u8D2D\u7269\u6E05\u5355');
      } else {
        shoppingList.push(this.foodId);
        this.isInShoppingList = true;
        ToastUtil.showSuccess('\u5DF2\u52A0\u5165\u8D2D\u7269\u6E05\u5355');
      }

      AppStorage.setOrCreate<string[]>('shopping_list', shoppingList);
    } catch (e) {
      console.error('\u8D2D\u7269\u6E05\u5355\u64CD\u4F5C\u5931\u8D25:', e);
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
        Text('\u{1F360} ' + (this.foodDetail ? this.foodDetail.foodName : '\u98DF\u6750\u8BE6\u60C5'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)
        Text('').width(40)
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#FA8C16');
              Text('\u6B63\u5728\u52A0\u8F7D...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 12 });
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center);
          } else if (this.foodDetail) {
            Column() {
              Text(this.foodDetail.foodName)
                .fontSize(this.isElderMode ? 28 : 24)
                .fontWeight('bold')
                .fontColor('#333333')
                .margin({ bottom: 16 });

              if (this.foodDetail.efficacy && this.foodDetail.efficacy.length > 0) {
                Row({ space: 8 }) {
                  Text('\u{1F489}')
                    .fontSize(14)
                  ForEach(this.foodDetail.efficacy.split('\u3001'), (tag: string) => {
                    Text(tag.trim())
                      .fontSize(11)
                      .fontColor('#52C41A')
                      .backgroundColor('#F6FFED')
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .borderRadius(12);
                  }, (tag: string) => tag.trim());
                }
                .width('100%')
                .margin({ bottom: 12 });
              }
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingLG(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#FFF7E6' })
            .alignItems(HorizontalAlign.Start);

            if (this.foodDetail.applicableDisease && this.foodDetail.applicableDisease.length > 0) {
              Column() {
                Text('\u9002\u7528\u75C7\u72B6')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ bottom: 12 })
                  .width('100%')
                  .textAlign(TextAlign.Start);
                Text(this.foodDetail.applicableDisease)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .width('100%')
                  .textAlign(TextAlign.Start);
              }
              .width('85%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#E6F4FF' })
              .alignItems(HorizontalAlign.Start);
            }

            if (this.recipes.length > 0) {
              Column() {
                Text('\u{1F373} \u98DF\u7597\u505A\u6CD5')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ bottom: 16 })
                  .width('100%')
                  .textAlign(TextAlign.Start);

                ForEach(this.recipes, (recipe: RecipeStep, index: number) => {
                  Column() {
                    Row() {
                      Text((index + 1).toString())
                        .fontSize(18)
                        .fontWeight('bold')
                        .fontColor('#FFFFFF')
                        .width(32)
                        .height(32)
                        .backgroundColor('#FA8C16')
                        .borderRadius(16)
                        .textAlign(TextAlign.Center)
                        .layoutWeight(0)
                      Text(recipe.title)
                        .fontSize(this.isElderMode ? 17 : 15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FA8C16')
                        .margin({ left: 10 })
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                    .margin({ bottom: 12 });

                    Column({ space: 8 }) {
                      ForEach(recipe.steps, (step: string, stepIndex: number) => {
                        Row({ space: 10 }) {
                          Text((stepIndex + 1).toString())
                            .fontSize(13)
                            .fontColor('#999999')
                            .width(20)
                            .height(20)
                            .backgroundColor('#F5F5F5')
                            .borderRadius(10)
                            .textAlign(TextAlign.Center)
                            .flexShrink(0)
                          Text(step)
                            .fontSize(this.isElderMode ? 15 : 13)
                            .fontColor('#444444')
                            .lineHeight(20)
                            .layoutWeight(1);
                        }
                        .width('100%')
                        .alignItems(VerticalAlign.Top);
                      }, (step: string, stepIndex: number) => index.toString() + '-' + stepIndex.toString());
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#FFFBF0')
                    .borderRadius(8)
                    .alignItems(HorizontalAlign.Start);
                  }
                  .width('100%')
                  .padding({ bottom: 16 });
                }, (recipe: RecipeStep, index: number) => index.toString());
              }
              .width('85%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#FFF7E6' })
              .alignItems(HorizontalAlign.Start);
            }

            if (this.foodDetail.dietaryTaboo && this.foodDetail.dietaryTaboo.length > 0) {
              Column() {
                Row() {
                  Text('\u26A0\uFE0F')
                    .fontSize(16)
                    .margin({ right: 8 })
                  Text('\u996E\u98DF\u7981\u5FCC')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#CF1322');
                }
                .width('100%')
                .margin({ bottom: 12 });

                Text(this.foodDetail.dietaryTaboo)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .width('100%')
                  .textAlign(TextAlign.Start);
              }
              .width('85%')
              .padding(16)
              .backgroundColor('#FFF1F0')
              .borderRadius(12)
              .border({ width: 1, color: '#FFCCC7' })
              .alignItems(HorizontalAlign.Start);
            }
          }
        }
        .width('100%')
        .padding({ top: GlobalTheme.getSpacingMD(this.isElderMode), bottom: 120 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Column() {
        Row() {
          Button(this.isFavorited ? '\u2764\uFE0F' : '\u{1F90D}')
            .width(56)
            .height(56)
            .fontSize(24)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .onClick(() => {
              this.handleFavorite();
            });

          Button(this.isInShoppingList ? '\u{1F6D2} \u79FB\u51FA' : '\u{1F6D2} \u52A0\u5165\u8D2D\u7269')
            .height(44)
            .fontSize(14)
            .fontColor(this.isInShoppingList ? '#999999' : '#FFFFFF')
            .backgroundColor(this.isInShoppingList ? '#F5F5F5' : '#FA8C16')
            .borderRadius(22)
            .onClick(() => {
              this.addToShoppingList();
            });

          Text('')
            .width(0)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center);
      }
      .width('100%')
      .height(80)
      .padding({ top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 12,
        color: '#00000012',
        offsetX: 0,
        offsetY: -4
      });

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}