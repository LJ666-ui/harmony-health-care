import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface MenuItem {
  icon: string;
  title: string;
  color: string;
  url: string;
}

@Entry
@Component
struct Profile {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State menuItems: MenuItem[] = [
    { icon: '📱', title: '设备绑定', color: '#1677FF', url: 'pages/DeviceDiscoveryPage' },
    { icon: '🎤', title: '语音助手', color: '#1677FF', url: 'pages/VoiceAssistantPage' },
    { icon: '⚙️', title: '账号设置', color: '#333333', url: '' },
    { icon: '🔒', title: '隐私设置', color: '#1677FF', url: 'pages/PrivacyPage' },
    { icon: 'ℹ️', title: '关于我们', color: '#333333', url: '' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  toggleElderMode(): void {
    this.isElderMode = !this.isElderMode;
    AppStorage.setOrCreate<boolean>('isOldModeEnabled', this.isElderMode);
  }

  handleMenuClick(item: MenuItem): void {
    if (item.url) {
      try {
        router.pushUrl({ url: item.url });
      } catch (e) {
        console.error('路由跳转失败:', e);
      }
    }
  }

  build() {
    Column() {
      Header({
        title: '个人中心',
        showBack: true
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('我的')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Circle()
                .width(80)
                .height(80)
                .fill('#4a90e220')
                .stroke(GlobalTheme.THEME_COLOR);

              Column({ space: 8 }) {
                Text('星云用户')
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor('#333333');
                Text('138****1234')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#666666');
              }
              .alignItems(HorizontalAlign.Start);
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR });
          }

          Column({ space: 1 }) {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('👴 老年模式')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#333333')
                .fontWeight('bold');

              Blank();

              Text(this.isElderMode ? '已开启' : '已关闭')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(this.isElderMode ? GlobalTheme.SUCCESS_COLOR : '#999999')
                .backgroundColor(this.isElderMode ? '#F6FFED' : '#F5F5F5')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(10);
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius({ topLeft: GlobalTheme.RADIUS_MD, topRight: GlobalTheme.RADIUS_MD })
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
            .onClick(() => this.toggleElderMode());

            ForEach(this.menuItems, (item: MenuItem) => {
              Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                Text(item.icon)
                  .fontSize(24);

                Text(item.title)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor(item.color)
                  .fontWeight(item.color === '#1677FF' ? FontWeight.Bold : FontWeight.Normal);

                Blank();

                Text('›')
                  .fontSize(28)
                  .fontColor('#999999');
              }
              .width('100%')
              .padding(GlobalTheme.getSpacingMD(this.isElderMode))
              .backgroundColor('#FFFFFF')
              .onClick(() => this.handleMenuClick(item));
            }, (item: MenuItem) => item.title);
          }
          .borderRadius(GlobalTheme.RADIUS_MD)
          .border({ width: 1, color: GlobalTheme.BORDER_COLOR });

          Button('退出登录')
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight('bold')
            .fontColor('#FFFFFF')
            .backgroundColor(GlobalTheme.THEME_COLOR)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .shadow({
              radius: 8,
              color: '#1677FF30',
              offsetX: 0,
              offsetY: 4
            })
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Login' });
            });
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .layoutWeight(1);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
