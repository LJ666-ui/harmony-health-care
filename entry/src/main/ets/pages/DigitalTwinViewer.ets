import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { GlobalTheme } from '../global';
import { HumanBodyModel, BodyViewType, OrganData } from '../digitaltwin/HumanBodyModel';
import { OrganVisualizer, OrganHealthData, OrganMetric } from '../digitaltwin/OrganVisualizer';
import { DiseasePredictor, UserProfile, DiseaseRisk, RiskPoint } from '../digitaltwin/DiseasePredictor';

interface TabItem {
  label: string;
  color: string;
}

interface PlanItem {
  id: string;
  name: string;
  icon: string;
  desc: string;
}

@Entry
@Component
struct DigitalTwinViewer {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State currentTab: number = 0;
  @State selectedOrganId: string = '';
  @State isLoading: boolean = true;
  @State healthScoreDisplay: number = 100;
  @State healthStatusDisplay: string = '健康';
  @State healthColorDisplay: string = '#52C41A';

  private userProfile: UserProfile = {
    age: 35,
    gender: 'male',
    height: 172,
    weight: 75,
    systolicBP: 128,
    diastolicBP: 82,
    totalCholesterol: 5.2,
    hdlCholesterol: 1.2,
    fastingGlucose: 5.6,
    isSmoker: false,
    hasDiabetes: false,
    isHypertensive: false,
    familyHistoryCVD: true,
    physicalActivity: 'moderate'
  };

  private heartMetrics: OrganMetric[] = [
    { name: '心率', value: 72, unit: 'bpm', normalMin: 60, normalMax: 100, isNormal: true },
    { name: '血压', value: 128, unit: 'mmHg', normalMin: 90, normalMax: 140, isNormal: true }
  ];

  private lungsMetrics: OrganMetric[] = [
    { name: '血氧', value: 96, unit: '%', normalMin: 95, normalMax: 100, isNormal: true },
    { name: '肺活量', value: 3.2, unit: 'L', normalMin: 3.5, normalMax: 5.0, isNormal: false }
  ];

  private liverMetrics: OrganMetric[] = [
    { name: 'ALT', value: 28, unit: 'U/L', normalMin: 0, normalMax: 40, isNormal: true }
  ];

  private kidneyMetrics: OrganMetric[] = [
    { name: '肌酐', value: 78, unit: 'μmol/L', normalMin: 44, normalMax: 133, isNormal: true }
  ];

  private brainMetrics: OrganMetric[] = [];

  private pancreasMetrics: OrganMetric[] = [
    { name: '空腹血糖', value: 5.6, unit: 'mmol/L', normalMin: 3.9, normalMax: 6.1, isNormal: true }
  ];

  private organHealthData: OrganHealthData[] = [
    {
      organId: 'heart',
      healthScore: 85,
      status: 'healthy',
      metrics: this.heartMetrics,
      lastCheckDate: '2025-04-20'
    },
    {
      organId: 'lungs',
      healthScore: 78,
      status: 'sub_healthy',
      metrics: this.lungsMetrics,
      lastCheckDate: '2025-04-18'
    },
    {
      organId: 'liver',
      healthScore: 92,
      status: 'healthy',
      metrics: this.liverMetrics,
      lastCheckDate: '2025-03-15'
    },
    {
      organId: 'kidney',
      healthScore: 88,
      status: 'healthy',
      metrics: this.kidneyMetrics,
      lastCheckDate: '2025-04-10'
    },
    {
      organId: 'brain',
      healthScore: 82,
      status: 'healthy',
      metrics: this.brainMetrics,
      lastCheckDate: '2025-02-28'
    },
    {
      organId: 'pancreas',
      healthScore: 75,
      status: 'sub_healthy',
      metrics: this.pancreasMetrics,
      lastCheckDate: '2025-04-22'
    }
  ];

  private tabNames: string[] = ['人体模型', '器官健康', '疾病预测', '方案模拟'];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    this.calculateOverallHealth();

    setTimeout(() => {
      this.isLoading = false;
    }, 800);
  }

  calculateOverallHealth(): void {
    if (this.organHealthData.length === 0) {
      this.healthScoreDisplay = 100;
      this.healthStatusDisplay = '健康';
      this.healthColorDisplay = '#52C41A';
      return;
    }

    let totalScore: number = 0;
    for (let i = 0; i < this.organHealthData.length; i++) {
      totalScore += this.organHealthData[i].healthScore;
    }

    const avgScore: number = Math.round(totalScore / this.organHealthData.length);
    this.healthScoreDisplay = avgScore;

    if (avgScore >= 85) {
      this.healthStatusDisplay = '健康';
      this.healthColorDisplay = '#52C41A';
    } else if (avgScore >= 70) {
      this.healthStatusDisplay = '亚健康';
      this.healthColorDisplay = '#FAAD14';
    } else if (avgScore >= 50) {
      this.healthStatusDisplay = '需关注';
      this.healthColorDisplay = '#FF7A45';
    } else {
      this.healthStatusDisplay = '异常';
      this.healthColorDisplay = '#FF4D4F';
    }
  }

  getOrganDataForModel(): OrganData[] {
    const result: OrganData[] = [];

    for (let i = 0; i < this.organHealthData.length; i++) {
      const health: OrganHealthData = this.organHealthData[i];

      let x: number = 0;
      let y: number = 180;
      let radius: number = 18;

      switch (health.organId) {
        case 'heart':
          x = 0; y = 180; radius = 20;
          break;
        case 'lungs':
          x = -25; y = 175; radius = 16;
          break;
        case 'liver':
          x = 15; y = 220; radius = 18;
          break;
        case 'kidney':
          x = 0; y = 260; radius = 14;
          break;
        case 'brain':
          x = 0; y = 60; radius = 22;
          break;
        case 'pancreas':
          x = -20; y = 235; radius = 12;
          break;
      }

      const item: OrganData = {
        id: health.organId,
        name: this.getOrganName(health.organId),
        nameEn: '',
        x: x,
        y: y,
        radius: radius,
        healthStatus: health.status,
        healthScore: health.healthScore,
        description: ''
      };
      result.push(item);
    }

    return result;
  }

  getOrganName(id: string): string {
    if (id === 'heart') { return '心脏'; }
    if (id === 'lungs') { return '肺部'; }
    if (id === 'liver') { return '肝脏'; }
    if (id === 'kidney') { return '肾脏'; }
    if (id === 'brain') { return '大脑'; }
    if (id === 'pancreas') { return '胰腺'; }
    return id;
  }

  getDiseasePredictions(): DiseaseRisk[] {
    return DiseasePredictor.getAllPredictions(this.userProfile, 5);
  }

  getLegendItems(): TabItem[] {
    const items: TabItem[] = [
      { label: '健康', color: '#52C41A' },
      { label: '亚健康', color: '#FAAD14' },
      { label: '高危', color: '#FF7A45' },
      { label: '异常', color: '#FF4D4F' }
    ];
    return items;
  }

  getCurvePoints(risk: DiseaseRisk): RiskPoint[] {
    return risk.predictionCurve.slice(0, Math.min(6, risk.predictionCurve.length));
  }

  getPlanItems(): PlanItem[] {
    const plans: PlanItem[] = [
      { id: 'exercise_regular', name: '规律运动', icon: '🏃', desc: '每周5次有氧运动' },
      { id: 'mediterranean_diet', name: '地中海饮食', icon: '🥗', desc: '健康饮食模式' },
      { id: 'weight_loss', name: '减重计划', icon: '⚖️', desc: '目标减重5-10%' },
      { id: 'quit_smoking', name: '戒烟计划', icon: '🚭', desc: '完全戒烟' },
      { id: 'sleep_optimization', name: '睡眠优化', icon: '😴', desc: '保证7-8小时睡眠' }
    ];
    return plans;
  }

  build() {
    Column() {
      Header({ title: '数字孪生系统', showBack: true });

      if (this.isLoading) {
        Loading({ text: '正在构建数字孪生体...' })
      } else {
        Row({ space: 0 }) {
          ForEach(this.tabNames, (name: string, index: number) => {
            Button(name)
              .fontSize(this.isElderMode ? 14 : 12)
              .height(44)
              .flexGrow(1)
              .backgroundColor(this.currentTab === index ? GlobalTheme.THEME_COLOR : '#FFFFFF')
              .fontColor(this.currentTab === index ? '#FFFFFF' : GlobalTheme.TEXT_SECONDARY)
              .borderRadius(0)
              .onClick(() => {
                this.currentTab = index;
              })
          }, (name: string, index: number) => `${index}`)
        }
        .width('100%')
        .margin({ top: 8 })

        Scroll() {
          Column() {
            if (this.currentTab === 0) {
              this.HumanBodyTab()
            } else if (this.currentTab === 1) {
              this.OrganHealthTab()
            } else if (this.currentTab === 2) {
              this.DiseasePredictionTab()
            } else {
              this.TreatmentSimulationTab()
            }
          }
          .width('100%')
          .padding({ bottom: 80 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }

      Footer({ activeIndex: 3 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(GlobalTheme.BG_COLOR)
  }

  @Builder
  HumanBodyTab() {
    Column() {
      Row() {
        Text('🧬 我的数字分身')
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY)

        Blank()

        Row() {
          Text(`综合评分 ${this.healthScoreDisplay}`)
            .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(this.healthColorDisplay)
        }
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .backgroundColor(this.healthColorDisplay + '15')
        .borderRadius(16)
      }
      .width('100%')
      .margin({ bottom: 16 })

      HumanBodyModel({
        viewType: BodyViewType.FRONT,
        organs: this.getOrganDataForModel()
      })

      Text('💡 点击器官查看详情 | 拖拽缩放调整视角')
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_HINT)
        .margin({ top: 12 })

      Row({ space: 12 }) {
        ForEach(this.getLegendItems(), (item: TabItem, index: number) => {
          Row() {
            Text('')
              .width(10)
              .height(10)
              .borderRadius(5)
              .backgroundColor(item.color)
            Text(item.label)
              .fontSize(11)
              .fontColor(GlobalTheme.TEXT_SECONDARY)
              .margin({ left: 4 })
          }
        }, (item: TabItem, index: number) => `${index}`)
      }
      .margin({ top: 16 })
    }
    .alignItems(HorizontalAlign.Center)
    .padding(16)
  }

  @Builder
  OrganHealthTab() {
    OrganVisualizer({ organs: this.organHealthData })
  }

  @Builder
  DiseasePredictionTab() {
    Column() {
      Text('📊 疾病风险预测')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 16 })

      Text('基于当前健康数据，预测未来5年患病风险')
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 20 })

      List({ space: 12 }) {
        ForEach(this.getDiseasePredictions(), (risk: DiseaseRisk, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Text(risk.diseaseName)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)

                Blank()

                Text(`${risk.currentRisk}%`)
                  .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                  .fontWeight(FontWeight.Bold)
                  .fontColor(DiseasePredictor.getRiskLevelColor(risk.riskLevel))

                Text(DiseasePredictor.getRiskLevelText(risk.riskLevel))
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor('#FFFFFF')
                  .backgroundColor(DiseasePredictor.getRiskLevelColor(risk.riskLevel))
                  .borderRadius(8)
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .margin({ left: 8 })
              }
              .width('100%')

              this.RiskCurveRow(risk)

              this.RiskFactorsSection(risk)

              this.RecommendationsSection(risk)
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .border({ width: 1, color: GlobalTheme.BORDER_COLOR })
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/PredictionReportPage',
              params: { diseaseName: risk.diseaseName }
            }).catch((err: Error) => {});
          })
        }, (risk: DiseaseRisk, index: number) => `${index}`)
      }
      .width('100%')
    }
    .padding(16)
  }

  @Builder
  RiskCurveRow(risk: DiseaseRisk) {
    Row() {
      ForEach(this.getCurvePoints(risk), (point: RiskPoint, pIndex: number) => {
        Column() {
          Text(`${point.year}`)
            .fontSize(9)
            .fontColor(GlobalTheme.TEXT_HINT)
          Text(`${point.risk}%`)
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor(point.risk > risk.currentRisk ? '#FF4D4F' : GlobalTheme.SUCCESS_COLOR)
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      }, (point: RiskPoint, pIndex: number) => `${pIndex}`)
    }
    .width('100%')
    .margin({ top: 12 })
    .padding(10)
    .backgroundColor('#F5F7FA')
    .borderRadius(8)
  }

  @Builder
  RiskFactorsSection(risk: DiseaseRisk) {
    if (risk.riskFactors && risk.riskFactors.length > 0) {
      Text('风险因素:')
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .margin({ top: 12 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(risk.riskFactors, (factor: string, fIndex: number) => {
          Text(factor)
            .fontSize(11)
            .fontColor('#FF7A45')
            .backgroundColor('#FFF7E6')
            .borderRadius(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ right: 6, bottom: 4 })
        }, (factor: string, fIndex: number) => `${fIndex}`)
      }
      .width('100%')
    }
  }

  @Builder
  RecommendationsSection(risk: DiseaseRisk) {
    if (risk.recommendations && risk.recommendations.length > 0) {
      Text('建议措施:')
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .margin({ top: 8 })

      ForEach(risk.recommendations.slice(0, 3), (rec: string, rIndex: number) => {
        Row() {
          Text('•')
            .fontColor(GlobalTheme.THEME_COLOR)
          Text(rec)
            .fontSize(12)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
            .margin({ left: 4 })
        }
        .width('100%')
        .margin({ top: 2 })
      }, (rec: string, rIndex: number) => `${rIndex}`)
    }
  }

  @Builder
  TreatmentSimulationTab() {
    Column() {
      Text('💊 治疗方案模拟')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 12 })

      Text('选择干预方案，预览健康指标变化趋势')
        .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
        .fontColor(GlobalTheme.TEXT_SECONDARY)
        .width('100%')
        .margin({ bottom: 16 })

      List({ space: 10 }) {
        ForEach(this.getPlanItems(), (plan: PlanItem, index: number) => {
          ListItem() {
            Row() {
              Text(plan.icon)
                .fontSize(32)

              Column() {
                Text(plan.name)
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontWeight(FontWeight.Medium)
                  .fontColor(GlobalTheme.TEXT_PRIMARY)

                Text(plan.desc)
                  .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
              .layoutWeight(1)

              Text('开始模拟 >')
                .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                .fontColor(GlobalTheme.THEME_COLOR)
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/PredictionReportPage',
                params: { planId: plan.id }
              }).catch((err: Error) => {});
            })
          }
        }, (plan: PlanItem, index: number) => `${index}`)
      }
      .width('100%')

      this.DisclaimerSection()
    }
    .padding(16)
  }

  @Builder
  DisclaimerSection() {
    Column() {
      Text('⚠️ 免责声明')
        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
        .fontWeight(FontWeight.Medium)
        .fontColor(GlobalTheme.WARNING_COLOR)

      Text('本系统提供的预测和模拟结果仅供参考，不构成医疗诊断或治疗建议。如有健康问题请咨询专业医生。')
        .fontSize(10)
        .fontColor(GlobalTheme.TEXT_LIGHT)
        .lineHeight(16)
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFBE6')
    .borderRadius(8)
    .margin({ top: 16 })
  }
}
