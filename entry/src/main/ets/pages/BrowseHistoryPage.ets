import { router } from '@kit.ArkUI';
import RdbHelper from '../utils/RdbHelper';
import { TABLE_BROWSE_HISTORY, COLUMN_CREATE_TIME } from '../utils/DatabaseConstants';
import { BrowseHistoryItem } from '../models/LocalModels';
import { StatPieChart } from '../components/StatPieChart';

interface ChartData {
  type: string;
  count: number;
  color: string;
}

interface GroupedHistory {
  date: string;
  records: BrowseHistoryItem[];
}

@Entry
@Component
struct BrowseHistoryPage {
  @State historyData: BrowseHistoryItem[] = [];
  @State groupedHistory: GroupedHistory[] = [];
  @State chartData: ChartData[] = [];
  @State todayCount: number = 0;
  @State weekDuration: number = 0;
  @State showClearDialog: boolean = false;

  aboutToAppear() {
    this.loadHistoryData();
  }

  async loadHistoryData(): Promise<void> {
    try {
      const resultSet = await RdbHelper.query(`SELECT * FROM ${TABLE_BROWSE_HISTORY} ORDER BY ${COLUMN_CREATE_TIME} DESC`);
      
      const history: BrowseHistoryItem[] = [];
      while (resultSet.goToNextRow()) {
        history.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          browse_type: resultSet.getString(resultSet.getColumnIndex('browse_type')),
          target_id: resultSet.getLong(resultSet.getColumnIndex('target_id')),
          target_title: resultSet.getString(resultSet.getColumnIndex('target_title')),
          browse_duration: resultSet.getLong(resultSet.getColumnIndex('browse_duration')),
          source_page: resultSet.getString(resultSet.getColumnIndex('source_page')),
          create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
        });
      }
      
      this.historyData = history;
      this.groupHistoryByDate();
      this.calculateStatistics();
      this.generateChartData();
    } catch (error) {
      console.error('Failed to load history data:', error);
    }
  }

  groupHistoryByDate(): void {
    const groups: Record<string, BrowseHistoryItem[]> = {};
    
    this.historyData.forEach(record => {
      if (record.create_time) {
        const date = new Date(record.create_time).toLocaleDateString();
        if (!groups[date]) {
          groups[date] = [];
        }
        groups[date].push(record);
      }
    });
    
    this.groupedHistory = Object.entries(groups).map(([date, records]) => ({
      date,
      records
    }));
  }

  calculateStatistics(): void {
    const now = Date.now();
    const todayStart = new Date(now);
    todayStart.setHours(0, 0, 0, 0);
    const todayStartTimestamp = todayStart.getTime();
    
    const weekStart = new Date(now);
    weekStart.setDate(weekStart.getDate() - 7);
    const weekStartTimestamp = weekStart.getTime();
    
    this.todayCount = this.historyData.filter(item => 
      item.create_time && item.create_time >= todayStartTimestamp
    ).length;
    
    this.weekDuration = this.historyData
      .filter(item => item.create_time && item.create_time >= weekStartTimestamp)
      .reduce((total, item) => total + (item.browse_duration || 0), 0);
  }

  generateChartData(): void {
    const typeCounts: Record<string, number> = {};
    
    this.historyData.forEach(item => {
      if (item.browse_type) {
        typeCounts[item.browse_type] = (typeCounts[item.browse_type] || 0) + 1;
      }
    });
    
    const colors = {
      'ARTICLE': '#3498db',
      'HERBAL': '#27ae60',
      'HOSPITAL': '#e67e22',
      'AI_CHAT': '#9b59b6',
      'FOOD': '#f1c40f',
      'KNOWLEDGE': '#1abc9c',
      'REHAB': '#e74c3c',
      'HOME': '#34495e'
    };
    
    this.chartData = Object.entries(typeCounts).map(([type, count]) => ({
      type,
      count,
      color: colors[type as keyof typeof colors] || '#95a5a6'
    }));
  }

  async clearHistory(): Promise<void> {
    try {
      await RdbHelper.executeSql(`DELETE FROM ${TABLE_BROWSE_HISTORY}`);
      this.historyData = [];
      this.groupedHistory = [];
      this.chartData = [];
      this.todayCount = 0;
      this.weekDuration = 0;
      this.showClearDialog = false;
    } catch (error) {
      console.error('Failed to clear history:', error);
    }
  }

  navigateToDetail(record: BrowseHistoryItem): void {
    if (!record.browse_type || !record.target_id) return;
    
    switch (record.browse_type) {
      case 'ARTICLE':
        router.push({ url: 'pages/ScienceDetailPage', params: { id: record.target_id } });
        break;
      case 'HERBAL':
        router.push({ url: 'pages/HerbalDetailPage', params: { id: record.target_id } });
        break;
      case 'HOSPITAL':
        router.push({ url: 'pages/HospitalDetailPage', params: { id: record.target_id } });
        break;
      default:
        break;
    }
  }

  formatDuration(ms: number): string {
    const seconds = Math.floor(ms / 1000);
    if (seconds < 60) return `${seconds}秒`;
    
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}分${seconds % 60}秒`;
    
    const hours = Math.floor(minutes / 60);
    return `${hours}小时${minutes % 60}分`;
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .onClick(() => router.back());
        Text('浏览历史')
          .fontSize(20)
          .fontWeight('bold');
        Button('清空')
          .onClick(() => this.showClearDialog = true);
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceBetween);

      Scroll() {
        Column({
          space: 20
        }) {
          Column() {
            Row({
              space: 20
            }) {
              Column() {
                Text('今日浏览')
                  .fontSize(14)
                  .fontColor('#666666');
                Text(this.todayCount.toString())
                  .fontSize(24)
                  .fontWeight('bold')
                  .fontColor('#333333');
              }
              .flexGrow(1);

              Column() {
                Text('本周总时长')
                  .fontSize(14)
                  .fontColor('#666666');
                Text(this.formatDuration(this.weekDuration))
                  .fontSize(24)
                  .fontWeight('bold')
                  .fontColor('#333333');
              }
              .flexGrow(1);
            }
            .padding(20);
          }
          .width('100%')
          .backgroundColor('#ffffff')
          .borderRadius(8)
          .shadow({ radius: 4, color: '#00000010' });

          if (this.chartData.length > 0) {
            Column() {
              Text('浏览类型分布')
                .fontSize(18)
                .fontWeight('bold')
                .margin({ bottom: 16 });
              StatPieChart({ data: this.chartData, sizeValue: 200 });
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#ffffff')
            .borderRadius(8)
            .shadow({ radius: 4, color: '#00000010' });
          }

          if (this.groupedHistory.length > 0) {
            ForEach(this.groupedHistory, (group) => {
              Column() {
                Text(group.date)
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ left: 16, bottom: 12 });
                
                ForEach(group.records, (record) => {
                  Column() {
                    Row({
                      space: 16
                    }) {
                      Column()
                        .width(40)
                        .height(40)
                        .backgroundColor('#f0f0f0')
                        .borderRadius(20)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(HorizontalAlign.Center);

                      Column({
                        space: 4
                      }) {
                        Text(record.target_title || '未知')
                          .fontSize(16)
                          .fontColor('#333333');
                        Row() {
                          Text(this.formatTime(record.create_time!))
                            .fontSize(14)
                            .fontColor('#999999');
                          Text('·')
                            .fontSize(14)
                            .fontColor('#999999');
                          Text(this.formatDuration(record.browse_duration || 0))
                            .fontSize(14)
                            .fontColor('#999999');
                        }
                      }
                      .flexGrow(1);
                    }
                    .padding(16);
                  }
                  .width('100%')
                  .backgroundColor('#ffffff')
                  .borderRadius(8)
                  .shadow({ radius: 2, color: '#00000008' })
                  .onClick(() => this.navigateToDetail(record));
                });
              }
              .width('100%');
            });
          } else {
            Column() {
              Image('common:ic_empty')
                .width(80)
                .height(80);
              Text('暂无浏览历史')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 16 });
              Text('浏览页面后会自动记录')
                .fontSize(14)
                .fontColor('#cccccc')
                .margin({ top: 8 });
            }
            .width('100%')
            .height(400)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);
          }
        }
        .padding(16);
      }

      if (this.showClearDialog) {
        Column({
          space: 20
        }) {
          Text('确认清空')
            .fontSize(18)
            .fontWeight('bold');
          Text('确定要清空所有浏览历史记录吗？此操作不可恢复。')
            .fontSize(14)
            .fontColor('#666666')
            .textAlign(TextAlign.Center);
          Row({
            space: 20
          }) {
            Button('取消')
              .flexGrow(1)
              .onClick(() => this.showClearDialog = false);
            Button('确定')
              .flexGrow(1)
              .onClick(() => this.clearHistory());
          }
        }
        .padding(20)
        .backgroundColor('#ffffff')
        .borderRadius(8)
        .width('80%')
        .position({ x: '10%', y: '40%' });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5');
  }
}
