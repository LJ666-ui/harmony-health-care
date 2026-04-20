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
  ingredients?: string[];
}

interface IngredientItem {
  name: string;
  amount?: string;
  nutrition?: string;
}

const NUTRITION_MAP: Record<string, string> = {
  '\u897F\u7EA2\u67FF': '\u542B\u5927\u91CF\u8304\u7EA2\u7D20\u3001\u7EF4\u751F\u7D20C',
  '\u80E1\u841D\u535C': '\u542B\u80E1\u841D\u535C\u7D20\u3001\u7EF4\u751F\u7D20A\u3001\u9499',
  '\u767D\u841D\u535C': '\u542B\u6787\u6798\u82F7\u3001\u786E\u5143\u7D20',
  '\u5357\u74DC': '\u542B\u79DF\u9178\u3001\u7EF4\u751F\u7D20E',
  '\u571F\u8C46': '\u542B\u86CB\u767D\u8D28\u3001\u8A6E\u7EA4\u7EF4',
  '\u7EA2\u67A3': '\u542B\u94C1\u3001\u7EF4\u751F\u7D20C',
  '\u84B8\u7C89': '\u78B3\u6C34\u5316\u5408\u7269\u4E3B\u8981\u6765\u6E90',
  '\u84DD\u83DC': '\u542B\u841D\u535C\u786B\u7D20\u3001\u7EF4\u751F\u7D20K',
  '\u82BD\u83DC': '\u542B\u7EF4\u751F\u7D20C\u3001\u8A6E\u7EA4\u7EF4',
  '\u9999\u8549': '\u542B\u94BE\u3001\u7EF4\u751F\u7D20B6',
  '\u860B\u679C': '\u542B\u679C\u80F6\u3001\u7EF4\u751F\u7D20C',
  '\u68A8': '\u542B\u679C\u7CD6\u3001\u7EF4\u751F\u7D20B',
  '\u8461\u8404': '\u542B\u82B1\u9752\u7D20\u3001\u7EF4\u751F\u7D20K',
  '\u897F\u74DC': '\u542B\u897F\u74DC\u82F7\u3001\u6C34\u5206\u5145\u8DB3',
  '\u867D\u4EC1': '\u9AD8\u86CB\u767D\u8D28\u3001\u4F4E\u8102\u80AA',
  '\u9E2D\u8089': '\u542B\u7EF4\u751F\u7D20B\u7FA4\u3001\u7EF4\u751F\u7D20E',
  '\u9E21\u8089': '\u9AD8\u86CB\u767D\u8D28\u3001\u4F4E\u8102\u80AA',
  '\u725B\u8089': '\u542B\u94C1\u3001\u950C\u3001\u86CB\u767D\u8D28',
  '\u732A\u8089': '\u542B\u86CB\u767D\u8D28\u3001\u8102\u80AA',
  '\u7CA5': '\u6613\u6D88\u5316\u3001\u8865\u5145\u80FD\u91CF',
  '\u6C64': '\u8425\u517B\u4E30\u5BCC\u3001\u6613\u5438\u6536'
};

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
  @State allIngredients: IngredientItem[] = [];
  @State showIngredientDetail: number = -1;

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
        this.allIngredients = this.extractAllIngredients(this.recipes);

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

  extractIngredientsFromStep(step: string): string[] {
    const ingredients: string[] = [];
    const nutritionKeys: string[] = Object.keys(NUTRITION_MAP);

    for (let i = 0; i < nutritionKeys.length; i++) {
      if (step.indexOf(nutritionKeys[i]) >= 0) {
        ingredients.push(nutritionKeys[i]);
      }
    }

    const amountPattern: RegExp = /(\d+)(g|\u514B|ml|\u6BEB\u5347|\u4E2A|\u7247|\u6839|\u52A9|\u5C3A|\u52FE)/g;
    const amounts: RegExpExecArray | null = amountPattern.exec(step);
    if (amounts && amounts.length > 0) {
      for (let j = 1; j < amounts.length; j++) {
        if (!ingredients.includes(amounts[j])) {
          ingredients.push(amounts[j]);
        }
      }
    }

    return ingredients;
  }

  extractAllIngredients(recipes: RecipeStep[]): IngredientItem[] {
    const ingredientMap: Record<string, IngredientItem> = {};

    for (let i = 0; i < recipes.length; i++) {
      const recipe: RecipeStep = recipes[i];
      if (recipe.steps && recipe.steps.length > 0) {
        const firstStep: string = recipe.steps[0];
        const extracted: string[] = this.extractIngredientsFromStep(firstStep + ' ' + recipe.title);

        for (let j = 0; j < extracted.length; j++) {
          const name: string = extracted[j];
          if (!ingredientMap[name]) {
            ingredientMap[name] = {
              name: name,
              nutrition: NUTRITION_MAP[name] || '\u8425\u517B\u4E30\u5BCC'
            };
          }
        }
      }
    }

    return Object.values(ingredientMap);
  }

  getIngredientNutrition(name: string): string {
    return NUTRITION_MAP[name] || '\u8425\u517B\u4E30\u5BFF\u3001\u5065\u5EB7\u98DF\u6750';
  }

  toggleIngredientDetail(index: number): void {
    if (this.showIngredientDetail === index) {
      this.showIngredientDetail = -1;
    } else {
      this.showIngredientDetail = index;
    }
  }

  getFoodEmoji(name: string): string {
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
    if (nameMap[name]) return nameMap[name];
    return '\u{1F37D}';
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

            if (this.allIngredients.length > 0) {
              Column() {
                Row() {
                  Text('\u{1F95C}')
                    .fontSize(18)
                    .margin({ right: 8 })
                  Text('\u98DF\u6750\u6E05\u5355')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .layoutWeight(1)
                  Text(this.allIngredients.length.toString() + '\u79CD')
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .width('100%')
                .margin({ bottom: 12 });

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.allIngredients, (ingredient: IngredientItem, index: number) => {
                    Column() {
                      Row({ space: 6 }) {
                        Text(this.getFoodEmoji(ingredient.name))
                          .fontSize(18)
                        Text(ingredient.name)
                          .fontSize(this.isElderMode ? 15 : 13)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')
                        Text('\u25BC')
                          .fontSize(10)
                          .fontColor(this.showIngredientDetail === index ? '#1677FF' : '#999999')
                      }
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .onClick(() => this.toggleIngredientDetail(index))

                      if (this.showIngredientDetail === index) {
                        Column() {
                          Text('\u{1F4CA} \u8425\u517B\u6210\u5206')
                            .fontSize(11)
                            .fontColor('#1677FF')
                            .margin({ bottom: 4 })
                          Text(ingredient.nutrition || this.getIngredientNutrition(ingredient.name))
                            .fontSize(11)
                            .fontColor('#666666')
                            .lineHeight(16)
                        }
                        .padding(8)
                        .backgroundColor('#F0F5FF')
                        .borderRadius(6)
                        .width('100%')
                        .margin({ top: 4 })
                      }
                    }
                    .backgroundColor('#FAFAFA')
                    .borderRadius(8)
                    .border({ width: 1, color: '#E8E8E8', style: BorderStyle.Dashed })
                    .margin({ right: 8, bottom: 8 });
                  }, (ingredient: IngredientItem, index: number) => ingredient.name + index.toString());
                }
                .width('100%')
              }
              .width('85%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#F6FFED' })
              .alignItems(HorizontalAlign.Start);
            }

            if (this.recipes.length > 0) {
              Column() {
                Row() {
                  Text('\u{1F373}')
                    .fontSize(18)
                    .margin({ right: 8 })
                  Text('\u98DF\u7597\u505A\u6CD5')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                  Text(this.recipes.length.toString() + '\u4E2A\u98DF\u7597\u65B9')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ left: 8 })
                }
                .width('100%')
                .margin({ bottom: 16 });

                ForEach(this.recipes, (recipe: RecipeStep, index: number) => {
                  Column() {
                    Row() {
                      Column() {
                        Text((index + 1).toString())
                          .fontSize(16)
                          .fontWeight('bold')
                          .fontColor('#FFFFFF')
                          .width(28)
                          .height(28)
                          .backgroundColor('#FA8C16')
                          .borderRadius(14)
                          .textAlign(TextAlign.Center)
                      }
                      .margin({ right: 12 })

                      Column() {
                        Text(recipe.title)
                          .fontSize(this.isElderMode ? 17 : 15)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#FA8C16')

                        Text('\u5171' + recipe.steps.length + '\u4E2A\u6B65\u9AA4')
                          .fontSize(11)
                          .fontColor('#999999')
                          .margin({ top: 2 })
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                    .margin({ bottom: 12 });

                    Column({ space: 10 }) {
                      ForEach(recipe.steps, (step: string, stepIndex: number) => {
                        Row({ space: 12 }) {
                          Column() {
                            Text((stepIndex + 1).toString())
                              .fontSize(12)
                              .fontWeight('bold')
                              .fontColor('#FA8C16')
                              .width(22)
                              .height(22)
                              .backgroundColor('#FFF7E6')
                              .borderRadius(11)
                              .textAlign(TextAlign.Center)

                            if (stepIndex < recipe.steps.length - 1) {
                              Column()
                                .width(2)
                                .height(20)
                                .backgroundColor('#FFD591')
                                .margin({ top: 2 })
                            }
                          }
                          .flexShrink(0)

                          Column() {
                            Text(step)
                              .fontSize(this.isElderMode ? 15 : 13)
                              .fontColor('#444444')
                              .lineHeight(20)
                              .layoutWeight(1);
                          }
                          .layoutWeight(1)
                          .alignItems(HorizontalAlign.Start)
                        }
                        .width('100%')
                        .alignItems(VerticalAlign.Top)
                        .padding({ left: 4, right: 4, top: 4, bottom: 4 });
                      }, (step: string, stepIndex: number) => index.toString() + '-' + stepIndex.toString());
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#FFFBF0')
                    .borderRadius(10)
                    .alignItems(HorizontalAlign.Start)
                    .border({ width: 1, color: '#FFE7BA', style: BorderStyle.Dashed });
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