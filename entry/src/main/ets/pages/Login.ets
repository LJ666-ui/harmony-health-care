import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
interface UserInfo {
  userId?: number;
  username: string;
  userType?: number;
  avatar?: string;
  age?: number;
  gender?: string;
}
interface LoginResponseData {
  token: string;
  userId?: number;
  username?: string;
  userType?: number;
  userInfo?: UserInfo;
}

interface LoginRequestData {
  username: string;
  password: string;
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
      try {
        router.replaceUrl({ url: 'pages/HomePage' });
      } catch (error) {
        console.error('跳转首页失败:', error);
      }
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

  async handleLogin(): Promise<void> {
    if (!this.validateForm()) {
      ToastUtil.showError(this.errorMessage, 2000);
      return;
    }

    this.isLoading = true;

    try {
      const loginRequest: LoginRequestData = {
        username: this.username,
        password: this.password
      };
      const response: BaseResponse<LoginResponseData> = await HttpUtil.post<LoginResponseData>('/user/login', loginRequest);

      if (response.success) {
        // 保存Token到AppStorage
        if (response.data && response.data.token) {
          try {
            AppStorage.setOrCreate<string>('token', response.data.token);
            HttpUtil.saveToken(response.data.token);
          } catch (error) {
            console.error('保存Token失败:', error);
          }
        }

        // 保存用户信息
        if (response.data) {
          try {
            const userInfo: UserInfo = response.data.userInfo || {
              userId: response.data.userId,
              username: response.data.username || '',
              userType: response.data.userType,
              avatar: '',
              age: undefined,
              gender: undefined
            } as UserInfo;
            AppStorage.setOrCreate<UserInfo>('userInfo', userInfo);
            AppStorage.setOrCreate<string>('username', userInfo.username || '');
            if (userInfo.userId) {
              AppStorage.setOrCreate<number>('userId', userInfo.userId);
            }
          } catch (error) {
            console.error('保存用户信息失败:', error);
          }
        }

        try {
          AppStorage.setOrCreate<boolean>('isLoggedIn', true);
        } catch (error) {
          console.error('保存登录状态失败:', error);
        }

        ToastUtil.loginSuccess();

        setTimeout(() => {
          try {
            router.replaceUrl({ url: 'pages/HomePage' });
          } catch (error) {
            console.error('跳转首页失败:', error);
          }
        }, 500);
      } else {
        this.errorMessage = response.message || '登录失败';
        ToastUtil.showError(this.errorMessage, 2000);
      }
    } catch (error) {
      this.errorMessage = '网络请求失败，请稍后重试';
      ToastUtil.showError(this.errorMessage, 2000);
    } finally {
      this.isLoading = false;
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
            text: $username
          })

          Input({
            placeholder: '请输入密码',
            inputType: 'password',
            text: $password
          })

          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.ERROR_COLOR)
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
              .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .shadow({
                radius: 8,
                color: '#1677FF30',
                offsetX: 0,
                offsetY: 4
              })
              .onClick(async () => await this.handleLogin());
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
              .onClick(() => {
                try {
                  router.pushUrl({ url: 'pages/Register' });
                } catch (error) {
                  console.error('跳转注册页失败:', error);
                }
              });
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
