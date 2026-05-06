/**
 * 无障碍文本组件
 * Accessible Text - 支持老年模式、大字体、高对比度
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { AccessibilityConfig } from '../../utils/AccessibilityConfig';

/**
 * 文本类型
 */
export type TextType = 'title' | 'subtitle' | 'body' | 'caption';

/**
 * 无障碍文本组件
 */
@Component
export struct AccessibleText {
  @Prop content: string = '';
  @Prop type: TextType = 'body';
  @Prop color?: string;
  @Prop maxLines?: number;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  /**
   * 获取字体大小
   */
  private getFontSize(): number {
    let baseSize: number;
    switch (this.type) {
      case 'title':
        baseSize = 20;
        break;
      case 'subtitle':
        baseSize = 18;
        break;
      case 'body':
        baseSize = 16;
        break;
      case 'caption':
        baseSize = 14;
        break;
      default:
        baseSize = 16;
        break;
    }

    return this.isElderMode ? baseSize * 1.25 : baseSize;
  }

  /**
   * 获取字体颜色
   */
  private getFontColor(): string {
    if (this.color) {
      return this.color;
    }

    // 高对比度模式
    if (this.isElderMode) {
      return '#000000';  // 纯黑
    }

    // 标准模式
    switch (this.type) {
      case 'title':
        return '#333333';
      case 'subtitle':
        return '#333333';
      case 'body':
        return '#666666';
      case 'caption':
        return '#999999';
      default:
        return '#666666';
    }
  }

  /**
   * 获取行高
   */
  private getLineHeight(): number {
    return this.getFontSize() * 1.4;
  }

  /**
   * 获取字重
   */
  private getFontWeight(): FontWeight {
    switch (this.type) {
      case 'title':
        return FontWeight.Bold;
      case 'subtitle':
        return FontWeight.Medium;
      default:
        return FontWeight.Normal;
    }
  }

  build() {
    Text(this.content)
      .fontSize(this.getFontSize())
      .fontColor(this.getFontColor())
      .fontWeight(this.getFontWeight())
      .lineHeight(this.getLineHeight())
      .maxLines(this.maxLines)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      // 无障碍属性
      .accessibilityText(this.content)
  }
}
