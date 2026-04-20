import { ParkingService, ParkingConstants } from '../parking/ParkingService';
import { parkingMockData } from '../mock/parkingMock';

@Entry
@Component
export struct ParkingLotPage {
  @State parkingLots: any[] = [];
  @State isLoading: boolean = true;
  @State currentLocation: any = null;

  aboutToAppear(): void {
    this.loadParkingLots();
    this.getCurrentLocation();
  }

  async loadParkingLots(): Promise<void> {
    try {
      this.isLoading = true;
      
      const service = ParkingService.getInstance();
      const lots = await service.getParkingLots();
      
      if (lots && lots.length > 0) {
        this.parkingLots = lots;
        console.log('[ParkingLotPage] 加载停车场成功，数量:', lots.length);
      }
    } catch (error) {
      console.error('[ParkingLotPage] 加载失败:', error.message);
      this.parkingLots = parkingMockData.parkingLots;
    } finally {
      this.isLoading = false;
    }
  }

  async getCurrentLocation(): Promise<void> {
    try {
      const locationService = LocationService.getInstance();
      const result = await locationService.getCurrentLocation();
      
      if (result.success) {
        this.currentLocation = result.location;
        console.log('[ParkingLotPage] 获取位置成功');
      }
    } catch (error) {
      console.error('[ParkingLotPage] 获取位置失败:', error.message);
      this.currentLocation = {
        latitude: 39.9075,
        longitude: 116.4102,
        accuracy: 10,
        timestamp: Date.now()
      };
    }
  }

  selectParkingLot(lot: any): void {
    console.log('[ParkingLotPage] 选择停车场:', lot.name);
    
    AlertDialog.show({
      title: lot.name,
      message: `地址：${lot.address}\n总车位：${lot.totalSpaces}个\n空闲车位：${lot.availableSpaces}个\n费率：¥${lot.hourlyRate}/小时\n距离：${lot.distance}米`,
      primaryText: '查看车位',
      secondaryText: '导航前往',
      onPrimaryClick: () => {
        console.log('[ParkingLotPage] 跳转到车位选择页面，停车场ID:', lot.id);
      },
      onSecondaryClick: () => {
        this.navigateToLot(lot);
      }
    });
  }

  navigateToLot(lot: any): void {
    try {
      console.log('[ParkingLotPage] 导航到停车场:', lot.name, '坐标:', lot.latitude, lot.longitude);
      
      AlertDialog.show({
        title: '📍 导航提示',
        message: `正在启动导航到 ${lot.name}\n${lot.address}`,
        primaryText: '确定'
      });
    } catch (error) {
      console.error('[ParkingLotPage] 导航失败:', error.message);
      AlertDialog.show({
        title: '提示',
        message: '系统地图暂不可用',
        primaryText: '确定'
      });
    }
  }

  getAvailabilityColor(available: number, total: number): string {
    const ratio = available / total;
    if (ratio > 0.3) {
      return '#52C41A';
    } else if (ratio > 0.1) {
      return '#FAAD14';
    } else {
      return '#FF4D4F';
    }
  }

  getAvailabilityLabel(available: number, total: number): string {
    const ratio = available / total;
    if (ratio > 0.3) {
      return '充足';
    } else if (ratio > 0.1) {
      return '紧张';
    } else {
      return '已满';
    }
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '🅿️ 选择停车场', 
        showBack: true 
      })
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.parkingLots.length === 0) {
        this.buildEmptyView()
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
      
      Text('正在加载附近停车场...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildEmptyView() {
    Column({ space: 30 }) {
      Text('🚗')
        .fontSize(80)
      
      Text('附近暂无停车场')
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
      
      Text('请检查网络连接或稍后重试')
        .fontSize(14)
        .fontColor('#999999')
      
      Button('刷新')
        .width(200)
        .height(45)
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .onClick(() => this.loadParkingLots())
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildMainView() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.parkingLots, (lot: any, index: number) => {
          this.buildParkingLotCard(lot)
        })
        
        this.buildTipsSection()
      }
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildParkingLotCard(lot: any) {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Image($r('sys.media.ic_public_parking'))
          .width(48)
          .height(48)
          .fillColor('#1677FF')
        
        Column({ space: 4 }) {
          Row() {
            Text(lot.name)
              .fontSize(18)
              .fontColor('#333333')
              .fontWeight(FontStyle.Bold)
            
            Blank()
            
            Text(this.getAvailabilityLabel(lot.availableSpaces, lot.totalSpaces))
              .fontSize(13)
              .fontColor(this.getAvailabilityColor(lot.availableSpaces, lot.totalSpaces))
              .fontWeight(FontWeight.Medium)
              .padding({ horizontal: 10, vertical: 4 })
              .borderRadius(12)
              .backgroundColor(
                this.getAvailabilityBgColor(lot.availableSpaces, lot.totalSpaces)
              )
          }
          .width('100%')
          
          Text(lot.address)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      
      Row({ space: 24 }) {
        this.buildInfoColumn('总车位', lot.totalSpaces.toString())
        this.buildInfoColumn('空闲', lot.availableSpaces.toString(), '#52C41A')
        this.buildInfoColumn('费率', `¥${lot.hourlyRate}/h`)
        this.buildInfoColumn('距离', `${lot.distance}m`)
      }
      .width('100%')
      .padding({ vertical: 8 })
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
      
      Row({ space: 12 }) {
        Button('查看车位')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#1677FF')
          .borderRadius(21)
          .fontSize(15)
          .onClick(() => this.selectParkingLot(lot))
        
        Button('导航前往')
          .layoutWeight(1)
          .height(42)
          .backgroundColor('#FFFFFF')
          .fontColor('#1677FF')
          .borderRadius(21)
          .border({ width: 1, color: '#1677FF' })
          .fontSize(15)
          .onClick(() => this.navigateToLot(lot))
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.selectParkingLot(lot))
  }

  @Builder buildInfoColumn(label: string, value: string, valueColor?: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontColor(valueColor || '#333333')
        .fontWeight(FontWeight.Bold)
      Text(label)
        .fontSize(11)
        .fontColor('#999999')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder buildTipsSection() {
    Column({ space: 12 }) {
      Row() {
        Text('💡 停车小贴士')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      Column({ space: 8 }) {
        this.buildTipItem('首小时免费停车，之后按小时计费');
        this.buildTipItem('预约车位后15分钟内到达，超时自动释放');
        this.buildTipItem('新能源车位和充电桩车位优先供给电动车使用');
        this.buildTipItem('无障碍车位仅供残障人士使用');
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFBE6')
    .borderRadius(12)
    .border({ width: 1, color: '#FFE58F' })
  }

  @Builder buildTipItem(text: string) {
    Row({ space: 8 }) {
      Text('•')
        .fontSize(14)
        .fontColor('#FAAD14')
        .fontWeight(FontWeight.Bold)
      Text(text)
        .fontSize(13)
        .fontColor('#666666')
        .lineHeight(18)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  getAvailabilityBgColor(available: number, total: number): string {
    const ratio = available / total;
    if (ratio > 0.3) {
      return '#F6FFED';
    } else if (ratio > 0.1) {
      return '#FFFBE6';
    } else {
      return '#FFF2F0';
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
