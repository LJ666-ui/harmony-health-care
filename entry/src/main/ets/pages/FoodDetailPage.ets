import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';

interface FoodItem {
  id: string;
  name: string;
  image: string;
  calories: number; // 热量（千卡）
  protein: number; // 蛋白质（克）
  fat: number; // 脂肪（克）
  carbs: number; // 碳水化合物（克）
  suitableFor: string[]; // 适用人群
  notSuitableFor: string[]; // 不适用人群
  nutrition: Record<string, number>; // 详细营养成分
  recommendedAmount: string; // 推荐食用量
  suitablePairings: string[]; // 搭配食材
  relatedRecipes: string[]; // 相关食谱
}

@Entry
@Component
struct FoodDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State food: FoodItem | null = null;
  @State loading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadFoodDetail();
  }

  loadFoodDetail(): void {
    // 模拟从本地数据加载食材详情
    const foods: FoodItem[] = [
      {
        id: '1',
        name: '西兰花',
        image: '🥦',
        calories: 34,
        protein: 2.8,
        fat: 0.4,
        carbs: 7,
        suitableFor: ['糖尿病', '高血压', '痛风'],
        notSuitableFor: [],
        nutrition: {
          '维生素C': 89.2,
          '维生素K': 101.6,
          '叶酸': 63.2,
          '膳食纤维': 2.6
        },
        recommendedAmount: '每天100-150克',
        suitablePairings: ['鸡胸肉', '虾仁', '豆腐'],
        relatedRecipes: ['清炒西兰花', '西兰花虾仁', '西兰花豆腐汤']
      },
      {
        id: '2',
        name: '三文鱼',
        image: '🐟',
        calories: 208,
        protein: 20.4,
        fat: 13.4,
        carbs: 0,
        suitableFor: ['高血压', '痛风'],
        notSuitableFor: [],
        nutrition: {
          'Omega-3脂肪酸': 2.26,
          '维生素D': 11.2,
          '维生素B12': 2.6,
          '硒': 41.8
        },
        recommendedAmount: '每周200-300克',
        suitablePairings: ['柠檬', '橄榄油', '芦笋'],
        relatedRecipes: ['烤三文鱼', '三文鱼沙拉', '三文鱼炒饭']
      },
      {
        id: '3',
        name: '糙米',
        image: '🌾',
        calories: 111,
        protein: 2.6,
        fat: 0.9,
        carbs: 23.7,
        suitableFor: ['糖尿病', '高血压'],
        notSuitableFor: [],
        nutrition: {
          '膳食纤维': 1.8,
          '镁': 42,
          '磷': 63,
          '锌': 0.8
        },
        recommendedAmount: '每天50-100克',
        suitablePairings: ['蔬菜', '瘦肉', '豆类'],
        relatedRecipes: ['糙米饭', '糙米粥', '糙米沙拉']
      },
      {
        id: '4',
        name: '豆腐',
        image: '🥛',
        calories: 76,
        protein: 8,
        fat: 4.8,
        carbs: 1.9,
        suitableFor: ['糖尿病', '高血压', '痛风'],
        notSuitableFor: [],
        nutrition: {
          '钙': 126,
          '铁': 1.5,
          '镁': 27,
          '蛋白质': 8
        },
        recommendedAmount: '每天50-100克',
        suitablePairings: ['蔬菜', '肉类', '蘑菇'],
        relatedRecipes: ['麻婆豆腐', '豆腐汤', '豆腐炒青菜']
      },
      {
        id: '5',
        name: '香蕉',
        image: '🍌',
        calories: 89,
        protein: 1.1,
        fat: 0.3,
        carbs: 22.8,
        suitableFor: ['高血压', '痛风'],
        notSuitableFor: ['糖尿病'],
        nutrition: {
          '钾': 358,
          '维生素B6': 0.367,
          '膳食纤维': 2.6,
          '维生素C': 8.7
        },
        recommendedAmount: '每天1-2根',
        suitablePairings: ['牛奶', '燕麦', '坚果'],
        relatedRecipes: ['香蕉奶昔', '香蕉燕麦粥', '烤香蕉']
      }
    ];

    const params = router.getParams() as Record<string, string>;
    if (params && params.foodId) {
      const foodId = params.foodId;
      this.food = foods.find(f => f.id === foodId) || null;
    }
    this.loading = false;
  }

  build() {
    Column() {
      // 头部
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
        Text('食材详情')
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

      if (this.loading) {
        // 加载状态
        Column() {
          Text('加载中...')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#999999');
        }
        .width('100%')
        .height(400)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else if (!this.food) {
        // 食材不存在
        Column() {
          Text('🍎')
            .fontSize(48)
            .margin({ bottom: 16 });
          Text('食材不存在')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#999999');
        }
        .width('100%')
        .height(400)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Scroll() {
          Column() {
            // 食材基本信息
            Column() {
              Text(this.food.image)
                .fontSize(80)
                .margin({ bottom: 16 });
              Text(this.food.name)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 8 });
              Row() {
                Text(`热量: ${this.food.calories}kcal`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ right: 16 });
                Text(`蛋白质: ${this.food.protein}g`)
                  .fontSize(14)
                  .fontColor('#666666');
              };
              Row() {
                Text(`脂肪: ${this.food.fat}g`)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ right: 16 });
                Text(`碳水: ${this.food.carbs}g`)
                  .fontSize(14)
                  .fontColor('#666666');
              }
              .margin({ top: 4 });
              Row() {
                ForEach(this.food.suitableFor, (item: string) => {
                  Text(item)
                    .fontSize(12)
                    .fontColor('#52C41A')
                    .backgroundColor('#F6FFED')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(4)
                    .margin({ right: 8 });
                }, (item: string) => item);
                ForEach(this.food.notSuitableFor, (item: string) => {
                  Text(item)
                    .fontSize(12)
                    .fontColor('#FF4757')
                    .backgroundColor('#FFF1F0')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(4)
                    .margin({ right: 8 });
                }, (item: string) => item);
              }
              .margin({ top: 12 });
            }
            .width('100%')
            .padding({ top: 24, bottom: 24 })
            .backgroundColor('#FFFFFF')
            .alignItems(HorizontalAlign.Center);

            // 详细营养成分表
            Column() {
              Text('详细营养成分')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 16 })
                .width('100%')
                .textAlign(TextAlign.Start);
              ForEach(Object.entries(this.food.nutrition), (item: [string, number]) => {
                Row() {
                  Text(item[0])
                    .fontSize(14)
                    .fontColor('#666666')
                    .layoutWeight(1);
                  Text(item[1].toString())
                    .fontSize(14)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Bold);
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 });
              }, (item: [string, number]) => item[0]);
            }
            .width('85%')
            .margin({ top: 16, bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            // 推荐食用量
            Column() {
              Text('推荐食用量')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Text(this.food.recommendedAmount)
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Start);
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            // 搭配食材
            Column() {
              Text('搭配食材')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              Row({ space: 12 }) {
                ForEach(this.food.suitablePairings, (item: string) => {
                  Text(item)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .fontSize(14)
                    .fontColor('#1677FF')
                    .backgroundColor('#E6F4FF')
                    .borderRadius(16);
                }, (item: string) => item);
              }
            }
            .width('85%')
            .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });

            // 相关食谱
            Column() {
              Text('相关食谱')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')
                .textAlign(TextAlign.Start);
              ForEach(this.food.relatedRecipes, (item: string) => {
                Row() {
                  Text('🍳')
                    .fontSize(16)
                    .margin({ right: 12 });
                  Text(item)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1);
                  Text('›')
                    .fontSize(20)
                    .fontColor('#999999');
                }
                .width('100%')
                .padding({ top: 12, bottom: 12 });
              }, (item: string) => item);
            }
            .width('85%')
            .margin({ bottom: 100, left: '7.5%', right: '7.5%' })
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' });
          }
          .width('100%')
          .padding({ top: 0 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}