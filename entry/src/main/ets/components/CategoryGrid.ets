import { router } from '@kit.ArkUI';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

export interface CategoryItem {
  id: string;
  icon: string;
  title: string;
  color: string;
  route?: string;
}

@Component
export struct CategoryGrid {
  @Prop categories: CategoryItem[] = [];
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  private defaultCategories: CategoryItem[] = [
    { id: 'science', icon: '📰', title: '健康科普', color: '#27AE60', route: 'pages/SciencePage' },
    { id: 'herbal', icon: '🌿', title: '中药材', color: '#8B4513', route: 'pages/HerbalListPage' },
    { id: 'food', icon: '🍎', title: '食材百科', color: '#E74C3C', route: 'pages/FoodEncyclopediaPage' },
    { id: 'knowledge', icon: '🔗', title: '知识图谱', color: '#3498DB', route: 'pages/KnowledgeGraphPage' },
    { id: 'imaging_ai', icon: '🔬', title: '影像AI', color: '#9B59B6', route: 'pages/ImageAnalysisPage' },
    { id: 'ancient', icon: '📜', title: '古籍医学', color: '#16A085', route: 'pages/AncientMedicalImgPage' },
    { id: 'stats', icon: '📊', title: '数据统计', color: '#F39C12', route: 'pages/StatisticsPage' },
    { id: 'collect', icon: '❤️', title: '我的收藏', color: '#E91E63', route: 'pages/MyCollectPage' },
    { id: 'history', icon: '⏱️', title: '浏览历史', color: '#607D8B', route: 'pages/BrowseHistoryPage' }
  ];

  build() {
    Column({ space: 16 }) {
      Text('内容分类')
        .fontSize(this.isElderMode ? 18 : 16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')

      Grid() {
        ForEach(this.categories.length > 0 ? this.categories : this.defaultCategories, (item: CategoryItem) => {
          GridItem() {
            Column({ space: 8 }) {
              Text(item.icon)
                .fontSize(this.isElderMode ? 36 : 28)

              Text(item.title)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .padding({ top: 16, bottom: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: item.color + '33' })
            .onClick(() => {
              if (item.route) {
                try {
                  router.pushUrl({ url: item.route });
                } catch (error) {
                  console.error('导航失败:', error);
                }
              }
            })
          }
        }, (item: CategoryItem) => item.id)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
    }
    .padding({ left: 16, right: 16 })
  }
}
