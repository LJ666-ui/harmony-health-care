import { ParkingService, ParkingConstants } from '../parking/ParkingService';
import { ARNavigationView } from '../components/ARNavigationView';
import { ParkingTimer } from '../components/ParkingTimer';
import { parkingMockData } from '../mock/parkingMock';
import { NavigationTitleBar } from '../components/NavigationTitleBar';

@Entry
@Component
export struct FindCarPage {
  @State parkingRecord: any = null;
  @State isLoading: boolean = true;
  @State navigationMode: 'map' | 'ar' | 'text' = 'ar';
  @State isNavigating: boolean = false;
  @State arNavigationData: {
    distanceRemaining: number;
    bearing: number;
    instruction: string;
    isArrived: boolean
  } = {
    distanceRemaining: 100,
    bearing: 0,
    instruction: '',
    isArrived: false
  };
  private navigationTimerId: number | null = null;

  aboutToAppear(): void {
    this.loadParkingRecord();
  }

  aboutToDisappear(): void {
    this.stopNavigation();
  }

  async loadParkingRecord(): Promise<void> {
    try {
      this.isLoading = true;
      
      const service = ParkingService.getInstance();
      const record = await service.getParkingRecord('USER_001');
      
      if (record) {
        this.parkingRecord = record;
        console.log('[FindCarPage] 加载停车记录成功');
      } else {
        console.log('[FindCarPage] 无有效停车记录，使用Mock数据');
        this.parkingRecord = parkingMockData.activeRecord;
      }
    } catch (error) {
      console.error('[FindCarPage] 加载失败:', error.message);
      this.parkingRecord = parkingMockData.activeRecord;
    } finally {
      this.isLoading = false;
    }
  }

  startMapNavigation(): void {
    if (!this.parkingRecord) return;
    
    const targetLat = this.parkingRecord.latitude;
    const targetLng = this.parkingRecord.longitude;
    
    try {
      console.log('[FindCarPage] 启动地图导航到:', targetLat, targetLng);
      
      AlertDialog.show({
        title: '导航提示',
        message: `正在导航到 ${this.parkingRecord.spaceNumber} 车位\n${this.parkingRecord.lotName} ${this.parkingRecord.floor}`,
        primaryText: '确定'
      });
    } catch (error) {
      console.error('[FindCarPage] 地图导航启动失败:', error.message);
      AlertDialog.show({
        title: '提示',
        message: '系统地图暂不可用，请使用其他导航方式',
        primaryText: '确定'
      });
    }
  }

  startARNavigation(): void {
    if (!this.parkingRecord) return;
    
    this.isNavigating = true;
    this.navigationMode = 'ar';
    
    let distance = 128;
    const bearing = Math.floor(Math.random() * 360);
    
    this.arNavigationData = {
      distanceRemaining: distance,
      bearing: bearing,
      instruction: this.getInstructionByDistance(distance),
      isArrived: false
    };
    
    this.navigationTimerId = setInterval(() => {
      if (distance > 5) {
        distance -= Math.random() * 8 + 2;
        
        if (distance < 0) {
          distance = 0;
        }
        
        this.arNavigationData = {
          distanceRemaining: Math.round(distance),
          bearing: bearing + (Math.random() - 0.5) * 10,
          instruction: this.getInstructionByDistance(distance),
          isArrived: distance <= 5
        };
      } else {
        this.arNavigationData.isArrived = true;
        this.stopNavigation();
      }
    }, 500);
  }

  stopNavigation(): void {
    if (this.navigationTimerId) {
      clearInterval(this.navigationTimerId);
      this.navigationTimerId = null;
    }
    this.isNavigating = false;
  }

  getInstructionByDistance(distance: number): string {
    if (distance > 100) {
      return '继续前进，距离较远';
    } else if (distance > 50) {
      return '向前直行50米';
    } else if (distance > 20) {
      return '即将到达，注意观察车位标识';
    } else if (distance > 10) {
      return '车位就在前方左侧/右侧';
    } else {
      return '您已接近停车位';
    }
  }

  showTextGuide(): void {
    if (!this.parkingRecord) return;
    
    const guide = this.generateTextGuide(this.parkingRecord);
    
    AlertDialog.show({
      title: '📋 文字指引',
      message: guide,
      primaryText: '我知道了',
      secondaryText: '复制指引',
      onSecondaryClick: () => {
        console.log('[FindCarPage] 复制文字指引到剪贴板');
      }
    });
  }

  generateTextGuide(record: any): string {
    return `
📍 目标：${record.spaceNumber}
🏢 停车场：${record.lotName}
📍 楼层：${record.floor}

🚶‍♂️ 导航路线：
1. 从门诊大厅北门进入
2. 乘坐扶梯下${record.floor}层
3. 向左转50米
4. 进入A区
5. 找到第${record.spaceNumber.split('-')[1]}号车位

📝 备注：${record.note || '无'}
💰 预计费用：¥${this.calculateCurrentFee().toFixed(2)}
    `.trim();
  }

  calculateCurrentFee(): number {
    if (!this.parkingRecord) return 0;
    
    const startTime = new Date(this.parkingRecord.parkingTime).getTime();
    const elapsed = Date.now() - startTime;
    const minutes = elapsed / (1000 * 60);
    const chargeableMinutes = Math.max(0, minutes - 60);
    
    if (chargeableMinutes <= 0) return 0;
    
    const hours = chargeableMinutes / 60;
    const fee = hours * 5;
    const days = Math.ceil(hours / 24);
    
    return Math.min(fee, days * 50);
  }

  updatePhoto(): void {
    console.log('[FindCarPage] 从相册选择新照片（无摄像头版本）');
    
    AlertDialog.show({
      title: '更新照片',
      message: '将从相册选择照片更新停车位置记录',
      primaryText: '去相册选择',
      secondaryText: '取消',
      onPrimaryClick: () => {
        console.log('[FindCarPage] 打开相册选择器');
      }
    });
  }

  goToPayment(): void {
    if (!this.parkingRecord) return;
    
    const fee = this.calculateCurrentFee();
    
    AlertDialog.show({
      title: '💰 停车缴费',
      message: `
当前费用：¥${fee.toFixed(2)}
停车时长：${this.formatDuration(Date.now() - new Date(this.parkingRecord.parkingTime).getTime())}
车位号：${this.parkingRecord.spaceNumber}

确认支付？
      `.trim(),
      primaryText: '立即支付',
      secondaryText: '取消',
      onPrimaryClick: () => {
        AlertDialog.show({
          title: '支付成功',
          message: '已支付 ¥' + fee.toFixed(2) + '\n感谢使用智慧停车服务！',
          primaryText: '完成'
        });
      }
    });
  }

  formatDuration(milliseconds: number): string {
    const totalMinutes = Math.floor(milliseconds / (1000 * 60));
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return `${hours}小时${minutes}分钟`;
    }
    return `${minutes}分钟`;
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '🚗 反向寻车', 
        showBack: true 
      })
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.parkingRecord) {
        this.buildEmptyView()
      } else if (this.isNavigating && this.navigationMode === 'ar') {
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
      
      Text('正在加载停车信息...')
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
      
      Text('暂无停车记录')
        .fontSize(20)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
      
      Text('您当前没有进行中的停车记录')
        .fontSize(14)
        .fontColor('#999999')
      
      Button('去停车')
        .width(200)
        .height(45)
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .onClick(() => {
          console.log('[FindCarPage] 跳转到停车场选择页面');
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildMainView() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildParkingInfoCard()
        
        this.buildTimerCard()
        
        this.buildPhotoAndNoteCard()
        
        this.buildNavigationOptions()
        
        this.buildActionButtons()
      }
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildParkingInfoCard() {
    Column({ space: 12 }) {
      Row() {
        Text('📍 停车位置')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      Grid() {
        GridItem() {
          this.buildInfoItem('停车场', this.parkingRecord?.lotName || '-')
        }.rowStart(0).columnStart(0)
        
        GridItem() {
          this.buildInfoItem('车位号', this.parkingRecord?.spaceNumber || '-')
        }.rowStart(0).columnStart(1)
        
        GridItem() {
          this.buildInfoItem('楼层', this.parkingRecord?.floor || '-')
        }.rowStart(1).columnStart(0)
        
        GridItem() {
          this.buildInfoItem('停放时间', this.formatParkingTime(this.parkingRecord?.parkingTime))
        }.rowStart(1).columnStart(1)
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
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

  @Builder buildInfoItem(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#999999')
      Text(value)
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder buildTimerCard() {
    ParkingTimer({
      startTime: new Date(this.parkingRecord?.parkingTime).getTime(),
      hourlyRate: 5,
      freeMinutes: 60,
      dailyCap: 50
    })
  }

  @Builder buildPhotoAndNoteCard() {
    Column({ space: 12 }) {
      Row() {
        Text('📷 停放照片与备注')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
        
        Blank()
        
        Text('更新')
          .fontSize(14)
          .fontColor('#1677FF')
          .onClick(() => this.updatePhoto())
      }
      .width('100%')
      
      if (this.parkingRecord?.photoUri && this.parkingRecord.photoUri !== '') {
        Image(this.parkingRecord.photoUri)
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
      } else {
        Column({ space: 8 }) {
          Text('📷')
            .fontSize(40)
          Text('暂无照片')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(120)
        .backgroundColor('#F8F8F8')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }
      
      if (this.parkingRecord?.note) {
        Text('📝 ' + this.parkingRecord.note)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
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

  @Builder buildNavigationOptions() {
    Column({ space: 12 }) {
      Row() {
        Text('🧭 选择导航方式')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      
      Row({ space: 12 }) {
        this.buildNavOptionButton(
          '🗺️',
          '地图导航',
          this.navigationMode === 'map',
          () => this.startMapNavigation()
        )
        
        this.buildNavOptionButton(
          '🎯',
          '模拟AR导航',
          this.navigationMode === 'ar',
          () => this.startARNavigation()
        )
        
        this.buildNavOptionButton(
          '📋',
          '文字指引',
          this.navigationMode === 'text',
          () => this.showTextGuide()
        )
      }
      .width('100%')
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

  @Builder buildNavOptionButton(icon: string, label: string, isSelected: boolean, onClick: () => void) {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(28)
      Text(label)
        .fontSize(12)
        .fontColor(isSelected ? '#1677FF' : '#666666')
    }
    .width(100)
    .height(80)
    .backgroundColor(isSelected ? '#E6F4FF' : '#F5F5F5')
    .borderRadius(8)
    .border({
      width: isSelected ? 2 : 1,
      color: isSelected ? '#1677FF' : 'transparent'
    })
    .justifyContent(FlexAlign.Center)
    .onClick(onClick)
  }

  @Builder buildActionButtons() {
    Row({ space: 12 }) {
      Button('📍 开始导航')
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#1677FF')
        .borderRadius(24)
        .onClick(() => {
          if (this.navigationMode === 'map') {
            this.startMapNavigation();
          } else if (this.navigationMode === 'ar') {
            this.startARNavigation();
          } else {
            this.showTextGuide();
          }
        })
      
      Button('📷 更新照片')
        .layoutWeight(1)
        .height(48)
        .backgroundColor('#FFFFFF')
        .fontColor('#1677FF')
        .borderRadius(24)
        .border({ width: 1, color: '#1677FF' })
        .onClick(() => this.updatePhoto())
    }
    .width('100%')
    
    Button('💰 去缴费')
      .width('100%')
      .height(48)
      .margin({ top: 12 })
      .backgroundColor('#FF4D4F')
      .borderRadius(24)
      .onClick(() => this.goToPayment())
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

  formatParkingTime(timeStr: string): string {
    if (!timeStr) return '-';
    
    const date = new Date(timeStr);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${month}-${day} ${hours}:${minutes}`;
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
