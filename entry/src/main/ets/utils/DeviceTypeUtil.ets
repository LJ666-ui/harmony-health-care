/**
 * 设备类型检测工具类
 * 用于识别当前设备类型并提供相应的UI适配
 */
import { display } from '@kit.ArkUI';

export enum DeviceType {
  PHONE = 'phone',
  TABLET = 'tablet',
  TWO_IN_ONE = '2in1',
  WEARABLE = 'wearable',
  UNKNOWN = 'unknown'
}

export class DeviceTypeUtil {
  private static instance: DeviceTypeUtil;
  private currentDeviceType: DeviceType = DeviceType.UNKNOWN;
  private screenWidth: number = 0;
  private screenHeight: number = 0;

  private constructor() {
    this.initDeviceType();
  }

  public static getInstance(): DeviceTypeUtil {
    if (!DeviceTypeUtil.instance) {
      DeviceTypeUtil.instance = new DeviceTypeUtil();
    }
    return DeviceTypeUtil.instance;
  }

  /**
   * 初始化设备类型
   */
  private initDeviceType(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync();
      this.screenWidth = displayInfo.width;
      this.screenHeight = displayInfo.height;

      // 根据屏幕宽度和高度判断设备类型
      // 手环/手表: 宽度和高度都较小（通常 < 500vp），且接近正方形或圆形
      // 手机: 300-600vp
      // 平板竖屏: 600-840vp
      // 平板横屏/2in1: > 840vp
      const minDimension = Math.min(this.screenWidth, this.screenHeight);
      const maxDimension = Math.max(this.screenWidth, this.screenHeight);
      const aspectRatio = maxDimension / minDimension;

      // 手表/手环特征：屏幕小（< 500vp）且接近正方形（宽高比 < 1.3）
      if (minDimension < 500 && aspectRatio < 1.3) {
        this.currentDeviceType = DeviceType.WEARABLE;
      } else if (this.screenWidth < 600) {
        this.currentDeviceType = DeviceType.PHONE;
      } else if (this.screenWidth < 840) {
        this.currentDeviceType = DeviceType.TABLET;
      } else {
        this.currentDeviceType = DeviceType.TWO_IN_ONE;
      }

      console.info('[DeviceTypeUtil] 设备类型检测: 宽度=' + this.screenWidth + 
                   ', 高度=' + this.screenHeight + 
                   ', 类型=' + this.currentDeviceType);
    } catch (error) {
      console.error('[DeviceTypeUtil] 初始化设备类型失败:', error);
      this.currentDeviceType = DeviceType.PHONE;
    }
  }

  /**
   * 获取当前设备类型
   */
  public getDeviceType(): DeviceType {
    return this.currentDeviceType;
  }

  /**
   * 判断是否为手环/手表设备
   */
  public isWatchOrWearable(): boolean {
    return this.currentDeviceType === DeviceType.WEARABLE;
  }

  /**
   * 判断是否为手机设备
   */
  public isPhone(): boolean {
    return this.currentDeviceType === DeviceType.PHONE;
  }

  /**
   * 判断是否为平板设备
   */
  public isTablet(): boolean {
    return this.currentDeviceType === DeviceType.TABLET;
  }

  /**
   * 判断是否为2in1设备
   */
  public is2In1(): boolean {
    return this.currentDeviceType === DeviceType.TWO_IN_ONE;
  }

  /**
   * 获取屏幕宽度
   */
  public getScreenWidth(): number {
    return this.screenWidth;
  }

  /**
   * 获取适配后的字体大小
   * @param baseSize 基础字体大小
   */
  public getAdaptiveFontSize(baseSize: number): number {
    if (this.isWatchOrWearable()) {
      // 手环手表字体缩小30%
      return Math.round(baseSize * 0.7);
    } else if (this.isPhone()) {
      return baseSize;
    } else if (this.isTablet()) {
      // 平板字体放大10%
      return Math.round(baseSize * 1.1);
    } else {
      // 2in1字体放大20%
      return Math.round(baseSize * 1.2);
    }
  }

  /**
   * 获取适配后的间距
   * @param baseSpacing 基础间距
   */
  public getAdaptiveSpacing(baseSpacing: number): number {
    if (this.isWatchOrWearable()) {
      // 手环手表间距缩小50%
      return Math.round(baseSpacing * 0.5);
    } else if (this.isPhone()) {
      return baseSpacing;
    } else if (this.isTablet()) {
      return Math.round(baseSpacing * 1.2);
    } else {
      return Math.round(baseSpacing * 1.5);
    }
  }

  /**
   * 获取适配后的图标大小
   * @param baseSize 基础图标大小
   */
  public getAdaptiveIconSize(baseSize: number): number {
    if (this.isWatchOrWearable()) {
      // 手环手表图标缩小40%
      return Math.round(baseSize * 0.6);
    } else if (this.isPhone()) {
      return baseSize;
    } else if (this.isTablet()) {
      return Math.round(baseSize * 1.2);
    } else {
      return Math.round(baseSize * 1.4);
    }
  }

  /**
   * 获取适配后的按钮高度
   * @param baseHeight 基础按钮高度
   */
  public getAdaptiveButtonHeight(baseHeight: number): number {
    if (this.isWatchOrWearable()) {
      // 手环手表按钮高度缩小30%
      return Math.round(baseHeight * 0.7);
    } else if (this.isPhone()) {
      return baseHeight;
    } else if (this.isTablet()) {
      return Math.round(baseHeight * 1.1);
    } else {
      return Math.round(baseHeight * 1.2);
    }
  }

  /**
   * 获取内容区域宽度百分比
   */
  public getContentWidthPercent(): string {
    if (this.isWatchOrWearable()) {
      return '95%';
    } else if (this.isPhone()) {
      return '90%';
    } else if (this.isTablet()) {
      return '80%';
    } else {
      return '70%';
    }
  }

  /**
   * 是否显示完整内容
   * 手环手表只显示精简内容
   */
  public shouldShowFullContent(): boolean {
    return !this.isWatchOrWearable();
  }

  /**
   * 获取每行显示的项目数量
   */
  public getItemsPerRow(): number {
    if (this.isWatchOrWearable()) {
      return 2;
    } else if (this.isPhone()) {
      return 3;
    } else if (this.isTablet()) {
      return 4;
    } else {
      return 6;
    }
  }
}
