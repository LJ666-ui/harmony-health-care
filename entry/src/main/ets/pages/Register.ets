import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Input } from '../components/Input';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface RegisterRequestData {
  username: string;
  password: string;
  userType: number;
  phone?: string;
}

interface DoctorRegisterData {
  userId: number;
  realName: string;
  phone: string;
  hospital: string;
  department: string;
  licenseNumber: string;
}

interface RegisterResponseData {
  userId: number;
  message: string;
  userType: number;
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
    if (!this.validateForm()) {
      ToastUtil.showError(this.errorMessage, 2000);
      return;
    }

    this.isLoading = true;

    try {
      const registerRequest: RegisterRequestData = {
        username: this.username,
        password: this.password,
        userType: this.selectedRole
      };

      if (this.selectedRole === 1) {
        registerRequest.phone = this.phone;
      }

      const response: BaseResponse<RegisterResponseData> = await HttpUtil.post<RegisterResponseData>(
        ApiConstants.USER_REGISTER, registerRequest
      );

      if (response.success) {
        if (this.selectedRole === 1 && response.data && response.data.userId) {
          try {
            const doctorData: DoctorRegisterData = {
              userId: response.data.userId,
              realName: this.realName,
              phone: this.phone,
              hospital: this.hospital,
              department: this.department,
              licenseNumber: this.licenseNumber
            };
            await HttpUtil.post<Record<string, Object>>(ApiConstants.DOCTOR_REGISTER, doctorData);
          } catch (doctorError) {
            console.error('医生信息注册失败:', JSON.stringify(doctorError));
            ToastUtil.showInfo('账号已创建，但医生信息提交失败，请联系管理员补录');
          }
        }

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
