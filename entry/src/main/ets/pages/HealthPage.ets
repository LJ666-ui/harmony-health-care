import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { CarouselBanner, BannerItem, GradientColorStop } from '../components/CarouselBanner';
import { HealthOverviewCard, HealthOverviewData } from '../components/HealthOverviewCard';
import { AccessibilityConfig } from '../utils/AccessibilityConfig';
import { HealthService, HealthData } from '../services/HealthService';
import { ToastUtil } from '../common/utils/ToastUtil';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';

interface ServiceCard {
  id: number;
  icon: string;
  title: string;
  description: string;
  url: string;
}

interface WhatIfItem {
  label: string;
  impact: string;
  color: string;
}

interface VitalSignItem {
  name: string;
  value: string;
  unit: string;
  color: string;
}

interface OrganStatusItem {
  name: string;
  status: string;
  color: string;
  percent: number;
}

@Entry
@Component
struct HealthPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @StorageLink('userId') userId: number = 0;
  @State currentTab: number = 0;
  @State isLoading: boolean = true;
  @State vitalSigns: VitalSignItem[] = [];
  @State aiHealthAnalysis: string = '';
  @State aiRiskAlert: string = '';
  @State aiPersonalizedAdvice: string = '';

  private healthService: HealthService = HealthService.getInstance();
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  healthBanners: BannerItem[] = [
    {
      id: 'ai_risk',
      icon: '🧠⚡',
      title: '端侧AI风险评估',
      subtitle: 'MindSpore推理 · 本地隐私保护 · SHAP可解释',
      ctaText: '开始评估',
      targetUrl: 'pages/RiskAssessmentPage',
      gradientColors: [{ color: '#9B59B6', offset: 0 }, { color: '#8E44AD', offset: 1 }]
    },
    {
      id: 'monitoring',
      icon: '📊📡',
      title: '患者实时健康监控',
      subtitle: '心率/血压/血糖/血氧 · 异常自动告警',
      ctaText: '查看监控',
      targetUrl: 'pages/MonitoringDashboard',
      gradientColors: [{ color: '#E74C3C', offset: 0 }, { color: '#C0392B', offset: 1 }]
    },
    {
      id: 'digital_twin',
      icon: '👤🔄',
      title: '您的数字孪生分身',
      subtitle: '3D人体模型 · 器官健康可视化 · 预测模拟',
      ctaText: '查看我的孪生',
      targetUrl: 'pages/DigitalTwinPage',
      gradientColors: [{ color: '#3498DB', offset: 0 }, { color: '#2980B9', offset: 1 }]
    },
    {
      id: 'rehab_plan',
      icon: '🏃💪',
      title: '今日康复任务',
      subtitle: '上肢训练×3组 · 平衡练习×10min',
      ctaText: '开始训练',
      targetUrl: 'pages/RehabListPage',
      gradientColors: [{ color: '#2ECC71', offset: 0 }, { color: '#27AE60', offset: 1 }]
    }
  ];

  healthOverviewData: HealthOverviewData = {
    healthScore: 85,
    riskLevel: '低风险',
    riskColor: '#4CAF50',
    rehabProgress: 67,
    lastAssessmentDate: '2026-04-15'
  };

  rehabServices: ServiceCard[] = [
    { id: 1, icon: '🏃', title: '康复课程', description: '专业康复训练指导', url: 'pages/RehabListPage' },
    { id: 2, icon: '🎮', title: '3D康复训练', description: '沉浸式3D康复体验', url: 'pages/Rehab3DPage' }
  ];

  whatIfItems: WhatIfItem[] = [
    { label: '如果我戒烟...', impact: '-15%', color: '#4CAF50' },
    { label: '如果每天运动30分钟...', impact: '-20%', color: '#4CAF50' },
    { label: '如果控制饮食...', impact: '-10%', color: '#4CAF50' }
  ];

  organStatuses: OrganStatusItem[] = [
    { name: '心脏', status: '正常', color: '#E74C3C', percent: 95 },
    { name: '肺部', status: '良好', color: '#3498DB', percent: 88 },
    { name: '肝脏', status: '正常', color: '#9B59B6', percent: 92 },
    { name: '肾脏', status: '良好', color: '#27AE60', percent: 90 }
  ];

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    }
    this.loadHealthData();
  }

  async loadHealthData(): Promise<void> {
    this.isLoading = true;
    try {
      const healthDataMap = await this.healthService.getLatestHealthData(this.userId);
      
      this.vitalSigns = [];
      
      const bloodPressure = healthDataMap.get('blood_pressure');
      if (bloodPressure) {
        this.vitalSigns.push({
          name: '血压',
          value: `${bloodPressure.systolic || bloodPressure.value}/${bloodPressure.diastolic || 80} mmHg`,
          unit: '正常范围: 90-140/60-90',
          color: '#3498DB'
        });
      } else {
        this.vitalSigns.push({
          name: '血压',
          value: '-- mmHg',
          unit: '暂无数据',
          color: '#999'
        });
      }

      const bloodSugar = healthDataMap.get('blood_sugar');
      if (bloodSugar) {
        this.vitalSigns.push({
          name: '血糖',
          value: `${bloodSugar.value} mmol/L`,
          unit: '正常范围: 3.9-6.1',
          color: '#9B59B6'
        });
      } else {
        this.vitalSigns.push({
          name: '血糖',
          value: '-- mmol/L',
          unit: '暂无数据',
          color: '#999'
        });
      }

      const heartRate = healthDataMap.get('heart_rate');
      if (heartRate) {
        this.vitalSigns.push({
          name: '心率',
          value: `${heartRate.value} bpm`,
          unit: '正常范围: 60-100',
          color: '#E74C3C'
        });
      } else {
        this.vitalSigns.push({
          name: '心率',
          value: '-- bpm',
          unit: '暂无数据',
          color: '#999'
        });
      }
    } catch (error) {
      console.error('[HealthPage] 加载健康数据失败:', error);
      ToastUtil.showError('加载数据失败');
      
      this.vitalSigns = [
        { name: '心率', value: '-- bpm', unit: '暂无数据', color: '#999' },
        { name: '血压', value: '-- mmHg', unit: '暂无数据', color: '#999' },
        { name: '血糖', value: '-- mmol/L', unit: '暂无数据', color: '#999' }
      ];
    } finally {
      this.isLoading = false;
    }
  }

  async analyzeHealthWithAI(): Promise<void> {
    try {
      const request = AIRequestBuilder.createDataRequest(
        JSON.stringify(this.vitalSigns),
        'health_summary',
        String(this.userId)
      );
      const response = await this.orchestrator.process(request);
      this.aiHealthAnalysis = typeof response.output.content === 'string' ? response.output.content : JSON.stringify(response.output.content);
    } catch (error) {
      console.error('[HealthPage] AI健康分析失败:', error);
      this.aiHealthAnalysis = 'AI分析暂时不可用';
    }
  }

  async checkRiskWithAI(): Promise<void> {
    try {
      const request = AIRequestBuilder.createDataRequest(
        JSON.stringify(this.vitalSigns),
        'risk_analysis',
        String(this.userId)
      );
      const response = await this.orchestrator.process(request);
      this.aiRiskAlert = typeof response.output.content === 'string' ? response.output.content : JSON.stringify(response.output.content);
    } catch (error) {
      console.error('[HealthPage] AI风险检测失败:', error);
      this.aiRiskAlert = 'AI风险检测暂时不可用';
    }
  }

  async getPersonalizedAdviceFromAI(): Promise<void> {
    try {
      const request = AIRequestBuilder.createDataRequest(
        '基于我的当前健康数据，请给出个性化的健康管理建议',
        'health_consultation',
        String(this.userId)
      );
      const response = await this.orchestrator.process(request);
      this.aiPersonalizedAdvice = typeof response.output.content === 'string' ? response.output.content : JSON.stringify(response.output.content);
    } catch (error) {
      console.error('[HealthPage] AI个性化建议失败:', error);
      this.aiPersonalizedAdvice = 'AI建议暂时不可用';
    }
  }

  build(): void {
    Column() {
      Header({
        title: '健康中心',
        showBack: false
      });

      Scroll() {
        Column({ space: AccessibilityConfig.getSpacingMD() }) {
          this.buildBannerSection()
          this.buildOverviewSection()
          this.buildTabSection()
        }
        .width('85%')
        .padding({
          top: AccessibilityConfig.getSpacingLG(),
          bottom: AccessibilityConfig.getSpacingLG()
        })
      }
      .height(0)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top);

      Footer({ activeIndex: 2 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AccessibilityConfig.getBgColor())
  }

  @Builder buildBannerSection() {
    CarouselBanner({ banners: this.healthBanners })
  }

  @Builder buildOverviewSection() {
    HealthOverviewCard({ overviewData: this.healthOverviewData })
  }

  @Builder buildTabSection() {
    Column({ space: 12 }) {
      Tabs({ index: this.currentTab }) {
        TabContent() {
          this.buildRehabContent()
        }.tabBar(this.buildTabBar('康复训练', '🏃'))

        TabContent() {
          this.buildAiAssessContent()
        }.tabBar(this.buildTabBar('AI评估', '🧠'))

        TabContent() {
          this.buildMonitoringContent()
        }.tabBar(this.buildTabBar('实时监控', '📊'))

        TabContent() {
          this.buildDigitalTwinContent()
        }.tabBar(this.buildTabBar('数字孪生', '👤'))
      }
      .barPosition(BarPosition.Start)
      .barHeight(this.isElderMode ? 48 : 40)
      .animationDuration(200)
      .onChange((index: number) => {
        this.currentTab = index;
      })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder buildTabBar(label: string, icon: string) {
    Row({ space: 6 }) {
      Text(icon)
        .fontSize(this.isElderMode ? 18 : 14)

      Text(label)
        .fontSize(this.isElderMode ? 14 : 12)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 16, right: 16, top: 10, bottom: 10 })
  }

  @Builder buildRehabContent() {
    Scroll() {
      Column({ space: AccessibilityConfig.getSpacingMD() }) {
        ForEach(this.rehabServices, (service: ServiceCard) => {
          Row({ space: AccessibilityConfig.getSpacingMD() }) {
            Column() {
              Text(service.icon)
                .fontSize(this.isElderMode ? 28 : 22)
                .fontColor(AccessibilityConfig.getThemeColor());
            }
            .width(64)
            .height(64)
            .backgroundColor(AccessibilityConfig.getThemeColor() + '20')
            .borderRadius(32)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center);

            Column({ space: 4 }) {
              Text(service.title)
                .fontSize(this.isElderMode ? 16 : 14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333');

              Text(service.description)
                .fontSize(this.isElderMode ? 13 : 11)
                .fontColor('#666666');
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .margin({ left: AccessibilityConfig.getSpacingMD() });

            Text('›')
              .fontSize(this.isElderMode ? 18 : 14)
              .fontColor('#CCCCCC');
          }
          .width('100%')
          .padding(AccessibilityConfig.getSpacingMD())
          .backgroundColor('#FAFAFA')
          .borderRadius(10)
          .onClick(() => {
            router.pushUrl({ url: service.url });
          });
        }, (service: ServiceCard) => service.id.toString())

        Column({ space: 12 }) {
          Text('推荐康复计划')
            .fontSize(this.isElderMode ? 16 : 14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Row({ space: 12 }) {
            ForEach(['上肢训练', '平衡练习', '呼吸训练'], (rehabItem: string) => {
              Column({ space: 8 }) {
                Text(rehabItem === '上肢训练' ? '💪' : rehabItem === '平衡练习' ? '🚶' : '🫁')
                  .fontSize(28)

                Text(rehabItem)
                  .fontSize(12)
                  .fontColor('#666666')

                Text('30分钟')
                  .fontSize(10)
                  .fontColor('#999999')
              }
              .flexGrow(1)
              .height(100)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(10)
            }, (rehabItem: string) => rehabItem)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: '#F0F0F0' })
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .height(300)
  }

  @Builder buildAiAssessContent() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text('🧠')
              .fontSize(24)

            Text('端侧AI风险评估引擎')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }

          Row({ space: 8 }) {
            Text('上次评估:')
              .fontSize(13)
              .fontColor('#666666')

            Text('2026-04-15')
              .fontSize(13)
              .fontColor(AccessibilityConfig.getThemeColor())

            Text('结果: 低风险')
              .fontSize(13)
              .fontColor('#4CAF50')
              .backgroundColor('#4CAF5020')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(10)
          }

          Row({ space: 12 }) {
            Button('立即重新评估')
              .height(36)
              .fontSize(13)
              .backgroundColor(AccessibilityConfig.getThemeColor())
              .onClick(() => {
                router.pushUrl({ url: 'pages/RiskAssessmentPage' });
              })

            Button('查看历史报告')
              .height(36)
              .fontSize(13)
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .onClick(() => {
                router.pushUrl({ url: 'pages/RiskHistoryPage' });
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: '#F0F0F0' })

        Column({ space: 12 }) {
          Text('⚡ What-if 模拟')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Column({ space: 8 }) {
            ForEach(this.whatIfItems, (item: WhatIfItem) => {
              Row() {
                Text(item.label)
                  .fontSize(13)
                  .fontColor('#666666')
                  .layoutWeight(1)

                Text(item.impact)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(item.color)
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
            }, (item: WhatIfItem) => item.label)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: '#F0F0F0' })
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .height(300)
  }

  @Builder buildMonitoringContent() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text('📊')
              .fontSize(24)

            Text('患者实时监控系统')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }

          Row({ space: 8 }) {
            Text('● 正常')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#4CAF50')

            Text('(最后更新: 刚刚)')
              .fontSize(12)
              .fontColor('#999999')
              .layoutWeight(1)
          }

          Column({ space: 10 }) {
            ForEach(this.vitalSigns, (vital: VitalSignItem) => {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(vital.name)
                    .fontSize(12)
                    .fontColor('#666666')

                  Text(vital.value)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(vital.color)

                  Text(vital.unit)
                    .fontSize(10)
                    .fontColor('#999999')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Column()
                  .width(40)
                  .height(40)
                  .backgroundColor(vital.color + '20')
                  .borderRadius(20)
                  .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
            }, (vital: VitalSignItem) => vital.name)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: '#F0F0F0' })

        Row({ space: 12 }) {
          Button('进入监控面板 →')
            .flexGrow(1)
            .height(38)
            .fontSize(13)
            .backgroundColor(AccessibilityConfig.getThemeColor())
            .onClick(() => {
              router.pushUrl({ url: 'pages/MonitoringDashboard' });
            })

          Button('告警历史 →')
            .flexGrow(1)
            .height(38)
            .fontSize(13)
            .backgroundColor('#F5F5F5')
            .fontColor('#666666')
            .onClick(() => {
              router.pushUrl({ url: 'pages/AlertHistoryPage' });
            })
        }
        .width('100%')
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .height(300)
  }

  @Builder buildDigitalTwinContent() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text('👤')
              .fontSize(24)

            Text('患者数字孪生系统')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
          }

          Column() {
            Text('🔄')
              .fontSize(64)
              .fontColor(AccessibilityConfig.getThemeColor())

            Text('3D人体模型预览')
              .fontSize(14)
              .fontColor('#666666')

            Text('点击进入完整数字孪生系统，查看器官健康状态可视化')
              .fontSize(12)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
              .maxLines(2)
          }
          .width('100%')
          .height(160)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F8F9FF')
          .borderRadius(10)
          .onClick(() => {
            router.pushUrl({ url: 'pages/DigitalTwinPage' });
          })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: '#F0F0F0' })

        Column({ space: 12 }) {
          Text('器官健康状态')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Row({ space: 10 }) {
            ForEach(this.organStatuses, (organ: OrganStatusItem) => {
              Column({ space: 6 }) {
                Text(organ.name)
                  .fontSize(12)
                  .fontColor('#666666')

                Text(`${organ.percent}%`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(organ.color)

                Text(organ.status)
                  .fontSize(10)
                  .fontColor(organ.color)
                  .backgroundColor(organ.color + '20')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .borderRadius(8)
              }
              .flexGrow(1)
              .height(90)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FAFAFA')
              .borderRadius(8)
            }, (organ: OrganStatusItem) => organ.name)
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .border({ width: 1, color: '#F0F0F0' })

        Button('进入数字孪生 →')
          .width('100%')
          .height(42)
          .fontSize(14)
          .backgroundColor(AccessibilityConfig.getThemeColor())
          .onClick(() => {
            router.pushUrl({ url: 'pages/DigitalTwinPage' });
          })
      }
      .padding(16)
    }
    .scrollBar(BarState.Off)
    .height(300)
  }
}
