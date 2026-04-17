import { AccessibilityConfig, FontSizeLevel, ColorMode, AnimationMode } from '../utils/AccessibilityConfig';

@Component
export struct AccessiblePageWrapper {
  @StorageLink('fontSizeLevel') currentFontSizeLevel: string = 'medium';
  @StorageLink('colorMode') currentColorMode: string = 'normal';
  @StorageLink('animationMode') currentAnimationMode: string = 'normal';
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('ttsEnabled') ttsEnabled: boolean = false;

  @Prop pageTitle: string = '';
  @Prop showBackButton: boolean = false;
  @BuilderParam content: () => void;

  getBgColor(): string {
    return AccessibilityConfig.getBgColor();
  }

  getTextColor(): string {
    return AccessibilityConfig.getTextPrimary();
  }

  getAnimationDuration(): number {
    if (this.currentAnimationMode === 'none') {
      return 0;
    } else if (this.currentAnimationMode === 'reduced') {
      return 150;
    }
    return 300;
  }

  shouldAnimate(): boolean {
    return this.currentAnimationMode !== 'none';
  }

  build() {
    Column() {

      if (this.content) {
        this.content();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getBgColor())
    .animation({
      duration: this.getAnimationDuration(),
      curve: Curve.EaseInOut
    })
  }
}

@Component
export struct AccessibleText {
  @StorageLink('fontSizeLevel') currentFontSizeLevel: string = 'medium';

  @Prop textContent: string = '';
  @Prop textType: 'title' | 'subtitle' | 'body' | 'small' | 'tiny' | 'button' = 'body';
  @Prop fontWeightValue: FontWeight | number = FontWeight.Normal;
  @Prop textColor?: string;
  @Prop textAlignValue: TextAlign = TextAlign.Start;
  @Prop maxLinesNum: number = 0;

  getFontSize(): number {
    switch (this.textType) {
      case 'title':
        return AccessibilityConfig.getFontSizeTitle();
      case 'subtitle':
        return AccessibilityConfig.getFontSizeSubtitle();
      case 'body':
        return AccessibilityConfig.getFontSizeBody();
      case 'small':
        return AccessibilityConfig.getFontSizeSmall();
      case 'tiny':
        return AccessibilityConfig.getFontSizeTiny();
      case 'button':
        return AccessibilityConfig.getFontSizeButton();
      default:
        return AccessibilityConfig.getFontSizeBody();
    }
  }

  getColor(): string {
    if (this.textColor) {
      return this.textColor;
    }
    switch (this.textType) {
      case 'title':
      case 'subtitle':
        return AccessibilityConfig.getTextPrimary();
      case 'body':
        return AccessibilityConfig.getTextPrimary();
      case 'small':
      case 'tiny':
        return AccessibilityConfig.getTextSecondary();
      default:
        return AccessibilityConfig.getTextPrimary();
    }
  }

  build() {
    Text(this.textContent)
      .fontSize(this.getFontSize())
      .fontWeight(this.fontWeightValue)
      .fontColor(this.getColor())
      .textAlign(this.textAlignValue)
      .maxLines(this.maxLinesNum)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}

@Component
export struct AccessibleButton {
  @StorageLink('fontSizeLevel') currentFontSizeLevel: string = 'medium';

  @Prop buttonLabel: string = '';
  @Prop buttonType: 'primary' | 'secondary' | 'text' | 'danger' = 'primary';
  @Prop isDisabled: boolean = false;
  @Prop fullWidth: boolean = false;
  onClickAction?: () => void;

  getButtonHeight(): number {
    return AccessibilityConfig.getButtonHeight();
  }

  getFontSize(): number {
    return AccessibilityConfig.getFontSizeButton();
  }

  getBackgroundColor(): string {
    if (this.isDisabled) {
      return '#CCCCCC';
    }
    switch (this.buttonType) {
      case 'primary':
        return AccessibilityConfig.getThemeColor();
      case 'secondary':
        return '#F5F5F5';
      case 'text':
        return 'transparent';
      case 'danger':
        return AccessibilityConfig.getErrorColor();
      default:
        return AccessibilityConfig.getThemeColor();
    }
  }

  getTextColor(): string {
    if (this.isDisabled) {
      return '#999999';
    }
    switch (this.buttonType) {
      case 'primary':
        return '#FFFFFF';
      case 'secondary':
        return AccessibilityConfig.getTextPrimary();
      case 'text':
        return AccessibilityConfig.getThemeColor();
      case 'danger':
        return '#FFFFFF';
      default:
        return '#FFFFFF';
    }
  }

  build() {
    Button(this.buttonLabel)
      .height(this.getButtonHeight())
      .fontSize(this.getFontSize())
      .backgroundColor(this.getBackgroundColor())
      .fontColor(this.getTextColor())
      .borderRadius(this.getButtonHeight() / 2)
      .enabled(!this.isDisabled)
      .width(this.fullWidth ? '100%' : 'auto')
      .onClick(() => {
        if (this.onClickAction && !this.isDisabled) {
          this.onClickAction();
        }
      })
  }
}

@Component
export struct AccessibleCard {
  @StorageLink('fontSizeLevel') currentFontSizeLevel: string = 'medium';
  @StorageLink('colorMode') currentColorMode: string = 'normal';

  @BuilderParam content: () => void;
  @Prop cardPadding: number = 16;
  @Prop onClickAction?: () => void;

  getCardBgColor(): string {
    return AccessibilityConfig.getCardBgColor();
  }

  getBorderColor(): string {
    return AccessibilityConfig.getBorderColor();
  }

  getPadding(): number {
    return AccessibilityConfig.getListItemPadding() + this.cardPadding - 16;
  }

  build() {
    Column() {
      if (this.content) {
        this.content();
      }
    }
    .width('100%')
    .padding(this.getPadding())
    .backgroundColor(this.getCardBgColor())
    .borderRadius(12)
    .border({ width: 1, color: this.getBorderColor() })
    .shadow({
      radius: 8,
      color: AccessibilityConfig.getShadowColor(),
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      if (this.onClickAction) {
        this.onClickAction();
      }
    })
  }
}
