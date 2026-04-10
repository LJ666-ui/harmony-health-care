import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { RISK_INDICATORS, HEALTH_SCORE, SCORE_LEVEL, SCORE_LEVEL_COLOR } from '../mock/riskMock';

interface RiskItem {
  id: string;
  name: string;
  icon: string;
  level: string;
  levelColor: string;
  progress: number;
  description: string;
}

@Entry
@Component
struct RiskAssessmentPage {
  @State riskItems: RiskItem[] = RISK_INDICATORS as RiskItem[];
  @State score: number = HEALTH_SCORE;
  @State scoreLevel: string = SCORE_LEVEL;
  @State scoreLevelColor: string = SCORE_LEVEL_COLOR;
  @State showReportToast: boolean = false;

  getLevelBgColor(levelColor: string): string {
    if (levelColor === '#52C41A') {
      return '#F6FFED';
    }
    if (levelColor === '#FAAD14') {
      return '#FFFBE6';
    }
    return '#FFF1F0';
  }

  handleGenerateReport(): void {
    this.showReportToast = true;
    setTimeout(() => {
      this.showReportToast = false;
    }, 2000);
  }

  build() {
    Column() {
      Header({ title: '健康风险评估', showBack: true });

      Scroll() {
        Column({ space: 20 }) {
          Column({ space: 16 }) {
            Text('综合健康评分')
              .fontSize(22)
              .fontWeight('bold')
              .fontColor('#1677FF');

            Stack({ alignContent: Alignment.Center }) {
              Progress({
                value: this.score,
                total: 100,
                type: ProgressType.Ring
              })
                .width(180)
                .height(180)
                .color('#1677FF')
                .backgroundColor('#F0F0F0')
                .style({ strokeWidth: 12 });

              Column({ space: 4 }) {
                Text(this.score.toString())
                  .fontSize(48)
                  .fontWeight('bold')
                  .fontColor('#1677FF');

                Text(this.scoreLevel)
                  .fontSize(18)
                  .fontColor(this.scoreLevelColor)
                  .fontWeight('bold');
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);
            }
            .width(200)
            .height(200);

            Text('基于您的健康记录数据综合评估')
              .fontSize(13)
              .fontColor('#999999');
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Center);

          Column({ space: 12 }) {
            Row() {
              Text('风险指标详情')
                .fontSize(20)
                .fontWeight('bold')
                .fontColor('#333333');

              Blank();

              Text(this.riskItems.length + ' 项指标')
                .fontSize(13)
                .fontColor('#999999')
                .backgroundColor('#F5F5F5')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .borderRadius(10);
            }
            .width('100%');

            List({ space: 12 }) {
              ForEach(this.riskItems, (item: RiskItem) => {
                ListItem() {
                  Column({ space: 12 }) {
                    Row({ space: 12 }) {
                      Text(item.icon)
                        .fontSize(28);

                      Column({ space: 4 }) {
                        Text(item.name)
                          .fontSize(16)
                          .fontWeight('bold')
                          .fontColor('#333333');

                        Text(item.description)
                          .fontSize(12)
                          .fontColor('#888888')
                          .maxLines(2);
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start);

                      Column() {
                        Text(item.level + '风险')
                          .fontSize(13)
                          .fontWeight('bold')
                          .fontColor(item.levelColor);
                      }
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .backgroundColor(this.getLevelBgColor(item.levelColor))
                      .borderRadius(8);
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top);

                    Column({ space: 8 }) {
                      Row() {
                        Text('风险程度')
                          .fontSize(12)
                          .fontColor('#666666');

                        Blank();

                        Text(item.progress + '%')
                          .fontSize(12)
                          .fontColor(item.levelColor)
                          .fontWeight('bold');
                      }
                      .width('100%');

                      Progress({
                        value: item.progress,
                        total: 100,
                        type: ProgressType.Linear
                      })
                        .width('100%')
                        .height(8)
                        .color(item.levelColor)
                        .backgroundColor('#F0F0F0')
                        .borderRadius(4);
                    }
                    .width('100%');
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .border({ width: 1, color: '#F0F0F0' });
                }
              }, (item: RiskItem) => item.id);
            }
            .width('100%')
            .layoutWeight(1);
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16);

          Button('📋 生成完整报告')
            .width('100%')
            .height(52)
            .fontSize(17)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .borderRadius(26)
            .onClick(() => this.handleGenerateReport());

          if (this.showReportToast) {
            Text('✅ 报告生成成功！')
              .fontSize(15)
              .fontColor('#52C41A')
              .backgroundColor('#F6FFED')
              .padding({ left: 24, right: 24, top: 12, bottom: 12 })
              .borderRadius(25)
              .border({ width: 1, color: '#B7EB8F' })
              .margin({ top: 8 });
          }
        }
        .width('85%')
        .padding({ top: 20, bottom: 40 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}
