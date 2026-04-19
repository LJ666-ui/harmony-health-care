interface HerbalInfo {
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
          Text(this.herbal.category || '未分类')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getCategoryColor(this.herbal.category))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4);

          if (this.herbal.nature) {
            Text(`${this.herbal.nature}`)
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
    const icons: string[] = ['🌿', '🌾', '🌸', '🫒', '🩸', '🌱', '🔴', '🦌', '🍂', '🌼', '🌻', '🍃', '🥔', '🖤', '🎋', '🍄', '💮', '🌵', '🫧', '☘️'];
    const index: number = firstChar.charCodeAt(0) % icons.length;
    return icons[index];
  }

  private getCategoryColor(category: string): string {
    const colorMap: Record<string, string> = {
      '根茎类': '#1677FF',
      '全草类': '#52C41A',
      '果实/种子类': '#FA8C16',
      '动物类': '#EB2F96',
      '枝叶/树皮类': '#13C2C2',
      '花类': '#722ED1',
      '藻菌地衣类': '#8C8C8C',
      '其他': '#999999'
    };
    return colorMap[category] || '#1677FF';
  }

  private getCategoryBgColor(category: string): string {
    const colorMap: Record<string, string> = {
      '根茎类': '#E6F7FF',
      '全草类': '#F6FFED',
      '果实/种子类': '#FFF7E6',
      '动物类': '#FFF0F6',
      '枝叶/树皮类': '#E6FFFB',
      '花类': '#F9F0FF',
      '藻菌地衣类': '#FAFAFA',
      '其他': '#F5F5F5'
    };
    return colorMap[category] || '#E6F7FF';
  }

  private getGradientAngle(category: string): number {
    const angleMap: Record<string, number> = {
      '根茎类': 135,
      '全草类': 90,
      '果实/种子类': 180,
      '动物类': 45,
      '枝叶/树皮类': 225,
      '花类': 270,
      '藻菌地衣类': 315,
      '其他': 0
    };
    return angleMap[category] || 135;
  }

  private getGradientColors(category: string): [string, number][] {
    const colorMap: Record<string, [string, number][]> = {
      '根茎类': [['#E6F7FF', 0], ['#BAE7FF', 1]],
      '全草类': [['#F6FFED', 0], ['#B7EB8F', 1]],
      '果实/种子类': [['#FFF7E6', 0], ['#FFD591', 1]],
      '动物类': [['#FFF0F6', 0], ['#FFADD2', 1]],
      '枝叶/树皮类': [['#E6FFFB', 0], ['#87E8DE', 1]],
      '花类': [['#F9F0FF', 0], ['#D3ADF7', 1]],
      '藻菌地衣类': [['#FAFAFA', 0], ['#D9D9D9', 1]],
      '其他': [['#F5F5F5', 0], ['#D9D9D9', 1]]
    };
    return colorMap[category] || [['#E6F7FF', 0], ['#BAE7FF', 1]];
  }
}
