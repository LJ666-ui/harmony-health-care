import { router } from '@kit.ArkUI';
import { GlobalTheme } from '../global';

@Entry
@Component
struct Index {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State showPage: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    setTimeout(() => {
      this.showPage = false;
      setTimeout(() => {
        router.replaceUrl({
          url: 'pages/Login'
        });
      }, 300);
    }, 2000);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Column() {
          Text('⭐')
            .fontSize(this.isElderMode ? 80 : 64)
            .margin({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });

          Text('星云医疗助手')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .letterSpacing(2);

          Text('智慧医疗，守护健康')
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) })
            .letterSpacing(1);
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('正在进入...')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_HINT);

          Progress({
            value: 0,
            total: 100,
            type: ProgressType.Ring
          })
            .width(36)
            .height(36)
            .color(GlobalTheme.THEME_COLOR)
            .backgroundColor(GlobalTheme.BORDER_COLOR)
            .style({ strokeWidth: 3 })
            .margin({ top: GlobalTheme.getSpacingSM(this.isElderMode) });
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: '50%', y: '85%' })
        .translate({ x: '-50%' });
      }
      .width('100%')
      .height('100%')
      .backgroundColor(GlobalTheme.BG_COLOR)
      .opacity(this.showPage ? 1 : 0)
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      });
    }
    .width('100%')
    .height('100%')
  }
}
