import { router } from '@kit.ArkUI';

interface HistoryItem {
  id: string;
  date: string;
  level: string;
  levelColor: string;
  mainRisks: string[];
  score: number;
}

@Entry
@Component
struct RiskHistoryPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State historyItems: HistoryItem[] = [
    {
      id: '1',
      date: '2026-04-10',
      level: '低风险',
      levelColor: '#52C41A',
      mainRisks: ['高血压'],
      score: 78
    },
    {
      id: '2',
      date: '2026-03-25',
      level: '中风险',
      levelColor: '#FAAD14',
      mainRisks: ['高血压', '跌倒'],
      score: 65
    },
    {
      id: '3',
      date: '2026-03-10',
      level: '中风险',
      levelColor: '#FAAD14',
      mainRisks: ['高血压', '糖尿病'],
      score: 62
    },
    {
      id: '4',
      date: '2026-02-20',
      level: '高风险',
      levelColor: '#FF4D4F',
      mainRisks: ['高血压', '糖尿病', '跌倒'],
      score: 45
    }
  ];

  getLevelBgColor(levelColor: string): string {
    if (levelColor === '#52C41A') {
      return '#F6FFED';
    }
    if (levelColor === '#FAAD14') {
      return '#FFFBE6';
    }
    return '#FFF1F0';
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.back();
          });
        Text('评估历史')
          .fontSize(18)
          .fontWeight('bold')
          .flexGrow(1)
          .textAlign(TextAlign.Center);
        Blank()
          .width(60);
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      Scroll() {
        Column() {
          Text('历史评估记录')
            .fontSize(20)
            .fontWeight('bold')
            .fontColor('#333333')
            .margin({ top: 24, bottom: 16 });

          // 时间线
          ForEach(this.historyItems, (item: HistoryItem, index: number) => {
            Row() {
              // 左侧时间线
              Column() {
                Circle()
                  .width(16)
                  .height(16)
                  .fill(item.levelColor);
                if (index < this.historyItems.length - 1) {
                  Line()
                    .width(2)
                    .height(100)
                    .stroke('#E5E5E5');
                }
              }
              .alignItems(HorizontalAlign.Center)
              .margin({ right: 16 });

              // 右侧内容
              Column() {
                Row() {
                  Text(item.date)
                    .fontSize(16)
                    .fontWeight('bold')
                    .fontColor('#333333')
                    .flexGrow(1);
                  Text(item.level)
                    .fontSize(14)
                    .fontWeight('bold')
                    .fontColor(item.levelColor)
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .backgroundColor(this.getLevelBgColor(item.levelColor))
                    .borderRadius(12);
                }
                .width('100%')
                .margin({ bottom: 8 });

                Row() {
                  Text('主要风险：')
                    .fontSize(14)
                    .fontColor('#666666');
                  ForEach(item.mainRisks, (risk: string) => {
                    Text(risk)
                      .fontSize(12)
                      .fontColor('#666666')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor('#F5F5F5')
                      .borderRadius(10)
                      .margin({ left: 8 });
                  });
                }
                .width('100%')
                .margin({ bottom: 8 });

                Row() {
                  Text('健康评分：')
                    .fontSize(14)
                    .fontColor('#666666');
                  Text(item.score.toString())
                    .fontSize(14)
                    .fontWeight('bold')
                    .fontColor('#1677FF')
                    .margin({ left: 8 });
                }
                .width('100%');
              }
              .flexGrow(1);
            }
            .width('100%')
            .margin({ bottom: 24 });
          });

          // 趋势说明
          Column() {
            Text('趋势分析')
              .fontSize(18)
              .fontWeight('bold')
              .fontColor('#333333')
              .margin({ bottom: 12 });
            Text('您的健康风险呈下降趋势，从高风险逐渐改善为低风险，继续保持良好的生活习惯！')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center);
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#F0F7FF')
          .borderRadius(16)
          .margin({ top: 16, bottom: 48 });

          // 重新评估按钮
          Button('开始新的评估')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(24)
            .onClick(() => {
              router.push({ url: 'pages/RiskAssessmentPage' });
            });
        }
        .width('85%')
        .padding({ top: 24, bottom: 48 });
      }
      .height(0)
      .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
