import { router } from '@kit.ArkUI';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Loading } from '../components/Loading';
import { EmptyState } from '../components/EmptyState';
import { GlobalTheme } from '../global';
import { OrganInfo, OrganMetric, OrganPosition } from '../digitaltwin/OrganVisualizer';

interface HealthScoreData {
  score: number;
  status: string;
}

@Entry
@Component
struct OrganDetailPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;

  @State organId: string = '';
  @State organName: string = '';
  @State healthScore: number = 0;
  @State healthStatus: string = '';
  @State isLoading: boolean = true;
  @State currentDefinition: OrganInfo | null = null;
  @State currentMetrics: OrganMetric[] = [];

  private heartRiskFactors: string[] = ['高血压', '高血脂', '吸烟', '肥胖', '缺乏运动', '家族病史'];
  private heartSymptoms: string[] = ['胸痛或胸闷', '心悸或心跳不规则', '呼吸困难', '极度疲劳', '头晕或晕厥'];
  private lungsRiskFactors: string[] = ['吸烟', '空气污染', '职业暴露（粉尘/化学品）', '呼吸道感染史'];
  private lungsSymptoms: string[] = ['持续咳嗽', '咳痰', '呼吸急促', '胸闷或胸痛', '喘息声'];
  private liverRiskFactors: string[] = ['长期饮酒', '脂肪肝', '病毒性肝炎', '药物滥用', '肥胖'];
  private liverSymptoms: string[] = ['乏力或疲劳', '食欲下降', '恶心或呕吐', '腹部不适或疼痛', '皮肤或眼白发黄'];
  private kidneyRiskFactors: string[] = ['高血压', '糖尿病', '肾结石', '长期使用肾毒性药物', '脱水'];
  private kidneySymptoms: string[] = ['水肿（尤其是脚踝）', '尿量变化', '尿中带泡沫', '腰背部疼痛', '疲劳乏力'];
  private brainRiskFactors: string[] = ['高血压', '糖尿病', '动脉硬化', '睡眠障碍', '头部外伤史'];
  private brainSymptoms: string[] = ['头痛', '记忆力减退', '注意力难以集中', '情绪波动', '睡眠障碍'];
  private pancreasRiskFactors: string[] = ['肥胖', '酗酒', '胆石症', '遗传因素', '高脂饮食'];
  private pancreasSymptoms: string[] = ['上腹痛', '恶心呕吐', '血糖波动', '消化不良', '体重下降'];

  private heartPos: OrganPosition = { x: 0, y: 180 };
  private lungsPos: OrganPosition = { x: -25, y: 175 };
  private liverPos: OrganPosition = { x: 15, y: 220 };
  private kidneyPos: OrganPosition = { x: 0, y: 260 };
  private brainPos: OrganPosition = { x: 0, y: 60 };
  private pancreasPos: OrganPosition = { x: -20, y: 235 };

  private heartMetrics: OrganMetric[] = [
    { name: '心率', value: 72, unit: 'bpm', normalMin: 60, normalMax: 100, isNormal: true },
    { name: '收缩压', value: 128, unit: 'mmHg', normalMin: 90, normalMax: 140, isNormal: true },
    { name: '舒张压', value: 82, unit: 'mmHg', normalMin: 60, normalMax: 90, isNormal: true },
    { name: '心电图', value: 1, unit: '正常', normalMin: 1, normalMax: 1, isNormal: true }
  ];

  private lungsMetrics: OrganMetric[] = [
    { name: '血氧饱和度', value: 96, unit: '%', normalMin: 95, normalMax: 100, isNormal: true },
    { name: '肺活量', value: 3.2, unit: 'L', normalMin: 3.5, normalMax: 5.0, isNormal: false },
    { name: '呼吸频率', value: 16, unit: '次/分', normalMin: 12, normalMax: 20, isNormal: true }
  ];

  private liverMetrics: OrganMetric[] = [
    { name: 'ALT(谷丙转氨酶)', value: 28, unit: 'U/L', normalMin: 0, normalMax: 40, isNormal: true },
    { name: 'AST(谷草转氨酶)', value: 25, unit: 'U/L', normalMin: 0, normalMax: 40, isNormal: true },
    { name: '总胆红素', value: 14, unit: 'μmol/L', normalMin: 0, normalMax: 17, isNormal: true }
  ];

  private kidneyMetrics: OrganMetric[] = [
    { name: '肌酐', value: 78, unit: 'μmol/L', normalMin: 44, normalMax: 133, isNormal: true },
    { name: '尿素氮', value: 5.2, unit: 'mmol/L', normalMin: 2.5, normalMax: 7.1, isNormal: true },
    { name: '尿酸', value: 380, unit: 'μmol/L', normalMin: 150, normalMax: 420, isNormal: true }
  ];

  private brainMetrics: OrganMetric[] = [];

  private pancreasMetrics: OrganMetric[] = [
    { name: '空腹血糖', value: 5.6, unit: 'mmol/L', normalMin: 3.9, normalMax: 6.1, isNormal: true },
    { name: '糖化血红蛋白', value: 5.8, unit: '%', normalMin: 4.0, normalMax: 6.0, isNormal: true }
  ];

  private heartDef: OrganInfo = {} as OrganInfo;
  private lungsDef: OrganInfo = {} as OrganInfo;
  private liverDef: OrganInfo = {} as OrganInfo;
  private kidneyDef: OrganInfo = {} as OrganInfo;
  private brainDef: OrganInfo = {} as OrganInfo;
  private pancreasDef: OrganInfo = {} as OrganInfo;

  getOrganDefinition(organId: string): OrganInfo | null {
    switch (organId) {
      case 'heart':
        return this.heartDef;
      case 'lungs':
        return this.lungsDef;
      case 'liver':
        return this.liverDef;
      case 'kidney':
        return this.kidneyDef;
      case 'brain':
        return this.brainDef;
      case 'pancreas':
        return this.pancreasDef;
      default:
        return null;
    }
  }

  getMockMetrics(organId: string): OrganMetric[] {
    switch (organId) {
      case 'heart':
        return this.heartMetrics;
      case 'lungs':
        return this.lungsMetrics;
      case 'liver':
        return this.liverMetrics;
      case 'kidney':
        return this.kidneyMetrics;
      case 'brain':
        return this.brainMetrics;
      case 'pancreas':
        return this.pancreasMetrics;
      default:
        return [];
    }
  }

  getMockScore(organId: string): HealthScoreData | null {
    switch (organId) {
      case 'heart': {
        const _data: HealthScoreData = { score: 85, status: 'healthy' };
        return _data;
      }
      case 'lungs': {
        const _data: HealthScoreData = { score: 78, status: 'sub_healthy' };
        return _data;
      }
      case 'liver': {
        const _data: HealthScoreData = { score: 92, status: 'healthy' };
        return _data;
      }
      case 'kidney': {
        const _data: HealthScoreData = { score: 88, status: 'healthy' };
        return _data;
      }
      case 'brain': {
        const _data: HealthScoreData = { score: 82, status: 'healthy' };
        return _data;
      }
      case 'pancreas': {
        const _data: HealthScoreData = { score: 75, status: 'sub_healthy' };
        return _data;
      }
      default:
        return null;
    }
  }

  private initOrganDef(def: OrganInfo, id: string, name: string, nameEn: string, icon: string,
    category: 'cardiovascular' | 'respiratory' | 'digestive' | 'nervous' | 'urinary' | 'endocrine',
    pos: OrganPosition, normalRange: string, risks: string[], syms: string[]): void {
    def.id = id;
    def.name = name;
    def.nameEn = nameEn;
    def.icon = icon;
    def.category = category;
    def.position = pos;
    def.normalRange = normalRange;
    def.riskFactors = risks;
    def.symptoms = syms;
  }

  aboutToAppear(): void {
    if (AppStorage.get<boolean>('isOldModeEnabled') === undefined) {
      AppStorage.setOrCreate<boolean>('isOldModeEnabled', false);
    } else {
      this.isElderMode = AppStorage.get<boolean>('isOldModeEnabled') || false;
    }

    this.initOrganDef(this.heartDef, 'heart', '心脏', 'Heart', '❤️', 'cardiovascular',
      this.heartPos, '心率60-100次/分，血压90-140/60-90mmHg',
      this.heartRiskFactors, this.heartSymptoms);

    this.initOrganDef(this.lungsDef, 'lungs', '肺部', 'Lungs', '🫁', 'respiratory',
      this.lungsPos, '血氧饱和度95-100%，肺活量3.5-5.0L',
      this.lungsRiskFactors, this.lungsSymptoms);

    this.initOrganDef(this.liverDef, 'liver', '肝脏', 'Liver', '🟤', 'digestive',
      this.liverPos, 'ALT<40U/L，AST<40U/L，胆红素<17μmol/L',
      this.liverRiskFactors, this.liverSymptoms);

    this.initOrganDef(this.kidneyDef, 'kidney', '肾脏', 'Kidney', '🫘', 'urinary',
      this.kidneyPos, '肌酐44-133μmol/L，尿素2.5-7.1mmol/L',
      this.kidneyRiskFactors, this.kidneySymptoms);

    this.initOrganDef(this.brainDef, 'brain', '大脑', 'Brain', '🧠', 'nervous',
      this.brainPos, '认知功能正常，无异常神经体征',
      this.brainRiskFactors, this.brainSymptoms);

    this.initOrganDef(this.pancreasDef, 'pancreas', '胰腺', 'Pancreas', '🔶', 'endocrine',
      this.pancreasPos, '空腹血糖3.9-6.1mmol/L，淀粉酶40-180U/L',
      this.pancreasRiskFactors, this.pancreasSymptoms);

    try {
      const params = router.getParams() as Record<string, Object> | undefined;

      if (params && params['organId']) {
        this.organId = String(params['organId']);

        const definition: OrganInfo | null = this.getOrganDefinition(this.organId);
        if (definition) {
          this.organName = definition.name;
          this.currentDefinition = definition;
        }

        const scoreData: HealthScoreData | null = this.getMockScore(this.organId);
        if (scoreData) {
          this.healthScore = scoreData.score;
          this.healthStatus = scoreData.status;
        }

        this.currentMetrics = this.getMockMetrics(this.organId);
      }
    } catch (error) {
      console.error('获取器官参数失败:', error);
    }

    setTimeout(() => {
      this.isLoading = false;
    }, 500);
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'healthy':
        return '#52C41A';
      case 'sub_healthy':
        return '#FAAD14';
      case 'high_risk':
        return '#FF7A45';
      case 'diseased':
        return '#FF4D4F';
      default:
        return '#999999';
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'healthy':
        return '健康';
      case 'sub_healthy':
        return '亚健康';
      case 'high_risk':
        return '高危';
      case 'diseased':
        return '异常';
      default:
        return '未知';
    }
  }

  getCategoryName(category: string): string {
    switch (category) {
      case 'cardiovascular':
        return '心血管系统';
      case 'respiratory':
        return '呼吸系统';
      case 'digestive':
        return '消化系统';
      case 'nervous':
        return '神经系统';
      case 'urinary':
        return '泌尿系统';
      case 'endocrine':
        return '内分泌系统';
      default:
        return '其他';
    }
  }

  build() {
    Column() {
      Header({ title: this.organName || '器官详情', showBack: true });

      if (this.isLoading) {
        Loading({ text: '加载器官信息...' })
      } else {
        Scroll() {
          Column() {
            if (this.currentDefinition) {
              Row() {
                Text(this.currentDefinition.icon)
                  .fontSize(48)

                Column() {
                  Text(this.organName)
                    .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
                    .fontWeight(FontWeight.Bold)
                    .fontColor(GlobalTheme.TEXT_PRIMARY)

                  Text(this.currentDefinition.nameEn + ' · ' + this.getCategoryName(this.currentDefinition.category))
                    .fontSize(GlobalTheme.getFontSizeSmall(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_SECONDARY)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 16 })
                .layoutWeight(1)

                Column() {
                  Text(`${this.healthScore}`)
                    .fontSize(GlobalTheme.getFontSizeTitle(this.isElderMode))
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getStatusColor(this.healthStatus))

                  Text(this.getStatusText(this.healthStatus))
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontColor('#FFFFFF')
                    .backgroundColor(this.getStatusColor(this.healthStatus))
                    .borderRadius(12)
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding(20)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ bottom: 16 })

              Text('📊 健康指标')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight(FontWeight.Medium)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .width('100%')
                .margin({ bottom: 12 })

              if (this.currentMetrics.length > 0) {
                ForEach(this.currentMetrics, (metric: OrganMetric, _index: number) => {
                  Column() {
                    Row() {
                      Text(metric.name)
                        .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                        .fontWeight(FontWeight.Medium)
                        .fontColor(GlobalTheme.TEXT_PRIMARY)

                      Blank()

                      Text(`${metric.value}${metric.unit}`)
                        .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                        .fontWeight(FontWeight.Bold)
                        .fontColor(metric.isNormal ? GlobalTheme.SUCCESS_COLOR : GlobalTheme.ERROR_COLOR)
                    }
                    .width('100%')

                    Row() {
                      Text(`参考值: ${metric.normalMin}-${metric.normalMax}${metric.unit}`)
                        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                        .fontColor(GlobalTheme.TEXT_SECONDARY)

                      Blank()

                      Text(metric.isNormal ? '✅ 正常' : '⚠️ 异常')
                        .fontSize(GlobalTheme.getFontSizeTiny(this.isElderMode))
                        .fontColor(metric.isNormal ? GlobalTheme.SUCCESS_COLOR : GlobalTheme.WARNING_COLOR)
                    }
                    .width('100%')
                    .margin({ top: 4 })

                    Row() {
                      Text('')
                        .width('100%')
                        .height(4)
                        .borderRadius(2)
                        .backgroundColor('#F0F0F0')
                    }
                    .width('100%')
                    .margin({ top: 8 })

                    Row() {
                      Text('')
                        .width(`${Math.min((metric.value / metric.normalMax) * 100, 100)}%`)
                        .height(4)
                        .borderRadius(2)
                        .backgroundColor(metric.isNormal ? GlobalTheme.SUCCESS_COLOR : GlobalTheme.ERROR_COLOR)
                    }
                    .width('100%')
                  }
                  .width('100%')
                  .padding(14)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .margin({ bottom: 8 })
                }, (_metric: OrganMetric, index: number) => `${index}`)
              } else {
                Column() {
                  Text('暂无详细指标数据')
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_HINT)
                }
                .width('100%')
                .height(80)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
              }

              Text(`📋 正常范围`)
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight(FontWeight.Medium)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .width('100%')
                .margin({ top: 16, bottom: 8 })

              Text(this.currentDefinition.normalRange || '')
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontColor(GlobalTheme.THEME_COLOR)
                .width('100%')
                .padding(14)
                .backgroundColor('#E6F7FF')
                .borderRadius(12)

              Text('⚠️ 风险因素')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight(FontWeight.Medium)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .width('100%')
                .margin({ top: 16, bottom: 8 })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.currentDefinition.riskFactors, (_factor: string, _index: number) => {
                  Text(_factor)
                    .fontSize(13)
                    .fontColor('#FF7A45')
                    .backgroundColor('#FFF7E6')
                    .borderRadius(16)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .margin({ right: 8, bottom: 8 })
                }, (_factor: string, index: number) => `${index}`)
              }
              .width('100%')

              Text('🩺 常见症状')
                .fontSize(GlobalTheme.getFontSizeSubtitle(this.isElderMode))
                .fontWeight(FontWeight.Medium)
                .fontColor(GlobalTheme.TEXT_PRIMARY)
                .width('100%')
                .margin({ top: 16, bottom: 8 })

              ForEach(this.currentDefinition.symptoms, (_symptom: string, _index: number) => {
                Row() {
                  Text('•')
                    .fontColor(GlobalTheme.THEME_COLOR)
                    .fontSize(16)
                  Text(_symptom)
                    .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                    .fontColor(GlobalTheme.TEXT_PRIMARY)
                    .margin({ left: 8 })
                }
                .width('100%')
                .padding(10)
                .backgroundColor(_index % 2 === 0 ? '#FAFBFC' : '#FFFFFF')
                .borderRadius(8)
              }, (_symptom: string, index: number) => `${index}`)

              Button('返回数字孪生主页面')
                .width('100%')
                .height(GlobalTheme.getButtonHeight(this.isElderMode))
                .fontSize(GlobalTheme.getFontSizeBody(this.isElderMode))
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .backgroundColor(GlobalTheme.THEME_COLOR)
                .borderRadius(GlobalTheme.RADIUS_LG)
                .margin({ top: 24 })
                .onClick(() => {
                  router.back();
                })
            } else {
              EmptyState({
                title: '未找到器官信息',
                description: '请选择有效的器官'
              })
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
}
