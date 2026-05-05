/**
 * 无障碍文本组件
 * 自动应用无障碍配置，支持字体大小调整、高对比度等特性
 */

import { AccessibilityConfig } from '../../common/accessibility/AccessibilityConfig';

/**
 * 无障碍文本组件
 */
@Component
export struct AccessibleText {
  // 从全局状态绑定无障碍配置
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  // 组件属性
  @Prop text: string = '';
  @Prop maxLines?: number;
  @Prop textColor?: string;
  @Prop fontSizeOverride?: number;
  @Prop fontWeight?: FontWeight;
  @Prop textAlign?: TextAlign;
  @Prop textOverflow?: TextOverflow;
  @Prop lineHeight?: number;
  @Prop letterSpacing?: number;
  @Prop decoration?: TextDecorationType;
  
  /**
   * 获取实际字体大小
   */
  private getActualFontSize(): number {
    if (this.fontSizeOverride) {
      return this.elderlyMode ? this.fontSizeOverride + 2 : this.fontSizeOverride;
    }
    return this.fontSize;
  }
  
  /**
   * 获取实际文字颜色
   */
  private getActualTextColor(): string {
    if (this.textColor) {
      return this.textColor;
    }
    
    // 高对比度模式使用纯黑色
    if (this.highContrast) {
      return '#000000';
    }
    
    return '#333333';
  }
  
  /**
   * 获取行高
   */
  private getActualLineHeight(): number | undefined {
    if (this.lineHeight) {
      return this.lineHeight;
    }
    
    // 老年模式增加行高，提高可读性
    if (this.elderlyMode) {
      return this.getActualFontSize() * 1.6;
    }
    
    return undefined;
  }
  
  build() {
    Text(this.text)
      .fontSize(this.getActualFontSize())
      .fontColor(this.getActualTextColor())
      .fontWeight(this.fontWeight ?? FontWeight.Normal)
      .textAlign(this.textAlign ?? TextAlign.Start)
      .textOverflow(this.textOverflow ?? TextOverflow.Ellipsis)
      .maxLines(this.maxLines ?? Infinity)
      .lineHeight(this.getActualLineHeight())
      .letterSpacing(this.letterSpacing)
      .decoration({ type: this.decoration ?? TextDecorationType.None, color: this.getActualTextColor() })
      // 无障碍属性
      .accessibilityText(this.text)
      .accessibilityLevel('auto')
  }
}

/**
 * 标题文本组件（H1）
 */
@Component
export struct AccessibleH1 {
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  @Prop text: string = '';
  @Prop textColor?: string;
  
  build() {
    AccessibleText({
      text: this.text,
      textColor: this.textColor,
      fontSizeOverride: this.elderlyMode ? 28 : 24,
      fontWeight: FontWeight.Bold
    })
  }
}

/**
 * 标题文本组件（H2）
 */
@Component
export struct AccessibleH2 {
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  @Prop text: string = '';
  @Prop textColor?: string;
  
  build() {
    AccessibleText({
      text: this.text,
      textColor: this.textColor,
      fontSizeOverride: this.elderlyMode ? 24 : 20,
      fontWeight: FontWeight.Bold
    })
  }
}

/**
 * 标题文本组件（H3）
 */
@Component
export struct AccessibleH3 {
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  @Prop text: string = '';
  @Prop textColor?: string;
  
  build() {
    AccessibleText({
      text: this.text,
      textColor: this.textColor,
      fontSizeOverride: this.elderlyMode ? 20 : 18,
      fontWeight: FontWeight.Medium
    })
  }
}

/**
 * 说明文本组件（较小字体）
 */
@Component
export struct AccessibleCaption {
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  @Prop text: string = '';
  @Prop textColor?: string;
  @Prop maxLines?: number;
  
  build() {
    AccessibleText({
      text: this.text,
      textColor: this.textColor ?? '#666666',
      fontSizeOverride: this.elderlyMode ? 16 : 14,
      maxLines: this.maxLines
    })
  }
}

/**
 * 错误文本组件
 */
@Component
export struct AccessibleErrorText {
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  @Prop text: string = '';
  
  build() {
    AccessibleText({
      text: this.text,
      textColor: this.highContrast ? '#000000' : '#E74C3C',
      fontSizeOverride: this.elderlyMode ? 16 : 14
    })
  }
}

/**
 * 成功文本组件
 */
@Component
export struct AccessibleSuccessText {
  @StorageLink('fontSize') fontSize: number = 16;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  @Prop text: string = '';
  
  build() {
    AccessibleText({
      text: this.text,
      textColor: this.highContrast ? '#000000' : '#27AE60',
      fontSizeOverride: this.elderlyMode ? 16 : 14
    })
  }
}
