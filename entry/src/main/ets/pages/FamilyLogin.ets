import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, RequestOptions } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface FamilyLoginResponseData {
  token: string;
  familyInfo: FamilyInfo;
  relatedUser: RelatedUser;
}

interface FamilyInfo {
  id: number;
  name: string;
  phone: string;
  relation: string;
  age?: number;
  gender?: number;
  healthCondition?: string;
  isEmergencyContact: number;
}

interface RelatedUser {
  id: number;
  username: string;
  realName?: string;
  phone?: string;
}

interface FamilyLoginRequestData {
  phone: string;
  password: string;
}

@Entry
@Component
struct FamilyLogin {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State showPassword: boolean = false;

  // 手机号验证正则
  private phoneRegex: RegExp = /^1[3-9]\d{9}$/;

  async aboutToAppear(): Promise<void> {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  // 验证手机号
  private validatePhone(): boolean {
    if (!this.phone) {
      this.phoneError = '请输入手机号';
      return false;
    }
    if (!this.phoneRegex.test(this.phone)) {
      this.phoneError = '手机号格式不正确';
      return false;
    }
    this.phoneError = '';
    return true;
  }

  // 验证密码
  private validatePassword(): boolean {
    if (!this.password) {
      this.passwordError = '请输入密码';
      return false;
    }
    if (this.password.length < 6) {
      this.passwordError = '密码长度不能少于6位';
      return false;
    }
    this.passwordError = '';
    return true;
  }

  // 处理登录
  private async handleLogin(): Promise<void> {
    // 验证输入
    const isPhoneValid = this.validatePhone();
    const isPasswordValid = this.validatePassword();

    if (!isPhoneValid || !isPasswordValid) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const requestData: FamilyLoginRequestData = {
        phone: this.phone,
        password: this.password
      };

      const options: RequestOptions = { skipAuth: true };
      const response = await HttpUtil.post<FamilyLoginResponseData>('/family/login', requestData, options);

      if (response.success && response.data) {
        // 保存Token和家属信息
        const settings = SettingsUtil.getInstance();
        await settings.saveFamilyToken(response.data.token);
        await settings.saveFamilyInfo(response.data.familyInfo);

        // 更新全局状态
        AppStorage.setOrCreate<string>('familyToken', response.data.token);
        AppStorage.setOrCreate<FamilyInfo>('familyInfo', response.data.familyInfo);
        AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', true);

        ToastUtil.showSuccess('登录成功');

        // 跳转到家属主页
        router.replaceUrl({
          url: 'pages/FamilyHome'
        });
      } else {
        this.errorMessage = response.message || '登录失败，请重试';
        ToastUtil.showError(this.errorMessage);
      }
    } catch (error) {
      console.error('家属登录失败:', error);
      this.errorMessage = '登录失败，请检查网络连接';
      ToastUtil.showError(this.errorMessage);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Header({ title: '家属登录' })

      // 主要内容区域
      Column() {
        // Logo和标题
        Column() {
          Image($r('app.media.startIcon'))
            .width(80)
            .height(80)
            .margin({ bottom: 20 })

          Text('家属登录')
            .fontSize(this.isElderMode ? 28 : 24)
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .margin({ bottom: 10 })

          Text('使用手机号和密码登录')
            .fontSize(this.isElderMode ? 18 : 14)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: 40 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 40 })

        // 登录表单
        Column() {
          // 手机号输入
          Column() {
            TextInput({ placeholder: '请输入手机号', text: this.phone })
              .type(InputType.PhoneNumber)
              .fontSize(this.isElderMode ? 20 : 16)
              .height(this.isElderMode ? 60 : 50)
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .padding({ left: 15, right: 15 })
              .onChange((value: string) => {
                this.phone = value;
                this.validatePhone();
              })

            if (this.phoneError) {
              Text(this.phoneError)
                .fontSize(12)
                .fontColor('#FF0000')
                .margin({ top: 5 })
            }
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 密码输入
          Column() {
            Row() {
              TextInput({ placeholder: '请输入密码', text: this.password })
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .fontSize(this.isElderMode ? 20 : 16)
                .height(this.isElderMode ? 60 : 50)
                .layoutWeight(1)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .padding({ left: 15, right: 15 })
                .onChange((value: string) => {
                  this.password = value;
                  this.validatePassword();
                })

              // 显示/隐藏密码按钮
              Button(this.showPassword ? '隐藏' : '显示')
                .fontSize(12)
                .height(30)
                .width(50)
                .margin({ left: 10 })
                .onClick(() => {
                  this.showPassword = !this.showPassword;
                })
            }
            .width('100%')

            if (this.passwordError) {
              Text(this.passwordError)
                .fontSize(12)
                .fontColor('#FF0000')
                .margin({ top: 5 })
            }
          }
          .width('100%')
          .margin({ bottom: 30 })

          // 错误提示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#FF0000')
              .margin({ bottom: 20 })
          }

          // 登录按钮
          Button('登录')
            .width('100%')
            .height(this.isElderMode ? 60 : 50)
            .fontSize(this.isElderMode ? 20 : 18)
            .fontColor('#FFFFFF')
            .backgroundColor(GlobalTheme.THEME_COLOR)
            .borderRadius(8)
            .enabled(!this.isLoading)
            .onClick(() => {
              this.handleLogin();
            })

          // 提示信息
          Text('家属登录功能需由用户在"家属管理"中开启')
            .fontSize(12)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ top: 20 })

          // 返回用户登录
          Button('用户登录')
            .fontSize(14)
            .fontColor(GlobalTheme.THEME_COLOR)
            .backgroundColor(Color.Transparent)
            .margin({ top: 20 })
            .onClick(() => {
              router.replaceUrl({
                url: 'pages/Login'
              });
            })
        }
        .width('85%')
        .padding(20)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')

      // Loading遮罩
      if (this.isLoading) {
        Loading()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
