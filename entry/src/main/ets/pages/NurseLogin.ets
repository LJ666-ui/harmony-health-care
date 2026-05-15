import { router } from '@kit.ArkUI';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, RequestOptions } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

interface NurseLoginResponseData {
  token: string;
  nurseInfo: NurseInfo;
  relatedUser: RelatedUser;
}

interface NurseInfo {
  id: number;
  userId: number;
  nurseNo: string;
  name: string;
  phone: string;
  department: string;
  title: string;
  avatar: string;
  status: number;
}

interface RelatedUser {
  id: number;
  username: string;
  phone?: string;
}

interface NurseLoginRequestData {
  phone: string;
  password: string;
}

@Entry
@Component
struct NurseLogin {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State showPassword: boolean = false;

  private phoneRegex: RegExp = /^1[3-9]\d{9}$/;

  async aboutToAppear(): Promise<void> {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    
    AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
  }

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

  private async handleLogin(): Promise<void> {
    const isPhoneValid = this.validatePhone();
    const isPasswordValid = this.validatePassword();

    if (!isPhoneValid || !isPasswordValid) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      console.log('[NurseLogin] 开始登录请求...');
      console.log('[NurseLogin] 手机号:', this.phone);

      const requestData: NurseLoginRequestData = {
        phone: this.phone,
        password: this.password
      };

      const options: RequestOptions = { skipAuth: true };

      console.log('[NurseLogin] 发送POST请求到 /nurse/login');
      const response = await HttpUtil.post<NurseLoginResponseData>('/nurse/login', requestData, options);

      console.log('[NurseLogin] 收到响应:', JSON.stringify(response));
      console.log('[NurseLogin] success:', response.success);
      console.log('[NurseLogin] data:', response.data ? '存在' : '不存在');
      console.log('[NurseLogin] message:', response.message);

      if (response.success && response.data) {
        console.log('[NurseLogin] 登录成功，保存Token和护士信息...');

        const settings = SettingsUtil.getInstance();
        await settings.saveNurseToken(response.data.token);
        await settings.saveNurseInfo(response.data.nurseInfo);

        AppStorage.setOrCreate<string>('nurseToken', response.data.token);
        AppStorage.setOrCreate<NurseInfo>('nurseInfo', response.data.nurseInfo);
        AppStorage.setOrCreate<boolean>('isNurseLoggedIn', true);
        AppStorage.setOrCreate<boolean>('isLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isAdminLoggedIn', false);

        const nurseId: number = response.data.nurseInfo.id || 0;
        const userId: number = response.data.nurseInfo.userId || 0;
        console.log('[NurseLogin] 护士信息 - nurseId:', nurseId, ', userId:', userId);

        AppStorage.setOrCreate<number>('userId', userId);
        AppStorage.setOrCreate<number>('nurseId', nurseId);
        AppStorage.setOrCreate<number>('userAccountId', userId);

        ToastUtil.showSuccess('登录成功');
        console.log('[NurseLogin] 准备跳转到护士工作台...');

        router.replaceUrl({
          url: 'pages/NurseWorkbench'
        });
      } else {
        console.error('[NurseLogin] 登录失败:', response.message);
        this.errorMessage = response.message || '登录失败，请重试';
        ToastUtil.showError(this.errorMessage);
      }
    } catch (error) {
      console.error('[NurseLogin] 护士登录异常:', error);
      this.errorMessage = '登录失败，请检查网络连接';
      ToastUtil.showError(this.errorMessage);
    } finally {
      console.log('[NurseLogin] 登录请求结束，isLoading设为false');
      this.isLoading = false;
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Image($r('app.media.111'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .position({ x: 0, y: 0 });

        Column() {
          Column() {
            Image($r('app.media.startIcon'))
              .width(70)
              .height(70)
              .margin({ bottom: 20 })
              .borderRadius(16)

            Text('护士登录')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ bottom: 8 })

            Text('使用手机号和密码登录')
              .fontSize(14)
              .fontColor('#FFFFFF90')
              .margin({ bottom: 10 })
          }
          .width('100%')
          .height(280)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#1a2942')
          .borderRadius({ bottomLeft: 40, bottomRight: 40 })

          Column() {
            TextInput({ placeholder: '请输入手机号', text: this.phone })
              .type(InputType.PhoneNumber)
              .fontSize(16)
              .height(52)
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.phone = value;
                this.validatePhone();
              })
              .margin({ top: 30, bottom: 16 })

            TextInput({ placeholder: '请输入密码', text: this.password })
              .type(InputType.Password)
              .fontSize(16)
              .height(52)
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.password = value;
                this.validatePassword();
              })
              .margin({ bottom: 24 })

            if (this.errorMessage) {
              Text(this.errorMessage)
                .fontSize(13)
                .fontColor('#F5222D')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ bottom: 16 })
            }

            Button(this.isLoading ? '登录中...' : '登 录')
              .width('100%')
              .height(52)
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .backgroundColor('#1a2942')
              .borderRadius(12)
              .enabled(!this.isLoading)
              .onClick(() => {
                this.handleLogin();
              })

            Text('演示账号：admin / admin123')
              .fontSize(12)
              .fontColor('#94A3B8')
              .margin({ top: 24, bottom: 20 })

            Button() {
              Row() {
                Text('← ')
                  .fontSize(15)
                  .fontColor('#1677FF')
                Text('返回用户端')
                  .fontSize(15)
                  .fontColor('#1677FF')
              }
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              router.replaceUrl({
                url: 'pages/Login'
              });
            })
          }
          .width('88%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')

        if (this.isLoading) {
          Loading()
        }
      }
      .width('100%')
      .height('100%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F4F8');
  }
}