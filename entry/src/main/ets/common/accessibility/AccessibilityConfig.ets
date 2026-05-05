/**
 * 无障碍配置管理类
 * 提供无障碍配置的管理、存储和应用功能
 * 符合WCAG 2.1 AA级标准
 */

/**
 * 无障碍配置接口
 */
export interface AccessibilitySettings {
  // 老年模式（大字体、大按钮、简化操作）
  elderlyMode: boolean;
  
  // 大字体模式
  largeFontMode: boolean;
  
  // 高对比度模式
  highContrastMode: boolean;
  
  // 最小触控区域（dp）
  minTouchTarget: number;
  
  // 基础字体大小（sp）
  baseFontSize: number;
  
  // 语音引导开关
  voiceGuidance: boolean;
  
  // 屏幕阅读器支持
  screenReaderSupport: boolean;
  
  // 操作确认级别（none/important/all）
  confirmationLevel: 'none' | 'important' | 'all';
  
  // 动画简化（减少动画效果）
  reduceMotion: boolean;
  
  // 颜色对比度等级
  contrastRatio: number;
}

/**
 * 配置变更监听器类型
 */
export type ConfigChangeListener = (newSettings: AccessibilitySettings) => void;

/**
 * 无障碍配置管理类（单例模式）
 */
export class AccessibilityConfig {
  private static instance: AccessibilityConfig;
  private settings: AccessibilitySettings;
  private listeners: ConfigChangeListener[] = [];
  
  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
    this.settings = this.getDefaultSettings();
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): AccessibilityConfig {
    if (!AccessibilityConfig.instance) {
      AccessibilityConfig.instance = new AccessibilityConfig();
    }
    return AccessibilityConfig.instance;
  }
  
  /**
   * 获取默认配置
   */
  private getDefaultSettings(): AccessibilitySettings {
    return {
      elderlyMode: false,
      largeFontMode: false,
      highContrastMode: false,
      minTouchTarget: 44, // WCAG 2.1推荐最小触控区域
      baseFontSize: 16,   // 标准字体大小
      voiceGuidance: false,
      screenReaderSupport: false,
      confirmationLevel: 'important',
      reduceMotion: false,
      contrastRatio: 4.5  // WCAG AA级标准
    };
  }
  
  /**
   * 初始化配置（从本地存储加载）
   */
  public async initialize(): Promise<void> {
    try {
      // 尝试从AppStorage加载已保存的配置
      const savedConfig = AppStorage.get<string>('accessibility_config');
      
      if (savedConfig) {
        this.settings = JSON.parse(savedConfig) as AccessibilitySettings;
      } else {
        this.settings = this.getDefaultSettings();
      }
      
      // 应用配置到全局
      this.applySettings();
      
      console.info('[AccessibilityConfig] 配置初始化成功');
    } catch (error) {
      console.error('[AccessibilityConfig] 初始化失败:', error);
      this.settings = this.getDefaultSettings();
      this.applySettings();
    }
  }
  
  /**
   * 获取当前配置
   */
  public getSettings(): AccessibilitySettings {
    return { ...this.settings };
  }
  
  /**
   * 更新配置
   * @param newSettings 部分新配置
   */
  public async updateSettings(newSettings: Partial<AccessibilitySettings>): Promise<void> {
    // 合并新旧配置
    this.settings = { ...this.settings, ...newSettings };
    
    // 应用配置到全局
    this.applySettings();
    
    // 通知所有监听器
    this.notifyListeners();
    
    // 持久化配置
    await this.persistSettings();
    
    console.info('[AccessibilityConfig] 配置已更新:', newSettings);
  }
  
  /**
   * 应用配置到全局样式（AppStorage）
   */
  private applySettings(): void {
    // 计算实际字体大小
    let fontSize = this.settings.baseFontSize;
    if (this.settings.elderlyMode) {
      fontSize = 20; // 老年模式使用20sp
    } else if (this.settings.largeFontMode) {
      fontSize = 18; // 大字体模式使用18sp
    }
    
    // 计算实际触控区域大小
    let minTouchTarget = this.settings.minTouchTarget;
    if (this.settings.elderlyMode) {
      minTouchTarget = 52; // 老年模式增大触控区域
    }
    
    // 应用到AppStorage（全局状态）
    AppStorage.setOrCreate('fontSize', fontSize);
    AppStorage.setOrCreate('minTouchTarget', minTouchTarget);
    AppStorage.setOrCreate('highContrast', this.settings.highContrastMode);
    AppStorage.setOrCreate('elderlyMode', this.settings.elderlyMode);
    AppStorage.setOrCreate('reduceMotion', this.settings.reduceMotion);
    AppStorage.setOrCreate('voiceGuidance', this.settings.voiceGuidance);
  }
  
  /**
   * 持久化配置到本地存储
   */
  private async persistSettings(): Promise<void> {
    try {
      const configString = JSON.stringify(this.settings);
      AppStorage.setOrCreate('accessibility_config', configString);
    } catch (error) {
      console.error('[AccessibilityConfig] 持久化配置失败:', error);
    }
  }
  
  /**
   * 添加配置变更监听器
   * @param listener 监听器函数
   */
  public addListener(listener: ConfigChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }
  
  /**
   * 移除配置变更监听器
   * @param listener 监听器函数
   */
  public removeListener(listener: ConfigChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index !== -1) {
      this.listeners.splice(index, 1);
    }
  }
  
  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    const currentSettings = this.getSettings();
    this.listeners.forEach((listener) => {
      try {
        listener(currentSettings);
      } catch (error) {
        console.error('[AccessibilityConfig] 监听器执行失败:', error);
      }
    });
  }
  
  /**
   * 重置为默认配置
   */
  public async resetToDefault(): Promise<void> {
    this.settings = this.getDefaultSettings();
    this.applySettings();
    this.notifyListeners();
    await this.persistSettings();
    console.info('[AccessibilityConfig] 配置已重置为默认值');
  }
  
  /**
   * 启用老年模式（一键开启所有老年友好特性）
   */
  public async enableElderlyMode(): Promise<void> {
    await this.updateSettings({
      elderlyMode: true,
      largeFontMode: true,
      minTouchTarget: 52,
      baseFontSize: 20,
      voiceGuidance: true,
      confirmationLevel: 'all',
      reduceMotion: true,
      contrastRatio: 7.0 // AAA级对比度
    });
  }
  
  /**
   * 禁用老年模式（恢复标准模式）
   */
  public async disableElderlyMode(): Promise<void> {
    await this.updateSettings({
      elderlyMode: false,
      largeFontMode: false,
      minTouchTarget: 44,
      baseFontSize: 16,
      confirmationLevel: 'important',
      reduceMotion: false,
      contrastRatio: 4.5
    });
  }
  
  /**
   * 检查是否需要操作确认
   * @param isImportant 是否为重要操作
   */
  public needsConfirmation(isImportant: boolean): boolean {
    switch (this.settings.confirmationLevel) {
      case 'none':
        return false;
      case 'important':
        return isImportant;
      case 'all':
        return true;
      default:
        return isImportant;
    }
  }
  
  /**
   * 获取当前字体大小
   */
  public getFontSize(): number {
    if (this.settings.elderlyMode) {
      return 20;
    } else if (this.settings.largeFontMode) {
      return 18;
    }
    return this.settings.baseFontSize;
  }
  
  /**
   * 获取当前触控区域大小
   */
  public getTouchTargetSize(): number {
    return this.settings.elderlyMode ? 52 : this.settings.minTouchTarget;
  }
  
  /**
   * 获取文本颜色（考虑高对比度模式）
   * @param normalColor 正常模式颜色
   * @param highContrastColor 高对比度模式颜色
   */
  public getTextColor(normalColor: string, highContrastColor?: string): string {
    if (this.settings.highContrastMode) {
      return highContrastColor ?? '#000000';
    }
    return normalColor;
  }
  
  /**
   * 获取背景颜色（考虑高对比度模式）
   * @param normalColor 正常模式颜色
   * @param highContrastColor 高对比度模式颜色
   */
  public getBackgroundColor(normalColor: string, highContrastColor?: string): string {
    if (this.settings.highContrastMode) {
      return highContrastColor ?? '#FFFFFF';
    }
    return normalColor;
  }
}
