/**
 * 无障碍配置工具类
 * 提供无障碍功能的统一管理和配置
 * 
 * 根据项目规划V14.0 - 9.3提示词6要求开发
 */

/**
 * 无障碍配置接口
 */
export interface AccessibilityConfig {
  // 老年模式
  isElderMode: boolean;
  
  // 高对比度模式
  isHighContrastMode: boolean;
  
  // 大字体模式
  isLargeTextMode: boolean;
  
  // 屏幕阅读器模式
  isScreenReaderEnabled: boolean;
  
  // 语音控制模式
  isVoiceControlEnabled: boolean;
  
  // 触觉反馈
  isHapticFeedbackEnabled: boolean;
  
  // 字体缩放比例
  fontScale: number;
}

/**
 * 字体大小配置
 */
export interface FontSizeConfig {
  // 标题字体
  title: number;
  
  // 正文字体
  body: number;
  
  // 辅助文字
  caption: number;
  
  // 按钮文字
  button: number;
  
  // 输入框文字
  input: number;
}

/**
 * 颜色配置
 */
export interface ColorConfig {
  // 主色
  primary: string;
  
  // 背景色
  background: string;
  
  // 文字色
  text: string;
  
  // 辅助文字色
  textSecondary: string;
  
  // 错误色
  error: string;
  
  // 成功色
  success: string;
  
  // 警告色
  warning: string;
}

/**
 * 无障碍配置管理类
 */
export class AccessibilityManager {
  private static instance: AccessibilityManager;
  private config: AccessibilityConfig;
  
  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
    // 从AppStorage加载配置
    this.config = {
      isElderMode: AppStorage.get<boolean>('isElderMode') || false,
      isHighContrastMode: AppStorage.get<boolean>('isHighContrastMode') || false,
      isLargeTextMode: AppStorage.get<boolean>('isLargeTextMode') || false,
      isScreenReaderEnabled: AppStorage.get<boolean>('isScreenReaderEnabled') || false,
      isVoiceControlEnabled: AppStorage.get<boolean>('isVoiceControlEnabled') || false,
      isHapticFeedbackEnabled: AppStorage.get<boolean>('isHapticFeedbackEnabled') || true,
      fontScale: AppStorage.get<number>('fontScale') || 1.0
    };
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): AccessibilityManager {
    if (!AccessibilityManager.instance) {
      AccessibilityManager.instance = new AccessibilityManager();
    }
    return AccessibilityManager.instance;
  }
  
  /**
   * 获取当前配置
   */
  public getConfig(): AccessibilityConfig {
    return { ...this.config };
  }
  
  /**
   * 切换老年模式
   */
  public toggleElderMode(): void {
    this.config.isElderMode = !this.config.isElderMode;
    AppStorage.setOrCreate<boolean>('isElderMode', this.config.isElderMode);
    
    // 老年模式自动启用大字体
    if (this.config.isElderMode) {
      this.setFontScale(1.25);
    } else {
      this.setFontScale(1.0);
    }
    
    console.log('[Accessibility] 老年模式:', this.config.isElderMode ? '已启用' : '已关闭');
  }
  
  /**
   * 切换高对比度模式
   */
  public toggleHighContrastMode(): void {
    this.config.isHighContrastMode = !this.config.isHighContrastMode;
    AppStorage.setOrCreate<boolean>('isHighContrastMode', this.config.isHighContrastMode);
    console.log('[Accessibility] 高对比度模式:', this.config.isHighContrastMode ? '已启用' : '已关闭');
  }
  
  /**
   * 切换大字体模式
   */
  public toggleLargeTextMode(): void {
    this.config.isLargeTextMode = !this.config.isLargeTextMode;
    AppStorage.setOrCreate<boolean>('isLargeTextMode', this.config.isLargeTextMode);
    
    if (this.config.isLargeTextMode) {
      this.setFontScale(1.5);
    } else {
      this.setFontScale(1.0);
    }
    
    console.log('[Accessibility] 大字体模式:', this.config.isLargeTextMode ? '已启用' : '已关闭');
  }
  
  /**
   * 设置字体缩放比例
   */
  public setFontScale(scale: number): void {
    this.config.fontScale = Math.max(0.8, Math.min(2.0, scale));
    AppStorage.setOrCreate<number>('fontScale', this.config.fontScale);
    console.log('[Accessibility] 字体缩放比例:', this.config.fontScale);
  }
  
  /**
   * 获取字体大小配置
   */
  public getFontSizeConfig(): FontSizeConfig {
    const baseConfig: FontSizeConfig = {
      title: 20,
      body: 16,
      caption: 14,
      button: 16,
      input: 16
    };
    
    // 老年模式字体增大
    if (this.config.isElderMode) {
      return {
        title: 24,
        body: 20,
        caption: 18,
        button: 20,
        input: 20
      };
    }
    
    // 应用字体缩放
    const scale = this.config.fontScale;
    return {
      title: Math.round(baseConfig.title * scale),
      body: Math.round(baseConfig.body * scale),
      caption: Math.round(baseConfig.caption * scale),
      button: Math.round(baseConfig.button * scale),
      input: Math.round(baseConfig.input * scale)
    };
  }
  
  /**
   * 获取颜色配置
   */
  public getColorConfig(): ColorConfig {
    // 高对比度模式
    if (this.config.isHighContrastMode) {
      return {
        primary: '#0000FF',
        background: '#FFFFFF',
        text: '#000000',
        textSecondary: '#333333',
        error: '#FF0000',
        success: '#00AA00',
        warning: '#FF8800'
      };
    }
    
    // 标准模式
    return {
      primary: '#3498DB',
      background: '#F8F9FA',
      text: '#333333',
      textSecondary: '#666666',
      error: '#E74C3C',
      success: '#2ECC71',
      warning: '#F39C12'
    };
  }
  
  /**
   * 获取最小触控尺寸
   */
  public getMinTouchSize(): number {
    return this.config.isElderMode ? 48 : 44; // dp
  }
  
  /**
   * 获取页面边距
   */
  public getPagePadding(): number {
    return this.config.isElderMode ? 20 : 16; // dp
  }
  
  /**
   * 获取组件间距
   */
  public getComponentGap(): number {
    return this.config.isElderMode ? 16 : 12; // dp
  }
  
  /**
   * 触觉反馈
   */
  public hapticFeedback(type: 'light' | 'medium' | 'heavy' = 'light'): void {
    if (!this.config.isHapticFeedbackEnabled) {
      return;
    }
    
    // 调用振动API（实际项目中应使用HarmonyOS振动API）
    try {
      // vibrator.vibrate(type === 'light' ? 10 : type === 'medium' ? 30 : 50);
      console.log('[Accessibility] 触觉反馈:', type);
    } catch (error) {
      console.error('[Accessibility] 触觉反馈失败:', error);
    }
  }
  
  /**
   * 语音播报
   */
  public speak(text: string): void {
    if (!this.config.isScreenReaderEnabled) {
      return;
    }
    
    // 调用TTS API（实际项目中应使用HarmonyOS TTS API）
    try {
      // tts.speak(text);
      console.log('[Accessibility] 语音播报:', text);
    } catch (error) {
      console.error('[Accessibility] 语音播报失败:', error);
    }
  }
}

/**
 * 无障碍装饰器
 * 为组件自动添加无障碍属性
 */
export function Accessible(options: {
  label: string;
  hint?: string;
  role?: 'button' | 'link' | 'heading' | 'list' | 'listItem';
  level?: 'important' | 'normal' | 'low';
}) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;
    
    descriptor.value = function (...args: any[]) {
      // 添加无障碍属性
      const result = originalMethod.apply(this, args);
      
      // 在实际应用中，这里可以自动为组件添加accessibility属性
      console.log(`[Accessibility] 组件 ${propertyKey} 已添加无障碍属性:`, options);
      
      return result;
    };
    
    return descriptor;
  };
}

/**
 * 颜色对比度计算工具
 */
export class ColorContrastUtil {
  /**
   * 计算相对亮度
   */
  private static getRelativeLuminance(color: string): number {
    // 解析RGB值
    const hex = color.replace('#', '');
    const r = parseInt(hex.substring(0, 2), 16) / 255;
    const g = parseInt(hex.substring(2, 4), 16) / 255;
    const b = parseInt(hex.substring(4, 6), 16) / 255;
    
    // 计算相对亮度
    const R = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4);
    const G = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4);
    const B = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4);
    
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }
  
  /**
   * 计算对比度
   */
  public static getContrastRatio(color1: string, color2: string): number {
    const L1 = this.getRelativeLuminance(color1);
    const L2 = this.getRelativeLuminance(color2);
    
    const lighter = Math.max(L1, L2);
    const darker = Math.min(L1, L2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /**
   * 检查是否符合WCAG AA标准
   */
  public static meetsWCAGAA(color1: string, color2: string, isLargeText: boolean = false): boolean {
    const ratio = this.getContrastRatio(color1, color2);
    const threshold = isLargeText ? 3.0 : 4.5;
    return ratio >= threshold;
  }
}

/**
 * 导出单例实例
 */
export const accessibilityManager = AccessibilityManager.getInstance();
