import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';

interface LoginResponseData {
  token: string;
  userId?: number;
  username?: string;
  userType?: number;
  userInfo?: PersistedUserInfo;
}

interface LoginRequestData {
  username: string;
  password: string;
}

function createPersistedUserInfo(
  userId?: number,
  username: string = '',
  userType?: number,
  avatar: string = '',
  age?: number,
  gender?: string
): PersistedUserInfo {
  return {
    userId: userId,
    username: username,
    userType: userType,
    avatar: avatar,
    age: age,
    gender: gender
  };
}

@Entry
@Component
struct Login {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  async aboutToAppear(): Promise<void> {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    try {
      const settings: SettingsUtil = SettingsUtil.getInstance();
      const isLoggedIn: boolean = await settings.isLoggedIn();
      if (isLoggedIn) {
        const token: string = await settings.getToken();
        if (token && token.length > 0) {
          AppStorage.setOrCreate<string>('token', token);
          AppStorage.setOrCreate<boolean>('isLoggedIn', true);
          const userInfo: PersistedUserInfo | null = await settings.getUserInfo();
          if (userInfo) {
            AppStorage.setOrCreate<PersistedUserInfo | null>('userInfo', userInfo);
            AppStorage.setOrCreate<string>('username', userInfo.username || '');
            if (userInfo.userId) {
              AppStorage.setOrCreate<number>('userId', userInfo.userId);
            }
          }
          router.replaceUrl({ url: 'pages/HomePage' });
        }
      }
    } catch (error) {
      console.error('检查登录状态失败:', error);
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
        if (response.data && response.data.token) {
          try {
            await HttpUtil.saveToken(response.data.token);
          } catch (error) {
            console.error('保存Token失败:', error);
          }
        }

        if (response.data) {
          try {
            const settings: SettingsUtil = SettingsUtil.getInstance();
            let userInfo: PersistedUserInfo;
            if (response.data.userInfo) {
              userInfo = response.data.userInfo;
            } else {
              userInfo = createPersistedUserInfo(
                response.data.userId,
                response.data.username || '',
                response.data.userType,
                '',
                undefined,
                undefined
              );
            }
            await settings.saveUserInfo(userInfo);
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
          // 渐变头部区域
          Column() {
            Text('🏥')
              .fontSize(48)
              .margin({ bottom: 16 });
            Text('星云医疗助手')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#FFFFFF')
              .margin({ bottom: 8 });
            Text('欢迎回来，请登录您的账号')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor('#FFFFFFCC')
          }
          .width('100%')
          .padding({ top: 40, bottom: 36 })
          .linearGradient({
            angle: 135,
            colors: [['#1677FF', 0], ['#36CFC9', 1]]
          })
          .borderRadius({ bottomLeft: 32, bottomRight: 32 })
          .margin({ top: -GlobalTheme.getSpacingLG(this.isElderMode), left: -GlobalTheme.getSpacingMD(this.isElderMode), right: -GlobalTheme.getSpacingMD(this.isElderMode) });

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
            Row() {
              Text('⚠️ ')
                .fontSize(14)
                .fontColor(GlobalTheme.ERROR_COLOR);
              Text(this.errorMessage)
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.ERROR_COLOR);
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFF2F0')
            .borderRadius(10)
            .border({ width: 1, color: '#FFCCC7', style: BorderStyle.Solid });
          }

          if (this.isLoading) {
            Loading();
          } else {
            Button('登 录')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .shadow({
                radius: 12,
                color: '#1677FF44',
                offsetX: 0,
                offsetY: 6
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

          // 演示账号提示卡片
          Row({ space: 8 }) {
            Text('💡')
              .fontSize(16);
            Column({ space: 2 }) {
              Text('演示账号')
                .fontSize(12)
                .fontWeight('bold')
                .fontColor('#666666');
              Text('138****1234 / 密码：123456')
                .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                .fontColor('#999999');
            }
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%')
          .padding(14)
          .backgroundColor('#FAFBFF')
          .borderRadius(10)
          .border({ width: 1, color: '#E8ECF2', style: BorderStyle.Solid });

          // 功能亮点
          Row({ space: 0 }) {
            Column({ space: 6 }) {
              Text('🔒')
                .fontSize(24);
              Text('安全加密')
                .fontSize(11)
                .fontColor('#666666');
            }
            .layoutWeight(1);

            Column({ space: 6 }) {
              Text('🤖')
                .fontSize(24);
              Text('AI智能')
                .fontSize(11)
                .fontColor('#666666');
            }
            .layoutWeight(1);

            Column({ space: 6 }) {
              Text('👨‍⚕️')
                .fontSize(24);
              Text('专业医生')
                .fontSize(11)
                .fontColor('#666666');
            }
            .layoutWeight(1);

            Column({ space: 6 }) {
              Text('📊')
                .fontSize(24);
              Text('健康追踪')
                .fontSize(11)
                .fontColor('#666666');
            }
            .layoutWeight(1);
          }
          .width('100%')
          .padding({ top: 20, bottom: 8 })
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