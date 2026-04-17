import { router } from '@kit.ArkUI';
import RdbHelper from '../utils/RdbHelper';
import { TABLE_BROWSE_HISTORY, COLUMN_BROWSE_TYPE, COLUMN_TARGET_ID, COLUMN_TARGET_TITLE } from '../utils/DatabaseConstants';
import { BrowseHistoryItem } from '../models/LocalModels';
import { RecommendCard } from '../components/RecommendCard';

interface Recommendation {
  id: number;
  title: string;
  imageUrl: string;
  reason: string;
  source: string;
  type: string;
}

@Entry
@Component
struct DailyRecommendPage {
  @State recommendations: Recommendation[] = [];
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadRecommendations();
  }

  async loadRecommendations(): Promise<void> {
    this.isLoading = true;
    try {
      const resultSet = await RdbHelper.query(`SELECT ${COLUMN_BROWSE_TYPE}, ${COLUMN_TARGET_ID}, ${COLUMN_TARGET_TITLE}, COUNT(*) as count FROM ${TABLE_BROWSE_HISTORY} GROUP BY ${COLUMN_BROWSE_TYPE}, ${COLUMN_TARGET_ID} ORDER BY count DESC LIMIT 10`);
      
      const history: BrowseHistoryItem[] = [];
      while (resultSet.goToNextRow()) {
        history.push({
          browse_type: resultSet.getString(resultSet.getColumnIndex('browse_type')),
          target_id: resultSet.getLong(resultSet.getColumnIndex('target_id')),
          target_title: resultSet.getString(resultSet.getColumnIndex('target_title'))
        });
      }
      
      this.generateRecommendations(history);
    } catch (error) {
      console.error('Failed to load recommendations:', error);
      this.recommendations = [];
    } finally {
      this.isLoading = false;
    }
  }

  generateRecommendations(history: BrowseHistoryItem[]): void {
    const mockRecommendations: Recommendation[] = [
      {
        id: 1,
        title: '高血压患者的日常饮食调理',
        imageUrl: 'https://example.com/images/hypertension.jpg',
        reason: '基于您对健康文章的关注',
        source: '健康资讯',
        type: 'ARTICLE'
      },
      {
        id: 2,
        title: '黄芪的功效与作用',
        imageUrl: 'https://example.com/images/astragalus.jpg',
        reason: '基于您对中药材的兴趣',
        source: '药材百科',
        type: 'HERBAL'
      },
      {
        id: 3,
        title: '如何选择合适的医院',
        imageUrl: 'https://example.com/images/hospital.jpg',
        reason: '基于您对医疗服务的关注',
        source: '就医指南',
        type: 'HOSPITAL'
      },
      {
        id: 4,
        title: '糖尿病患者的运动建议',
        imageUrl: 'https://example.com/images/diabetes.jpg',
        reason: '基于您对健康管理的关注',
        source: '健康资讯',
        type: 'ARTICLE'
      },
      {
        id: 5,
        title: '枸杞的营养价值',
        imageUrl: 'https://example.com/images/wolfberry.jpg',
        reason: '基于您对中药材的兴趣',
        source: '药材百科',
        type: 'HERBAL'
      }
    ];
    
    if (history.length > 0) {
      this.recommendations = mockRecommendations;
    } else {
      this.recommendations = [];
    }
  }

  navigateToDetail(recommendation: Recommendation): void {
    try {
      switch (recommendation.type) {
        case 'ARTICLE':
          router.pushUrl({
            url: 'pages/ScienceDetailPage',
            params: { id: recommendation.id.toString() }
          });
          break;
        case 'HERBAL':
          router.pushUrl({
            url: 'pages/HerbalDetailPage',
            params: { id: recommendation.id.toString() }
          });
          break;
        case 'HOSPITAL':
          router.pushUrl({
            url: 'pages/HospitalDetailPage',
            params: { id: recommendation.id.toString() }
          });
          break;
        default:
          break;
      }
    } catch (error) {
      console.error('导航失败:', error);
    }
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .onClick(() => router.back());
        Text('每日推荐')
          .fontSize(20)
          .fontWeight('bold');
        Column()
          .width(60);
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceBetween);

      Scroll() {
        Column({
          space: 16
        }) {
          Text('基于您的浏览习惯推荐')
            .fontSize(18)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ top: 16, left: 16 });

          if (this.isLoading) {
            Column() {
              Text('正在生成推荐...')
                .fontSize(16)
                .fontColor('#999999');
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          } else if (this.recommendations.length > 0) {
            ForEach(this.recommendations, (item: Recommendation) => {
              RecommendCard({
                imageUrl: item.imageUrl,
                title: item.title,
                reason: item.reason,
                source: item.source,
                onClickCallback: () => this.navigateToDetail(item)
              });
            });
          } else {
            Column() {
              Image('common:ic_empty')
                .width(80)
                .height(80);
              Text('多逛逛就有推荐啦😊')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 16 });
              Text('浏览更多内容，我们会为您推荐感兴趣的话题')
                .fontSize(14)
                .fontColor('#cccccc')
                .margin({ top: 8 });
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          }
        }
        .padding(16);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5');
  }
}
