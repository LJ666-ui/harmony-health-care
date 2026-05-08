import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { SettingsUtil } from '../utils/SettingsUtil';

@Entry
@Component
struct NurseHealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State isLoading: boolean = false;

  async aboutToAppear(): Promise<void> {
    const settings = SettingsUtil.getInstance();
    const isLoggedIn = await settings.isNurseLoggedIn();
    if (!isLoggedIn) {
      ToastUtil.showError('请先登录');
      router.replaceUrl({ url: 'pages/NurseLogin' });
    }
  }

  build() {
    Column() {
      Header({ title: '健康档案', showBack: true })

      Column() {
        Text('📋')
          .fontSize(48)
          .margin({ bottom: 16 })

        Text('护士健康档案管理')
          .fontSize(this.isElderMode ? 22 : 18)
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY)
          .margin({ bottom: 8 })

        Text('查看和管理患者的健康档案记录')
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .margin({ bottom: 20 })

        Column() {
          Text('功能说明：')
            .fontSize(14)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .width('100%')
            .margin({ bottom: 10 })

          Text('• 查看患者列表')
            .fontSize(13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%')
            .margin({ bottom: 6 })

          Text('• 查看患者健康档案详情')
            .fontSize(13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%')
            .margin({ bottom: 6 })

          Text('• 管理病历记录')
            .fontSize(13)
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .width('100%')
        }
        .width('85%')
        .padding(16)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
