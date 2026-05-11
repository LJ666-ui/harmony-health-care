import { ParkingLot, ParkingSpace, Location } from '../models/ParkingModels';
import { ParkingService } from '../parking/ParkingService';
import { router } from '@kit.ArkUI';
import { ToastUtil } from '../common/utils/ToastUtil';

@Entry
@Component
struct ParkingListPage {
  @State parkingLots: ParkingLot[] = [];
  @State isLoading: boolean = true;
  @State selectedLot: ParkingLot | null = null;

  private parkingService: ParkingService = ParkingService.getInstance();

  aboutToAppear(): void {
    this.loadParkingLots();
  }

  async loadParkingLots() {
    this.isLoading = true;
    try {
      await this.parkingService.init();
      
      let userLocation: Location;
      try {
        userLocation = await this.parkingService.getCurrentLocation();
      } catch (locationError) {
        console.warn('获取位置失败，使用默认位置:', locationError);
        const defaultLocation: Location = {
          latitude: 39.913889,
          longitude: 116.417778
        };
        userLocation = defaultLocation;
      }
      
      this.parkingLots = await this.parkingService.getParkingLots(userLocation.latitude, userLocation.longitude);
    } catch (error) {
      console.error('Failed to load parking lots:', error);
      ToastUtil.showError('加载停车场失败');
    } finally {
      this.isLoading = false;
    }
  }

  onLotClick(lot: ParkingLot) {
    this.selectedLot = lot;
    router.pushUrl({
      url: 'pages/ParkingSpacePage',
      params: {
        lotId: lot.id
      }
    });
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
        } else if (this.parkingLots.length === 0) {
          Column() {
            Text('🅿️')
              .fontSize(64)
              .margin({ bottom: 16 });
            
            Text('暂无停车场数据')
              .fontSize(16)
              .fontColor('#999999');
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center);
        } else {
          List({ space: 12 }) {
            ForEach(this.parkingLots, (lot: ParkingLot) => {
              ListItem() {
                ParkingLotItem({ parkingLot: lot })
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16 })
        }
      }
      .width('100%')
      .height('100%')
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
      Text('智慧停车')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(600)
      Row() {
        Text('🔄')
          .fontSize(20)
      }
      .height(32)
      .padding({ left: 8, right: 8 })
      .onClick(() => {
        this.loadParkingLots();
      })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#1677FF')
  }
}

@Component
export struct ParkingLotItem {
  @Prop parkingLot: ParkingLot;

  build() {
    Column() {
      Row() {
        Text(this.parkingLot.name)
          .fontSize(18)
          .fontColor('#000000')
          .fontWeight(600)
          .lineHeight(25)
          .flexGrow(1)
        Text(`${this.parkingLot.distance}m`)
          .fontSize(14)
          .fontColor('#1677FF')
          .fontWeight(500)
          .lineHeight(20)
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      Row() {
        Text(`空闲车位: ${this.parkingLot.availableSpaces}/${this.parkingLot.totalSpaces}`)
          .fontSize(14)
          .fontColor('#000000')
          .opacity(0.6)
          .lineHeight(20)
          .flexGrow(1)
        Text(`¥${this.parkingLot.hourlyRate}/小时`)
          .fontSize(14)
          .fontColor('#000000')
          .opacity(0.6)
          .lineHeight(20)
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .margin({ top: 8 })
      if (this.parkingLot.hasCharging || this.parkingLot.hasDisabled) {
        Row() {
          if (this.parkingLot.hasCharging) {
            Text('充电桩')
              .fontSize(12)
              .fontColor('#52C41A')
              .lineHeight(17)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#F6FFED')
              .borderRadius(4)
          }
          if (this.parkingLot.hasDisabled) {
            Text('无障碍')
              .fontSize(12)
              .fontColor('#1677FF')
              .lineHeight(17)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#F0F7FF')
              .borderRadius(4)
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}
