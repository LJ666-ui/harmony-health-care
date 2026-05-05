/**
 * 无障碍按钮组件
 * 自动应用无障碍配置，支持最小触控区域、高对比度等特性
 */

import { AccessibilityConfig } from '../../common/accessibility/AccessibilityConfig';

/**
 * 无障碍按钮组件
 */
@Component
export struct AccessibleButton {
  // 从全局状态绑定无障碍配置
  @StorageLink('minTouchTarget') minTouchTarget: number = 44;
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  // 组件属性
  @Prop text: string = '';
  @Prop icon?: Resource;
  @Prop disabled: boolean = false;
  @Prop type: 'primary' | 'secondary' | 'text' = 'primary';
  @Prop width?: number;
  @Prop height?: number;
  @Prop backgroundColor?: string;
  @Prop textColor?: string;
  @Prop borderRadius?: number;
  
  // 事件回调
  private onClickHandler?: () => void;
  
  /**
   * 设置点击事件
   */
  public onClick(handler: () => void): this {
    this.onClickHandler = handler;
    return this;
  }
  
  /**
   * 获取按钮背景色
   */
  private getButtonBackgroundColor(): string {
    if (this.disabled) {
      return '#E0E0E0';
    }
    
    if (this.backgroundColor) {
      return this.backgroundColor;
    }
    
    if (this.highContrast) {
      return this.type === 'primary' ? '#000000' : '#FFFFFF';
    }
    
    switch (this.type) {
      case 'primary':
        return '#3498DB';
      case 'secondary':
        return '#95A5A6';
      case 'text':
        return 'transparent';
      default:
        return '#3498DB';
    }
  }
  
  /**
   * 获取按钮文字颜色
   */
  private getButtonTextColor(): string {
    if (this.disabled) {
      return '#9E9E9E';
    }
    
    if (this.textColor) {
      return this.textColor;
    }
    
    if (this.highContrast) {
      return this.type === 'primary' ? '#FFFFFF' : '#000000';
    }
    
    switch (this.type) {
      case 'primary':
        return '#FFFFFF';
      case 'secondary':
        return '#FFFFFF';
      case 'text':
        return '#3498DB';
      default:
        return '#FFFFFF';
    }
  }
  
  /**
   * 获取按钮宽度
   */
  private getButtonWidth(): number | string {
    if (this.width) {
      return Math.max(this.width, this.minTouchTarget);
    }
    return 'auto';
  }
  
  /**
   * 获取按钮高度
   */
  private getButtonHeight(): number {
    if (this.height) {
      return Math.max(this.height, this.minTouchTarget);
    }
    return this.minTouchTarget;
  }
  
  /**
   * 获取字体大小
   */
  private getButtonTextSize(): number {
    return this.elderlyMode ? this.fontSize + 2 : this.fontSize;
  }
  
  build() {
    Button() {
      Row() {
        // 图标
        if (this.icon) {
          Image(this.icon)
            .width(20)
            .height(20)
            .margin({ right: 8 })
        }
        
        // 文字
        Text(this.text)
          .fontSize(this.getButtonTextSize())
          .fontColor(this.getButtonTextColor())
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width(this.getButtonWidth())
    .height(this.getButtonHeight())
    .backgroundColor(this.getButtonBackgroundColor())
    .borderRadius(this.borderRadius ?? 8)
    .enabled(!this.disabled)
    .opacity(this.disabled ? 0.6 : 1)
    // 无障碍属性
    .accessibilityText(this.text)
    .accessibilityDescription(this.disabled ? `${this.text}，按钮已禁用` : `${this.text}，点击执行操作`)
    .accessibilityLevel(this.type === 'primary' ? 'important' : 'auto')
    // 点击事件
    .onClick(() => {
      if (!this.disabled && this.onClickHandler) {
        this.onClickHandler();
      }
    })
  }
}

/**
 * 创建无障碍按钮的便捷函数
 */
export function createAccessibleButton(
  text: string,
  onClick: () => void,
  options?: {
    icon?: Resource;
    disabled?: boolean;
    type?: 'primary' | 'secondary' | 'text';
    width?: number;
    height?: number;
    backgroundColor?: string;
    textColor?: string;
  }
): AccessibleButton {
  // 注意：这里返回的是组件定义，实际使用时需要在build()中实例化
  // 这个函数主要用于文档说明和类型提示
  throw new Error('This function is for type hinting only. Use the component directly in build() method.');
}
