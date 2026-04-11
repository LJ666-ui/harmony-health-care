@Component
export struct ClickableCard {
  @Prop onClick: () => void = () => {};
  @Prop children: () => void = () => {};

  @State isPressed: boolean = false;

  build() {
    Column() {
      this.children();
    }
    .scale({ x: this.isPressed ? 0.97 : 1, y: this.isPressed ? 0.97 : 1 })
    .opacity(this.isPressed ? 0.9 : 1)
    .animation({
      duration: 150,
      curve: Curve.EaseInOut
    })
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
        if (this.onClick) {
          this.onClick();
        }
      }
    });
  }
}
