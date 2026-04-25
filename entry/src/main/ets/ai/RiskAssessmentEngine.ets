import { HealthInputData, RiskAssessmentResult, RiskItem, RiskLevel, RiskRisksMap, getRiskLevel, getRiskColor, getRiskLabel } from '../models/AIModels';
import { HealthFeatureExtractor } from './HealthFeatureExtractor';

class SuggestionRule {
  riskKey: string = '';
  minThreshold: number = 0;
  maxThreshold: number = 0;
  suggestions: string[] = [];

  constructor(riskKey?: string, minThreshold?: number, maxThreshold?: number, suggestions?: string[]) {
    if (riskKey !== undefined) this.riskKey = riskKey;
    if (minThreshold !== undefined) this.minThreshold = minThreshold;
    if (maxThreshold !== undefined) this.maxThreshold = maxThreshold;
    if (suggestions !== undefined) this.suggestions = suggestions;
  }
}

export class RiskAssessmentEngine {
  private static instance: RiskAssessmentEngine | null = null;
  private isModelLoaded: boolean = false;
  private useFallback: boolean = true;

  private readonly WEIGHTS: number[] = [0.25, 0.25, 0.15, 0.20, 0.15];

  private readonly SUGGESTION_RULES: SuggestionRule[] = [
    new SuggestionRule('hypertension', 0.6, 1.0, [
      '控制盐摄入，每日不超过5g',
      '定期监测血压，建议每天早晚各一次',
      '减少高脂肪食物摄入，增加蔬菜水果',
      '遵医嘱服用降压药物，不可自行停药',
      '每周至少150分钟中等强度有氧运动',
      '限制饮酒，男性每日酒精量不超过25g',
      '保持情绪稳定，避免过度紧张和焦虑',
      '3个月后复查血压，评估治疗效果'
    ]),
    new SuggestionRule('hypertension', 0.3, 0.6, [
      '注意低盐饮食，每日盐摄入不超过6g',
      '每周至少3次有氧运动，每次30分钟以上',
      '保持健康体重，BMI控制在18.5-24之间',
      '定期监测血压，建议每周至少2次'
    ]),
    new SuggestionRule('diabetes', 0.6, 1.0, [
      '严格控制碳水化合物摄入，选择低GI食物',
      '每日监测空腹及餐后血糖',
      '遵医嘱使用降糖药物或胰岛素',
      '增加膳食纤维摄入，每日25-30g',
      '规律运动有助于提高胰岛素敏感性',
      '定期检查糖化血红蛋白(HbA1c)',
      '注意足部护理，预防糖尿病足',
      '3个月后复查血糖及相关指标'
    ]),
    new SuggestionRule('diabetes', 0.3, 0.6, [
      '控制甜食和精制碳水摄入',
      '增加全谷物和蔬菜比例',
      '保持规律运动，每周至少150分钟',
      '定期监测血糖，建议每月至少1次'
    ]),
    new SuggestionRule('fall', 0.6, 1.0, [
      '居家环境改造：安装扶手、防滑垫、夜灯',
      '进行平衡训练：太极拳、站立练习',
      '定期检查视力，佩戴合适的眼镜',
      '穿防滑鞋，避免穿拖鞋外出',
      '起床时先坐1-2分钟再站立',
      '评估药物副作用，避免使用影响平衡的药物',
      '使用辅助行走工具（拐杖/助行器）'
    ]),
    new SuggestionRule('fall', 0.3, 0.6, [
      '适当增加平衡训练，如太极拳',
      '注意居家安全，保持地面干燥',
      '定期进行骨密度检查',
      '保证充足的维生素D和钙摄入'
    ]),
    new SuggestionRule('frailty', 0.6, 1.0, [
      '制定个性化营养方案，保证蛋白质摄入1.0-1.2g/kg/天',
      '进行渐进式抗阻训练，每周2-3次',
      '补充维生素D，每日800-1000IU',
      '保证充足睡眠，每晚7-8小时',
      '定期评估躯体功能，监测衰弱进展',
      '参与社交活动，预防抑郁和认知下降',
      '定期体检，关注慢性病管理'
    ]),
    new SuggestionRule('frailty', 0.3, 0.6, [
      '增加蛋白质摄入，保证每餐有优质蛋白',
      '适度进行力量训练，如弹力带练习',
      '保持规律作息，避免久坐不动',
      '定期进行衰弱评估'
    ]),
    new SuggestionRule('sarcopenia', 0.6, 1.0, [
      '增加蛋白质摄入至1.2-1.5g/kg/天',
      '进行系统性抗阻训练，重点锻炼大肌群',
      '补充亮氨酸和HMB，促进肌肉合成',
      '保证维生素D充足，每日800-1000IU',
      '避免长时间卧床，保持日常活动量',
      '定期评估肌肉量和肌力',
      '必要时咨询营养师制定饮食方案'
    ]),
    new SuggestionRule('sarcopenia', 0.3, 0.6, [
      '保证每日蛋白质摄入达到1.0g/kg',
      '每周进行2-3次力量训练',
      '注意补充钙和维生素D',
      '保持日常活动，避免久坐'
    ])
  ];

  static getInstance(): RiskAssessmentEngine {
    if (RiskAssessmentEngine.instance === null) {
      RiskAssessmentEngine.instance = new RiskAssessmentEngine();
    }
    return RiskAssessmentEngine.instance;
  }

  async assessRisk(healthData: HealthInputData, historyData?: HealthInputData[]): Promise<RiskAssessmentResult> {
    const startTime: number = Date.now();
    const features: number[] = HealthFeatureExtractor.extractFeatures(healthData);

    let probabilities: number[];
    try {
      if (!this.useFallback && this.isModelLoaded) {
        probabilities = await this.runInference(features);
      } else {
        probabilities = this.ruleBasedAssess(healthData, features);
      }
    } catch (e) {
      probabilities = this.ruleBasedAssess(healthData, features);
    }

    const overallScore: number = this.calculateOverallScore(probabilities);
    const overallLevel: RiskLevel = getRiskLevel(overallScore);
    const suggestions: string[] = this.generateSuggestions(probabilities, healthData);

    const result: RiskAssessmentResult = new RiskAssessmentResult(
      this.generateId(),
      new Date().toISOString(),
      new RiskRisksMap(
        this.buildRiskItem(probabilities[0], 'hypertension', '高血压', healthData),
        this.buildRiskItem(probabilities[1], 'diabetes', '糖尿病', healthData),
        this.buildRiskItem(probabilities[2], 'fall', '跌倒', healthData),
        this.buildRiskItem(probabilities[3], 'frailty', '衰弱', healthData),
        this.buildRiskItem(probabilities[4], 'sarcopenia', '肌少症', healthData)
      ),
      overallScore,
      overallLevel,
      suggestions,
      this.useFallback ? 'rule-based-v1' : 'mindspore-v1.0.0',
      Date.now() - startTime
    );

    return result;
  }

  private ruleBasedAssess(data: HealthInputData, features: number[]): number[] {
    const hypertensionRisk: number = this.assessHypertensionRule(data, features);
    const diabetesRisk: number = this.assessDiabetesRule(data, features);
    const fallRisk: number = this.assessFallRule(data, features);
    const frailtyRisk: number = this.assessFrailtyRule(data, features);
    const sarcopeniaRisk: number = this.assessSarcopeniaRule(data, features);
    return [hypertensionRisk, diabetesRisk, fallRisk, frailtyRisk, sarcopeniaRisk];
  }

  private assessHypertensionRule(data: HealthInputData, features: number[]): number {
    let risk: number = 0;
    if (data.systolic >= 180 || data.diastolic >= 110) {
      risk = 0.9;
    } else if (data.systolic >= 140 || data.diastolic >= 90) {
      risk = 0.7;
    } else if (data.systolic >= 120 || data.diastolic >= 80) {
      risk = 0.4;
    } else {
      risk = 0.15;
    }
    if (data.age >= 65) {
      risk += 0.1;
    }
    if (data.smoking) {
      risk += 0.08;
    }
    if (data.drinking) {
      risk += 0.05;
    }
    if (data.bmi >= 28) {
      risk += 0.07;
    }
    return Math.min(1, risk);
  }

  private assessDiabetesRule(data: HealthInputData, features: number[]): number {
    let risk: number = 0;
    if (data.fastingGlucose >= 7.0) {
      risk = 0.85;
    } else if (data.fastingGlucose >= 6.1) {
      risk = 0.55;
    } else if (data.fastingGlucose >= 5.6) {
      risk = 0.35;
    } else {
      risk = 0.1;
    }
    if (data.bmi >= 28) {
      risk += 0.1;
    }
    if (data.age >= 45) {
      risk += 0.08;
    }
    if (data.exerciseFrequency < 2) {
      risk += 0.07;
    }
    return Math.min(1, risk);
  }

  private assessFallRule(data: HealthInputData, features: number[]): number {
    let risk: number = 0;
    if (data.age >= 80) {
      risk = 0.7;
    } else if (data.age >= 70) {
      risk = 0.5;
    } else if (data.age >= 65) {
      risk = 0.35;
    } else {
      risk = 0.1;
    }
    if (data.medicalHistory.indexOf('骨质疏松') >= 0) {
      risk += 0.15;
    }
    if (data.medicalHistory.indexOf('帕金森') >= 0) {
      risk += 0.12;
    }
    if (data.exerciseFrequency < 2) {
      risk += 0.08;
    }
    return Math.min(1, risk);
  }

  private assessFrailtyRule(data: HealthInputData, features: number[]): number {
    let risk: number = 0;
    if (data.age >= 80) {
      risk += 0.25;
    } else if (data.age >= 70) {
      risk += 0.15;
    } else if (data.age >= 65) {
      risk += 0.08;
    }
    if (data.bmi < 18.5) {
      risk += 0.2;
    } else if (data.bmi > 28) {
      risk += 0.12;
    }
    if (data.exerciseFrequency < 2) {
      risk += 0.15;
    }
    if (data.sleepDuration < 6 || data.sleepDuration > 9) {
      risk += 0.1;
    }
    if (data.medicalHistory.length >= 3) {
      risk += 0.12;
    }
    return Math.min(1, risk);
  }

  private assessSarcopeniaRule(data: HealthInputData, features: number[]): number {
    let risk: number = 0;
    if (data.age < 60) {
      return 0.08;
    }
    if (data.age >= 80) {
      risk += 0.3;
    } else if (data.age >= 70) {
      risk += 0.2;
    } else {
      risk += 0.1;
    }
    if (data.bmi < 18.5) {
      risk += 0.25;
    } else if (data.bmi < 20) {
      risk += 0.12;
    }
    if (data.exerciseFrequency < 2) {
      risk += 0.15;
    }
    if (data.medicalHistory.indexOf('骨质疏松') >= 0) {
      risk += 0.1;
    }
    return Math.min(1, risk);
  }

  private async runInference(features: number[]): Promise<number[]> {
    return new Promise((resolve, reject) => {
      try {
        setTimeout(() => {
          const data: HealthInputData = new HealthInputData(
            features[0] * 100,
            '男',
            170,
            65,
            features[1] * 40,
            features[2] * 220,
            features[3] * 140,
            features[4] * 25,
            features[4] * 25 * 1.5,
            features[5] * 150,
            7,
            3,
            false,
            false,
            []
          );
          const result: number[] = this.ruleBasedAssess(data, features);
          resolve(result);
        }, 100);
      } catch (e) {
        reject(e);
      }
    });
  }

  private calculateOverallScore(probabilities: number[]): number {
    let score: number = 0;
    for (let i: number = 0; i < probabilities.length; i++) {
      score += probabilities[i] * this.WEIGHTS[i];
    }
    return Math.min(1, score);
  }

  private buildRiskItem(value: number, key: string, label: string, data: HealthInputData): RiskItem {
    const level: RiskLevel = getRiskLevel(value);
    const color: string = getRiskColor(level);
    let description: string = '';
    if (key === 'hypertension') {
      description = '血压 ' + data.systolic + '/' + data.diastolic + 'mmHg';
    } else if (key === 'diabetes') {
      description = '空腹血糖 ' + data.fastingGlucose + 'mmol/L';
    } else if (key === 'fall') {
      description = data.age >= 65 ? '年龄 ' + data.age + '岁，存在跌倒风险' : '跌倒风险较低';
    } else if (key === 'frailty') {
      description = 'BMI ' + data.bmi.toFixed(1);
    } else if (key === 'sarcopenia') {
      description = data.age >= 60 ? '年龄 ' + data.age + '岁，需关注肌肉量' : '肌肉量正常';
    }
    return new RiskItem(key, label, value, level, color, description);
  }

  private generateSuggestions(probabilities: number[], data: HealthInputData): string[] {
    const keys: string[] = ['hypertension', 'diabetes', 'fall', 'frailty', 'sarcopenia'];
    const allSuggestions: string[] = [];

    for (let i: number = 0; i < keys.length; i++) {
      const key: string = keys[i];
      const prob: number = probabilities[i];
      const matchedRules: SuggestionRule[] = this.SUGGESTION_RULES.filter(
        (rule: SuggestionRule) => rule.riskKey === key && prob >= rule.minThreshold && prob < rule.maxThreshold
      );
      if (matchedRules.length > 0) {
        const rule: SuggestionRule = matchedRules[0];
        const count: number = Math.min(3, rule.suggestions.length);
        for (let j: number = 0; j < count; j++) {
          allSuggestions.push(rule.suggestions[j]);
        }
      }
    }

    allSuggestions.push('保持良好的作息习惯，保证每晚7-8小时充足睡眠');

    return allSuggestions;
  }

  private generateId(): string {
    return 'RA-' + Date.now().toString(36) + '-' + Math.random().toString(36).substring(2, 8);
  }
}
