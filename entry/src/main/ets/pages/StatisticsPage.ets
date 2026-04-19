import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { GlobalTheme } from '../global';

interface DataPoint {
  label: string;
  value: number;
}

interface HealthSummary {
  totalRecords: number;
  abnormalRatio: number;
  rehabCompletion: number;
  articlesRead: number;
}

const TIME_RANGES: string[] = ['近7天', '近30天', '近90天', '全年'];

const MOCK_BLOOD_PRESSURE_7D: DataPoint[] = [
  { label: '4/8', value: 135 }, { label: '4/9', value: 128 },
  { label: '4/10', value: 142 }, { label: '4/11', value: 130 },
  { label: '4/12', value: 125 }, { label: '4/13', value: 132 },
  { label: '4/14', value: 127 }
];

const MOCK_BLOOD_SUGAR_30D: DataPoint[] = [
  { label: '第1周', value: 6.2 }, { label: '第2周', value: 5.8 },
  { label: '第3周', value: 6.5 }, { label: '第4周', value: 5.9 }
];

const MOCK_EXERCISE_DAYS: DataPoint[] = [
  { label: '周一', value: 1 }, { label: '周二', value: 0 },
  { label: '周三', value: 1 }, { label: '周四', value: 1 },
  { label: '周五', value: 0 }, { label: '周六', value: 1 },
  { label: '周日', value: 1 }
];

const MOCK_HEALTH_SCORE_TREND: DataPoint[] = [
  { label: '1月', value: 72 }, { label: '2月', value: 75 },
  { label: '3月', value: 78 }, { label: '4月', value: 82 }
];

@Entry
@Component
struct StatisticsPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State healthScore: number = 82;
  @State currentRangeIndex: number = 0;
  @State healthSummary: HealthSummary = {
    totalRecords: 48,
    abnormalRatio: 15,
    rehabCompletion: 85,
    articlesRead: 23
  };

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }
  }

  getScoreColor(score: number): string {
    if (score >= 80) return '#52C41A';
    if (score >= 60) return '#FAAD14';
    return '#FF4D4F';
  }

  getScoreLabel(score: number): string {
    if (score >= 85) return '优秀';
    if (score >= 70) return '良好';
    if (score >= 60) return '一般';
    return '需改善';
  }

  changeTimeRange(index: number): void {
    this.currentRangeIndex = index;
    this.updateDataForRange(index);
  }

  updateDataForRange(index: number): void {
    const multipliers: number[] = [1, 4, 12, 1];
    const mult: number = multipliers[index] || 1;
    this.healthSummary = {
      totalRecords: 48 * mult,
      abnormalRatio: index === 0 ? 15 : index === 1 ? 12 : index === 2 ? 18 : 16,
      rehabCompletion: index === 0 ? 85 : index === 1 ? 78 : index === 2 ? 82 : 80,
      articlesRead: Math.round(23 * mult * 0.7)
    };
  }

  build() {
    Column() {
      Header({ title: '健康统计', showBack: true });

      Scroll() {
        Column({ space: 20 }) {

          Row({ space: 10 }) {
            ForEach(TIME_RANGES, (range: string, index: number) => {
              Text(range)
                .fontSize(13)
                .fontColor(this.currentRangeIndex === index ? '#FFFFFF' : '#666666')
                .backgroundColor(this.currentRangeIndex === index ? '#1677FF' : '#F5F5F5')
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .borderRadius(16)
                .onClick(() => this.changeTimeRange(index));
            }, (range: string, index: number) => 'range_' + index);
          }
          .width('100%')
          .justifyContent(FlexAlign.Center);

          Column({ space: 20 }) {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(180)
                .height(180)
                .borderRadius(90)
                .backgroundColor('#F0F0F0');

              Stack({ alignContent: Alignment.TopStart }) {
                Column()
                  .width(180)
                  .height(180)
                  .borderRadius(90)
                  .backgroundColor('#E6F7FF');
              }
              .width(180)
              .height(180)
              .clip(true);

              Column({ space: 4 }) {
                Text('' + this.healthScore)
                  .fontSize(42)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.getScoreColor(this.healthScore));

                Text('健康评分')
                  .fontSize(13)
                  .fontColor('#999999');

                Text(this.getScoreLabel(this.healthScore))
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.getScoreColor(this.healthScore))
                  .backgroundColor(this.getScoreColor(this.healthScore) + '18')
                  .padding({ left: 12, right: 12, top: 3, bottom: 3 })
                  .borderRadius(10);
              }
            }
            .width(200)
            .height(200);

            Row({ space: 24 }) {
              this.buildMiniStat('📊', '最高', '142/89', '#FF4D4F');
              this.buildMiniStat('📉', '最低', '118/72', '#1677FF');
              this.buildMiniStat('📋', '平均', '130/80', '#52C41A');
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
          .justifyContent(FlexAlign.Center);

          Text('📈 趋势图表')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%');

          Column({ space: 16 }) {
            this.buildChartCard('血压趋势（近7天）收缩压', '🩺', '#1677FF', MOCK_BLOOD_PRESSURE_7D, 90, 160);
            this.buildChartCard('血糖均值变化', '💉', '#FAAD14', MOCK_BLOOD_SUGAR_30D, 4, 9);
            this.buildBarChartCard('本周运动打卡', '🏃', '#52C41A', MOCK_EXERCISE_DAYS);
            this.buildChartCard('健康评分趋势', '⭐', '#722ED1', MOCK_HEALTH_SCORE_TREND, 50, 100);
          }
          .width('100%');

          Text('📊 数据汇总')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%');

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            this.buildSummaryCard('📝', '记录次数', '' + this.healthSummary.totalRecords + '次', '#1677FF', '#E6F7FF');
            this.buildSummaryCard('⚠️', '异常占比', '' + this.healthSummary.abnormalRatio + '%', this.healthSummary.abnormalRatio > 20 ? '#FF4D4F' : '#FAAD14', this.healthSummary.abnormalRatio > 20 ? '#FFF1F0' : '#FFFBE6');
            this.buildSummaryCard('✅', '康复完成率', '' + this.healthSummary.rehabCompletion + '%', '#52C41A', '#F6FFED');
            this.buildSummaryCard('📚', '科普阅读', '' + this.healthSummary.articlesRead + '篇', '#722ED1', '#F9F0FF');
          }
          .width('100%');
        }
        .width('85%')
        .padding({ top: 16, bottom: 100 });
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 4 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }

  @Builder
  buildMiniStat(icon: string, label: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(icon)
        .fontSize(22);

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color);

      Text(label)
        .fontSize(11)
        .fontColor('#999999');
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  buildChartCard(title: string, icon: string, color: string, data: DataPoint[], minVal: number, maxVal: number) {
    Column({ space: 12 }) {
      Row() {
        Text(icon + ' ' + title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1);

        Text('最新: ' + data[data.length - 1].value + this.getUnitByTitle(title))
          .fontSize(12)
          .fontColor(color)
          .fontWeight(FontWeight.Medium);
      }
      .width('100%');

      Column() {
        Row() {
          ForEach(data, (point: DataPoint, index: number) => {
            Column({ space: 4 }) {
              Column()
                .width(8)
                .height(Math.max(8, ((point.value - minVal) / (maxVal - minVal)) * 80))
                .backgroundColor(color)
                .borderRadius(4);

              Text(point.label)
                .fontSize(9)
                .fontColor('#999999');
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center);
          }, (point: DataPoint, index: number) => 'p_' + index);
        }
        .width('100%')
        .height(110)
        .alignItems(VerticalAlign.Bottom);
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FAFAFA')
      .borderRadius(8);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildBarChartCard(title: string, icon: string, color: string, data: DataPoint[]) {
    Column({ space: 12 }) {
      Row() {
        Text('' + icon + ' ' + title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1);

        Text('' + this.countPositiveDays(data) + '/7天')
          .fontSize(12)
          .fontColor(color)
          .fontWeight(FontWeight.Medium);
      }
      .width('100%');

      Row() {
        ForEach(data, (point: DataPoint, index: number) => {
          Column({ space: 6 }) {
            Column()
              .width(32)
              .height(point.value > 0 ? 50 : 8)
              .backgroundColor(point.value > 0 ? color : '#F0F0F0')
              .borderRadius(6)
              .justifyContent(point.value > 0 ? FlexAlign.End : FlexAlign.Center);

            if (point.value > 0) {
              Text('✓')
                .fontSize(12)
                .fontColor('#FFFFFF');
            } else {
              Text('✗')
                .fontSize(10)
                .fontColor('#CCCCCC');
            }

            Text(point.label)
              .fontSize(10)
              .fontColor('#999999');
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center);
        }, (point: DataPoint, index: number) => 'bar_' + index);
      }
      .width('100%')
      .height(100)
      .alignItems(VerticalAlign.Bottom);
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 });
  }

  @Builder
  buildSummaryCard(icon: string, title: string, value: string, textColor: string, bgColor: string) {
    Column({ space: 10 }) {
      Text(icon)
        .fontSize(28);

      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(textColor);

      Text(title)
        .fontSize(12)
        .fontColor('#666666');
    }
    .width('48%')
    .padding(16)
    .backgroundColor(bgColor)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .alignItems(HorizontalAlign.Center);
  }

  private getUnitByTitle(title: string): string {
    if (title.indexOf('压') >= 0) {
      return '';
    } else if (title.indexOf('糖') >= 0) {
      return 'mmol/L';
    } else {
      return '分';
    }
  }

  private countPositiveDays(data: DataPoint[]): number {
    let count = 0;
    for (let i = 0; i < data.length; i++) {
      if (data[i].value > 0) {
        count++;
      }
    }
    return count;
  }
}