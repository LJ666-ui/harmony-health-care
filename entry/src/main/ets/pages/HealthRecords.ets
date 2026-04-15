import { router } from '@kit.ArkUI';
import { HealthRecord } from '../models/HealthData';

interface Stats {
  recordDays: number;
  recentRecord: string;
  abnormalCount: number;
}

@Entry
@Component
struct HealthRecords {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State selectedTab: string = '全部';
  @State selectedTimeRange: string = '一周';
  @State sortOrder: string = '倒序';
  @State records: HealthRecord[] = this.generateMockData();
  @State filteredRecords: HealthRecord[] = [];
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State hasMore: boolean = true;
  @State loading: boolean = false;

  private tabs: string[] = ['全部', '血压', '血糖', '心率', '体重', '其他'];
  private timeRanges: string[] = ['一周', '一月', '三月'];
  private sortOrders: string[] = ['正序', '倒序'];

  aboutToAppear() {
    this.loadInitialData();
  }

  loadInitialData() {
    this.currentPage = 1;
    this.hasMore = true;
    this.filterAndSortRecords();
  }

  generateMockData(): HealthRecord[] {
    return [
      {
        id: '1',
        type: '血压',
        value: '120/80',
        unit: 'mmHg',
        date: '2026-04-15',
        time: '09:30',
        notes: '正常范围',
        icon: '📊',
        color: '#1677FF',
        createdAt: Date.now() - 3600000,
        updatedAt: Date.now() - 3600000
      },
      {
        id: '2',
        type: '血糖',
        value: '5.6',
        unit: 'mmol/L',
        date: '2026-04-15',
        time: '08:00',
        notes: '空腹血糖',
        icon: '🍬',
        color: '#FF7F50',
        createdAt: Date.now() - 7200000,
        updatedAt: Date.now() - 7200000
      },
      {
        id: '3',
        type: '心率',
        value: '75',
        unit: 'bpm',
        date: '2026-04-14',
        time: '18:00',
        notes: '静息心率',
        icon: '❤️',
        color: '#FF4444',
        createdAt: Date.now() - 86400000,
        updatedAt: Date.now() - 86400000
      },
      {
        id: '4',
        type: '体重',
        value: '65',
        unit: 'kg',
        date: '2026-04-14',
        time: '07:00',
        notes: '早晨体重',
        icon: '⚖️',
        color: '#9370DB',
        createdAt: Date.now() - 90000000,
        updatedAt: Date.now() - 90000000
      },
      {
        id: '5',
        type: '血压',
        value: '140/90',
        unit: 'mmHg',
        date: '2026-04-13',
        time: '10:00',
        notes: '偏高',
        icon: '📊',
        color: '#FF4444',
        createdAt: Date.now() - 172800000,
        updatedAt: Date.now() - 172800000
      }
    ];
  }

  filterAndSortRecords() {
    let filtered = [...this.records];

    if (this.selectedTab !== '全部') {
      filtered = filtered.filter(record => record.type === this.selectedTab);
    }

    const now = Date.now();
    let timeLimit = 0;
    switch (this.selectedTimeRange) {
      case '一周':
        timeLimit = now - 7 * 24 * 60 * 60 * 1000;
        break;
      case '一月':
        timeLimit = now - 30 * 24 * 60 * 60 * 1000;
        break;
      case '三月':
        timeLimit = now - 90 * 24 * 60 * 60 * 1000;
        break;
    }
    filtered = filtered.filter(record => record.createdAt >= timeLimit);

    if (this.sortOrder === '正序') {
      filtered.sort((a, b) => a.createdAt - b.createdAt);
    } else {
      filtered.sort((a, b) => b.createdAt - a.createdAt);
    }

    if (this.currentPage === 1) {
      this.filteredRecords = filtered.slice(0, this.pageSize);
    } else {
      this.filteredRecords = [...this.filteredRecords, ...filtered.slice(this.currentPage * this.pageSize, (this.currentPage + 1) * this.pageSize)];
    }
    this.hasMore = this.filteredRecords.length < filtered.length;
  }

  loadMore() {
    if (!this.loading && this.hasMore) {
      this.loading = true;
      setTimeout(() => {
        this.currentPage++;
        this.filterAndSortRecords();
        this.loading = false;
      }, 1000);
    }
  }

  getStatusIcon(value: string, type: string): string {
    if (type === '血压') {
      const parts = value.split('/');
      const systolic = Number(parts[0]);
      const diastolic = Number(parts[1]);
      if (systolic >= 140 || diastolic >= 90) return '⚠️';
      if (systolic < 90 || diastolic < 60) return '⚠️';
      return '✅';
    } else if (type === '血糖') {
      const val = Number(value);
      if (val >= 7.0) return '⚠️';
      if (val < 3.9) return '⚠️';
      return '✅';
    } else if (type === '心率') {
      const val = Number(value);
      if (val >= 100 || val < 60) return '⚠️';
      return '✅';
    }
    return '✅';
  }

  getStatusColor(value: string, type: string): string {
    if (type === '血压') {
      const parts = value.split('/');
      const systolic = Number(parts[0]);
      const diastolic = Number(parts[1]);
      if (systolic >= 140 || diastolic >= 90) return '#FF4444';
      if (systolic < 90 || diastolic < 60) return '#FF4444';
      return '#52C41A';
    } else if (type === '血糖') {
      const val = Number(value);
      if (val >= 7.0) return '#FF4444';
      if (val < 3.9) return '#FF4444';
      return '#52C41A';
    } else if (type === '心率') {
      const val = Number(value);
      if (val >= 100 || val < 60) return '#FF4444';
      return '#52C41A';
    }
    return '#52C41A';
  }

  getStats(): Stats {
    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();
    
    const monthlyRecords = this.records.filter(record => {
      const recordDate = new Date(record.date);
      return recordDate.getMonth() === currentMonth && recordDate.getFullYear() === currentYear;
    });

    const recordDays = new Set(monthlyRecords.map(record => record.date)).size;
    const recentRecord = this.records.sort((a, b) => b.createdAt - a.createdAt)[0];
    const abnormalCount = monthlyRecords.filter(record => {
      const statusIcon = this.getStatusIcon(record.value, record.type);
      return statusIcon === '⚠️';
    }).length;

    return {
      recordDays,
      recentRecord: recentRecord ? `${recentRecord.date} ${recentRecord.time}` : '暂无记录',
      abnormalCount
    };
  }

  deleteRecord(id: string) {
    this.records = this.records.filter(record => record.id !== id);
    this.filterAndSortRecords();
  }

  @State stats: Stats = this.getStats();

  build() {
    Column() {
      Text('← 返回')
        .fontSize(16)
        .fontColor('#1677FF')
        .padding(12)
        .width('100%')
        .onClick(() => {
          router.back();
        });

      Scroll() {
        Column({ space: 16 }) {
          Text('健康记录')
            .fontSize(24)
            .fontWeight('bold')
            .fontColor('#1677FF')
            .margin({ top: 16, bottom: 12 });

          Row() {
            Column() {
              Text(this.stats.recordDays.toString())
                .fontSize(20)
                .fontWeight('bold')
                .fontColor('#1677FF');
              Text('本月记录天数')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 });
            }
            .width('33%')
            .alignItems(HorizontalAlign.Center);

            Column() {
              Text(this.stats.recentRecord)
                .fontSize(12)
                .fontWeight('bold')
                .fontColor('#1677FF')
                .textAlign(TextAlign.Center);
              Text('最近记录时间')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 });
            }
            .width('33%')
            .alignItems(HorizontalAlign.Center);

            Column() {
              Text(this.stats.abnormalCount.toString())
                .fontSize(20)
                .fontWeight('bold')
                .fontColor('#FF4444');
              Text('异常次数')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 });
            }
            .width('33%')
            .alignItems(HorizontalAlign.Center);
          }
          .width('85%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          Row() {
            Scroll() {
              Row() {
                ForEach(this.tabs, (tab: string) => {
                  Text(tab)
                    .fontSize(14)
                    .fontColor(this.selectedTab === tab ? '#FFFFFF' : '#666666')
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.selectedTab === tab ? '#1677FF' : '#F0F0F0')
                    .borderRadius(16)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.selectedTab = tab;
                      this.loadInitialData();
                    });
                });
              }
            }
          }
          .width('85%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          Row() {
            Row() {
              ForEach(this.timeRanges, (range: string) => {
                Text(range)
                  .fontSize(12)
                  .fontColor(this.selectedTimeRange === range ? '#FFFFFF' : '#666666')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.selectedTimeRange === range ? '#52C41A' : '#F5F5F5')
                  .borderRadius(14)
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.selectedTimeRange = range;
                    this.loadInitialData();
                  });
              });
            }

            Row() {
              ForEach(this.sortOrders, (order: string) => {
                Text(order)
                  .fontSize(12)
                  .fontColor(this.sortOrder === order ? '#FFFFFF' : '#666666')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.sortOrder === order ? '#9370DB' : '#F5F5F5')
                  .borderRadius(14)
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.sortOrder = order;
                    this.loadInitialData();
                  });
              });
            }
          }
          .width('85%')
          .justifyContent(FlexAlign.SpaceBetween)

          Column() {
            Text('📈 趋势图表')
              .fontSize(16)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 16 });

            Row() {
              Text('近7天')
                .fontSize(12)
                .fontColor('#1677FF')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .backgroundColor('#E6F7FF')
                .borderRadius(14)
                .margin({ right: 8 });
              Text('近30天')
                .fontSize(12)
                .fontColor('#666666')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .backgroundColor('#F5F5F5')
                .borderRadius(14);
            }
            .margin({ bottom: 16 });

            Column() {
              // 模拟折线图
              Text('📊 血压趋势图')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 16 })
                .textAlign(TextAlign.Center);
              Row() {
                ForEach(['04-09', '04-10', '04-11', '04-12', '04-13', '04-14', '04-15'], (date: string) => {
                  Column() {
                    Text('⬆')
                      .fontSize(24)
                      .fontColor('#1677FF')
                      .margin({ bottom: 8 });
                    Text(date)
                      .fontSize(10)
                      .fontColor('#999999');
                  }
                  .margin({ right: 20 });
                });
              }
              .margin({ bottom: 16 });
              Row() {
                Row() {
                  Text('✅')
                    .fontSize(14)
                    .margin({ right: 4 });
                  Text('正常范围')
                    .fontSize(12)
                    .fontColor('#52C41A');
                }
                .margin({ right: 16 });
                Row() {
                  Text('⚠️')
                    .fontSize(14)
                    .margin({ right: 4 });
                  Text('异常数据')
                    .fontSize(12)
                    .fontColor('#FF4444');
                };
              }
            }
            .width('100%')
            .height(200);
          }
          .width('85%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          if (this.filteredRecords.length === 0) {
            Column() {
              Text('📝')
                .fontSize(48)
                .margin({ bottom: 12 });
              Text('暂无记录，快去添加第一条吧')
                .fontSize(14)
                .fontColor('#999999');
            }
            .width('85%')
            .height(200)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center);
          } else {
            Column() {
              ForEach(this.filteredRecords, (record: HealthRecord) => {
                Column() {
                  Row() {
                    Text(record.icon)
                      .fontSize(20)
                      .margin({ right: 12 });
                    Column() {
                      Row() {
                        Text(record.type)
                          .fontSize(15)
                          .fontWeight('bold')
                          .fontColor('#333333');
                        Blank();
                        Text(`${record.value} ${record.unit}`)
                          .fontSize(14)
                          .fontWeight('bold')
                          .fontColor(record.color);
                      }
                      Row() {
                        Text(`${record.date} ${record.time}`)
                          .fontSize(12)
                          .fontColor('#999999');
                        Blank();
                        Text(this.getStatusIcon(record.value, record.type))
                          .fontSize(14);
                      }
                      .margin({ top: 4 });
                    }
                    .layoutWeight(1);
                  }
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(10)
                .margin({ top: 8 })
                .onClick(() => {
                  router.push({
                    url: 'pages/HealthRecordDetail',
                    params: { record: record }
                  });
                });
              });

              if (this.loading) {
                Row() {
                  Text('加载中...')
                    .fontSize(12)
                    .fontColor('#999999');
                }
                .width('100%')
                .height(40)
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center);
              } else if (!this.hasMore) {
                Row() {
                  Text('已加载全部数据')
                    .fontSize(12)
                    .fontColor('#999999');
                }
                .width('100%')
                .height(40)
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center);
              }
            }
            .width('85%');
          }
        }
        .width('100%')
        .padding({ bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off);

      Button('+ 添加记录')
        .width(64)
        .height(64)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(32)
        .position({ x: '80%', y: '75%' })
        .onClick(() => {
          router.push({
            url: 'pages/AddHealthRecord'
          });
        });

      Row() {
            Text('🏠').fontSize(20).margin(8).onClick(() => router.push({ url: 'pages/HomePage' }));
            Text('📋').fontSize(20).margin(8).fontColor('#1677FF');
            Text('💊').fontSize(20).margin(8).onClick(() => router.push({ url: 'pages/Medications' }));
            Text('📚').fontSize(20).margin(8).onClick(() => router.push({ url: 'pages/SciencePage' }));
            Text('👤').fontSize(20).margin(8).onClick(() => router.push({ url: 'pages/Profile' }));
          }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .padding(8)
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: -2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
