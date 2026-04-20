import { HealthData } from '../ai/HealthFeatureExtractor';
import { RiskAssessmentEngine, RiskAssessmentResult } from '../ai/RiskAssessmentEngine';
import { RadarChart } from '../components/RadarChart';
import { GaugeChart } from '../components/GaugeChart';
import { RiskCard } from '../components/RiskCard';
import { SuggestionsList } from '../components/SuggestionsList';

export interface DiseaseInfo {
  name: string;
  icon: string;
  desc: string;
}

@Entry
@Component
struct RiskAssessmentPage {
  @State isLoading: boolean = false;
  @State isAssessing: boolean = false;
  @State assessmentResult: RiskAssessmentResult | null = null;
  @State healthData: HealthData | null = null;
  @State showDetail: boolean = false;
  @State selectedDisease: string = '';

  private assessmentEngine: RiskAssessmentEngine = RiskAssessmentEngine.getInstance();

  aboutToAppear(): void {
    console.log('[RiskAssessmentPage] 页面加载完成');
    this.loadMockHealthData();
  }

  private async loadMockHealthData(): Promise<void> {
    this.isLoading = true;

    try {
      const mockModule = await import('../mock/riskAssessmentMock');
      
      if (mockModule && mockModule.riskMockData) {
        this.healthData = mockModule.riskMockData.getSampleUserHealthData();

        console.log('[RiskAssessmentPage] Mock健康数据加载成功');
        if (this.healthData) {
          console.log(`  年龄: ${this.healthData.age}`);
          console.log(`  血压: ${this.healthData.bloodPressure.systolic}/${this.healthData.bloodPressure.diastolic}`);
        }
      }
    } catch (error) {
      console.warn('[RiskAssessmentPage] Mock数据加载失败，使用默认数据:', error);
      this.healthData = this.getDefaultHealthData();
    }

    this.isLoading = false;
  }

  private getDefaultHealthData(): HealthData {
    return {
      age: 68,
      gender: 'MALE',
      bloodPressure: {
        systolic: 135,
        diastolic: 85
      },
      bloodGlucose: {
        fasting: 5.8,
        hba1c: 5.9
      },
      heartRate: {
        resting: 72
      },
      bodyMetrics: {
        height: 170,
        weight: 70,
        bmi: 24.2
      },
      functionalTests: {
        gripStrength: 30,
        gaitSpeed: 1.0,
        tandemStandTime: 18
      },
      cognitiveScores: {
        mmse: 28,
        gds: 3
      },
      nutrition: 11,
      medicationCount: 3,
      sleepData: {
        durationHours: 7,
        deepSleepRatio: 0.2
      },
      exerciseFrequency: 3
    };
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1677FF')
          .onClick(() => {
            console.log('[RiskAssessmentPage] 返回上一页');
          })
        
        Text('🤖 AI风险评估')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Text('')
          .width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.assessmentResult) {
        this.buildInputView()
      } else {
        this.buildResultView()
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
      
      Text('正在准备评估数据...')
        .fontSize(16)
        .fontColor('#666666')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder buildInputView() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildHeaderCard()

        if (this.healthData) {
          this.buildHealthOverviewCard()
        }

        this.buildStartButton()
        
        this.buildFeatureInfoCard()
      }
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildHeaderCard() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        Text('🤖')
          .fontSize(32)
        
        Column({ space: 4 }) {
          Text('AI共病风险评估系统')
            .fontSize(20)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Bold)
          
          Text('基于AI模型 + 医学指南的智能分析')
            .fontSize(13)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Row({ space: 12 }) {
        this.buildInfoBadge('⚡', '端侧推理', '本地处理，保护隐私')
        this.buildInfoBadge('🎯', '5维评估', '高血压/糖尿病/跌倒/衰弱/肌少症')
        this.buildInfoBadge('💡', '智能建议', '个性化健康指导')
      }
      .width('100%')
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

  @Builder buildInfoBadge(icon: string, title: string, desc: string) {
    Column({ space: 4 }) {
      Text(icon)
        .fontSize(24)
      
      Text(title)
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
      
      Text(desc)
        .fontSize(10)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .maxLines(2)
    }
    .flexGrow(1)
    .padding(10)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
  }

  @Builder buildHealthOverviewCard() {
    Column({ space: 14 }) {
      Text('📊 您的健康数据概览')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        this.buildDataItem('年龄', `${this.healthData!.age}岁`, '#1677FF')
        this.buildDataItem('BMI', `${this.healthData!.bodyMetrics.bmi?.toFixed(1) || '-'}`, '#52C41A')
        this.buildDataItem('血压', 
          `${this.healthData!.bloodPressure.systolic}/${this.healthData!.bloodPressure.diastolic}`, 
          '#FF4D4F')
        this.buildDataItem('血糖', `${this.healthData!.bloodGlucose.fasting}mmol/L`, '#FAAD14')
        this.buildDataItem('心率', `${this.healthData!.heartRate.resting}bpm`, '#722ED1')
        this.buildDataItem('运动', `每周${this.healthData!.exerciseFrequency}次`, '#13C2C2')
      }
      .width('100%')

      Text('💡 点击"开始评估"按钮，AI将基于您的健康数据进行全面风险分析')
        .fontSize(12)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildDataItem(label: string, value: string, color: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(15)
        .fontColor(color)
        .fontWeight(FontWeight.Bold)
      
      Text(label)
        .fontSize(11)
        .fontColor('#999999')
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor(`${color}08`)
    .borderRadius(8)
  }

  @Builder buildStartButton() {
    Button(this.isAssessing ? '⏳ 正在评估中...' : '🚀 开始AI风险评估')
      .width('100%')
      .height(56)
      .fontSize(18)
      .fontColor('#FFFFFF')
      .fontWeight(FontWeight.Bold)
      .backgroundColor(this.isAssessing ? '#95B9FF' : '#1677FF')
      .borderRadius(28)
      .shadow({
        radius: this.isAssessing ? 4 : 12,
        color: this.isAssessing ? 'rgba(22,119,255,0.2)' : 'rgba(22,119,255,0.35)',
        offsetX: 0,
        offsetY: this.isAssessing ? 2 : 6
      })
      .enabled(!this.isAssessing)
      .onClick(() => this.startAssessment())
  }

  @Builder buildFeatureInfoCard() {
    Column({ space: 12 }) {
      Text('🔬 评估维度说明')
        .fontSize(15)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      ForEach([
        { name: '高血压', icon: '💓', desc: '基于血压值、年龄、BMI等综合评估' },
        { name: '糖尿病', icon: '🩸', desc: '基于血糖、HbA1c、体重等指标' },
        { name: '跌倒风险', icon: '⚠️', desc: '基于平衡能力、步速、用药情况' },
        { name: '衰弱综合征', icon: '👴', desc: '基于Fried表型（5项标准）' },
        { name: '肌少症', icon: '💪', desc: '基于握力、步速、肌肉量' }
      ], (item: DiseaseInfo) => {
        Row({ space: 10 }) {
          Text(item.icon)
            .fontSize(22)
          
          Column({ space: 2 }) {
            Text(item.name)
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
            
            Text(item.desc)
              .fontSize(12)
              .fontColor('#999999')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildResultView() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildScoreHeader()
        
        this.buildRadarChartSection()
        
        this.buildRiskDetailsSection()
        
        this.buildSuggestionsSection()
        
        this.buildActionButtons()
      }
      .padding(16)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder buildScoreHeader() {
    Column({ space: 12 }) {
      GaugeChart({
        value: this.assessmentResult?.overallScore || 0,
        chartSize: 260,
        title: '综合风险评分'
      })
      
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('评估方法')
            .fontSize(11)
            .fontColor('#999999')
          
          Text(this.getMethodLabel(this.assessmentResult?.assessmentMethod))
            .fontSize(13)
            .fontColor('#1677FF')
            .fontWeight(FontWeight.Medium)
        }
        
        Column({ space: 4 }) {
          Text('置信度')
            .fontSize(11)
            .fontColor('#999999')
          
          Text(`${((this.assessmentResult?.confidence || 0) * 100).toFixed(0)}%`)
            .fontSize(13)
            .fontColor('#52C41A')
            .fontWeight(FontWeight.Medium)
        }
        
        Column({ space: 4 }) {
          Text('耗时')
            .fontSize(11)
            .fontColor('#999999')
          
          Text(`${this.assessmentResult?.processingTimeMs || 0}ms`)
            .fontSize(13)
            .fontColor('#666666')
            .fontWeight(FontWeight.Medium)
        }
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
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 4
    })
  }

  private getMethodLabel(method?: string): string {
    switch (method) {
      case 'AI_MODEL': return 'AI深度学习';
      case 'RULE_BASED': return '医学规则引擎';
      default: return method || '-';
    }
  }

  @Builder buildRadarChartSection() {
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
        chartSize: 280,
        showValue: true,
        animated: true
      })

      Text('五边形面积越大，整体风险越高；颜色越深，需重点关注')
        .fontSize(11)
        .fontColor('#BBBBBB')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder buildRiskDetailsSection() {
    Column({ space: 12 }) {
      Text('🔍 各维度风险详情')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)

      Scroll() {
        Row({ space: 12 }) {
          if (this.assessmentResult) {
            RiskCard({ risk: this.assessmentResult.risks.hypertension, compact: true })
            RiskCard({ risk: this.assessmentResult.risks.diabetes, compact: true })
            RiskCard({ risk: this.assessmentResult.risks.fall, compact: true })
            RiskCard({ risk: this.assessmentResult.risks.frailty, compact: true })
            RiskCard({ risk: this.assessmentResult.risks.sarcopenia, compact: true })
          }
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
      .scrollBar(BarState.Off)
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
        maxItems: 8
      })
    }
    .width('100%')
  }

  @Builder buildActionButtons() {
    Row({ space: 12 }) {
      Button('📋 查看完整报告')
        .layoutWeight(1)
        .height(48)
        .fontSize(15)
        .fontColor('#1677FF')
        .backgroundColor('#E6F4FF')
        .borderRadius(24)
        .onClick(() => {
          console.log('[RiskAssessmentPage] 跳转到详细报告页面');
        })

      Button('📊 历史对比')
        .layoutWeight(1)
        .height(48)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#52C41A')
        .borderRadius(24)
        .onClick(() => {
          console.log('[RiskAssessmentPage] 跳转到趋势对比页面');
        })
    }
    .width('100%')

    Button('🔄 重新评估')
      .width('100%')
      .height(44)
      .fontSize(14)
      .fontColor('#666666')
      .backgroundColor('#F5F5F5')
      .borderRadius(22)
      .margin({ top: 8 })
      .onClick(() => {
        this.assessmentResult = null;
      })
  }

  private async startAssessment(): Promise<void> {
    if (!this.healthData) {
      AlertDialog.show({
        title: '提示',
        message: '健康数据未准备好',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
      return;
    }

    this.isAssessing = true;

    try {
      console.log('[RiskAssessmentPage] 开始执行AI风险评估...');
      
      const result = await this.assessmentEngine.assessRisk(
        this.healthData,
        undefined
      );

      this.assessmentResult = result;

      console.log('[RiskAssessmentPage] 评估完成！');
      console.log(`  综合评分: ${(result.overallScore * 100).toFixed(1)}分`);
      console.log(`  风险等级: ${result.overallLevel}`);

    } catch (error) {
      console.error('[RiskAssessmentPage] 评估失败:', error instanceof Error ? error.message : String(error));
      
      AlertDialog.show({
        title: '❌ 评估失败',
        message: error instanceof Error ? error.message : '未知错误',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
    } finally {
      this.isAssessing = false;
    }
  }
}