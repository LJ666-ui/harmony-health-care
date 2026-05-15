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
  @Prop arrowDirection: number = 0;
  @Prop arrowColor: string = '#52C41A';
  @Prop arrowSize: number = 100;

  private arrowSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private arrowContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.arrowSettings);

  build() {
    Stack() {
      Canvas(this.arrowContext)
        .width(this.arrowSize)
        .height(this.arrowSize)
        .rotate({ angle: this.arrowDirection })
        .onReady(() => {
          this.drawArrow();
        })
    }
    .width(this.arrowSize)
    .height(this.arrowSize)
  }

  private drawArrow(): void {
    const ctx = this.arrowContext;
    const halfSize = this.arrowSize / 2;

    ctx.clearRect(0, 0, this.arrowSize, this.arrowSize);
    ctx.save();
    ctx.translate(halfSize, halfSize);

    ctx.fillStyle = this.arrowColor;
    ctx.strokeStyle = '#FFFFFF';
    ctx.lineWidth = 3;

    ctx.beginPath();
    ctx.moveTo(0, -halfSize * 0.8);
    ctx.lineTo(-halfSize * 0.5, halfSize * 0.3);
    ctx.lineTo(0, halfSize * 0.1);
    ctx.lineTo(halfSize * 0.5, halfSize * 0.3);
    ctx.closePath();

    ctx.fill();
    ctx.stroke();
    ctx.restore();
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
      Progress({
        value: this.totalDistance > 0 ? this.totalDistance - this.currentDistance : 0,
        total: this.totalDistance > 0 ? this.totalDistance : 1,
        type: ProgressType.Linear
      })
        .width('100%')
        .height(8)
        .color('#52C41A')
      
      Row() {
        Text(`剩余 ${Math.round(this.currentDistance)} 米`)
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
  private onNavigateClick: () => void = () => {};  // 新增：导航按钮回调
  
  build() {
    if (this.destination !== null) {
      Row() {
        // 左侧图标
        Column() {
          Text(this.getCategoryIcon(this.destination.category))
            .fontSize(28)
          
          Text(`${this.destination.floor}F`)
            .fontSize(11)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)
            .margin({ top: 2 })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F0F5FF')
        .borderRadius(12)
        
        // 中间信息
        Column() {
          // 名称行
          Row() {
            Text(this.destination.name)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            if (this.destination.isAccessible) {
              Text('♿')
                .fontSize(14)
                .margin({ left: 4 })
            }
          }
          .width('100%')

          // 位置行
          Text(`${this.destination.building} ${this.destination.floor}层`)
            .fontSize(12)
            .fontColor('#888888')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .margin({ top: 3 })
          
          // 描述行
          if (this.destination.description !== '') {
            Text(this.destination.description)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 3 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 12, right: 8 })
        
        // 右侧操作区
        Column() {
          // 收藏按钮
          Text(this.isFavorite ? '⭐' : '☆')
            .fontSize(24)
            .fontColor(this.isFavorite ? '#FFB800' : '#CCCCCC')
            .onClick(() => {
              this.onFavoriteToggle();
            })

          // 导航按钮 - 新增！
          Button('导航')
            .backgroundColor('#52C41A')
            .fontSize(12)
            .height(32)
            .width(60)
            .borderRadius(16)
            .margin({ top: 10 })
            .onClick(() => {
              console.log(`[DestinationCard] 点击导航按钮: ${this.destination?.name}`);
              this.onNavigateClick();
            })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .width(70)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({
        radius: 2,
        color: '#00000008',
        offsetX: 0,
        offsetY: 1
      })
      .onClick(() => {
        console.log(`[DestinationCard] click: ${this.destination?.name}`);
        this.onCardClick();
      })
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
