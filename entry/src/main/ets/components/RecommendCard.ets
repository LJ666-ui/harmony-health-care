@Component
struct RecommendCard {
  @Prop imageUrl: string = '';
  @Prop title: string = '';
  @Prop reason: string = '';
  @Prop source: string = '';
  onClickCallback?: () => void;

  build() {
    Column() {
      Image(this.imageUrl)
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover);

      Column({
        space: 8
      }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(2);

        Text(this.reason)
          .fontSize(14)
          .fontColor('#666666');

        Row() {
          Text(this.source)
            .fontSize(12)
            .fontColor('#999999')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#f0f0f0')
            .borderRadius(4);
        }
      }
      .padding(12);
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .shadow({ radius: 4, color: '#00000010' })
    .onClick(() => {
      if (this.onClickCallback) {
        this.onClickCallback();
      }
    });
  }
}

export { RecommendCard };
