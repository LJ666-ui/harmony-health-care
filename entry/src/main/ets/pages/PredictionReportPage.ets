import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { GlobalTheme } from '../global';
import { DiseasePredictor, UserProfile, DiseaseRisk, RiskPoint } from '../digitaltwin/DiseasePredictor';
import { TreatmentSimulator, SimulationPlan, SimulationResult, SimulationConfig } from '../digitaltwin/TreatmentSimulator';

interface SimDataWrapper {
  plan: SimulationPlan;
  results: SimulationResult[];
}

@Entry
@Component
struct PredictionReportPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State reportType: string = '';
  @State diseaseName: string = '';
  @State planId: string = '';
  @State isLoading: boolean = true;
  @State selectedDuration: number = 12;
  @State currentRisk: DiseaseRisk | null = null;
  @State simData: SimDataWrapper | null = null;

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

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    try {
      const params = router.getParams() as Record<string, Object> | undefined;
      
      if (params) {
        if (params['diseaseName']) {
          this.reportType = 'disease';
          this.diseaseName = String(params['diseaseName']);
        }
        
        if (params['planId']) {
          this.reportType = 'simulation';
          this.planId = String(params['planId']);
        }
      }
    } catch (error) {
      console.error('获取报告参数失败:', error);
    }

    this.loadReportData();

    setTimeout(() => {
      this.isLoading = false;
    }, 600);
  }

  loadReportData(): void {
    if (this.reportType === 'disease' && this.diseaseName) {
      const predictions: DiseaseRisk[] = DiseasePredictor.getAllPredictions(this.userProfile, 5);
      for (let i = 0; i < predictions.length; i++) {
        if (predictions[i].diseaseName === this.diseaseName) {
          this.currentRisk = predictions[i];
          break;
        }
      }
    } else if (this.reportType === 'simulation' && this.planId) {
      for (let i = 0; i < TreatmentSimulator.PLANS.length; i++) {
        if (TreatmentSimulator.PLANS[i].id === this.planId) {
          const config: SimulationConfig = {
            profile: this.userProfile,
            selectedPlan: TreatmentSimulator.PLANS[i],
            durationMonths: this.selectedDuration,
            adherenceLevel: 'medium'
          };
          this.simData = {
            plan: TreatmentSimulator.PLANS[i],
            results: TreatmentSimulator.simulate(config)
          };
          break;
        }
      }
    }
  }

  refreshSimulationData(): void {
    if (this.reportType === 'simulation' && this.planId) {
      for (let i = 0; i < TreatmentSimulator.PLANS.length; i++) {
        if (TreatmentSimulator.PLANS[i].id === this.planId) {
          const config: SimulationConfig = {
            profile: this.userProfile,
            selectedPlan: TreatmentSimulator.PLANS[i],
            durationMonths: this.selectedDuration,
            adherenceLevel: 'medium'
          };
          this.simData = {
            plan: TreatmentSimulator.PLANS[i],
            results: TreatmentSimulator.simulate(config)
          };
          break;
        }
      }
    }
  }

  build() {
    Column() {
      Header({ 
        title: this.reportType === 'disease' ? `${this.diseaseName}风险报告` : '治疗方案模拟报告', 
        showBack: true 
      });

      if (this.isLoading) {
        Loading({ text: '生成报告中...' })
      } else {
        Scroll() {
          Column() {
            if (this.reportType === 'disease') {
              if (this.currentRisk) {
                this.DiseaseReportDetail()
              } else {
                Text('未找到疾病预测数据')
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT)
              }
            } else if (this.reportType === 'simulation') {
              if (this.simData) {
                this.SimulationReportDetail()
              } else {
                Text('未找到模拟数据')
                  .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                  .fontColor(GlobalTheme.TEXT_HINT)
              }
            } else {
              Text('无效的报告类型')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.TEXT_HINT)
            }
          }
          .width('100%')
          .padding(16)
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
  DiseaseReportDetail() {
    Column() {
      Row() {
        Text(`📊 ${this.currentRisk!.diseaseName}风险评估报告`)
          .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
          .fontWeight(FontWeight.Bold)
          .fontColor(GlobalTheme.TEXT_PRIMARY)
      }
      .width('100%')
      .margin({ bottom: 16 })

      Column() {
        Row() {
          Text('当前风险等级')
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
          
          Blank()
          
          Text(DiseasePredictor.getRiskLevelText(this.currentRisk!.riskLevel))
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(DiseasePredictor.getRiskLevelColor(this.currentRisk!.riskLevel))
        }
        .width('100%')

        Row() {
          Text(`${this.currentRisk!.currentRisk}%`)
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor(DiseasePredictor.getRiskLevelColor(this.currentRisk!.riskLevel))
          
          Blank()
          
          Column() {
            ForEach([0, 25, 50, 75, 100], (threshold: number) => {
              Row() {
                Text(`${threshold}%`)
                  .fontSize(10)
                  .fontColor(GlobalTheme.TEXT_LIGHT)
                Blank()
              }.width(60).margin({ top: threshold === 0 ? 0 : -14 })
            }, (threshold: number) => `${threshold}`)
            
            Column() {
              ForEach([0, 20, 40, 60, 80], (value: number) => {
                Row() {
                  Text('')
                    .width(`${Math.min(this.currentRisk!.currentRisk / 100 * 100, value + 20) > value ? Math.max(0, this.currentRisk!.currentRisk - value) / 20 * 100 : 0}%`)
                    .height(12)
                    .borderRadius(6)
                    .backgroundColor(DiseasePredictor.getRiskLevelColor(this.currentRisk!.riskLevel))
                  
                  Text('')
                    .layoutWeight(1)
                    .height(12)
                    .borderRadius(6)
                    .backgroundColor('#F0F0F0')
                }
                .width(60)
                .margin({ top: 4 })
              }, (value: number) => `${value}`)
            }
            .rotate({ angle: 180 })
          }
        }
        .width('100%')
        .margin({ top: 16 })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ bottom: 16 })

      Text('📈 风险趋势预测（未来5年）')
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Medium)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 12 })

      Column() {
        Row() {
          ForEach(this.currentRisk!.predictionCurve.slice(0, 6), (point: RiskPoint, index: number) => {
            Column() {
              Text(`${point.year}`)
                .fontSize(10)
                .fontColor(GlobalTheme.TEXT_HINT)
              
              Column() {
                Text('')
                  .width(30)
                  .height(Math.max(point.risk * 1.5, 10))
                  .borderRadius(6)
                  .backgroundColor(
                    point.risk < 20 ? '#52C41A' :
                    point.risk < 40 ? '#FAAD14' :
                    point.risk < 60 ? '#FF7A45' : '#FF4D4F'
                  )
                
                Text(`${point.risk}%`)
                  .fontSize(11)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(
                    point.risk < 20 ? '#52C41A' :
                    point.risk < 40 ? '#FAAD14' :
                    point.risk < 60 ? '#FF7A45' : '#FF4D4F'
                  )
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Center)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }, (point: RiskPoint, index: number) => `${index}`)
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ bottom: 16 })

      this.RiskFactorsBuilder()

      this.RecommendationsBuilder()

      Column() {
        Text('⚠️ 重要提示')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontWeight(FontWeight.Medium)
          .fontColor(GlobalTheme.WARNING_COLOR)
        
        Text('本评估结果基于您提供的健康数据和医学统计模型计算，仅供参考，不构成医疗诊断或治疗建议。如有疑虑请及时就医咨询专业医生。')
          .fontSize(11)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .lineHeight(18)
          .margin({ top: 6 })
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFBE6')
      .borderRadius(12)
      .margin({ top: 20 })
    }
  }

  @Builder
  RiskFactorsBuilder() {
    if (this.currentRisk!.riskFactors && this.currentRisk!.riskFactors.length > 0) {
      Column() {
        Text('⚠️ 主要风险因素')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight(FontWeight.Medium)
          .fontColor(GlobalTheme.TEXT_PRIMARY)
          .width('100%')
          .margin({ bottom: 8 })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.currentRisk!.riskFactors, (factor: string, _index: number) => {
            Row() {
              Text('•')
                .fontColor('#FF7A45')
              Text(factor)
                .fontSize(13)
                .fontColor('#333333')
            }
            .backgroundColor('#FFF7E6')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8, bottom: 8 })
          }, (factor: string, _index: number) => `${_index}`)
        }
        .width('100%')
        .margin({ bottom: 16 })
      }
    }
  }

  @Builder
  RecommendationsBuilder() {
    if (this.currentRisk!.recommendations && this.currentRisk!.recommendations.length > 0) {
      Column() {
        Text('💡 预防建议')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontWeight(FontWeight.Medium)
          .fontColor(GlobalTheme.TEXT_PRIMARY)
          .width('100%')
          .margin({ bottom: 8 })

        ForEach(this.currentRisk!.recommendations, (rec: string, index: number) => {
          Row() {
            Text(`${index + 1}`)
              .width(24)
              .height(24)
              .borderRadius(12)
              .backgroundColor(GlobalTheme.THEME_COLOR)
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
            
            Text(rec)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontColor(GlobalTheme.TEXT_PRIMARY)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding(12)
          .backgroundColor(index % 2 === 0 ? '#FFFFFF' : '#F5F7FA')
          .borderRadius(8)
          .margin({ bottom: 6 })
        }, (rec: string, index: number) => `${index}`)
      }
    }
  }

  @Builder
  SimulationReportDetail() {
    Column() {
      Row() {
        Text(this.simData!.plan.icon)
          .fontSize(36)
        
        Column() {
          Text(`💊 ${this.simData!.plan.name}`)
            .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
            .fontWeight(FontWeight.Bold)
            .fontColor(GlobalTheme.TEXT_PRIMARY)
          
          Text(this.simData!.plan.description)
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(GlobalTheme.TEXT_SECONDARY)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ bottom: 16 })

      Row() {
        Text('模拟周期:')
          .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY)
        
        Blank()
        
        ForEach([6, 12, 24, 36], (months: number) => {
          Button(`${months}个月`)
            .fontSize(12)
            .height(28)
            .padding({ left: 10, right: 10 })
            .backgroundColor(this.selectedDuration === months ? GlobalTheme.THEME_COLOR : '#F5F5F5')
            .fontColor(this.selectedDuration === months ? '#FFFFFF' : GlobalTheme.TEXT_SECONDARY)
            .borderRadius(14)
            .margin({ left: 4 })
            .onClick(() => {
              this.selectedDuration = months;
              this.refreshSimulationData();
            })
        }, (months: number) => `${months}`)
      }
      .width('100%')
      .margin({ bottom: 16 })

      Text('📊 预期效果')
        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor(GlobalTheme.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: 12 })

      ForEach(this.simData!.results, (result: SimulationResult, index: number) => {
        Column() {
          Row() {
            Text(result.metricName)
              .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
              .fontWeight(FontWeight.Medium)
              .fontColor(GlobalTheme.TEXT_PRIMARY)
            
            Blank()
            
            Text(`${result.currentValue}${result.unit}`)
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor('#999999')
            
            Text('→')
              .fontSize(16)
              .fontColor(GlobalTheme.THEME_COLOR)
              .margin({ left: 8, right: 8 })
            
            Text(`${result.projectedValues[result.projectedValues.length - 1]}${result.unit}`)
              .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
              .fontWeight(FontWeight.Bold)
              .fontColor(result.improvement > 0 ? GlobalTheme.SUCCESS_COLOR : GlobalTheme.ERROR_COLOR)
          }
          .width('100%')

          Text(`预计改善: ${Math.abs(result.improvement).toFixed(1)}%`)
            .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
            .fontColor(result.improvement > 0 ? GlobalTheme.SUCCESS_COLOR : GlobalTheme.WARNING_COLOR)
            .width('100%')
            .margin({ top: 8 })

          Row() {
            ForEach(result.projectedValues.filter((_: number, i: number) => 
              i % Math.ceil(result.projectedValues.length / 6) === 0
            ).slice(0, 6), (value: number, vIndex: number) => {
              Column() {
                Text(`${value}`)
                  .fontSize(11)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(value <= result.currentValue ? GlobalTheme.SUCCESS_COLOR : '#FF7A45')
                
                Text(`${vIndex * Math.round(this.selectedDuration / 5)}月`)
                  .fontSize(9)
                  .fontColor(GlobalTheme.TEXT_HINT)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }, (value: number, vIndex: number) => `${vIndex}`)
          }
          .width('100%')
          .margin({ top: 12 })
          .padding(10)
          .backgroundColor('#F5F7FA')
          .borderRadius(8)

          this.NotesBuilder(result)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ bottom: 12 })
      }, (result: SimulationResult, index: number) => `${index}`)

      Button('开始执行此方案')
        .width('100%')
        .height(GlobalTheme.getButtonHeight(this.isElderMode))
        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor(GlobalTheme.THEME_COLOR)
        .borderRadius(GlobalTheme.RADIUS_LG)
        .margin({ top: 8 })
        .onClick(() => {
          console.log('用户选择执行方案:', this.simData!.plan.id);
        })

      Column() {
        Text('⚠️ 免责声明')
          .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
          .fontWeight(FontWeight.Medium)
          .fontColor(GlobalTheme.WARNING_COLOR)
        
        Text('本模拟基于统计学模型和医学研究数据，实际效果因人而异。请在专业医生指导下制定个性化治疗方案。')
          .fontSize(11)
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .lineHeight(18)
          .margin({ top: 6 })
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFBE6')
      .borderRadius(12)
      .margin({ top: 16 })
    }
  }

  @Builder
  NotesBuilder(result: SimulationResult) {
    if (result.notes && result.notes.length > 0) {
      ForEach(result.notes, (note: string, _nIndex: number) => {
        Text(`• ${note}`)
          .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
          .fontColor(GlobalTheme.TEXT_SECONDARY)
          .width('100%')
          .margin({ top: 4 })
      }, (note: string, _nIndex: number) => `${_nIndex}`)
    }
  }
}
