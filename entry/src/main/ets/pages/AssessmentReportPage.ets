import { RiskAssessmentResult } from '../ai/RiskAssessmentEngine';
import { ReportGenerator, GeneratedReport } from '../ai/ReportGenerator';
import { RadarChart } from './RadarChart';
import { GaugeChart } from './GaugeChart';
import { RiskCard } from './RiskCard';
import { SuggestionsList } from './SuggestionsList';

@Entry
@Component
struct AssessmentReportPage {
  @State assessmentResult: RiskAssessmentResult | null = null;
  @State generatedReport: GeneratedReport | null = null;
  @State isGenerating: boolean = false;
  @State showRawText: boolean = false;

  aboutToAppear(): void {
    console.log('[AssessmentReportPage] 页面加载完成');
    this.loadAssessmentData();
  }

  private async loadAssessmentData(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, Object>;
      
      if (params && params['result']) {
        const resultStr = params['result'] as string;
        this.assessmentResult = JSON.parse(resultStr);
        
        console.log('[AssessmentReportPage] 从路由参数加载评估结果成功');
      } else {
        console.log('[AssessmentReportPage] 未找到路由参数，尝试从Mock加载');
        
        const mockModule = await import('../mock/riskAssessmentMock');
        
        if (mockModule && mockModule.riskMockData) {
          this.assessmentResult = mockModule.riskMockData.getSampleAssessmentResult();
          console.log('[AssessmentReportPage] Mock数据加载成功');
        }
      }

      if (this.assessmentResult) {
        this.generateFullReport();
      }
    } catch (error) {
      console.error('[AssessmentReportPage] 数据加载失败:', error instanceof Error ? error.message : String(error));
    }
  }

  private generateFullReport(): void {
    if (!this.assessmentResult) return;

    console.log('[AssessmentReportPage] 开始生成完整报告...');

    try {
      this.generatedReport = ReportGenerator.generateComprehensiveReport(
        this.assessmentResult,
        undefined
      );

      console.log(`[AssessmentReportPage] 报告生成完成，共${this.generatedReport.sections.length}个章节`);
    } catch (error) {
      console.error('[AssessmentReportPage] 报告生成失败:', error instanceof Error ? error.message : String(error));
    }
  }

  build() {
    Column() {
      NavigationTitleBar({ 
        title: '📋 详细评估报告', 
        showBack: true 
      })

      if (!this.assessmentResult || !this.generatedReport) {
        this.buildEmptyView()
      } else if (this.showRawText) {
        this.buildTextView()
      } else {
        this.buildReportView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  @Builder buildEmptyView() {
    Column({ space: 20 }) {
      Text('📄')
        .fontSize(48)
      
      Text('暂无评估报告')
        .fontSize(18)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
      
      Text('请先完成AI风险评估以生成详细报告')
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

  @Builder buildReportView() {
    Column() {
      Row({ space: 10 }) {
        Button('📊 图表视图')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontColor(!this.showRawText ? '#1677FF' : '#666666')
          .backgroundColor(!this.showRawText ? '#E6F4FF' : '#F5F5F5')
          .borderRadius(20)

        Button('📝 文本视图')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontColor(this.showRawText ? '#1677FF' : '#666666')
          .backgroundColor(this.showRawText ? '#E6F4FF' : '#F5F5F5')
          .borderRadius(20)
          .onClick(() => {
            this.showRawText = true;
          })
      }
      .width('100%')

      Scroll() {
        Column({ space: 16 }) {
          this.buildReportHeader()

          this.buildScoreOverview()

          this.buildRadarSection()

          this.buildDetailedRisksSection()

          this.buildSuggestionsSection()

          this.buildActionPlanSection()

          this.buildDisclaimerSection()
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      Row({ space: 12 }) {
        Button('📤 分享报告')
          .layoutWeight(1)
          .height(46)
          .fontSize(15)
          .fontColor('#1677FF')
          .backgroundColor('#E6F4FF')
          .borderRadius(23)
          .onClick(() => this.shareReport())

        Button('💾 保存PDF')
          .layoutWeight(1)
          .height(46)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(23)
          .onClick(() => this.saveAsPDF())
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
  }

  @Builder buildTextView() {
    Column() {
      Row({ space: 10 }) {
        Button('📊 图表视图')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontColor(!this.showRawText ? '#1677FF' : '#666666')
          .backgroundColor(!this.showRawText ? '#E6F4FF' : '#F5F5F5')
          .borderRadius(20)
          .onClick(() => {
            this.showRawText = false;
          })

        Button('📝 文本视图')
          .layoutWeight(1)
          .height(40)
          .fontSize(13)
          .fontColor(this.showRawText ? '#1677FF' : '#666666')
          .backgroundColor(this.showRawText ? '#E6F4FF' : '#F5F5F5')
          .borderRadius(20)
      }
      .width('100%')

      Scroll() {
        Text(this.getFormattedReportText())
          .fontSize(12)
          .fontColor('#333333')
          .lineHeight(18)
          .textAlign(TextAlign.Start)
          .padding(16)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      Button('← 返回图表视图')
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor('#666666')
        .backgroundColor('#F5F5F5')
        .borderRadius(22)
        .margin(16)
        .onClick(() => {
          this.showRawText = false;
        })
    }
    .width('100%')
  }

  @Builder buildReportHeader() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Text('🏥')
          .fontSize(36)
        
        Column({ space: 4 }) {
          Text(this.generatedReport?.title || 'AI健康风险评估报告')
            .fontSize(18)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Bold)
          
          Text(`生成时间：${new Date(this.generatedReport?.generatedAt || '').toLocaleString('zh-CN')}`)
            .fontSize(12)
            .fontColor('#999999')
          
          Text(`报告编号：${this.generatedReport?.id || '-'}`)
            .fontSize(11)
            .fontColor('#BBBBBB')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Text(this.generatedReport?.summary || '')
        .fontSize(14)
        .fontColor('#555555')
        .lineHeight(20)
        .textAlign(TextAlign.Justify)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder buildScoreOverview() {
    Column({ space: 12 }) {
      Text('🎯 综合风险评分')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Row({ space: 16 }) {
        GaugeChart({
          value: this.assessmentResult?.overallScore || 0,
          size: 180,
          showLabel: true
        })

        Column({ space: 10 }) {
          ForEach([
            { label: '评估方法', value: this.getMethodLabel(), icon: '⚡' },
            { label: '置信度', value: `${((this.assessmentResult?.confidence || 0) * 100).toFixed(0)}%`, icon: '✅' },
            { label: '处理耗时', value: `${this.assessmentResult?.processingTimeMs || 0}ms`, icon: '⏱️' },
            { label: '模型版本', value: this.assessmentResult?.modelVersion || '-', icon: '🤖' }
          ], (item: Object) => {
            const info = item as { label: string; value: string; icon: string };
            
            Row({ space: 8 }) {
              Text(info.icon)
                .fontSize(16)
              
              Column({ space: 2 }) {
                Text(info.label)
                  .fontSize(11)
                  .fontColor('#999999')
                
                Text(info.value)
                  .fontSize(13)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  private getMethodLabel(): string {
    switch (this.assessmentResult?.assessmentMethod) {
      case 'AI_MODEL': return 'AI深度学习模型';
      case 'RULE_BASED': return '医学指南规则引擎';
      default: return this.assessmentResult?.assessmentMethod || '-';
    }
  }

  @Builder buildRadarSection() {
    Column({ space: 12 }) {
      Text('📈 五维风险雷达图')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      RadarChart({
        data: [
          { label: '高血压', value: this.assessmentResult?.risks.hypertension.probability || 0, color: '#FF4D4F' },
          { label: '糖尿病', value: this.assessmentResult?.risks.diabetes.probability || 0, color: '#FAAD14' },
          { label: '跌倒风险', value: this.assessmentResult?.risks.fall.probability || 0, color: '#FF7875' },
          { label: '衰弱综合征', value: this.assessmentResult?.risks.frailty.probability || 0, color: '#FFA39E' },
          { label: '肌少症', value: this.assessmentResult?.risks.sarcopenia.probability || 0, color: '#FFCCC7' }
        ],
        size: 260,
        showValue: true,
        animated: true
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildDetailedRisksSection() {
    Column({ space: 12 }) {
      Text('🔍 各维度详细分析')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      if (this.assessmentResult) {
        RiskCard({ risk: this.assessmentResult.risks.hypertension })
        RiskCard({ risk: this.assessmentResult.risks.diabetes })
        RiskCard({ risk: this.assessmentResult.risks.fall })
        RiskCard({ risk: this.assessmentResult.risks.frailty })
        RiskCard({ risk: this.assessmentResult.risks.sarcopenia })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildSuggestionsSection() {
    Column({ space: 12 }) {
      Text('💡 个性化健康建议')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      SuggestionsList({
        suggestions: this.assessmentResult?.suggestions || [],
        showCategory: true,
        maxItems: 10
      })
    }
    .width('100%')
  }

  @Builder buildActionPlanSection() {
    if (!this.generatedReport || !this.generatedReport.actionItems.length) {
      return;
    }

    Column({ space: 12 }) {
      Text('🎯 行动计划清单')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      ForEach(this.generatedReport.actionItems.slice(0, 6), (action: Object, index: number) => {
        const item = action as { id: string; category: string; description: string; priority: string; responsibleParty: string };
        
        Row({ space: 10 }) {
          Text((index + 1).toString())
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .width(24)
            .height(24)
            .borderRadius(12)
            .textAlign(TextAlign.Center)
            .backgroundColor(
              item.priority === 'IMMEDIATE' ? '#FF4D4F' :
              item.priority === 'SOON' ? '#FAAD14' : '#52C41A'
            )

          Column({ space: 4 }) {
            Text(item.description)
              .fontSize(14)
              .fontColor('#333333')
              .lineHeight(19)
            
            Row({ space: 8 }) {
              Text(item.category)
                .fontSize(11)
                .fontColor('#1677FF')
                .backgroundColor('#E6F4FF')
                .padding({ horizontal: 6, vertical: 2 })
                .borderRadius(8)
              
              Text(item.responsibleParty)
                .fontSize(11)
                .fontColor('#999999')
            }
          }
          .alignItems(HorizontalAlign.Start)
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

  @Builder buildDisclaimerSection() {
    Column({ space: 8 }) {
      Text('⚠️ 重要声明')
        .fontSize(13)
        .fontColor('#FF4D4F')
        .fontWeight(FontWeight.Medium)

      Text('本报告由AI辅助生成，基于您提供的健康数据和医学指南规则。报告内容仅供参考，不能替代专业医疗诊断和建议。如有任何健康问题，请及时咨询专业医生。')
        .fontSize(12)
        .fontColor('#999999')
        .lineHeight(18)
        .textAlign(TextAlign.Justify)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFBE6')
    .borderRadius(8)
  }

  private getFormattedReportText(): string {
    if (!this.generatedReport) return '';

    return ReportGenerator.formatReportForDisplay(this.generatedReport);
  }

  private shareReport(): void {
    AlertDialog.show({
      title: '分享报告',
      message: '是否将此评估报告分享给医生或家人？',
      primaryText: '确认分享',
      secondaryText: '取消',
      onPrimaryClick: () => {
        console.log('[AssessmentReportPage] 用户确认分享报告');
      }
    });
  }

  private saveAsPDF(): void {
    AlertDialog.show({
      title: '保存为PDF',
      message: '正在准备PDF文件...',
      primaryText: '确定'
    });

    console.log('[AssessmentReportPage] 用户请求保存PDF');
  }
}

@Component
struct NavigationTitleBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;

  build() {
    Row() {
      if (this.showBack) {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      if (this.showBack) {
        Text('')
          .width(24)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
