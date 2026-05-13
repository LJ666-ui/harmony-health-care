import { router } from '@kit.ArkUI';

export interface GradientColorStop {
  color: string;
  offset: number;
}

export interface BannerItem {
  id: string;
  icon: string;
  title: string;
  subtitle: string;
  ctaText: string;
  targetUrl: string;
  gradientColors: GradientColorStop[];
}

@Component
export struct CarouselBanner {
  @Prop banners: BannerItem[] = [];
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    if (this.banners.length === 0) {
      // 空数据时固定高度，避免页面布局塌陷（统一采用合理高度）
      Column()
        .width('100%')
        .height(160)
    } else {
      Swiper() {
        ForEach(this.banners, (banner: BannerItem) => {
          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Text(banner.icon)
                .fontSize(this.isElderMode ? 28 : 22)

              Text(banner.title)
                .fontSize(this.isElderMode ? 20 : 16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .layoutWeight(1)
            }
            .alignItems(VerticalAlign.Center)

            Text(banner.subtitle)
              .fontSize(this.isElderMode ? 14 : 12)
              .fontColor('#FFFFFFCC')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Row() {
              Text(banner.ctaText)
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)

              Text(' →')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#FFFFFF')
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('#FFFFFF30')
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('100%')
          .padding(16)
          .linearGradient({
            angle: 135,
            colors: [
              [(banner.gradientColors && banner.gradientColors[0]) ? banner.gradientColors[0].color : '#1677FF', (banner.gradientColors && banner.gradientColors[0]) ? banner.gradientColors[0].offset : 0],
              [(banner.gradientColors && banner.gradientColors[1]) ? banner.gradientColors[1].color : '#36CFC9', (banner.gradientColors && banner.gradientColors[1]) ? banner.gradientColors[1].offset : 1]
            ] as [string, number][]
          })
          .borderRadius(12)
          .onClick(() => {
            if (banner.targetUrl) {
              router.pushUrl({ url: banner.targetUrl });
            }
          })
        }, (banner: BannerItem) => banner.id)
      }
      .autoPlay(true)
      .interval(4000)
      .loop(true)
      .indicator(new DotIndicator()
        .itemWidth(6)
        .itemHeight(6)
        .selectedItemWidth(18)
        .selectedItemHeight(6)
        .color('#FFFFFF80')
        .selectedColor('#FFFFFF'))
      .width('100%')
      .height(this.isElderMode ? 180 : 160)
    }
  }
}