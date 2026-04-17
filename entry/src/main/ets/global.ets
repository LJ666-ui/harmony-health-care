import { AccessibilityConfig, FontSizeLevel } from './utils/AccessibilityConfig';

export class GlobalTheme {
  static readonly IS_OLD_MODE_KEY: string = 'isOldModeEnabled';

  static readonly THEME_COLOR: string = '#1677FF';
  static readonly BG_COLOR: string = '#F5F7FA';
  static readonly CARD_BG: string = '#FFFFFF';
  static readonly TEXT_PRIMARY: string = '#333333';
  static readonly TEXT_SECONDARY: string = '#666666';
  static readonly TEXT_HINT: string = '#999999';
  static readonly TEXT_LIGHT: string = '#BBBBBB';

  static readonly SUCCESS_COLOR: string = '#52C41A';
  static readonly WARNING_COLOR: string = '#FAAD14';
  static readonly ERROR_COLOR: string = '#FF4D4F';
  static readonly BUTTON_TEXT_COLOR: string = '#FFFFFF';

  static readonly BORDER_COLOR: string = '#F0F0F0';
  static readonly SHADOW_COLOR: string = '#00000008';

  static getFontSizeTitle(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getFontSizeTitle();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.FONT_SIZE_TITLE_ELDER : GlobalTheme.FONT_SIZE_TITLE_NORMAL;
    }
    return AccessibilityConfig.getFontSizeTitle();
  }

  static getFontSizeSubtitle(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getFontSizeSubtitle();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.FONT_SIZE_SUBTITLE_ELDER : GlobalTheme.FONT_SIZE_SUBTITLE_NORMAL;
    }
    return AccessibilityConfig.getFontSizeSubtitle();
  }

  static getFontSizeBody(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getFontSizeBody();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.FONT_SIZE_BODY_ELDER : GlobalTheme.FONT_SIZE_BODY_NORMAL;
    }
    return AccessibilityConfig.getFontSizeBody();
  }

  static getFontSizeSmall(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getFontSizeSmall();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.FONT_SIZE_SMALL_ELDER : GlobalTheme.FONT_SIZE_SMALL_NORMAL;
    }
    return AccessibilityConfig.getFontSizeSmall();
  }

  static getFontSizeTiny(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getFontSizeTiny();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.FONT_SIZE_TINY_ELDER : GlobalTheme.FONT_SIZE_TINY_NORMAL;
    }
    return AccessibilityConfig.getFontSizeTiny();
  }

  static getButtonHeight(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getButtonHeight();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.BUTTON_HEIGHT_ELDER : GlobalTheme.BUTTON_HEIGHT_NORMAL;
    }
    return AccessibilityConfig.getButtonHeight();
  }

  static getSpacingXS(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getSpacingXS();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.SPACING_XS_ELDER : GlobalTheme.SPACING_XS_NORMAL;
    }
    return AccessibilityConfig.getSpacingXS();
  }

  static getSpacingSM(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getSpacingSM();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.SPACING_SM_ELDER : GlobalTheme.SPACING_SM_NORMAL;
    }
    return AccessibilityConfig.getSpacingSM();
  }

  static getSpacingMD(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getSpacingMD();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.SPACING_MD_ELDER : GlobalTheme.SPACING_MD_NORMAL;
    }
    return AccessibilityConfig.getSpacingMD();
  }

  static getSpacingLG(isElderMode?: boolean): number {
    const useAccessibility = AppStorage.get<string>('fontSizeLevel') !== undefined;
    if (useAccessibility) {
      return AccessibilityConfig.getSpacingLG();
    }
    if (isElderMode !== undefined) {
      return isElderMode ? GlobalTheme.SPACING_LG_ELDER : GlobalTheme.SPACING_LG_NORMAL;
    }
    return AccessibilityConfig.getSpacingLG();
  }

  static readonly FONT_SIZE_TITLE_NORMAL: number = 24;
  static readonly FONT_SIZE_TITLE_ELDER: number = 30;

  static readonly FONT_SIZE_SUBTITLE_NORMAL: number = 20;
  static readonly FONT_SIZE_SUBTITLE_ELDER: number = 26;

  static readonly FONT_SIZE_BODY_NORMAL: number = 16;
  static readonly FONT_SIZE_BODY_ELDER: number = 22;

  static readonly FONT_SIZE_SMALL_NORMAL: number = 13;
  static readonly FONT_SIZE_SMALL_ELDER: number = 18;

  static readonly FONT_SIZE_TINY_NORMAL: number = 11;
  static readonly FONT_SIZE_TINY_ELDER: number = 15;

  static readonly BUTTON_HEIGHT_NORMAL: number = 50;
  static readonly BUTTON_HEIGHT_ELDER: number = 60;

  static readonly SPACING_XS_NORMAL: number = 4;
  static readonly SPACING_XS_ELDER: number = 6;

  static readonly SPACING_SM_NORMAL: number = 8;
  static readonly SPACING_SM_ELDER: number = 12;

  static readonly SPACING_MD_NORMAL: number = 16;
  static readonly SPACING_MD_ELDER: number = 22;

  static readonly SPACING_LG_NORMAL: number = 20;
  static readonly SPACING_LG_ELDER: number = 28;

  static readonly RADIUS_SM: number = 8;
  static readonly RADIUS_MD: number = 12;
  static readonly RADIUS_LG: number = 16;
}