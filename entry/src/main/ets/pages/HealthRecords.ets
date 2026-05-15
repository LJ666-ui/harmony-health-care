import { router } from '@kit.ArkUI';
import { HealthRecord } from '../models/HealthData';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';

interface Stats {
  recordDays: number;
  recentRecord: string;
  abnormalCount: number;
}

interface ChartData {
  sys: number[];
  dia: number[];
  dates: string[];
}

interface SimpleChartData {
  values: number[];
  dates: string[];
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
  @State aiSummary: string = '';
  @State abnormalItems: string[] = [];
  @State chartDates: string[] = [];
  @State bpSysData: number[] = [];
  @State bpDiaData: number[] = [];
  @State glucoseValues: number[] = [];
  @State bpMaxValue: number = 150;
  @State bpMinValue: number = 60;
  // 修复：移除错误的直接赋值，统一在aboutToAppear初始化
  @State stats: Stats = { recordDays: 0, recentRecord: '暂无记录', abnormalCount: 0 };

  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();
  private tabs: string[] = ['全部', '血压', '血糖', '心率', '体重', '其他'];
  private timeRanges: string[] = ['一周', '一月', '三月'];
  private sortOrders: string[] = ['正序', '倒序'];

  aboutToAppear() {
    this.loadInitialData();
    // 修复：初始化统计数据
    this.stats = this.getStats();
  }

  loadInitialData() {
    this.currentPage = 1;
    this.hasMore = true;
    this.filterAndSortRecords();
    this.initChartData();
  }

  initChartData() {
    this.chartDates = this.getChartDates();
    const bpData = this.getBloodPressureData();
    this.bpSysData = bpData.sys;
    this.bpDiaData = bpData.dia;
    if (this.bpSysData.length > 0) {
      this.bpMaxValue = this.getMaxValue(this.bpSysData);
      this.bpMinValue = this.getMinValue(this.bpDiaData);
    }
    const glucoseData = this.getGlucoseData();
    this.glucoseValues = glucoseData.values;
  }

  generateMockData(): HealthRecord[] {
    const data: HealthRecord[] = [];
    const now = new Date('2026-05-14');

    for (let i = 0; i < 14; i++) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      const dateStr = this.formatDate(date);

      data.push({
        id: 'bp_' + i,
        type: '血压',
        value: (115 + Math.floor(Math.random() * 25)) + '/' + (72 + Math.floor(Math.random() * 18)),
        unit: 'mmHg',
        date: dateStr,
        time: '09:' + String(30 - Math.floor(Math.random() * 30)).padStart(2, '0'),
        notes: '',
        icon: '📊',
        color: '#1677FF',
        createdAt: date.getTime(),
        updatedAt: date.getTime()
      });

      if (i % 2 === 0) {
        data.push({
          id: 'glucose_' + i,
          type: '血糖',
          value: (4.5 + Math.random() * 1.8).toFixed(1),
          unit: 'mmol/L',
          date: dateStr,
          time: '08:00',
          notes: i % 4 === 0 ? '空腹' : '餐后2h',
          icon: '🍬',
          color: '#FF7F50',
          createdAt: date.getTime() - 3600000,
          updatedAt: date.getTime() - 3600000
        });
      }

      if (i % 3 === 0) {
        data.push({
          id: 'hr_' + i,
          type: '心率',
          value: '' + (68 + Math.floor(Math.random() * 20)),
          unit: 'bpm',
          date: dateStr,
          time: '18:00',
          notes: '静息心率',
          icon: '❤️',
          color: '#FF4444',
          createdAt: date.getTime() - 7200000,
          updatedAt: date.getTime() - 7200000
        });
      }

      if (i % 5 === 0) {
        data.push({
          id: 'weight_' + i,
          type: '体重',
          value: (63 + Math.random() * 3).toFixed(1),
          unit: 'kg',
          date: dateStr,
          time: '07:00',
          notes: '早晨体重',
          icon: '⚖️',
          color: '#9370DB',
          createdAt: date.getTime() - 10800000,
          updatedAt: date.getTime() - 10800000
        });
      }
    }
    return data;
  }

  formatDate(date: Date): string {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  filterAndSortRecords() {
    let filtered = [...this.records];

    // 修复：简化筛选逻辑，移除冗余for循环
    if (this.selectedTab !== '全部') {
      filtered = filtered.filter(item => item.type === this.selectedTab);
    }

    // 时间筛选
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
    filtered = filtered.filter(item => item.createdAt >= timeLimit);

    // 排序
    filtered.sort((a, b) => this.sortOrder === '正序' ? a.createdAt - b.createdAt : b.createdAt - a.createdAt);

    // 分页
    if (this.currentPage === 1) {
      this.filteredRecords = filtered.slice(0, this.pageSize);
    } else {
      const newItems = filtered.slice(this.currentPage * this.pageSize, (this.currentPage + 1) * this.pageSize);
      this.filteredRecords = [...this.filteredRecords, ...newItems];
    }
    this.hasMore = this.filteredRecords.length < filtered.length;
  }

  getChartDates(): string[] {
    const dates: string[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      dates.push(this.formatShortDate(date));
    }
    return dates;
  }

  formatShortDate(date: Date): string {
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${m}-${d}`;
  }

  getBloodPressureData(): ChartData {
    const bpRecords = this.records.filter(r => r.type === '血压').sort((a, b) => a.createdAt - b.createdAt);
    const dates = this.getChartDates();
    const sys: number[] = [];
    const dia: number[] = [];

    for (let i = 0; i < 7; i++) {
      const dayRecord = bpRecords.find(r => r.date.includes(dates[i]));
      if (dayRecord) {
        const parts = dayRecord.value.split('/');
        sys.push(parseInt(parts[0]) || 120);
        dia.push(parseInt(parts[1]) || 80);
      } else if (i > 0) {
        sys.push(sys[sys.length - 1] || 120);
        dia.push(dia[dia.length - 1] || 80);
      } else {
        sys.push(120);
        dia.push(80);
      }
    }
    return { sys, dia, dates };
  }

  getGlucoseData(): SimpleChartData {
    const glucoseRecords = this.records.filter(r => r.type === '血糖').sort((a, b) => a.createdAt - b.createdAt);
    const dates = this.getChartDates();
    const values: number[] = [];

    for (let i = 0; i < 7; i++) {
      const dayRecord = glucoseRecords.find(r => r.date.includes(dates[i]));
      if (dayRecord) {
        values.push(parseFloat(dayRecord.value) || 5.5);
      } else if (i > 0) {
        values.push(values[values.length - 1] || 5.5);
      } else {
        values.push(5.5);
      }
    }
    return { values, dates };
  }

  getHeartRateData(): SimpleChartData {
    const hrRecords = this.records.filter(r => r.type === '心率').sort((a, b) => a.createdAt - b.createdAt);
    const dates = this.getChartDates();
    const values: number[] = [];

    for (let i = 0; i < 7; i++) {
      const dayRecord = hrRecords.find(r => r.date.includes(dates[i]));
      if (dayRecord) {
        values.push(parseInt(dayRecord.value) || 75);
      } else if (i > 0) {
        values.push(values[values.length - 1] || 75);
      } else {
        values.push(75);
      }
    }
    return { values, dates };
  }

  getMaxValue(arr: number[]): number {
    let max = arr[0] || 100;
    arr.forEach(item => { if (item > max) max = item; });
    return Math.ceil(max * 1.1 / 10) * 10;
  }

  getMinValue(arr: number[]): number {
    let min = arr[0] || 60;
    arr.forEach(item => { if (item < min) min = item; });
    return Math.floor(min * 0.9 / 10) * 10;
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
      const parts = value.split('/').map(Number);
      const systolic = parts[0] || 0;
      const diastolic = parts[1] || 0;
      if (systolic >= 140 || diastolic >= 90 || systolic < 90 || diastolic < 60) return '⚠️';
      return '✅';
    } else if (type === '血糖') {
      const val = Number(value);
      if (val >= 7.0 || val < 3.9) return '⚠️';
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
      const parts = value.split('/').map(Number);
      const systolic = parts[0] || 0;
      const diastolic = parts[1] || 0;
      if (systolic >= 140 || diastolic >= 90 || systolic < 90 || diastolic < 60) return '#FF4444';
      return '#52C41A';
    } else if (type === '血糖') {
      const val = Number(value);
      if (val >= 7.0 || val < 3.9) return '#FF4444';
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

    // 去重日期
    const dateSet = Array.from(new Set(monthlyRecords.map(item => item.date)));
    const recordDays = dateSet.length;

    // 最近记录
    const sortedRecords = [...this.records].sort((a, b) => b.createdAt - a.createdAt);
    const recentRecord = sortedRecords[0] ?? null;

    // 异常统计
    const abnormalCount = monthlyRecords.filter(item => this.getStatusIcon(item.value, item.type) === '⚠️').length;

    return {
      recordDays,
      recentRecord: recentRecord ? `${recentRecord.date} ${recentRecord.time}` : '暂无记录',
      abnormalCount
    };
  }

  deleteRecord(id: string) {
    this.records = this.records.filter(item => item.id !== id);
    this.filterAndSortRecords();
  }

  async generateAISummary(): Promise<void> {
    try {
      const request = AIRequestBuilder.createWithIntent(
        JSON.stringify(this.filteredRecords),
        'health_summary'
      );
      const response = await this.orchestrator.process(request);
      const content = response.output.content;
      this.aiSummary = typeof content === 'string' ? content : JSON.stringify(content);
      this.abnormalItems = response.suggestions || [];
    } catch (error) {
      console.error('[HealthRecords] AI摘要生成失败:', error);
      this.aiSummary = 'AI摘要暂时不可用';
    }
  }

  async detectAbnormalWithAI(): Promise<void> {
    try {
      const request = AIRequestBuilder.createWithIntent(
        JSON.stringify(this.records),
        'risk_analysis'
      );
      const response = await this.orchestrator.process(request);
      if (response.suggestions) this.abnormalItems = response.suggestions;
    } catch (error) {
      console.error('[HealthRecords] AI异常检测失败:', error);
    }
  }

  @Builder
  BloodPressureChart() {
    Column() {
      Text('📊 血压趋势图')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 12 })
        .textAlign(TextAlign.Center);

      Row() {
        ForEach(this.chartDates, (date: string, index: number) => {
          this.BPBarColumn(index);
        }, (date: string): string => date);
      }
      .justifyContent(FlexAlign.SpaceAround);

      Row({ space: 16 }) {
        Row({ space: 4 }) {
          Column().width(10).height(10).backgroundColor('#1677FF').borderRadius(2);
          Text('收缩压').fontSize(10).fontColor('#666666');
        }
        Row({ space: 4 }) {
          Column().width(10).height(10).backgroundColor('#36CFC9').borderRadius(2);
          Text('舒张压').fontSize(10).fontColor('#666666');
        };
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 8 });
    }
  }

  @Builder
  BPBarColumn(index: number) {
    Column({ space: 4 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width(32)
          .height(80)
          .backgroundColor('#F5F7FA')
          .borderRadius(4);
        this.BPBars(index);
      }
      .width(38)
      .height(85);
      this.DateLabel(index);
    }
  }

  @Builder
  BPBars(index: number) {
    Column() {
      Row({ space: 2 }) {
        Column()
          .width(14)
          .height(this.calcBarHeight(this.getSysValue(index), this.bpMaxValue, this.bpMinValue, 70))
          .borderRadius({ topLeft: 4, topRight: 4 })
          .backgroundColor('#1677FF');
        Column()
          .width(14)
          .height(this.calcBarHeight(this.getDiaValue(index), this.bpMaxValue, this.bpMinValue, 70))
          .borderRadius({ topLeft: 4, topRight: 4 })
          .backgroundColor('#36CFC9');
      }
    }
    .alignItems(HorizontalAlign.End);
  }

  getSysValue(index: number): number {
    return this.bpSysData[index] ?? 120;
  }

  getDiaValue(index: number): number {
    return this.bpDiaData[index] ?? 80;
  }

  @Builder
  DateLabel(index: number) {
    Text(this.chartDates[index] ?? '--')
      .fontSize(9)
      .fontColor('#999999');
  }

  @Builder
  GlucoseChart() {
    Row() {
      ForEach(this.chartDates, (date: string, index: number) => {
        this.GlucoseBarColumn(index);
      }, (date: string): string => date);
    }
    .justifyContent(FlexAlign.SpaceAround);
  }

  @Builder
  GlucoseBarColumn(index: number) {
    Column({ space: 4 }) {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width(32)
          .height(60)
          .backgroundColor('#FFF5EE')
          .borderRadius(4);
        this.GlucoseBar(index);
      }
      .width(38)
      .height(65);
      this.DateLabel(index);
    }
  }

  @Builder
  GlucoseBar(index: number) {
    if (index < this.glucoseValues.length) {
      Column()
        .width(28)
        .height(this.calcGlucoseHeight(this.glucoseValues[index]))
        .borderRadius({ topLeft: 4, topRight: 4 })
        .backgroundColor(this.getGlucoseColor(this.glucoseValues[index]));
    }
  }

  calcGlucoseHeight(value: number): number {
    const h = (value / 10) * 55;
    return h > 6 ? h : 6;
  }

  getGlucoseColor(value: number): string {
    if (value > 6.1) return '#FF4444';
    if (value < 3.9) return '#FAAD14';
    return '#FF7F50';
  }

  calcBarHeight(value: number, maxVal: number, minVal: number, maxHeight: number): number {
    if (maxVal <= minVal) return 4;
    const height = ((value - minVal) / (maxVal - minVal)) * maxHeight;
    return height > 0 ? height : 4;
  }

  @Builder
  LoadingStatus() {
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

  build() {
    Column() {
      // 返回按钮
      Text('← 返回')
        .fontSize(16)
        .fontColor('#1677FF')
        .padding(12)
        .width('100%')
        .onClick(() => router.back());

      // 主滚动区域
      Scroll() {
        Column({ space: 16 }) {
          Text('健康记录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1677FF')
            .margin({ top: 16, bottom: 12 });

          // 统计卡片
          Row() {
            // 本月记录天数
            Column() {
              Text(this.stats.recordDays.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1677FF');
              Text('本月记录天数')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 });
            }
            .width('33%')
            .alignItems(HorizontalAlign.Center);

            // 最近记录时间
            Column() {
              Text(this.stats.recentRecord)
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1677FF')
                .textAlign(TextAlign.Center);
              Text('最近记录时间')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 });
            }
            .width('33%')
            .alignItems(HorizontalAlign.Center);

            // 异常次数
            Column() {
              Text(this.stats.abnormalCount.toString())
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
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
          .backgroundColor(Color.White)
          .borderRadius(12);

          // 类型标签
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
                }, (tab: string): string => tab);
              }
            }
          }
          .width('85%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12);

          // 时间/排序筛选
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
              }, (range: string): string => range);
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
              }, (order: string): string => order);
            }
          }
          .width('85%')
          .justifyContent(FlexAlign.SpaceBetween);

          // 图表区域
          Column() {
            Text('📈 趋势图表')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
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

            this.BloodPressureChart();

            Divider().color('#F0F0F0').margin({ top: 8, bottom: 8 });

            Text('🍬 血糖趋势图')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ bottom: 12 })
              .textAlign(TextAlign.Center);

            this.GlucoseChart();

            Row() {
              Text('正常: 3.9-6.1 mmol/L')
                .fontSize(10)
                .fontColor('#52C41A');
            }
            .justifyContent(FlexAlign.Center)
            .margin({ top: 6 });
          }
          .width('85%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12);

          // 记录列表
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
            .backgroundColor(Color.White)
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
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#333333');
                        Blank();
                        Text(`${record.value} ${record.unit}`)
                          .fontSize(14)
                          .fontWeight(FontWeight.Bold)
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
                .backgroundColor(Color.White)
                .borderRadius(10)
                .margin({ top: 8 })
                // 修复：统一路由API
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/HealthRecordDetail',
                    params: { record: record }
                  });
                });
              }, (record: HealthRecord): string => record.id);
              this.LoadingStatus();
            }
            .width('85%');
          }
        }
        .width('100%')
        .padding({ bottom: 100 });
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off);

      // 添加记录悬浮按钮
      Button('+ 添加记录')
        .width(64)
        .height(64)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(32)
        .position({ x: '80%', y: '75%' })
        // 修复：统一路由API
        .onClick(() => {
          router.pushUrl({ url: 'pages/AddHealthRecord' });
        });

      // 底部导航栏
      Row() {
        Text('🏠').fontSize(20).margin(8).onClick(() => router.pushUrl({ url: 'pages/HomePage' }));
        Text('📋').fontSize(20).margin(8).fontColor('#1677FF');
        Text('💊').fontSize(20).margin(8).onClick(() => router.pushUrl({ url: 'pages/Medications' }));
        Text('📚').fontSize(20).margin(8).onClick(() => router.pushUrl({ url: 'pages/SciencePage' }));
        Text('👤').fontSize(20).margin(8).onClick(() => router.pushUrl({ url: 'pages/Profile' }));
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .padding(8)
      .backgroundColor(Color.White)
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: -2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}