import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';

interface ReportItem {
  id: number;
  title: string;
  hospital: string;
  date: string;
  type: string;
  status: string;
}

@Entry
@Component
struct ReportPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State searchText: string = '';
  @State reportList: ReportItem[] = [];
  @State filteredReports: ReportItem[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadReports();
  }

  async loadReports(): Promise<void> {
    this.isLoading = true;
    
    try {
      // 模拟API调用，实际项目中应替换为真实API
      await new Promise<void>(resolve => setTimeout(resolve, 500));
      
      // 默认数据
      this.reportList = [
        { id: 1, title: '2024年度体检报告', hospital: '北京协和医院', date: '2024-12-15', type: '年度体检', status: '已完成' },
        { id: 2, title: '入职体检报告', hospital: '北京大学第一医院', date: '2024-10-20', type: '入职体检', status: '已完成' },
        { id: 3, title: '专项检查报告', hospital: '北京同仁医院', date: '2024-08-10', type: '专项检查', status: '已完成' },
        { id: 4, title: '2023年度体检报告', hospital: '北京协和医院', date: '2023-12-18', type: '年度体检', status: '已完成' },
        { id: 5, title: '婚前体检报告', hospital: '北京妇幼保健院', date: '2023-06-05', type: '婚前体检', status: '已完成' }
      ];
      
      this.filterReports();
    } catch (error) {
      console.error('[ReportPage] 加载报告数据异常:', error);
      ToastUtil.showError('加载失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  filterReports(): void {
    if (!this.searchText.trim()) {
      this.filteredReports = this.reportList;
      return;
    }
    
    const searchLower = this.searchText.toLowerCase();
    this.filteredReports = this.reportList.filter(report => 
      report.title.toLowerCase().includes(searchLower) ||
      report.hospital.toLowerCase().includes(searchLower) ||
      report.type.toLowerCase().includes(searchLower)
    );
  }

  handleReportClick(report: ReportItem): void {
    ToastUtil.showInfo('报告详情功能开发中');
    // 实际项目中应跳转到报告详情页
    // router.pushUrl({ url: 'pages/ReportDetailPage', params: { reportId: report.id } });
  }

  build() {
    Column() {
      Header({ title: '体检报告', showBack: true });

      // 搜索框
      Row() {
        Text('🔍')
          .fontSize(16)
          .margin({ left: 12 })
        TextInput({
          placeholder: '搜索报告...',
          text: this.searchText
        })
          .fontSize(this.isElderMode ? 16 : 14)
          .width('100%')
          .height(40)
          .backgroundColor('#f5f5f5')
          .borderRadius(20)
          .onChange((value: string) => {
            this.searchText = value;
            this.filterReports();
          })
      }
      .width('90%')
      .height(50)
      .backgroundColor('#f5f5f5')
      .borderRadius(25)
      .margin({ top: 15, bottom: 15 })

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#3498DB')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.filteredReports.length === 0) {
        Column() {
          Text('📋')
            .fontSize(60)
          Text('暂无体检报告')
            .fontSize(16)
            .fontColor('#999')
            .margin({ top: 10 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.filteredReports, (report: ReportItem) => {
              Row() {
                Column() {
                  Row() {
                    Text(report.title)
                      .fontSize(this.isElderMode ? 18 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333')
                      .layoutWeight(1)
                    
                    Text(report.status)
                      .fontSize(12)
                      .fontColor('#fff')
                      .backgroundColor('#2ECC71')
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(10)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  Row() {
                    Text('🏥 ' + report.hospital)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#666')
                      .layoutWeight(1)
                    
                    Text('📅 ' + report.date)
                      .fontSize(this.isElderMode ? 14 : 12)
                      .fontColor('#999')
                  }
                  .width('100%')

                  Text('类型：' + report.type)
                    .fontSize(this.isElderMode ? 14 : 12)
                    .fontColor('#666')
                    .margin({ top: 6 })
                }
                .width('100%')
                .padding(15)
                .alignItems(HorizontalAlign.Start)
              }
              .width('90%')
              .backgroundColor('#fff')
              .borderRadius(12)
              .shadow({ radius: 3, color: '#e0e0e0', offsetX: 0, offsetY: 2 })
              .margin({ bottom: 12 })
              .onClick(() => this.handleReportClick(report))
            })
          }
          .width('100%')
          .padding({ top: 10, bottom: 20 })
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
