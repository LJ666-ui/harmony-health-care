@Component
export struct PullRefresh {
  @Prop onRefresh: () => void = () => {};
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  private defaultContent() {}

  @State isRefreshing: boolean = false;

  build() {
    Column() {
      if (this.isRefreshing) {
        Row() {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#1677FF');
          Text('正在刷新...')
            .fontSize(13)
            .fontColor('#666666')
            .margin({ left: 8 });
        }
        .width('100%')
        .height(50)
        .justifyContent(FlexAlign.Center);
      }

      this.content();
    }
    .onTouch((event: TouchEvent) => {
      try {
        if (event.type === TouchType.Up && !this.isRefreshing) {
          this.isRefreshing = true;

          setTimeout(() => {
            try {
              this.onRefresh();
            } catch (e) {
              console.error('PullRefresh onRefresh error:', e);
            }
            this.isRefreshing = false;
          }, 1500);
        }
      } catch (e) {
        console.error('PullRefresh onTouch error:', e);
      }
    });
  }
}
