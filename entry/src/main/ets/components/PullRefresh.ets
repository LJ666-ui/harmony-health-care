@Component
export struct PullRefresh {
  @Prop onRefresh: () => void = () => {};
  @Prop children: () => void = () => {};

  @State isRefreshing: boolean = false;
  @State refreshText: string = '下拉刷新';

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

      this.children();
    }
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.refreshText = '下拉刷新';
      } else if (event.type === TouchType.Up && !this.isRefreshing) {
        this.isRefreshing = true;
        this.refreshText = '正在刷新...';

        setTimeout(() => {
          this.onRefresh();
          this.isRefreshing = false;
          this.refreshText = '刷新完成';
        }, 1500);
      }
    });
  }
}
