import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { RISK_INDICATORS, HEALTH_SCORE, SCORE_LEVEL, SCORE_LEVEL_COLOR } from '../mock/riskMock';
import { GlobalTheme } from '../global';

interface RiskItem {
  id: string;
  name: string;
  value: number;
  unit: string;
  normalRange: string;
  status: string;
  icon: string;
  color: string;
  level: string;
  levelColor: string;
  progress: number;
  description: string;
}

@Entry
@Component
struct RiskAssessmentPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State riskItems: RiskItem[] = [
    { id: '1', name: '血压', value: 145, unit: 'mmHg', normalRange: '90-140', status: 'warning', icon: '🩺', color: '#1677FF', level: '中', levelColor: '#FAAD14', progress: 72, description: '血压偏高，建议定期监测' },
    { id: '2', name: '血糖', value: 7.8, unit: 'mmol/L', normalRange: '3.9-6.1', status: 'danger', icon: '💉', color: '#FF4D4F', level: '高', levelColor: '#FF4D4F', progress: 85, description: '血糖偏高，需注意饮食控制' },
    { id: '3', name: '心率', value: 88, unit: '次/分', normalRange: '60-100', status: 'normal', icon: '❤️', color: '#52C41A', level: '低', levelColor: '#52C41A', progress: 35, description: '心率正常范围' },
    { id: '4', name: 'BMI', value: 26.5, unit: 'kg/m²', normalRange: '18.5-24', status: 'warning', icon: '⚖️', color: '#FAAD14', level: '中', levelColor: '#FAAD14', progress: 65, description: 'BMI超标，建议控制体重' },
    { id: '5', name: '骨密度', value: -1.8, unit: 'T值', normalRange: '-1~+1', status: 'warning', icon: '🦴', color: '#FA8C16', level: '中', levelColor: '#FA8C16', progress: 68, description: '骨密度偏低，注意补钙' },
    { id: '6', name: '血氧饱和度', value: 96, unit: '%', normalRange: '95-100', status: 'normal', icon: '🫁', color: '#13C2C2', level: '低', levelColor: '#52C41A', progress: 28, description: '血氧正常' },
    { id: '7', name: '总胆固醇', value: 5.8, unit: 'mmol/L', normalRange: '<5.18', status: 'warning', icon: '🧪', color: '#722ED1', level: '中', levelColor: '#FAAD14', progress: 62, description: '胆固醇略高，需低脂饮食' },
    { id: '8', name: '睡眠质量评分', value: 62, unit: '分', normalRange: '>70', status: 'danger', icon: '😴', color: '#EB2F96', level: '高', levelColor: '#FF4D4F', progress: 78, description: '睡眠质量差，建议改善作息' }
  ];
  @State score: number = HEALTH_SCORE;
  @State scoreLevel: string = SCORE_LEVEL;
  @State scoreLevelColor: string = SCORE_LEVEL_COLOR;
  @State showReportToast: boolean = false;

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') ?? false;
    }
  }

  getLevelBgColor(levelColor: string): string {
    if (levelColor === GlobalTheme.SUCCESS_COLOR) {
      return '#F6FFED';
    }
    if (levelColor === GlobalTheme.WARNING_COLOR) {
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
        Column({ space: GlobalTheme.getSpacingLG(this.isElderMode) }) {
          Column({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
            Text('综合健康评分')
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight('bold')
              .fontColor(GlobalTheme.THEME_COLOR);

            Stack({ alignContent: Alignment.Center }) {
              Progress({
                value: this.score,
                total: 100,
                type: ProgressType.Ring
              })
                .width(180)
                .height(180)
                .color(GlobalTheme.THEME_COLOR)
                .backgroundColor(GlobalTheme.BORDER_COLOR)
                .style({ strokeWidth: 12 });

              Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
                Text(this.score.toString())
                  .fontSize(this.isElderMode ? 56 : 48)
                  .fontWeight('bold')
                  .fontColor(GlobalTheme.THEME_COLOR);

                Text(this.scoreLevel)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor(this.scoreLevelColor)
                  .fontWeight('bold');
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);
            }
            .width(200)
            .height(200);

            Text('基于您的健康记录数据综合评估')
              .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_HINT);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingLG(this.isElderMode))
          .backgroundColor(GlobalTheme.CARD_BG)
          .borderRadius(GlobalTheme.RADIUS_LG)
          .alignItems(HorizontalAlign.Center);

          Column({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
            Row() {
              Text('风险指标详情')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight('bold')
                .fontColor(GlobalTheme.TEXT_PRIMARY);

              Blank();

              Text(this.riskItems.length + ' 项指标')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT)
                .backgroundColor('#F5F5F5')
                .padding({ left: GlobalTheme.getSpacingSM(this.isElderMode), right: GlobalTheme.getSpacingSM(this.isElderMode), top: GlobalTheme.getSpacingXS(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) })
                .borderRadius(GlobalTheme.RADIUS_MD);
            }
            .width('100%');

            List({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
              ForEach(this.riskItems, (item: RiskItem) => {
                ListItem() {
                  Column({ space: GlobalTheme.getSpacingSM(this.isElderMode) }) {
                    Row({ space: GlobalTheme.getSpacingMD(this.isElderMode) }) {
                      Text(item.icon)
                        .fontSize(this.isElderMode ? 32 : 28);

                      Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
                        Text(item.name)
                          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                          .fontWeight('bold')
                          .fontColor(GlobalTheme.TEXT_PRIMARY);

                        Text(item.description)
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.TEXT_SECONDARY)
                          .maxLines(2);
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start);

                      Column() {
                        Text(item.level + '风险')
                          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                          .fontWeight('bold')
                          .fontColor(item.levelColor);
                      }
                      .padding({ left: GlobalTheme.getSpacingSM(this.isElderMode), right: GlobalTheme.getSpacingSM(this.isElderMode), top: GlobalTheme.getSpacingXS(this.isElderMode), bottom: GlobalTheme.getSpacingXS(this.isElderMode) })
                      .backgroundColor(this.getLevelBgColor(item.levelColor))
                      .borderRadius(GlobalTheme.RADIUS_SM);
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top);

                    Column({ space: GlobalTheme.getSpacingXS(this.isElderMode) }) {
                      Row() {
                        Text('风险程度')
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                          .fontColor(GlobalTheme.TEXT_SECONDARY);

                        Blank();

                        Text(item.progress + '%')
                          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
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
                        .backgroundColor(GlobalTheme.BORDER_COLOR)
                        .borderRadius(GlobalTheme.RADIUS_SM);
                    }
                    .width('100%');
                  }
                  .width('100%')
                  .padding(GlobalTheme.getSpacingMD(this.isElderMode))
                  .backgroundColor(GlobalTheme.CARD_BG)
                  .borderRadius(GlobalTheme.RADIUS_MD)
                  .border({ width: 1, color: GlobalTheme.BORDER_COLOR });
                }
              }, (item: RiskItem) => item.id);
            }
            .width('100%')
            .layoutWeight(1);
          }
          .width('100%')
          .padding(GlobalTheme.getSpacingMD(this.isElderMode))
          .backgroundColor(GlobalTheme.CARD_BG)
          .borderRadius(GlobalTheme.RADIUS_LG);

          Button('📋 生成完整报告')
            .width('100%')
            .height(GlobalTheme.getButtonHeight(this.isElderMode))
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontColor('#FFFFFF')
            .backgroundColor(GlobalTheme.THEME_COLOR)
            .borderRadius(GlobalTheme.RADIUS_LG)
            .onClick(() => this.handleGenerateReport());

          if (this.showReportToast) {
            Text('✅ 报告生成成功！')
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.SUCCESS_COLOR)
              .backgroundColor('#F6FFED')
              .padding({ left: GlobalTheme.getSpacingLG(this.isElderMode), right: GlobalTheme.getSpacingLG(this.isElderMode), top: GlobalTheme.getSpacingSM(this.isElderMode), bottom: GlobalTheme.getSpacingSM(this.isElderMode) })
              .borderRadius(GlobalTheme.RADIUS_LG)
              .border({ width: 1, color: '#B7EB8F' })
              .margin({ top: GlobalTheme.getSpacingSM(this.isElderMode) });
          }
        }
        .width('85%')
        .padding({ top: GlobalTheme.getSpacingLG(this.isElderMode), bottom: GlobalTheme.getSpacingLG(this.isElderMode) * 2 });
      }
      .flexGrow(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR);
  }
}
