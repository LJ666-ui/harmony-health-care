import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';

interface RegisterRequestData {
  username: string;
  password: string;
  userType?: number;
}

interface RegisterResponseData {
  userId: number;
  message: string;
}

@Entry
@Component
struct Register {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  validateForm(): boolean {
    this.errorMessage = '';

    if (!this.username || this.username.trim() === '') {
      this.errorMessage = '请输入账号';
      return false;
    }

    if (this.username.length < 3 || this.username.length > 20) {
      this.errorMessage = '账号长度应在3-20位之间';
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

    if (this.password !== this.confirmPassword) {
      this.errorMessage = '两次密码输入不一致';
      return false;
    }

    return true;
  }

  async handleRegister(): Promise<void> {
    if (!this.validateForm()) {
      ToastUtil.showError(this.errorMessage, 2000);
      return;
    }

    this.isLoading = true;

    try {
      const registerRequest: RegisterRequestData = {
        username: this.username,
        password: this.password,
        userType: 0
      };

      const response: BaseResponse<RegisterResponseData> = await HttpUtil.post<RegisterResponseData>('/user/register', registerRequest);

      if (response.success) {
        ToastUtil.showSuccess('注册成功，请登录');

        setTimeout(() => {
          try {
            router.back();
          } catch (error) {
            console.error('返回登录页失败:', error);
          }
        }, 1000);
      } else {
        this.errorMessage = response.message || '注册失败';
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
        title: '注册',
        showBack: true
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('创建新账号')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: this.isElderMode ? 36 : 24, bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Text('请填写以下信息完成注册')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });

          Input({
            placeholder: '请输入账号(3-20位)',
            inputType: 'text',
            text: $username
          })

          Input({
            placeholder: '请输入密码(至少6位)',
            inputType: 'password',
            text: $password
          })

          Input({
            placeholder: '请再次输入密码',
            inputType: 'password',
            text: $confirmPassword
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
            Button('注册')
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
              .onClick(async () => await this.handleRegister());
          }

          Row() {
            Text('已有账号？')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor('#666666');

            Text('去登录')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.THEME_COLOR)
              .onClick(() => {
                try {
                  router.back();
                } catch (error) {
                  console.error('返回登录页失败:', error);
                }
              });
          }
          .width('100%')
          .justifyContent(FlexAlign.Center);
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
