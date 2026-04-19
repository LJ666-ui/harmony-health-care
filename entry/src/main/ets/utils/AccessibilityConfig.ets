export enum FontSizeLevel {
  TINY = 'tiny',
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large',
  XLARGE = 'xlarge',
  EXTRA_LARGE = 'extra_large'
}

export enum ColorMode {
  NORMAL = 'normal',
  DARK = 'dark',
  HIGH_CONTRAST = 'high_contrast',
  COLOR_BLIND_FRIENDLY = 'color_blind_friendly'
}

export enum AnimationMode {
  NORMAL = 'normal',
  REDUCED = 'reduced',
  NONE = 'none'
}

class AccessibilityConfig {
  private static instance: AccessibilityConfig;
  private isElderMode: boolean = false;
  private fontSizeLevel: string = 'medium';
  private colorMode: string = 'normal';
  private animationMode: string = 'normal';
  private isTTSEnabledVal: boolean = false;
  private firstTimeGuideShown: boolean = false;

  public static getInstance(): AccessibilityConfig {
    if (!AccessibilityConfig.instance) {
      AccessibilityConfig.instance = new AccessibilityConfig();
    }
    return AccessibilityConfig.instance;
  }

  public static getFirstTimeGuideShown(): boolean {
    return AccessibilityConfig.getInstance().firstTimeGuideShown;
  }

  public static markFirstTimeGuideShown(): void {
    AccessibilityConfig.getInstance().firstTimeGuideShown = true;
  }

  public static getFontSizeLevel(): FontSizeLevel {
    return AccessibilityConfig.getInstance().fontSizeLevel as FontSizeLevel;
  }

  public static setFontSizeLevel(level: FontSizeLevel): void {
    AccessibilityConfig.getInstance().fontSizeLevel = level;
  }

  public static getColorMode(): ColorMode {
    return AccessibilityConfig.getInstance().colorMode as ColorMode;
  }

  public static setColorMode(mode: ColorMode): void {
    AccessibilityConfig.getInstance().colorMode = mode;
  }

  public static getAnimationMode(): AnimationMode {
    return AccessibilityConfig.getInstance().animationMode as AnimationMode;
  }

  public static setAnimationMode(mode: AnimationMode): void {
    AccessibilityConfig.getInstance().animationMode = mode;
  }

  public static isTTSEnabled(): boolean {
    return AccessibilityConfig.getInstance().isTTSEnabledVal;
  }

  public static setTTSEnabled(enabled: boolean): void {
    AccessibilityConfig.getInstance().isTTSEnabledVal = enabled;
  }

  public static resetToDefault(): void {
    const config = AccessibilityConfig.getInstance();
    config.isElderMode = false;
    config.fontSizeLevel = 'medium';
    config.colorMode = 'normal';
    config.animationMode = 'normal';
    config.isTTSEnabledVal = false;
  }

  public setElderMode(enabled: boolean): void {
    this.isElderMode = enabled;
  }

  public getElderMode(): boolean {
    return this.isElderMode;
  }

  public static getSpacingXS(): number {
    return 4;
  }

  public static getSpacingSM(): number {
    return 8;
  }

  public static getSpacingMD(): number {
    return 16;
  }

  public static getSpacingLG(): number {
    return 24;
  }

  public static getSpacingXL(): number {
    return 32;
  }

  public static getFontSizeTiny(): number {
    return 10;
  }

  public static getFontSizeCaption(): number {
    return 12;
  }

  public static getFontSizeSmall(): number {
    return 13;
  }

  public static getFontSizeBody(): number {
    return 14;
  }

  public static getFontSizeSubtitle(): number {
    return 16;
  }

  public static getFontSizeTitle(): number {
    return 20;
  }

  public static getFontSizeHeading(): number {
    return 24;
  }

  public static getFontSizeButton(): number {
    return 15;
  }

  public static getIconButtonSize(): number {
    return 40;
  }

  public static getButtonHeight(): number {
    return 44;
  }

  public static getThemeColor(): string {
    return '#1677FF';
  }

  public static getTextPrimary(): string {
    return '#333333';
  }

  public static getTextSecondary(): string {
    return '#666666';
  }

  public static getTextHint(): string {
    return '#999999';
  }

  public static getShadowColor(): string {
    return '#00000020';
  }

  public static getBackgroundColor(): string {
    return '#F5F5F5';
  }

  public static getBgColor(): string {
    return '#F5F5F5';
  }

  public static getCardBgColor(): string {
    return '#FFFFFF';
  }

  public static getActiveBgColor(): string {
    return '#E6F4FF';
  }

  public static getBorderColor(): string {
    return '#E0E0E0';
  }

  public static getSuccessColor(): string {
    return '#52C41A';
  }

  public static getWarningColor(): string {
    return '#FAAD14';
  }

  public static getErrorColor(): string {
    return '#FF4D4F';
  }
}

export default new AccessibilityConfig();
export { AccessibilityConfig };
