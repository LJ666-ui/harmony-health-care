import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface RehabService {
  id: number;
  icon: string;
  title: string;
  description: string;
  url: string;
}

@Entry
@Component
struct RehabPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State services: RehabService[] = [
    { id: 1, icon: '🏃', title: '康复课程', description: '专业康复训练指导', url: 'pages/RehabListPage' },
    { id: 2, icon: '🎮', title: '3D康复训练', description: '沉浸式3D康复体验', url: 'pages/Rehab3DPage' },
    { id: 3, icon: '⚠️', title: '健康评估', description: '个性化风险评估', url: 'pages/RiskAssessmentPage' }
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
        title: '康复中心',
        showBack: false
      });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('智慧康复')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          Text('为您提供专业的康复服务')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });

          ForEach(this.services, (service: RehabService) => {
            Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              Column() {
                Text(service.icon)
                  .fontSize(32)
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
                .fontSize(24)
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
          }, (service: RehabService) => service.id.toString());
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .layoutWeight(1);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
