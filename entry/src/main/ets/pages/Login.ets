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

interface RoleButtonParams {
  title: string;
  desc: string;
  route: string;
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
struct Login {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State showPassword: boolean = false;
  @State roleButtons: RoleButtonParams[] = [];

  private phoneRegex: RegExp = /^1[3-9]\d{9}$/;

  async aboutToAppear(): Promise<void> {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    
    this.roleButtons = [
      { title: '用户登录', desc: '患者账号', route: 'pages/PatientLoginPage' },
      { title: '家属登录', desc: '陪护账号', route: 'pages/FamilyLogin' },
      { title: '护士登录', desc: '医护人员', route: 'pages/NurseLogin' },
      { title: '医生登录', desc: '医师账号', route: 'pages/DoctorLogin' },
      { title: '管理员登录', desc: '系统管理', route: 'pages/AdminLogin' }
    ];
    
    await this.checkAutoLogin();
  }

  private async checkAutoLogin(): Promise<void> {
    try {
      const settings: SettingsUtil = SettingsUtil.getInstance();
      const isLoggedIn: boolean = await settings.isLoggedIn();
      if (isLoggedIn) {
        const token: string = await settings.getToken();
        if (token && token.length > 0) {
          try {
            const options: RequestOptions = { skipAuth: false };
            const response = await HttpUtil.get<PersistedUserInfo>('/user/info', options);
            if (response.success) {
              AppStorage.setOrCreate<string>('token', token);
              AppStorage.setOrCreate<boolean>('isLoggedIn', true);
              const userInfo: PersistedUserInfo | null = await settings.getUserInfo();
              if (userInfo) {
                AppStorage.setOrCreate<PersistedUserInfo | null>('userInfo', userInfo);
                AppStorage.setOrCreate<string>('username', userInfo.username || '');
                if (userInfo.userId) {
                  AppStorage.setOrCreate<number>('userId', userInfo.userId);
                }
                userInfo.userType === 1
                  ? router.replaceUrl({ url: 'pages/DoctorHomePage' })
                  : router.replaceUrl({ url: 'pages/HomePage' });
              } else {
                router.replaceUrl({ url: 'pages/HomePage' });
              }
            } else {
              console.info('[Login] Token已失效，清除登录状态');
              await settings.clearAllLoginData();
            }
          } catch (error) {
            console.error('[Login] Token验证失败:', error);
            await settings.clearAllLoginData();
          }
        }
      }
    } catch (error) {
      console.error('检查登录状态失败:', error);
    }
  }

  private validatePhone(): void {
    this.phoneError = !this.username ? '' :
      !this.phoneRegex.test(this.username) ? '请输入正确的11位手机号' : '';
  }

  private validatePassword(): void {
    this.passwordError = !this.password ? '' :
      (this.password.length < 6 || this.password.length > 20) ? '密码长度为6-20位' : '';
  }

  validateForm(): boolean {
    this.errorMessage = '';

    if (!this.username.trim()) {
      this.errorMessage = '请输入账号';
      return false;
    }
    if (!this.phoneRegex.test(this.username)) {
      this.errorMessage = '请输入正确的11位手机号';
      return false;
    }
    if (!this.password.trim()) {
      this.errorMessage = '请输入密码';
      return false;
    }
    if (this.password.length < 6 || this.password.length > 20) {
      this.errorMessage = '密码长度为6-20位';
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
      const loginRequest: LoginRequestData = { phone: this.username, password: this.password };
      const response: BaseResponse<LoginResponseData> = await HttpUtil.post<LoginResponseData>(
        '/user/login', loginRequest,
        { showLoading: true, loadingText: '登录中...', retryCount: 1 }
      );

      if (response.success) {
        response.data?.token && await HttpUtil.saveToken(response.data.token);

        if (response.data) {
          const settings: SettingsUtil = SettingsUtil.getInstance();
          const userInfo: PersistedUserInfo = response.data.userInfo || createPersistedUserInfo(
            response.data.userId, response.data.username, response.data.userType
          );

          if (userInfo.userType === 1 && userInfo.userId) {
            try {
              const doctorResp = await HttpUtil.get<Object>(ApiConstants.DOCTOR_INFO + userInfo.userId);
              if (doctorResp.success && doctorResp.data) {
                const raw = doctorResp.data as Record<string, Object>;
                userInfo.doctorInfo = {
                  id: raw.id as number, realName: raw.realName as string, phone: raw.phone as string, hospital: raw.hospital as string,
                  department: raw.department as string, licenseNumber: raw.licenseNumber as string, title: raw.title as string,
                  specialty: raw.specialty as string, avatar: raw.avatar as string, description: raw.description as string,
                  rating: raw.rating as number, status: raw.status as number
                };
              }
            } catch (doctorErr) {
              console.error('获取医生信息失败:', JSON.stringify(doctorErr));
            }
          }

          await settings.saveUserInfo(userInfo);
          EventPersistenceManager.cacheUserInfo(
            userInfo.userId ?? 0, response.data.token ?? '', userInfo.username, userInfo.avatar, String(userInfo.userType ?? 0)
          ).catch((err: Error) => console.warn('缓存用户信息失败:', err));

          userInfo.userId && AppStorage.setOrCreate<number>('userId', userInfo.userId);
        }

        AppStorage.setOrCreate<boolean>('isLoggedIn', true);
        const userType = response.data?.userType;
        AppStorage.setOrCreate<boolean>('isPatientLoggedIn', userType !== 1);
        AppStorage.setOrCreate<boolean>('isFamilyLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', false);
        AppStorage.setOrCreate<boolean>('isAdminLoggedIn', false);

        ToastUtil.loginSuccess();
        setTimeout(() => {
          userType === 1
            ? router.replaceUrl({ url: 'pages/DoctorHomePage' })
            : router.replaceUrl({ url: 'pages/HomePage' });
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
    Stack() {
      Image($r('app.media.login_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover);

      Column() {
        Scroll() {
          Column({ space: 16 }) {
            Column()
              .height(80)
            
            ForEach(this.roleButtons, (item: RoleButtonParams) => this.RoleButton(item), 
              (item: RoleButtonParams): string => item.route)
          }
          .width('88%')
          .padding({ bottom: 40 });
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        if (this.isLoading) {
          Loading()
        }
      }
      .width('100%')
      .height('100%');
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  RoleButton(params: RoleButtonParams) {
    Row({ space: 12 }) {
      Column({ space: 2 }) {
        Text(params.title)
          .fontSize(18)
          .fontWeight('bold')
          .fontColor('#FFFFFF');

        Text(params.desc)
          .fontSize(13)
          .fontColor('#FFFFFFCC');
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      Text('>')
        .fontSize(22)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Lighter);
    }
    .width('100%')
    .height(68)
    .padding({ left: 24, right: 20 })
    .backgroundColor('#6BB3FF')
    .borderRadius(16)
    .shadow({ radius: 12, color: '#5BA8F530', offsetX: 0, offsetY: 6 })
    .onClick(() => router.pushUrl({ url: params.route }));
  }
}