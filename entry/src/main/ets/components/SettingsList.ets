import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { router } from '@kit.ArkUI';

interface MenuItem {
  icon: string;
  title: string;
  color: string;
  url: string;
}

@Component
export struct SettingsList {
  @Prop settingsItems: MenuItem[] = [];
  onMenuClick: (item: MenuItem) => void = () => {};
  @StorageLink('isOldModeEnabled') isOldModeEnabled: boolean = false;

  build() {
    Column() {
      Row() {
        Text('设置')
          .fontSize(this.isOldModeEnabled ? 18 : 16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 });

      Column() {
        ForEach(this.settingsItems, (item: MenuItem) => {
          Row() {
            Text(item.icon)
              .fontSize(18)
              .width(28)
              .fontColor(item.color);

            Text(item.title)
              .fontSize(AccessibilityConfig.getFontSizeBody())
              .fontColor('#333333')
              .layoutWeight(1)
              .margin({ left: 12 });

            Text('›')
              .fontSize(20)
              .fontColor('#CCCCCC');
          }
          .width('100%')
          .padding({
            left: AccessibilityConfig.getSpacingMD(),
            right: AccessibilityConfig.getSpacingMD(),
            top: AccessibilityConfig.getSpacingMD(),
            bottom: AccessibilityConfig.getSpacingMD()
          })
          .backgroundColor(AccessibilityConfig.getCardBgColor())
          .borderRadius(16)
          .borderWidth(1)
          .borderColor(AccessibilityConfig.getBorderColor())
          .alignItems(VerticalAlign.Center)
          .accessibilityText(item.title)
          .onClick(() => {
            this.onMenuClick(item);
          });
        });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('90%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 16 });
  }
}
