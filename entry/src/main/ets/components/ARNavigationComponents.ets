/**
 * AR院内导航系统 - UI组件库
 * 
 * 提供可复用的UI组件
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import {
  NavigationDestination,
  DestinationCategory
} from '../models/ARNavigationModels';

// ==================== AR视图组件 ====================

/**
 * AR相机视图组件
 * 用于显示AR导航画面
 */
@Component
export struct ARView {
  @Prop canvasWidth: number = 1080;
  @Prop canvasHeight: number = 1920;
  
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  build() {
    Stack() {
      Canvas(this.context)
        .width(this.canvasWidth)
        .height(this.canvasHeight)
        .backgroundColor('#1a1a1a')
    }
    .width('100%')
    .height('100%')
  }
}

// ==================== 方向箭头组件 ====================

/**
 * 3D方向箭头组件
 * 用于显示导航方向指引
 */
@Component
export struct DirectionArrow {
  @Prop arrowDirection: number = 0;  // 朝向角度(0-360度)
  @Prop arrowColor: string = '#52C41A';  // 箭头颜色
  @Prop arrowSize: number = 100;  // 箭头大小
  
  build() {
    Stack() {
      // 使用Canvas绘制箭头
      Canvas(this.createArrowContext())
        .width(this.arrowSize)
        .height(this.arrowSize)
        .rotate({ angle: this.arrowDirection })
    }
    .width(this.arrowSize)
    .height(this.arrowSize)
  }
  
  private createArrowContext(): CanvasRenderingContext2D {
    const settings = new RenderingContextSettings(true);
    const ctx = new CanvasRenderingContext2D(settings);
    
    // 绘制箭头形状
    ctx.fillStyle = this.arrowColor;
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 3;
    
    const halfSize = this.arrowSize / 2;
    ctx.translate(halfSize, halfSize);
    
    ctx.beginPath();
    ctx.moveTo(0, -halfSize * 0.8);  // 箭头尖端
    ctx.lineTo(-halfSize * 0.5, halfSize * 0.3);  // 左侧
    ctx.lineTo(0, halfSize * 0.1);  // 底部中心
    ctx.lineTo(halfSize * 0.5, halfSize * 0.3);  // 右侧
    ctx.closePath();
    
    ctx.fill();
    ctx.stroke();
    
    return ctx;
  }
}

// ==================== 导航进度组件 ====================

/**
 * 导航进度组件
 * 显示当前导航状态和进度
 */
@Component
export struct NavigationProgress {
  @Prop currentDistance: number = 0;  // 剩余距离(米)
  @Prop totalDistance: number = 100;  // 总距离(米)
  @Prop estimatedTime: number = 0;  // 预计时间(分钟)
  
  build() {
    Column() {
      // 进度条
      Progress({
        value: this.totalDistance - this.currentDistance,
        total: this.totalDistance,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(8)
        .color('#52C41A')
      
      // 距离和时间信息
      Row() {
        Text(`剩余 ${this.currentDistance.toFixed(0)} 米`)
          .fontSize(14)
          .fontColor('#333333')
        
        Blank()
        
        Text(`预计 ${this.estimatedTime} 分钟`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}

// ==================== 目的地卡片组件 ====================

/**
 * 目的地卡片组件
 * 显示目的地信息
 */
@Component
export struct DestinationCard {
  @Prop destination: NavigationDestination | null = null;
  @Prop isFavorite: boolean = false;
  private onCardClick: () => void = () => {};
  private onFavoriteToggle: () => void = () => {};
  
  build() {
    if (this.destination !== null) {
      Row() {
        // 左侧图标
        Column() {
          Text(this.getCategoryIcon(this.destination.category))
            .fontSize(32)
        }
        .width(60)
        .height(60)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F0F0F0')
        .borderRadius(8)
        
        // 中间信息
        Column() {
          Text(this.destination.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(`${this.destination.building} ${this.destination.floor}层`)
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
          
          if (this.destination.description !== '') {
            Text(this.destination.description)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 12, right: 12 })
        
        // 右侧收藏按钮
        Column() {
          Text(this.isFavorite ? '★' : '☆')
            .fontSize(24)
            .fontColor(this.isFavorite ? '#FFB800' : '#CCCCCC')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onFavoriteToggle())
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .shadow({
        radius: 4,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => this.onCardClick())
    }
  }
  
  private getCategoryIcon(category: DestinationCategory): string {
    const iconMap: Map<DestinationCategory, string> = new Map([
      [DestinationCategory.DEPARTMENT, '🏥'],
      [DestinationCategory.PHARMACY, '💊'],
      [DestinationCategory.LAB, '🔬'],
      [DestinationCategory.ELEVATOR, '🛗'],
      [DestinationCategory.RESTROOM, '🚻'],
      [DestinationCategory.PAYMENT, '💰'],
      [DestinationCategory.EMERGENCY, '🚑'],
      [DestinationCategory.REGISTRATION, '📋'],
      [DestinationCategory.IMAGING, '📷'],
      [DestinationCategory.WARD, '🛏️']
    ]);
    return iconMap.get(category) ?? '📍';
  }
}

// ==================== 分类标签组件 ====================

/**
 * 分类标签组件
 * 用于选择目的地分类
 */
@Component
export struct CategoryTab {
  @Prop category: DestinationCategory | null = null;
  @Prop isSelected: boolean = false;
  private onTabClick: () => void = () => {};
  
  build() {
    Column() {
      Text(this.getCategoryName())
        .fontSize(14)
        .fontColor(this.isSelected ? '#FFFFFF' : '#333333')
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(this.isSelected ? '#52C41A' : '#F0F0F0')
    .borderRadius(16)
    .onClick(() => this.onTabClick())
  }
  
  private getCategoryName(): string {
    if (this.category === null) {
      return '全部';
    }
    
    const nameMap: Map<DestinationCategory, string> = new Map([
      [DestinationCategory.DEPARTMENT, '科室'],
      [DestinationCategory.PHARMACY, '药房'],
      [DestinationCategory.LAB, '检验'],
      [DestinationCategory.ELEVATOR, '电梯'],
      [DestinationCategory.RESTROOM, '洗手间'],
      [DestinationCategory.PAYMENT, '缴费'],
      [DestinationCategory.EMERGENCY, '急诊'],
      [DestinationCategory.REGISTRATION, '挂号'],
      [DestinationCategory.IMAGING, '影像'],
      [DestinationCategory.WARD, '病房']
    ]);
    return nameMap.get(this.category) ?? '其他';
  }
}

// ==================== 搜索栏组件 ====================

/**
 * 搜索栏组件
 * 用于搜索目的地
 */
@Component
export struct SearchBar {
  @Prop placeholder: string = '搜索目的地...';
  @Link searchText: string;
  private onSearch: (keyword: string) => void = () => {};
  private onClear: () => void = () => {};
  
  build() {
    Row() {
      // 搜索图标
      Text('🔍')
        .fontSize(20)
        .margin({ left: 12, right: 8 })
      
      // 输入框
      TextInput({ placeholder: this.placeholder, text: this.searchText })
        .layoutWeight(1)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onChange((value: string) => {
          this.searchText = value;
          this.onSearch(value);
        })
      
      // 清除按钮
      if (this.searchText !== '') {
        Text('✕')
          .fontSize(18)
          .fontColor('#999999')
          .margin({ right: 12 })
          .onClick(() => {
            this.searchText = '';
            this.onClear();
          })
      }
    }
    .width('100%')
    .height(48)
    .backgroundColor('#F5F5F5')
    .borderRadius(24)
  }
}

// ==================== 加载视图组件 ====================

/**
 * 加载视图组件
 * 显示加载状态
 */
@Component
export struct LoadingView {
  @Prop message: string = '加载中...';
  
  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#52C41A')
      
      Text(this.message)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}

// ==================== 空视图组件 ====================

/**
 * 空视图组件
 * 显示空数据状态
 */
@Component
export struct EmptyView {
  @Prop message: string = '暂无数据';
  
  build() {
    Column() {
      Text('📭')
        .fontSize(48)
      
      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}
