/**
 * 停车场地图组件
 * 
 * 功能：
 * 1. 渲染停车场平面图
 * 2. 绘制车位网格（根据status着色：绿/红/黄）
 * 3. 点击车位显示详情弹窗
 * 4. 支持缩放、拖拽
 * 5. 显示当前位置蓝点和目标车位标记
 */

import { ParkingSpace, SpaceStatus, SpaceType, ParkingColors } from '../parking/ParkingConstants';

interface ParkingMapProps {
  spaces: ParkingSpace[];
  selectedSpaceId?: string;
  currentLocation?: { lat: number; lng: number };
  onSpaceClick: (space: ParkingSpace) => void;
  onMapReady?: () => void;
}

@Component
export struct ParkingMap {
  @Prop spaces: ParkingSpace[] = [];
  @Prop selectedSpaceId: string = '';
  @Prop currentLocation?: { lat: number; lng: number };
  @State scale: number = 1.0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  private onSpaceClickCallback: (space: ParkingSpace) => void = () => {};
  private onMapReadyCallback?: () => void;

  aboutToAppear(): void {
    if (this.onMapReadyCallback) {
      setTimeout(() => {
        this.onMapReadyCallback?.();
      }, 500);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      this.buildParkingGrid()

      if (this.currentLocation) {
        this.buildCurrentLocationMarker()
      }

      if (this.selectedSpaceId) {
        this.buildSelectedSpaceMarker()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
    .gesture(
      PinchGesture({ fingers: 2 })
        .onActionUpdate((event: GestureEvent) => {
          if (event.scale) {
            this.scale = Math.max(0.5, Math.min(3.0, event.scale));
          }
        })
    )
    .gesture(
      PanGesture()
        .onActionUpdate((event: GestureEvent) => {
          if (event.offsetX !== undefined && event.offsetY !== undefined) {
            this.offsetX += event.offsetX;
            this.offsetY += event.offsetY;
          }
        })
    )
  }

  /**
   * 构建停车位网格
   */
  @Builder
  buildParkingGrid() {
    Column() {
      Grid() {
        ForEach(this.spaces, (space: ParkingSpace) => {
          GridItem() {
            this.buildSpaceItem(space)
          }
        }, (space: ParkingSpace) => space.id)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .padding(12)
      .width('100%')
      .height('100%')
    }
    .scale({ x: this.scale, y: this.scale })
    .translate({ x: this.offsetX, y: this.offsetY })
  }

  /**
   * 构建单个车位项
   */
  @Builder
  buildSpaceItem(space: ParkingSpace) {
    Column() {
      Text(space.spaceNumber)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getSpaceTextColor(space.status))

      Text(this.getSpaceTypeLabel(space.type))
        .fontSize(10)
        .fontColor(this.getSpaceTextColor(space.status))
        .margin({ top: 4 })

      if (space.floor) {
        Text(space.floor)
          .fontSize(10)
          .fontColor(this.getSpaceTextColor(space.status))
          .margin({ top: 2 })
      }
    }
    .width('100%')
    .height(70)
    .backgroundColor(this.getSpaceBackgroundColor(space.status))
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .border({
      width: this.selectedSpaceId === space.id ? 3 : 1,
      color: this.selectedSpaceId === space.id ? '#1677FF' : '#E5E5E5'
    })
    .shadow(
      this.selectedSpaceId === space.id ? {
        radius: 8,
        color: 'rgba(22,119,255,0.3)',
        offsetX: 0,
        offsetY: 2
      } : {
        radius: 2,
        color: 'rgba(0,0,0,0.05)',
        offsetX: 0,
        offsetY: 1
      }
    )
    .onClick(() => {
      this.onSpaceClickCallback(space);
    })
  }

  /**
   * 构建当前位置标记（蓝点）
   */
  @Builder
  buildCurrentLocationMarker() {
    Column() {
      Circle({ width: 20, height: 20 })
        .fill('#1677FF')
        .stroke('#FFFFFF')
        .strokeWidth(3)

      Ripple({ radius: 25, color: 'rgba(22,119,255,0.3)' })
        .animate(true)
    }
    .position({ x: '50%', y: '50%' })
    .translate({ x: -10, y: -10 })
  }

  /**
   * 构建选中车位标记
   */
  @Builder
  buildSelectedSpaceMarker() {
    Column() {
      Image($r('app.media.ic_location_pin'))
        .width(30)
        .height(30)
        .fillColor('#FF4D4F')
    }
    .position({ x: '50%', y: '50%' })
    .translate({ x: -15, y: -30 })
  }

  // ==================== 辅助方法 ====================

  /**
   * 根据状态获取背景颜色
   */
  getSpaceBackgroundColor(status: SpaceStatus): string {
    switch (status) {
      case SpaceStatus.AVAILABLE:
        return ParkingColors.AVAILABLE + '20';
      case SpaceStatus.OCCUPIED:
        return ParkingColors.OCCUPIED + '20';
      case SpaceStatus.RESERVED:
        return ParkingColors.RESERVED + '20';
      default:
        return '#CCCCCC20';
    }
  }

  /**
   * 根据状态获取文字颜色
   */
  getSpaceTextColor(status: SpaceStatus): string {
    switch (status) {
      case SpaceStatus.AVAILABLE:
        return ParkingColors.AVAILABLE;
      case SpaceStatus.OCCUPIED:
        return ParkingColors.OCCUPIED;
      case SpaceStatus.RESERVED:
        return ParkingColors.RESERVED;
      default:
        return '#666666';
    }
  }

  /**
   * 获取车位类型标签
   */
  getSpaceTypeLabel(type: SpaceType): string {
    switch (type) {
      case SpaceType.DISABLED:
        return '无障碍';
      case SpaceType.ELECTRIC:
        return '新能源';
      case SpaceType.CHARGING:
        return '充电桩';
      case SpaceType.NORMAL:
      default:
        return '';
    }
  }
}
