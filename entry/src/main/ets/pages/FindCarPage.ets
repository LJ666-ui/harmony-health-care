import { NavigationMode, NavigationStatus, Location, ParkingRecord, Step, IndoorLocation, FeeDetail, FeeDetailBreakdown } from '../models/ParkingModels';
import { ParkingService } from '../parking/ParkingService';
import { NavigationEngine } from '../parking/NavigationEngine';
import { NavigationConstants, ParkingErrorCode, ParkingErrorMessage } from '../parking/ParkingConstants';
import { router } from '@kit.ArkUI';

enum NavMode { OVERVIEW = 'OVERVIEW', MAP = 'MAP', AR = 'AR', TEXT = 'TEXT' }

@Entry
@Component
struct FindCarPage {
  @State parkingRecord: ParkingRecord | null = null;
  @State isLoading: boolean = true;
  @State navMode: NavMode = NavMode.OVERVIEW;
  @State currentDistance: number = 0;
  @State showPaymentSheet: boolean = false;
  @State timerSeconds: number = 0;
  @State navigationStatus: NavigationStatus = NavigationStatus.IDLE;
  @State textGuideSteps: Step[] = [];

  private timer: number = -1;
  private parkingService: ParkingService = ParkingService.getInstance();
  private navigationEngine: NavigationEngine = NavigationEngine.getInstance();

  aboutToAppear(): void {
    this.loadParkingRecord();
    this.startTimer();
  }

  aboutToDisappear(): void {
    this.stopTimer();
    this.navigationEngine.stopNavigation();
  }

  async loadParkingRecord(): Promise<void> {
    this.isLoading = true;
    try {
      await this.parkingService.init();
      this.parkingRecord = await this.parkingService.getParkingRecord();
      if (!this.parkingRecord) {
        const indoorLocation: IndoorLocation = {
          building: '门诊楼',
          floor: 'B2',
          nearLandmark: '3号电梯厅旁'
        };
        const feeDetail: FeeDetail = {
          baseFee: 12.50,
          weekendDiscount: 0,
          capDiscount: 0,
          finalFee: 12.50
        };
        this.parkingRecord = {
          recordId: 'PRK20260424001',
          parkingLotId: 'LOT001',
          parkingLotName: '门诊楼地下停车场',
          spaceId: 'SPACE_A_128',
          spaceNumber: 'A-128',
          floor: 'B2',
          zone: 'A区',
          latitude: 39.908715,
          longitude: 116.398755,
          accuracy: 5,
          indoorLocation: indoorLocation,
          photoUri: '',
          note: 'B2层A区,电梯口左转第一排,白色柱子旁边',
          carDescription: '白色特斯拉 Model 3',
          licensePlate: '京A·88888',
          parkTime: Date.now() - 9300000,
          isActive: true,
          currentFee: 12.50,
          feeDetails: feeDetail
        };
      }
    } catch (error) {
      console.error('Failed to load parking record:', error);
    } finally {
      this.isLoading = false;
    }
  }

  startTimer(): void {
    this.stopTimer();
    this.timer = setInterval(() => {
      this.timerSeconds++;
      if (this.parkingRecord) {
        const duration: number = Date.now() - this.parkingRecord.parkTime;
        const feeDetail: FeeDetailBreakdown = this.parkingService.calculateFee(duration / 60000);
        this.parkingRecord.currentFee = feeDetail.totalFee;
      }
    }, 1000);
  }

  stopTimer(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  async onNavigateMap(): Promise<void> {
    this.navMode = NavMode.MAP;
    this.navigationStatus = NavigationStatus.NAVIGATING;
    try {
      const userLocation: Location = await this.parkingService.getCurrentLocation();
      await this.navigationEngine.startNavigation(NavigationMode.MAP, {
        latitude: this.parkingRecord!.latitude,
        longitude: this.parkingRecord!.longitude
      }, {
        onUpdate: (position: Location, distance: number): void => {
          this.currentDistance = distance;
        },
        onArrival: (): void => {
          this.onArrival();
        }
      });
    } catch (error) {
      console.error('Failed to start navigation:', error);
    }
  }

  async onStartAR(): Promise<void> {
    this.navMode = NavMode.AR;
    this.navigationStatus = NavigationStatus.NAVIGATING;
    try {
      const userLocation: Location = await this.parkingService.getCurrentLocation();
      await this.navigationEngine.startNavigation(NavigationMode.AR, {
        latitude: this.parkingRecord!.latitude,
        longitude: this.parkingRecord!.longitude
      }, {
        onUpdate: (position: Location, distance: number): void => {
          this.currentDistance = distance;
        },
        onArrival: (): void => {
          this.onArrival();
        }
      });
    } catch (error) {
      console.error('Failed to start AR navigation:', error);
    }
  }

  onShowTextGuide(): void {
    this.navMode = NavMode.TEXT;
    this.textGuideSteps = this.navigationEngine.getTextGuideSteps();
  }

  onArrival(): void {
    this.navigationStatus = NavigationStatus.ARRIVED;
    this.navigationEngine.stopNavigation();
    this.navMode = NavMode.OVERVIEW;
  }

  onStopNavigation(): void {
    this.navigationEngine.stopNavigation();
    this.navigationStatus = NavigationStatus.IDLE;
    this.navMode = NavMode.OVERVIEW;
  }

  onGoToPayment(): void {
    this.showPaymentSheet = true;
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column().width('100%').height('100%').backgroundColor('#F5F5F5')
      Column() {
        this.NavigationBar()
        if (this.isLoading) {
          LoadingProgress()
            .width(50)
            .height(50)
        } else if (this.parkingRecord) {
          if (this.navMode === NavMode.OVERVIEW) {
            this.OverviewSection()
            this.NavModeSelector()
          } else if (this.navMode === NavMode.MAP) {
            this.MapNavView()
          } else if (this.navMode === NavMode.AR) {
            this.ARNavView()
          } else if (this.navMode === NavMode.TEXT) {
            this.TextGuideView()
          }
        } else {
          this.EmptyView()
        }
        BottomActionBar({ onStopNavigation: (): void => {
          this.onStopNavigation();
        } })
      }
      .width('100%')
      .height('100%')
      if (this.showPaymentSheet && this.parkingRecord) {
        PaymentBottomSheet({ parkingRecord: this.parkingRecord, showPaymentSheet: $showPaymentSheet })
      }
    }
  }

  @Builder NavigationBar() {
    Row() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(20)
          .height(20)
          .fillColor(Color.White)
      }
      .height(32)
      .padding({ left: 8, right: 8 })
      .onClick(() => {
        router.back();
      })
      Text('寻车')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(600)
      Row() {
        Image($r('sys.media.ohos_ic_public_share'))
          .width(20)
          .height(20)
          .fillColor(Color.White)
      }
      .height(32)
      .padding({ left: 8, right: 8 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#1677FF')
  }

  @Builder OverviewSection() {
    Column() {
      Row() {
        Text(this.parkingRecord!.parkingLotName + ' ' + this.parkingRecord!.floor + '层 ' + this.parkingRecord!.spaceNumber + '号车位')
          .fontSize(24)
          .fontColor('#000000')
          .fontWeight(600)
          .lineHeight(33)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      Row() {
        Column() {
          Row() {
            Text(this.parkingRecord!.floor + '层')
              .fontSize(16)
              .fontColor('#000000')
              .opacity(0.9)
              .lineHeight(22)
          }
          .alignItems(VerticalAlign.Center)
          Row() {
            Text(this.parkingRecord!.zone)
              .fontSize(12)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(17)
          }
          .alignItems(VerticalAlign.Center)
          .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        Row() {
          Column() {
            Text('停放时长')
              .fontSize(12)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(17)
            Text(this.formatDuration(this.timerSeconds))
              .fontSize(16)
              .fontColor('#000000')
              .fontWeight(500)
              .lineHeight(22)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ right: 24 })
          Column() {
            Text('当前费用')
              .fontSize(12)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(17)
            Text('¥' + this.parkingRecord!.currentFee.toFixed(2))
              .fontSize(16)
              .fontColor('#1677FF')
              .fontWeight(600)
              .lineHeight(22)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      Row() {
        Text(this.parkingRecord!.carDescription)
          .fontSize(14)
          .fontColor('#000000')
          .fontWeight(500)
          .lineHeight(20)
          .flexShrink(1)
        Text(this.parkingRecord!.licensePlate)
          .fontSize(14)
          .fontColor('#000000')
          .opacity(0.9)
          .lineHeight(20)
          .flexShrink(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  @Builder NavModeSelector() {
    Column() {
      Column() {
        Row() {
          Row() {
            Text('🗺️')
              .fontSize(24)
          }
          .width(40)
          .height(40)
          .backgroundColor('#F0F7FF')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          Column() {
            Text('地图导航')
              .fontSize(16)
              .fontColor('#000000')
              .fontWeight(500)
              .lineHeight(22)
            Text('距您约320m,预计步行4分钟')
              .fontSize(14)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(20)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          Text('开始导航')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .lineHeight(20)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#1677FF')
            .borderRadius(15)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .onClick(() => {
        this.onNavigateMap();
      })
      Divider()
        .color('#F0F0F0')
        .strokeWidth(0.5)
      Column() {
        Row() {
          Row() {
            Image($r('sys.media.ohos_ic_public_camera'))
              .width(24)
              .height(24)
              .fillColor('#1677FF')
          }
          .width(40)
          .height(40)
          .backgroundColor('#F0F7FF')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          Column() {
            Text('AR实景导航')
              .fontSize(16)
              .fontColor('#000000')
              .fontWeight(500)
              .lineHeight(22)
            Text('相机实景+方向箭头,最后100米体验最佳')
              .fontSize(14)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(20)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          Text('启动AR导航')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .lineHeight(20)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#1677FF')
            .borderRadius(15)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .onClick(() => {
        this.onStartAR();
      })
      Divider()
        .color('#F0F0F0')
        .strokeWidth(0.5)
      Column() {
        Row() {
          Row() {
            Image($r('sys.media.ohos_ic_public_text'))
              .width(24)
              .height(24)
              .fillColor('#1677FF')
          }
          .width(40)
          .height(40)
          .backgroundColor('#F0F7FF')
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          Column() {
            Text('文字指引')
              .fontSize(16)
              .fontColor('#000000')
              .fontWeight(500)
              .lineHeight(22)
            Text('无需网络,离线可用')
              .fontSize(14)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(20)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          Text('查看指引')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .lineHeight(20)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('#1677FF')
            .borderRadius(15)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .onClick(() => {
        this.onShowTextGuide();
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12 })
  }

  @Builder MapNavView() {
    Column() {
      Row() {
        Text('地图导航')
          .fontSize(20)
          .fontColor('#000000')
          .fontWeight(600)
          .lineHeight(28)
          .flexGrow(1)
        Text('距离车位: ' + this.currentDistance + 'm')
          .fontSize(14)
          .fontColor('#000000')
          .opacity(0.6)
          .lineHeight(20)
      }
      .width('100%')
      .padding(16)
      Row() {
        Column() {
          Text('📍')
            .fontSize(32)
            .lineHeight(44)
          Text('当前位置')
            .fontSize(12)
            .fontColor('#000000')
            .opacity(0.6)
            .lineHeight(17)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        Column() {
          Text('⬇️')
            .fontSize(16)
            .lineHeight(22)
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 12, right: 12 })
        Column() {
          Text('🎯')
            .fontSize(32)
            .lineHeight(44)
          Text('停车位')
            .fontSize(12)
            .fontColor('#000000')
            .opacity(0.6)
            .lineHeight(17)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder ARNavView() {
    Column() {
      Row() {
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(20)
            .height(20)
            .fillColor(Color.White)
        }
        .height(32)
        .padding({ left: 8, right: 8 })
        .onClick(() => {
          this.onStopNavigation();
        })
        Text('距离车位: ' + this.currentDistance + 'm')
          .fontSize(16)
          .fontColor(Color.White)
          .lineHeight(22)
          .flexGrow(1)
          .textAlign(TextAlign.Center)
        Row()
          .width(32)
          .height(32)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('rgba(0,0,0,0.5)')
      Column() {
        Text('↑')
          .fontSize(48)
          .fontColor(Color.White)
          .lineHeight(67)
        Text('直行 ' + this.currentDistance + 'm')
          .fontSize(16)
          .fontColor(Color.White)
          .lineHeight(22)
          .margin({ top: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 200 })
      Row() {
        Button('切换地图')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('rgba(0,0,0,0.5)')
          .height(40)
          .type(ButtonType.Normal)
          .onClick(() => {
            this.navMode = NavMode.MAP;
          })
        Button('切换文字')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('rgba(0,0,0,0.5)')
          .height(40)
          .type(ButtonType.Normal)
          .margin({ left: 12 })
          .onClick(() => {
            this.navMode = NavMode.TEXT;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .position({ x: 0, y: 520 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  @Builder TextGuideView() {
    Column() {
      Row() {
        Text('文字指引')
          .fontSize(20)
          .fontColor('#000000')
          .fontWeight(600)
          .lineHeight(28)
          .flexGrow(1)
      }
      .width('100%')
      .padding(16)
      List({ space: 12 }) {
        ForEach(this.textGuideSteps, (step: Step) => {
          ListItem() {
            Row() {
              Row() {
                Text(step.isCompleted ? '✅' : step.stepId)
                  .fontSize(16)
                  .fontColor(step.isCompleted ? '#52C41A' : '#FFFFFF')
                  .lineHeight(22)
              }
              .width(32)
              .height(32)
              .backgroundColor(step.isCompleted ? '#E6FFFB' : '#1677FF')
              .borderRadius(16)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
              Text(step.instruction)
                .fontSize(16)
                .fontColor('#000000')
                .lineHeight(22)
                .fontWeight(step.isCompleted ? 400 : 500)
                .flexGrow(1)
                .margin({ left: 12 })
              Text(step.distance + 'm')
                .fontSize(14)
                .fontColor('#000000')
                .opacity(0.6)
                .lineHeight(20)
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder EmptyView() {
    Column() {
      Text('🚗')
        .fontSize(64)
        .lineHeight(90)
      Text('暂无停车记录')
        .fontSize(16)
        .fontColor('#000000')
        .opacity(0.6)
        .lineHeight(22)
        .margin({ top: 12 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 200 })
  }

  formatDuration(seconds: number): string {
    const hours: number = Math.floor(seconds / 3600);
    const minutes: number = Math.floor((seconds % 3600) / 60);
    const secs: number = seconds % 60;
    if (hours > 0) {
      return hours + '小时' + minutes + '分钟';
    } else if (minutes > 0) {
      return minutes + '分钟';
    } else {
      return secs + '秒';
    }
  }
}

@Component
struct BottomActionBar {
  onStopNavigation: () => void = () => {};

  build() {
    Row() {
      Button('📍 开始导航')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#1677FF')
        .borderRadius(8)
        .height(40)
        .flexGrow(1)
        .type(ButtonType.Normal)
      Button('📷 更新照片')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#1677FF')
        .borderRadius(8)
        .height(40)
        .flexGrow(1)
        .margin({ left: 12 })
        .type(ButtonType.Normal)
      Button('💰 去缴费')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#1677FF')
        .borderRadius(8)
        .height(40)
        .flexGrow(1)
        .margin({ left: 12 })
        .type(ButtonType.Normal)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}

@Component
export struct PaymentBottomSheet {
  @Prop parkingRecord: ParkingRecord | null = null;
  @Link showPaymentSheet: boolean;

  build() {
    Row() {
      Column() {
        Row() {
          Text('💰 停车缴费')
            .fontSize(20)
            .fontColor('#000000')
            .fontWeight(600)
            .lineHeight(28)
          Text('✕')
            .fontSize(24)
            .fontColor('#000000')
            .opacity(0.4)
            .lineHeight(33)
            .margin({ left: 'auto' })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })
        Column() {
          Text('¥' + this.parkingRecord?.currentFee.toFixed(2))
            .fontSize(36)
            .fontColor('#FF4D4F')
            .fontWeight(600)
            .lineHeight(50)
          Text('停放时长: ' + (this.parkingRecord ? this.formatDuration(Date.now() - this.parkingRecord.parkTime) : '0分钟'))
            .fontSize(14)
            .fontColor('#000000')
            .opacity(0.6)
            .lineHeight(20)
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })
        Divider()
          .color('#F0F0F0')
          .strokeWidth(0.5)
        Row() {
          Column() {
            Text('基础费用')
              .fontSize(14)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(20)
            Text('¥' + this.parkingRecord?.feeDetails.baseFee.toFixed(2))
              .fontSize(16)
              .fontColor('#000000')
              .lineHeight(22)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1)
          Column() {
            Text('周末折扣')
              .fontSize(14)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(20)
            Text('-¥' + Math.abs(this.parkingRecord?.feeDetails.weekendDiscount).toFixed(2))
              .fontSize(16)
              .fontColor('#52C41A')
              .lineHeight(22)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1)
          Column() {
            Text('封顶优惠')
              .fontSize(14)
              .fontColor('#000000')
              .opacity(0.6)
              .lineHeight(20)
            Text('-¥' + Math.abs(this.parkingRecord?.feeDetails.capDiscount).toFixed(2))
              .fontSize(16)
              .fontColor('#52C41A')
              .lineHeight(22)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1)
        }
        .width('100%')
        .padding(16)
        Row() {
          Text('确认支付')
            .fontSize(16)
            .fontColor(Color.White)
            .lineHeight(22)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#1677FF')
        .borderRadius(8)
        .margin({ left: 16, right: 16, top: 12, bottom: 16 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Bottom)
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.4)')
    .onClick(() => {
      this.showPaymentSheet = false;
    })
  }

  formatDuration(ms: number): string {
    const seconds: number = Math.floor(ms / 1000);
    const hours: number = Math.floor(seconds / 3600);
    const minutes: number = Math.floor((seconds % 3600) / 60);
    const secs: number = seconds % 60;
    if (hours > 0) {
      return hours + '小时' + minutes + '分钟';
    } else if (minutes > 0) {
      return minutes + '分钟';
    } else {
      return secs + '秒';
    }
  }
}
