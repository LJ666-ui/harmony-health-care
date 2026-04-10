import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';
import { GlobalTheme } from '../global';

@Entry
@Component
struct Login {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State username: string = '';
  @State password: string = '';

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  handleLogin(): void {
    if (this.username && this.password) {
      router.pushUrl({ url: 'pages/HomePage' });
    }
  }

  build() {
    Column() {
      Header({
        title: '登录',
        showBack: true
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('星云医疗助手')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: this.isElderMode ? 36 : 24, bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Text('欢迎回来，请登录您的账号')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });

          Input({
            placeholder: '请输入手机号/账号',
            inputType: 'text',
            text: $username,
            onChange: (value) => {
              this.username = value;
            }
          })

          Input({
            placeholder: '请输入密码',
            inputType: 'password',
            text: $password,
            onChange: (value) => {
              this.password = value;
            }
          })

          Button('登录')
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
            .onClick(() => this.handleLogin());

          Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
            Text('忘记密码？')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.THEME_COLOR)
              .onClick(() => console.log('忘记密码'));

            Blank();

            Text('新用户注册')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.THEME_COLOR)
              .onClick(() => console.log('注册'));
          }
          .width('100%');

          Text('演示账号：138****1234 / 密码：123456')
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor('#999999')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#F5F5F5')
            .borderRadius(8);
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
