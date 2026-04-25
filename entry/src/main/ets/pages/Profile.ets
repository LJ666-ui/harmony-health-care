import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { AccessibilitySettingsPanel, FirstTimeGuide } from '../components/GuideComponents';
import { NetworkStatusBanner } from '../components/ErrorComponents';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

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
            // 渐变用户信息卡片
            Stack({ alignContent: Alignment.BottomStart }) {
              Column()
                .width('100%')
                .height(140)
                .linearGradient({
                  angle: 135,
                  colors: [['#1677FF', 0], ['#36CFC9', 1]]
                })
                .borderRadius({ topLeft: 20, topRight: 20, bottomLeft: 16, bottomRight: 16 });

              Row({ space: 16 }) {
                Circle()
                  .width(64)
                  .height(64)
                  .fill('#FFFFFF33')
                  .stroke('#FFFFFF')
                  .strokeWidth(3);

                Column({ space: 6 }) {
                  Text('星云用户')
                    .fontSize(AccessibilityConfig.getFontSizeTitle())
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF');

                  Row({ space: 8 }) {
                    Text('138****1234')
                      .fontSize(AccessibilityConfig.getFontSizeSmall())
                      .fontColor('#FFFFFFCC');
                    Text('ID: 10086')
                      .fontSize(10)
                      .fontColor('#FFFFFF66')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor('#FFFFFF22')
                      .borderRadius(10);
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                Column() {
                  Text('编辑')
                    .fontSize(12)
                    .fontColor('#FFFFFF');
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#FFFFFF22')
                .borderRadius(14);
              }
              .width('90%')
              .padding({ left: 20, right: 0, bottom: 20 });
            }
            .width('85%')
            .margin({ top: AccessibilityConfig.getSpacingMD(), bottom: AccessibilityConfig.getSpacingMD() });

            // 统计数据行
            Row() {
              Column({ space: 4 }) {
                Text('128')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1677FF');
                Text('健康天数')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .layoutWeight(1);

              Line().width(1).height(32).stroke('#EEEEEE');

              Column({ space: 4 }) {
                Text('12')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#52C41A');
                Text('评估次数')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .layoutWeight(1);

              Line().width(1).height(32).stroke('#EEEEEE');

              Column({ space: 4 }) {
                Text('5')
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FAAD14');
                Text('收藏文章')
                  .fontSize(11)
                  .fontColor('#999999');
              }
              .layoutWeight(1);
            }
            .width('85%')
            .height(80)
            .padding({ left: 24, right: 24 })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 8, color: '#00000006', offsetX: 0, offsetY: 3 })
            .margin({ bottom: AccessibilityConfig.getSpacingMD() });

            // 功能菜单列表
            Column({ space: 1 }) {
              Row({ space: AccessibilityConfig.getSpacingMD() }) {
                Text('👴 老年模式')
                  .fontSize(AccessibilityConfig.getFontSizeBody())
                  .fontColor(AccessibilityConfig.getTextPrimary())
                  .fontWeight(FontWeight.Bold);

                Blank();

                Text(this.isElderMode ? '已开启' : '已关闭')
                  .fontSize(AccessibilityConfig.getFontSizeSmall())
                  .fontColor(this.isElderMode ? '#52C41A' : '#999999')
                  .backgroundColor(this.isElderMode ? '#F6FFED' : '#F5F5F5')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(10);
              }
              .width('100%')
              .padding(AccessibilityConfig.getSpacingMD())
              .backgroundColor(AccessibilityConfig.getCardBgColor())
              .borderRadius({ topLeft: 16, topRight: 16 })
              .border({ width: 1, color: AccessibilityConfig.getBorderColor() })
              .accessibilityText('老年模式，当前' + (this.isElderMode ? '已开启' : '已关闭'))
              .onClick(() => this.toggleElderMode());

              ForEach(this.menuItems, (item: MenuItem) => {
                Row({ space: AccessibilityConfig.getSpacingMD() }) {
                  Text(item.icon)
                    .fontSize(18)
                    .width(28)
                    .textAlign(TextAlign.Center);

                  Text(item.title)
                    .fontSize(AccessibilityConfig.getFontSizeBody())
                    .fontColor(item.color === '#333333' ? AccessibilityConfig.getTextPrimary() : item.color)
                    .fontWeight(item.color === '#1677FF' || item.color === '#722ED1' || item.color === '#52C41A' || item.color === '#FAAD14' || item.color === '#FF4757' ? FontWeight.Bold : FontWeight.Normal);

                  Blank();

                  Text('›')
                    .fontSize(20)
                    .fontColor('#CCCCCC');
                }
                .width('100%')
                .padding(AccessibilityConfig.getSpacingMD())
                .backgroundColor(AccessibilityConfig.getCardBgColor())
                .accessibilityText('' + item.title)
                .onClick(() => this.handleMenuClick(item));
              }, (item: MenuItem) => item.title);
            }
            .borderRadius(16)
            .border({ width: 1, color: AccessibilityConfig.getBorderColor() });

            Button('退出登录')
              .width('85%')
              .height(AccessibilityConfig.getButtonHeight())
              .fontSize(AccessibilityConfig.getFontSizeButton())
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF4D4F')
              .backgroundColor('#FFF1F0')
              .borderRadius(AccessibilityConfig.getButtonHeight() / 2)
              .border({ width: 1, color: '#FFCCC7', style: BorderStyle.Solid })
              .margin({
                top: AccessibilityConfig.getSpacingLG(),
                bottom: AccessibilityConfig.getSpacingLG()
              })
              .accessibilityText('退出登录按钮')
              .onClick(async () => {
                try {
                  const settings: SettingsUtil = SettingsUtil.getInstance();
                  await settings.clearAllLoginData();
                  ToastUtil.showInfo('已退出登录');
                  router.replaceUrl({ url: 'pages/Login' });
                } catch (error) {
                  console.error('退出登录失败:', error);
                }
              });
          }
          .width('85%')
          .padding({
            top: AccessibilityConfig.getSpacingMD(),
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
