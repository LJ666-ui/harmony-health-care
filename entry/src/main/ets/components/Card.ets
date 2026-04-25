import { GlobalTheme } from '../global';


@Component
export struct Card {
  @Prop title: string = '';
  @Prop value: string = '';
  @Prop description: string = '';
  @Prop status: string = '';
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight('bold')
          .fontColor(GlobalTheme.TEXT_PRIMARY);
        Blank().layoutWeight(1);
        Text(this.status)
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontColor(GlobalTheme.THEME_COLOR);
      }
      .margin({ bottom: GlobalTheme.getSpacingSM(this.isElderMode) });

      Text(this.value)
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight('bold')
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .margin({ bottom: 4 });

      Text(this.description)
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY);
    }
    .width('100%')
    .padding(GlobalTheme.getSpacingMD(this.isElderMode))
    .backgroundColor('#FFFFFF')
    .borderRadius(GlobalTheme.RADIUS_MD)
    .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
  }
}
