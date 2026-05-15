import { router } from '@kit.ArkUI';
import { RiskAssessmentResult, RiskItem as AIRiskItem, RiskLevel as AIRiskLevelType, RadarDataItem, getRiskColor, getRiskLabel } from '../models/AIModels';
import { RadarChart } from '../components/RadarChart';
import { getRadarDataFromResult } from '../mock/riskAssessmentMock';
import { AIOrchestrator } from '../ai/orchestrator/AIOrchestrator';
import { AIRequestBuilder } from '../ai/utils/AIRequestBuilder';
import { GlobalVoiceAssistant } from '../components/GlobalVoiceAssistant';

class AssessmentData {
  age: string = '';
  gender: string = '男';
  height: string = '';
  weight: string = '';
  bmi: number = 0;
  systolic: string = '';
  diastolic: string = '';
  fastingGlucose: string = '';
  postprandialGlucose: string = '';
  smoking: string = '否';
  drinking: string = '否';
  exercise: string = '每周1-2次';
  medicalHistory: string[] = [];
}

class RiskLevelInfo {
  level: string = '';
  color: string = '';
  icon: string = '';
  message: string = '';
  constructor(level?: string, color?: string, icon?: string, message?: string) {
    if (level !== undefined) this.level = level;
    if (color !== undefined) this.color = color;
    if (icon !== undefined) this.icon = icon;
    if (message !== undefined) this.message = message;
  }
}

class RiskItemDisplay {
  id: string = '';
  name: string = '';
  level: string = '';
  levelColor: string = '';
  icon: string = '';
  description: string = '';
  value: number = 0;
  constructor(id?: string, name?: string, level?: string, levelColor?: string, icon?: string,
    description?: string, value?: number) {
    if (id !== undefined) this.id = id;
    if (name !== undefined) this.name = name;
    if (level !== undefined) this.level = level;
    if (levelColor !== undefined) this.levelColor = levelColor;
    if (icon !== undefined) this.icon = icon;
    if (description !== undefined) this.description = description;
    if (value !== undefined) this.value = value;
  }
}

class PageParams {
  assessmentData: AssessmentData = new AssessmentData();
  aiResult: RiskAssessmentResult | null = null;
}

@Entry
@Component
struct RiskResultPage {
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  @State riskLevel: RiskLevelInfo = new RiskLevelInfo('低风险', '#52C41A', '🟢', '您的健康状况良好');
  @State riskItems: RiskItemDisplay[] = [];
  @State radarData: RadarDataItem[] = [];
  @State aiSuggestions: string[] = [];
  @State hasValidData: boolean = false;
  @State assessmentData: AssessmentData = new AssessmentData();
  @State aiResult: RiskAssessmentResult | null = null;
  @State overallScore: number = 0;
  @State aiDeepAnalysis: string = '';
  @State isAiAnalyzing: boolean = false;
  @State showAiAnalysis: boolean = false;
  private orchestrator: AIOrchestrator = AIOrchestrator.getInstance();

  aboutToAppear(): void {
    const params = router.getParams() as PageParams;
    if (params && params.assessmentData) {
      const data: AssessmentData = params.assessmentData;
      if (data.age && data.age.trim() !== '') {
        this.assessmentData = data;
        this.hasValidData = true;
        if (params.aiResult) {
          this.aiResult = params.aiResult;
          this.applyAIResult(params.aiResult);
        } else {
          this.calculateRisks();
          this.generateSuggestions();
        }
      }
    }
  }

  private applyAIResult(result: RiskAssessmentResult): void {
    this.overallScore = Math.round(result.overallScore * 100);
    const levelLabel: string = getRiskLabel(result.overallLevel);
    const levelColor: string = getRiskColor(result.overallLevel);
    let icon: string = '🟢';
    let message: string = '您的健康状况良好';

    if (result.overallLevel === AIRiskLevelType.HIGH || result.overallLevel === AIRiskLevelType.CRITICAL) {
      icon = '🔴';
      message = '发现高风险指标，建议尽早就医';
    } else if (result.overallLevel === AIRiskLevelType.MEDIUM) {
      icon = '🟡';
      message = '有指标需要关注，建议改善生活方式';
    }

    this.riskLevel = new RiskLevelInfo(levelLabel, levelColor, icon, message);
    this.riskItems = [
      this.convertRiskItem(result.risks.hypertension, '1', '🩺'),
      this.convertRiskItem(result.risks.diabetes, '2', '💉'),
      this.convertRiskItem(result.risks.fall, '3', '🧓'),
      this.convertRiskItem(result.risks.frailty, '4', '💪'),
      this.convertRiskItem(result.risks.sarcopenia, '5', '🏋️')
    ];
    this.radarData = getRadarDataFromResult(result);
    this.aiSuggestions = result.suggestions;
  }

  private convertRiskItem(item: AIRiskItem, id: string, icon: string): RiskItemDisplay {
    return new RiskItemDisplay(id, item.label, getRiskLabel(item.level), item.color, icon,
      item.description, item.value);
  }

  getLevelBgColor(levelColor: string): string {
    if (levelColor === '#52C41A') {
      return '#F6FFED';
    }
    if (levelColor === '#FAAD14') {
      return '#FFFBE6';
    }
    return '#FFF1F0';
  }

  handleViewReport() {
    router.pushUrl({
      url: 'pages/RiskDetailPage',
      params: { assessmentData: this.assessmentData, aiResult: this.aiResult }
    });
  }

  async getAIDeepAnalysis(): Promise<void> {
    if (this.isAiAnalyzing) return;
    this.isAiAnalyzing = true;
    this.showAiAnalysis = true;
    this.aiDeepAnalysis = '正在生成AI深度解读...';

    try {
      const riskSummary = `综合评分:${this.overallScore}分, 风险等级:${this.riskLevel.level}。` +
        this.riskItems.map(item => `${item.name}:${item.level}(${item.value})`).join('; ') +
        `建议:${this.aiSuggestions.join('; ')}`;

      const userId = String(AppStorage.get('userId') || 'anonymous');
      const request = AIRequestBuilder.createWithIntent(
        `请作为专业健康顾问，对以下风险评估结果进行深度解读，给出个性化建议：${riskSummary}`,
        'risk_deep_analysis',
        userId
      );
      request.preferences = { preferredAgent: 'deepseek' };

      const response = await this.orchestrator.process(request);
      this.aiDeepAnalysis = typeof response.output.content === 'string'
        ? response.output.content
        : JSON.stringify(response.output.content);
    } catch (error) {
      this.aiDeepAnalysis = 'AI深度解读暂时不可用，请稍后重试。当前建议：' +
        this.aiSuggestions.slice(0, 3).join('\n');
    } finally {
      this.isAiAnalyzing = false;
    }
  }

  handleShare() {
    const summaryMsg: string = this.buildAssessmentSummary();
    router.pushUrl({
      url: 'pages/DoctorListPage',
      params: { shareMessage: summaryMsg, shareType: 'riskAssessment' }
    });
  }

  private buildAssessmentSummary(): string {
    let lines: string[] = [];
    lines.push('【健康风险评估报告】');
    lines.push('综合风险等级：' + this.riskLevel.level + ' ' + this.riskLevel.icon);
    if (this.overallScore > 0) {
      lines.push('综合评分：' + this.overallScore + '/100分');
    }
    lines.push('');
    lines.push('五维风险评估详情：');
    for (let i: number = 0; i < this.riskItems.length; i++) {
      const item: RiskItemDisplay = this.riskItems[i];
      const valPercent: number = Math.round(item.value * 100);
      lines.push(item.icon + ' ' + item.name + '：' + item.level + '(' + valPercent + '%)');
      if (item.description && item.description.trim() !== '') {
        lines.push('   → ' + item.description);
      }
    }
    lines.push('');
    if (this.aiSuggestions.length > 0) {
      lines.push('AI建议（前3条）：');
      const showCount: number = Math.min(3, this.aiSuggestions.length);
      for (let i: number = 0; i < showCount; i++) {
        lines.push((i + 1).toString() + '. ' + this.aiSuggestions[i]);
      }
    }
    return lines.join('\n');
  }

  handleReassess() {
    router.pushUrl({ url: 'pages/RiskAssessmentPage' });
  }

  handleRehabPlan() {
    console.log('制定康复计划');
  }

  private calculateRisks(): void {
    const data: AssessmentData = this.assessmentData;
    const items: RiskItemDisplay[] = [];
    let highRiskCount: number = 0;
    let midRiskCount: number = 0;

    const age: number = parseFloat(data.age) || 0;
    const systolic: number = parseFloat(data.systolic) || 0;
    const diastolic: number = parseFloat(data.diastolic) || 0;
    const fastingGlucose: number = parseFloat(data.fastingGlucose) || 0;

    if (systolic > 0 && diastolic > 0) {
      if (systolic >= 140 || diastolic >= 90) {
        items.push(new RiskItemDisplay('1', '高血压', '高风险', '#FF4D4F', '🩺', '血压偏高(' + systolic + '/' + diastolic + 'mmHg)，建议尽快就医检查', 0.7));
        highRiskCount++;
      } else if (systolic >= 120 || diastolic >= 80) {
        items.push(new RiskItemDisplay('1', '高血压', '中风险', '#FAAD14', '🩺', '血压正常偏高(' + systolic + '/' + diastolic + 'mmHg)，建议定期监测', 0.4));
        midRiskCount++;
      } else {
        items.push(new RiskItemDisplay('1', '高血压', '低风险', '#52C41A', '🩺', '血压正常(' + systolic + '/' + diastolic + 'mmHg)，请继续保持', 0.15));
      }
    } else {
      items.push(new RiskItemDisplay('1', '高血压', '低风险', '#52C41A', '🩺', '血压数据正常', 0.1));
    }

    if (fastingGlucose > 0) {
      if (fastingGlucose >= 7.0) {
        items.push(new RiskItemDisplay('2', '糖尿病', '高风险', '#FF4D4F', '💉', '空腹血糖偏高(' + fastingGlucose + 'mmol/L)，建议就医检查', 0.75));
        highRiskCount++;
      } else if (fastingGlucose >= 6.1) {
        items.push(new RiskItemDisplay('2', '糖尿病', '中风险', '#FAAD14', '💉', '空腹血糖偏高(' + fastingGlucose + 'mmol/L)，需注意饮食控制', 0.45));
        midRiskCount++;
      } else {
        items.push(new RiskItemDisplay('2', '糖尿病', '低风险', '#52C41A', '💉', '空腹血糖正常(' + fastingGlucose + 'mmol/L)', 0.1));
      }
    } else {
      items.push(new RiskItemDisplay('2', '糖尿病', '低风险', '#52C41A', '💉', '血糖在正常范围内', 0.1));
    }

    if (age >= 65 || data.medicalHistory.includes('骨质疏松') || (data.exercise === '每周1-2次' && data.smoking === '是')) {
      items.push(new RiskItemDisplay('3', '跌倒', '中风险', '#FAAD14', '🧓', age >= 65 ? '年龄较大，存在跌倒风险，建议加强平衡训练' : '存在跌倒风险因素，建议加强平衡训练', 0.4));
      midRiskCount++;
    } else {
      items.push(new RiskItemDisplay('3', '跌倒', '低风险', '#52C41A', '🧓', '跌倒风险较低', 0.1));
    }

    if (data.bmi < 18.5 || data.bmi >= 27) {
      items.push(new RiskItemDisplay('4', '衰弱', '中风险', '#FAAD14', '💪', 'BMI为' + data.bmi + '，需要注意营养和运动', 0.4));
      midRiskCount++;
    } else if (data.bmi <= 0) {
      items.push(new RiskItemDisplay('4', '衰弱', '低风险', '#52C41A', '💪', '身体状况良好', 0.1));
    } else {
      items.push(new RiskItemDisplay('4', '衰弱', '低风险', '#52C41A', '💪', 'BMI正常(' + data.bmi + ')，身体状况良好', 0.15));
    }

    if (data.bmi < 18.5 || (data.exercise === '每周1-2次' && age >= 60)) {
      items.push(new RiskItemDisplay('5', '肌少症', '中风险', '#FAAD14', '🏋️', '建议增加蛋白质摄入和抗阻运动', 0.35));
      midRiskCount++;
    } else {
      items.push(new RiskItemDisplay('5', '肌少症', '低风险', '#52C41A', '🏋️', '肌肉量正常', 0.1));
    }

    this.riskItems = items;
    this.radarData = [];

    let bpActual: number = systolic;
    let bpUnit: string = 'mmHg';
    let bpL1: number = 119;
    let bpL2Min: number = 120;
    let bpL2Max: number = 139;
    let bpL3Min: number = 140;
    let bpL3Max: number = 180;
    if (systolic <= 0) {
      bpActual = 115; bpL1 = 119; bpL2Min = 120; bpL2Max = 139; bpL3Min = 140; bpL3Max = 180;
    } else if (systolic >= 140 || diastolic >= 90) {
      bpL1 = 119; bpL2Min = 120; bpL2Max = 139; bpL3Min = 140; bpL3Max = 180;
    } else if (systolic >= 120 || diastolic >= 80) {
      bpL1 = 119; bpL2Min = 120; bpL2Max = 139; bpL3Min = 140; bpL3Max = 180;
    }
    const bpItem: RadarDataItem = new RadarDataItem();
    bpItem.label = '高血压';
    bpItem.value = items[0].value;
    bpItem.color = items[0].levelColor;
    bpItem.actualValue = bpActual;
    bpItem.unit = bpUnit;
    bpItem.level1Max = bpL1;
    bpItem.level2Min = bpL2Min;
    bpItem.level2Max = bpL2Max;
    bpItem.level3Min = bpL3Min;
    bpItem.level3Max = bpL3Max;
    this.radarData.push(bpItem);

    let gluActual: number = fastingGlucose;
    if (fastingGlucose <= 0) { gluActual = 5.2; }
    const gluItem: RadarDataItem = new RadarDataItem();
    gluItem.label = '糖尿病';
    gluItem.value = items[1].value;
    gluItem.color = items[1].levelColor;
    gluItem.actualValue = gluActual;
    gluItem.unit = 'mmol/L';
    gluItem.level1Max = 6.09;
    gluItem.level2Min = 6.10;
    gluItem.level2Max = 6.99;
    gluItem.level3Min = 7.00;
    gluItem.level3Max = 12.0;
    this.radarData.push(gluItem);

    let fallActual: number = age;
    if (age <= 0) { fallActual = 45; }
    const fallItem: RadarDataItem = new RadarDataItem();
    fallItem.label = '跌倒风险';
    fallItem.value = items[2].value;
    fallItem.color = items[2].levelColor;
    fallItem.actualValue = fallActual;
    fallItem.unit = '岁';
    fallItem.level1Max = 64.9;
    fallItem.level2Min = 65.0;
    fallItem.level2Max = 75.0;
    fallItem.level3Min = 76.0;
    fallItem.level3Max = 100;
    this.radarData.push(fallItem);

    let bmiVal: number = data.bmi > 0 ? data.bmi : 22;
    if (bmiVal <= 0) { bmiVal = 22; }
    const bmiItem: RadarDataItem = new RadarDataItem();
    bmiItem.label = '衰弱';
    bmiItem.value = items[3].value;
    bmiItem.color = items[3].levelColor;
    bmiItem.actualValue = bmiVal;
    bmiItem.unit = 'kg/m²';
    bmiItem.level1Max = 25.0;
    bmiItem.level2Min = 17.5;
    bmiItem.level2Max = 27.0;
    bmiItem.level3Min = 28.0;
    bmiItem.level3Max = 35.0;
    this.radarData.push(bmiItem);

    let stepsVal: number = data.exercise === '每周3次以上' ? 8000 :
      data.exercise === '每周1-2次' ? 3000 : 6000;
    const stepItem: RadarDataItem = new RadarDataItem();
    stepItem.label = '肌少症';
    stepItem.value = items[4].value;
    stepItem.color = items[4].levelColor;
    stepItem.actualValue = stepsVal;
    stepItem.unit = '步';
    stepItem.level1Max = 5000;
    stepItem.level2Min = 3000;
    stepItem.level2Max = 4999;
    stepItem.level3Min = 1500;
    stepItem.level3Max = 2999;
    this.radarData.push(stepItem);

    if (highRiskCount > 0) {
      this.riskLevel = new RiskLevelInfo('高风险', '#FF4D4F', '🔴', '发现' + highRiskCount + '项高风险指标，建议尽早就医');
    } else if (midRiskCount > 0) {
      this.riskLevel = new RiskLevelInfo('中风险', '#FAAD14', '🟡', '有' + midRiskCount + '项指标需要关注');
    } else {
      this.riskLevel = new RiskLevelInfo('低风险', '#52C41A', '🟢', '您的健康状况良好');
    }
  }

  private generateSuggestions(): void {
    const suggestions: string[] = [];
    const data: AssessmentData = this.assessmentData;
    const systolic: number = parseFloat(data.systolic) || 0;
    const diastolic: number = parseFloat(data.diastolic) || 0;
    const glucose: number = parseFloat(data.fastingGlucose) || 0;
    const bmi: number = data.bmi;

    if (systolic >= 140 || diastolic >= 90) {
      suggestions.push('您的血压偏高，建议减少盐分摄入，每日食盐不超过5g，定期监测血压');
    }
    if (glucose >= 6.1) {
      suggestions.push('您的血糖偏高，建议控制碳水化合物摄入，避免高糖食物');
    }
    if (bmi < 18.5) {
      suggestions.push('您的BMI偏低(' + bmi + ')，建议增加营养摄入，适当进行力量训练');
    } else if (bmi >= 27) {
      suggestions.push('您的BMI偏高(' + bmi + ')，建议控制饮食热量，增加有氧运动');
    }
    if (data.smoking === '是') {
      suggestions.push('吸烟会显著增加心血管疾病风险，建议戒烟或减少吸烟量');
    }
    if (data.drinking === '是') {
      suggestions.push('过量饮酒会影响健康，建议适量饮酒或戒酒');
    }
    if (data.exercise === '每周1-2次') {
      suggestions.push('运动频率偏低，建议逐步增加到每周至少150分钟中等强度运动');
    }
    suggestions.push('保持良好的作息习惯，保证每晚7-8小时充足睡眠');
    this.aiSuggestions = suggestions;
  }

  build() {
    Stack() {
      Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.back();
          });
        Text('评估结果')
          .fontSize(18)
          .fontWeight('bold')
          .flexGrow(1)
          .textAlign(TextAlign.Center);
        Text('历史')
          .fontSize(16)
          .fontColor('#1677FF')
          .padding(12)
          .onClick(() => {
            router.pushUrl({ url: 'pages/RiskHistoryPage' });
          });
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 });

      Scroll() {
        if (this.hasValidData) {
          Column() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Column()
                .width('100%')
                .height('100%')
                .borderRadius(20)
                .linearGradient({
                  angle: 135,
                  colors: [[this.riskLevel.color + 'DD', 0], [this.riskLevel.color + '44', 1]]
                });
              Column() {
                Text(this.riskLevel.icon)
                  .fontSize(56)
                  .margin({ bottom: 12 });
                Text(this.riskLevel.level)
                  .fontSize(36)
                  .fontWeight('bold')
                  .fontColor('#FFFFFF')
                  .margin({ bottom: 8 })
                  .textShadow({ radius: 10, color: '#00000022', offsetX: 0, offsetY: 2 });
                if (this.overallScore > 0) {
                  Text('综合评分: ' + this.overallScore + '分')
                    .fontSize(18)
                    .fontColor('#FFFFFFCC')
                    .margin({ bottom: 4 });
                }
                Text(this.riskLevel.message)
                  .fontSize(16)
                  .fontColor('#FFFFFFCC')
                  .lineHeight(22);
              }
              .width('100%')
              .padding(32)
              .alignItems(HorizontalAlign.Center);
              Circle()
                .width(80)
                .height(80)
                .fill(this.riskLevel.color + '18')
                .margin({ top: -20, right: -20 });
            }
            .width('100%')
            .height(180)
            .borderRadius(20)
            .shadow({ radius: 16, color: this.riskLevel.color + '30', offsetX: 0, offsetY: 8 })
            .margin({ top: 12, bottom: 24 });

            Column() {
              Text('📊 五维风险雷达图')
                .fontSize(18)
                .fontWeight('bold')
                .fontColor('#333333')
                .margin({ bottom: 16 });
              RadarChart({
                data: this.radarData,
                sizeValue: 300,
                showValue: true,
                animated: true
              });
              Row({ space: 20 }) {
                Row({ space: 6 }) {
                  Circle().width(10).height(10).fill('#52C41A');
                  Text('低风险(0-30%)').fontSize(11).fontColor('#666666');
                }
                Row({ space: 6 }) {
                  Circle().width(10).height(10).fill('#FAAD14');
                  Text('中风险(30-60%)').fontSize(11).fontColor('#666666');
                }
                Row({ space: 6 }) {
                  Circle().width(10).height(10).fill('#FF4D4F');
                  Text('高风险(60%+)').fontSize(11).fontColor('#666666');
                }
              }
              .margin({ top: 12, bottom: 8 });
              if (this.aiResult) {
                Text('AI模型: ' + this.aiResult.modelVersion + ' | 耗时: ' + this.aiResult.processingTimeMs + 'ms')
                  .fontSize(11)
                  .fontColor('#999999')
                  .margin({ top: 4 });
              }
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: 2 })
            .alignItems(HorizontalAlign.Center)
            .margin({ bottom: 24 });

            Row() {
              Text('📋 风险详情')
                .fontSize(18)
                .fontWeight('bold')
                .fontColor('#333333');
              Blank();
              Text('共 ' + this.riskItems.length + ' 项指标')
                .fontSize(12)
                .fontColor('#999999')
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor('#F5F5F5')
                .borderRadius(10);
            }
            .width('100%')
            .margin({ bottom: 16 });

            ForEach(this.riskItems, (item: RiskItemDisplay) => {
              Column() {
                Row() {
                  Column() {
                    Text(item.icon)
                      .fontSize(28);
                    Text(item.name)
                      .fontSize(11)
                      .fontColor('#999999')
                      .margin({ top: 2 });
                  }
                  .width(48);
                  Column() {
                    Row() {
                      Text(item.level)
                        .fontSize(14)
                        .fontWeight('bold')
                        .fontColor(item.levelColor)
                        .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                        .backgroundColor(this.getLevelBgColor(item.levelColor))
                        .borderRadius(8);
                      Blank();
                      Text(Math.round(item.value * 100) + '%')
                        .fontSize(14)
                        .fontWeight('bold')
                        .fontColor(item.levelColor);
                    }
                    .width('100%');
                    Progress({ value: item.value * 100, total: 100, type: ProgressType.Linear })
                      .width('100%')
                      .height(6)
                      .color(item.levelColor)
                      .backgroundColor('#F0F0F0')
                      .margin({ top: 8, bottom: 4 });
                    Text(item.description)
                      .fontSize(13)
                      .fontColor('#666666')
                      .margin({ top: 2 })
                      .lineHeight(20);
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%');
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(14)
              .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: 2 })
              .margin({ bottom: 10 });
            });

            Column({ space: 14 }) {
              Row() {
                Row({ space: 8 }) {
                  Text('🤖')
                    .fontSize(20);
                  Text('AI 智能解读建议')
                    .fontSize(17)
                    .fontWeight('bold')
                    .fontColor('#333333');
                }
                Blank();
                Text('基于您的数据生成')
                  .fontSize(11)
                  .fontColor('#1677FF')
                  .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                  .backgroundColor('#E8F0FF')
                  .borderRadius(10);
              }
              .width('100%');
              ForEach(this.aiSuggestions, (suggestion: string, index: number) => {
                Row({ space: 10 }) {
                  Text((index + 1).toString())
                    .fontSize(13)
                    .fontWeight('bold')
                    .fontColor('#FFFFFF')
                    .width(22)
                    .height(22)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#1677FF')
                    .borderRadius(11);
                  Text(suggestion)
                    .fontSize(13)
                    .fontColor('#555555')
                    .flexGrow(1)
                    .lineHeight(21);
                }
                .width('100%')
                .margin({ bottom: 6 });
              });
            }
            .width('100%')
            .padding(18)
            .backgroundColor('#F8FAFF')
            .borderRadius(16)
            .border({ width: 1, color: '#E8F0FF', style: BorderStyle.Solid })
            .margin({ top: 24, bottom: 12 });

            if (!this.showAiAnalysis) {
              Button('🧠 AI 深度解读')
                .width('100%')
                .height(48)
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#FFFFFF')
                .backgroundColor('#6366F1')
                .borderRadius(24)
                .shadow({ radius: 10, color: '#6366F144', offsetX: 0, offsetY: 4 })
                .margin({ bottom: 24 })
                .onClick(() => this.getAIDeepAnalysis());
            }

            if (this.showAiAnalysis) {
              Column({ space: 12 }) {
                Row() {
                  Row({ space: 8 }) {
                    Text('🧠')
                      .fontSize(20);
                    Text('AI 深度解读')
                      .fontSize(17)
                      .fontWeight('bold')
                      .fontColor('#333333');
                  }
                  Blank();
                  if (this.isAiAnalyzing) {
                    LoadingProgress()
                      .width(20)
                      .height(20)
                      .color('#6366F1');
                  } else {
                    Text('DeepSeek')
                      .fontSize(11)
                      .fontColor('#6366F1')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor('#EEF2FF')
                      .borderRadius(8);
                  }
                }
                .width('100%');

                Scroll() {
                  Text(this.aiDeepAnalysis)
                    .fontSize(14)
                    .fontColor('#475569')
                    .lineHeight(24)
                }
                .width('100%')
                .constraintSize({ maxHeight: 240 })
              }
              .width('100%')
              .padding(18)
              .backgroundColor('#FAFAFE')
              .borderRadius(16)
              .border({ width: 1, color: '#E0E7FF', style: BorderStyle.Solid })
              .margin({ bottom: 24 });
            }

            Column({ space: 12 }) {
              Button('查看详细报告')
                .width('100%')
                .height(50)
                .fontSize(15)
                .fontWeight('bold')
                .fontColor('#FFFFFF')
                .backgroundColor('#1677FF')
                .borderRadius(25)
                .shadow({ radius: 10, color: '#1677FF44', offsetX: 0, offsetY: 4 })
                .onClick(() => {
                  this.handleViewReport();
                });
              Row() {
                Button('分享给医生')
                  .layoutWeight(1)
                  .height(46)
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(23)
                  .border({ width: 1.5, color: '#1677FF' })
                  .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
                  .onClick(() => {
                    this.handleShare();
                  });
                Button('重新评估')
                  .layoutWeight(1)
                  .height(46)
                  .fontSize(14)
                  .fontColor('#666666')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(23)
                  .border({ width: 1, color: '#E0E0E0' })
                  .margin({ left: 12 })
                  .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: 2 })
                  .onClick(() => {
                    this.handleReassess();
                  });
              }
              .width('100%');
              Button('制定康复计划')
                .width('100%')
                .height(46)
                .fontSize(14)
                .fontColor('#52C41A')
                .backgroundColor('#F6FFED')
                .borderRadius(23)
                .border({ width: 1, color: '#B7EB8F' })
                .onClick(() => {
                  this.handleRehabPlan();
                });
            }
            .width('100%')
            .margin({ bottom: 40 });
          }
          .width('90%')
          .padding({ top: 16, bottom: 32 });
        } else {
          Column() {
            Stack({ alignContent: Alignment.BottomStart }) {
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 135,
                  colors: [['#E8E8E8', 0], ['#F5F5F5', 1]]
                })
                .borderRadius({ topLeft: 20, topRight: 20, bottomLeft: 16, bottomRight: 16 });
              Column() {
                Text('📋')
                  .fontSize(64)
                  .margin({ bottom: 20 });
                Text('暂无评估数据')
                  .fontSize(24)
                  .fontWeight('bold')
                  .fontColor('#333333')
                  .margin({ bottom: 10 });
                Text('完成健康风险评估后，这里将展示您的专属报告')
                  .fontSize(14)
                  .fontColor('#999999')
                  .textAlign(TextAlign.Center)
                  .lineHeight(22)
                  .width('80%');
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .padding({ bottom: 32 });
            }
            .width('90%')
            .margin({ top: 40, bottom: 32 });
            Button('开始健康评估')
              .width('60%')
              .height(50)
              .fontSize(16)
              .fontWeight('bold')
              .fontColor('#FFFFFF')
              .backgroundColor('#1677FF')
              .borderRadius(25)
              .shadow({ radius: 10, color: '#1677FF44', offsetX: 0, offsetY: 4 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/RiskAssessmentPage' });
              });
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text('📊')
                  .fontSize(24);
                Text('历史记录')
                  .fontSize(11)
                  .fontColor('#666666');
              }
              .layoutWeight(1)
              .height(70)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/RiskHistoryPage' });
              });
              Column({ space: 6 }) {
                Text('👨‍⚕️')
                  .fontSize(24);
                Text('咨询医生')
                  .fontSize(11)
                  .fontColor('#666666');
              }
              .layoutWeight(1)
              .height(70)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({ radius: 4, color: '#00000006', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/DoctorListPage' });
              });
            }
            .width('85%')
            .margin({ top: 24 });
          }
          .width('90%')
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Center);
        }
      }
      .height(0)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA');

      GlobalVoiceAssistant()
    }
    .width('100%')
    .height('100%')
  }
}