import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse } from '../common/utils/HttpUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

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

@Entry
@Component
struct NurseProfile {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('nurseInfo') nurseInfo: NurseInfo | null = null;
  @StorageLink('nurseToken') nurseToken: string = '';
  @State isLoading: boolean = false;

  async aboutToAppear(): Promise<void> {
    // 加载护士信息
    if (!this.nurseInfo) {
      const settings = SettingsUtil.getInstance();
      const savedInfo = await settings.getNurseInfo();
      if (savedInfo) {
        this.nurseInfo = savedInfo as NurseInfo;
      }
    }
  }

  private async loadNurseInfo(): Promise<void> {
    if (!this.nurseToken) {
      ToastUtil.showError('未登录');
      return;
    }

    this.isLoading = true;
    try {
      const response = await HttpUtil.get<NurseInfo>('/nurse/info');

      if (response.success && response.data) {
        this.nurseInfo = response.data;
        const settings = SettingsUtil.getInstance();
        await settings.saveNurseInfo(response.data);
        ToastUtil.showSuccess('信息已更新');
      } else {
        ToastUtil.showError(response.message || '获取信息失败');
      }
    } catch (error) {
      console.error('加载护士信息失败:', error);
      ToastUtil.showError('网络错误');
    } finally {
      this.isLoading = false;
    }
  }

  private handleLogout(): void {
    AlertDialog.show({
      title: '提示',
      message: '确定要退出登录吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        action: async () => {
          const settings = SettingsUtil.getInstance();
          await settings.clearNurseAuth();
          AppStorage.setOrCreate<string>('nurseToken', '');
          AppStorage.setOrCreate<NurseInfo | null>('nurseInfo', null);
          AppStorage.setOrCreate<boolean>('isNurseLoggedIn', false);
          router.replaceUrl({ url: 'pages/Index' });
        }
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Header({ title: '个人中心' })

      Scroll() {
        Column({ space: 16 }) {
          // 个人信息卡片
          Column() {
            // 头像区域
            Column() {
              Image(this.nurseInfo?.avatar || $r('app.media.startIcon'))
                .width(80)
                .height(80)
                .borderRadius(40)
                .backgroundColor('#E0E0E0')

              Text(this.nurseInfo?.name || '护士')
                .fontSize(this.isElderMode ? 24 : 20)
                .fontWeight(FontWeight.Bold)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .margin({ top: 12 })

              Text(`${this.nurseInfo?.department || '-'} | ${this.nurseInfo?.title || '-'}`)
                .fontSize(this.isElderMode ? 16 : 14)
                .fontColor(GlobalTheme.TEXT_SECONDARY)
                .margin({ top: 4 })
            }
            .width('100%')
            .padding({ top: 24, bottom: 16 })

            // 信息列表
            Column() {
              this.InfoItem('工号', this.nurseInfo?.nurseNo || '-')
              this.InfoItem('姓名', this.nurseInfo?.name || '-')
              this.InfoItem('手机号', this.nurseInfo?.phone || '-')
              this.InfoItem('科室', this.nurseInfo?.department || '-')
              this.InfoItem('职称', this.nurseInfo?.title || '-')
            }
            .width('100%')
            .padding({ left: 20, right: 20, bottom: 20 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 功能菜单
          Column() {
            this.MenuItem('编辑个人信息', () => {
              ToastUtil.showInfo('功能开发中');
            })

            this.MenuItem('修改密码', () => {
              ToastUtil.showInfo('功能开发中');
            })

            this.MenuItem('消息通知', () => {
              ToastUtil.showInfo('功能开发中');
            })

            this.MenuItem('帮助与反馈', () => {
              ToastUtil.showInfo('功能开发中');
            })

            this.MenuItem('关于我们', () => {
              ToastUtil.showInfo('功能开发中');
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

          // 退出登录按钮
          Button('退出登录')
            .width('100%')
            .height(50)
            .fontSize(this.isElderMode ? 18 : 16)
            .backgroundColor('#FF6B6B')
            .onClick(() => {
              this.handleLogout();
            })
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  InfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width(80)

      Text(value)
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .layoutWeight(1)
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  MenuItem(title: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(this.isElderMode ? 16 : 14)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .layoutWeight(1)

      Text('>')
        .fontSize(16)
        .fontColor(GlobalTheme.TEXT_SECONDARY)
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(onClick)
  }
}
