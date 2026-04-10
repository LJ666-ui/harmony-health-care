import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Card } from '../components/Card';
import { EmptyState } from '../components/EmptyState';
import { Loading } from '../components/Loading';
import { PullRefresh } from '../components/PullRefresh';
import { ClickFeedback, ButtonWithFeedback } from '../components/ClickFeedback';
import { HealthRecord } from '../models/HealthData';
import { GlobalTheme } from '../global';

@Entry
@Component
struct HealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State records: HealthRecord[] = [];
  @State filteredRecords: HealthRecord[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State selectedType: string = '全部';
  @State currentPage: number = 1;
  @State pageSize: number = 5;

  private recordTypes: string[] = ['全部', '血压', '血糖', '心率', '体温', '体重', '睡眠'];

  private defaultRecords: HealthRecord[] = [
    {
      id: '1',
      type: '血压',
      value: '120/80',
      unit: 'mmHg',
      date: '2026-04-11',
      time: '08:30',
      notes: '晨起测量，血压正常范围，继续保持低盐饮食',
      icon: '',
      color: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '2',
      type: '血压',
      value: '145/92',
      unit: 'mmHg',
      date: '2026-04-10',
      time: '18:20',
      notes: '晚餐后测量略高，建议减少钠盐摄入，明日复测',
      icon: '',
      color: '#FF4D4F',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '3',
      type: '血糖',
      value: '5.6',
      unit: 'mmol/L',
      date: '2026-04-11',
      time: '07:00',
      notes: '空腹血糖正常，餐后2小时需监测',
      icon: '',
      color: '#52C41A',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '4',
      type: '血糖',
      value: '9.8',
      unit: 'mmol/L',
      date: '2026-04-10',
      time: '12:30',
      notes: '餐后血糖偏高，注意控制碳水化合物摄入量',
      icon: '',
      color: '#FAAD14',
      createdAt: 0,
      updatedAt: 0
    },
    {
      id: '5',
      type: '心率',
      value: '72',
      unit: '次/分',
      date: '2026-04-11',
      time: '09:00',
      notes: '静息心率正常，心律齐',
      icon: '',
      color: '#1677FF',
      createdAt: 0,
      updatedAt: 0
    }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }

    this.loadRecords();
  }

  loadRecords(): void {
    const storedRecords = AppStorage.get<HealthRecord[]>('healthRecords');
    if (storedRecords && storedRecords.length > 0) {
      this.records = storedRecords;
    } else {
      this.records = [...this.defaultRecords];
    }

    this.applyFilter();
  }

  applyFilter(): void {
    if (this.selectedType === '全部') {
      this.filteredRecords = [...this.records];
    } else {
      this.filteredRecords = this.records.filter(item => item.type === this.selectedType);
    }

    this.currentPage = 1;
  }

  get paginatedRecords(): HealthRecord[] {
    const start = (this.currentPage - 1) * this.pageSize;
    const end = start + this.pageSize;
    return this.filteredRecords.slice(start, end);
  }

  get totalPages(): number {
    return Math.ceil(this.filteredRecords.length / this.pageSize);
  }

  get hasRecords(): boolean {
    return this.filteredRecords.length > 0;
  }

  handleRefresh(): void {
    this.isRefreshing = true;

    setTimeout(() => {
      this.loadRecords();
      this.isRefreshing = false;

      promptAction.showToast({
        message: '刷新成功',
        duration: 1500
      });
    }, 1500);
  }

  handleAddRecord(): void {
    const newRecord: HealthRecord = {
      id: Date.now().toString(),
      type: '体温',
      value: '36.8',
      unit: '℃',
      date: new Date().toISOString().split('T')[0],
      time: new Date().toTimeString().slice(0, 5),
      notes: '新增测试记录',
      icon: '',
      color: '#52C41A',
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    this.records.unshift(newRecord);
    AppStorage.setOrCreate<HealthRecord[]>('healthRecords', this.records);

    this.applyFilter();

    promptAction.showToast({
      message: '添加成功',
      duration: 1500
    });
  }

  handleTypeChange(type: string): void {
    this.selectedType = type;
    this.applyFilter();
  }

  handlePageChange(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
    }
  }

  build() {
    Column() {
      Header({ title: '健康记录', showBack: true });

      Scroll() {
        PullRefresh({
          onRefresh: () => this.handleRefresh(),
          isRefreshing: this.isRefreshing
        }) {
          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('健康记录')
              .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor('#1677FF')
              .margin({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingMD(this.isElderMode) });

            Scroll() {
              Row({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
                ForEach(this.recordTypes, (type: string) => {
                  Text(type)
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(this.selectedType === type ? '#FFFFFF' : '#666666')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.selectedType === type ? '#1677FF' : '#F0F0F0')
                    .borderRadius(16)
                    .onClick(() => this.handleTypeChange(type));
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .width('100%');

            if (!this.hasRecords) {
              EmptyState({
                icon: '📋',
                title: '暂无健康记录',
                description: '点击下方按钮添加您的第一条健康数据',
                buttonText: '+ 添加记录',
                onAdd: () => this.handleAddRecord()
              });
            } else {
              List({ space: 8 }) {
                ForEach(this.paginatedRecords, (item: HealthRecord) => {
                  ListItem() {
                    Column() {
                      ClickFeedback({
                        onItemClick: () => {
                          console.log('健康记录项被点击:', item.id);
                        },
                        content: () => {
                          Card({
                            title: item.type,
                            value: item.value + item.unit,
                            description: item.date + ' ' + item.time,
                            status: '正常'
                          });
                        }
                      });

                      if (item.notes) {
                        Text(item.notes)
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor('#999999')
                          .margin({ top: 4 });
                      }
                    }
                  }
                }, (item: HealthRecord) => item.id);
              }
              .width('100%')
              .height(0)
              .layoutWeight(1);

              if (this.totalPages > 1) {
                Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                  Button('上一页')
                    .enabled(this.currentPage > 1)
                    .opacity(this.currentPage > 1 ? 1 : 0.5)
                    .height(32)
                    .fontSize(12)
                    .onClick(() => this.handlePageChange(this.currentPage - 1));

                  Text(`${this.currentPage} / ${this.totalPages}`)
                    .fontSize(12)
                    .fontColor('#666666');

                  Button('下一页')
                    .enabled(this.currentPage < this.totalPages)
                    .opacity(this.currentPage < this.totalPages ? 1 : 0.5)
                    .height(32)
                    .fontSize(12)
                    .onClick(() => this.handlePageChange(this.currentPage + 1));
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .margin({ top: 8 });
              }
            }

            ButtonWithFeedback({
              text: '+ 添加记录',
              type: 'primary',
              btnSize: 'large',
              onItemClick: () => this.handleAddRecord()
            })
              .width('100%')
              .margin({ top: 8 });

            ButtonWithFeedback({
              text: '📊 健康风险评估',
              type: 'primary',
              btnSize: 'large',
              onItemClick: () => {
                router.pushUrl({ url: 'pages/RiskAssessmentPage' });
              }
            })
              .width('100%')
              .margin({ top: 8 });
          }
          .width('85%')
          .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) });
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
