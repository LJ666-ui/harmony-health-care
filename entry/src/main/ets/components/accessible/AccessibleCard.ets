/**
 * 无障碍卡片组件
 * 提供可点击的卡片容器，支持无障碍焦点管理
 */

import { AccessibilityConfig } from '../../common/accessibility/AccessibilityConfig';

/**
 * 无障碍卡片组件
 */
@Component
export struct AccessibleCard {
  // 从全局状态绑定无障碍配置
  @StorageLink('minTouchTarget') minTouchTarget: number = 44;
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  // 组件属性
  @Prop title?: string;
  @Prop subtitle?: string;
  @Prop backgroundColor?: string;
  @Prop borderRadius?: number;
  @Prop padding?: number;
  @Prop elevation?: number;
  @Prop clickable: boolean = true;
  @Prop disabled: boolean = false;
  
  // 插槽内容（使用@Builder）
  @BuilderParam content: () => void;
  
  // 事件回调
  private onClickHandler?: () => void;
  private onLongPressHandler?: () => void;
  
  /**
   * 设置点击事件
   */
  public onClick(handler: () => void): this {
    this.onClickHandler = handler;
    return this;
  }
  
  /**
   * 设置长按事件
   */
  public onLongPress(handler: () => void): this {
    this.onLongPressHandler = handler;
    return this;
  }
  
  /**
   * 获取卡片背景色
   */
  private getCardBackgroundColor(): string {
    if (this.disabled) {
      return '#F5F5F5';
    }
    
    if (this.backgroundColor) {
      return this.backgroundColor;
    }
    
    // 高对比度模式使用纯白色
    if (this.highContrast) {
      return '#FFFFFF';
    }
    
    return '#FFFFFF';
  }
  
  /**
   * 获取内边距
   */
  private getCardPadding(): number {
    if (this.padding) {
      return this.padding;
    }
    
    // 老年模式增加内边距
    return this.elderlyMode ? 20 : 16;
  }
  
  /**
   * 获取圆角
   */
  private getCardBorderRadius(): number {
    if (this.borderRadius) {
      return this.borderRadius;
    }
    
    return this.elderlyMode ? 12 : 8;
  }
  
  /**
   * 获取阴影
   */
  private getCardElevation(): number {
    if (this.elevation !== undefined) {
      return this.elevation;
    }
    
    return this.elderlyMode ? 4 : 2;
  }
  
  build() {
    Column() {
      // 标题区域
      if (this.title || this.subtitle) {
        Column() {
          if (this.title) {
            Text(this.title)
              .fontSize(this.elderlyMode ? 20 : 18)
              .fontColor(this.highContrast ? '#000000' : '#333333')
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          
          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize(this.elderlyMode ? 16 : 14)
              .fontColor(this.highContrast ? '#000000' : '#666666')
              .margin({ top: 4 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })
      }
      
      // 内容区域
      if (this.content) {
        this.content();
      }
    }
    .width('100%')
    .padding(this.getCardPadding())
    .backgroundColor(this.getCardBackgroundColor())
    .borderRadius(this.getCardBorderRadius())
    .shadow({
      radius: this.getCardElevation(),
      color: '#1F000000',
      offsetX: 0,
      offsetY: 2
    })
    .opacity(this.disabled ? 0.6 : 1)
    // 无障碍属性
    .accessibilityText(this.title ?? '卡片')
    .accessibilityDescription(
      this.disabled
        ? `${this.title ?? '卡片'}，已禁用`
        : this.clickable
          ? `${this.title ?? '卡片'}，点击查看详情`
          : this.title ?? '卡片'
    )
    .accessibilityLevel(this.clickable ? 'important' : 'auto')
    // 交互事件
    .onClick(() => {
      if (!this.disabled && this.clickable && this.onClickHandler) {
        this.onClickHandler();
      }
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          if (!this.disabled && this.clickable && this.onLongPressHandler) {
            this.onLongPressHandler();
          }
        })
    )
  }
}

/**
 * 简化版卡片组件（无标题）
 */
@Component
export struct AccessibleSimpleCard {
  @StorageLink('highContrast') highContrast: boolean = false;
  @StorageLink('elderlyMode') elderlyMode: boolean = false;
  
  @Prop backgroundColor?: string;
  @Prop borderRadius?: number;
  @Prop padding?: number;
  @Prop clickable: boolean = false;
  
  @BuilderParam content: () => void;
  
  private onClickHandler?: () => void;
  
  public onClick(handler: () => void): this {
    this.onClickHandler = handler;
    return this;
  }
  
  build() {
    Column() {
      if (this.content) {
        this.content();
      }
    }
    .width('100%')
    .padding(this.padding ?? (this.elderlyMode ? 20 : 16))
    .backgroundColor(this.backgroundColor ?? '#FFFFFF')
    .borderRadius(this.borderRadius ?? (this.elderlyMode ? 12 : 8))
    .shadow({
      radius: 2,
      color: '#1F000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      if (this.clickable && this.onClickHandler) {
        this.onClickHandler();
      }
    })
  }
}
