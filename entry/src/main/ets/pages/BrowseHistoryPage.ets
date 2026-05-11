import { router } from '@kit.ArkUI';
import RdbHelper from '../utils/RdbHelper';
import { TABLE_BROWSE_HISTORY, COLUMN_CREATE_TIME, COLUMN_BROWSE_TYPE } from '../utils/DatabaseConstants';
import { BrowseHistoryItem } from '../models/LocalModels';

interface GroupedHistory {
  date: string;
  records: BrowseHistoryItem[];
}

interface TestArticleData {
  id: number;
  title: string;
  time: number;
}

@Entry
@Component
struct BrowseHistoryPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State historyData: BrowseHistoryItem[] = [];
  @State articleHistoryData: BrowseHistoryItem[] = [];
  @State groupedHistory: GroupedHistory[] = [];
  @State showClearDialog: boolean = false;
  @State currentFilter: string = 'ARTICLE';
  @State filterTabs: string[] = ['科普文章', '全部记录'];

  aboutToAppear() {
    this.loadHistoryData();
  }

  async loadHistoryData(): Promise<void> {
    try {
      if (!RdbHelper.isInitialized()) {
        console.warn('数据库未初始化，跳过加载');
        return;
      }

      const resultSet = await RdbHelper.query('SELECT * FROM ' + TABLE_BROWSE_HISTORY + ' ORDER BY ' + COLUMN_CREATE_TIME + ' DESC');

      const history: BrowseHistoryItem[] = [];
      if (resultSet) {
        while (resultSet.goToNextRow()) {
          history.push({
            id: resultSet.getLong(resultSet.getColumnIndex('id')),
            browse_type: resultSet.getString(resultSet.getColumnIndex(COLUMN_BROWSE_TYPE)),
            target_id: resultSet.getLong(resultSet.getColumnIndex('target_id')),
            target_title: resultSet.getString(resultSet.getColumnIndex('target_title')),
            browse_duration: resultSet.getLong(resultSet.getColumnIndex('browse_duration')),
            source_page: resultSet.getString(resultSet.getColumnIndex('source_page')),
            create_time: resultSet.getLong(resultSet.getColumnIndex(COLUMN_CREATE_TIME))
          });
        }
        resultSet.close();
      }

      this.historyData = history;
      this.filterByType(this.currentFilter);
    } catch (error) {
      console.error('Failed to load history data:', error);
      this.historyData = [];
      this.articleHistoryData = [];
      this.groupedHistory = [];
    }
  }

  filterByType(type: string): void {
    this.currentFilter = type;

    if (type === 'ARTICLE') {
      this.articleHistoryData = this.historyData.filter((item: BrowseHistoryItem) => {
        return item.browse_type === 'ARTICLE';
      });
    } else {
      this.articleHistoryData = [...this.historyData];
    }

    this.groupHistoryByDate();
  }

  groupHistoryByDate(): void {
    const groups: Record<string, BrowseHistoryItem[]> = {};

    for (let i = 0; i < this.articleHistoryData.length; i++) {
      const record = this.articleHistoryData[i];
      if (record.create_time) {
        const date = new Date(record.create_time);
        const dateStr = date.getFullYear() + '-' +
          String(date.getMonth() + 1).padStart(2, '0') + '-' +
          String(date.getDate()).padStart(2, '0');
        if (!groups[dateStr]) {
          groups[dateStr] = [];
        }
        groups[dateStr].push(record);
      }
    }

    const keys: string[] = Object.keys(groups);
    keys.sort((a: string, b: string) => b.localeCompare(a));

    this.groupedHistory = [];
    for (let j = 0; j < keys.length; j++) {
      this.groupedHistory.push({
        date: keys[j],
        records: groups[keys[j]]
      });
    }
  }

  async clearArticleHistory(): Promise<void> {
    try {
      if (this.currentFilter === 'ARTICLE') {
        await RdbHelper.executeSql('DELETE FROM ' + TABLE_BROWSE_HISTORY + ' WHERE ' + COLUMN_BROWSE_TYPE + ' = \'ARTICLE\'');
      } else {
        await RdbHelper.executeSql('DELETE FROM ' + TABLE_BROWSE_HISTORY);
      }

      this.historyData = [];
      this.articleHistoryData = [];
      this.groupedHistory = [];
      this.showClearDialog = false;
    } catch (error) {
      console.error('Failed to clear history:', error);
    }
  }

  async insertTestData(): Promise<void> {
    try {
      const testArticles: TestArticleData[] = [
        { id: 1, title: '高血压的预防与日常管理指南', time: Date.now() - 3600000 },
        { id: 2, title: '糖尿病患者饮食注意事项大全', time: Date.now() - 7200000 },
        { id: 3, title: '冬季养生保健知识', time: Date.now() - 86400000 },
        { id: 4, title: '心血管疾病的早期症状识别', time: Date.now() - 172800000 },
        { id: 5, title: '如何科学补充维生素和矿物质', time: Date.now() - 259200000 }
      ];

      for (let i = 0; i < testArticles.length; i++) {
        const article = testArticles[i];
        await RdbHelper.executeSql(
          'INSERT OR IGNORE INTO ' + TABLE_BROWSE_HISTORY +
          ' (browse_type, target_id, target_title, source_page, create_time, browse_duration) VALUES ' +
          '(\'ARTICLE\', ' + article.id + ', \'' + article.title +
          '\', \'ScienceDetailPage\', ' + article.time + ', ' + (Math.floor(Math.random() * 120) + 30) * 1000 + ')'
        );
      }

      console.log('测试数据插入成功');
      this.loadHistoryData();
    } catch (error) {
      console.error('插入测试数据失败:', error);
    }
  }

  navigateToDetail(record: BrowseHistoryItem): void {
    if (!record.browse_type || !record.target_id) return;

    switch (record.browse_type) {
      case 'ARTICLE':
        router.pushUrl({
          url: 'pages/ScienceDetailPage',
          params: { articleId: record.target_id.toString(), articleTitle: record.target_title || '' }
        });
        break;
      case 'HERBAL':
        router.pushUrl({ url: 'pages/HerbalDetailPage', params: { id: record.target_id } });
        break;
      case 'FOOD':
        router.pushUrl({ url: 'pages/FoodDetailPage', params: { foodId: record.target_id.toString() } });
        break;
      default:
        break;
    }
  }

  getTypeIcon(type: string): string {
    const iconMap: Record<string, string> = {
      'ARTICLE': '📰',
      'HERBAL': '🌿',
      'FOOD': '🥗',
      'HOSPITAL': '🏥',
      'AI_CHAT': '🤖',
      'KNOWLEDGE': '📚',
      'REHAB': '💪',
      'PAGE': '📱'
    };
    return iconMap[type] || '📄';
  }

  getTypeName(type: string): string {
    const nameMap: Record<string, string> = {
      'ARTICLE': '科普文章',
      'HERBAL': '中药材',
      'FOOD': '健康食材',
      'HOSPITAL': '医院信息',
      'AI_CHAT': 'AI对话',
      'KNOWLEDGE': '知识图谱',
      'REHAB': '康复训练',
      'PAGE': '页面浏览'
    };
    return nameMap[type] || type;
  }

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const isToday = date.toDateString() === now.toDateString();

    if (isToday) {
      return '今天 ' + date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
    }

    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    if (date.toDateString() === yesterday.toDateString()) {
      return '昨天 ' + date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
    }

    return (date.getMonth() + 1) + '月' + date.getDate() + '日 ' +
      date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
  }

  formatDuration(ms: number): string {
    if (!ms || ms <= 0) return '';
    const seconds = Math.floor(ms / 1000);
    if (seconds < 60) return seconds + '秒';
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return minutes + '分钟';
    const hours = Math.floor(minutes / 60);
    return hours + '小时' + (minutes % 60) + '分';
  }

  build() {
    Column() {
      Column() {
        Row() {
          Button() {
            Row({ space: 4 }) {
              Text('←')
                .fontSize(18)
                .fontColor('#1677FF');
            }
          }
          .height(36)
          .padding({ left: 8, right: 8 })
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back());

          Text('浏览历史')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
            .textAlign(TextAlign.Center);

          Button() {
            Text('清空')
              .fontSize(14)
              .fontColor('#FF4D4F');
          }
          .height(36)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.showClearDialog = true);
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.SpaceBetween);

        Row({ space: 12 }) {
          ForEach(this.filterTabs, (tab: string, index: number) => {
            Text(tab)
              .fontSize(15)
              .fontWeight(this.currentFilter === (index === 0 ? 'ARTICLE' : 'ALL') ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(this.currentFilter === (index === 0 ? 'ARTICLE' : 'ALL') ? '#1677FF' : '#666666')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.currentFilter === (index === 0 ? 'ARTICLE' : 'ALL') ? '#E6F4FF' : Color.Transparent)
              .borderRadius(16)
              .onClick(() => this.filterByType(index === 0 ? 'ARTICLE' : 'ALL'));
          });

          Button('测试数据')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#52C41A')
            .height(32)
            .borderRadius(16)
            .padding({ left: 12, right: 12 })
            .onClick(() => this.insertTestData());
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 });

        Scroll() {
          Column({ space: 12 }) {
            if (this.groupedHistory.length > 0) {
              ForEach(this.groupedHistory, (group: GroupedHistory) => {
                Column() {
                  Text(group.date)
                    .fontSize(13)
                    .fontColor('#999999')
                    .margin({ left: 16, bottom: 8 })
                    .fontWeight(FontWeight.Medium);

                  ForEach(group.records, (record: BrowseHistoryItem) => {
                    Row() {
                      Column({ space: 6 }) {
                        Text(this.getTypeIcon(record.browse_type || ''))
                          .fontSize(24);

                        if (record.browse_duration && record.browse_duration > 0) {
                          Text(this.formatDuration(record.browse_duration))
                            .fontSize(10)
                            .fontColor('#999999');
                        }
                      }
                      .width(48)
                      .justifyContent(FlexAlign.Center);

                      Column({ space: 4 }) {
                        Text(record.target_title || '未命名内容')
                          .fontSize(this.isElderMode ? 17 : 15)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis });

                        Row({ space: 8 }) {
                          Text(this.getTypeName(record.browse_type || ''))
                            .fontSize(11)
                            .fontColor('#666666')
                            .backgroundColor('#F5F5F5')
                            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                            .borderRadius(10);

                          Text(this.formatTime(record.create_time || 0))
                            .fontSize(11)
                            .fontColor('#999999');
                        }
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start);

                      Text('>')
                        .fontSize(16)
                        .fontColor('#CCCCCC');
                    }
                    .width('100%')
                    .padding(16)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(12)
                    .shadow({ radius: 2, color: '#00000008', offsetX: 0, offsetY: 1 })
                    .onClick(() => this.navigateToDetail(record));
                  }, (record: BrowseHistoryItem) => String(record.id ?? 0));
                }
                .width('100%');
              }, (group: GroupedHistory) => group.date);
            } else {
              Column({ space: 16 }) {
                Text('📖')
                  .fontSize(64);

                Text(this.currentFilter === 'ARTICLE' ? '暂无文章浏览记录' : '暂无浏览历史')
                  .fontSize(16)
                  .fontColor('#666666')
                  .fontWeight(FontWeight.Medium);

                Text(this.currentFilter === 'ARTICLE' ? '阅读科普文章后会自动记录在这里' : '浏览页面后会自动记录')
                  .fontSize(13)
                  .fontColor('#999999')
                  .textAlign(TextAlign.Center);

                Button('去发现好文章')
                  .height(40)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#1677FF')
                  .borderRadius(20)
                  .padding({ left: 24, right: 24 })
                  .margin({ top: 16 })
                  .onClick(() => {
                    router.back();
                    router.pushUrl({ url: 'pages/DiscoverPage' });
                  });
              }
              .width('100%')
              .height(450)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);
            }
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 32 });
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA');

      if (this.showClearDialog) {
        Column() {
          Column({ space: 20 }) {
            Text('⚠️')
              .fontSize(48);

            Text('确认清空')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333');

            Text(this.currentFilter === 'ARTICLE'
              ? '确定要清空所有文章浏览记录吗？'
              : '确定要清空所有浏览历史记录吗？此操作不可恢复。')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)
              .lineHeight(20);

            Row({ space: 12 }) {
              Button('取消')
                .flexGrow(1)
                .height(44)
                .fontSize(15)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .borderRadius(22)
                .onClick(() => this.showClearDialog = false);

              Button('确定清空')
                .flexGrow(1)
                .height(44)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .backgroundColor('#FF4D4F')
                .borderRadius(22)
                .onClick(() => this.clearArticleHistory());
            }
          }
          .width('85%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 16, color: '#00000020' });
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      }
    }
    .width('100%')
    .height('100%');
  }
}
