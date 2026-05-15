import { router } from '@kit.ArkUI';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, RequestOptions } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';
import { DoctorInfo, DoctorInfoHelper } from '../models/DoctorModel';

interface DoctorLoginResponseData {
  token: string;
  doctorInfo: DoctorInfo;
}

interface DoctorLoginRequestData {
  phone: string;
  password: string;
}

@Entry
@Component
struct DoctorLogin {
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
    this.errorMessage = '';
    this.phoneError = '';
    this.passwordError = '';

    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }

    const isDoctorLoggedIn: boolean = AppStorage.get<boolean>('isDoctorLoggedIn') || false;
    const doctorToken: string | undefined = AppStorage.get<string>('doctorToken');
    if (isDoctorLoggedIn && doctorToken && doctorToken.length > 0) {
      router.replaceUrl({ url: 'pages/DoctorMainPage' });
      return;
    }
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
      const requestData: DoctorLoginRequestData = {
        phone: this.phone,
        password: this.password
      };

      const options: RequestOptions = { skipAuth: true };
      const response = await HttpUtil.post<DoctorLoginResponseData>('/doctor/login', requestData, options);

      if (response.success && response.data) {
        const settings = SettingsUtil.getInstance();

        let doctorInfo: DoctorInfo = new DoctorInfo();
        if (response.data.doctorInfo) {
          const rawDoctorInfo: Record<string, Object> =
            JSON.parse(JSON.stringify(response.data.doctorInfo));
          doctorInfo = DoctorInfoHelper.fromJson(rawDoctorInfo);
        }

        await settings.saveDoctorToken(response.data.token);
        await settings.saveDoctorInfo(doctorInfo);

        AppStorage.setOrCreate<string>('doctorToken', response.data.token);
        AppStorage.setOrCreate<DoctorInfo>('doctorInfo', doctorInfo);
        AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', true);

        AppStorage.setOrCreate<boolean>('isLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isAdminLoggedIn', false);

        if (doctorInfo.userId) {
          AppStorage.setOrCreate<number>('userId', doctorInfo.userId);
        }
        if (doctorInfo.id) {
          AppStorage.setOrCreate<number>('doctorId', doctorInfo.id);
        }

        ToastUtil.showSuccess('登录成功');

        setTimeout(() => {
          router.replaceUrl({
            url: 'pages/DoctorMainPage'
          });
        }, 300);
      } else {
        this.errorMessage = response.message || '登录失败，请重试';
        ToastUtil.showError(this.errorMessage);
      }
    } catch (error) {
      console.error('医生登录失败:', error);
      this.errorMessage = '登录失败，请检查网络连接';
      ToastUtil.showError(this.errorMessage);
    } finally {
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

        Scroll() {
          Column() {
            Column() {
              Image($r('app.media.startIcon'))
                .width(70)
                .height(70)
                .margin({ bottom: 20 })
                .borderRadius(16)

              Text('医生登录')
                .fontSize(this.isElderMode ? 28 : 24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ bottom: 8 })

              Text('使用手机号和密码登录')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#FFFFFF90')
            }
            .width('100%')
            .height(this.isElderMode ? 300 : 260)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#1a2942')
            .borderRadius({ bottomLeft: 40, bottomRight: 40 })

            Column() {
              Text('手机号')
                .fontSize(this.isElderMode ? 15 : 14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ top: 30, bottom: 8 })

              Row() {
                TextInput({ placeholder: '请输入11位手机号', text: this.phone })
                  .type(InputType.PhoneNumber)
                  .fontSize(this.isElderMode ? 17 : 15)
                  .height(52)
                  .layoutWeight(1)
                  .backgroundColor('#F8FAFC')
                  .borderRadius(10)
                  .padding({ left: 16, right: 12 })
                  .onChange((value: string) => {
                    this.phone = value.trim();
                    if (this.phoneError) {
                      this.validatePhone();
                    }
                  })
              }
              .width('100%')
              .backgroundColor('#F8FAFC')
              .borderRadius(10)
              .border({
                width: 1.5,
                color: this.phoneError ? '#F5222D' : '#E2E8F0'
              })

              if (this.phoneError) {
                Text(this.phoneError)
                  .fontSize(this.isElderMode ? 13 : 12)
                  .fontColor('#F5222D')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ top: 4 })
              }

              Text('密码')
                .fontSize(this.isElderMode ? 15 : 14)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .textAlign(TextAlign.Start)
                .margin({ top: 18, bottom: 8 })

              Row() {
                TextInput({ placeholder: '请输入登录密码', text: this.password })
                  .type(this.showPassword ? InputType.Normal : InputType.Password)
                  .fontSize(this.isElderMode ? 17 : 15)
                  .height(52)
                  .layoutWeight(1)
                  .backgroundColor('#F8FAFC')
                  .borderRadius(10)
                  .padding({ left: 16, right: 44 })
                  .onChange((value: string) => {
                    this.password = value;
                    if (this.passwordError) {
                      this.validatePassword();
                    }
                  })

                Button() {
                  Text(this.showPassword ? '🙈' : '👁️')
                    .fontSize(18)
                }
                .type(ButtonType.Normal)
                .width(40)
                .height(40)
                .backgroundColor(Color.Transparent)
                .position({ x: '100%', y: '50%' })
                .translate({ x: -46, y: '-50%' })
                .onClick(() => {
                  this.showPassword = !this.showPassword;
                })
              }
              .width('100%')
              .height(52)
              .backgroundColor('#F8FAFC')
              .borderRadius(10)
              .border({
                width: 1.5,
                color: this.passwordError ? '#F5222D' : '#E2E8F0'
              })

              if (this.passwordError) {
                Text(this.passwordError)
                  .fontSize(this.isElderMode ? 13 : 12)
                  .fontColor('#F5222D')
                  .width('100%')
                  .textAlign(TextAlign.Start)
                  .margin({ top: 4 })
              }

              if (this.errorMessage && !this.phoneError && !this.passwordError) {
                Row() {
                  Text('⚠️ ')
                    .fontSize(14)
                  Text(this.errorMessage)
                    .fontSize(this.isElderMode ? 14 : 13)
                    .fontColor('#F5222D')
                }
                .width('100%')
                .padding({ top: 10, bottom: 10, left: 14, right: 14 })
                .backgroundColor('#FFF2F0')
                .borderRadius(8)
                .margin({ top: 8 })
              }

              Button(this.isLoading ? '登录中...' : '登 录')
                .width('100%')
                .height(this.isElderMode ? 56 : 52)
                .fontSize(this.isElderMode ? 18 : 17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .backgroundColor(this.isLoading ? '#94A3B8' : '#1a2942')
                .borderRadius(12)
                .enabled(!this.isLoading)
                .onClick(() => {
                  this.handleLogin();
                })
                .margin({ top: 24 })

              Text('首次登录请联系管理员开通账号')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#94A3B8')
                .margin({ top: 20, bottom: 16 })
                .textAlign(TextAlign.Center)

              Button() {
                Row() {
                  Text('← 返回用户端')
                    .fontSize(this.isElderMode ? 16 : 15)
                    .fontColor('#1677FF')
                }
              }
              .type(ButtonType.Normal)
              .height(42)
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: '#91D5FF', style: BorderStyle.Solid })
              .borderRadius(21)
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
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)

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
