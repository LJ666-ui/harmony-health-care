import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface MedicalService {
  id: number;
  icon: string;
  title: string;
  description: string;
  url: string;
}

@Entry
@Component
struct MedicalPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State services: MedicalService[] = [
    { id: 1, icon: '🏥', title: '医院列表', description: '查找附近医院和科室', url: 'pages/HospitalPage' },
    { id: 2, icon: '📅', title: '预约挂号', description: '在线预约医生门诊', url: 'pages/Appointments' },
    { id: 3, icon: '🗺️', title: '院内导航', description: 'AR智能导航到诊室', url: 'pages/ARNavigationPage' },
    { id: 4, icon: '💊', title: '用药管理', description: '设置用药提醒', url: 'pages/Medications' }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  build(): void {
    Column() {
      Header({
        title: '就医服务',
        showBack: false
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('智慧就医')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Text('为您提供便捷的医疗服务')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });

          ForEach(this.services, (service: MedicalService) => {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Column() {
                Text(service.icon)
                  .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
                  .fontColor(GlobalTheme.THEME_COLOR);
              }
              .width(64)
              .height(64)
              .backgroundColor(GlobalTheme.THEME_COLOR + '20')
              .borderRadius(32)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);

              Column({ space: 4 }) {
                Text(service.title)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor('#333333');

                Text(service.description)
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor('#666666');
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

              Text('›')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor('#CCCCCC');
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor('#FFFFFF')
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
            .shadow({
              radius: 8,
              color: GlobalTheme.SHADOW_COLOR,
              offsetX: 0,
              offsetY: 2
            })
            .onClick(() => {
              router.pushUrl({ url: service.url });
            });
          }, (service: MedicalService) => service.id.toString());
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
