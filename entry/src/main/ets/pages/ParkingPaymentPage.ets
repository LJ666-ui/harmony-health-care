import { ParkingService, ParkingConstants } from '../parking/ParkingService';
import { parkingMockData } from '../mock/parkingMock';
import { NavigationTitleBar } from '../components/NavigationTitleBar';

@Entry
@Component
export struct ParkingPaymentPage {
  @State parkingRecord: any = null;
  @State isLoading: boolean = true;
  @State totalFee: number = 0;
  @State selectedPaymentMethod: 'wechat' | 'alipay' | 'unionpay' = 'wechat';
  @State isProcessing: boolean = false;
  @State paymentSuccess: boolean = false;
  @State paymentId: string = '';

  aboutToAppear(): void {
    this.loadParkingRecord();
  }

  async loadParkingRecord(): Promise<void> {
    try {
      this.isLoading = true;
      
      const service = ParkingService.getInstance();
      const record = await service.getParkingRecord('USER_001');
      
      if (record) {
        this.parkingRecord = record;
        this.calculateFee(record);
      } else {
        console.log('[ParkingPaymentPage] 无有效停车记录，使用Mock数据');
        this.parkingRecord = parkingMockData.activeRecord;
        this.calculateFee(parkingMockData.activeRecord);
      }
    } catch (error) {
      console.error('[ParkingPaymentPage] 加载失败:', error.message);
      this.parkingRecord = parkingMockData.activeRecord;
      this.calculateFee(parkingMockData.activeRecord);
    } finally {
      this.isLoading = false;
    }
  }

  calculateFee(record: any): void {
    if (!record) return;
    
    const startTime = new Date(record.parkingTime).getTime();
    const elapsed = Date.now() - startTime;
    const totalMinutes = elapsed / (1000 * 60);
    const chargeableMinutes = Math.max(0, totalMinutes - 60);
    
    if (chargeableMinutes <= 0) {
      this.totalFee = 0;
      return;
    }
    
    const hours = chargeableMinutes / 60;
    const fee = hours * 5;
    const days = Math.ceil(hours / 24);
    this.totalFee = Math.min(fee, days * 50);
    this.totalFee = Math.round(this.totalFee * 100) / 100;
  }

  async processPayment(): Promise<void> {
    if (this.isProcessing) return;
    
    this.isProcessing = true;
    
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      this.paymentId = 'PAY_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
      this.paymentSuccess = true;
      
      console.log('[ParkingPaymentPage] 支付成功，订单号:', this.paymentId);
    } catch (error) {
      console.error('[ParkingPaymentPage] 支付失败:', error.message);
      AlertDialog.show({
        title: '支付失败',
        message: '请稍后重试',
        primaryText: '确定'
      });
    } finally {
      this.isProcessing = false;
    }
  }

  getPaymentMethodIcon(method: string): string {
    switch (method) {
      case 'wechat':
        return '💚';
      case 'alipay':
        return '💙';
      case 'unionpay':
        return '💳';
      default:
        return '💰';
    }
  }

  getPaymentMethodName(method: string): string {
    switch (method) {
      case 'wechat':
        return '微信支付';
      case 'alipay':
        return '支付宝';
      case 'unionpay':
        return '银联云闪付';
      default:
        return '其他支付';
    }
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '💰 停车缴费', 
        showBack: true 
      })
      
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.parkingRecord) {
        this.buildEmptyView()
      } else if (this.paymentSuccess) {
        this.buildSuccessView()
      } else {
        this.buildPaymentView()
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
      
      Text('正在加载缴费信息...')
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
      
      Text('您当前没有需要缴费的停车记录')
        .fontSize(14)
        .fontColor('#999999')
      
      Button('返回')
        .width(200)
        .height(45)
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .onClick(() => {
          console.log('[ParkingPaymentPage] 返回上一页');
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildPaymentView() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildParkingInfoCard()
        
        this.buildFeeDetailsCard()
        
        this.buildPaymentMethodsCard()
        
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
        Text('📍 停车信息')
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

  @Builder buildFeeDetailsCard() {
    Column({ space: 12 }) {
      Row() {
        Text('💰 费用明细')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      Column({ space: 8 }) {
        this.buildFeeItem('停车时长', this.formatDuration())
        this.buildFeeItem('免费时长', '60分钟')
        this.buildFeeItem('计费时长', this.formatChargeableDuration())
        this.buildFeeItem('费率', '¥5.00/小时')
        
        Divider()
          .width('100%')
          .height(1)
          .backgroundColor('#E8E8E8')
        
        this.buildFeeItem('总计', `¥${this.totalFee.toFixed(2)}`, true)
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

  @Builder buildFeeItem(label: string, value: string, isTotal: boolean = false) {
    Row() {
      Text(label)
        .fontSize(isTotal ? 16 : 14)
        .fontColor(isTotal ? '#333333' : '#666666')
        .fontWeight(isTotal ? FontWeight.Bold : FontWeight.Normal)
      
      Blank()
      
      Text(value)
        .fontSize(isTotal ? 18 : 14)
        .fontColor(isTotal ? '#FF4D4F' : '#666666')
        .fontWeight(isTotal ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
  }

  @Builder buildPaymentMethodsCard() {
    Column({ space: 12 }) {
      Row() {
        Text('💳 选择支付方式')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      Column({ space: 8 }) {
        this.buildPaymentMethodItem('wechat')
        this.buildPaymentMethodItem('alipay')
        this.buildPaymentMethodItem('unionpay')
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

  @Builder buildPaymentMethodItem(method: 'wechat' | 'alipay' | 'unionpay') {
    Row() {
      Row({ space: 12 }) {
        Text(this.getPaymentMethodIcon(method))
          .fontSize(24)
        Text(this.getPaymentMethodName(method))
          .fontSize(16)
          .fontColor('#333333')
      }
      
      Blank()
      
      if (this.selectedPaymentMethod === method) {
        Image($r('sys.media.ic_checkbox_checked'))
          .width(20)
          .height(20)
          .fillColor('#1677FF')
      } else {
        Image($r('sys.media.ic_checkbox_unchecked'))
          .width(20)
          .height(20)
          .fillColor('#CCCCCC')
      }
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.selectedPaymentMethod === method ? '#E6F4FF' : 'transparent')
    .borderRadius(8)
    .padding({ horizontal: 12 })
    .onClick(() => {
      this.selectedPaymentMethod = method;
    })
  }

  @Builder buildActionButtons() {
    Column({ space: 12 }) {
      Button('确认支付 ¥' + this.totalFee.toFixed(2))
        .width('100%')
        .height(50)
        .backgroundColor('#1677FF')
        .borderRadius(25)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .onClick(() => this.processPayment())
      
      if (this.isProcessing) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color('#1677FF')
          Text('正在处理支付...')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
  }

  @Builder buildSuccessView() {
    Column({ space: 30 }) {
      Text('✅')
        .fontSize(100)
      
      Text('支付成功')
        .fontSize(24)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
      
      Text('订单号: ' + this.paymentId)
        .fontSize(14)
        .fontColor('#666666')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      Text('支付金额: ¥' + this.totalFee.toFixed(2))
        .fontSize(16)
        .fontColor('#FF4D4F')
        .fontWeight(FontWeight.Medium)
      
      Column({ space: 12 }) {
        Button('返回首页')
          .width(200)
          .height(45)
          .backgroundColor('#1677FF')
          .borderRadius(22)
          .onClick(() => {
            console.log('[ParkingPaymentPage] 返回首页');
          })
        
        Button('查看停车记录')
          .width(200)
          .height(45)
          .backgroundColor('#FFFFFF')
          .fontColor('#1677FF')
          .borderRadius(22)
          .border({ width: 1, color: '#1677FF' })
          .onClick(() => {
            console.log('[ParkingPaymentPage] 跳转到停车记录页面');
          })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
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

  formatDuration(): string {
    if (!this.parkingRecord) return '-';
    
    const startTime = new Date(this.parkingRecord.parkingTime).getTime();
    const elapsed = Date.now() - startTime;
    const totalMinutes = Math.floor(elapsed / (1000 * 60));
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return `${hours}小时${minutes}分钟`;
    }
    return `${minutes}分钟`;
  }

  formatChargeableDuration(): string {
    if (!this.parkingRecord) return '-';
    
    const startTime = new Date(this.parkingRecord.parkingTime).getTime();
    const elapsed = Date.now() - startTime;
    const totalMinutes = Math.floor(elapsed / (1000 * 60));
    const chargeableMinutes = Math.max(0, totalMinutes - 60);
    
    if (chargeableMinutes <= 0) {
      return '0分钟';
    }
    
    const hours = Math.floor(chargeableMinutes / 60);
    const minutes = chargeableMinutes % 60;
    
    if (hours > 0) {
      return `${hours}小时${minutes}分钟`;
    }
    return `${minutes}分钟`;
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
