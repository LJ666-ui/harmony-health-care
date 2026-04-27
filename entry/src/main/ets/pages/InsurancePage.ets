import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface InsuranceInfo {
  cardNumber: string;
  name: string;
  type: string;
  balance: number;
  status: string;
  validDate: string;
}

interface ReimbursementRecord {
  id: number;
  type: string;
  amount: number;
  reimbursed: number;
  date: string;
  status: string;
}

@Entry
@Component
struct InsurancePage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State insuranceInfo: InsuranceInfo | null = null;
  @State records: ReimbursementRecord[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.isLoading = true;
    
    try {
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      this.insuranceInfo = {
        cardNumber: '1101**********1234',
        name: '张三',
        type: '城镇职工基本医疗保险',
        balance: 3568.50,
        status: '正常',
        validDate: '2025-12-31'
      };
      
      this.records = [
        { id: 1, type: '门诊费用', amount: 350.00, reimbursed: 210.00, date: '2024-12-10', status: '已报销' },
        { id: 2, type: '住院费用', amount: 8500.00, reimbursed: 5950.00, date: '2024-11-25', status: '已报销' },
        { id: 3, type: '门诊费用', amount: 280.00, reimbursed: 168.00, date: '2024-11-15', status: '已报销' },
        { id: 4, type: '药品费用', amount: 450.00, reimbursed: 315.00, date: '2024-10-20', status: '已报销' },
        { id: 5, type: '门诊费用', amount: 520.00, reimbursed: 0, date: '2024-12-18', status: '审核中' }
      ];
    } catch (error) {
      console.error('[InsurancePage] 加载数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  refreshInfo(): void {
    ToastUtil.showInfo('刷新中...');
    this.loadData();
  }

  viewRecordDetail(record: ReimbursementRecord): void {
    ToastUtil.showInfo('详情功能开发中');
  }

  build() {
    Column() {
      Header({ title: '医保服务', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#8E44AD')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 医保信息卡片
            if (this.insuranceInfo) {
              Column() {
                Row() {
                  Text('🛡️')
                    .fontSize(30)
                    .margin({ right: 10 })
                  
                  Text('医保卡信息')
                    .fontSize(this.isElderMode ? 18 : 16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333')
                    .layoutWeight(1)
                  
                  Text(this.insuranceInfo.status)
                    .fontSize(12)
                    .fontColor('#fff')
                    .backgroundColor('#2ECC71')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .borderRadius(10)
                }
                .width('100%')
                .margin({ bottom: 15 })

                Row() {
                  Column() {
                    Text('卡号')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                    Text(this.insuranceInfo.cardNumber)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontColor('#333')
                      .fontWeight(FontWeight.Bold)
                      .margin({ top: 5 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Column() {
                    Text('持卡人')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                    Text(this.insuranceInfo.name)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontColor('#333')
                      .fontWeight(FontWeight.Bold)
                      .margin({ top: 5 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')

                Divider().margin({ top: 15, bottom: 15 })

                Row() {
                  Text('类型：' + this.insuranceInfo.type)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#666')
                }
                .width('100%')

                Row() {
                  Column() {
                    Text('账户余额')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                    Text('¥' + this.insuranceInfo.balance.toFixed(2))
                      .fontSize(this.isElderMode ? 20 : 18)
                      .fontColor('#8E44AD')
                      .fontWeight(FontWeight.Bold)
                      .margin({ top: 5 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Column() {
                    Text('有效期至')
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                    Text(this.insuranceInfo.validDate)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontColor('#333')
                      .margin({ top: 5 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .margin({ top: 10 })

                Button('刷新信息')
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#8E44AD')
                  .backgroundColor('#F3E5F5')
                  .borderRadius(20)
                  .width('100%')
                  .margin({ top: 15 })
                  .onClick(() => this.refreshInfo())
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding(20)
              .shadow({ radius: 3, color: '#e0e0e0', offsetX: 0, offsetY: 2 })
              .margin({ top: 15, bottom: 20 })
            }

            // 报销记录
            Text('报销记录')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ bottom: 10 })

            ForEach(this.records, (record: ReimbursementRecord) => {
              Row() {
                Column() {
                  Row() {
                    Text(record.type)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                      .layoutWeight(1)
                    
                    Text(record.status)
                      .fontSize(12)
                      .fontColor('#fff')
                      .backgroundColor(record.status === '已报销' ? '#2ECC71' : '#F39C12')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(10)
                  }
                  .width('100%')

                  Row() {
                    Text('费用：¥' + record.amount.toFixed(2))
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                    
                    Text('报销：¥' + record.reimbursed.toFixed(2))
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#8E44AD')
                      .margin({ left: 15 })
                  }
                  .width('100%')
                  .margin({ top: 8 })

                  Text('📅 ' + record.date)
                    .fontSize(this.isElderMode ? 12 : 10)
                    .fontColor('#999')
                    .margin({ top: 5 })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding(15)
              .shadow({ radius: 2, color: '#e0e0e0', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 10 })
              .onClick(() => this.viewRecordDetail(record))
            })
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      Footer();
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
  }
}
