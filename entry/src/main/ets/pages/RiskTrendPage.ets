import { RiskAssessmentResult, RisksMap } from '../ai/RiskAssessmentEngine';
import { OverallTrend, TrendAnalyzer, TrendAnalysis } from '../ai/TrendAnalyzer';
import { RadarChart, RadarDataItem } from '../components/RadarChart';
import { NavigationTitleBar } from '../components/NavigationTitleBar';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct RiskTrendPage {
  @State isLoading: boolean = true;
  @State trendData: OverallTrend | null = null;
  @State selectedDisease: string | null = null;
  @State showDetailModal: boolean = false;

  private historyResults: RiskAssessmentResult[] = [];

  aboutToAppear(): void {
    console.log('[RiskTrendPage] 页面加载完成');
    this.loadHistoricalData();
  }

  private async loadHistoricalData(): Promise<void> {
    this.isLoading = true;

    try {
      const mockModule = await import('../mock/riskAssessmentMock');
      
      if (mockModule && mockModule.riskMockData) {
        this.historyResults = mockModule.riskMockData.getHistoricalAssessments();
        
        console.log(`[RiskTrendPage] 历史数据加载成功，共${this.historyResults.length}条记录`);
      }
    } catch (error) {
      console.warn('[RiskTrendPage] Mock数据加载失败:', error);
      
      this.historyResults = this.generateFallbackHistory();
    }

    if (this.historyResults.length >= 2) {
      const currentResult = this.historyResults[this.historyResults.length - 1];
      this.trendData = TrendAnalyzer.analyzeTrend(
        this.historyResults.slice(0, -1),
        currentResult
      );
      
      console.log('[RiskTrendPage] 趋势分析完成');
    }

    this.isLoading = false;
  }

  private generateFallbackHistory(): RiskAssessmentResult[] {
    const baseTime = Date.now();
    
    return [
      this.createMockResult(baseTime - 90 * 24 * 60 * 60 * 1000, 0.45),
      this.createMockResult(baseTime - 60 * 24 * 60 * 60 * 1000, 0.48),
      this.createMockResult(baseTime - 30 * 24 * 60 * 60 * 1000, 0.52)
    ];
  }

  private createMockResult(timestamp: number, overallScore: number): RiskAssessmentResult {
    const result: RiskAssessmentResult = {
      assessmentId: `ASSESS_${timestamp}`,
      timestamp: new Date(timestamp).toISOString(),
      assessmentMethod: 'RULE_BASED',
      modelVersion: 'v2.0',
      processingTimeMs: Math.floor(Math.random() * 50) + 20,
      confidence: 0.85 + Math.random() * 0.12,
      overallScore: overallScore,
      overallLevel: overallScore < 0.35 ? 'LOW' : 
                  overallScore < 0.55 ? 'MEDIUM' : 
                  overallScore < 0.75 ? 'HIGH' : 'CRITICAL',
      risks: {
        hypertension: {
          disease: 'hypertension',
          label: '高血压',
          probability: 0.3 + Math.random() * 0.4,
          level: 'MEDIUM',
          color: '#FF4D4F',
          factors: ['血压偏高'],
          evidence: '基于历史数据模拟'
        },
        diabetes: {
          disease: 'diabetes',
          label: '糖尿病',
          probability: 0.25 + Math.random() * 0.3,
          level: 'MEDIUM',
          color: '#FAAD14',
          factors: ['血糖波动'],
          evidence: '基于历史数据模拟'
        },
        fall: {
          disease: 'fall',
          label: '跌倒风险',
          probability: 0.35 + Math.random() * 0.3,
          level: 'MEDIUM',
          color: '#FF7875',
          factors: ['平衡能力下降'],
          evidence: '基于历史数据模拟'
        },
        frailty: {
          disease: 'frailty',
          label: '衰弱综合征',
          probability: 0.4 + Math.random() * 0.3,
          level: 'HIGH',
          color: '#FFA39E',
          factors: ['体重减轻', '握力下降'],
          evidence: '基于历史数据模拟'
        },
        sarcopenia: {
          disease: 'sarcopenia',
          label: '肌少症',
          probability: 0.35 + Math.random() * 0.25,
          level: 'MEDIUM',
          color: '#FFCCC7',
          factors: ['步速减慢'],
          evidence: '基于历史数据模拟'
        }
      } as RisksMap,
      suggestions: [],
      featureInterpretations: []
    };
    return result;
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '📊 风险趋势分析', 
        showBack: true 
      })

      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.trendData || this.trendData.diseaseTrends.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildTrendView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildLoadingView() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(60)
        .height(60)
        .color('#1677FF')
      
      Text('正在分析健康趋势...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildEmptyView() {
    Column({ space: 20 }) {
      Text('📈')
        .fontSize(48)
      
      Text('暂无足够的历史数据')
        .fontSize(18)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
      
      Text('至少需要2次评估记录才能进行趋势分析')
        .fontSize(14)
        .fontColor('#999999')

      Button('去评估')
        .width(160)
        .height(44)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(22)
        .margin({ top: 20 })
        .onClick(() => {
          router.replaceUrl({
            url: 'pages/RiskAssessmentPage'
          });
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildTrendView() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildOverviewCard()

        this.buildOverallTrendChart()

        this.buildDiseaseTrendCards()

        this.buildKeyFindingsSection()

        this.buildRecommendationsSection()
      }
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildOverviewCard() {
    Column({ space: 14 }) {
      Row({ space: 10 }) {
        Text('📊')
          .fontSize(32)
        
        Column({ space: 4 }) {
          Text('健康风险趋势概览')
            .fontSize(19)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
          
          Text(`基于近 ${this.trendData!.assessmentCount} 次评估记录，跨度 ${this.trendData!.timeSpanDays} 天`)
            .fontSize(13)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Row({ space: 12 }) {
        this.buildStatItem(
          '总体趋势',
          this.getTrendIcon(this.trendData!.overallTrend),
          this.getTrendLabel(this.trendData!.overallTrend)
        )
        
        this.buildStatItem(
          '变化率',
          '',
          `${this.trendData!.overallChangeRate > 0 ? '+' : ''}${(this.trendData!.overallChangeRate * 100).toFixed(1)}%`
        )
        
        this.buildStatItem(
          '评估次数',
          '',
          `${this.trendData!.assessmentCount}次`
        )

        this.buildStatItem(
          '时间跨度',
          '',
          `${this.trendData!.timeSpanDays}天`
        )
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 6,
      color: 'rgba(22,119,255,0.08)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder buildStatItem(label: string, icon: string, value: string) {
    Column({ space: 4 }) {
      if (icon) {
        Text(icon)
          .fontSize(20)
      }
      
      Text(value)
        .fontSize(15)
        .fontColor(
          this.trendData?.overallTrend === 'IMPROVING' ? '#52C41A' :
          this.trendData?.overallTrend === 'WORSENING' ? '#FF4D4F' : '#FAAD14'
        )
        .fontWeight(FontWeight.Bold)
      
      Text(label)
        .fontSize(11)
        .fontColor('#999999')
    }
    .flexGrow(1)
    .padding(8)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
  }

  @Builder buildOverallTrendChart() {
    Column({ space: 12 }) {
      Text('📈 综合趋势对比图')
        .fontSize(16)
        fontColor('#333333')
        fontWeight(FontWeight.Bold)

      if (this.trendData && this.trendData.diseaseTrends.length > 0) {
        RadarChart({
          data: this.trendData.diseaseTrends.map(trend => ({
            label: trend.label,
            value: trend.currentScore,
            color: this.getDiseaseColor(trend.disease)
          } as RadarDataItem)),
          size: 280,
          showValue: true,
          animated: true
        })
      }

      Text(`五边形展示当前各项风险值，面积越大表示综合风险越高`)
        .fontSize(11)
        .fontColor('#BBBBBB')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildDiseaseTrendCards() {
    Column({ space: 12 }) {
      Text('🔍 各维度变化详情')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach(this.trendData?.diseaseTrends || [], (trend: Object) => {
        const t = trend as TrendAnalysis;
        
        this.buildDiseaseTrendCard(t)
      })
    }
    .width('100%')
  }

  @Builder buildDiseaseTrendCard(trend: TrendAnalysis) {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        Text(this.getDiseaseIcon(trend.disease))
          .fontSize(26)
        
        Column({ space: 4 }) {
          Row({ space: 8 }) {
            Text(trend.label)
              .fontSize(17)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
            
            Text(this.getTrendArrow(trend.trendDirection))
              .fontSize(18)
            
            Blank()
            
            Text(`${Math.round(trend.currentScore * 100)}%`)
              .fontSize(24)
              .fontColor(this.getDiseaseColor(trend.disease))
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')

          Text(trend.trendDescription)
            .fontSize(13)
            .fontColor('#666666')
            .lineHeight(18)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Row({ space: 8 }) {
        Text(`上次: ${trend.previousScore !== undefined ? Math.round(trend.previousScore * 100) + '%' : '-'}`)
          .fontSize(12)
          .fontColor('#999999')
        
        Text('|')
          .fontSize(12)
          .fontColor('#DDDDDD')
        
        Text(`变化: ${trend.changeRate > 0 ? '+' : ''}${(trend.changeRate * 100).toFixed(1)}%`)
          .fontSize(12)
          .fontColor(
            trend.changeRate < -0.05 ? '#52C41A' :
            trend.changeRate > 0.05 ? '#FF4D4F' : '#999999'
          )
        
        Text('|')
          .fontSize(12)
          .fontColor('#DDDDDD')
        
        Text(`波动性: ${(trend.volatility * 100).toFixed(1)}`)
          .fontSize(12)
          .fontColor(trend.volatility > 0.12 ? '#FAAD14' : '#52C41A')
      }
      .width('100%')

      if (trend.prediction) {
        Row({ space: 8 }) {
          Text('🎯 预测下月:')
            .fontSize(13)
            .fontColor('#666666')
          
          Text(`${Math.round(trend.prediction.nextMonthScore * 100)}%`)
            .fontSize(15)
            .fontColor(
              trend.prediction.riskLevel === 'CRITICAL' ? '#CF1322' :
              trend.prediction.riskLevel === 'HIGH' ? '#FF4D4F' :
              trend.prediction.riskLevel === 'MEDIUM' ? '#FAAD14' : '#52C41A'
            )
            .fontWeight(FontWeight.Bold)
          
          Text(`(${(trend.prediction.confidence * 100).toFixed(0)}%置信度)`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FFFBE6')
        .borderRadius(8)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({
      width: 1,
      color: trend.trendDirection === 'WORSENING' ? `${this.getDiseaseColor(trend.disease)}30` : 
             trend.trendDirection === 'IMPROVING' ? `#52C41A20` : 'transparent'
    })
    .onClick(() => {
      this.selectedDisease = trend.disease;
      this.showDetailModal = true;
    })
  }

  @Builder buildKeyFindingsSection() {
    if (!this.trendData || !this.trendData.keyFindings.length) {
      return;
    }

    Column({ space: 12 }) {
      Text('💡 关键发现')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach(this.trendData.keyFindings, (finding: string, index: number) => {
        Row({ space: 10 }) {
          Text((index + 1).toString())
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .width(22)
            .height(22)
            .borderRadius(11)
            .textAlign(TextAlign.Center)
            .backgroundColor('#1677FF')
          
          Text(finding)
            .fontSize(14)
            .fontColor('#333333')
            .lineHeight(20)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(index % 2 === 0 ? '#FAFAFA' : '#FFFFFF')
        .borderRadius(8)
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildRecommendationsSection() {
    if (!this.trendData || !this.trendData.recommendations.length) {
      return;
    }

    Column({ space: 12 }) {
      Text('📝 改进建议')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach(this.trendData.recommendations.slice(0, 5), (rec: string, index: number) => {
        Row({ space: 10 }) {
          Text('✅')
            .fontSize(16)
          
          Text(rec)
            .fontSize(14)
            .fontColor('#555555')
            .lineHeight(19)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(index % 2 === 0 ? '#F6FFED' : '#FFFFFF')
        .borderRadius(8)
      })

      Button('查看完整报告')
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor('#1677FF')
        .backgroundColor('#E6F4FF')
        .borderRadius(22)
        .margin({ top: 8 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/AssessmentReportPage'
          });
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  private getTrendIcon(direction: string): string {
    switch (direction) {
      case 'IMPROVING': return '✅';
      case 'WORSENING': return '⚠️';
      case 'STABLE': return '➡️';
      default: return '❓';
    }
  }

  private getTrendLabel(direction: string): string {
    switch (direction) {
      case 'IMPROVING': return '改善';
      case 'WORSENING': return '恶化';
      case 'STABLE': return '稳定';
      default: return direction;
    }
  }

  private getTrendArrow(direction: string): string {
    switch (direction) {
      case 'IMPROVING': return '↓ 改善';
      case 'WORSENING': return '↑ 恶化';
      case 'STABLE': return '→ 稳定';
      default: return '';
    }
  }

  private getDiseaseIcon(disease: string): string {
    const diseaseIcons = new Map<string, string>([
      ['hypertension', '💓'],
      ['diabetes', '🩸'],
      ['fall', '⚠️'],
      ['frailty', '👴'],
      ['sarcopenia', '💪']
    ]);
    return diseaseIcons.get(disease) ?? '📊';
  }

  private getDiseaseColor(disease: string): string {
    const diseaseColors = new Map<string, string>([
      ['hypertension', '#FF4D4F'],
      ['diabetes', '#FAAD14'],
      ['fall', '#FF7875'],
      ['frailty', '#FFA39E'],
      ['sarcopenia', '#FFCCC7']
    ]);
    return diseaseColors.get(disease) ?? '#999999';
  }
}


