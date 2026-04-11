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

  static readonly BORDER_COLOR: string = '#F0F0F0';
  static readonly SHADOW_COLOR: string = '#00000008';

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

  static getFontSizeTitle(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.FONT_SIZE_TITLE_ELDER : GlobalTheme.FONT_SIZE_TITLE_NORMAL;
  }

  static getFontSizeSubtitle(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.FONT_SIZE_SUBTITLE_ELDER : GlobalTheme.FONT_SIZE_SUBTITLE_NORMAL;
  }

  static getFontSizeBody(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.FONT_SIZE_BODY_ELDER : GlobalTheme.FONT_SIZE_BODY_NORMAL;
  }

  static getFontSizeSmall(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.FONT_SIZE_SMALL_ELDER : GlobalTheme.FONT_SIZE_SMALL_NORMAL;
  }

  static getFontSizeTiny(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.FONT_SIZE_TINY_ELDER : GlobalTheme.FONT_SIZE_TINY_NORMAL;
  }

  static getButtonHeight(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.BUTTON_HEIGHT_ELDER : GlobalTheme.BUTTON_HEIGHT_NORMAL;
  }

  static getSpacingXS(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.SPACING_XS_ELDER : GlobalTheme.SPACING_XS_NORMAL;
  }

  static getSpacingSM(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.SPACING_SM_ELDER : GlobalTheme.SPACING_SM_NORMAL;
  }

  static getSpacingMD(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.SPACING_MD_ELDER : GlobalTheme.SPACING_MD_NORMAL;
  }

  static getSpacingLG(isElderMode: boolean): number {
    return isElderMode ? GlobalTheme.SPACING_LG_ELDER : GlobalTheme.SPACING_LG_NORMAL;
  }
}
