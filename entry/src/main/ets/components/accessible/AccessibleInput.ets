/**
 * 无障碍输入框组件
 * Accessible Input - 支持老年模式、大字体、语音输入
 * 
 * @author Nebula Medical Team
 * @date 2026-05-06
 */

/**
 * 无障碍输入框组件
 */
@Component
export struct AccessibleInput {
  @Link value: string;
  @Prop placeholder: string = '';
  @Prop label: string = '';
  @Prop type: 'text' | 'number' | 'phone' = 'text';
  @Prop maxLength?: number;
  @Prop error?: string;
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  /**
   * 获取字体大小
   */
  private getFontSize(): number {
    return this.isElderMode ? 20 : 16;
  }

  /**
   * 获取输入框高度
   */
  private getInputHeight(): number {
    return this.isElderMode ? 56 : 44;
  }

  /**
   * 获取内边距
   */
  private getPadding(): number {
    return this.isElderMode ? 20 : 16;
  }

  build() {
    Column() {
      // 标签
      if (this.label) {
        Text(this.label)
          .fontSize(this.getFontSize())
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
          .width('100%')
      }

      // 输入框
      TextInput({ 
        placeholder: this.placeholder, 
        text: this.value 
      })
        .fontSize(this.getFontSize())
        .height(this.getInputHeight())
        .padding(this.getPadding())
        .backgroundColor('#FFFFFF')
        .border({
          width: 1,
          color: this.error ? '#FF4D4F' : '#E0E0E0'
        })
        .borderRadius(8)
        .width('100%')
        .type(this.getInputType())
        .maxLength(this.maxLength)
        .onChange((value: string) => {
          this.value = value;
        })
        // 无障碍属性
        .accessibilityText(this.label || this.placeholder)
        .accessibilityDescription(this.error || `输入${this.label || this.placeholder}`)

      // 错误提示
      if (this.error) {
        Text(this.error)
          .fontSize(this.isElderMode ? 16 : 12)
          .fontColor('#FF4D4F')
          .margin({ top: 4 })
          .width('100%')
      }
    }
    .width('100%')
  }

  /**
   * 获取输入类型
   */
  private getInputType(): InputType {
    switch (this.type) {
      case 'number':
        return InputType.Number;
      case 'phone':
        return InputType.PhoneNumber;
      default:
        return InputType.Normal;
    }
  }
}
