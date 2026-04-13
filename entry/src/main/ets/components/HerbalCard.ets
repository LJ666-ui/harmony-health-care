import { HerbalInfo } from '../mock/herbalMock';

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

        Text(this.getHerbalIcon(this.herbal.name))
          .fontSize(56);

        if (this.herbal.isCollected) {
          Text('❤️')
            .fontSize(18)
            .margin({ top: 8, right: 8 });
        }
      }

      Column({ space: 6 }) {
        Text(this.herbal.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Row({ space: 6 }) {
          Text(this.herbal.category.replace('药', ''))
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getCategoryColor(this.herbal.category))
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4);

          Text(`${this.herbal.nature}`)
            .fontSize(10)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .padding({ left: 4, right: 4, top: 2, bottom: 2 })
            .borderRadius(4);
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

  private getHerbalIcon(name: string): string {
    const iconMap: Record<string, string> = {
      '人参': '🌿',
      '黄芪': '🌾',
      '当归': '🌸',
      '熟地黄': '🫒',
      '阿胶': '🩸',
      '麦冬': '🌱',
      '枸杞子': '🔴',
      '鹿茸': '🦌',
      '杜仲': '🍂',
      '金银花': '🌼',
      '菊花': '🌻',
      '甘草': '🍃',
      '白术': '🌿',
      '山药': '🥔',
      '何首乌': '🖤',
      '淫羊藿': '🌿',
      '石斛': '🎋',
      '茯苓': '🍄',
      '连翘': '💮',
      '肉苁蓉': '🌵'
    };
    return iconMap[name] || '🌿';
  }

  private getCategoryColor(category: string): string {
    const colorMap: Record<string, string> = {
      '补气药': '#1677FF',
      '补血药': '#EB2F96',
      '补阴药': '#52C41A',
      '补阳药': '#FA8C16',
      '清热药': '#13C2C2'
    };
    return colorMap[category] || '#999999';
  }

  private getCategoryBgColor(category: string): string {
    const colorMap: Record<string, string> = {
      '补气药': '#E6F7FF',
      '补血药': '#FFF0F6',
      '补阴药': '#F6FFED',
      '补阳药': '#FFF7E6',
      '清热药': '#E6FFFB'
    };
    return colorMap[category] || '#F5F5F5';
  }

  private getGradientAngle(category: string): number {
    const angleMap: Record<string, number> = {
      '补气药': 135,
      '补血药': 90,
      '补阴药': 180,
      '补阳药': 45,
      '清热药': 225
    };
    return angleMap[category] || 135;
  }

  private getGradientColors(category: string): [string, number][] {
    const colorMap: Record<string, [string, number][]> = {
      '补气药': [['#E6F7FF', 0], ['#BAE7FF', 1]],
      '补血药': [['#FFF0F6', 0], ['#FFADD2', 1]],
      '补阴药': [['#F6FFED', 0], ['#B7EB8F', 1]],
      '补阳药': [['#FFF7E6', 0], ['#FFD591', 1]],
      '清热药': [['#E6FFFB', 0], ['#87E8DE', 1]]
    };
    return colorMap[category] || [['#F6FFED', 0], ['#D9D9D9', 1]];
  }
}
