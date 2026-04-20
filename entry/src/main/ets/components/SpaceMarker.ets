/**
 * 车位标记组件（三色状态）
 * 
 * 功能：
 * 1. 显示车位状态颜色（绿/红/黄）
 * 2. 显示车位编号
 * 3. 支持选中高亮效果
 */

import { ParkingSpace, SpaceStatus, SpaceType, ParkingColors } from '../parking/ParkingConstants';

interface SpaceMarkerProps {
  space: ParkingSpace;
  isSelected?: boolean;
  size?: number;
  onClick?: (space: ParkingSpace) => void;
}

@Component
export struct SpaceMarker {
  @Prop space: ParkingSpace;
  @Prop isSelected: boolean = false;
  @Prop size: number = 60;
  private onClickCallback?: (space: ParkingSpace) => void;

  build() {
    Column() {
      this.buildMarkerContent()
    }
    .width(this.size)
    .height(this.size)
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(8)
    .border({
      width: this.isSelected ? 3 : 1,
      color: this.isSelected ? '#1677FF' : 'transparent'
    })
    .shadow(
      this.isSelected ? {
        radius: 8,
        color: 'rgba(22,119,255,0.4)',
        offsetX: 0,
        offsetY: 2
      } : {
        radius: 2,
        color: 'rgba(0,0,0,0.1)',
        offsetX: 0,
        offsetY: 1
      }
    )
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.onClickCallback) {
        this.onClickCallback(this.space);
      }
    })
  }

  /**
   * 构建标记内容
   */
  @Builder
  buildMarkerContent() {
    Column() {
      Text(this.space.spaceNumber)
        .fontSize(this.size > 50 ? 14 : 11)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTextColor())

      if (this.showTypeIcon()) {
        Text(this.getTypeIcon())
          .fontSize(10)
          .fontColor(this.getTextColor())
          .margin({ top: 2 })
      }
    }
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 获取背景颜色
   */
  private getBackgroundColor(): string {
    const baseColor = this.getStatusColor();
    return baseColor + '30';
  }

  /**
   * 获取文字/图标颜色
   */
  private getTextColor(): string {
    return this.getStatusColor();
  }

  /**
   * 获取状态对应的颜色
   */
  private getStatusColor(): string {
    switch (this.space.status) {
      case SpaceStatus.AVAILABLE:
        return ParkingColors.AVAILABLE;
      case SpaceStatus.OCCUPIED:
        return ParkingColors.OCCUPIED;
      case SpaceStatus.RESERVED:
        return ParkingColors.RESERVED;
      default:
        return '#999999';
    }
  }

  /**
   * 是否显示类型图标
   */
  private showTypeIcon(): boolean {
    return this.space.type !== SpaceType.NORMAL && this.size > 45;
  }

  /**
   * 获取类型图标文字
   */
  private getTypeIcon(): string {
    switch (this.space.type) {
      case SpaceType.DISABLED:
        return '♿';
      case SpaceType.ELECTRIC:
        return '⚡';
      case SpaceType.CHARGING:
        return '🔌';
      default:
        return '';
    }
  }
}
