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
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State showPassword: boolean = false;

  // 手机号验证正则：11位，1开头，第二位3-9
  private phoneRegex: RegExp = /^1[3-9]\d{9}$/;

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
            if (userInfo.userType === 1) {
              router.replaceUrl({ url: 'pages/DoctorHomePage' });
            } else {
              router.replaceUrl({ url: 'pages/HomePage' });
            }
          } else {
            router.replaceUrl({ url: 'pages/HomePage' });
          }
        }
      }
    } catch (error) {
      console.error('检查登录状态失败:', error);
    }
  }

  /**
   * 实时验证手机号
   */
  private validatePhone(): void {
    if (!this.username) {
      this.phoneError = '';
    } else if (!this.phoneRegex.test(this.username)) {
      this.phoneError = '请输入正确的11位手机号';
    } else {
      this.phoneError = '';
    }
  }

  /**
   * 实时验证密码
   */
  private validatePassword(): void {
    if (!this.password) {
      this.passwordError = '';
    } else if (this.password.length < 6 || this.password.length > 20) {
      this.passwordError = '密码长度为6-20位';
    } else {
      this.passwordError = '';
    }
  }

  /**
   * 检查表单是否有效
   */
  private isFormValid(): boolean {
    return this.phoneRegex.test(this.username) &&
           this.password.length >= 6 &&
           this.password.length <= 20;
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
            const userType: number | undefined = response.data?.userType;
            if (userType === 1) {
              router.replaceUrl({ url: 'pages/DoctorHomePage' });
            } else {
              router.replaceUrl({ url: 'pages/HomePage' });
            }
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

          // 手机号输入框
          Column({ space: 4 }) {
            Row() {
              Text('📱')
                .fontSize(16)
                .margin({ right: 8 });
              TextInput({ placeholder: '请输入手机号', text: this.username })
                .type(InputType.Number)
                .maxLength(11)
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .border({
                  width: 1,
                  color: this.phoneError ? '#F5222D' : '#E8ECF2',
                  style: BorderStyle.Solid
                })
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => {
                  this.username = value;
                  this.validatePhone();
                });
              if (this.username) {
                Button({ type: ButtonType.Circle }) {
                  Text('✕')
                    .fontSize(14)
                    .fontColor('#999999');
                }
                .width(24)
                .height(24)
                .backgroundColor('#F5F5F5')
                .margin({ left: 8 })
                .onClick(() => {
                  this.username = '';
                  this.phoneError = '';
                });
              }
            }
            .width('100%');

            if (this.phoneError) {
              Text(this.phoneError)
                .fontSize(12)
                .fontColor('#F5222D')
                .margin({ left: 24 });
            }
          }
          .width('100%');

          // 密码输入框
          Column({ space: 4 }) {
            Row() {
              Text('🔒')
                .fontSize(16)
                .margin({ right: 8 });
              TextInput({ placeholder: '请输入密码', text: this.password })
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .maxLength(20)
                .layoutWeight(1)
                .height(44)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .border({
                  width: 1,
                  color: this.passwordError ? '#F5222D' : '#E8ECF2',
                  style: BorderStyle.Solid
                })
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => {
                  this.password = value;
                  this.validatePassword();
                });
              Button({ type: ButtonType.Circle }) {
                Text(this.showPassword ? '👁️' : '👁️‍🗨️')
                  .fontSize(14);
              }
              .width(24)
              .height(24)
              .backgroundColor('#F5F5F5')
              .margin({ left: 8 })
              .onClick(() => {
                this.showPassword = !this.showPassword;
              });
            }
            .width('100%');

            if (this.passwordError) {
              Text(this.passwordError)
                .fontSize(12)
                .fontColor('#F5222D')
                .margin({ left: 24 });
            }
          }
          .width('100%');

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
            Button(this.isLoading ? '登录中...' : '登 录')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor(this.isFormValid() ? GlobalTheme.BUTTON_TEXT_COLOR : '#999999')
              .backgroundColor(this.isFormValid() ? GlobalTheme.THEME_COLOR : '#CCCCCC')
              .borderRadius(GlobalTheme.RADIUS_MD)
              .enabled(this.isFormValid() && !this.isLoading)
              .shadow({
                radius: 12,
                color: this.isFormValid() ? '#1677FF44' : '#00000000',
                offsetX: 0,
                offsetY: 6
              })
              .onClick(async () => await this.handleLogin());
          }

          Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
            Text('忘记密码？')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.THEME_COLOR)
              .onClick(() => {
                ToastUtil.showInfo('请联系客服重置密码', 2000);
              });

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