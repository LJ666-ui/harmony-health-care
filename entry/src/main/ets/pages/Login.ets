import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface UserInfo {
  username: string;
  avatar: string;
  age: number;
  gender: string;
}

@Entry
@Component
struct Login {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    const isLoggedIn = AppStorage.get<boolean>('isLoggedIn');
    if (isLoggedIn) {
      router.replaceUrl({ url: 'pages/HomePage' });
    }
  }

  validateForm(): boolean {
    this.errorMessage = '';

    if (!this.username || this.username.trim() === '') {
      this.errorMessage = '请输入账号';
      return false;
    }

    if (!this.password || this.password.trim() === '') {
      this.errorMessage = '请输入密码';
      return false;
    }

    if (this.password.length < 6) {
      this.errorMessage = '密码长度不能少于6位';
      return false;
    }

    return true;
  }

  handleLogin(): void {
    if (!this.validateForm()) {
      ToastUtil.showError(this.errorMessage, 2000);
      return;
    }

    this.isLoading = true;

    setTimeout(() => {
      const mockUserInfo: UserInfo = {
        username: '张三',
        avatar: '',
        age: 65,
        gender: '男'
      };

      AppStorage.setOrCreate<UserInfo>('userInfo', mockUserInfo);
      AppStorage.setOrCreate<boolean>('isLoggedIn', true);

      ToastUtil.loginSuccess();

      setTimeout(() => {
        router.replaceUrl({ url: 'pages/HomePage' });
      }, 500);
    }, 1500);
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
              this.errorMessage = '';
            }
          })

          Input({
            placeholder: '请输入密码',
            inputType: 'password',
            text: $password,
            onChange: (value) => {
              this.password = value;
              this.errorMessage = '';
            }
          })

          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#FF4D4F')
              .width('100%')
              .padding(8)
              .backgroundColor('#FFF2F0')
              .borderRadius(8)
              .textAlign(TextAlign.Center);
          }

          if (this.isLoading) {
            Loading();
          } else {
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
          }

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
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
