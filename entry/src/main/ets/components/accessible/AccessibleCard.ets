/**
 * 无障碍卡片组件
 * Accessible Card - 支持老年模式、大字体、语音播报
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

/**
 * 无障碍卡片组件
 */
@Component
export struct AccessibleCard {
  @Prop title: string = '';
  @Prop subtitle?: string;
  @Prop icon?: string;
  @Prop showArrow: boolean = false;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  private onClickHandler: () => void = () => {};

  /**
   * 获取字体大小
   */
  private getTitleSize(): number {
    return this.isElderMode ? 20 : 18;
  }

  private getSubtitleSize(): number {
    return this.isElderMode ? 18 : 14;
  }

  /**
   * 获取内边距
   */
  private getPadding(): number {
    return this.isElderMode ? 20 : 16;
  }

  /**
   * 获取间距
   */
  private getSpacing(): number {
    return this.isElderMode ? 16 : 12;
  }

  build() {
    Column() {
      Row() {
        // 图标
        if (this.icon) {
          Text(this.icon)
            .fontSize(this.isElderMode ? 32 : 24)
            .margin({ right: 12 })
        }

        // 内容
        Column() {
          // 标题
          Text(this.title)
            .fontSize(this.getTitleSize())
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .width('100%')

          // 副标题
          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(this.getSubtitleSize())
              .fontColor('#666666')
              .margin({ top: 4 })
              .width('100%')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 箭头
        if (this.showArrow) {
          Text('>')
            .fontSize(this.getTitleSize())
            .fontColor('#999999')
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(this.getPadding())
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
    .shadow({
      radius: 4,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onClickHandler();
    })
    // 无障碍属性
    .accessibilityText(this.title)
    .accessibilityDescription(this.subtitle || this.title)
  }
}
