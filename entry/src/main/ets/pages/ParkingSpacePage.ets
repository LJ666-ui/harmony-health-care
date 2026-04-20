import { ParkingService, ParkingConstants, SpaceStatus, SpaceType } from '../parking/ParkingService';
import { ParkingMap } from '../components/ParkingMap';
import { SpaceMarker } from '../components/SpaceMarker';
import { parkingMockData } from '../mock/parkingMock';

@Entry
@Component
export struct ParkingSpacePage {
  @State selectedLot: any = null;
  @State spaces: any[] = [];
  @State selectedSpace: any = null;
  @State isLoading: boolean = true;
  @State filterType: string = 'ALL';
  @State isReserving: boolean = false;
  @State reservationResult: any = null;

  aboutToAppear(): void {
    this.loadParkingSpaces();
  }

  async loadParkingSpaces(): Promise<void> {
    try {
      this.isLoading = true;
      
      const service = ParkingService.getInstance();
      
      const lots = await service.getParkingLots();
      if (lots && lots.length > 0) {
        this.selectedLot = lots[0];
        
        const spaceList = await service.getParkingSpaces(this.selectedLot.id);
        if (spaceList && spaceList.length > 0) {
          this.spaces = spaceList;
          console.log('[ParkingSpacePage] 加载车位成功，数量:', spaceList.length);
        }
      }
    } catch (error) {
      console.error('[ParkingSpacePage] 加载失败:', error.message);
      this.selectedLot = parkingMockData.parkingLots[0];
      this.spaces = parkingMockData.getSpacesByLotId(this.selectedLot.id);
    } finally {
      this.isLoading = false;
    }
  }

  async reserveSelectedSpace(): Promise<void> {
    if (!this.selectedSpace || this.isReserving) return;
    
    if (this.selectedSpace.status !== SpaceStatus.AVAILABLE) {
      AlertDialog.show({
        title: '提示',
        message: '该车位当前不可预约',
        primaryText: '确定'
      });
      return;
    }
    
    this.isReserving = true;
    
    try {
      console.log('[ParkingSpacePage] 开始预约车位:', this.selectedSpace.spaceNumber);
      
      const service = ParkingService.getInstance();
      const result = await service.reserveSpace(this.selectedSpace.id, 'USER_001');
      
      this.reservationResult = result;
      
      if (result.success) {
        AlertDialog.show({
          title: '✅ 预约成功',
          message: `车位号：${this.selectedSpace.spaceNumber}\n预约ID：${result.reservationId}\n有效期：15分钟\n\n${result.message}`,
          primaryText: '开始导航',
          secondaryText: '查看详情',
          onPrimaryClick: () => {
            console.log('[ParkingSpacePage] 跳转到导航页面');
          },
          onSecondaryClick: () => {
            console.log('[ParkingSpacePage] 查看预约详情');
          }
        });
        
        this.updateSpaceStatus(this.selectedSpace.id, SpaceStatus.RESERVED);
      } else {
        AlertDialog.show({
          title: '❌ 预约失败',
          message: result.message || '请稍后重试',
          primaryText: '确定'
        });
      }
    } catch (error) {
      console.error('[ParkingSpacePage] 预约失败:', error.message);
      AlertDialog.show({
        title: '错误',
        message: '预约失败：' + error.message,
        primaryText: '确定'
      });
    } finally {
      this.isReserving = false;
    }
  }

  updateSpaceStatus(spaceId: string, newStatus: SpaceStatus): void {
    const index = this.spaces.findIndex(s => s.id === spaceId);
    if (index !== -1) {
      this.spaces[index].status = newStatus;
    }
  }

  handleSpaceClick(space: any): void {
    this.selectedSpace = space;
    console.log('[ParkingSpacePage] 选择车位:', space.spaceNumber);
  }

  getFilteredSpaces(): any[] {
    if (this.filterType === 'ALL') {
      return this.spaces;
    }
    return this.spaces.filter(s => s.type === this.filterType);
  }

  getSpaceStatistics(): { total: number; available: number; occupied: number; reserved: number } {
    const filtered = this.getFilteredSpaces();
    return {
      total: filtered.length,
      available: filtered.filter(s => s.status === SpaceStatus.AVAILABLE).length,
      occupied: filtered.filter(s => s.status === SpaceStatus.OCCUPIED).length,
      reserved: filtered.filter(s => s.status === SpaceStatus.RESERVED).length
    };
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '🅿️ 车位选择', 
        showBack: true 
      })
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.selectedLot) {
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
      
      Text('正在加载车位信息...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildEmptyView() {
    Column({ space: 30 }) {
      Text('🅿️')
        .fontSize(80)
      
      Text('暂无停车场信息')
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
      
      Button('返回选择停车场')
        .width(200)
        .height(45)
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .onClick(() => {
          console.log('[ParkingSpacePage] 返回停车场选择页面');
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildMainView() {
    Column({ space: 12 }) {
      this.buildLotInfoCard()
      
      this.buildFilterBar()
      
      this.buildStatisticsBar()
      
      Scroll() {
        Column({ space: 8 }) {
          ForEach(this.getFilteredSpaces(), (space: any, index: number) => {
            this.buildSpaceItem(space)
          })
        }
        .padding(12)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      
      if (this.selectedSpace) {
        this.buildBottomActionPanel()
      }
    }
  }

  @Builder buildLotInfoCard() {
    Row({ space: 12 }) {
      Image($r('sys.media.ic_public_parking'))
        .width(40)
        .height(40)
        .fillColor('#1677FF')
      
      Column({ space: 4 }) {
        Text(this.selectedLot?.name || '')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
        Text(`¥${this.selectedLot?.hourlyRate}/小时 | 距离${this.selectedLot?.distance}米`)
          .fontSize(13)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Text(`${this.getSpaceStatistics().available}/${this.getSpaceStatistics().total} 空位`)
        .fontSize(14)
        .fontColor('#52C41A')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({ horizontal: 16, vertical: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder buildFilterBar() {
    Row({ space: 8 }) {
      this.buildFilterButton('ALL', '全部', 'ALL' === this.filterType)
      this.buildFilterButton(SpaceType.NORMAL, '普通', SpaceType.NORMAL === this.filterType)
      this.buildFilterButton(SpaceType.DISABLED, '无障碍', SpaceType.DISABLED === this.filterType)
      this.buildFilterButton(SpaceType.ELECTRIC, '新能源', SpaceType.ELECTRIC === this.filterType)
      this.buildFilterButton(SpaceType.CHARGING, '充电桩', SpaceType.CHARGING === this.filterType)
    }
    .width('100%')
    .padding({ horizontal: 16 })
  }

  @Builder buildFilterButton(type: string, label: string, isSelected: boolean) {
    Text(label)
      .fontSize(13)
      .fontColor(isSelected ? '#FFFFFF' : '#666666')
      .padding({ horizontal: 12, vertical: 6 })
      .borderRadius(15)
      .backgroundColor(isSelected ? '#1677FF' : '#F0F0F0')
      .onClick(() => {
        this.filterType = type;
      })
  }

  @Builder buildStatisticsBar() {
    Row({ space: 20 }) {
      this.buildStatItem('总计', this.getSpaceStatistics().total.toString(), '#333333')
      this.buildStatItem('空闲', this.getSpaceStatistics().available.toString(), '#52C41A')
      this.buildStatItem('占用', this.getSpaceStatistics().occupied.toString(), '#FF4D4F')
      this.buildStatItem('预约', this.getSpaceStatistics().reserved.toString(), '#FAAD14')
    }
    .width('100%')
    .padding({ horizontal: 16, vertical: 8 })
    .backgroundColor('#FAFAFA')
    .borderRadius(8)
  }

  @Builder buildStatItem(label: string, value: string, color: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(18)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)
      Text(label)
        .fontSize(11)
        .fontColor('#999999')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder buildSpaceItem(space: any) {
    Row({ space: 12 }) {
      SpaceMarker({
        space: space,
        isSelected: this.selectedSpace?.id === space.id,
        size: 50,
        onClick: (s: any) => this.handleSpaceClick(s)
      })
      
      Column({ space: 4 }) {
        Row() {
          Text(space.spaceNumber)
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Text(this.getStatusLabel(space.status))
            .fontSize(12)
            .fontColor(this.getStatusColor(space.status))
            .padding({ horizontal: 8, vertical: 2 })
            .borderRadius(10)
            .backgroundColor(this.getStatusBgColor(space.status))
        }
        .width('100%')
        
        Row({ space: 12 }) {
          Text(`楼层: ${space.floor}`)
            .fontSize(13)
            .fontColor('#666666')
          Text(`类型: ${this.getTypeLabel(space.type)}`)
            .fontSize(13)
            .fontColor('#666666')
        }
        .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(
      this.selectedSpace?.id === space.id ? '#E6F4FF' : '#FFFFFF'
    )
    .borderRadius(8)
    .border({
      width: this.selectedSpace?.id === space.id ? 2 : 0,
      color: this.selectedSpace?.id === space.id ? '#1677FF' : 'transparent'
    })
    .shadow({
      radius: this.selectedSpace?.id === space.id ? 8 : 2,
      color: this.selectedSpace?.id === space.id ? 'rgba(22,119,255,0.15)' : 'rgba(0,0,0,0.04)',
      offsetX: 0,
      offsetY: 1
    })
    .onClick(() => this.handleSpaceClick(space))
  }

  @Builder buildBottomActionPanel() {
    Column({ space: 12 }) {
      if (this.isReserving) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#FFFFFF')
          Text('正在预约...')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .width('100%')
        .height(50)
        .backgroundColor('#A0CFFF')
        .borderRadius(25)
        .justifyContent(FlexAlign.Center)
      } else {
        Button(`预约 ${this.selectedSpace?.spaceNumber} 车位`)
          .width('100%')
          .height(50)
          .backgroundColor(
            this.selectedSpace?.status === SpaceStatus.AVAILABLE
              ? '#1677FF'
              : '#CCCCCC'
          )
          .borderRadius(25)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .enabled(this.selectedSpace?.status === SpaceStatus.AVAILABLE)
          .onClick(() => this.reserveSelectedSpace())
      }
      
      Text(`预约后将锁定15分钟，请尽快到达`)
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ horizontal: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: -2
    })
  }

  getStatusLabel(status: string): string {
    switch (status) {
      case SpaceStatus.AVAILABLE:
        return '空闲';
      case SpaceStatus.OCCUPIED:
        return '占用';
      case SpaceStatus.RESERVED:
        return '预约中';
      default:
        return status;
    }
  }

  getStatusColor(status: string): string {
    switch (status) {
      case SpaceStatus.AVAILABLE:
        return '#52C41A';
      case SpaceStatus.OCCUPIED:
        return '#FF4D4F';
      case SpaceStatus.RESERVED:
        return '#FAAD14';
      default:
        return '#999999';
    }
  }

  getStatusBgColor(status: string): string {
    switch (status) {
      case SpaceStatus.AVAILABLE:
        return '#F6FFED';
      case SpaceStatus.OCCUPIED:
        return '#FFF2F0';
      case SpaceStatus.RESERVED:
        return '#FFFBE6';
      default:
        return '#F5F5F5';
    }
  }

  getTypeLabel(type: string): string {
    switch (type) {
      case SpaceType.NORMAL:
        return '普通';
      case SpaceType.DISABLED:
        return '无障碍';
      case SpaceType.ELECTRIC:
        return '新能源';
      case SpaceType.CHARGING:
        return '充电桩';
      default:
        return type;
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
