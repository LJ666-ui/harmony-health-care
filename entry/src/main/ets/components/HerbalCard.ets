export interface HerbalInfo {
  id: string;
  name: string;
  alias: string[];
  category: string;
  nature: string;
  taste: string;
  meridian: string[];
  efficacy: string[];
  indications: string[];
  usage: string;
  dosage: string;
  caution: string;
  image: string;
}

@Component
export struct HerbalCard {
  @Prop herbal: HerbalInfo = {} as HerbalInfo;
  @State isPressed: boolean = false;
  onCardClick?: (herbal: HerbalInfo) => void;

  build() {
    Column({ space: 8 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .width('100%')
          .height(140)
          .linearGradient({
            angle: this.getGradientAngle(this.herbal.category),
            colors: this.getGradientColors(this.herbal.category)
          })
          .borderRadius({ topLeft: 12, topRight: 12 })
          .justifyContent(FlexAlign.Center)
          .clip(true);

        Text(this.getHerbalIcon())
          .fontSize(56);
      }

      Column({ space: 6 }) {
        Text(this.herbal.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Row({ space: 6 }) {
          Text(this.herbal.category || '\u672A\u5206\u7C7B')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getCategoryColor(this.herbal.category))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4);

          if (this.herbal.nature) {
            Text('' + this.herbal.nature)
              .fontSize(10)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .borderRadius(4);
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: 10, right: 10, bottom: 8 });

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.herbal.efficacy.slice(0, 2), (efficacy: string) => {
          Text(efficacy.length > 6 ? efficacy.substring(0, 6) + '...' : efficacy)
            .fontSize(9)
            .fontColor(this.getCategoryColor(this.herbal.category))
            .backgroundColor(this.getCategoryBgColor(this.herbal.category))
            .padding({ left: 5, right: 5, top: 2, bottom: 2 })
            .borderRadius(3)
            .margin(1);
        }, (efficacy: string) => efficacy);
      }
      .width('100%')
      .padding({ left: 10, right: 10, bottom: 10 });
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow(
      this.isPressed
        ? { radius: 2, color: '#00000008', offsetX: 0, offsetY: 0 }
        : { radius: 6, color: '#00000012', offsetX: 0, offsetY: 3 }
    )
    .scale({ x: this.isPressed ? 0.97 : 1.0, y: this.isPressed ? 0.97 : 1.0 })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick(this.herbal);
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    });
  }

  private getHerbalIcon(): string {
    const firstChar: string = this.herbal.name.charAt(0);
    const icons: string[] = ['\uD83C\uDF3F', '\uD83C\uDF3E', '\uD83C\uDF38', '\uD83E\uDD52', '\uD83D\uDC78', '\uD83C\uDF31', '\uD83D\uDD34', '\uD83E\uDD86', '\uD83C\uDF42', '\uD83C\uDF3C', '\uD83C\uDF3B', '\uD83C\uDF43', '\uD83E\uDD54', '\u2665', '\uD83C\uDF4B', '\uD83C\uDF44', '\uD83E\uDEAE', '\uD83C\uDF35', '\uD83E\uDDA7', '\u2618'];
    return icons[firstChar.charCodeAt(0) % icons.length];
  }

  private getCategoryColor(category: string): string {
    const colorMap: Record<string, string> = {
      '\u6839\u830E\u7C7B': '#1677FF',
      '\u5168\u8349\u7C7B': '#52C41A',
      '\u679C\u5B9E/\u79CD\u5B50\u7C7B': '#FA8C16',
      '\u52A8\u7269\u7C7B': '#EB2F96',
      '\u679D\u53F6/\u6811\u76AE\u7C7B': '#13C2C2',
      '\u82B1\u7C7B': '#722ED1',
      '\u85FB\u83CC\u5730\u8863\u7C7B': '#8C8C8C',
      '\u5176\u4ED6': '#999999'
    };
    return colorMap[category] || '#1677FF';
  }

  private getCategoryBgColor(category: string): string {
    const colorMap: Record<string, string> = {
      '\u6839\u830E\u7C7B': '#E6F7FF',
      '\u5168\u8349\u7C7B': '#F6FFED',
      '\u679C\u5B9E/\u79CD\u5B50\u7C7B': '#FFF7E6',
      '\u52A8\u7269\u7C7B': '#FFF0F6',
      '\u679D\u53F6/\u6811\u76AE\u7C7B': '#E6FFFB',
      '\u82B1\u7C7B': '#F9F0FF',
      '\u85FB\u83CC\u5730\u8863\u7C7B': '#FAFAFA',
      '\u5176\u4ED6': '#F5F5F5'
    };
    return colorMap[category] || '#E6F7FF';
  }

  private getGradientAngle(category: string): number {
    const angleMap: Record<string, number> = {
      '\u6839\u830E\u7C7B': 135,
      '\u5168\u8349\u7C7B': 90,
      '\u679C\u5B9E/\u79CD\u5B50\u7C7B': 180,
      '\u52A8\u7269\u7C7B': 45,
      '\u679D\u53F6/\u6811\u76AE\u7C7B': 225,
      '\u82B1\u7C7B': 270,
      '\u85FB\u83CC\u5730\u8863\u7C7B': 315,
      '\u5176\u4ED6': 0
    };
    return angleMap[category] || 135;
  }

  private getGradientColors(category: string): [string, number][] {
    const colorMap: Record<string, [string, number][]> = {
      '\u6839\u830E\u7C7B': [['#E6F7FF', 0], ['#BAE7FF', 1]],
      '\u5168\u8349\u7C7B': [['#F6FFED', 0], ['#B7EB8F', 1]],
      '\u679C\u5B9E/\u79CD\u5B50\u7C7B': [['#FFF7E6', 0], ['#FFD591', 1]],
      '\u52A8\u7269\u7C7B': [['#FFF0F6', 0], ['#FFADD2', 1]],
      '\u679D\u53F6/\u6811\u76AE\u7C7B': [['#E6FFFB', 0], ['#87E8DE', 1]],
      '\u82B1\u7C7B': [['#F9F0FF', 0], ['#D3ADF7', 1]],
      '\u85FB\u83CC\u5730\u8863\u7C7B': [['#FAFAFA', 0], ['#D9D9D9', 1]],
      '\u5176\u4ED6': [['#F5F5F5', 0], ['#D9D9D9', 1]]
    };
    return colorMap[category] || [['#E6F7FF', 0], ['#BAE7FF', 1]];
  }
}
