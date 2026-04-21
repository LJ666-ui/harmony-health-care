import { router } from '@kit.ArkUI';

interface NavigationTitleBarProps {
  title: string;
  showBack?: boolean;
  onSettingsClick?: () => void;
}

@Component
export struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @Prop onSettingsClick: (() => void) | null = null;

  build() {
    Row({ space: 12 }) {
      if (this.showBack) {
        Column()
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F0F0F0')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.back();
          }) {
            Text('←')
              .fontSize(18)
              .fontColor('#333333');
          }
      } else {
        Blank().width(40);
      }

      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });

      if (this.onSettingsClick) {
        Column()
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#F0F0F0')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.onSettingsClick) {
              this.onSettingsClick();
            }
          }) {
            Text('⚙️')
              .fontSize(18);
          }
      } else {
        Blank().width(40);
      }
    }
    .width('100%')
    .height(56)
    .backgroundColor('#FFFFFF')
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .shadow({
      radius: 2,
      color: '#00000010',
      offsetX: 0,
      offsetY: 1
    });
  }
}
