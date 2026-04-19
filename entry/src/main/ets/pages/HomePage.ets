import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import BrowseTracker from '../utils/BrowseTracker';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface UserInfo {
  username: string;
  avatar: string;
  age: number;
  gender: string;
}

interface FeatureCard {
  id: number;
  icon: string;
  title: string;
  description: string;
  url: string;
}

interface HomeStats {
  todaySteps: number;
  weekAppointments: number;
  healthScore: number;
  heartRate: number;
  bloodPressure: string;
}

interface HospitalInfo {
  id: number;
  name: string;
  distance?: string;
  level?: string;
  address?: string;
}

interface ArticleInfo {
  id: number;
  title: string;
  coverImage?: string;
  categoryName?: string;
}

interface HerbalInfoSimple {
  id: number;
  name: string;
}

@Entry
@Component
struct HomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('fontSizeLevel') currentFontSizeLevel: string = 'medium';
  @StorageLink('colorMode') currentColorMode: string = 'normal';

  @State clickedCard: number = -1;
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State userInfo: UserInfo | null = null;
  @State homeStats: HomeStats | null = null;

  @State nearbyHospitals: HospitalInfo[] = [];
  @State articles: ArticleInfo[] = [];
  @State hotHerbals: HerbalInfoSimple[] = [];
  @State latestHealthRecord: Object | null = null;

  @State featureCards: FeatureCard[] = [
    { id: 0, icon: '📋', title: '健康记录', description: '查看和管理您的健康数据', url: 'pages/HealthRecords' },
    { id: 1, icon: '📅', title: '预约管理', description: '管理您的医疗预约', url: 'pages/Appointments' },
    { id: 2, icon: '💊', title: '用药管理', description: '跟踪您的用药情况', url: 'pages/Medications' },
    { id: 3, icon: '🍎', title: '饮食食谱', description: '食材百科和营养知识', url: 'pages/FoodEncyclopediaPage' },
    { id: 4, icon: '🤖', title: 'AI健康顾问', description: '智能健康问答助手', url: 'pages/AiChatPage' },
    { id: 5, icon: '🎤', title: '语音助手', description: '智能语音交互服务', url: 'pages/VoiceAssistantPage' },
    { id: 6, icon: '🌿', title: '药材百科', description: '中药材知识库查询', url: 'pages/HerbalListPage' },
    { id: 7, icon: '📱', title: '设备管理', description: '鸿蒙多设备协同管理', url: 'pages/DeviceManagePage' },
    { id: 8, icon: '🔒', title: '隐私设置', description: '管理隐私和权限', url: 'pages/PrivacyPage' }
  ];

  private recordId: number | undefined = undefined;

  aboutToAppear(): void {
    try {
      BrowseTracker.recordStart('HOME', 'PAGE', 1, '首页').then(id => {
        this.recordId = id;
      }).catch((err: Error) => {
        console.warn('浏览记录启动失败:', err.message);
      });
    } catch (trackerError) {
      console.warn('BrowseTracker 初始化失败:', trackerError);
    }

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      const elderMode = AppStorage.get<boolean>('isOldModeEnabled');
      this.isElderMode = elderMode ? elderMode : false;
    }

    if (AppStorage.get<string>('fontSizeLevel') === undefined) {
      AppStorage.setOrCreate<string>('fontSizeLevel', 'medium');
    }
    const fontSizeLevel = AppStorage.get<string>('fontSizeLevel');
    this.currentFontSizeLevel = fontSizeLevel ? fontSizeLevel : 'medium';

    if (AppStorage.get<string>('colorMode') === undefined) {
      AppStorage.setOrCreate<string>('colorMode', 'normal');
    }
    const colorMode = AppStorage.get<string>('colorMode');
    this.currentColorMode = colorMode ? colorMode : 'normal';

    this.loadHomeData();
  }

  aboutToDisappear(): void {
    // 记录浏览结束
    if (this.recordId) {
      BrowseTracker.recordEnd(this.recordId);
    }
  }

  async loadHomeData(): Promise<void> {
    this.isLoading = true;
    this.hasError = false;

    try {
      const storedUserInfo: UserInfo | undefined = AppStorage.get<UserInfo>('userInfo');
      if (storedUserInfo) {
        this.userInfo = storedUserInfo;
      } else {
        this.userInfo = {
          username: '张三',
          avatar: '',
          age: 65,
          gender: '男'
        } as UserInfo;
      }

      this.homeStats = {
        todaySteps: 6852,
        weekAppointments: 3,
        healthScore: 85,
        heartRate: 72,
        bloodPressure: '120/80'
      } as HomeStats;

      this.isLoading = false;

      const userId: number = AppStorage.get<number>('userId') || 1;

      setTimeout(async () => {
        try {
          const hospitalParams: Record<string, string | number | boolean> = {};
          hospitalParams['longitude'] = 116.404;
          hospitalParams['latitude'] = 39.915;

          const articleParams: Record<string, string | number | boolean> = {};
          articleParams['pageSize'] = 5;

          const herbalParams: Record<string, string | number | boolean> = {};
          herbalParams['limit'] = 10;

          const healthRecordParams: Record<string, string | number | boolean> = {};
          healthRecordParams['userId'] = userId;

          const hospitalsRes: BaseResponse<HospitalInfo[]> = await HttpUtil.get<HospitalInfo[]>('/hospital/nearby', hospitalParams);
          if (hospitalsRes.success && hospitalsRes.data) {
            this.nearbyHospitals = hospitalsRes.data as HospitalInfo[];
          }

          const articlesRes: BaseResponse<ArticleInfo[]> = await HttpUtil.get<ArticleInfo[]>('/healthArticle/list', articleParams);
          if (articlesRes.success && articlesRes.data) {
            this.articles = articlesRes.data as ArticleInfo[];
          }

          const herbalsRes: BaseResponse<HerbalInfoSimple[]> = await HttpUtil.get<HerbalInfoSimple[]>('/herbal/hot', herbalParams);
          if (herbalsRes.success && herbalsRes.data) {
            this.hotHerbals = herbalsRes.data as HerbalInfoSimple[];
          }

          const healthRes: BaseResponse<Object> = await HttpUtil.get<Object>('/health-record/latest', healthRecordParams);
          if (healthRes.success && healthRes.data) {
            this.latestHealthRecord = healthRes.data;
          }
        } catch (apiError) {
          console.warn('API 加载失败，使用默认数据:', apiError);
        }
      }, 100);
    } catch (error) {
      console.error('加载首页数据失败:', error);
      this.isLoading = false;
      this.hasError = false;
    }
  }

  handleRetry(): void {
    this.loadHomeData();
  }

  handleCardClick(card: FeatureCard): void {
    this.clickedCard = card.id;
    console.log('准备跳转到:', card.url);
    setTimeout(() => {
      try {
        router.pushUrl({
          url: card.url,
          params: { from: 'HomePage' }
        }).then(() => {
          console.log('跳转成功:', card.url);
        }).catch((err: Error) => {
          console.error('跳转失败:', err.message, card.url);
        });
      } catch (e) {
        console.error('路由跳转异常:', e);
      }
    }, 150);
  }

  build() {
    Column() {
      Header({ title: '首页', showBack: true });

      Scroll() {
        Column({ space: AccessibilityConfig.getSpacingLG() }) {
          if (this.isLoading) {
            Loading();
          } else if (this.hasError) {
            EmptyState({
              icon: '❌',
              title: '加载失败',
              description: '数据加载出现问题，请重试',
              buttonText: '重新加载',
              onAdd: () => this.handleRetry()
            });
          } else {
            Text('星云医疗助手')
              .fontSize(AccessibilityConfig.getFontSizeTitle())
              .fontWeight('bold')
              .fontColor(AccessibilityConfig.getThemeColor())
              .margin({ top: AccessibilityConfig.getSpacingLG(), bottom: AccessibilityConfig.getSpacingMD() });

            if (this.userInfo) {
              Row({ space: AccessibilityConfig.getSpacingMD() }) {
                Column() {
                  Text('👤')
                    .fontSize(40)
                }
                .width(64)
                .height(64)
                .backgroundColor('#F0F0F0')
                .borderRadius(32)
                .justifyContent(FlexAlign.Center);

                Column({ space: 4 }) {
                  Text('您好，' + this.userInfo.username)
                    .fontSize(AccessibilityConfig.getFontSizeBody())
                    .fontWeight('bold')
                    .fontColor(AccessibilityConfig.getTextPrimary());

                  Text('' + this.userInfo.age + '岁 | ' + this.userInfo.gender)
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary());
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(12)
              .margin({ bottom: AccessibilityConfig.getSpacingMD() });
            }

            if (this.homeStats) {
              Row({ space: AccessibilityConfig.getSpacingSM() }) {
                this.buildStatCard('👟', '今日步数', this.homeStats.todaySteps.toLocaleString() + '步', '#52C41A');
                this.buildStatCard('📅', '本周预约', this.homeStats.weekAppointments + '个', '#1677FF');
                this.buildStatCard('⭐', '健康评分', this.homeStats.healthScore + '分', '#FAAD14');
              }
              .width('100%');
            }

            Text('为您提供全方位的智慧医疗服务')
              .fontSize(AccessibilityConfig.getFontSizeBody())
              .fontColor(AccessibilityConfig.getTextSecondary())
              .margin({ top: AccessibilityConfig.getSpacingMD(), bottom: AccessibilityConfig.getSpacingMD() });

            Column({ space: AccessibilityConfig.getSpacingMD() }) {
              ForEach(this.featureCards, (card: FeatureCard) => {
                Row({ space: AccessibilityConfig.getSpacingMD() }) {
                  Column() {
                    Text(card.icon)
                      .fontSize(32)
                      .fontColor(this.clickedCard === card.id ? '#FFFFFF' : AccessibilityConfig.getThemeColor());
                  }
                  .width(64)
                  .height(64)
                  .backgroundColor(this.clickedCard === card.id ? AccessibilityConfig.getThemeColor() : AccessibilityConfig.getActiveBgColor())
                  .borderRadius(32)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center);

                  Column({ space: 8 }) {
                    Text(card.title)
                      .fontSize(AccessibilityConfig.getFontSizeBody())
                      .fontWeight('bold')
                      .fontColor(AccessibilityConfig.getTextPrimary());

                    Text(this.clickedCard === card.id ? '正在跳转...' : card.description)
                      .fontSize(AccessibilityConfig.getFontSizeSmall())
                      .fontColor(this.clickedCard === card.id ? AccessibilityConfig.getThemeColor() : AccessibilityConfig.getTextSecondary());
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: AccessibilityConfig.getSpacingMD() });
                }
                .width('100%')
                .padding(AccessibilityConfig.getSpacingMD())
                .backgroundColor(this.clickedCard === card.id ? '#E6F4FF' : AccessibilityConfig.getCardBgColor())
                .borderRadius(12)
                .border({
                  width: this.clickedCard === card.id ? 2 : 1,
                  color: this.clickedCard === card.id ? AccessibilityConfig.getThemeColor() : AccessibilityConfig.getBorderColor()
                })
                .shadow(this.clickedCard === card.id ? {
                  radius: 12,
                  color: '#1677FF30',
                  offsetX: 0,
                  offsetY: 4
                } : {
                  radius: 8,
                  color: AccessibilityConfig.getShadowColor(),
                  offsetX: 0,
                  offsetY: 2
                })
                .onClick(() => this.handleCardClick(card));
              }, (card: FeatureCard) => card.id.toString());
            }
            .width('100%');
          }
        }
        .width('100%')
        .padding({ top: AccessibilityConfig.getSpacingLG(), bottom: AccessibilityConfig.getSpacingLG() });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBgColor());
  }

  @Builder
  buildStatCard(icon: string, label: string, value: string, color: string) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(28);

      Text(value)
        .fontSize(AccessibilityConfig.getFontSizeBody())
        .fontWeight('bold')
        .fontColor(color);

      Text(label)
        .fontSize(AccessibilityConfig.getFontSizeTiny())
        .fontColor(AccessibilityConfig.getTextSecondary());
    }
    .layoutWeight(1)
    .padding(AccessibilityConfig.getSpacingMD())
    .backgroundColor(AccessibilityConfig.getCardBgColor())
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
