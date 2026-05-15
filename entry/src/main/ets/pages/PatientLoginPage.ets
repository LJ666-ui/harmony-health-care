import { router } from '@kit.ArkUI';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, RequestOptions } from '../common/utils/HttpUtil';
import { SettingsUtil, PersistedUserInfo, PersistedDoctorInfo } from '../utils/SettingsUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import EventPersistenceManager from '../utils/EventPersistenceManager';

interface LoginResponseData {
  token: string;
  userId?: number;
  username?: string;
  userType?: number;
  userInfo?: PersistedUserInfo;
}

interface LoginRequestData {
  phone: string;
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
struct PatientLoginPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showPassword: boolean = false;

  private phoneRegex: RegExp = /^1[3-9]\d{9}$/;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  private isFormValid(): boolean {
    return this.phoneRegex.test(this.username) && this.password.length >= 6 && this.password.length <= 20;
  }

  private validateForm(): boolean {
    if (!this.username || this.username.trim() === '') {
      this.errorMessage = '请输入手机号';
      return false;
    }
    if (!this.phoneRegex.test(this.username)) {
      this.errorMessage = '请输入正确的11位手机号';
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
        phone: this.username,
        password: this.password
      };
      const response: BaseResponse<LoginResponseData> = await HttpUtil.post<LoginResponseData>(
        '/user/login',
        loginRequest,
        {
          showLoading: true,
          loadingText: '登录中...',
          retryCount: 1
        }
      );

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

            if (userInfo.userType === 1 && userInfo.userId) {
              try {
                const doctorInfoUrl: string = ApiConstants.DOCTOR_INFO + userInfo.userId;
                const doctorResp: BaseResponse<Object> = await HttpUtil.get<Object>(doctorInfoUrl);
                if (doctorResp.success && doctorResp.data) {
                  const raw: Record<string, Object> = doctorResp.data as Record<string, Object>;
                  const doctorInfo: PersistedDoctorInfo = {};
                  if (raw['id'] !== undefined) { doctorInfo.id = raw['id'] as number; }
                  if (raw['realName'] !== undefined) { doctorInfo.realName = raw['realName'] as string; }
                  if (raw['phone'] !== undefined) { doctorInfo.phone = raw['phone'] as string; }
                  if (raw['hospital'] !== undefined) { doctorInfo.hospital = raw['hospital'] as string; }
                  if (raw['department'] !== undefined) { doctorInfo.department = raw['department'] as string; }
                  if (raw['licenseNumber'] !== undefined) { doctorInfo.licenseNumber = raw['licenseNumber'] as string; }
                  if (raw['title'] !== undefined) { doctorInfo.title = raw['title'] as string; }
                  if (raw['specialty'] !== undefined) { doctorInfo.specialty = raw['specialty'] as string; }
                  if (raw['avatar'] !== undefined) { doctorInfo.avatar = raw['avatar'] as string; }
                  if (raw['description'] !== undefined) { doctorInfo.description = raw['description'] as string; }
                  if (raw['rating'] !== undefined) { doctorInfo.rating = raw['rating'] as number; }
                  if (raw['status'] !== undefined) { doctorInfo.status = raw['status'] as number; }
                  userInfo.doctorInfo = doctorInfo;
                }
              } catch (doctorErr) {
                console.error('获取医生信息失败:', JSON.stringify(doctorErr));
              }
            }

            await settings.saveUserInfo(userInfo);

            try {
              await EventPersistenceManager.cacheUserInfo(
                userInfo.userId ?? 0,
                response.data?.token ?? '',
                userInfo.username,
                userInfo.avatar,
                String(userInfo.userType ?? 0)
              );
            } catch (cacheErr) {
              console.warn('[PatientLoginPage] 缓存用户信息失败:', cacheErr);
            }

            if (userInfo && userInfo.userId) {
              AppStorage.setOrCreate<number>('userId', userInfo.userId);
            }
          } catch (error) {
            console.error('保存用户信息失败:', error);
          }
        }

        try {
          AppStorage.setOrCreate<boolean>('isLoggedIn', true);
          const loginUserType: number | undefined = response.data?.userType;
          if (loginUserType === 1) {
            AppStorage.setOrCreate<boolean>('isPatientLoggedIn', false);
            AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
            AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
            AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', false);
            AppStorage.setOrCreate<boolean>('isAdminLoggedIn', false);
          } else {
            AppStorage.setOrCreate<boolean>('isPatientLoggedIn', true);
            AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
            AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
            AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', false);
            AppStorage.setOrCreate<boolean>('isAdminLoggedIn', false);
          }
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

            Text('用户登录')
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
            TextInput({ placeholder: '请输入手机号', text: this.username })
              .type(InputType.Number)
              .maxLength(11)
              .fontSize(16)
              .height(52)
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.username = value;
              })
              .margin({ top: 30, bottom: 16 })

            TextInput({ placeholder: '请输入密码', text: this.password })
              .type(InputType.Password)
              .maxLength(20)
              .fontSize(16)
              .height(52)
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.password = value;
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
              .onClick(async () => await this.handleLogin())

            Text('演示账号：admin / admin123')
              .fontSize(12)
              .fontColor('#94A3B8')
              .margin({ top: 24, bottom: 20 })

            Row({ space: 4 }) {
              Text('其他登录方式：')
                .fontSize(13)
                .fontColor('#94A3B8');
              Text('家属')
                .fontSize(13)
                .fontColor('#1677FF')
                .onClick(() => {
                  router.replaceUrl({ url: 'pages/FamilyLogin' });
                });
              Text(' / ')
                .fontSize(13)
                .fontColor('#CBD5E1');
              Text('护士')
                .fontSize(13)
                .fontColor('#1677FF')
                .onClick(() => {
                  router.replaceUrl({ url: 'pages/NurseLogin' });
                });
              Text(' / ')
                .fontSize(13)
                .fontColor('#CBD5E1');
              Text('医生')
                .fontSize(13)
                .fontColor('#1677FF')
                .onClick(() => {
                  router.replaceUrl({ url: 'pages/DoctorLogin' });
                });
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
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