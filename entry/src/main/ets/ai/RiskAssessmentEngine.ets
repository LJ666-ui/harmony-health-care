import { HealthData, HealthFeatureExtractor } from './HealthFeatureExtractor';
import { RuleBasedAssessor, RuleBasedResult, DiseaseRisk } from './RuleBasedAssessor';
import { ModelLoader, InferenceResult } from './ModelLoader';

export interface RiskItem {
  disease: string;
  label: string;
  probability: number;
  level: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  color: string;
  factors: string[];
  evidence: string;
}

export interface RisksMap {
  hypertension: RiskItem;
  diabetes: RiskItem;
  fall: RiskItem;
  frailty: RiskItem;
  sarcopenia: RiskItem;
}

export interface RiskAssessmentResult {
  assessmentId: string;
  timestamp: string;
  risks: RisksMap;
  overallScore: number;
  overallLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  suggestions: Suggestion[];
  features?: number[];
  featureInterpretations?: FeatureInterpretation[];
  assessmentMethod: 'AI_MODEL' | 'RULE_BASED' | 'HYBRID' | 'ERROR';
  modelVersion: string;
  processingTimeMs: number;
  confidence: number;
}

export interface FeatureInterpretation {
  name: string;
  value: string;
  status: 'normal' | 'warning' | 'abnormal';
}

export interface Suggestion {
  category: string;
  priority: 'HIGH' | 'MEDIUM' | 'LOW';
  content: string;
  targetDisease?: string;
}

export interface EngineStatus {
  isReady: boolean;
  mode: string;
  modelLoaded: boolean;
  lastAssessmentTime?: string;
}

export interface PriorityOrder {
  HIGH: number;
  MEDIUM: number;
  LOW: number;
}

export class RiskAssessmentEngine {
  private static instance: RiskAssessmentEngine | null = null;
  private modelLoader: ModelLoader;
  private useAIMode: boolean = false;

  private constructor() {
    this.modelLoader = ModelLoader.getInstance();
    console.log('[RiskAssessmentEngine] AI风险评估引擎初始化完成');
  }

  static getInstance(): RiskAssessmentEngine {
    if (!RiskAssessmentEngine.instance) {
      RiskAssessmentEngine.instance = new RiskAssessmentEngine();
    }
    return RiskAssessmentEngine.instance;
  }

  async assessRisk(
    healthData: HealthData,
    historyData?: HealthData[]
  ): Promise<RiskAssessmentResult> {
    const startTime = Date.now();

    console.log('[RiskAssessmentEngine] ══════════════════════════');
    console.log('[RiskAssessmentEngine] 开始AI共病风险评估...');
    console.log('[RiskAssessmentEngine] ══════════════════════════');

    try {

      console.log('\n[Step 1/4] 提取10维特征向量...');
      const features = HealthFeatureExtractor.extractFeatures(healthData);
      const featureInterpretations = HealthFeatureExtractor.getFeatureInterpretation(features);

      console.log(`[Step 1/4] ✅ 特征提取完成，维度: ${features.length}`);

      let rawProbabilities: number[] = [];
      let assessmentMethod: 'AI_MODEL' | 'RULE_BASED' | 'HYBRID' = 'RULE_BASED';
      let modelVersion = '1.0.0-Rule';

      console.log('\n[Step 2/4] 执行风险推理...');

      if (this.useAIMode) {
        try {
          console.log('  尝试使用MindSpore AI模型推理...');

          const loadResult = await this.modelLoader.load('risk_assessment_model.ms');

          if (loadResult.success && loadResult.modelInfo) {
            const inferenceResult: InferenceResult = await this.modelLoader.runInference(features);

            rawProbabilities = inferenceResult.output;
            assessmentMethod = 'AI_MODEL';
            modelVersion = inferenceResult.modelVersion;

            console.log(`  ✅ AI模型推理成功，耗时: ${inferenceResult.inferenceTimeMs}ms`);
            console.log(`  模型版本: ${modelVersion}`);
          } else {
            throw new Error('模型加载失败');
          }
        } catch (aiError) {
          console.warn(`  ⚠️ AI模型不可用: ${aiError instanceof Error ? aiError.message : String(aiError)}`);
          console.log('  自动降级为规则引擎...');

          const ruleResult: RuleBasedResult = RuleBasedAssessor.assessAllRisks(healthData);
          rawProbabilities = ruleResult.probabilities;
          assessmentMethod = 'RULE_BASED';
          modelVersion = '1.0.0-Rule-Fallback';
        }
      } else {
        console.log('  使用规则引擎模式（默认）...');

        const ruleResult: RuleBasedResult = RuleBasedAssessor.assessAllRisks(healthData);
        rawProbabilities = ruleResult.probabilities;
        assessmentMethod = 'RULE_BASED';
        modelVersion = '1.0.0-Rule';
      }

      console.log(`[Step 2/4] ✅ 推理完成`);
      console.log(`  原始概率值: [${rawProbabilities.map(v => (v * 100).toFixed(1) + '%').join(', ')}]`);

      console.log('\n[Step 3/4] 构建评估结果对象...');
      const result = this.buildAssessmentResult(
        rawProbabilities,
        features,
        featureInterpretations,
        healthData,
        assessmentMethod,
        modelVersion,
        historyData
      );

      result.processingTimeMs = Date.now() - startTime;

      console.log('[Step 3/4] ✅ 结果构建完成');

      console.log('\n[Step 4/4] 生成个性化建议...');
      result.suggestions = this.generateSuggestions(result.risks, healthData);

      console.log(`[Step 4/4] ✅ 建议生成完成，共${result.suggestions.length}条`);

      console.log('\n[RiskAssessmentEngine] ══════════════════════════');
      console.log('[RiskAssessmentEngine] 📊 评估结果摘要:');
      console.log(`   评估ID: ${result.assessmentId}`);
      console.log(`   综合评分: ${(result.overallScore * 100).toFixed(1)}/100 (${result.overallLevel})`);
      console.log(`   高血压: ${(result.risks.hypertension.probability * 100).toFixed(1)}% (${result.risks.hypertension.level})`);
      console.log(`   糖尿病: ${(result.risks.diabetes.probability * 100).toFixed(1)}% (${result.risks.diabetes.level})`);
      console.log(`   跌倒风险: ${(result.risks.fall.probability * 100).toFixed(1)}% (${result.risks.fall.level})`);
      console.log(`   衰弱: ${(result.risks.frailty.probability * 100).toFixed(1)}% (${result.risks.frailty.level})`);
      console.log(`   肌少症: ${(result.risks.sarcopenia.probability * 100).toFixed(1)}% (${result.risks.sarcopenia.level})`);
      console.log(`   处理耗时: ${result.processingTimeMs}ms`);
      console.log(`   评估方法: ${result.assessmentMethod}`);
      console.log('[RiskAssessmentEngine] ══════════════════════════\n');

      return result;

    } catch (error) {
      console.error('[RiskAssessmentEngine] ❌ 评估过程出错:', error instanceof Error ? error.message : String(error));

      return this.createErrorResult(error instanceof Error ? error.message : String(error), startTime);
    }
  }

  private buildAssessmentResult(
    probabilities: number[],
    features: number[],
    interpretations: FeatureInterpretation[],
    healthData: HealthData,
    method: 'AI_MODEL' | 'RULE_BASED' | 'HYBRID',
    version: string = '1.0.0',
    historyData?: HealthData[]
  ): RiskAssessmentResult {

    const ruleResult = RuleBasedAssessor.assessAllRisks(healthData);

    const risks: RisksMap = {
      hypertension: this.buildRiskItem(probabilities[0], 'hypertension', '高血压', ruleResult.risks.hypertension),
      diabetes: this.buildRiskItem(probabilities[1], 'diabetes', '糖尿病', ruleResult.risks.diabetes),
      fall: this.buildRiskItem(probabilities[2], 'fall', '跌倒风险', ruleResult.risks.fall),
      frailty: this.buildRiskItem(probabilities[3], 'frailty', '衰弱综合征', ruleResult.risks.frailty),
      sarcopenia: this.buildRiskItem(probabilities[4], 'sarcopenia', '肌少症', ruleResult.risks.sarcopenia)
    };

    const overallScore = this.calculateOverallScore(probabilities);
    const overallLevel = this.classifyOverallLevel(overallScore);
    const confidence = method === 'AI_MODEL' ? 0.92 : 0.78;

    return {
      assessmentId: this.generateUUID(),
      timestamp: new Date().toISOString(),
      risks: risks,
      overallScore: overallScore,
      overallLevel: overallLevel,
      suggestions: [],
      features: features,
      featureInterpretations: interpretations,
      assessmentMethod: method,
      modelVersion: version,
      processingTimeMs: 0,
      confidence: confidence
    };
  }

  private buildRiskItem(
    probability: number,
    diseaseKey: string,
    label: string,
    ruleBased: DiseaseRisk
  ): RiskItem {
    const level = this.classifyRiskLevel(probability);
    const color = this.getRiskColor(level);

    return {
      disease: diseaseKey,
      label: label,
      probability: probability,
      level: level,
      color: color,
      factors: ruleBased.factors || [],
      evidence: ruleBased.evidence || ''
    };
  }

  private classifyRiskLevel(probability: number): 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' {
    if (probability >= 0.8) return 'CRITICAL';
    if (probability >= 0.6) return 'HIGH';
    if (probability >= 0.3) return 'MEDIUM';
    return 'LOW';
  }

  private getRiskColor(level: string): string {
    switch (level) {
      case 'CRITICAL': return '#CF1322';
      case 'HIGH': return '#FF4D4F';
      case 'MEDIUM': return '#FAAD14';
      case 'LOW': return '#52C41A';
      default: return '#999999';
    }
  }

  private calculateOverallScore(probabilities: number[]): number {
    const weights: number[] = [0.25, 0.25, 0.15, 0.20, 0.15];

    let weightedSum = 0;
    for (let i = 0; i < probabilities.length; i++) {
      weightedSum += probabilities[i] * weights[i];
    }

    return parseFloat(weightedSum.toFixed(4));
  }

  private classifyOverallLevel(score: number): 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' {
    if (score >= 0.75) return 'CRITICAL';
    if (score >= 0.55) return 'HIGH';
    if (score >= 0.35) return 'MEDIUM';
    return 'LOW';
  }

  private generateSuggestions(risks: RisksMap, healthData: HealthData): Suggestion[] {
    const suggestions: Suggestion[] = [];

    if (risks.hypertension.probability > 0.5) {
      const s1: Suggestion = {
        category: '血压管理',
        priority: 'HIGH',
        content: '建议每日监测血压，控制在140/90mmHg以下',
        targetDisease: 'hypertension'
      };
      suggestions.push(s1);
      const s2: Suggestion = {
        category: '饮食调整',
        priority: 'HIGH',
        content: '减少盐摄入量至每日<6g，避免高盐食品',
        targetDisease: 'hypertension'
      };
      suggestions.push(s2);
    }

    if (risks.diabetes.probability > 0.5) {
      const s3: Suggestion = {
        category: '血糖管理',
        priority: 'HIGH',
        content: '定期检测空腹血糖和HbA1c，控制在正常范围',
        targetDisease: 'diabetes'
      };
      suggestions.push(s3);
      const s4: Suggestion = {
        category: '生活方式',
        priority: 'MEDIUM',
        content: '控制碳水化合物摄入，增加膳食纤维',
        targetDisease: 'diabetes'
      };
      suggestions.push(s4);
    }

    if (risks.fall.probability > 0.4) {
      const s5: Suggestion = {
        category: '安全防护',
        priority: 'HIGH',
        content: '居家环境防跌倒改造：安装扶手、防滑垫、改善照明',
        targetDisease: 'fall'
      };
      suggestions.push(s5);
      const s6: Suggestion = {
        category: '运动训练',
        priority: 'MEDIUM',
        content: '进行平衡能力训练（如太极拳、单腿站立练习）',
        targetDisease: 'fall'
      };
      suggestions.push(s6);
    }

    if (risks.frailty.probability > 0.45) {
      const s7: Suggestion = {
        category: '营养干预',
        priority: 'HIGH',
        content: '保证优质蛋白质摄入（每日1.2-1.5g/kg体重）',
        targetDisease: 'frailty'
      };
      suggestions.push(s7);
      const s8: Suggestion = {
        category: '运动处方',
        priority: 'MEDIUM',
        content: '进行抗阻力训练，每周2-3次，增强肌肉力量',
        targetDisease: 'frailty'
      };
      suggestions.push(s8);
    }

    if (risks.sarcopenia.probability > 0.35) {
      const s9: Suggestion = {
        category: '肌肉健康',
        priority: 'MEDIUM',
        content: '补充维生素D和钙质，促进骨骼肌肉健康',
        targetDisease: 'sarcopenia'
      };
      suggestions.push(s9);
    }

    if (healthData.exerciseFrequency !== undefined && healthData.exerciseFrequency < 2) {
      const s10: Suggestion = {
        category: '运动建议',
        priority: 'MEDIUM',
        content: `当前每周运动${healthData.exerciseFrequency}次，建议增加到每周3-5次`
      };
      suggestions.push(s10);
    }

    if (healthData.sleepData !== undefined &&
        healthData.sleepData.durationHours !== undefined &&
        (healthData.sleepData.durationHours < 6 || healthData.sleepData.durationHours > 9)) {
      const s11: Suggestion = {
        category: '睡眠管理',
        priority: 'LOW',
        content: '保持规律作息，每日睡眠7-8小时为宜'
      };
      suggestions.push(s11);
    }

    suggestions.sort((a: Suggestion, b: Suggestion): number => {
      const getPriorityValue = (priority: 'HIGH' | 'MEDIUM' | 'LOW'): number => {
        switch (priority) {
          case 'HIGH': return 0;
          case 'MEDIUM': return 1;
          case 'LOW': return 2;
        }
      };
      return getPriorityValue(a.priority) - getPriorityValue(b.priority);
    });

    return suggestions.slice(0, 10);
  }

  private generateUUID(): string {
    return 'ASSESS_' + Date.now().toString(36) + '_' +
           Math.random().toString(36).substr(2, 9).toUpperCase();
  }

  private createErrorResult(errorMessage: string, startTime: number): RiskAssessmentResult {
    const createDefaultRisk = (disease: string, label: string): RiskItem => {
      return { disease: disease, label: label, probability: 0, level: 'LOW', color: '#52C41A', factors: [], evidence: '' };
    };
    
    return {
      assessmentId: this.generateUUID(),
      timestamp: new Date().toISOString(),
      risks: {
        hypertension: createDefaultRisk('hypertension', '高血压'),
        diabetes: createDefaultRisk('diabetes', '糖尿病'),
        fall: createDefaultRisk('fall', '跌倒风险'),
        frailty: createDefaultRisk('frailty', '衰弱综合征'),
        sarcopenia: createDefaultRisk('sarcopenia', '肌少症')
      },
      overallScore: 0,
      overallLevel: 'LOW',
      suggestions: [{
        category: '系统错误',
        priority: 'HIGH',
        content: '评估过程中出现错误：' + errorMessage + '，请稍后重试或联系医生'
      }],
      assessmentMethod: 'ERROR',
      modelVersion: 'N/A',
      processingTimeMs: Date.now() - startTime,
      confidence: 0
    };
  }

  setAIMode(enabled: boolean): void {
    this.useAIMode = enabled;
    console.log(`[RiskAssessmentEngine] AI模式已${enabled ? '启用' : '禁用'}`);
  }

  async quickAssess(
    age: number,
    gender: 'MALE' | 'FEMALE',
    systolicBP: number,
    diastolicBP: number,
    fastingGlucose: number,
    height: number,
    weight: number
  ): Promise<RiskAssessmentResult> {

    const healthData: HealthData = {
      age: age,
      gender: gender,
      bloodPressure: {
        systolic: systolicBP,
        diastolic: diastolicBP
      },
      bloodGlucose: {
        fasting: fastingGlucose
      },
      heartRate: {
        resting: 72
      },
      bodyMetrics: {
        height: height,
        weight: weight
      },
      exerciseFrequency: 2,
      medicationCount: 2
    };

    return this.assessRisk(healthData);
  }

  getEngineStatus(): EngineStatus {
    const modelStatus = this.modelLoader.getModelStatus();

    return {
      isReady: true,
      mode: this.useAIMode ? 'AI_MODEL' : 'RULE_BASED',
      modelLoaded: modelStatus.isLoaded,
      lastAssessmentTime: undefined
    };
  }
}
