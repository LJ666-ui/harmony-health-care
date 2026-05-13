import { router } from '@kit.ArkUI';
import { HttpUtil } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ChangePasswordPage {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State showOldPassword: boolean = false;
  @State showNewPassword: boolean = false;
  @State showConfirmPassword: boolean = false;

  build() {
    Column() {
      Scroll() {
        Column({ space: 24 }) {
          this.buildHeader();
          
          this.buildPasswordField('原密码', this.oldPassword, this.showOldPassword, 
            (value: string) => { this.oldPassword = value; },
            () => { this.showOldPassword = !this.showOldPassword; }
          );
          
          this.buildPasswordField('新密码', this.newPassword, this.showNewPassword,
            (value: string) => { this.newPassword = value; },
            () => { this.showNewPassword = !this.showNewPassword; }
          );
          
          this.buildPasswordField('确认新密码', this.confirmPassword, this.showConfirmPassword,
            (value: string) => { this.confirmPassword = value; },
            () => { this.showConfirmPassword = !this.showConfirmPassword; }
          );
          
          this.buildTips();
          
          this.buildSubmitButton();
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 40 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#F5F7FA');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildHeader() {
    Column({ space: 16 }) {
      Text('修改密码')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333');

      Text('请定期更换密码以保护账户安全')
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  buildPasswordField(label: string, value: string, showPassword: boolean, 
                     onChange: (value: string) => void, onToggleVisibility: () => void) {
    Column({ space: 12 }) {
      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%');

      Row() {
        TextInput({ text: value })
          .fontSize(15)
          .fontColor('#333333')
          .layoutWeight(1)
          .type(showPassword ? InputType.Normal : InputType.Password)
          .placeholder(`请输入${label}`)
          .onChange(onChange);

        Button(showPassword ? '隐藏' : '显示')
          .fontSize(12)
          .fontColor('#1677FF')
          .backgroundColor('transparent')
          .onClick(onToggleVisibility);
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .border({ width: 1, color: '#E5E5E5' });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  buildTips() {
    Column({ space: 8 }) {
      Text('密码要求：')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .width('100%');

      Text('• 长度不少于6个字符')
        .fontSize(13)
        .fontColor('#999999')
        .width('100%');

      Text('• 建议包含字母、数字和特殊字符')
        .fontSize(13)
        .fontColor('#999999')
        .width('100%');

      Text('• 不能与原密码相同')
        .fontSize(13)
        .fontColor('#999999')
        .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF9E6')
    .borderRadius(8)
    .margin({ top: 8 });
  }

  @Builder
  buildSubmitButton() {
    Button('确认修改')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor('#FFFFFF')
      .backgroundColor('#1677FF')
      .borderRadius(8)
      .enabled(!this.isLoading && this.validateForm())
      .onClick(() => {
        this.handleChangePassword();
      });

    if (this.isLoading) {
      Text('正在处理...')
        .fontSize(14)
        .fontColor('#1677FF')
        .margin({ top: 12 });
    }
  }

  private validateForm(): boolean {
    return this.oldPassword.trim().length > 0 &&
           this.newPassword.trim().length >= 6 &&
           this.confirmPassword.trim().length > 0;
  }

  private handleChangePassword(): void {
    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的新密码不一致' });
      return;
    }

    if (this.oldPassword === this.newPassword) {
      promptAction.showToast({ message: '新密码不能与原密码相同' });
      return;
    }

    this.isLoading = true;

    const token: string | undefined = AppStorage.get<string>('doctorToken');
    
    const passwordData = {
      oldPassword: this.oldPassword,
      newPassword: this.newPassword
    };

    HttpUtil.post(`${ApiConstants.DOCTOR_INFO.replace(/\/$/, '')}/password`, passwordData, { 'Token': token || '' })
      .then((response: object) => {
        const res = response as Record<string, Object>;
        if (res['code'] === 200) {
          promptAction.showToast({ message: '密码修改成功，请重新登录' });
          
          setTimeout(() => {
            AppStorage.setOrCreate<boolean>('isDoctorLoggedIn', false);
            AppStorage.setOrCreate<string>('doctorToken', '');
            router.replaceUrl({ url: 'pages/Login' });
          }, 1500);
        } else {
          promptAction.showToast({ message: (res['message'] as string) || '修改失败' });
        }
      })
      .catch((error: Error) => {
        promptAction.showToast({ message: '网络错误：' + error.message });
      })
      .finally(() => {
        this.isLoading = false;
      });
  }
}
