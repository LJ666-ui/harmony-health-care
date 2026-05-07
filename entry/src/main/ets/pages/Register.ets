import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import { SettingsUtil, PersistedUserInfo } from '../utils/SettingsUtil';
import EventPersistenceManager from '../utils/EventPersistenceManager';

interface RegisterRequestData {
  username: string;
  password: string;
  userType: number;
  phone?: string;
  realName?: string;
  hospital?: string;
  department?: string;
  licenseNumber?: string;
}

interface RegisterResponseData {
  userId: number;
  message: string;
  userType: number;
}

interface SendCodeRequest {
  phone: string;
}

interface SendCodeResponse {
  message: string;
  code?: string;
}

interface LoginRequestData {
  username: string;
  password: string;
}

interface LoginResponseData {
  token: string;
  userInfo?: PersistedUserInfo;
}

const DEPARTMENTS: string[] = [
  '内科', '外科', '儿科', '妇产科', '骨科',
  '眼科', '耳鼻喉科', '口腔科', '皮肤科', '中医科',
  '康复科', '急诊科', '麻醉科', '影像科', '检验科'
];

@Entry
@Component
struct Register {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedRole: number = 0;
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State phone: string = '';
  @State realName: string = '';
  @State hospital: string = '';
  @State department: string = '';
  @State licenseNumber: string = '';
  @State showDeptPicker: boolean = false;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  // 验证码相关状态
  @State verificationCode: string = '';
  @State countdown: number = 0;
  @State isCountingDown: boolean = false;
  private countdownTimer: number = -1;

  // 密码强度相关状态
  @State passwordStrength: 'weak' | 'medium' | 'strong' = 'weak';
  @State passwordStrengthPercent: number = 0;

  // 用户协议
  @State agreedToTerms: boolean = false;

  // 手机号验证正则
  private phoneRegex: RegExp = /^1[3-9]\d{9}$/;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
  }

  aboutToDisappear(): void {
    // 清除倒计时定时器
    if (this.countdownTimer !== -1) {
      clearInterval(this.countdownTimer);
    }
  }

  /**
   * 安全显示Toast提示（捕获异常并提供降级方案）
   */
  private safeShowToast(type: 'success' | 'error', message: string, duration: number = 2000): void {
    try {
      if (type === 'success') {
        ToastUtil.showSuccess(message, duration);
      } else {
        ToastUtil.showError(message, duration);
      }
      console.log(`[Toast] ${type}: ${message}`);
    } catch (error) {
      console.error('[Toast] Toast显示失败，使用降级方案:', error);
      console.log(`[Toast降级] ${type}: ${message}`);
    }
  }

  /**
   * 断言状态一致性（检测并修正状态不一致）
   */
  private assertStateConsistency(): void {
    console.log('[状态检查] 开始状态一致性检查');
    console.log(`[状态检查] username: ${this.username}`);
    console.log(`[状态检查] isCountingDown: ${this.isCountingDown}`);
    console.log(`[状态检查] countdown: ${this.countdown}`);
    console.log(`[状态检查] phoneRegex.test(username): ${this.phoneRegex.test(this.username)}`);

    if (this.isCountingDown && this.countdown <= 0) {
      console.error('[状态检查] 检测到状态不一致: isCountingDown=true但countdown<=0，自动修正');
      this.isCountingDown = false;
      this.countdown = 0;
    }

    if (!this.isCountingDown && this.countdown > 0) {
      console.error('[状态检查] 检测到状态不一致: isCountingDown=false但countdown>0，自动修正');
      this.countdown = 0;
    }

    if (!this.phoneRegex.test(this.username)) {
      console.warn('[状态检查] 手机号格式无效');
    }

    console.log('[状态检查] 状态一致性检查完成');
  }

  /**
   * 发送验证码
   */
  private async sendVerificationCode(): Promise<void> {
    console.log('[验证码] 进入sendVerificationCode方法');
    console.log(`[验证码] 当前手机号: ${this.username}`);

    // 状态一致性检查
    this.assertStateConsistency();

    // 验证手机号格式
    const isValidPhone = this.phoneRegex.test(this.username);
    console.log(`[验证码] 手机号验证结果: ${isValidPhone}`);

    if (!isValidPhone) {
      console.warn('[验证码] 手机号格式验证失败');
      this.safeShowToast('error', '请输入正确的手机号', 2000);
      return;
    }

    try {
      const sendCodeRequest: SendCodeRequest = {
        phone: this.username
      };
      console.log(`[验证码] 准备发送请求: ${JSON.stringify(sendCodeRequest)}`);

      const response = await HttpUtil.post<SendCodeResponse>(
        '/user/send-code',
        sendCodeRequest,
        { skipAuth: true }
      );
      console.log(`[验证码] 收到响应: ${JSON.stringify(response)}`);

      if (response.success) {
        console.log('[验证码] 验证码发送成功');
        this.safeShowToast('success', '验证码已发送', 2000);
        this.startCountdown();
        // 测试环境：如果后端返回了验证码，自动填充
        if (response.data && response.data.code) {
          this.verificationCode = response.data.code;
          console.log('[测试模式] 验证码已自动填充:', response.data.code);
        }
      } else {
        console.warn(`[验证码] 验证码发送失败: ${response.message}`);
        this.safeShowToast('error', response.message || '发送失败', 2000);
      }
    } catch (error) {
      // 后端服务未启动时，使用Mock模式
      console.warn('[验证码] 验证码服务暂不可用，使用Mock模式');
      console.error('[验证码] 错误详情:', error);
      this.safeShowToast('success', '验证码已发送（测试模式）', 2000);
      this.startCountdown();
      // 自动填充测试验证码
      this.verificationCode = '123456';
      console.log('[测试模式] 验证码已自动填充: 123456');
    }
  }

  /**
   * 开始倒计时
   */
  private startCountdown(): void {
    this.countdown = 60;
    this.isCountingDown = true;
    this.countdownTimer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.countdownTimer);
        this.isCountingDown = false;
        this.countdown = 0;
      }
    }, 1000);
  }

  /**
   * 计算密码强度
   */
  private calculatePasswordStrength(): void {
    const pwd = this.password;

    if (!pwd || pwd.length === 0) {
      this.passwordStrength = 'weak';
      this.passwordStrengthPercent = 0;
      return;
    }

    // 弱：长度<8 或 纯数字
    if (pwd.length < 8 || /^\d+$/.test(pwd)) {
      this.passwordStrength = 'weak';
      this.passwordStrengthPercent = 30;
      return;
    }

    // 强：长度>12 且 包含特殊字符
    if (pwd.length > 12 && /[!@#$%^&*]/.test(pwd)) {
      this.passwordStrength = 'strong';
      this.passwordStrengthPercent = 100;
      return;
    }

    // 中：长度8-12 且 包含字母和数字
    if (pwd.length >= 8 && pwd.length <= 12 && /[a-zA-Z]/.test(pwd) && /\d/.test(pwd)) {
      this.passwordStrength = 'medium';
      this.passwordStrengthPercent = 60;
      return;
    }

    // 默认中等
    this.passwordStrength = 'medium';
    this.passwordStrengthPercent = 60;
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

    if (this.selectedRole === 1) {
      if (!this.realName || this.realName.trim() === '') {
        this.errorMessage = '请填写真实姓名';
        return false;
      }
      if (!this.phone || this.phone.trim() === '') {
        this.errorMessage = '请填写手机号';
        return false;
      }
      if (!/^1[3-9]\d{9}$/.test(this.phone)) {
        this.errorMessage = '手机号格式不正确';
        return false;
      }
      if (!this.hospital || this.hospital.trim() === '') {
        this.errorMessage = '请填写所属医院';
        return false;
      }
      if (!this.department || this.department.trim() === '') {
        this.errorMessage = '请选择科室';
        return false;
      }
      if (!this.licenseNumber || this.licenseNumber.trim() === '') {
        this.errorMessage = '请填写执业证号';
        return false;
      }
    }

    return true;
  }

  async handleRegister(): Promise<void> {
    // 验证用户协议
    if (!this.agreedToTerms) {
      ToastUtil.showError('请先同意用户协议', 2000);
      return;
    }

    if (!this.validateForm()) {
      ToastUtil.showError(this.errorMessage, 2000);
      return;
    }

    this.isLoading = true;

    try {
      const registerRequest: RegisterRequestData = {
        username: this.username,
        password: this.password,
        userType: this.selectedRole,
        phone: this.username  // 普通用户使用手机号作为用户名，同时也设置phone字段
      };

      if (this.selectedRole === 1) {
        registerRequest.phone = this.phone;
        registerRequest.realName = this.realName;
        registerRequest.hospital = this.hospital;
        registerRequest.department = this.department;
        registerRequest.licenseNumber = this.licenseNumber;
      }

      const response: BaseResponse<RegisterResponseData> = await HttpUtil.post<RegisterResponseData>(
        ApiConstants.USER_REGISTER,
        registerRequest,
        { skipAuth: true, retryCount: 1 }
      );

      if (response.success) {
        ToastUtil.showSuccess('注册成功，正在自动登录...', 2000);

        // 自动登录
        setTimeout(async () => {
          try {
            const loginRequest: LoginRequestData = {
              username: this.username,
              password: this.password
            };
            const loginResponse = await HttpUtil.post<LoginResponseData>('/user/login', loginRequest, { skipAuth: true });

            if (loginResponse.success && loginResponse.data) {
              await HttpUtil.saveToken(loginResponse.data.token);
              if (loginResponse.data.userInfo) {
                const settings = SettingsUtil.getInstance();
                await settings.saveUserInfo(loginResponse.data.userInfo);
                try {
                  await EventPersistenceManager.cacheUserInfo(
                    loginResponse.data.userInfo.userId ?? 0,
                    loginResponse.data.token ?? '',
                    loginResponse.data.userInfo.username,
                    loginResponse.data.userInfo.avatar,
                    String(loginResponse.data.userInfo.userType ?? 0)
                  );
                } catch (cacheErr) {
                  console.warn('Register: 缓存用户信息到本地DB失败:', cacheErr);
                }
              }
              AppStorage.setOrCreate<boolean>('isLoggedIn', true);
              router.replaceUrl({ url: 'pages/HomePage' });
            } else {
              router.back();
            }
          } catch (error) {
            console.error('自动登录失败:', error);
            router.back();
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

          Text('请选择角色并填写信息完成注册')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Row({ space: 16 }) {
            Column({ space: 8 }) {
              Row({ space: 8 }) {
                Text('👤')
                  .fontSize(24);
                Text('普通用户')
                  .fontSize(this.isElderMode ? 15 : 13)
                  .fontColor(this.selectedRole === 0 ? GlobalTheme.THEME_COLOR : '#666666');
              }
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(10)
              .backgroundColor(this.selectedRole === 0 ? '#E6F4FF' : '#F5F5F5')
              .border(this.selectedRole === 0 ? { width: 2, color: GlobalTheme.THEME_COLOR } :
                { width: 1, color: '#E0E0E0' })
              .onClick(() => {
                this.selectedRole = 0;
              })
              .layoutWeight(1);

              Text('浏览健康知识、AI咨询、风险自测等')
                .fontSize(10)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 4 });
            }
            .layoutWeight(1);

            Column({ space: 8 }) {
              Row({ space: 8 }) {
                Text('👨‍⚕️')
                  .fontSize(24);
                Text('医生入驻')
                  .fontSize(this.isElderMode ? 15 : 13)
                  .fontColor(this.selectedRole === 1 ? GlobalTheme.THEME_COLOR : '#666666');
              }
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(10)
              .backgroundColor(this.selectedRole === 1 ? '#E6F4FF' : '#F5F5F5')
              .border(this.selectedRole === 1 ? { width: 2, color: GlobalTheme.THEME_COLOR } :
                { width: 1, color: '#E0E0E0' })
              .onClick(() => {
                this.selectedRole = 1;
              })
              .layoutWeight(1);

              Text('在线问诊、患者管理、消息回复')
                .fontSize(10)
                .fontColor('#999999')
                .textAlign(TextAlign.Center)
                .width('100%')
                .margin({ top: 4 });
            }
            .layoutWeight(1);
          }
          .width('100%');

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
                .border({ width: 1, color: '#E8ECF2', style: BorderStyle.Solid })
                .padding({ left: 12, right: 12 })
                .onChange((value: string) => {
                  this.username = value;
                });
            }
            .width('100%');
          }
          .width('100%');

          // 验证码输入框
          Row({ space: 8 }) {
            TextInput({ placeholder: '请输入验证码', text: this.verificationCode })
              .type(InputType.Number)
              .maxLength(6)
              .layoutWeight(1)
              .height(44)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .border({ width: 1, color: '#E8ECF2', style: BorderStyle.Solid })
              .padding({ left: 16, right: 16 });

            Button(this.isCountingDown ? `${this.countdown}秒` : '获取验证码')
              .width(110)
              .height(44)
              .fontSize(13)
              .fontColor(this.isCountingDown || !this.phoneRegex.test(this.username) ? '#999999' : '#FFFFFF')
              .backgroundColor(this.isCountingDown || !this.phoneRegex.test(this.username) ? '#CCCCCC' : GlobalTheme.THEME_COLOR)
              .borderRadius(8)
              .enabled(!this.isCountingDown && this.phoneRegex.test(this.username))
              .hitTestBehavior(HitTestMode.Block)
              .onClick(() => {
                console.log('[onClick] 验证码按钮被点击');
                console.log(`[onClick] 按钮状态 - enabled: ${!this.isCountingDown && this.phoneRegex.test(this.username)}`);
                console.log(`[onClick] 手机号: ${this.username}, 正在倒计时: ${this.isCountingDown}`);
                
                try {
                  this.sendVerificationCode();
                } catch (error) {
                  console.error('[onClick] onClick处理异常:', error);
                  this.safeShowToast('error', '操作失败，请重试', 2000);
                }
              });
          }
          .width('100%');

          // 密码输入框
          Column({ space: 4 }) {
            TextInput({ placeholder: '请设置密码(6-20位)', text: this.password })
              .type(InputType.Password)
              .maxLength(20)
              .width('100%')
              .height(44)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .border({ width: 1, color: '#E8ECF2', style: BorderStyle.Solid })
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.password = value;
                this.calculatePasswordStrength();
              });

            // 密码强度指示器
            if (this.password && this.password.length > 0) {
              Row({ space: 8 }) {
                Progress({ value: this.passwordStrengthPercent, total: 100, type: ProgressType.Linear })
                  .width(100)
                  .height(4)
                  .color(this.passwordStrength === 'weak' ? '#F5222D' :
                         this.passwordStrength === 'medium' ? '#FAAD14' : '#52C41A');

                Text('密码强度：')
                  .fontSize(12)
                  .fontColor('#666666');

                Text(this.passwordStrength === 'weak' ? '弱' :
                     this.passwordStrength === 'medium' ? '中' : '强')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.passwordStrength === 'weak' ? '#F5222D' :
                             this.passwordStrength === 'medium' ? '#FAAD14' : '#52C41A');
              }
              .width('100%');
            }
          }
          .width('100%');

          // 确认密码输入框
          Column({ space: 4 }) {
            TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
              .type(InputType.Password)
              .maxLength(20)
              .width('100%')
              .height(44)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .border({ width: 1, color: '#E8ECF2', style: BorderStyle.Solid })
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.confirmPassword = value;
              });

            if (this.confirmPassword && this.confirmPassword.length > 0 && this.password !== this.confirmPassword) {
              Text('两次密码输入不一致')
                .fontSize(12)
                .fontColor('#F5222D');
            }
          }
          .width('100%');

          // 用户协议
          Row({ space: 8 }) {
            Checkbox({ name: 'agreement', group: 'registerGroup' })
              .select(this.agreedToTerms)
              .selectedColor(GlobalTheme.THEME_COLOR)
              .onChange((isChecked: boolean) => {
                this.agreedToTerms = isChecked;
              });

            Row({ space: 4 }) {
              Text('我已阅读并同意')
                .fontSize(12)
                .fontColor('#666666');

              Text('《用户协议》')
                .fontSize(12)
                .fontColor(GlobalTheme.THEME_COLOR)
                .onClick(() => {
                  router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
                });

              Text('和')
                .fontSize(12)
                .fontColor('#666666');

              Text('《隐私政策》')
                .fontSize(12)
                .fontColor(GlobalTheme.THEME_COLOR)
                .onClick(() => {
                  router.pushUrl({ url: 'pages/PrivacyPolicyPage' });
                });
            }
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 });

          if (this.selectedRole === 1) {
            Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Text('医生信息认证')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%');

              Row({ space: 8 }) {
                Text('📋')
                  .fontSize(14)
                  .fontColor(GlobalTheme.THEME_COLOR);
                Text('以下信息将用于医生身份核验，请如实填写')
                  .fontSize(11)
                  .fontColor('#FF9800');
              }
              .width('100%')
              .padding(10)
              .backgroundColor('#FFF8E1')
              .borderRadius(8);

              Input({
                placeholder: '真实姓名（与执业证一致）',
                inputType: 'text',
                text: $realName
              })

              Input({
                placeholder: '手机号',
                inputType: 'text',
                text: $phone
              })

              Input({
                placeholder: '所属医院全称',
                inputType: 'text',
                text: $hospital
              })

              Row() {
                Text('科室')
                  .fontSize(13)
                  .fontColor('#333333')
                  .width(80);

                Text(this.department || '请选择科室')
                  .fontSize(13)
                  .fontColor(this.department ? '#333333' : '#999999')
                  .layoutWeight(1)
                  .onClick(() => {
                    this.showDeptPicker = !this.showDeptPicker;
                  });

                Text('▼')
                  .fontSize(10)
                  .fontColor('#999999')
                  .margin({ left: 4 });
              }
              .width('100%')
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor('#FFFFFF')
              .borderRadius(10)
              .border({ width: 1, color: '#E0E0E0' });

              if (this.showDeptPicker) {
                Column() {
                  ForEach(DEPARTMENTS, (dept: string) => {
                    Text(dept)
                      .fontSize(13)
                      .fontColor(this.department === dept ? GlobalTheme.THEME_COLOR : '#333333')
                      .width('100%')
                      .height(40)
                      .textAlign(TextAlign.Center)
                      .backgroundColor(this.department === dept ? '#E6F4FF' : '#FFFFFF')
                      .onClick(() => {
                        this.department = dept;
                        this.showDeptPicker = false;
                      });
                  }, (dept: string) => dept);
                }
                .width('100%')
                .constraintSize({ maxHeight: 210 })
                .borderRadius(8)
                .border({ width: 1, color: '#D0D0D0' })
                .shadow({ radius: 4, color: '#00000015', offsetX: 0, offsetY: 2 });
              }

              Input({
                placeholder: '医师执业证号',
                inputType: 'text',
                text: $licenseNumber
              })
            }
            .width('100%');
          }

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
            Button(this.selectedRole === 1 ? '申请入驻' : '立即注册')
              .width('100%')
              .height(GlobalTheme.getButtonHeight(this.isElderMode))
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.BUTTON_TEXT_COLOR)
              .backgroundColor(this.selectedRole === 1 ? '#52C41A' : GlobalTheme.THEME_COLOR)
              .borderRadius(GlobalTheme.RADIUS_MD)
              .shadow({
                radius: 8,
                color: this.selectedRole === 1 ? '#52C41A30' : '#1677FF30',
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
                  console.error('返回登录页失败:', JSON.stringify(error));
                }
              });
          }
          .width('100%')
          .justifyContent(FlexAlign.Center);
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .scrollBar(BarState.Off)
      .height(0)
      .layoutWeight(1)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
