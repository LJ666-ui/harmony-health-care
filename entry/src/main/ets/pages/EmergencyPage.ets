import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface EmergencyGuide {
  id: number;
  title: string;
  icon: string;
  category: string;
  summary: string;
  steps: string[];
}

@Entry
@Component
struct EmergencyPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchText: string = '';
  @State guides: EmergencyGuide[] = [];
  @State filteredGuides: EmergencyGuide[] = [];
  @State categories: string[] = ['全部'];
  @State selectedCategory: string = '全部';
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadGuides();
  }

  async loadGuides(): Promise<void> {
    this.isLoading = true;
    
    try {
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      this.guides = [
        { 
          id: 1, 
          title: '心肺复苏（CPR）', 
          icon: '❤️', 
          category: '心肺复苏',
          summary: '心脏骤停时的紧急救护措施',
          steps: ['确认现场安全', '呼叫急救电话', '进行胸外按压', '开放气道', '人工呼吸']
        },
        { 
          id: 2, 
          title: '止血包扎', 
          icon: '🩹', 
          category: '外伤处理',
          summary: '外伤出血时的止血方法',
          steps: ['直接压迫止血', '抬高伤肢', '包扎固定', '及时就医']
        },
        { 
          id: 3, 
          title: '烧伤处理', 
          icon: '🔥', 
          category: '外伤处理',
          summary: '烧伤烫伤的紧急处理',
          steps: ['冷水冲洗', '脱去衣物', '覆盖伤口', '不要挑破水泡', '及时就医']
        },
        { 
          id: 4, 
          title: '食物中毒', 
          icon: '🤢', 
          category: '中毒急救',
          summary: '食物中毒的应急处理',
          steps: ['停止进食', '催吐（清醒时）', '补充水分', '保留样本', '及时就医']
        },
        { 
          id: 5, 
          title: '中暑急救', 
          icon: '☀️', 
          category: '环境急救',
          summary: '高温中暑的紧急处理',
          steps: ['转移至阴凉处', '解开衣物', '冷水擦拭', '补充水分', '严重时就医']
        },
        { 
          id: 6, 
          title: '骨折处理', 
          icon: '🦴', 
          category: '外伤处理',
          summary: '骨折的临时固定方法',
          steps: ['不要移动伤者', '固定骨折部位', '冷敷消肿', '及时就医']
        }
      ];
      
      const categorySet = new Set<string>();
      this.guides.forEach(g => categorySet.add(g.category));
      this.categories = ['全部', ...Array.from(categorySet)];
      
      this.filterGuides();
    } catch (error) {
      console.error('[EmergencyPage] 加载数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  filterGuides(): void {
    let result = this.guides;
    
    if (this.selectedCategory !== '全部') {
      result = result.filter(g => g.category === this.selectedCategory);
    }
    
    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase();
      result = result.filter(g => 
        g.title.toLowerCase().includes(searchLower) ||
        g.summary.toLowerCase().includes(searchLower)
      );
    }
    
    this.filteredGuides = result;
  }

  viewGuideDetail(guide: EmergencyGuide): void {
    ToastUtil.showInfo('详情功能开发中');
    // 实际项目中应跳转到详情页
  }

  build() {
    Column() {
      Header({ title: '急救指南', showBack: true });

      // 搜索框
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12 })
        TextInput({
          placeholder: '搜索急救知识...',
          text: this.searchText
        })
          .fontSize(this.isElderMode ? 16 : 14)
          .width('100%')
          .height(40)
          .backgroundColor('#f5f5f5')
          .borderRadius(20)
          .onChange((value: string) => {
            this.searchText = value;
            this.filterGuides();
          })
      }
      .width('90%')
      .height(50)
      .backgroundColor('#f5f5f5')
      .borderRadius(25)
      .margin({ top: 15, bottom: 10 })

      // 分类筛选
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Text(category)
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(this.selectedCategory === category ? '#fff' : '#666')
              .backgroundColor(this.selectedCategory === category ? '#E67E22' : '#f5f5f5')
              .padding({ left: 15, right: 15, top: 8, bottom: 8 })
              .borderRadius(20)
              .margin({ right: 10 })
              .onClick(() => {
                this.selectedCategory = category;
                this.filterGuides();
              })
          })
        }
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height(50)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#E67E22')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredGuides.length === 0) {
        Column() {
          Text('🚑')
            .fontSize(60)
          Text('暂无相关急救知识')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.filteredGuides, (guide: EmergencyGuide) => {
              Row() {
                Text(guide.icon)
                  .fontSize(40)
                  .margin({ right: 15 })

                Column() {
                  Text(guide.title)
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                    .width('100%')

                  Text(guide.summary)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#666')
                    .margin({ top: 5 })
                    .width('100%')

                  Text('分类：' + guide.category)
                    .fontSize(this.isElderMode ? 12 : 10)
                    .fontColor('#999')
                    .margin({ top: 5 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding(15)
              .shadow({ radius: 2, color: '#e0e0e0', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 10 })
              .onClick(() => this.viewGuideDetail(guide))
            })
          }
          .width('100%')
          .padding({ top: 10, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      Footer();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
  }
}
