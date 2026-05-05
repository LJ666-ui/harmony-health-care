import { display } from '@kit.ArkUI';

export enum BreakpointType {
  SM = 'sm',
  MD = 'md',
  LG = 'lg'
}

export interface BreakpointRange {
  type: BreakpointType;
  minWidth: number;
  maxWidth: number;
}

export class BreakpointConstants {
  static readonly SM_MAX_WIDTH: number = 600;
  static readonly MD_MAX_WIDTH: number = 840;

  static readonly RANGES: BreakpointRange[] = [
    { type: BreakpointType.SM, minWidth: 0, maxWidth: BreakpointConstants.SM_MAX_WIDTH },
    { type: BreakpointType.MD, minWidth: BreakpointConstants.SM_MAX_WIDTH, maxWidth: BreakpointConstants.MD_MAX_WIDTH },
    { type: BreakpointType.LG, minWidth: BreakpointConstants.MD_MAX_WIDTH, maxWidth: Number.MAX_SAFE_INTEGER }
  ];

  static readonly GRID_COLUMNS: Record<string, number> = {
    [BreakpointType.SM]: 4,
    [BreakpointType.MD]: 8,
    [BreakpointType.LG]: 12
  };

  static readonly GUTTER: Record<string, number> = {
    [BreakpointType.SM]: 8,
    [BreakpointType.MD]: 12,
    [BreakpointType.LG]: 16
  };

  static readonly CONTENT_MAX_WIDTH: Record<string, number> = {
    [BreakpointType.SM]: 360,
    [BreakpointType.MD]: 600,
    [BreakpointType.LG]: 840
  };

  static readonly QUICK_ACTION_COLUMNS: Record<string, number> = {
    [BreakpointType.SM]: 4,
    [BreakpointType.MD]: 4,
    [BreakpointType.LG]: 6
  };

  static readonly CARD_SPAN: Record<string, number> = {
    [BreakpointType.SM]: 4,
    [BreakpointType.MD]: 4,
    [BreakpointType.LG]: 6
  };

  static readonly LIST_COLUMNS: Record<string, number> = {
    [BreakpointType.SM]: 1,
    [BreakpointType.MD]: 2,
    [BreakpointType.LG]: 3
  };

  static readonly SIDE_PANEL_RATIO: Record<string, number> = {
    [BreakpointType.SM]: 0,
    [BreakpointType.MD]: 0.35,
    [BreakpointType.LG]: 0.3
  };
}

export class BreakpointSystem {
  private static instance: BreakpointSystem | null = null;
  private currentBreakpoint: BreakpointType = BreakpointType.SM;
  private listeners: Map<string, (bp: BreakpointType) => void> = new Map();
  private windowWidth: number = 360;

  static getInstance(): BreakpointSystem {
    if (!BreakpointSystem.instance) {
      BreakpointSystem.instance = new BreakpointSystem();
    }
    return BreakpointSystem.instance;
  }

  getCurrentBreakpoint(): BreakpointType {
    return this.currentBreakpoint;
  }

  getWindowWidth(): number {
    return this.windowWidth;
  }

  isSM(): boolean {
    return this.currentBreakpoint === BreakpointType.SM;
  }

  isMD(): boolean {
    return this.currentBreakpoint === BreakpointType.MD;
  }

  isLG(): boolean {
    return this.currentBreakpoint === BreakpointType.LG;
  }

  getGridColumns(): number {
    return BreakpointConstants.GRID_COLUMNS[this.currentBreakpoint] ?? 4;
  }

  getGutter(): number {
    return BreakpointConstants.GUTTER[this.currentBreakpoint] ?? 8;
  }

  getQuickActionColumns(): number {
    return BreakpointConstants.QUICK_ACTION_COLUMNS[this.currentBreakpoint] ?? 4;
  }

  getListColumns(): number {
    return BreakpointConstants.LIST_COLUMNS[this.currentBreakpoint] ?? 1;
  }

  getCardSpan(): number {
    return BreakpointConstants.CARD_SPAN[this.currentBreakpoint] ?? 4;
  }

  getSidePanelRatio(): number {
    return BreakpointConstants.SIDE_PANEL_RATIO[this.currentBreakpoint] ?? 0;
  }

  hasSidePanel(): boolean {
    return this.currentBreakpoint !== BreakpointType.SM;
  }

  getFontSizeScale(): number {
    switch (this.currentBreakpoint) {
      case BreakpointType.SM:
        return 1.0;
      case BreakpointType.MD:
        return 1.05;
      case BreakpointType.LG:
        return 1.1;
      default:
        return 1.0;
    }
  }

  getIconSize(baseSize: number): number {
    return Math.round(baseSize * this.getFontSizeScale());
  }

  getPaddingScale(): number {
    switch (this.currentBreakpoint) {
      case BreakpointType.SM:
        return 1.0;
      case BreakpointType.MD:
        return 1.25;
      case BreakpointType.LG:
        return 1.5;
      default:
        return 1.0;
    }
  }

  getScaledPadding(basePadding: number): number {
    return Math.round(basePadding * this.getPaddingScale());
  }

  registerListener(id: string, callback: (bp: BreakpointType) => void): void {
    this.listeners.set(id, callback);
  }

  unregisterListener(id: string): void {
    this.listeners.delete(id);
  }

  updateBreakpoint(width: number): void {
    this.windowWidth = width;
    let newBreakpoint: BreakpointType = BreakpointType.SM;

    if (width >= BreakpointConstants.MD_MAX_WIDTH) {
      newBreakpoint = BreakpointType.LG;
    } else if (width >= BreakpointConstants.SM_MAX_WIDTH) {
      newBreakpoint = BreakpointType.MD;
    }

    if (newBreakpoint !== this.currentBreakpoint) {
      this.currentBreakpoint = newBreakpoint;
      this.listeners.forEach((callback) => {
        callback(newBreakpoint);
      });
    }
  }

  static calculateBreakpoint(width: number): BreakpointType {
    if (width >= BreakpointConstants.MD_MAX_WIDTH) {
      return BreakpointType.LG;
    } else if (width >= BreakpointConstants.SM_MAX_WIDTH) {
      return BreakpointType.MD;
    }
    return BreakpointType.SM;
  }
}
