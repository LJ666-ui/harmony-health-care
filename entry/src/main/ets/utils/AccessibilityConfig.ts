export enum FontSizeLevel {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large',
  EXTRA_LARGE = 'extra_large'
}

export enum ColorMode {
  NORMAL = 'normal',
  HIGH_CONTRAST = 'high_contrast',
  COLOR_BLIND_FRIENDLY = 'color_blind_friendly'
}

export enum AnimationMode {
  NORMAL = 'normal',
  REDUCED = 'reduced',
  NONE = 'none'
}

interface FontSizeConfig {
  title: number;
  subtitle: number;
  body: number;
  small: number;
  tiny: number;
  button: number;
}

const FONT_SIZE_CONFIGS: Record<FontSizeLevel, FontSizeConfig> = {
  [FontSizeLevel.SMALL]: { title: 20, subtitle: 17, body: 14, small: 12, tiny: 10, button: 14 },
  [FontSizeLevel.MEDIUM]: { title: 24, subtitle: 20, body: 16, small: 13, tiny: 11, button: 16 },
  [FontSizeLevel.LARGE]: { title: 30, subtitle: 26, body: 22, small: 18, tiny: 15, button: 18 },
  [FontSizeLevel.EXTRA_LARGE]: { title: 36, subtitle: 32, body: 28, small: 22, tiny: 18, button: 22 }
};

interface TouchAreaConfig {
  minTouchWidth: number;
  minTouchHeight: number;
  buttonHeight: number;
  iconButtonSize: number;
  listItemPadding: number;
}

const TOUCH_AREA_CONFIGS: Record<FontSizeLevel, TouchAreaConfig> = {
  [FontSizeLevel.SMALL]: { minTouchWidth: 40, minTouchHeight: 40, buttonHeight: 44, iconButtonSize: 36, listItemPadding: 12 },
  [FontSizeLevel.MEDIUM]: { minTouchWidth: 44, minTouchHeight: 44, buttonHeight: 50, iconButtonSize: 40, listItemPadding: 14 },
  [FontSizeLevel.LARGE]: { minTouchWidth: 48, minTouchHeight: 48, buttonHeight: 56, iconButtonSize: 44, listItemPadding: 16 },
  [FontSizeLevel.EXTRA_LARGE]: { minTouchWidth: 52, minTouchHeight: 52, buttonHeight: 64, iconButtonSize: 48, listItemPadding: 20 }
};

interface SpacingConfig {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
}

const SPACING_CONFIGS: Record<FontSizeLevel, SpacingConfig> = {
  [FontSizeLevel.SMALL]: { xs: 4, sm: 8, md: 14, lg: 18, xl: 24 },
  [FontSizeLevel.MEDIUM]: { xs: 4, sm: 8, md: 16, lg: 20, xl: 28 },
  [FontSizeLevel.LARGE]: { xs: 6, sm: 12, md: 22, lg: 28, xl: 34 },
  [FontSizeLevel.EXTRA_LARGE]: { xs: 8, sm: 14, md: 28, lg: 34, xl: 42 }
};

interface ColorScheme {
  primary: string;
  bg: string;
  cardBg: string;
  textPrimary: string;
  textSecondary: string;
  textHint: string;
  success: string;
  warning: string;
  error: string;
  border: string;
  shadow: string;
  activeBg: string;
  disabledText: string;
}

const COLOR_SCHEMES: Record<ColorMode, ColorScheme> = {
  [ColorMode.NORMAL]: {
    primary: '#1677FF',
    bg: '#F5F7FA',
    cardBg: '#FFFFFF',
    textPrimary: '#333333',
    textSecondary: '#666666',
    textHint: '#999999',
    success: '#52C41A',
    warning: '#FAAD14',
    error: '#FF4D4F',
    border: '#F0F0F0',
    shadow: '#00000008',
    activeBg: '#E6F7FF',
    disabledText: '#BBBBBB'
  },
  [ColorMode.HIGH_CONTRAST]: {
    primary: '#0A5FD9',
    bg: '#FFFFFF',
    cardBg: '#FFFFFF',
    textPrimary: '#000000',
    textSecondary: '#333333',
    textHint: '#555555',
    success: '#006400',
    warning: '#B8860B',
    error: '#CC0000',
    border: '#CCCCCC',
    shadow: '#00000015',
    activeBg: '#D6EBFF',
    disabledText: '#777777'
  },
  [ColorMode.COLOR_BLIND_FRIENDLY]: {
    primary: '#0066CC',
    bg: '#F5F7FA',
    cardBg: '#FFFFFF',
    textPrimary: '#1A1A1A',
    textSecondary: '#4A4A4A',
    textHint: '#808080',
    success: '#007B5E',
    warning: '#D4760C',
    error: '#CC2929',
    border: '#E0E0E0',
    shadow: '#00000008',
    activeBg: '#DEECF9',
    disabledText: '#AAAAAA'
  }
};

export class AccessibilityConfig {
  static readonly FONT_SIZE_LEVEL_KEY: string = 'fontSizeLevel';
  static readonly COLOR_MODE_KEY: string = 'colorMode';
  static readonly ANIMATION_MODE_KEY: string = 'animationMode';
  static readonly IS_OLD_MODE_KEY: string = 'isOldModeEnabled';
  static readonly TTS_ENABLED_KEY: string = 'ttsEnabled';
  static readonly FIRST_TIME_GUIDE_SHOWN: string = 'firstTimeGuideShown';

  static getFontSizeLevel(): FontSizeLevel {
    const level = AppStorage.get<string>(AccessibilityConfig.FONT_SIZE_LEVEL_KEY);
    return (level as FontSizeLevel) || FontSizeLevel.MEDIUM;
  }

  static setFontSizeLevel(level: FontSizeLevel): void {
    AppStorage.setOrCreate<string>(AccessibilityConfig.FONT_SIZE_LEVEL_KEY, level);
  }

  static getColorMode(): ColorMode {
    const mode = AppStorage.get<string>(AccessibilityConfig.COLOR_MODE_KEY);
    return (mode as ColorMode) || ColorMode.NORMAL;
  }

  static setColorMode(mode: ColorMode): void {
    AppStorage.setOrCreate<string>(AccessibilityConfig.COLOR_MODE_KEY, mode);
  }

  static getAnimationMode(): AnimationMode {
    const mode = AppStorage.get<string>(AccessibilityConfig.ANIMATION_MODE_KEY);
    return (mode as AnimationMode) || AnimationMode.NORMAL;
  }

  static setAnimationMode(mode: AnimationMode): void {
    AppStorage.setOrCreate<string>(AccessibilityConfig.ANIMATION_MODE_KEY, mode);
  }

  static isOldModeEnabled(): boolean {
    const val = AppStorage.get<boolean>(AccessibilityConfig.IS_OLD_MODE_KEY);
    return val ? val : false;
  }

  static isTTSEnabled(): boolean {
    const val = AppStorage.get<boolean>(AccessibilityConfig.TTS_ENABLED_KEY);
    return val ? val : false;
  }

  static setTTSEnabled(enabled: boolean): void {
    AppStorage.setOrCreate<boolean>(AccessibilityConfig.TTS_ENABLED_KEY, enabled);
  }

  static isFirstTimeGuideShown(): boolean {
    const val = AppStorage.get<boolean>(AccessibilityConfig.FIRST_TIME_GUIDE_SHOWN);
    return val ? val : false;
  }

  static markFirstTimeGuideShown(): void {
    AppStorage.setOrCreate<boolean>(AccessibilityConfig.FIRST_TIME_GUIDE_SHOWN, true);
  }

  static getFontSizes(): FontSizeConfig {
    const level = this.getFontSizeLevel();
    return FONT_SIZE_CONFIGS[level];
  }

  static getTouchAreas(): TouchAreaConfig {
    const level = this.getFontSizeLevel();
    return TOUCH_AREA_CONFIGS[level];
  }

  static getSpacing(): SpacingConfig {
    const level = this.getFontSizeLevel();
    return SPACING_CONFIGS[level];
  }

  static getColors(): ColorScheme {
    const mode = this.getColorMode();
    return COLOR_SCHEMES[mode];
  }

  static getFontSizeTitle(): number {
    return this.getFontSizes().title;
  }

  static getFontSizeSubtitle(): number {
    return this.getFontSizes().subtitle;
  }

  static getFontSizeBody(): number {
    return this.getFontSizes().body;
  }

  static getFontSizeSmall(): number {
    return this.getFontSizes().small;
  }

  static getFontSizeTiny(): number {
    return this.getFontSizes().tiny;
  }

  static getFontSizeButton(): number {
    return this.getFontSizes().button;
  }

  static getButtonHeight(): number {
    return this.getTouchAreas().buttonHeight;
  }

  static getMinTouchSize(): number {
    return this.getTouchAreas().minTouchWidth;
  }

  static getIconButtonSize(): number {
    return this.getTouchAreas().iconButtonSize;
  }

  static getListItemPadding(): number {
    return this.getTouchAreas().listItemPadding;
  }

  static getSpacingXS(): number {
    return this.getSpacing().xs;
  }

  static getSpacingSM(): number {
    return this.getSpacing().sm;
  }

  static getSpacingMD(): number {
    return this.getSpacing().md;
  }

  static getSpacingLG(): number {
    return this.getSpacing().lg;
  }

  static getSpacingXL(): number {
    return this.getSpacing().xl;
  }

  static getThemeColor(): string {
    return this.getColors().primary;
  }

  static getBgColor(): string {
    return this.getColors().bg;
  }

  static getCardBgColor(): string {
    return this.getColors().cardBg;
  }

  static getTextPrimary(): string {
    return this.getColors().textPrimary;
  }

  static getTextSecondary(): string {
    return this.getColors().textSecondary;
  }

  static getTextHint(): string {
    return this.getColors().textHint;
  }

  static getSuccessColor(): string {
    return this.getColors().success;
  }

  static getWarningColor(): string {
    return this.getColors().warning;
  }

  static getErrorColor(): string {
    return this.getColors().error;
  }

  static getBorderColor(): string {
    return this.getColors().border;
  }

  static getShadowColor(): string {
    return this.getColors().shadow;
  }

  static getActiveBgColor(): string {
    return this.getColors().activeBg;
  }

  static isReducedMotion(): boolean {
    const mode = this.getAnimationMode();
    return mode === AnimationMode.REDUCED || mode === AnimationMode.NONE;
  }

  static shouldShowAnimation(): boolean {
    return this.getAnimationMode() !== AnimationMode.NONE;
  }

  static resetToDefault(): void {
    this.setFontSizeLevel(FontSizeLevel.MEDIUM);
    this.setColorMode(ColorMode.NORMAL);
    this.setAnimationMode(AnimationMode.NORMAL);
    this.setTTSEnabled(false);
  }
}