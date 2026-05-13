import { TouchType } from '@kit.ArkUI';
import curves from '@ohos.curves';

@Component
export struct ClickableCard {
  onClick: () => void = () => {};
  @BuilderParam contentBuilder: () => void = this.defaultContent;

  @Builder
  private defaultContent() {}

  @State isPressed: boolean = false;

  build() {
    Column() {
      this.contentBuilder();
    }
    .scale({ x: this.isPressed ? 0.97 : 1, y: this.isPressed ? 0.97 : 1 })
    .opacity(this.isPressed ? 0.9 : 1)
    .animation({
      duration: 150,
      curve: 4
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