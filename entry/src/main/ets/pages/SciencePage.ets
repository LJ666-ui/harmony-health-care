import { router } from '@kit.ArkUI';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

export interface ScienceArticle {
  id: string;
  title: string;
  coverIcon: string;
  summary: string;
  publishTime: string;
  category: string;
  readCount: string;
}

@Entry
@Component
struct SciencePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State selectedCategory: string = '全部';
  @State isRefreshing: boolean = false;
  @State currentBannerIndex: number = 0;
  @State searchText: string = '';
  @State searchHistory: string[] = ['高血压', '糖尿病', '颈椎病', '跌倒预防'];
  @State showSearchHistory: boolean = false;
  @State searchResults: ScienceArticle[] = [];
  
  private categories: string[] = ['全部', '慢病护理', '急救知识', '用药指导', '康复训练', '营养膳食', '心理健康'];
  
  private bannerArticles: ScienceArticle[] = [
    {
      id: '1',
      title: '高血压患者的日常饮食指南',
      coverIcon: '🩺',
      summary: '科学合理的饮食是控制血压的重要手段，本文详细介绍高血压患者应遵循的DASH饮食原则...',
      publishTime: '2026-04-08',
      category: '慢病护理',
      readCount: '3.2k'
    },
    {
      id: '2',
      title: '老年人如何预防跌倒？骨科专家支招',
      coverIcon: '🦴',
      summary: '跌倒是老年人致伤致残的主要原因之一，了解科学的预防措施可以有效降低风险...',
      publishTime: '2026-04-07',
      category: '康复训练',
      readCount: '2.8k'
    },
    {
      id: '3',
      title: '糖尿病患者的运动处方',
      coverIcon: '💊',
      summary: '适度运动对血糖控制有显著效果，但需掌握正确方法和注意事项，避免低血糖发生...',
      publishTime: '2026-04-06',
      category: '慢病护理',
      readCount: '4.1k'
    }
  ];
  
  private articles: ScienceArticle[] = [
    {
      id: '1',
      title: '高血压患者的日常饮食指南',
      coverIcon: '🩺',
      summary: '科学合理的饮食是控制血压的重要手段，本文详细介绍高血压患者应遵循的DASH饮食原则...',
      publishTime: '2026-04-08',
      category: '慢病护理',
      readCount: '3.2k'
    },
    {
      id: '2',
      title: '老年人如何预防跌倒？骨科专家支招',
      coverIcon: '🦴',
      summary: '跌倒是老年人致伤致残的主要原因之一，了解科学的预防措施可以有效降低风险...',
      publishTime: '2026-04-07',
      category: '康复训练',
      readCount: '2.8k'
    },
    {
      id: '3',
      title: '糖尿病患者的运动处方',
      coverIcon: '💊',
      summary: '适度运动对血糖控制有显著效果，但需掌握正确方法和注意事项，避免低血糖发生...',
      publishTime: '2026-04-06',
      category: '慢病护理',
      readCount: '4.1k'
    },
    {
      id: '4',
      title: '颈椎病的康复训练方法',
      coverIcon: '🧘',
      summary: '长期低头看手机导致颈椎问题日益年轻化，这套康复训练动作每天10分钟有效缓解...',
      publishTime: '2026-04-05',
      category: '康复训练',
      readCount: '5.3k'
    },
    {
      id: '5',
      title: '如何正确测量血压？家庭自测指南',
      coverIcon: '📊',
      summary: '血压测量的时间、姿势、频率都会影响结果准确性，学会正确的自测方法至关重要...',
      publishTime: '2026-04-04',
      category: '慢病护理',
      readCount: '3.7k'
    }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    
    // 自动轮播（添加异常处理）
    try {
      setInterval(() => {
        this.currentBannerIndex = (this.currentBannerIndex + 1) % this.bannerArticles.length;
      }, 3000);
    } catch (e) {
      console.error('轮播定时器设置失败', e);
    }
  }

  handleRefresh(): void {
    this.isRefreshing = true;
    
    setTimeout(() => {
      this.isRefreshing = false;
      ToastUtil.refreshSuccess();
    }, 1500);
  }

  getFilteredArticles(): ScienceArticle[] {
    if (this.selectedCategory === '全部') {
      return this.articles;
    }
    return this.articles.filter(article => article.category === this.selectedCategory);
  }

  handleSearch(): void {
    if (this.searchText.trim()) {
      // 添加到搜索历史
      this.addToSearchHistory(this.searchText.trim());
      // 执行搜索（添加异常处理）
      try {
        this.searchResults = this.articles.filter(article =>
          article.title.includes(this.searchText.trim()) ||
          article.summary.includes(this.searchText.trim())
        );
      } catch (e) {
        console.error('搜索操作失败', e);
        this.searchResults = [];
      }
      this.showSearchHistory = false;
    }
  }

  addToSearchHistory(keyword: string): void {
    try {
      // 移除重复的历史记录
      this.searchHistory = this.searchHistory.filter(item => item !== keyword);
      // 添加到历史记录开头
      this.searchHistory.unshift(keyword);
      // 限制历史记录数量
      if (this.searchHistory.length > 10) {
        this.searchHistory = this.searchHistory.slice(0, 10);
      }
    } catch (e) {
      console.error('添加搜索历史失败', e);
    }
  }

  clearSearchHistory(): void {
    try {
      this.searchHistory = [];
    } catch (e) {
      console.error('清空搜索历史失败', e);
    }
  }

  selectSearchHistory(keyword: string): void {
    this.searchText = keyword;
    this.handleSearch();
  }

  getArticlesToDisplay(): ScienceArticle[] {
    if (this.searchText.trim()) {
      return this.searchResults;
    }
    return this.getFilteredArticles();
  }

  // 高亮显示文本的方法
  @Builder
  buildHighlightedText(fullText: string, fontSize: number, color: string, fontWeight?: number, maxLines?: number) {
    if (this.searchText.trim() && fullText.includes(this.searchText.trim())) {
      Column() {
        ForEach(fullText.split(this.searchText.trim()), (part: string, index: number) => {
          Row() {
            Text(part)
              .fontSize(fontSize)
              .fontColor(color)
              .fontWeight(fontWeight);
            if (index < fullText.split(this.searchText.trim()).length - 1) {
              Text(this.searchText.trim())
                .fontSize(fontSize)
                .fontColor('#FF4757')
                .fontWeight(fontWeight);
            }
          }
        }, (part: string, index: number) => `${fullText}-${index}`);
      }
    } else {
      Text(fullText)
        .fontSize(fontSize)
        .fontColor(color)
        .fontWeight(fontWeight)
        .maxLines(maxLines);
    }
  }

  build(): void {
    Column() {
      Text('健康科普')
        .width('100%')
        .height(56)
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .backgroundColor('#FFFFFF')
        .textAlign(TextAlign.Center)

      // 搜索框
      Row() {
        Row() {
          Text('🔍')
            .fontSize(16)
            .margin({ left: 12 })
          TextInput({
            placeholder: '搜索健康知识...',
            text: this.searchText
          })
            .fontSize(this.isElderMode ? 16 : 14)
            .width('100%')
            .height(40)
            .padding({ left: 8, right: 12 })
            .backgroundColor('transparent')
            .onChange((value: string) => {
              this.searchText = value;
              this.showSearchHistory = true;
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

      // 搜索历史（使用ArkUI条件渲染）
      if (this.showSearchHistory && this.searchHistory.length > 0 && !this.searchText.trim()) {
        Column() {
          Row() {
            Text('搜索历史')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
            Button('清空')
              .fontSize(12)
              .fontColor('#999999')
              .backgroundColor('transparent')
              .border({ width: 0 })
              .onClick(() => this.clearSearchHistory());
          }
          .width('90%')
          .margin({ left: '5%', right: '5%' })
          .justifyContent(FlexAlign.SpaceBetween)

          Row() {
            ForEach(this.searchHistory, (keyword: string) => {
              Text(keyword)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#666666')
                .backgroundColor('#F0F5FF')
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => this.selectSearchHistory(keyword));
            }, (keyword: string) => keyword);
          }
          .width('90%')
          .margin({ left: '5%', right: '5%', top: 8, bottom: 16 })
        }
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ left: '5%', right: '5%' })
        .padding({ top: 16, bottom: 16 })
        .shadow({
          radius: 4,
          color: '#00000008',
          offsetX: 0,
          offsetY: 2
        });
      }

      // 知识图谱入口卡片
      Column() {
        Row() {
          Text('🕸️')
            .fontSize(32)
            .margin({ right: 16 });
          Column({ space: 6 }) {
            Text('知识图谱')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1677FF');
            Text('探索疾病、症状、药材、方剂之间的关联关系')
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#666666')
              .maxLines(2);
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Text('>')
            .fontSize(20)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Bold);
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#E6F4FF')
        .borderRadius(12)
        .margin({ top: 8, bottom: 16, left: '5%', right: '5%' })
        .border({ width: 2, color: '#1677FF33' })
        .onClick(() => {
          try {
            router.pushUrl({
              url: 'pages/KnowledgeGraphPage'
            });
          } catch (error) {
            console.error('Failed to navigate to KnowledgeGraphPage:', error);
          }
        });
      }

      // 分类导航
      Scroll() {
        Row({
          space: 12
        }) {
          ForEach(this.categories, (category: string) => {
            Text(category)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .fontSize(this.isElderMode ? 16 : 14)
              .fontColor(this.selectedCategory === category ? '#1677FF' : '#666666')
              .backgroundColor(this.selectedCategory === category ? '#E6F4FF' : '#F5F7FA')
              .borderRadius(20)
              .onClick(() => {
                this.selectedCategory = category;
              });
          }, (category: string) => category);
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)

      // 热门推荐轮播图
      Column() {
        Text('热门推荐')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16, top: 16, bottom: 8 })
          .width('100%')
          .textAlign(TextAlign.Start);

        Scroll() {
          Row({
            space: 12
          }) {
            ForEach(this.bannerArticles, (article: ScienceArticle) => {
              Column() {
                Text(article.coverIcon)
                  .fontSize(48)
                  .margin({ bottom: 8 });
                Text(article.title)
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .maxLines(2)
                  .textAlign(TextAlign.Center);
                Text(article.summary)
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#999999')
                  .maxLines(2)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 4 });
              }
              .width(200)
              .height(240)
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .border({ width: 1, color: '#F0F0F0' })
              .onClick(() => {
                try {
                  router.pushUrl({
                    url: 'pages/ScienceDetailPage',
                    params: { articleId: article.id }
                  });
                } catch (error) {
                  console.error('Failed to navigate to ScienceDetailPage:', error);
                }
              });
            }, (article: ScienceArticle) => article.id);
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
      }

      // 文章列表
      Column() {
        Text('文章列表')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16, top: 16, bottom: 8 })
          .width('100%')
          .textAlign(TextAlign.Start);

        Scroll() {
          Column() {
            if (this.getArticlesToDisplay().length === 0) {
              // 空状态
              Column() {
                Text('📚')
                  .fontSize(48)
                  .margin({ bottom: 16 });
                Text(this.searchText.trim() ? '未找到相关文章' : '暂无文章')
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor('#999999');
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);
            } else {
              ForEach(this.getArticlesToDisplay(), (article: ScienceArticle) => {
                Row() {
                  Column() {
                    Text(article.coverIcon).fontSize(36)
                  }
                  .width(64)
                  .height(64)
                  .backgroundColor('#F0F5FF')
                  .borderRadius(12)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)

                  Column() {
                    // 标题（使用修复后的Builder函数）
                    this.buildHighlightedText(
                      article.title,
                      this.isElderMode ? 20 : 16,
                      '#333333',
                      FontWeight.Bold,
                      2
                    )

                    // 摘要（使用修复后的Builder函数）
                    Column() {
                      this.buildHighlightedText(
                        article.summary,
                        this.isElderMode ? 16 : 13,
                        '#999999',
                        undefined,
                        2
                      )
                    }
                    .margin({ top: 6 })

                    Row() {
                      Text(article.category)
                        .fontSize(11)
                        .fontColor('#1677FF')
                        .backgroundColor('#E6F4FF')
                        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                        .borderRadius(4)

                      Text(`👁 ${article.readCount}`)
                        .fontSize(11)
                        .fontColor('#999999')
                        .margin({ left: 12 })

                      Text(article.publishTime)
                        .fontSize(11)
                        .fontColor('#BBBBBB')
                    }
                    .width('100%')
                    .margin({ top: 8 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                }
                .width('90%')
                .margin({ bottom: 10, left: '5%', right: '5%' })
                .padding(14)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .border({ width: 1, color: '#F0F0F0' })
                .onClick(() => {
                  try {
                    router.pushUrl({
                      url: 'pages/ScienceDetailPage',
                      params: { articleId: article.id }
                    });
                  } catch (error) {
                    console.error('Failed to navigate to ScienceDetailPage:', error);
                  }
                });
              }, (article: ScienceArticle) => article.id);
            }
          }
          .width('100%')
          .padding({ top: 8, bottom: 100 });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);
      }

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
