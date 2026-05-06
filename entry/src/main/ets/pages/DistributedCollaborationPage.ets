import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface CollaborationRecord {
  id: number;
  hospital: string;
  type: string;
  date: string;
  status: string;
  description: string;
}

interface MedicalRecord {
  id: number;
  title: string;
  hospital: string;
  date: string;
  shared: boolean;
}

@Entry
@Component
struct DistributedCollaborationPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State collaborations: CollaborationRecord[] = [];
  @State medicalRecords: MedicalRecord[] = [];
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
      
      this.collaborations = [
        { id: 1, hospital: '北京协和医院', type: '病历共享', date: '2024-12-15', status: '已完成', description: '共享检查报告至北京同仁医院' },
        { id: 2, hospital: '北京大学第一医院', type: '数据同步', date: '2024-12-10', status: '已完成', description: '同步用药记录至社区医院' },
        { id: 3, hospital: '北京同仁医院', type: '转诊申请', date: '2024-12-08', status: '已完成', description: '眼科转诊申请已通过' },
        { id: 4, hospital: '北京友谊医院', type: '病历共享', date: '2024-12-05', status: '进行中', description: '共享影像资料审核中' }
      ];
      
      this.medicalRecords = [
        { id: 1, title: '2024年度体检报告', hospital: '北京协和医院', date: '2024-12-15', shared: true },
        { id: 2, title: '眼科检查报告', hospital: '北京同仁医院', date: '2024-11-20', shared: true },
        { id: 3, title: '心电图检查', hospital: '北京大学第一医院', date: '2024-10-15', shared: false },
        { id: 4, title: '血常规检查', hospital: '北京协和医院', date: '2024-09-10', shared: false }
      ];
    } catch (error) {
      console.error('[DistributedCollaborationPage] 加载数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  shareRecord(record: MedicalRecord): void {
    if (record.shared) {
      ToastUtil.showInfo('该病历已共享');
      return;
    }
    
    const index = this.medicalRecords.findIndex(r => r.id === record.id);
    if (index !== -1) {
      this.medicalRecords[index].shared = true;
      ToastUtil.showSuccess('病历共享成功');
    }
  }

  syncData(): void {
    ToastUtil.showInfo('数据同步中...');
    setTimeout(() => {
      ToastUtil.showSuccess('数据同步完成');
    }, 1500);
  }

  viewCollaborationDetail(collaboration: CollaborationRecord): void {
    ToastUtil.showInfo('详情功能开发中');
  }

  build() {
    Column() {
      Header({ title: '跨院协同', showBack: true });

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#D35400')
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
            // 数据同步按钮
            Row() {
              Column() {
                Text('🔗')
                  .fontSize(40)
                Text('数据同步')
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#333')
                  .margin({ top: 5 })
              }
              .layoutWeight(1)
              .padding(15)
              .backgroundColor('#FFF3E0')
              .borderRadius(12)
              .onClick(() => this.syncData())

              Column() {
                Text('📊')
                  .fontSize(40)
                Text('协同统计')
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontColor('#333')
                  .margin({ top: 5 })
              }
              .layoutWeight(1)
              .padding(15)
              .backgroundColor('#E3F2FD')
              .borderRadius(12)
              .margin({ left: 10 })
              .onClick(() => ToastUtil.showInfo('功能开发中'))
            }
            .width('90%')
            .margin({ top: 15, bottom: 20 })

            // 协同记录
            Text('协同记录')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ bottom: 10 })

            ForEach(this.collaborations, (collaboration: CollaborationRecord) => {
              Row() {
                Column() {
                  Row() {
                    Text(collaboration.hospital)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                      .layoutWeight(1)
                    
                    Text(collaboration.status)
                      .fontSize(12)
                      .fontColor('#fff')
                      .backgroundColor(collaboration.status === '已完成' ? '#2ECC71' : '#F39C12')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(10)
                  }
                  .width('100%')

                  Row() {
                    Text('类型：' + collaboration.type)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                    
                    Text('📅 ' + collaboration.date)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                      .margin({ left: 15 })
                  }
                  .width('100%')
                  .margin({ top: 8 })

                  Text(collaboration.description)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#999')
                    .margin({ top: 5 })
                    .width('100%')
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
              .onClick(() => this.viewCollaborationDetail(collaboration))
            })

            // 病历共享
            Text('病历共享')
              .fontSize(this.isElderMode ? 18 : 16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .width('90%')
              .margin({ top: 20, bottom: 10 })

            ForEach(this.medicalRecords, (record: MedicalRecord) => {
              Row() {
                Column() {
                  Row() {
                    Text(record.title)
                      .fontSize(this.isElderMode ? 16 : 14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                      .layoutWeight(1)
                    
                    Text(record.shared ? '已共享' : '未共享')
                      .fontSize(12)
                      .fontColor('#fff')
                      .backgroundColor(record.shared ? '#2ECC71' : '#95A5A6')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(10)
                  }
                  .width('100%')

                  Row() {
                    Text('🏥 ' + record.hospital)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                      .layoutWeight(1)
                    
                    Text('📅 ' + record.date)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                if (!record.shared) {
                  Button('共享')
                    .fontSize(this.isElderMode ? 16 : 14)
                    .fontColor('#fff')
                    .backgroundColor('#D35400')
                    .borderRadius(20)
                    .height(36)
                    .padding({ left: 20, right: 20 })
                    .onClick(() => this.shareRecord(record))
                }
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .padding(15)
              .shadow({ radius: 2, color: '#e0e0e0', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 10 })
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
