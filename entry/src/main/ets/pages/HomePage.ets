import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface FeatureCard {
  id: number;
  icon: string;
  title: string;
  description: string;
  url: string;
}

@Entry
@Component
struct HomePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State clickedCard: number = -1;
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
    this.clickedCard = -1;
  }

  handleCardClick(card: FeatureCard): void {
    this.clickedCard = card.id;
    setTimeout(() => {
      try {
        router.pushUrl({ url: card.url });
      } catch (e) {
        console.error('路由跳转失败:', e);
      }
    }, 150);
  }

  build() {
    Column() {
      Header({ title: '首页', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('星云医疗助手')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Text('为您提供全方位的智慧医疗服务')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });

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
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .layoutWeight(1);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
