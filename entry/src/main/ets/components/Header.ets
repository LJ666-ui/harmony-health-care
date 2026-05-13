import { router } from '@kit.ArkUI';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';

interface HeaderAction {
  icon: string;
  label: string;
  onClick?: () => void;
}

@Component
export struct Header {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @Prop rightAction: HeaderAction | null = null;

  build() {
    Row({ space: 8 }) {
      if (this.showBack) {
        Column() {
          Text('←')
            .fontSize(AccessibilityConfig.getFontSizeBody())
            .fontColor(AccessibilityConfig.getThemeColor());
        }
        .width(AccessibilityConfig.getIconButtonSize())
        .height(AccessibilityConfig.getIconButtonSize())
        .borderRadius(AccessibilityConfig.getIconButtonSize() / 2)
        .backgroundColor(AccessibilityConfig.getThemeColor() + '15')
        .justifyContent(FlexAlign.Center)
        .accessibilityText('返回')
        .onClick(() => {
          router.back();
        })
      } else {
        Blank().width(AccessibilityConfig.getIconButtonSize());
      }

      Text(this.title)
        .fontSize(AccessibilityConfig.getFontSizeSubtitle())
        .fontWeight(FontWeight.Bold)
        .fontColor(AccessibilityConfig.getTextPrimary())
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .accessibilityText('页面标题：' + this.title);

      if (this.rightAction != null) {
        Column() {
          Text(this.rightAction.icon)
            .fontSize(AccessibilityConfig.getFontSizeBody())
            .fontColor(AccessibilityConfig.getTextSecondary());
        }
        .width(AccessibilityConfig.getIconButtonSize())
        .height(AccessibilityConfig.getIconButtonSize())
        .borderRadius(AccessibilityConfig.getIconButtonSize() / 2)
        .justifyContent(FlexAlign.Center)
        .accessibilityText(this.rightAction.label)
        .onClick(() => {
          if (this.rightAction && this.rightAction.onClick) {
            this.rightAction.onClick();
          }
        })
      } else {
        Blank().width(AccessibilityConfig.getIconButtonSize());
      }
    }
    .width('100%')
    .height(this.isElderMode ? 64 : 56)
    .backgroundColor('#FFFFFF')
    .padding({
      left: AccessibilityConfig.getSpacingMD(),
      right: AccessibilityConfig.getSpacingMD()
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .shadow({
      radius: 2,
      color: AccessibilityConfig.getShadowColor(),
      offsetX: 0,
      offsetY: 1
    });
  }
}
