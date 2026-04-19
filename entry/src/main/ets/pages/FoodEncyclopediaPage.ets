import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
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
struct FoodEncyclopediaPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchText: string = '';
  @State selectedNutrition: string = '全部';
  @State selectedGroup: string = '全部';
  @State foods: FoodItem[] = [
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
  @State filteredFoods: FoodItem[] = [];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.filteredFoods = this.foods;
  }

  handleSearch(): void {
    this.filterFoods();
  }

  handleNutritionFilter(nutrition: string): void {
    this.selectedNutrition = nutrition;
    this.filterFoods();
  }

  handleGroupFilter(group: string): void {
    this.selectedGroup = group;
    this.filterFoods();
  }

  filterFoods(): void {
    let result = [...this.foods];
    
    // 搜索筛选
    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase();
      result = result.filter(food => 
        food.name.toLowerCase().includes(searchLower)
      );
    }
    
    // 营养成分筛选
    if (this.selectedNutrition !== '全部') {
      switch (this.selectedNutrition) {
        case '高蛋白':
          result = result.filter(food => food.protein > 5);
          break;
        case '低糖':
          result = result.filter(food => food.carbs < 10);
          break;
        case '高钙':
          result = result.filter(food => food.nutrition['钙'] && food.nutrition['钙'] > 100);
          break;
      }
    }
    
    // 适用人群筛选
    if (this.selectedGroup !== '全部') {
      result = result.filter(food => food.suitableFor.includes(this.selectedGroup));
    }
    
    this.filteredFoods = result;
  }

  navigateToFoodDetail(food: FoodItem): void {
    router.pushUrl({
      url: 'pages/FoodDetailPage',
      params: { foodId: food.id }
    }).catch((error: Error) => {
      console.error('跳转食物详情失败:', error.message);
    });
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
        Text('食材百科')
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

      // 搜索框
      Row() {
        Row() {
          Text('🔍')
            .fontSize(16)
            .margin({ left: 12 })
          TextInput({
            placeholder: '搜索食材...',
            text: this.searchText
          })
            .fontSize(this.isElderMode ? 16 : 14)
            .width('100%')
            .height(40)
            .padding({ left: 8, right: 12 })
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.searchText = value;
            })
            .onSubmit(() => {
              this.handleSearch();
            })
        }
        .width('90%')
        .height(48)
        .backgroundColor('#F5F7FA')
        .borderRadius(24)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ top: 16, bottom: 8, left: 16, right: 16 })

      // 营养成分筛选
      Text('营养成分')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 16, top: 16, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start);

      Scroll() {
        Row({ space: 12 }) {
          ForEach(['全部', '高蛋白', '低糖', '高钙'], (nutrition: string) => {
            Text(nutrition)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(this.selectedNutrition === nutrition ? '#1677FF' : '#666666')
              .backgroundColor(this.selectedNutrition === nutrition ? '#E6F4FF' : '#F5F7FA')
              .borderRadius(20)
              .onClick(() => this.handleNutritionFilter(nutrition));
          }, (nutrition: string) => nutrition);
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)

      // 适用人群筛选
      Text('适用人群')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 16, top: 16, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start);

      Scroll() {
        Row({ space: 12 }) {
          ForEach(['全部', '糖尿病', '高血压', '痛风'], (group: string) => {
            Text(group)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(this.selectedGroup === group ? '#1677FF' : '#666666')
              .backgroundColor(this.selectedGroup === group ? '#E6F4FF' : '#F5F7FA')
              .borderRadius(20)
              .onClick(() => this.handleGroupFilter(group));
          }, (group: string) => group);
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)

      // 食材列表
      Text('食材列表')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ left: 16, top: 16, bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start);

      Scroll() {
        Column() {
          if (this.filteredFoods.length === 0) {
            // 空状态
            Column() {
              Text('🍎')
                .fontSize(48)
                .margin({ bottom: 16 });
              Text('未找到相关食材')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#999999');
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else {
            ForEach(this.filteredFoods, (food: FoodItem) => {
              Column() {
                Text(food.image)
                  .fontSize(48)
                  .margin({ bottom: 12 });
                Text(food.name)
                  .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ bottom: 8 });
                Row() {
                  Text(`热量: ${food.calories}kcal`)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ right: 12 });
                  Text(`蛋白质: ${food.protein}g`)
                    .fontSize(12)
                    .fontColor('#666666');
                };
                Row() {
                  Text(`脂肪: ${food.fat}g`)
                    .fontSize(12)
                    .fontColor('#666666')
                    .margin({ right: 12 });
                  Text(`碳水: ${food.carbs}g`)
                    .fontSize(12)
                    .fontColor('#666666');
                }
                .margin({ top: 4 });
                Row() {
                  ForEach(food.suitableFor, (item: string) => {
                    Text(item)
                      .fontSize(10)
                      .fontColor('#52C41A')
                      .backgroundColor('#F6FFED')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(4)
                      .margin({ right: 6 });
                  }, (item: string) => item);
                  ForEach(food.notSuitableFor, (item: string) => {
                    Text(item)
                      .fontSize(10)
                      .fontColor('#FF4757')
                      .backgroundColor('#FFF1F0')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(4)
                      .margin({ right: 6 });
                  }, (item: string) => item);
                }
                .margin({ top: 8 })
              }
              .width('85%')
              .margin({ bottom: 16, left: '7.5%', right: '7.5%' })
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .alignItems(HorizontalAlign.Center)
              .onClick(() => this.navigateToFoodDetail(food));
            }, (food: FoodItem) => food.id);
          }
        }
        .width('100%')
        .padding({ top: 8, bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}