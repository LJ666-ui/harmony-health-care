import { ParkingSpace } from '../models/ParkingModels';
import { ParkingService } from '../parking/ParkingService';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ParkingSpacePage {
  @State parkingSpaces: ParkingSpace[] = [];
  @State isLoading: boolean = true;
  @State lotId: string = '';

  private parkingService: ParkingService = ParkingService.getInstance();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    this.lotId = params.lotId;
    this.loadParkingSpaces();
  }

  async loadParkingSpaces() {
    this.isLoading = true;
    try {
      this.parkingSpaces = await this.parkingService.getParkingSpaces(this.lotId);
    } catch (error) {
      console.error('Failed to load parking spaces:', error);
    } finally {
      this.isLoading = false;
    }
  }

  onSpaceClick(space: ParkingSpace) {
    if (space.status === 'AVAILABLE') {
      console.log('Reserve space:', space.id);
    }
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
        } else {
          Grid() {
            ForEach(this.parkingSpaces, (space: ParkingSpace) => {
              GridItem() {
                ParkingSpaceItem({ parkingSpace: space })
              }
              .onClick(() => {
                this.onSpaceClick(space);
              })
            })
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
          .rowsGap(8)
          .columnsGap(8)
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
      Text('车位预约')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(600)
      Row()
        .width(32)
        .height(32)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#1677FF')
  }
}

@Component
export struct ParkingSpaceItem {
  @Prop parkingSpace: ParkingSpace;
  @State reservationTime: number = 0;

  build() {
    Column() {
      Text(this.parkingSpace.spaceNumber)
        .fontSize(14)
        .fontColor('#FFFFFF')
        .fontWeight(500)
        .lineHeight(20)
      Text(`${this.parkingSpace.floor}`)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .opacity(0.9)
        .lineHeight(17)
        .margin({ top: 4 })
      if (this.parkingSpace.status === 'RESERVED') {
        Text(`${this.formatTime(this.reservationTime)}`)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .lineHeight(17)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getStatusColor())
    .borderRadius(8)
  }

  getStatusColor() {
    switch (this.parkingSpace.status) {
      case 'AVAILABLE':
        return '#52C41A';
      case 'OCCUPIED':
        return '#FF4D4F';
      case 'RESERVED':
        return '#FAAD14';
      default:
        return '#52C41A';
    }
  }

  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
}
