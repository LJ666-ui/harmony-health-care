import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { GlobalTheme } from '../global';

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

@Entry
@Component
struct HomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State clickedCard: number = -1;
  @State isLoading: boolean = true;
  @State hasError: boolean = false;
  @State userInfo: UserInfo | null = null;
  @State homeStats: HomeStats | null = null;

  @State featureCards: FeatureCard[] = [
    { id: 0, icon: '📋', title: '健康记录', description: '查看和管理您的健康数据', url: 'pages/HealthRecords' },
    { id: 1, icon: '📅', title: '预约管理', description: '管理您的医疗预约', url: 'pages/Appointments' },
    { id: 2, icon: '💊', title: '用药管理', description: '跟踪您的用药情况', url: 'pages/Medications' },
    { id: 3, icon: '🎤', title: '语音助手', description: '智能语音交互服务', url: 'pages/VoiceAssistantPage' },
    { id: 4, icon: '🔒', title: '隐私设置', description: '管理隐私和权限', url: 'pages/PrivacyPage' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }

    this.loadHomeData();
  }

  loadHomeData(): void {
    this.isLoading = true;
    this.hasError = false;

    setTimeout(() => {
      try {
        const storedUserInfo = AppStorage.get<UserInfo>('userInfo');
        if (storedUserInfo) {
          this.userInfo = storedUserInfo;
        } else {
          this.userInfo = {
            username: '张三',
            avatar: '',
            age: 65,
            gender: '男'
          };
        }

        this.homeStats = {
          todaySteps: 6852,
          weekAppointments: 3,
          healthScore: 85,
          heartRate: 72,
          bloodPressure: '120/80'
        };

        this.isLoading = false;
      } catch (error) {
        console.error('加载首页数据失败:', error);
        this.isLoading = false;
        this.hasError = true;
      }
    }, 1500);
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
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
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
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            if (this.userInfo) {
              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
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
                  Text(`您好，${this.userInfo.username}`)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontWeight('bold')
                    .fontColor('#333333');

                  Text(`${this.userInfo.age}岁 | ${this.userInfo.gender}`)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor('#666666');
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start);
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FFFFFF')
              .borderRadius(GlobalTheme.RADIUS_MD)
              .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });
            }

            if (this.homeStats) {
              Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
                this.buildStatCard('👟', '今日步数', `${this.homeStats.todaySteps.toLocaleString()}步`, '#52C41A');
                this.buildStatCard('📅', '本周预约', `${this.homeStats.weekAppointments}个`, '#1677FF');
                this.buildStatCard('⭐', '健康评分', `${this.homeStats.healthScore}分`, '#FAAD14');
              }
              .width('100%');
            }

            Text('为您提供全方位的智慧医疗服务')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              ForEach(this.featureCards, (card: FeatureCard) => {
                Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                  Column() {
                    Text(card.icon)
                      .fontSize(32)
                      .fontColor(this.clickedCard === card.id ? '#FFFFFF' : GlobalTheme.THEME_COLOR);
                  }
                  .width(64)
                  .height(64)
                  .backgroundColor(this.clickedCard === card.id ? GlobalTheme.THEME_COLOR : GlobalTheme.THEME_COLOR + '20')
                  .borderRadius(32)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center);

                  Column({ space: 8 }) {
                    Text(card.title)
                      .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                      .fontWeight('bold')
                      .fontColor('#333333');

                    Text(this.clickedCard === card.id ? '正在跳转...' : card.description)
                      .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                      .fontColor(this.clickedCard === card.id ? GlobalTheme.THEME_COLOR : '#666666');
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });
                }
                .width('100%')
                .padding(GlobalTheme.getSpacingMD(this.isElderMode))
                .backgroundColor(this.clickedCard === card.id ? '#E6F4FF' : '#FFFFFF')
                .borderRadius(GlobalTheme.RADIUS_MD)
                .border({
                  width: this.clickedCard === card.id ? 2 : 1,
                  color: this.clickedCard === card.id ? GlobalTheme.THEME_COLOR : GlobalTheme.BORDER_COLOR
                })
                .shadow(this.clickedCard === card.id ? {
                  radius: 12,
                  color: '#1677FF30',
                  offsetX: 0,
                  offsetY: 4
                } : {
                  radius: 8,
                  color: GlobalTheme.SHADOW_COLOR,
                  offsetX: 0,
                  offsetY: 2
                })
                .onClick(() => this.handleCardClick(card));
              }, (card: FeatureCard) => card.id.toString());
            }
            .width('100%');
          }
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }

  @Builder
  buildStatCard(icon: string, label: string, value: string, color: string) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(28);

      Text(value)
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight('bold')
        .fontColor(color);

      Text(label)
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor('#666666');
    }
    .layoutWeight(1)
    .padding(GlobalTheme.getSpacingMD(this.isElderMode))
    .backgroundColor('#FFFFFF')
    .borderRadius(GlobalTheme.RADIUS_MD)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
