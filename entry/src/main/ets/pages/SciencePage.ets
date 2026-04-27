import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';

interface NavigationParams {
  searchKeyword?: string;
  articleId?: number | string;
  articleTitle?: string;
}

@Entry
@Component
struct SciencePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State currentBannerIndex: number = 0;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  private navigateTo(url: string, params?: NavigationParams): void {
    try {
      if (params) {
        router.pushUrl({ url: url, params: params });
      } else {
        router.pushUrl({ url: url });
      }
    } catch (error) {
      console.error('导航失败:', error);
    }
  }

  build() {
    // 保留悬浮发布按钮（完整功能）
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Header({ title: '发现' })

        Scroll() {
          Column({ space: this.isElderMode ? 16 : 12 }) {
            this.buildSearchBar()
            this.buildCarouselBanner()
            this.buildCategoryGrid()
            this.buildArticleSection()
            this.buildAIToolBox()
            Footer({ activeIndex: 3 })
          }
          .padding({ left: 16, right: 16, bottom: 80 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .height('100%')
      .backgroundColor('#F5F7FA')

      // 悬浮发布文章按钮
      Column() {
        Text('✏️')
          .fontSize(24)
        Text('发布')
          .fontSize(10)
          .fontColor('#FFFFFF')
          .margin({ top: 2 })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#1677FF')
      .borderRadius(28)
      .shadow({
        radius: 8,
        color: '#1677FF40',
        offsetX: 0,
        offsetY: 4
      })
      .margin({ right: 20, bottom: 90 })
      .onClick(() => {
        this.navigateTo('pages/PublishArticlePage');
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder buildSearchBar(): void {
    Row({ space: 10 }) {
      Row({ space: 8 }) {
        Text('🔍')
          .fontSize(18)

        TextInput({
          placeholder: '搜索健康知识、药材、食材...'
        })
          .fontSize(this.isElderMode ? 16 : 14)
          .layoutWeight(1)
          .height(40)
          .padding({ left: 8, right: 8 })
          .backgroundColor('transparent')
          .onChange((value: string) => {
            if (value && value.trim().length > 0) {
              console.log('搜索内容:', value);
            }
          })
          .onSubmit((enterKey: EnterKeyType) => {
            this.navigateTo('pages/ScienceDetailPage', { 'searchKeyword': 'search' });
          })
      }
      .layoutWeight(1)
      .height(48)
      .padding({ left: 16, right: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .border({ width: 1, color: '#E0E0E0' })

      Text('🎤')
        .fontSize(22)
        .width(40)
        .height(40)
        .textAlign(TextAlign.Center)
        .backgroundColor('#1677FF')
        .borderRadius(20)
        .onClick(() => {
          this.navigateTo('pages/AiChatPage');
        })
    }
    .width('100%')
    .margin({ top: 12 })
  }

  @Builder buildCarouselBanner(): void {
    Swiper() {
      this.buildBannerItem('#27AE60', '#229954', '📰🔥', '本周热门: 高血压防治全攻略', '阅读12.5k · 收藏3.2k', '立即阅读 →', 'pages/ScienceDetailPage')
      this.buildBannerItem('#9B59B6', '#8E44AD', '🔬🏥', 'X光/CT/MRI AI智能诊断', '秒级识别 · 多种病灶 · 可视化标注', '上传影像 →', 'pages/ImageAnalysisPage')
      this.buildBannerItem('#F39C12', '#E67E22', '🌿🍎', '[当季]养生食材推荐', '枸杞·银耳·百合 · 润肺养颜', '查看详情 →', 'pages/FoodEncyclopediaPage')
      this.buildBannerItem('#3498DB', '#2980B9', '🔗🌐', '医学知识图谱', '疾病-症状-药物关联 · 智能推理', '探索图谱 →', 'pages/KnowledgeGraphPage')
      this.buildBannerItem('#1ABC9C', '#16A085', '📜✨', '古医古籍数字化展览', '高清复原 · OCR识别 · 文化传承', '走进历史 →', 'pages/AncientMedicalImgPage')
    }
    .autoPlay(true)
    .interval(4000)
    .loop(true)
    .indicator(new DotIndicator()
      .itemWidth(6)
      .itemHeight(6)
      .selectedItemWidth(18)
      .selectedItemHeight(6)
      .color('#FFFFFF80')
      .selectedColor('#FFFFFF'))
    .width('100%')
    .height(this.isElderMode ? 180 : 160)
    .margin({ top: 12 })
  }

  @Builder buildBannerItem(color1: string, color2: string, icon: string, title: string, subtitle: string, ctaText: string, targetUrl: string): void {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text(icon)
          .fontSize(this.isElderMode ? 28 : 22)
        Text(title)
          .fontSize(this.isElderMode ? 20 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
      }
      .alignItems(VerticalAlign.Center)

      Text(subtitle)
        .fontSize(this.isElderMode ? 14 : 12)
        .fontColor('#FFFFFFCC')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text(ctaText)
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
        Text(' →')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#FFFFFF')
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF30')
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .linearGradient({
      angle: 135,
      colors: [[color1, 0], [color2, 1]]
    })
    .borderRadius(12)
    .onClick(() => {
      this.navigateTo(targetUrl);
    })
  }

  @Builder buildCategoryGrid(): void {
    Column({ space: 16 }) {
      Text('内容分类')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      Grid() {
        ForEach([
          { id: 'science', icon: '📰', title: '健康科普', route: 'pages/ScienceListPage' },
          { id: 'herbal', icon: '🌿', title: '中药材', route: 'pages/HerbalListPage' },
          { id: 'food', icon: '🍎', title: '食材百科', route: 'pages/FoodEncyclopediaPage' },
          { id: 'knowledge', icon: '🔗', title: '知识图谱', route: 'pages/KnowledgeGraphPage' },
          { id: 'imaging_ai', icon: '🔬', title: '影像AI', route: 'pages/ImageAnalysisPage' },
          { id: 'ancient', icon: '📜', title: '古籍医学', route: 'pages/AncientMedicalImgPage' },
          { id: 'stats', icon: '📊', title: '数据统计', route: 'pages/StatisticsPage' },
          { id: 'collect', icon: '❤️', title: '我的收藏', route: 'pages/MyCollectPage' },
          { id: 'history', icon: '⏱️', title: '浏览历史', route: 'pages/BrowseHistoryPage' }
        ], (item: Record<string, string>) => {
          GridItem() {
            Column({ space: 8 }) {
              Text(item['icon'] as string)
                .fontSize(this.isElderMode ? 36 : 28)
              Text(item['title'] as string)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 16, bottom: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: '#F0F0F0' })
            .onClick(() => {
              this.navigateTo(item['route'] as string);
            })
          }
        }, (item: Record<string, string>) => item['id'] as string)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
    }
    .margin({ top: 16 })
  }

  @Builder buildArticleSection(): void {
    Column({ space: 12 }) {
      Row() {
        Text('精选文章')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        // 发布文章按钮
        Text('✏️ 发布')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#1677FF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#E6F4FF')
          .borderRadius(15)
          .margin({ right: 8 })
          .onClick(() => {
            this.navigateTo('pages/PublishArticlePage');
          })

        Text('查看更多 >')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#1677FF')
          .onClick(() => {
            this.navigateTo('pages/ScienceListPage');
          })
      }
      .width('100%')

      Column({ space: 10 }) {
        ForEach([
          { id: 1, title: '高血压预防指南', readCount: '1.2k', author: '张医生', time: '2026-04-20' },
          { id: 2, title: '糖尿病饮食注意事项', readCount: '890', author: '李医生', time: '2026-04-18' }
        ], (article: Record<string, string | number>) => {
          Row({ space: 12 }) {
            Column()
              .width(100)
              .height(80)
              .backgroundColor('#F0F5FF')
              .borderRadius(8)
              .justifyContent(FlexAlign.Center) {
                Text('📰')
                  .fontSize(32)
              }

            Column({ space: 6 }) {
              Text(article['title'] as string)
                .fontSize(this.isElderMode ? 16 : 14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              Row({ space: 12 }) {
                Text('阅读' + (article['readCount'] as string))
                  .fontSize(this.isElderMode ? 12 : 11)
                  .fontColor('#999999')
                Text(article['author'] as string)
                  .fontSize(this.isElderMode ? 12 : 11)
                  .fontColor('#999999')
                Text(article['time'] as string)
                  .fontSize(this.isElderMode ? 12 : 11)
                  .fontColor('#999999')
              }
              .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })
          .onClick(() => {
            const idValue: number = article['id'] as number;
            this.navigateTo('pages/ScienceDetailPage', {
              articleId: idValue,
              articleTitle: article['title'] as string
            });
          })
        }, (article: Record<string, string | number>) => (article['id'] as number).toString())
      }
    }
    .margin({ top: 16 })
  }

  @Builder buildAIToolBox(): void {
    Column({ space: 16 }) {
      Row() {
        Text('AI工具箱')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('查看全部 >')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor('#1677FF')
          .onClick(() => {
            this.navigateTo('pages/AIAssistantPage');
          })
      }
      .width('100%')

      Grid() {
        ForEach([
          { id: 'imaging_ai', icon: '🔬🏥', title: '影像AI病灶识别分析', subtitle: 'X光/CT/MRI智能诊断', colors: ['#9B59B6', '#8E44AD'], route: 'pages/ImageAnalysisPage' },
          { id: 'risk_assessment', icon: '🧠⚡', title: '智能风险评估工具', subtitle: '端侧AI·本地隐私保护', colors: ['#E74C3C', '#C0392B'], route: 'pages/RiskAssessmentPage' },
          { id: 'ancient_restore', icon: '📜✨', title: '古医图复原增强工具', subtitle: '高清复原·OCR识别', colors: ['#1ABC9C', '#16A085'], route: 'pages/ImageRestorationPage' },
          { id: 'ai_chat', icon: '🤖💬', title: 'AI智能问答助手', subtitle: '健康咨询·用药指导', colors: ['#3498DB', '#2980B9'], route: 'pages/AiChatPage' }
        ], (tool: Record<string, string | string[]>) => {
          GridItem() {
            Column({ space: 10 }) {
              Text(tool['icon'] as string)
                .fontSize(36)
              Text(tool['title'] as string)
                .fontSize(this.isElderMode ? 15 : 13)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .textAlign(TextAlign.Center)
                .maxLines(1)
              Text(tool['subtitle'] as string)
                .fontSize(this.isElderMode ? 11 : 10)
                .fontColor('#FFFFFF99')
                .textAlign(TextAlign.Center)
                .maxLines(1)
            }
            .width('100%')
            .height(100)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .linearGradient({
              angle: 135,
              colors: [[(tool['colors'] as string[])[0], 0], [(tool['colors'] as string[])[1], 1]]
            })
            .borderRadius(12)
            .onClick(() => {
              this.navigateTo(tool['route'] as string);
            })
          }
        }, (tool: Record<string, string | string[]>) => tool['id'] as string)
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
    }
    .margin({ top: 16 })
  }
}