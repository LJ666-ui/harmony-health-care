import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

@Entry
@Component
struct DepartmentPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State departments: string[] = ['内科', '外科', '老年病科', '骨科', '康复科'];
  @State selectedDept: number = -1;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  build() {
    Column() {
      Header({ title: '科室选择', showBack: true });

      Scroll() {
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Text('选择科室')
            .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
            .fontWeight('bold')
            .fontColor(GlobalTheme.THEME_COLOR)
            .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

          ForEach(this.departments, (item: string, index: number) => {
            Row() {
              Column() {
                Text(item)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor(this.selectedDept === index ? '#FFFFFF' : GlobalTheme.THEME_COLOR);
              }
              .width(56)
              .height(56)
              .backgroundColor(this.selectedDept === index ? GlobalTheme.THEME_COLOR : GlobalTheme.THEME_COLOR + '20')
              .borderRadius(28)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
                Text(item)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight('bold')
                  .fontColor(GlobalTheme.TEXT_PRIMARY);
                Text('点击进入' + item + '预约管理')
                  .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY);
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: GlobalTheme.getSpacingMD(this.isElderMode) });

              Text('›')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT);
            }
            .width('100%')
            .padding(GlobalTheme.getSpacingMD(this.isElderMode))
            .backgroundColor(this.selectedDept === index ? GlobalTheme.THEME_COLOR + '15' : GlobalTheme.CARD_BG)
            .borderRadius(GlobalTheme.RADIUS_MD)
            .border({ width: 1, color: this.selectedDept === index ? GlobalTheme.THEME_COLOR : GlobalTheme.BORDER_COLOR })
            .onClick(() => {
              this.selectedDept = index;
              router.pushUrl({ url: 'pages/Appointments' });
            });
          }, (item: string, index: number) => item + '_' + index.toString());
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
