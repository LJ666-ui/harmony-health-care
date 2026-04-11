import { GlobalTheme } from '../../global';

@Component
export struct AnimatedPage {
  @Prop showAnimation: boolean = true;
  @BuilderParam content: () => void;
  @Prop bgColor: string = GlobalTheme.BG_COLOR;

  @State pageOpacity: number = 0;
  @State pageScale: number = 0.95;

  aboutToAppear(): void {
    if (this.showAnimation) {
      setTimeout(() => {
        this.pageOpacity = 1;
        this.pageScale = 1;
      }, 50);
    } else {
      this.pageOpacity = 1;
      this.pageScale = 1;
    }
  }

  build() {
    Column() {
      if (this.content) {
        this.content();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .opacity(this.pageOpacity)
    .scale({ x: this.pageScale, y: this.pageScale })
    .animation({
      duration: 300,
      curve: Curve.EaseOut
    });
  }
}
