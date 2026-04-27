import { AccessibilityConfig } from '../utils/AccessibilityConfig';

@Component
export struct SearchHistory {
  @Link history: string[];
  onClear: () => void = () => {};
  onSelect: (keyword: string) => void = () => {};
  @StorageLink('isOldModeEnabled') isOldModeEnabled: boolean = false;

  build() {
    Column() {
      Row() {
        Text('搜索历史')
          .fontColor('#333333')
          .fontSize(this.isOldModeEnabled ? 16 : 14)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1);

        Text('清空')
          .fontColor('#999999')
          .fontSize(this.isOldModeEnabled ? 14 : 12)
          .onClick(() => {
            this.onClear();
          });
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12
      });

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.history.slice(0, 10), (item: string, index: number) => {
          Text(item)
            .padding({
              left: this.isOldModeEnabled ? 12 : 8,
              right: this.isOldModeEnabled ? 12 : 8,
              top: this.isOldModeEnabled ? 12 : 8,
              bottom: this.isOldModeEnabled ? 12 : 8
            })
            .margin({ right: 8, bottom: 8 })
            .height(this.isOldModeEnabled ? 40 : 32)
            .backgroundColor('#F0F5FF')
            .borderRadius(16)
            .fontColor('#333333')
            .fontSize(this.isOldModeEnabled ? 14 : 12)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .onClick(() => {
              this.onSelect(item);
            });
        }, (item: string) => item);
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        bottom: 16
      });
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .width('90%')
    .alignItems(HorizontalAlign.Start)
    .shadow({
      radius: 4,
      color: '#00000008',
      offsetX: 0,
      offsetY: 2
    });
  }
}
