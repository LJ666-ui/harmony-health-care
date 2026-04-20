import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { AccessibilitySettingsPanel, FirstTimeGuide } from '../components/GuideComponents';
import { NetworkStatusBanner } from '../components/ErrorComponents';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';

interface UserInfo {
  username: string;
  avatar: string;
  age: number;
  gender: string;
}

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

  @State showAccessibilityPanel: boolean = false;

  @State menuItems: MenuItem[] = [
    { icon: '📱', title: '设备绑定', color: '#1677FF', url: 'pages/DeviceDiscoveryPage' },
    { icon: '🎤', title: '语音助手', color: '#1677FF', url: 'pages/VoiceAssistantPage' },
    { icon: '📊', title: '健康统计', color: '#52C41A', url: 'pages/StatisticsPage' },
    { icon: '🏆', title: '社区排行榜', color: '#FAAD14', url: 'pages/RankingPage' },
    { icon: '📋', title: '我的病历', color: '#1677FF', url: 'pages/MedicalRecord' },
    { icon: '❤️', title: '我的收藏', color: '#FF4757', url: 'pages/MyCollectPage' },
    { icon: '♿', title: '无障碍设置', color: '#722ED1', url: '' },
    { icon: '⚙️', title: '账号设置', color: '#333333', url: '' },
    { icon: '🔒', title: '隐私与安全', color: '#1677FF', url: 'pages/PrivacySettingPage' },
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
    if (item.title === '无障碍设置') {
      this.showAccessibilityPanel = true;
      return;
    }
    if (item.url) {
      try {
        router.pushUrl({ url: item.url });
      } catch (e) {
        console.error('路由跳转失败:', e);
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Header({
          title: '个人中心',
          showBack: true,
          rightAction: {
            icon: '♿',
            label: '无障碍设置',
            onClick: () => {
              this.showAccessibilityPanel = true;
            }
          }
        });

        Scroll() {
          Column({ space: AccessibilityConfig.getSpacingLG() }) {
            Text('我的')
              .fontSize(AccessibilityConfig.getFontSizeTitle())
              .fontWeight(FontWeight.Bold)
              .fontColor(AccessibilityConfig.getThemeColor())
              .margin({
                top: AccessibilityConfig.getSpacingLG(),
                bottom: AccessibilityConfig.getSpacingMD()
              });

            Column({ space: AccessibilityConfig.getSpacingMD() }) {
              Row({ space: AccessibilityConfig.getSpacingMD() }) {
                Circle()
                  .width(80)
                  .height(80)
                  .fill('#4a90e220')
                  .stroke(AccessibilityConfig.getThemeColor());

                Column({ space: 8 }) {
                  Text('星云用户')
                    .fontSize(AccessibilityConfig.getFontSizeBody())
                    .fontWeight(FontWeight.Bold)
                    .fontColor(AccessibilityConfig.getTextPrimary());

                  Text('138****1234')
                    .fontSize(AccessibilityConfig.getFontSizeSmall())
                    .fontColor(AccessibilityConfig.getTextSecondary());
                }
                .alignItems(HorizontalAlign.Start);
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius(12)
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() });
            }

            Column({ space: 1 }) {
              Row({ space: AccessibilityConfig.getSpacingMD() }) {
                Text('👴 老年模式')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .fontWeight(FontWeight.Bold);

                Blank();

                Text(this.isElderMode ? '已开启' : '已关闭')
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(this.isElderMode ? AccessibilityConfig.getSuccessColor() : AccessibilityConfig.getTextHint())
                  .backgroundColor(this.isElderMode ? '#F6FFED' : '#F5F5F5')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(10);
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius({ topLeft: 12, topRight: 12 })
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
              .accessibilityText('老年模式，当前' + (this.isElderMode ? '已开启' : '已关闭'))
              .onClick(() => this.toggleElderMode());

              ForEach(this.menuItems, (item: MenuItem) => {
                Row({ space: AccessibilityConfig.getSpacingMD() }) {
                  Text(item.icon)
                    .fontSize(AccessibilityConfig.getFontSizeBody());

                  Text(item.title)
                    .fontSize(AccessibilityConfig.getFontSizeBody())
                    .fontColor(item.color)
                    .fontWeight(item.color === '#1677FF' || item.color === '#722ED1' ? FontWeight.Bold : FontWeight.Normal);

                  Blank();

                  Text('›')
                    .fontSize(28)
                    .fontColor(AccessibilityConfig.getTextHint());
                }
                .width('100%')
                .padding(AccessibilityConfig.getSpacingMD())
                .backgroundColor(AccessibilityConfig.getCardBgColor())
                .accessibilityText('' + item.title)
                .onClick(() => this.handleMenuClick(item));
              }, (item: MenuItem) => item.title);
            }
            .borderRadius(12)
            .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

            Button('退出登录')
              .width('100%')
              .height(AccessibilityConfig.getButtonHeight())
              .fontSize(AccessibilityConfig.getFontSizeButton())
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor(AccessibilityConfig.getThemeColor())
              .borderRadius(AccessibilityConfig.getButtonHeight() / 2)
              .shadow({
                radius: 8,
                color: '#1677FF30',
                offsetX: 0,
                offsetY: 4
              })
              .margin({
                top: AccessibilityConfig.getSpacingLG(),
                bottom: AccessibilityConfig.getSpacingLG()
              })
              .accessibilityText('退出登录按钮')
              .onClick(() => {
                try {
                  AppStorage.setOrCreate<boolean>('isLoggedIn', false);
                  AppStorage.setOrCreate<string>('token', '');
                  AppStorage.setOrCreate<UserInfo | null>('userInfo', null);
                  HttpUtil.clearToken();
                  ToastUtil.showInfo('已退出登录');
                  router.replaceUrl({ url: 'pages/Login' });
                } catch (error) {
                  console.error('退出登录失败:', error);
                }
              });
          }
          .width('85%')
          .padding({
            top: AccessibilityConfig.getSpacingLG(),
            bottom: AccessibilityConfig.getSpacingLG()
          });
        }
        .height(0)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top);

        Footer({ activeIndex: 4 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AccessibilityConfig.getBgColor());

      if (this.showAccessibilityPanel) {
        AccessibilitySettingsPanel({
          onDismiss: () => {
            this.showAccessibilityPanel = false;
          }
        });
      }
    }
    .width('100%')
    .height('100%');
  }
}
