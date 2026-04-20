import { ParkingService, NavigationEngine, LocationService } from '../parking/ParkingService';
import { ARNavigationView } from '../components/ARNavigationView';
import { parkingMockData } from '../mock/parkingMock';

@Entry
@Component
export struct ParkingNavigationPage {
  @State selectedLot: any = null;
  @State selectedSpace: any = null;
  @State currentLocation: any = null;
  @State navigationRoute: any = null;
  @State isNavigating: boolean = false;
  @State arNavigationData: {
    distanceRemaining: number;
    bearing: number;
    instruction: string;
    isArrived: boolean
  } = {
    distanceRemaining: 0,
    bearing: 0,
    instruction: '',
    isArrived: false
  };
  private navigationTimerId: number | null = null;

  aboutToAppear(): void {
    this.loadInitialData();
  }

  aboutToDisappear(): void {
    this.stopNavigation();
  }

  async loadInitialData(): Promise<void> {
    try {
      const service = ParkingService.getInstance();
      const lots = await service.getParkingLots();
      
      if (lots && lots.length > 0) {
        this.selectedLot = lots[0];
      }
      
      const locationService = LocationService.getInstance();
      const locationResult = await locationService.getCurrentLocation();
      
      if (locationResult.success) {
        this.currentLocation = locationResult.location;
        console.log('[ParkingNavigationPage] 获取当前位置成功');
      }
    } catch (error) {
      console.error('[ParkingNavigationPage] 初始化失败:', error.message);
      this.selectedLot = parkingMockData.parkingLots[0];
      this.currentLocation = {
        latitude: 39.9075,
        longitude: 116.4102,
        accuracy: 10,
        timestamp: Date.now()
      };
    }
  }

  async planRouteToSpace(space: any): Promise<void> {
    if (!this.currentLocation || !space) return;
    
    try {
      console.log('[ParkingNavigationPage] 开始规划路径到车位:', space.spaceNumber);
      
      const engine = NavigationEngine.getInstance();
      this.navigationRoute = engine.planRoute(
        this.currentLocation,
        space.latitude,
        space.longitude,
        space.floor
      );
      
      if (this.navigationRoute && this.navigationRoute.steps.length > 0) {
        console.log('[ParkingNavigationPage] 路径规划成功，步骤数:', this.navigationRoute.steps.length);
        
        AlertDialog.show({
          title: '📍 导航路径',
          message: `目标：${space.spaceNumber}\n距离：${Math.round(this.navigationRoute.totalDistance)}米\n预计时间：${Math.ceil(this.navigationRoute.estimatedTime / 60)}分钟`,
          primaryText: '开始导航',
          secondaryText: '取消',
          onPrimaryClick: () => this.startNavigation()
        });
      }
    } catch (error) {
      console.error('[ParkingNavigationPage] 路径规划失败:', error.message);
      AlertDialog.show({
        title: '提示',
        message: '路径规划失败，请稍后重试',
        primaryText: '确定'
      });
    }
  }

  startNavigation(): void {
    if (!this.navigationRoute) return;
    
    this.isNavigating = true;
    
    let distance = this.navigationRoute.totalDistance;
    let stepIndex = 0;
    
    this.arNavigationData = {
      distanceRemaining: distance,
      bearing: Math.floor(Math.random() * 360),
      instruction: this.navigationRoute.steps[0]?.instruction || '开始导航',
      isArrived: false
    };
    
    this.navigationTimerId = setInterval(() => {
      if (distance > 3) {
        distance -= Math.random() * 10 + 3;
        
        if (distance < 0) {
          distance = 0;
        }
        
        const newStepIndex = this.findCurrentStep(distance);
        if (newStepIndex !== stepIndex && newStepIndex < this.navigationRoute.steps.length) {
          stepIndex = newStepIndex;
        }
        
        this.arNavigationData = {
          distanceRemaining: Math.round(distance),
          bearing: this.arNavigationData.bearing + (Math.random() - 0.5) * 15,
          instruction: this.navigationRoute.steps[stepIndex]?.instruction || '继续前进',
          isArrived: distance <= 3
        };
      } else {
        this.arNavigationData.isArrived = true;
        this.stopNavigation();
      }
    }, 500);
  }

  findCurrentStep(remainingDistance: number): number {
    if (!this.navigationRoute || !this.navigationRoute.steps) return 0;
    
    let accumulatedDistance = 0;
    
    for (let i = this.navigationRoute.steps.length - 1; i >= 0; i--) {
      accumulatedDistance += this.navigationRoute.steps[i].distance;
      if (accumulatedDistance >= remainingDistance) {
        return i;
      }
    }
    
    return 0;
  }

  stopNavigation(): void {
    if (this.navigationTimerId) {
      clearInterval(this.navigationTimerId);
      this.navigationTimerId = null;
    }
    this.isNavigating = false;
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '🧭 停车导航', 
        showBack: true 
      })
      
      if (!this.selectedLot) {
        this.buildLoadingView()
      } else if (this.isNavigating) {
        this.buildARNavigationView()
      } else {
        this.buildMainView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder buildLoadingView() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(60)
        .height(60)
        .color('#1677FF')
      
      Text('正在加载导航信息...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildMainView() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildDestinationCard()
        
        this.buildQuickActions()
        
        if (this.navigationRoute) {
          this.buildRouteDetails()
        }
      }
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildDestinationCard() {
    Column({ space: 12 }) {
      Row() {
        Text('🎯 目标位置')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      if (this.selectedSpace) {
        Column({ space: 8 }) {
          Row({ space: 12 }) {
            Text('🅿️')
              .fontSize(28)
            Column({ space: 4 }) {
              Text(this.selectedSpace.spaceNumber)
                .fontSize(20)
                .fontColor('#333333')
                .fontWeight(FontWeight.Bold)
              Text(`${this.selectedLot?.name} ${this.selectedSpace.floor}层`)
                .fontSize(14)
                .fontColor('#666666')
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          
          Row({ space: 16 }) {
            Text(`类型: ${this.getSpaceTypeLabel(this.selectedSpace.type)}`)
              .fontSize(13)
              .fontColor('#999999')
            Text(`状态: ${this.getStatusLabel(this.selectedSpace.status)}`)
              .fontSize(13)
              .fontColor(this.getStatusColor(this.selectedSpace.status))
          }
          .width('100%')
        }
      } else {
        Column({ space: 8 }) {
          Text('请先选择一个车位')
            .fontSize(14)
            .fontColor('#999999')
          Button('选择车位')
            .width(120)
            .height(36)
            .backgroundColor('#1677FF')
            .borderRadius(18)
            .onClick(() => {
              console.log('[ParkingNavigationPage] 跳转到车位选择页面');
            })
        }
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder buildQuickActions() {
    Row({ space: 12 }) {
      Button('🗺️ 地图导航')
        .layoutWeight(1)
        .height(45)
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .onClick(() => {
          if (this.selectedSpace) {
            this.planRouteToSpace(this.selectedSpace);
          } else {
            AlertDialog.show({
              title: '提示',
              message: '请先选择一个目标车位',
              primaryText: '确定'
            });
          }
        })
      
      Button('🎯 模拟AR导航')
        .layoutWeight(1)
        .height(45)
        .backgroundColor('#FFFFFF')
        .fontColor('#1677FF')
        .borderRadius(22)
        .border({ width: 1, color: '#1677FF' })
        .onClick(() => {
          if (this.selectedSpace) {
            this.planRouteToSpace(this.selectedSpace);
          } else {
            AlertDialog.show({
              title: '提示',
              message: '请先选择一个目标车位',
              primaryText: '确定'
            });
          }
        })
    }
    .width('100%')
  }

  @Builder buildRouteDetails() {
    Column({ space: 12 }) {
      Row() {
        Text('📋 导航路线详情')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      Column({ space: 8 }) {
        Row() {
          Text('总距离:')
            .fontSize(14)
            .fontColor('#666666')
          Blank()
          Text(Math.round(this.navigationRoute.totalDistance) + ' 米')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        
        Row() {
          Text('预计时间:')
            .fontSize(14)
            .fontColor('#666666')
          Blank()
          Text(Math.ceil(this.navigationRoute.estimatedTime / 60) + ' 分钟')
            .fontSize(14)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        
        Divider().width('100%').height(1).backgroundColor('#E8E8E8')
        
        ForEach(this.navigationRoute.steps, (step: any, index: number) => {
          Row({ space: 12 }) {
            Text((index + 1).toString())
              .width(24)
              .height(24)
              .borderRadius(12)
              .backgroundColor('#E6F4FF')
              .fontColor('#1677FF')
              .fontSize(12)
              .textAlign(TextAlign.Center)
            
            Column({ space: 2 }) {
              Text(step.instruction || '')
                .fontSize(14)
                .fontColor('#333333')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              
              if (step.distance !== undefined) {
                Text(step.distance + ' 米')
                  .fontSize(12)
                  .fontColor('#999999')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(16)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder buildARNavigationView() {
    Stack() {
      ARNavigationView({
        navigationData: this.arNavigationData,
        isNavigating: this.isNavigating,
        onStopNavigation: () => this.stopNavigation()
      })
      
      this.buildExitButton()
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder buildExitButton() {
    Button('✕ 退出导航')
      .position({ x: 16, y: 40 })
      .width(90)
      .height(36)
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .fontColor('#FFFFFF')
      .borderRadius(18)
      .fontSize(13)
      .onClick(() => this.stopNavigation())
  }

  getSpaceTypeLabel(type: string): string {
    switch (type) {
      case 'NORMAL':
        return '普通车位';
      case 'DISABLED':
        return '无障碍车位';
      case 'ELECTRIC':
        return '新能源车位';
      case 'CHARGING':
        return '充电桩车位';
      default:
        return type;
    }
  }

  getStatusLabel(status: string): string {
    switch (status) {
      case 'AVAILABLE':
        return '空闲';
      case 'OCCUPIED':
        return '占用';
      case 'RESERVED':
        return '预约中';
      default:
        return status;
    }
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'AVAILABLE':
        return '#52C41A';
      case 'OCCUPIED':
        return '#FF4D4F';
      case 'RESERVED':
        return '#FAAD14';
      default:
        return '#999999';
    }
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  
  build() {
    Row() {
      if (this.showBack) {
        Image($r('sys.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            console.log('[NavigationTitleBar] 返回上一页');
          })
      }
      
      Text(this.title)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      if (this.showBack) {
        Text('')
          .width(24)
      }
    }
    .width('100%')
    .height(56)
    .padding({ horizontal: 16 })
    .backgroundColor('#FFFFFF')
  }
}
