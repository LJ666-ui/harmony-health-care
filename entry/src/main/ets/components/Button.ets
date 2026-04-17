// 自定义按钮组件
@Component
export struct CustomButton {
  // 按钮文本
  private text: string = '';
  
  // 按钮类型
  private type: 'primary' | 'secondary' | 'outline' | 'danger' = 'primary';
  
  // 按钮大小
  private size: 'small' | 'medium' | 'large' = 'medium';
  
  // 是否禁用
  private disabled: boolean = false;
  
  // 是否加载中
  private loading: boolean = false;
  
  // 点击事件
  private onClick?: () => void;

  build() {
    Button(this.text, { type: ButtonType.Capsule, stateEffect: true })
      .width(this.getButtonWidth())
      .height(this.getButtonHeight())
      .fontSize(this.getFontSize())
      .fontWeight(FontWeight.Medium)
      .fontColor(this.getFontColor())
      .backgroundColor(this.getBackgroundColor())
      .border({ 
        width: this.type === 'outline' ? 1 : 0,
        color: this.getBorderColor()
      })
      .opacity(this.disabled ? 0.5 : 1)
      .enabled(!this.disabled && !this.loading)
      .onClick(() => {
        if (this.onClick && !this.disabled && !this.loading) {
          this.onClick();
        }
      })
  }

  // 获取按钮宽度
  private getButtonWidth(): string {
    switch (this.size) {
      case 'small': return '80vp';
      case 'medium': return '120vp';
      case 'large': return '100%';
      default: return '120vp';
    }
  }

  // 获取按钮高度
  private getButtonHeight(): number {
    switch (this.size) {
      case 'small': return 32;
      case 'medium': return 40;
      case 'large': return 48;
      default: return 40;
    }
  }

  // 获取字体大小
  private getFontSize(): number {
    switch (this.size) {
      case 'small': return 12;
      case 'medium': return 14;
      case 'large': return 16;
      default: return 14;
    }
  }

  // 获取字体颜色
  private getFontColor(): ResourceColor {
    if (this.type === 'outline') {
      return '#4a90e2';
    }
    return '#ffffff';
  }

  // 获取背景颜色
  private getBackgroundColor(): ResourceColor {
    if (this.type === 'outline') {
      return '#ffffff';
    }
    
    switch (this.type) {
      case 'primary': return '#4a90e2';
      case 'secondary': return '#666666';
      case 'danger': return '#ff6b6b';
      default: return '#4a90e2';
    }
  }

  // 获取边框颜色
  private getBorderColor(): ResourceColor {
    switch (this.type) {
      case 'primary': return '#4a90e2';
      case 'secondary': return '#666666';
      case 'danger': return '#ff6b6b';
      case 'outline': return '#4a90e2';
      default: return '#4a90e2';
    }
  }
}

// 按钮参数接口
export interface ButtonParams {
  text: string;
  type?: 'primary' | 'secondary' | 'outline' | 'danger';
  size?: 'small' | 'medium' | 'large';
  disabled?: boolean;
  loading?: boolean;
  onClick?: () => void;
}