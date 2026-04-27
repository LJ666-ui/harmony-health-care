import { AccessibilityConfig } from '../utils/AccessibilityConfig';

export interface HealthOverviewData {
  healthScore: number;
  riskLevel: string;
  riskColor: string;
  rehabProgress: number;
  lastAssessmentDate?: string;
}

@Component
export struct HealthOverviewCard {
  @Prop overviewData: HealthOverviewData = {
    healthScore: 85,
    riskLevel: '低风险',
    riskColor: '#4CAF50',
    rehabProgress: 67,
    lastAssessmentDate: '2026-04-15'
  };
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  build() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('❤️')
          .fontSize(this.isElderMode ? 20 : 16)

        Text('今日健康概览')
          .fontSize(this.isElderMode ? 18 : 15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Text(`上次评估: ${this.overviewData.lastAssessmentDate || '未评估'}`)
          .fontSize(this.isElderMode ? 12 : 10)
          .fontColor('#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 12 }) {
        this.buildScoreCard()
        this.buildRiskCard()
        this.buildRehabCard()
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder buildScoreCard() {
    Column({ space: 6 }) {
      Text('健康分')
        .fontSize(this.isElderMode ? 13 : 11)
        .fontColor('#666666')

      Text(`${this.overviewData.healthScore}`)
        .fontSize(this.isElderMode ? 28 : 24)
        .fontWeight(FontWeight.Bold)
        .fontColor(AccessibilityConfig.getThemeColor())

      Text('良好')
        .fontSize(this.isElderMode ? 11 : 9)
        .fontColor('#4CAF50')
        .backgroundColor('#4CAF5020')
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .borderRadius(10)
    }
    .layoutWeight(1)
    .height(100)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FAFAFA')
    .borderRadius(10)
  }

  @Builder buildRiskCard() {
    Column({ space: 6 }) {
      Text('风险等级')
        .fontSize(this.isElderMode ? 13 : 11)
        .fontColor('#666666')

      Text(this.overviewData.riskLevel)
        .fontSize(this.isElderMode ? 18 : 15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.overviewData.riskColor)

      Row({ space: 4 }) {
        ForEach([1, 2, 3, 4, 5], (_riskItem: number, index: number) => {
          Column()
            .width(16)
            .height(4)
            .backgroundColor(index < 2 ? this.overviewData.riskColor : '#E0E0E0')
            .borderRadius(2)
        })
      }
    }
    .layoutWeight(1)
    .height(100)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FAFAFA')
    .borderRadius(10)
  }

  @Builder buildRehabCard() {
    Column({ space: 6 }) {
      Text('康复进度')
        .fontSize(this.isElderMode ? 13 : 11)
        .fontColor('#666666')

      Text(`${this.overviewData.rehabProgress}%`)
        .fontSize(this.isElderMode ? 28 : 24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2196F3')

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(4)
          .backgroundColor('#E0E0E0')
          .borderRadius(2)

        Row()
          .width(`${this.overviewData.rehabProgress}%`)
          .height(4)
          .backgroundColor('#2196F3')
          .borderRadius(2)
      }
      .width('100%')
    }
    .layoutWeight(1)
    .height(100)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FAFAFA')
    .borderRadius(10)
  }
}
