import router from '@ohos.router';
import {
  NavigationDestination,
  NavigationPath,
  ARNavigationState,
  NavigationMode,
  WaypointType,
  Waypoint,
  FloorChange,
  NavigationInstruction
} from '../models/ARNavigationModels';
import {
  ARNavigationService,
  NavigationEventType
} from '../ar/ARNavigationService';
import { ARRenderer } from '../ar/ARRenderer';
import { PathPlanner } from '../ar/PathPlanner';
import { IndoorLocator } from '../ar/IndoorLocator';
import {
  NavigationProgress
} from '../components/ARNavigationComponents';

interface ARNavigationPageParams {
  destinationId?: string;
  destinationName?: string;
  pathData?: string;
  totalDistance?: number;
  estimatedTime?: number;
}

@Entry
@Component
struct ARNavigationPage {
  private destinationId: string = '';
  private destinationName: string = '';
  private pathDataStr: string = '';

  @State destination: NavigationDestination | null = null;
  @State navigationPath: NavigationPath | null = null;
  @State navigationState: ARNavigationState | null = null;
  @State isMuted: boolean = false;
  @State showModeSelector: boolean = false;
  @State currentMode: NavigationMode = NavigationMode.AR_MODE;
  @State isInitializing: boolean = true;
  @State hasArrived: boolean = false;
  @State isCanvasReady: boolean = false;
  @State currentInstruction: string = '正在计算路径...';
  @State remainingDistance: number = 0;
  @State totalDistance: number = 0;
  @State estimatedTime: number = 0;
  @State progress: number = 0;

  private navService: ARNavigationService = ARNavigationService.getInstance();
  private arRenderer: ARRenderer = ARRenderer.getInstance();
  private planner: PathPlanner = PathPlanner.getInstance();

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private stateUpdateTimer: number = -1;
  private isNavigationStarted: boolean = false;

  async aboutToAppear() {
    this.parseRouteParams();
    await this.prepareNavigation();
  }

  aboutToDisappear() {
    this.endNavigation();
  }

  private parseRouteParams(): void {
    try {
      const params = router.getParams() as ARNavigationPageParams;
      if (params) {
        this.destinationId = params.destinationId ?? '';
        this.destinationName = params.destinationName ?? '';
        this.pathDataStr = params.pathData ?? '';
        console.log(`[ARNavigationPage] parseRouteParams: destinationId=${this.destinationId}, destinationName=${this.destinationName}, pathDataLen=${this.pathDataStr.length}`);
      } else {
        console.warn('[ARNavigationPage] parseRouteParams: params is null');
      }
    } catch (error) {
      console.error('[ARNavigationPage] parseRouteParams error:', error);
    }
  }

  private async prepareNavigation(): Promise<void> {
    try {
      await this.planner.autoInitialize();

      this.destination = this.planner.getPOIById(this.destinationId);

      if (this.destination === null) {
        console.error('[ARNavigationPage] destination not found:', this.destinationId);
        router.back();
        return;
      }

      if (this.pathDataStr !== '') {
        try {
          this.navigationPath = JSON.parse(this.pathDataStr) as NavigationPath;
          this.totalDistance = this.navigationPath.totalDistance;
          this.remainingDistance = this.navigationPath.totalDistance;
          this.estimatedTime = this.navigationPath.estimatedTime;
          if (this.navigationPath.instructions.length > 0) {
            this.currentInstruction = this.navigationPath.instructions[0].text;
          }
        } catch (e) {
          console.error('[ARNavigationPage] parse pathData error:', e);
          this.navigationPath = null;
        }
      }

      this.setupEventListeners();
    } catch (error) {
      console.error('[ARNavigationPage] prepareNavigation error:', error);
      router.back();
    }
  }

  private onCanvasReady(): void {
    if (this.isCanvasReady) {
      return;
    }
    this.isCanvasReady = true;
    console.log('[ARNavigationPage] Canvas ready');

    this.arRenderer.initialize(this.canvasContext, 1080, 1920);

    if (!this.isNavigationStarted && this.destination !== null) {
      this.startNavigation();
    }
  }

  private async startNavigation(): Promise<void> {
    if (this.isNavigationStarted) {
      return;
    }

    try {
      this.isNavigationStarted = true;
      await this.navService.startNavigation(this.destination!);

      if (this.currentMode === NavigationMode.AR_MODE && this.isCanvasReady) {
        this.arRenderer.startRendering();
      }

      if (this.destination !== null) {
        IndoorLocator.getInstance().startSimulationToTarget(this.destination.position);
      }

      this.startStateUpdateLoop();
      this.isInitializing = false;
      console.log('[ARNavigationPage] navigation started');
    } catch (error) {
      console.error('[ARNavigationPage] startNavigation error:', error);
      this.isNavigationStarted = false;
      this.isInitializing = false;
    }
  }

  private setupEventListeners(): void {
    this.navService.addEventListener(NavigationEventType.ARRIVED, () => {
      this.hasArrived = true;
      console.log('[ARNavigationPage] arrived');
    });

    this.navService.addEventListener(NavigationEventType.ERROR, (event) => {
      console.error('[ARNavigationPage] navigation error:', event);
    });
  }

  private startStateUpdateLoop(): void {
    if (this.stateUpdateTimer !== -1) {
      clearInterval(this.stateUpdateTimer);
    }
    this.stateUpdateTimer = setInterval(() => {
      this.navigationState = this.navService.getNavigationState();

      if (this.navigationState !== null) {
        this.remainingDistance = this.navigationState.remainingDistance;
        this.totalDistance = this.navigationState.totalDistance;
        this.estimatedTime = this.navigationState.estimatedTime;
        this.progress = this.totalDistance > 0 ? 1 - this.remainingDistance / this.totalDistance : 0;

        if (this.navigationState.currentPath !== null &&
            this.navigationState.currentWaypointIndex < this.navigationState.currentPath.instructions.length) {
          this.currentInstruction = this.navigationState.currentPath.instructions[this.navigationState.currentWaypointIndex].text;
        }

        if (this.currentMode === NavigationMode.AR_MODE && this.isCanvasReady) {
          const currentWaypoint = this.navigationState.currentPath !== null
            ? this.navigationState.currentPath.waypoints[this.navigationState.currentWaypointIndex]
            : null;

          if (currentWaypoint !== null && currentWaypoint !== undefined) {
            const dx = currentWaypoint.position.x - this.navigationState.currentPosition.x;
            const dz = currentWaypoint.position.z - this.navigationState.currentPosition.z;
            const direction = (Math.atan2(dx, dz) * 180 / Math.PI + 360) % 360;
            this.arRenderer.updateArrowDirection(direction);

            if (currentWaypoint.type === WaypointType.TURN_LEFT || currentWaypoint.type === WaypointType.TURN_RIGHT) {
              this.arRenderer.setArrowStatus('turn');
            } else if (currentWaypoint.type === WaypointType.ARRIVAL) {
              this.arRenderer.setArrowStatus('arrival');
            } else {
              this.arRenderer.setArrowStatus('normal');
            }
          }

          this.arRenderer.updateCurrentPosition(
            this.navigationState.currentPosition.x,
            this.navigationState.currentPosition.z
          );

          if (this.destination !== null) {
            this.arRenderer.updateTargetPosition(
              this.destination.position.x,
              this.destination.position.z
            );
          }

          this.arRenderer.updateNavigationInfo({
            instruction: this.currentInstruction,
            remainingDistance: this.remainingDistance,
            estimatedTime: this.estimatedTime,
            progress: this.progress
          });
        }
      }
    }, 500);
  }

  private endNavigation(): void {
    if (this.stateUpdateTimer !== -1) {
      clearInterval(this.stateUpdateTimer);
      this.stateUpdateTimer = -1;
    }
    this.navService.endNavigation();
    this.arRenderer.stopRendering();
    IndoorLocator.getInstance().stopSimulation();
    this.isNavigationStarted = false;
    console.log('[ARNavigationPage] navigation ended');
  }

  private toggleMute(): void {
    this.isMuted = !this.isMuted;
    this.navService.setMuted(this.isMuted);
  }

  private switchMode(mode: NavigationMode): void {
    this.currentMode = mode;
    this.navService.setNavigationMode(mode);
    this.showModeSelector = false;

    if (mode === NavigationMode.AR_MODE && this.isCanvasReady) {
      this.arRenderer.startRendering();
    } else {
      this.arRenderer.stopRendering();
    }
  }

  build() {
    Stack() {
      if (this.currentMode === NavigationMode.AR_MODE) {
        Canvas(this.canvasContext)
          .width('100%')
          .height('100%')
          .backgroundColor('#1a1a1a')
          .onReady(() => {
            this.onCanvasReady();
          })
      } else if (this.currentMode === NavigationMode.MAP_2D) {
        this.Map2DView()
      } else {
        this.TextNavigationView()
      }

      Column() {
        this.TopBar()

        Column() {
          if (this.isInitializing) {
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
            this.ArrivalView()
          } else {
            this.NavigationInfo()
          }
        }
        .layoutWeight(1)

        this.BottomBar()
      }
      .width('100%')
      .height('100%')

      if (this.showModeSelector) {
        this.ModeSelector()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TopBar() {
    Row() {
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

  @Builder
  NavigationInfo() {
    Column() {
      Text(this.currentInstruction)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 12 })

      NavigationProgress({
        currentDistance: this.remainingDistance,
        totalDistance: this.totalDistance,
        estimatedTime: Math.ceil(this.estimatedTime / 60)
      })
    }
    .width('100%')
    .padding(16)
  }

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

  @Builder
  BottomBar() {
    Row() {
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

  @Builder
  Map2DView() {
    Column() {
      Scroll() {
        Column() {
          if (this.navigationPath !== null) {
            Text('🗺️ 2D地图导航')
              .fontSize(18)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            Column() {
              Row() {
                Text('起点')
                  .fontSize(12)
                  .fontColor('#52C41A')
                  .fontWeight(FontWeight.Bold)
                Blank()
                Text(`→ ${this.navigationPath.waypoints.length}个途经点 →`)
                  .fontSize(12)
                  .fontColor('#666666')
                Blank()
                Text('终点')
                  .fontSize(12)
                  .fontColor('#FF4D4F')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .margin({ bottom: 12 })

              ForEach(this.navigationPath.waypoints, (waypoint: Waypoint, index: number) => {
                  Row() {
                    Column() {
                      if (waypoint.type === WaypointType.TURN_LEFT) {
                        Text('↰')
                          .fontSize(20)
                          .fontColor('#FAAD14')
                      } else if (waypoint.type === WaypointType.TURN_RIGHT) {
                        Text('↱')
                          .fontSize(20)
                          .fontColor('#FAAD14')
                      } else if (waypoint.type === WaypointType.TAKE_ELEVATOR) {
                        Text('🛗')
                          .fontSize(20)
                      } else if (waypoint.type === WaypointType.TAKE_STAIRS) {
                        Text('🪜')
                          .fontSize(20)
                      } else if (waypoint.type === WaypointType.ARRIVAL) {
                        Text('📍')
                          .fontSize(20)
                      } else {
                        Text('●')
                          .fontSize(16)
                          .fontColor('#52C41A')
                      }
                    }
                    .width(40)
                    .height(40)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)

                    Column() {
                      Text(waypoint.instruction)
                        .fontSize(14)
                        .fontColor('#333333')
                        .maxLines(2)

                      Text(`${waypoint.distanceFromPrev.toFixed(0)}米`)
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 2 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 8 })

                    if (this.navigationState !== null && index <= this.navigationState.currentWaypointIndex) {
                      Text('✓')
                        .fontSize(16)
                        .fontColor('#52C41A')
                    }
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })
                }, (waypoint: Waypoint, index: number) => `${index}_${waypoint.id}`)

              if (this.navigationPath.floorChanges.length > 0) {
                Text('楼层切换')
                  .fontSize(14)
                  .fontColor('#666666')
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 16, bottom: 8 })

                ForEach(this.navigationPath.floorChanges, (change: FloorChange) => {
                  Row() {
                    Text(change.method === 'ELEVATOR' ? '🛗 电梯' : '🪜 楼梯')
                      .fontSize(14)
                      .fontColor('#333333')

                    Blank()

                    Text(`${change.fromFloor}F → ${change.toFloor}F`)
                      .fontSize(14)
                      .fontColor('#1890FF')
                  }
                  .width('100%')
                  .padding(8)
                  .backgroundColor('#F0F5FF')
                  .borderRadius(8)
                  .margin({ bottom: 4 })
                }, (change: FloorChange) => `${change.fromFloor}_${change.toFloor}_${change.method}`)
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
          } else {
            Column() {
              Text('🗺️')
                .fontSize(48)
                .margin({ bottom: 16 })

              Text('正在加载路径数据...')
                .fontSize(16)
                .fontColor('#666666')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(48)
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  TextNavigationView() {
    Column() {
      Scroll() {
        Column() {
          if (this.navigationPath !== null) {
            Text('📋 文字导航指引')
              .fontSize(18)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            ForEach(this.navigationPath.instructions, (instruction: NavigationInstruction, index: number) => {
              Row() {
                Column() {
                  Text(`${instruction.stepIndex + 1}`)
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                }
                .width(32)
                .height(32)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(
                  this.navigationState !== null && index <= this.navigationState.currentWaypointIndex
                    ? '#52C41A' : '#CCCCCC'
                )
                .borderRadius(16)

                Column() {
                  Text(instruction.text)
                    .fontSize(14)
                    .fontColor('#333333')
                    .maxLines(3)

                  Row() {
                    Text(`${instruction.distance.toFixed(0)}米`)
                      .fontSize(12)
                      .fontColor('#999999')

                    if (instruction.floorHint !== undefined && instruction.floorHint !== '') {
                      Text(instruction.floorHint)
                        .fontSize(12)
                        .fontColor('#1890FF')
                        .margin({ left: 8 })
                    }
                  }
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
              }
              .width('100%')
              .padding(12)
              .backgroundColor(
                this.navigationState !== null && index === this.navigationState.currentWaypointIndex
                  ? '#E6F7FF' : '#FFFFFF'
              )
              .borderRadius(8)
              .margin({ bottom: 8 })
            }, (instruction: NavigationInstruction, index: number) => `${index}_${instruction.stepIndex}`)
          } else {
            Column() {
              Text('📋')
                .fontSize(48)
                .margin({ bottom: 16 })

              Text('正在加载导航指引...')
                .fontSize(16)
                .fontColor('#666666')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(48)
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ModeSelector() {
    Column() {
      Column() {
        Text('选择导航模式')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

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
