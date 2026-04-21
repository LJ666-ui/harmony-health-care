import { HealthData } from '../ai/HealthFeatureExtractor';
import { RiskAssessmentResult, Suggestion, FeatureInterpretation, RiskItem, RisksMap } from '../ai/RiskAssessmentEngine';

export interface MockUserHealthProfile {
  userId: string;
  name: string;
  age: number;
  gender: 'MALE' | 'FEMALE';
  healthData: HealthData;
}

export interface RiskProbabilities {
  hypertension: number;
  diabetes: number;
  fall: number;
  frailty: number;
  sarcopenia: number;
}

export interface MockRiskItem {
  disease: string;
  label: string;
  probability: number;
  level: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  color: string;
  factors: string[];
  evidence: string;
}

export interface MockSuggestion {
  category: string;
  content: string;
  priority: 'LOW' | 'MEDIUM' | 'HIGH';
  targetDisease?: string;
}

export class RiskAssessmentMock {
  static instance: RiskAssessmentMock | null = null;

  sampleUserHealthData: MockUserHealthProfile = {
    userId: 'USER_001',
    name: '张三',
    age: 68,
    gender: 'MALE',
    healthData: {
      age: 68,
      gender: 'MALE',
      bloodPressure: {
        systolic: 145,
        diastolic: 92
      },
      bloodGlucose: {
        fasting: 6.8,
        hba1c: 6.5
      },
      heartRate: {
        resting: 78
      },
      bodyMetrics: {
        height: 168,
        weight: 62,
        bmi: 22.0
      },
      functionalTests: {
        gripStrength: 26,
        gaitSpeed: 0.85,
        tandemStandTime: 12
      },
      cognitiveScores: {
        mmse: 27,
        gds: 4
      },
      nutrition: 10,
      medicationCount: 5,
      sleepData: {
        durationHours: 6.5,
        deepSleepRatio: 0.15
      },
      exerciseFrequency: 2
    }
  };

  private constructor() {}

  static getInstance(): RiskAssessmentMock {
    if (!RiskAssessmentMock.instance) {
      RiskAssessmentMock.instance = new RiskAssessmentMock();
    }
    return RiskAssessmentMock.instance;
  }

  getSampleUserHealthData(): HealthData {
    return this.sampleUserHealthData.healthData;
  }

  getHistoricalAssessments(): RiskAssessmentResult[] {
    const baseTime = Date.now();

    return [
      this.createAssessmentResult(
        baseTime - 90 * 24 * 60 * 60 * 1000,
        0.42,
        { hypertension: 0.55, diabetes: 0.45, fall: 0.40, frailty: 0.38, sarcopenia: 0.35 }
      ),
      this.createAssessmentResult(
        baseTime - 60 * 24 * 60 * 60 * 1000,
        0.48,
        { hypertension: 0.60, diabetes: 0.50, fall: 0.45, frailty: 0.45, sarcopenia: 0.42 }
      ),
      this.createAssessmentResult(
        baseTime - 30 * 24 * 60 * 60 * 1000,
        0.55,
        { hypertension: 0.65, diabetes: 0.58, fall: 0.52, frailty: 0.52, sarcopenia: 0.48 }
      )
    ];
  }

  createAssessmentResult(
    timestamp: number,
    overallScore: number,
    riskProbabilities: RiskProbabilities
  ): RiskAssessmentResult {

    return {
      assessmentId: `ASSESS_${timestamp}`,
      timestamp: new Date(timestamp).toISOString(),
      assessmentMethod: 'RULE_BASED',
      modelVersion: 'v2.0',
      processingTimeMs: Math.floor(Math.random() * 80) + 20,
      confidence: 0.88 + Math.random() * 0.10,
      overallScore: overallScore,
      overallLevel: this.getOverallLevelFromScore(overallScore),
      risks: this.createRiskItems(riskProbabilities),
      suggestions: this.generateSuggestions(riskProbabilities),
      featureInterpretations: []
    };
  }

  getSampleAssessmentResult(): RiskAssessmentResult {
    const riskProbs: RiskProbabilities = {
      hypertension: 0.72,
      diabetes: 0.58,
      fall: 0.52,
      frailty: 0.65,
      sarcopenia: 0.48
    };

    return {
      assessmentId: `ASSESS_${Date.now()}`,
      timestamp: new Date().toISOString(),
      assessmentMethod: 'RULE_BASED',
      modelVersion: 'v2.0',
      processingTimeMs: 45,
      confidence: 0.92,
      overallScore: 0.59,
      overallLevel: 'MEDIUM',
      risks: this.createRiskItems(riskProbs),
      suggestions: this.generateSuggestions(riskProbs),
      featureInterpretations: [
        { name: '年龄', value: '68岁', status: 'normal' },
        { name: 'BMI', value: '22.0', status: 'normal' },
        { name: '收缩压', value: '145mmHg', status: 'abnormal' },
        { name: '舒张压', value: '92mmHg', status: 'warning' },
        { name: '空腹血糖', value: '6.8mmol/L', status: 'warning' },
        { name: '握力', value: '26kg', status: 'warning' },
        { name: '步速', value: '0.85m/s', status: 'abnormal' },
        { name: '用药数量', value: '5种', status: 'warning' },
        { name: 'MMS评分', value: '27分', status: 'normal' },
        { name: '运动频率', value: '2次/周', status: 'warning' }
      ] as FeatureInterpretation[]
    };
  }

  createRiskItems(probabilities: RiskProbabilities): RisksMap {
    const hypertensionItem: MockRiskItem = {
      disease: 'hypertension',
      label: '高血压',
      probability: probabilities.hypertension,
      level: this.getRiskLevelFromProbability(probabilities.hypertension),
      color: '#FF4D4F',
      factors: ['收缩压145mmHg', '舒张压92mmHg', '年龄68岁'],
      evidence: `基于血压值${probabilities.hypertension > 0.7 ? '显著' : ''}高于正常范围`
    };

    const diabetesItem: MockRiskItem = {
      disease: 'diabetes',
      label: '糖尿病',
      probability: probabilities.diabetes,
      level: this.getRiskLevelFromProbability(probabilities.diabetes),
      color: '#FAAD14',
      factors: ['空腹血糖6.8mmol/L', 'HbA1c 6.5%', '年龄因素'],
      evidence: `空腹血糖${probabilities.diabetes > 0.6 ? '接近' : '略'}糖尿病诊断阈值`
    };

    const fallItem: MockRiskItem = {
      disease: 'fall',
      label: '跌倒风险',
      probability: probabilities.fall,
      level: this.getRiskLevelFromProbability(probabilities.fall),
      color: '#FF7875',
      factors: ['步速0.85m/s', 'tandem站立12秒', '服用5种药物'],
      evidence: '步速低于0.8m/s阈值，结合多药治疗增加跌倒概率'
    };

    const frailtyItem: MockRiskItem = {
      disease: 'frailty',
      label: '衰弱综合征',
      probability: probabilities.frailty,
      level: this.getRiskLevelFromProbability(probabilities.frailty),
      color: '#FFA39E',
      factors: ['体重偏低(BMI=22)', '握力26kg(男性<28kg)', '步速减慢'],
      evidence: '符合Fried衰弱表型中3项标准：体重减轻、握力下降、步速减慢'
    };

    const sarcopeniaItem: MockRiskItem = {
      disease: 'sarcopenia',
      label: '肌少症',
      probability: probabilities.sarcopenia,
      level: this.getRiskLevelFromProbability(probabilities.sarcopenia),
      color: '#FFCCC7',
      factors: ['握力26kg', '步速0.85m/s', '运动频率不足'],
      evidence: '握力和步速均低于肌少症诊断临界值'
    };

    const result: RisksMap = {
      hypertension: hypertensionItem as RiskItem,
      diabetes: diabetesItem as RiskItem,
      fall: fallItem as RiskItem,
      frailty: frailtyItem as RiskItem,
      sarcopenia: sarcopeniaItem as RiskItem
    };
    return result;
  }

  generateSuggestions(probabilities: RiskProbabilities): Suggestion[] {
    const suggestions: Suggestion[] = [];

    if (probabilities.hypertension > 0.6) {
      suggestions.push({
        category: '血压管理',
        content: '每日早晚各测量一次血压并记录，建议控制在140/90mmHg以下',
        priority: 'HIGH',
        targetDisease: 'hypertension'
      });

      suggestions.push({
        category: '饮食调整',
        content: '减少钠盐摄入，每日食盐量不超过5克；增加钾摄入，多吃蔬菜水果',
        priority: 'HIGH',
        targetDisease: 'hypertension'
      });
    }

    if (probabilities.diabetes > 0.5) {
      suggestions.push({
        category: '血糖管理',
        content: '定期监测空腹血糖和餐后2小时血糖，建议复查糖化血红蛋白(HbA1c)',
        priority: 'HIGH',
        targetDisease: 'diabetes'
      });

      suggestions.push({
        category: '运动处方',
        content: '每周进行150分钟中等强度有氧运动（如快走），有助于改善胰岛素敏感性',
        priority: 'MEDIUM',
        targetDisease: 'diabetes'
      });
    }

    if (probabilities.fall > 0.45) {
      suggestions.push({
        category: '安全防护',
        content: '进行居家环境安全评估：清除地面障碍物、安装扶手、改善照明',
        priority: 'HIGH',
        targetDisease: 'fall'
      });

      suggestions.push({
        category: '运动训练',
        content: '每周3次平衡训练（如太极拳、单腿站立练习）和下肢力量训练',
        priority: 'MEDIUM',
        targetDisease: 'fall'
      });

      suggestions.push({
        category: '生活方式',
        content: '与医生沟通是否可以减少不必要的药物，特别是镇静催眠类药物',
        priority: 'MEDIUM',
        targetDisease: 'fall'
      });
    }

    if (probabilities.frailty > 0.5) {
      suggestions.push({
        category: '营养干预',
        content: '增加优质蛋白质摄入至每天1.2-1.5g/kg体重，推荐鱼、蛋、奶制品',
        priority: 'HIGH',
        targetDisease: 'frailty'
      });

      suggestions.push({
        category: '运动处方',
        content: '开始抗阻力训练计划：每周2-3次，使用弹力带或轻重量器械',
        priority: 'HIGH',
        targetDisease: 'frailty'
      });

      suggestions.push({
        category: '肌肉健康',
        content: '补充维生素D和钙剂，有助于维持肌肉功能和骨密度',
        priority: 'MEDIUM',
        targetDisease: 'frailty'
      });
    }

    if (probabilities.sarcopenia > 0.4) {
      suggestions.push({
        category: '肌肉健康',
        content: '进行握力训练：使用握力器或提重物练习，目标提升至28kg以上',
        priority: 'MEDIUM',
        targetDisease: 'sarcopenia'
      });

      suggestions.push({
        category: '运动建议',
        content: '增加日常活动量，如爬楼梯代替电梯，步行代替乘车',
        priority: 'LOW',
        targetDisease: 'sarcopenia'
      });
    }

    suggestions.push({
      category: '睡眠管理',
      content: '保持规律作息，每晚保证7-8小时高质量睡眠',
      priority: 'LOW'
    });

    suggestions.push({
      category: '定期评估',
      content: '每月进行一次AI风险评估以监控健康变化趋势',
      priority: 'LOW'
    });

    return suggestions;
  }

  generateRandomHealthData(): HealthData {
    const age = Math.floor(Math.random() * 30) + 60;
    const isMale = Math.random() > 0.5;
    const gender = isMale ? 'MALE' : 'FEMALE';
    const height = isMale ? 165 + Math.random() * 15 : 155 + Math.random() * 12;
    const weight = 50 + Math.random() * 25;

    return {
      age: age,
      gender: gender as 'MALE' | 'FEMALE',
      bloodPressure: {
        systolic: 110 + Math.floor(Math.random() * 60),
        diastolic: 70 + Math.floor(Math.random() * 35)
      },
      bloodGlucose: {
        fasting: 4.0 + Math.random() * 4.0,
        hba1c: 5.0 + Math.random() * 3.0
      },
      heartRate: {
        resting: 60 + Math.floor(Math.random() * 30)
      },
      bodyMetrics: {
        height: parseFloat(height.toFixed(1)),
        weight: parseFloat(weight.toFixed(1)),
        bmi: parseFloat((weight / ((height / 100) ** 2)).toFixed(1))
      },
      functionalTests: {
        gripStrength: 18 + Math.random() * 25,
        gaitSpeed: 0.5 + Math.random() * 1.0,
        tandemStandTime: Math.floor(Math.random() * 25)
      },
      cognitiveScores: {
        mmse: 20 + Math.floor(Math.random() * 10),
        gds: Math.floor(Math.random() * 10)
      },
      nutrition: 8 + Math.floor(Math.random() * 7),
      medicationCount: Math.floor(Math.random() * 9),
      sleepData: {
        durationHours: 5 + Math.random() * 4,
        deepSleepRatio: 0.1 + Math.random() * 0.25
      },
      exerciseFrequency: Math.floor(Math.random() * 7)
    };
  }

  getRiskLevelFromProbability(probability: number): 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' {
    if (probability < 0.35) return 'LOW';
    if (probability < 0.55) return 'MEDIUM';
    if (probability < 0.75) return 'HIGH';
    return 'CRITICAL';
  }

  getOverallLevelFromScore(score: number): 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' {
    if (score < 0.35) return 'LOW';
    if (score < 0.55) return 'MEDIUM';
    if (score < 0.75) return 'HIGH';
    return 'CRITICAL';
  }
}

export const riskMockData: RiskAssessmentMock = RiskAssessmentMock.getInstance();
