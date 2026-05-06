import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';
import { AdminMock, AdminInfo } from '../mock/adminMock';

@Entry
@Component
struct AdminLogin {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State username: string = '';
  @State password: string = '';
  @State showPassword: boolean = false;
  @State isLoading: boolean = false;
  @State errorMsg: string = '';

  build() {
    Column() {
      Column() {
        Text('🛡️')
          .fontSize(56)
          .margin({ bottom: 16 });
        Text('管理后台')
          .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF');
        Text('星云医疗助手 · 管理系统')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor('#FFFFFFCC')
          .margin({ top: 8 });
      }
      .width('100%')
      .padding({ top: 60, bottom: 48, left: 24, right: 24 })
      .linearGradient({ angle: 135, colors: [['#1E293B', 0], ['#334155', 1]] })
      .borderRadius({ bottomLeft: 32, bottomRight: 32 });

      Column({ space: 20 }) {
        Column({ space: 8 }) {
          Text('用户名')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          Row() {
            Text('👤')
              .fontSize(18)
              .margin({ right: 10 });
            TextInput({ placeholder: '请输入管理员用户名', text: this.username })
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(10)
              .border({ width: 1, color: '#E8ECF2', style: BorderStyle.Solid })
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.username = value;
                this.errorMsg = '';
              });
          }
          .width('100%');
        }

        Column({ space: 8 }) {
          Text('密码')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%');
          Row() {
            Text('🔒')
              .fontSize(18)
              .margin({ right: 10 });
            TextInput({ placeholder: '请输入密码', text: this.password })
              .type(this.showPassword ? InputType.Normal : InputType.Password)
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(10)
              .border({ width: 1, color: '#E8ECF2', style: BorderStyle.Solid })
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.password = value;
                this.errorMsg = '';
              });
            Button({ type: ButtonType.Normal }) {
              Text(this.showPassword ? '🙈' : '👁️')
                .fontSize(16);
            }
            .width(40)
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ left: 8 })
            .onClick(() => {
              this.showPassword = !this.showPassword;
            });
          }
          .width('100%');
        }

        if (this.errorMsg) {
          Row({ space: 6 }) {
            Text('⚠️')
              .fontSize(14);
            Text(this.errorMsg)
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.ERROR_COLOR);
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFF2F0')
          .borderRadius(10)
          .border({ width: 1, color: '#FFCCC7', style: BorderStyle.Solid });
        }

        Button(this.isLoading ? '登录中...' : '登 录')
          .width('100%')
          .height(50)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#1E293B')
          .borderRadius(12)
          .enabled(!this.isLoading)
          .margin({ top: 8 })
          .onClick(() => {
            this.handleLogin();
          });

        Row() {
          Text('演示账号：admin / admin123')
            .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_HINT);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 });

        Row() {
          Text('← 返回用户端')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.THEME_COLOR)
            .onClick(() => {
              router.back();
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 4 });
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 32, bottom: 24 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  private handleLogin(): void {
    if (!this.username.trim()) {
      this.errorMsg = '请输入用户名';
      return;
    }
    if (!this.password.trim()) {
      this.errorMsg = '请输入密码';
      return;
    }
    if (this.password.length < 6) {
      this.errorMsg = '密码长度不能少于6位';
      return;
    }

    this.isLoading = true;
    setTimeout(() => {
      const admin: AdminInfo | null = AdminMock.login(this.username, this.password);
      this.isLoading = false;
      if (admin) {
        AppStorage.setOrCreate<AdminInfo>('currentAdmin', admin);
        router.replaceUrl({ url: 'pages/AdminDashboard' });
      } else {
        this.errorMsg = '用户名或密码错误';
      }
    }, 600);
  }
}
