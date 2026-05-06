/**
 * AR院内导航系统 - AR导航主页面
 * 
 * AR实景导航主界面,显示相机画面和导航指引
 * 
 * @version 1.0
 * @date 2025-01-18
 * @author SDD Agent
 */

import router from '@ohos.router';
import {
  NavigationDestination,
  NavigationPath,
  ARNavigationState,
  NavigationMode
} from '../models/ARNavigationModels';
import {
  getMockDestinationById
} from '../mock/arMock';
import {
  ARNavigationService,
  NavigationEventType
} from '../ar/ARNavigationService';
import { ARRenderer } from '../ar/ARRenderer';
import {
  ARView,
  NavigationProgress
} from '../components/ARNavigationComponents';

@Entry
@Component
struct ARNavigationPage {
  // 路由参数
  private destinationId: string = '';
  private destinationName: string = '';
  private pathDataStr: string = '';

  // 状态变量
  @State destination: NavigationDestination | null = null;
  @State navigationPath: NavigationPath | null = null;
  @State navigationState: ARNavigationState | null = null;
  @State isMuted: boolean = false;
  @State showModeSelector: boolean = false;
  @State currentMode: NavigationMode = NavigationMode.AR_MODE;
  @State isInitializing: boolean = true;
  @State hasArrived: boolean = false;

  // 服务实例
  private navService: ARNavigationService = ARNavigationService.getInstance();
  private arRenderer: ARRenderer = ARRenderer.getInstance();

  // Canvas上下文
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  async aboutToAppear() {
    // 解析路由参数
    this.parseRouteParams();
    
    // 初始化导航
    await this.initializeNavigation();
  }

  aboutToDisappear() {
    // 结束导航
    this.endNavigation();
  }

  /**
   * 解析路由参数
   */
  private parseRouteParams(): void {
    try {
      const params = router.getParams();
      
      if (params !== null && params !== undefined) {
        const paramsObj = params as Record<string, string>;
        this.destinationId = paramsObj['destinationId'] ?? '';
        this.destinationName = paramsObj['destinationName'] ?? '';
        this.pathDataStr = paramsObj['pathData'] ?? '';
      }
    } catch (error) {
      console.error('[ARNavigationPage] 解析路由参数失败:', error);
    }
  }

  /**
   * 初始化导航
   */
  private async initializeNavigation(): Promise<void> {
    try {
      // 1. 获取目的地信息
      this.destination = getMockDestinationById(this.destinationId);
      
      if (this.destination === null) {
        console.error('[ARNavigationPage] 未找到目的地');
        router.back();
        return;
      }

      // 2. 解析路径数据
      if (this.pathDataStr !== '') {
        this.navigationPath = JSON.parse(this.pathDataStr) as NavigationPath;
      }

      // 3. 初始化AR渲染器
      await this.arRenderer.initialize(this.canvasContext);

      // 4. 启动导航服务
      if (this.destination !== null) {
        await this.navService.startNavigation(this.destination);
      }

      // 5. 设置事件监听
      this.setupEventListeners();

      // 6. 启动状态更新循环
      this.startStateUpdateLoop();

      this.isInitializing = false;
      console.log('[ARNavigationPage] 导航初始化完成');
    } catch (error) {
      console.error('[ARNavigationPage] 初始化导航失败:', error);
      router.back();
    }
  }

  /**
   * 设置事件监听器
   */
  private setupEventListeners(): void {
    // 监听到达事件
    this.navService.addEventListener(NavigationEventType.ARRIVED, () => {
      this.hasArrived = true;
      console.log('[ARNavigationPage] 已到达目的地');
    });

    // 监听错误事件
    this.navService.addEventListener(NavigationEventType.ERROR, (event) => {
      console.error('[ARNavigationPage] 导航错误:', event);
    });
  }

  /**
   * 启动状态更新循环
   */
  private startStateUpdateLoop(): void {
    // 每500ms更新一次UI状态
    setInterval(() => {
      this.navigationState = this.navService.getNavigationState();
    }, 500);
  }

  /**
   * 结束导航
   */
  private endNavigation(): void {
    this.navService.endNavigation();
    this.arRenderer.stopRendering();
    console.log('[ARNavigationPage] 导航已结束');
  }

  /**
   * 切换静音状态
   */
  private toggleMute(): void {
    this.isMuted = !this.isMuted;
    this.navService.setMuted(this.isMuted);
  }

  /**
   * 切换导航模式
   */
  private switchMode(mode: NavigationMode): void {
    this.currentMode = mode;
    this.navService.setNavigationMode(mode);
    this.showModeSelector = false;
  }

  build() {
    Stack() {
      // 1. AR视图(底层)
      if (this.currentMode === NavigationMode.AR_MODE) {
        ARView({
          canvasWidth: 1080,
          canvasHeight: 1920
        })
      } else {
        // 非AR模式显示简单背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#F5F5F5')
      }

      // 2. 导航信息叠加层
      Column() {
        // 顶部栏
        this.TopBar()

        // 中间内容区
        Column() {
          if (this.isInitializing) {
            // 加载中
            Column() {
              LoadingProgress()
                .width(48)
                .height(48)
                .color('#52C41A')
              
              Text('正在初始化导航...')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 16 })
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else if (this.hasArrived) {
            // 到达提示
            this.ArrivalView()
          } else {
            // 导航中
            this.NavigationInfo()
          }
        }
        .layoutWeight(1)

        // 底部控制栏
        this.BottomBar()
      }
      .width('100%')
      .height('100%')

      // 3. 模式选择器(弹出层)
      if (this.showModeSelector) {
        this.ModeSelector()
      }
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 子组件 ====================

  /**
   * 顶部栏
   */
  @Builder
  TopBar() {
    Row() {
      // 返回按钮
      Column() {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#33000000')
      .borderRadius(20)
      .onClick(() => router.back())

      Blank()

      // 目的地名称
      if (this.destination !== null) {
        Text(this.destination.name)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 48, bottom: 16 })
  }

  /**
   * 导航信息
   */
  @Builder
  NavigationInfo() {
    Column() {
      // 剩余距离和时间
      if (this.navigationState !== null) {
        NavigationProgress({
          currentDistance: this.navigationState.remainingDistance,
          totalDistance: this.navigationState.totalDistance,
          estimatedTime: this.navigationState.estimatedTime
        })
      }
    }
    .width('100%')
    .padding(16)
  }

  /**
   * 到达提示视图
   */
  @Builder
  ArrivalView() {
    Column() {
      Text('✓')
        .fontSize(64)
        .fontColor('#52C41A')
      
      Text('已到达目的地')
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16 })
      
      if (this.destination !== null) {
        Text(this.destination.name)
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 8 })
      }
      
      Button('结束导航')
        .width(200)
        .height(48)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#52C41A')
        .borderRadius(24)
        .margin({ top: 32 })
        .onClick(() => router.back())
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  /**
   * 底部控制栏
   */
  @Builder
  BottomBar() {
    Row() {
      // 静音按钮
      Column() {
        Text(this.isMuted ? '🔇' : '🔊')
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .onClick(() => this.toggleMute())

      Blank()

      // 模式切换按钮
      Column() {
        Text('切换')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width(80)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .onClick(() => {
        this.showModeSelector = !this.showModeSelector;
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 32 })
    .backgroundColor('#33000000')
  }

  /**
   * 模式选择器
   */
  @Builder
  ModeSelector() {
    Column() {
      Column() {
        Text('选择导航模式')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        // AR模式
        Row() {
          Text('AR实景')
            .fontSize(14)
            .fontColor(this.currentMode === NavigationMode.AR_MODE ? '#52C41A' : '#333333')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.currentMode === NavigationMode.AR_MODE ? '#E6F7FF' : '#F5F5F5')
        .borderRadius(8)
        .onClick(() => this.switchMode(NavigationMode.AR_MODE))

        // 2D地图模式
        Row() {
          Text('2D地图')
            .fontSize(14)
            .fontColor(this.currentMode === NavigationMode.MAP_2D ? '#52C41A' : '#333333')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.currentMode === NavigationMode.MAP_2D ? '#E6F7FF' : '#F5F5F5')
        .borderRadius(8)
        .margin({ top: 8 })
        .onClick(() => this.switchMode(NavigationMode.MAP_2D))

        // 文字模式
        Row() {
          Text('文字导航')
            .fontSize(14)
            .fontColor(this.currentMode === NavigationMode.TEXT_MODE ? '#52C41A' : '#333333')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.currentMode === NavigationMode.TEXT_MODE ? '#E6F7FF' : '#F5F5F5')
        .borderRadius(8)
        .margin({ top: 8 })
        .onClick(() => this.switchMode(NavigationMode.TEXT_MODE))
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#66000000')
    .onClick(() => {
      this.showModeSelector = false;
    })
  }
}
