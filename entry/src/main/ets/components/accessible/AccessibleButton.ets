/**
 * 无障碍按钮组件
 * Accessible Button - 支持老年模式、大字体、语音播报
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

import { AccessibilityConfig } from '../../utils/AccessibilityConfig';

/**
 * 无障碍按钮属性
 */
export interface AccessibleButtonProps {
  text: string;                    // 按钮文字
  icon?: string;                   // 图标
  onClick: () => void;             // 点击事件
  type?: 'primary' | 'secondary' | 'danger';  // 按钮类型
  disabled?: boolean;              // 是否禁用
  fullWidth?: boolean;             // 是否全宽
  voiceHint?: string;              // 语音提示
}

/**
 * 无障碍按钮组件
 */
@Component
export struct AccessibleButton {
  @Prop text: string = '';
  @Prop icon: string = '';
  @Prop type: 'primary' | 'secondary' | 'danger' = 'primary';
  @Prop disabled: boolean = false;
  @Prop fullWidth: boolean = false;
  @Prop voiceHint: string = '';
  @Prop isElderMode: boolean = false;
  @StorageLink('isOldModeEnabled') storageElderMode: boolean = false;

  private onClickHandler: () => void = () => {};

  aboutToAppear() {
    // 如果没有显式设置 isElderMode，使用全局设置
    if (!this.isElderMode) {
      this.isElderMode = this.storageElderMode;
    }
  }

  /**
   * 获取按钮颜色
   */
  private getButtonColor(): string {
    if (this.disabled) {
      return '#D9D9D9';
    }

    switch (this.type) {
      case 'primary':
        return '#1677FF';
      case 'secondary':
        return '#52C41A';
      case 'danger':
        return '#FF4D4F';
      default:
        return '#1677FF';
    }
  }

  /**
   * 获取字体大小
   */
  private getFontSize(): number {
    return this.isElderMode ? 20 : 16;
  }

  /**
   * 获取按钮高度
   */
  private getButtonHeight(): number {
    return this.isElderMode ? 56 : 44;  // 最小44dp
  }

  /**
   * 处理点击
   */
  private handleClick(): void {
    if (this.disabled) {
      return;
    }

    // 语音提示
    if (this.voiceHint && this.isElderMode) {
      this.speak(this.voiceHint);
    }

    // 执行点击事件
    this.onClickHandler();
  }

  /**
   * 语音播报
   */
  private speak(text: string): void {
    // 实际项目中使用TTS
    console.info('[AccessibleButton] 语音播报:', text);
  }

  build() {
    Button() {
      Row() {
        // 图标
        if (this.icon) {
          Text(this.icon)
            .fontSize(this.getFontSize() + 4)
            .margin({ right: 8 })
        }

        // 文字
        Text(this.text)
          .fontSize(this.getFontSize())
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
    }
    .width(this.fullWidth ? '100%' : 'auto')
    .height(this.getButtonHeight())
    .backgroundColor(this.getButtonColor())
    .borderRadius(8)
    .padding({ left: 16, right: 16 })
    .enabled(!this.disabled)
    .onClick(() => {
      this.handleClick();
    })
    // 无障碍属性
    .accessibilityText(this.text + '按钮')
    .accessibilityDescription(this.voiceHint || `点击${this.text}`)
    .accessibilityLevel('important')
  }
}
