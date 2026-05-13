@Component
export struct ClickFeedback {
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  private defaultContent() {}

  onItemClick?: () => void;
  @Prop scaleFactor: number = 0.97;
  @Prop opacityValue: number = 0.9;
  @Prop duration: number = 150;
  @Prop isEnabled: boolean = true;

  @State isPressed: boolean = false;

  build() {
    Column() {
      this.content();
    }
    .scale({ x: this.isPressed && this.isEnabled ? this.scaleFactor : 1, y: this.isPressed && this.isEnabled ? this.scaleFactor : 1 })
    .opacity(this.isPressed && this.isEnabled ? this.opacityValue : 1)
    .animation({
      duration: this.duration,
      curve: 4
    })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    });
  }
}

@Component
export struct ButtonWithFeedback {
  @Prop text: string = '';
  @Prop type: 'primary' | 'secondary' | 'outline' | 'danger' = 'primary';
  @Prop btnSize: 'small' | 'medium' | 'large' = 'medium';
  @Prop disabled: boolean = false;
  @Prop loading: boolean = false;
  onItemClick?: () => void;

  @State isPressed: boolean = false;

  private getButtonWidth(): string {
    switch (this.btnSize) {
      case 'small': return '80vp';
      case 'medium': return '120vp';
      case 'large': return '100%';
      default: return '120vp';
    }
  }

  private getButtonHeight(): number {
    switch (this.btnSize) {
      case 'small': return 32;
      case 'medium': return 40;
      case 'large': return 48;
      default: return 40;
    }
  }

  private getFontSize(): number {
    switch (this.btnSize) {
      case 'small': return 12;
      case 'medium': return 14;
      case 'large': return 16;
      default: return 14;
    }
  }

  private getFontColor(): ResourceColor {
    if (this.type === 'outline') {
      return '#4a90e2';
    }
    return '#ffffff';
  }

  private getBackgroundColor(): ResourceColor {
    if (this.type === 'outline') {
      return '#ffffff';
    }

    switch (this.type) {
      case 'primary': return '#4a90e2';
      case 'secondary': return '#666666';
      case 'danger': return '#ff6b6b';
      default: return '#4a90e2';
    }
  }

  private getBorderColor(): ResourceColor {
    switch (this.type) {
      case 'primary': return '#4a90e2';
      case 'secondary': return '#666666';
      case 'danger': return '#ff6b6b';
      case 'outline': return '#4a90e2';
      default: return '#4a90e2';
    }
  }

  build() {
    Button(this.text)
      .width(this.getButtonWidth())
      .height(this.getButtonHeight())
      .fontSize(this.getFontSize())
      .fontColor(this.getFontColor())
      .backgroundColor(this.getBackgroundColor())
      .border({
        width: this.type === 'outline' ? 1 : 0,
        color: this.getBorderColor()
      })
      .opacity(this.disabled || this.isPressed ? (this.disabled ? 0.5 : 0.85) : 1)
      .scale({ x: this.isPressed ? 0.95 : 1, y: this.isPressed ? 0.95 : 1 })
      .animation({
        duration: 150,
        curve: 4
      })
      .enabled(!this.disabled && !this.loading)
      .onClick(() => {
        if (this.disabled || this.loading) return;
        if (this.onItemClick) {
          this.onItemClick();
        }
      });
  }
}

@Component
export struct ListItemWithFeedback {
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  private defaultContent() {}

  onItemClick?: () => void;
  @Prop showRipple: boolean = true;

  @State isPressed: boolean = false;
  @State rippleScale: number = 0;

  build() {
    Stack() {
      Column() {
        this.content();
      }
      .width('100%')
      .height('100%');

      if (this.showRipple) {
        Row()
          .width(200)
          .height(200)
          .borderRadius(100)
          .backgroundColor('#000000')
          .opacity(this.isPressed ? 0.05 : 0)
          .scale({ x: this.rippleScale, y: this.rippleScale })
          .animation({
            duration: 300,
            curve: 3
          })
      }
    }
    .width('100%')
    .scale({ x: this.isPressed ? 0.98 : 1, y: this.isPressed ? 0.98 : 1 })
    .opacity(this.isPressed ? 0.9 : 1)
    .animation({
      duration: 150,
      curve: 4
    })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    });
  }
}