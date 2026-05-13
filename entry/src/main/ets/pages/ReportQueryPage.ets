import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';
import { ToastUtil } from '../common/utils/ToastUtil';
import { HttpUtil, BaseResponse, HttpMethod } from '../common/utils/HttpUtil';
import { ApiConstants } from '../common/constants/ApiConstants';

interface ExamReportItem {
  id: number;
  reportType: string;
  reportName: string;
  examDate: string;
  departmentName: string;
  doctorName: string;
  hospitalName: string;
  pickupLocation: string;
  printStatus: number;
  resultStatus: number;
  conclusion: string;
  abnormalItems: string;
  printTime: string;
  resultTime: string;
  fee: number;
  printStatusText: string;
  resultStatusText: string;
}

interface CategoryItem {
  key: string;
  title: string;
  subtitle: string;
  icon: string;
  color: string;
  bgColor: string;
  types: string[];
}

@Entry
@Component
struct ReportQueryPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') currentUserId: number = 0;

  @State currentView: 'home' | 'list' = 'home';
  @State selectedCategoryKey: string = '';
  @State selectedCategoryTitle: string = '';
  @State reportList: ExamReportItem[] = [];
  @State allReports: ExamReportItem[] = [];
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  @State errorMessage: string = '';
  @State showDetailDialog: boolean = false;
  @State selectedReport: ExamReportItem | null = null;

  private categories: CategoryItem[] = [
    {
      key: 'imaging',
      title: '医学影像报告',
      subtitle: 'X光、CT、MRI、B超',
      icon: '🩻',
      color: '#1677FF',
      bgColor: '#E6F7FF',
      types: ['CT', 'CT检查', 'X光', 'X光片', 'DR', 'MRI', '核磁共振', 'B超', '超声']
    },
    {
      key: 'lab',
      title: '实验室检验报告',
      subtitle: '抽血、尿便、生化',
      icon: '🧪',
      color: '#722ED1',
      bgColor: '#F9F0FF',
      types: ['血常规', '血液', '尿常规', '尿液', '便常规', '生化', '化验', '肝功能', '肾功能', '血脂', '血糖']
    },
    {
      key: 'record',
      title: '病历文书',
      subtitle: '门诊病历、出院小结、诊断证明',
      icon: '📄',
      color: '#13C2C2',
      bgColor: '#E6FFFB',
      types: ['门诊病历', '出院小结', '诊断证明', '病历', '病案']
    },
    {
      key: 'special',
      title: '专项检查报告',
      subtitle: '心电图、胃肠镜、病理报告',
      icon: '❤️',
      color: '#FA541C',
      bgColor: '#FFF7E6',
      types: ['心电图', 'ECG', '胃肠镜', '胃镜', '肠镜', '病理', '脑电图', '肺功能', '骨密度']
    }
  ];

  private refreshTimer: number = -1;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
    this.loadReports();
    this.startAutoRefresh();
  }

  aboutToDisappear(): void {
    this.stopAutoRefresh();
  }

  startAutoRefresh(): void {
    this.refreshTimer = setInterval(() => {
      this.loadReports();
    }, 30000);
  }

  stopAutoRefresh(): void {
    if (this.refreshTimer !== -1) {
      clearInterval(this.refreshTimer);
      this.refreshTimer = -1;
    }
  }

  async loadReports(): Promise<void> {
    if (!this.currentUserId || this.currentUserId <= 0) return;

    this.isLoading = true;

    try {
      const params: Record<string, string> = {
        'userId': this.currentUserId.toString()
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.GET,
        ApiConstants.EXAMINATION_REPORT_LIST,
        undefined,
        params as Object,
        { showLoading: false }
      );

      if (response.success && response.data) {
        const data = response.data as Record<string, Object>;
        const rawList = data['reports'] as Object[];
        if (rawList && Array.isArray(rawList)) {
          const list: ExamReportItem[] = [];
          for (let i = 0; i < rawList.length; i++) {
            const raw = rawList[i] as Record<string, Object>;
            list.push({
              id: Number(raw['id'] || 0),
              reportType: String(raw['reportType'] || ''),
              reportName: String(raw['reportName'] || ''),
              examDate: String(raw['examDate'] || ''),
              departmentName: String(raw['departmentName'] || ''),
              doctorName: String(raw['doctorName'] || ''),
              hospitalName: String(raw['hospitalName'] || ''),
              pickupLocation: String(raw['pickupLocation'] || ''),
              printStatus: Number(raw['printStatus'] || 0),
              resultStatus: Number(raw['resultStatus'] || 0),
              conclusion: String(raw['conclusion'] || ''),
              abnormalItems: String(raw['abnormalItems'] || ''),
              printTime: raw['printTime'] ? String(raw['printTime']) : '',
              resultTime: raw['resultTime'] ? String(raw['resultTime']) : '',
              fee: Number(raw['fee'] || 0),
              printStatusText: String(raw['printStatusText'] || ''),
              resultStatusText: String(raw['resultStatusText'] || '')
            });
          }
          this.allReports = list;

          if (this.currentView === 'list' && this.selectedCategoryKey) {
            this.filterByCategory(this.selectedCategoryKey);
          } else {
            this.reportList = list;
          }
        }
        this.hasError = false;
      } else {
        this.hasError = true;
        this.errorMessage = response.message || '加载失败';
      }
    } catch (error) {
      console.error('加载报告列表失败:', error);
      this.hasError = true;
      this.errorMessage = '网络错误，请检查网络连接';
    } finally {
      this.isLoading = false;
    }
  }

  getCategoryCount(categoryKey: string): number {
    const cat = this.categories.find(c => c.key === categoryKey);
    if (!cat) return 0;
    let count = 0;
    for (let i = 0; i < this.allReports.length; i++) {
      for (let j = 0; j < cat.types.length; j++) {
        if ((this.allReports[i].reportType || '').includes(cat.types[j])) {
          count++;
          break;
        }
      }
    }
    return count;
  }

  filterByCategory(categoryKey: string): void {
    const cat = this.categories.find(c => c.key === categoryKey);
    if (!cat) return;

    const filtered: ExamReportItem[] = [];
    for (let i = 0; i < this.allReports.length; i++) {
      for (let j = 0; j < cat.types.length; j++) {
        if ((this.allReports[i].reportType || '').includes(cat.types[j])) {
          filtered.push(this.allReports[i]);
          break;
        }
      }
    }
    this.reportList = filtered;
  }

  enterCategory(category: CategoryItem): void {
    this.selectedCategoryKey = category.key;
    this.selectedCategoryTitle = category.title;
    this.filterByCategory(category.key);
    this.currentView = 'list';
  }

  goBackToList(): void {
    this.currentView = 'home';
    this.selectedCategoryKey = '';
    this.selectedCategoryTitle = '';
    this.reportList = [];
  }

  async initDemoData(): Promise<void> {
    try {
      const params: Record<string, string> = {
        'userId': this.currentUserId.toString()
      };

      const response: BaseResponse<Object> = await HttpUtil.request<Object>(
        HttpMethod.POST,
        ApiConstants.EXAMINATION_REPORT_INIT_DEMO,
        undefined,
        params as Object,
        { showLoading: true, loadingText: '初始化演示数据...' }
      );

      if (response.success) {
        ToastUtil.showSuccess('✅ 演示数据已生成', 2000);
        this.loadReports();
      } else {
        ToastUtil.showError(response.message || '初始化失败', 2000);
      }
    } catch (error) {
      ToastUtil.showError('网络异常', 1500);
    }
  }

  getReportIcon(type: string): string {
    const t = (type || '').toLowerCase();
    if (t.includes('ct')) return '🩻';
    if (t.includes('x光') || t.includes('x-ray') || t.includes('dr')) return '📷';
    if (t.includes('mri') || t.includes('核磁')) return '🧲';
    if (t.includes('血常规') || t.includes('血液')) return '🩸';
    if (t.includes('尿常规') || t.includes('尿液')) return '💧';
    if (t.includes('心电') || t.includes('ecg')) return '❤️';
    if (t.includes('b超') || t.includes('超声')) return '📊';
    if (t.includes('生化') || t.includes('化验')) return '🧪';
    if (t.includes('病历') || t.includes('病案')) return '📄';
    if (t.includes('病理')) return '🔬';
    if (t.includes('胃肠镜') || t.includes('胃镜') || t.includes('肠镜')) return '🏥';
    return '📋';
  }

  getPrintStatusColor(status: number): string {
    switch (status) {
      case 0: return '#999999';
      case 1: return '#FAAD14';
      case 2: return '#52C41A';
      default: return '#999999';
    }
  }

  getPrintStatusBgColor(status: number): string {
    switch (status) {
      case 0: return '#F5F5F5';
      case 1: return '#FFFBE6';
      case 2: return '#F6FFED';
      default: return '#F5F5F5';
    }
  }

  getResultStatusColor(status: number): string {
    return status === 1 ? '#1677FF' : '#999999';
  }

  isToday(dateStr: string): boolean {
    if (!dateStr) return false;
    const today = new Date();
    const d = new Date(dateStr.replace(/-/g, '/'));
    return d.getFullYear() === today.getFullYear() &&
           d.getMonth() === today.getMonth() &&
           d.getDate() === today.getDate();
  }

  handleReportClick(item: ExamReportItem): void {
    this.selectedReport = item;
    this.showDetailDialog = true;
  }

  closeDetail(): void {
    this.showDetailDialog = false;
    this.selectedReport = null;
  }

  @Builder
  CategoryCard(item: CategoryItem) {
    Row() {
      Column() {
        Text(item.icon)
          .fontSize(32)
          .margin({ bottom: 8 })
        Text(item.title)
          .fontSize(this.isElderMode ? 17 : 15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        Text(item.subtitle)
          .fontSize(this.isElderMode ? 12 : 10)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text(this.getCategoryCount(item.key).toString())
          .fontSize(this.isElderMode ? 24 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor(item.color)
        Text('份报告')
          .fontSize(this.isElderMode ? 11 : 9)
          .fontColor('#CCCCCC')

        Text('查看 >')
          .fontSize(this.isElderMode ? 14 : 12)
          .fontColor(item.color)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .backgroundColor(item.bgColor)
          .borderRadius(12)
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding({ left: 18, right: 16, top: 20, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .border({ width: item.color === '#1677FF' ? 2 : 1, color: item.color + (item.color === '#1677FF' ? '40' : '20'), radius: 14 })
    .shadow({ radius: item.color === '#1677FF' ? 8 : 4, color: item.color + '15', offsetX: 0, offsetY: 2 })
    .onClick(() => this.enterCategory(item))
  }

  @Builder
  ReportCard(item: ExamReportItem) {
    Column() {
      Row() {
        Text(this.getReportIcon(item.reportType))
          .fontSize(this.isElderMode ? 28 : 24)

        Column({ space: 4 }) {
          Row({ space: 6 }) {
            Text(item.reportName || item.reportType)
              .fontSize(this.isElderMode ? 18 : 15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            if (this.isToday(item.examDate)) {
              Text('今日')
                .fontSize(10)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF4D4F')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(8)
            }
          }
          .alignItems(VerticalAlign.Bottom)

          Row({ space: 8 }) {
            Text(item.departmentName || '')
              .fontSize(this.isElderMode ? 13 : 11)
              .fontColor('#999999')
            if (item.doctorName) {
              Text('· ' + item.doctorName)
                .fontSize(this.isElderMode ? 13 : 11)
                .fontColor('#999999')
            }
          }

          Text(item.hospitalName || '')
            .fontSize(this.isElderMode ? 12 : 10)
            .fontColor('#CCCCCC')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })

        Column({ space: 4 }) {
          Text(item.printStatusText)
            .fontSize(this.isElderMode ? 13 : 11)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getPrintStatusColor(item.printStatus))
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(this.getPrintStatusBgColor(item.printStatus))
            .borderRadius(10)

          if (item.printStatus === 2) {
            Text('可取片')
              .fontSize(this.isElderMode ? 12 : 10)
              .fontColor('#52C41A')
              .fontWeight(FontWeight.Bold)
          }
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Divider().color('#F0F0F0').strokeWidth(1).margin({ top: 12, bottom: 10 })

      Row() {
        Column() {
          Text('检查日期')
            .fontSize(this.isElderMode ? 12 : 10)
            .fontColor('#999999')
          Text((item.examDate || '--').substring(0, 10))
            .fontSize(this.isElderMode ? 16 : 13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('打印状态')
            .fontSize(this.isElderMode ? 12 : 10)
            .fontColor('#999999')
          Text(item.printStatusText)
            .fontSize(this.isElderMode ? 16 : 13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getPrintStatusColor(item.printStatus))
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('结果状态')
            .fontSize(this.isElderMode ? 12 : 10)
            .fontColor('#999999')
          Text(item.resultStatusText)
            .fontSize(this.isElderMode ? 16 : 13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.getResultStatusColor(item.resultStatus))
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      if (item.pickupLocation) {
        Row() {
          Text('📍 取片位置')
            .fontSize(this.isElderMode ? 13 : 11)
            .fontColor('#666666')
          Blank()
          Text(item.pickupLocation)
            .fontSize(this.isElderMode ? 14 : 12)
            .fontColor(GlobalTheme.THEME_COLOR)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .margin({ top: 8 })
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .backgroundColor(GlobalTheme.THEME_COLOR + '08')
        .borderRadius(8)
      }

      if (item.abnormalItems && item.resultStatus === 1) {
        Row() {
          Text('⚠️ 异常项')
            .fontSize(this.isElderMode ? 13 : 11)
            .fontColor('#FF4D4F')
          Blank()
          Text(item.abnormalItems)
            .fontSize(this.isElderMode ? 13 : 11)
            .fontColor('#FF4D4F')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .margin({ top: 6 })
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#FFF2F0')
        .borderRadius(6)
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: item.printStatus === 2 ? '#52C41A40' : '#F0F0F0' })
    .onClick(() => this.handleReportClick(item))
  }

  @Builder
  DetailDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .onClick(() => this.closeDetail());

      if (this.selectedReport) {
        Column({ space: 14 }) {
          Row() {
            Text('报告详情')
              .fontSize(this.isElderMode ? 20 : 17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Blank()
            Text('✕')
              .fontSize(20)
              .fontColor('#999999')
              .onClick(() => this.closeDetail())
          }
          .width('100%')

          Row() {
            Text(this.getReportIcon(this.selectedReport.reportType))
              .fontSize(28)
            Column({ space: 4 }) {
              Text(this.selectedReport.reportName || this.selectedReport.reportType)
                .fontSize(this.isElderMode ? 18 : 15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              Text(this.selectedReport.departmentName + ' · ' +
                   (this.selectedReport.doctorName || '未知医生'))
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#999999')
            }
            .layoutWeight(1)
            .margin({ left: 10 })
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Divider().strokeWidth(1).color('#F0F0F0')

          Column({ space: 10 }) {
            Row() {
              Text('🏥 医院')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#999999')
              Blank()
              Text(this.selectedReport.hospitalName || '-')
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#333333')
            }
            .width('100%')

            Row() {
              Text('📅 检查日期')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#999999')
              Blank()
              Text((this.selectedReport.examDate || '-').substring(0, 10))
                .fontSize(this.isElderMode ? 15 : 13)
                .fontColor('#333333')
            }
            .width('100%')

            Row() {
              Text('🖨️ 打印状态')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#999999')
              Blank()
              Text(this.selectedReport.printStatusText)
                .fontSize(this.isElderMode ? 15 : 13)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getPrintStatusColor(this.selectedReport.printStatus))
            }
            .width('100%')

            if (this.selectedReport.printTime) {
              Row() {
                Text('   打印时间')
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#CCCCCC')
                Blank()
                Text(this.selectedReport.printTime.substring(11))
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
            }

            Row() {
              Text('📋 结果状态')
                .fontSize(this.isElderMode ? 14 : 12)
                .fontColor('#999999')
              Blank()
              Text(this.selectedReport.resultStatusText)
                .fontSize(this.isElderMode ? 15 : 13)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.getResultStatusColor(this.selectedReport.resultStatus))
            }
            .width('100%')

            if (this.selectedReport.pickupLocation) {
              Column({ space: 6 }) {
                Text('📍 取片位置 / 窗口')
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#999999')
                  .alignSelf(ItemAlign.Start)
                Text(this.selectedReport.pickupLocation)
                  .fontSize(this.isElderMode ? 17 : 15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(GlobalTheme.THEME_COLOR)
                  .alignSelf(ItemAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(GlobalTheme.THEME_COLOR + '08')
              .borderRadius(10)
            }

            if (this.selectedReport.conclusion && this.selectedReport.resultStatus === 1) {
              Column({ space: 6 }) {
                Text('📝 检查结论')
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#999999')
                  .alignSelf(ItemAlign.Start)
                Text(this.selectedReport.conclusion)
                  .fontSize(this.isElderMode ? 15 : 13)
                  .fontColor('#333333')
                  .alignSelf(ItemAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F9F9F9')
              .borderRadius(10)
            }

            if (this.selectedReport.fee > 0) {
              Row() {
                Text('💰 检查费用')
                  .fontSize(this.isElderMode ? 14 : 12)
                  .fontColor('#999999')
                Blank()
                Text('¥' + this.selectedReport.fee.toFixed(2))
                  .fontSize(this.isElderMode ? 16 : 14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF4D4F')
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FAFAFA')
          .borderRadius(10)

          if (this.selectedReport.printStatus === 2) {
            Button('导航到取片处 🧭')
              .width('100%')
              .height(44)
              .fontSize(this.isElderMode ? 17 : 15)
              .fontColor('#FFFFFF')
              .backgroundColor('#52C41A')
              .borderRadius(22)
              .onClick(() => {
                ToastUtil.showSuccess('正在打开院内导航...', 1500);
              })
          }
        }
        .width('85%')
        .constraintSize({ maxHeight: '80%' })
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
      }
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  HomeView() {
    Scroll() {
      Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {

        Row() {
          Text('我的报告')
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.THEME_COLOR)

          Blank()

          Text('🔄 刷新')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontColor(GlobalTheme.THEME_COLOR)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor(GlobalTheme.THEME_COLOR + '15')
            .borderRadius(16)
            .onClick(() => {
              this.loadReports();
              ToastUtil.showInfo('已刷新');
            })
        }
        .width('85%')
        .margin({ top: GlobalTheme.getSpacingMD(this.isElderMode) })

        Text('选择报告分类，查看对应的检查结果和取片信息')
          .fontSize(this.isElderMode ? 13 : 11)
          .fontColor('#999999')
          .width('85%')

        ForEach(this.categories, (category: CategoryItem) => {
          this.CategoryCard(category);
        }, (cat: CategoryItem) => cat.key)

        Row() {
          Column() {
            Text('📋').fontSize(40).margin({ bottom: 8 });
            Text('共 ' + this.allReports.length + ' 份报告')
              .fontSize(this.isElderMode ? 15 : 13)
              .fontColor('#666666');
          }.layoutWeight(1).alignItems(HorizontalAlign.Center);

          Button('加载演示数据')
            .type(ButtonType.Normal)
            .borderRadius(20)
            .backgroundColor('#722ED1')
            .fontColor('#FFFFFF')
            .fontSize(this.isElderMode ? 15 : 13)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => this.initDemoData());
        }
        .width('85%')
        .padding(16)
        .backgroundColor('#FAFAFA')
        .borderRadius(12)
        .margin({ top: 8 })
      }
      .width('100%')
      .padding({ bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
    }
    .scrollBar(BarState.Off)
    .height(0)
    .layoutWeight(1);
  }

  @Builder
  ListView() {
    Column() {
      Row() {
        Text('< 返回分类')
          .fontSize(this.isElderMode ? 16 : 14)
          .fontColor(GlobalTheme.THEME_COLOR)
          .fontWeight(FontWeight.Medium)
          .onClick(() => this.goBackToList())

        Blank()

        Text(this.selectedCategoryTitle)
          .fontSize(this.isElderMode ? 17 : 15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()

        Text('🔄')
          .fontSize(this.isElderMode ? 18 : 16)
          .fontColor(GlobalTheme.THEME_COLOR)
          .onClick(() => {
            this.loadReports();
            ToastUtil.showInfo('已刷新');
          })
      }
      .width('85%')
      .padding({ top: 12, bottom: 8 })

      Text('共 ' + this.reportList.length + ' 份报告 | 点击卡片查看详情和取片位置')
        .fontSize(this.isElderMode ? 12 : 10)
        .fontColor('#999999')
        .width('85%')

      Scroll() {
        Column({ space: 12 }) {
          if (this.isLoading && this.reportList.length === 0) {
            Column() {
              LoadingProgress().width(50).height(50).color(GlobalTheme.THEME_COLOR);
              Text('加载中...')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY)
                .margin({ top: 10 });
            }.width('100%').height(250).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
          } else if (this.reportList.length === 0) {
            Column() {
              Text('📂').fontSize(48).margin({ bottom: 12 });
              Text('该分类暂无报告')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_SECONDARY);
              Text('就诊后的报告将在此显示')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT)
                .margin({ top: 6 });
            }.width('100%').height(300).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center);
          } else {
            ForEach(this.reportList, (item: ExamReportItem) => {
              this.ReportCard(item);
            }, (item: ExamReportItem) => '' + item.id);
          }
        }
        .width('85%')
        .padding({ top: 12, bottom: 120 });
      }
      .scrollBar(BarState.Off)
      .height(0)
      .layoutWeight(1);
    }
    .width('100%')
    .layoutWeight(1);
  }

  build() {
    Stack() {
      Column() {
        Header({
          title: this.currentView === 'list' ? this.selectedCategoryTitle : '我的报告',
          showBack: false
        });

        if (this.currentView === 'home') {
          this.HomeView();
        } else {
          this.ListView();
        }

        Footer({ activeIndex: 1 });
      }
      .width('100%')
      .height('100%')
      .backgroundColor(GlobalTheme.BG_COLOR);

      if (this.showDetailDialog && this.selectedReport) {
        this.DetailDialog();
      }
    }
    .width('100%')
    .height('100%')
  }
}
