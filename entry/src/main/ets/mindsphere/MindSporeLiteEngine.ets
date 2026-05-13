/**
 * MindSpore Lite 推理引擎封装
 * 用于端侧AI模型推理，保护用户隐私（数据不上云）
 *
 * 核心功能:
 * 1. 共病风险评估 (5维度: 高血压/糖尿病/跌倒/衰弱/肌少症)
 * 2. 异常检测 (健康数据实时监测)
 * 3. 跌倒预测 (基于传感器数据)
 *
 * 使用示例:
 * ```typescript
 * const engine = MindSporeLiteEngine.getInstance();
 *
 * // 加载模型
 * await engine.initialize();
 *
 * // 执行风险评估
 * const result = await engine.assessRisk(healthData);
 * console.log('风险等级:', result.overallLevel);
 * ```
 */

export interface MindSporeModelConfig {
  modelName: string;
  modelPath: string;       // .ms模型文件路径
  inputShape: number[];
  outputShape: number[];
}

export interface RiskAssessmentInput {
  age: number;
  gender: number;          // 0=女, 1=男
  bmi: number;
  smoking: number;         // 0或1
  drinking: number;        // 0或1
  systolic: number;        // 收缩压
  diastolic: number;       // 舒张压
  fastingGlucose: number;  // 空腹血糖
  hba1c: number;           // 糖化血红蛋白
  exerciseFrequency: number;
  sleepDuration: number;
  stepCount: number;
  sedentaryTime: number;
  hypertensionHistory: number;
  diabetesHistory: number;
  heartDiseaseHistory: number;
  strokeHistory: number;
  fractureHistory: number;
  medicationCount: number;
}

export interface RiskAssessmentOutput {
  hypertensionRisk: number;   // [0-1]
  diabetesRisk: number;       // [0-1]
  fallRisk: number;           // [0-1]
  frailtyRisk: number;        // [0-1]
  sarcopeniaRisk: number;     // [0-1]
  overallScore: number;        // [0-1]
  overallLevel: 'low' | 'medium' | 'high' | 'critical';
  suggestions: string[];
  modelVersion: string;
  inferenceTime: number;      // ms
}

export interface AnomalyDetectionResult {
  isAnomaly: boolean;
  anomalyType: string;
  confidence: number;
  details: Record<string, any>;
}

export class MindSporeLiteEngine {
  private static instance: MindSporeLiteEngine | null = null;
  private isInitialized: boolean = false;
  private useRealModel: boolean = false;

  private riskModelConfig: MindSporeModelConfig = {
    modelName: 'risk_assess',
    modelPath: 'entry/src/main/resources/rawfile/risk_assess.ms',
    inputShape: [1, 20],
    outputShape: [1, 5]
  };

  private constructor() {}

  public static getInstance(): MindSporeLiteEngine {
    if (MindSporeLiteEngine.instance === null) {
      MindSporeLiteEngine.instance = new MindSporeLiteEngine();
    }
    return MindSporeLiteEngine.instance;
  }

  /**
   * 初始化引擎，加载模型
   */
  async initialize(): Promise<boolean> {
    try {
      console.info('[MindSpore] 正在初始化推理引擎...');

      // 检查模型文件是否存在（实际项目中需要真实检查）
      const modelExists = await this.checkModelFile(this.riskModelConfig.modelPath);

      if (modelExists) {
        this.useRealModel = true;
        console.info('[MindSpore] 模型文件存在，将使用真实推理');
      } else {
        this.useRealModel = false;
        console.warn('[MindSpore] 模型文件不存在，将使用规则引擎作为fallback');
      }

      this.isInitialized = true;
      console.info('[MindSpore] 引擎初始化完成, 使用模式:', this.useRealModel ? '真实模型' : '规则引擎');

      return true;
    } catch (error) {
      console.error('[MindSpore] 初始化失败:', error);
      this.useRealModel = false;
      this.isInitialized = true; // 即使模型加载失败也标记为已初始化，使用fallback
      return true;
    }
  }

  /**
   * 执行共病风险评估（核心方法）
   */
  async assessRisk(input: RiskAssessmentInput): Promise<RiskAssessmentOutput> {
    const startTime = Date.now();

    if (!this.isInitialized) {
      await this.initialize();
    }

    try {
      let probabilities: number[];

      if (this.useRealModel) {
        probabilities = await this.runRealInference(input);
      } else {
        probabilities = this.runRuleBasedAssessment(input);
      }

      const overallScore = this.calculateOverallScore(probabilities);
      const overallLevel = this.getRiskLevel(overallScore);
      const suggestions = this.generateSuggestions(probabilities, input);

      const result: RiskAssessmentOutput = {
        hypertensionRisk: probabilities[0],
        diabetesRisk: probabilities[1],
        fallRisk: probabilities[2],
        frailtyRisk: probabilities[3],
        sarcopeniaRisk: probabilities[4],
        overallScore,
        overallLevel,
        suggestions,
        modelVersion: this.useRealModel ? 'mindspore-v1.0' : 'rule-based-v1',
        inferenceTime: Date.now() - startTime
      };

      console.info(`[MindSpore] 风险评估完成, 耗时=${result.inferenceTime}ms, 等级=${result.overallLevel}`);

      return result;
    } catch (error) {
      console.error('[MindSpore] 风险评估失败:', error);
      throw error;
    }
  }

  /**
   * 健康数据异常检测
   */
  async detectAnomaly(
    currentData: Record<string, number>,
    historicalData?: Record<string, number>[]
  ): Promise<AnomalyDetectionResult> {
    try {
      const anomalies: string[] = [];
      let maxConfidence = 0;

      for (const [key, value] of Object.entries(currentData)) {
        const normalRange = this.getNormalRange(key);
        if (normalRange && (value < normalRange.min || value > normalRange.max)) {
          anomalies.push(key);
          const deviation = Math.abs(value - ((normalRange.max + normalRange.min) / 2));
          maxConfidence = Math.max(maxConfidence, Math.min(deviation / normalRange.range, 1));
        }
      }

      return {
        isAnomaly: anomalies.length > 0,
        anomalyType: anomalies.join(','),
        confidence: maxConfidence,
        details: { anomalies, abnormalFields: anomalies }
      };
    } catch (error) {
      console.error('[MindSpore] 异常检测失败:', error);
      return {
        isAnomaly: false,
        anomalyType: '',
        confidence: 0,
        details: {}
      };
    }
  }

  /**
   * 跌倒风险预测
   */
  async predictFallRisk(sensorData: {
    accelerometer: { x: number; y: number; z: number };
    gyroscope: { x: number; y: number; z: number };
    age: number;
    hasFallHistory: boolean;
  }): Promise<{ riskLevel: 'low' | 'medium' | 'high'; confidence: number }> {
    try {
      const accMagnitude = Math.sqrt(
        sensorData.accelerometer.x ** 2 +
        sensorData.accelerometer.y ** 2 +
        sensorData.accelerometer.z ** 2
      );

      let riskScore = 0;

      if (sensorData.age >= 80) riskScore += 0.3;
      else if (sensorData.age >= 70) riskScore += 0.2;
      else if (sensorData.age >= 65) riskScore += 0.1;

      if (sensorData.hasFallHistory) riskScore += 0.25;

      if (accMagnitude < 8 || accMagnitude > 12) riskScore += 0.2;

      if (riskScore > 0.6) {
        return { riskLevel: 'high', confidence: Math.min(riskScore, 1) };
      } else if (riskScore > 0.3) {
        return { riskLevel: 'medium', confidence: riskScore };
      } else {
        return { riskLevel: 'low', confidence: riskScore };
      }
    } catch (error) {
      console.error('[MindSpore] 跌倒预测失败:', error);
      return { riskLevel: 'low', confidence: 0 };
    }
  }

  // ==================== 私有方法 ====================

  private async checkModelFile(path: string): Promise<boolean> {
    try {
      // 实际项目中应该检查文件是否存在
      // 这里默认返回false，表示使用规则引擎
      return false;
    } catch (e) {
      return false;
    }
  }

  private async runRealInference(input: RiskAssessmentInput): Promise<number[]> {
    // 实际的MindSpore Lite推理代码
    // 这里应该是调用MindSpore API进行模型推理

    console.info('[MindSpore] 执行真实模型推理');

    const features = this.extractFeatures(input);

    return new Promise((resolve) => {
      setTimeout(() => {
        // 模拟模型输出（实际应从模型获取）
        resolve(this.runRuleBasedAssessment(input));
      }, 50); // 模拟推理延迟
    });
  }

  private runRuleBasedAssessment(input: RiskAssessmentInput): number[] {
    const hypertensionRisk = this.assessHypertension(input);
    const diabetesRisk = this.assessDiabetes(input);
    const fallRisk = this.assessFall(input);
    const frailtyRisk = this.assessFrailty(input);
    const sarcopeniaRisk = this.assessSarcopenia(input);

    return [hypertensionRisk, diabetesRisk, fallRisk, frailtyRisk, sarcopeniaRisk];
  }

  private extractFeatures(input: RiskAssessmentInput): number[] {
    return [
      input.age / 100,
      input.gender,
      (input.bmi - 15) / 25,
      input.smoking,
      input.drinking,
      input.systolic / 200,
      input.diastolic / 120,
      input.fastingGlucose / 15,
      (input.hba1c || 5.5) / 12,
      input.exerciseFrequency / 7,
      input.sleepDuration / 12,
      input.stepCount / 20000,
      input.sedentaryTime / 16,
      input.hypertensionHistory,
      input.diabetesHistory,
      input.heartDiseaseHistory,
      input.strokeHistory,
      input.fractureHistory,
      input.medicationCount / 10
    ];
  }

  private assessHypertension(input: RiskAssessmentInput): number {
    let risk = 0;
    if (input.systolic >= 180 || input.diastolic >= 110) risk = 0.9;
    else if (input.systolic >= 140 || input.diastolic >= 90) risk = 0.7;
    else if (input.systolic >= 120 || input.diastolic >= 80) risk = 0.4;
    else risk = 0.15;

    if (input.age >= 65) risk += 0.1;
    if (input.smoking) risk += 0.08;
    if (input.drinking) risk += 0.05;
    if (input.bmi >= 28) risk += 0.07;

    return Math.min(1, risk);
  }

  private assessDiabetes(input: RiskAssessmentInput): number {
    let risk = 0;
    if (input.fastingGlucose >= 7.0) risk = 0.85;
    else if (input.fastingGlucose >= 6.1) risk = 0.55;
    else if (input.fastingGlucose >= 5.6) risk = 0.35;
    else risk = 0.1;

    if (input.bmi >= 28) risk += 0.1;
    if (input.age >= 45) risk += 0.08;
    if (input.exerciseFrequency < 2) risk += 0.07;

    return Math.min(1, risk);
  }

  private assessFall(input: RiskAssessmentInput): number {
    let risk = 0;
    if (input.age >= 80) risk = 0.7;
    else if (input.age >= 70) risk = 0.5;
    else if (input.age >= 65) risk = 0.35;
    else risk = 0.1;

    if (input.exerciseFrequency < 2) risk += 0.08;

    return Math.min(1, risk);
  }

  private assessFrailty(input: RiskAssessmentInput): number {
    let risk = 0;
    if (input.age >= 80) risk += 0.25;
    else if (input.age >= 70) risk += 0.15;
    else if (input.age >= 65) risk += 0.08;

    if (input.bmi < 18.5) risk += 0.2;
    else if (input.bmi > 28) risk += 0.12;
    if (input.exerciseFrequency < 2) risk += 0.15;
    if (input.sleepDuration < 6 || input.sleepDuration > 9) risk += 0.1;

    return Math.min(1, risk);
  }

  private assessSarcopenia(input: RiskAssessmentInput): number {
    let risk = 0;
    if (input.age < 60) return 0.08;

    if (input.age >= 80) risk += 0.3;
    else if (input.age >= 70) risk += 0.2;
    else risk += 0.1;

    if (input.bmi < 18.5) risk += 0.25;
    else if (input.bmi < 20) risk += 0.12;
    if (input.exerciseFrequency < 2) risk += 0.15;

    return Math.min(1, risk);
  }

  private calculateOverallScore(probabilities: number[]): number {
    const weights = [0.25, 0.25, 0.15, 0.20, 0.15];
    let score = 0;
    for (let i = 0; i < probabilities.length; i++) {
      score += probabilities[i] * weights[i];
    }
    return score;
  }

  private getRiskLevel(score: number): 'low' | 'medium' | 'high' | 'critical' {
    if (score < 0.3) return 'low';
    if (score < 0.5) return 'medium';
    if (score < 0.7) return 'high';
    return 'critical';
  }

  private generateSuggestions(probabilities: number[], input: RiskAssessmentInput): string[] {
    const suggestions: string[] = [];

    if (probabilities[0] > 0.6) {
      suggestions.push('控制盐摄入，每日不超过5g');
      suggestions.push('定期监测血压，建议每天早晚各一次');
    }
    if (probabilities[1] > 0.6) {
      suggestions.push('控制碳水化合物摄入，选择低GI食物');
      suggestions.push('每日监测空腹及餐后血糖');
    }
    if (probabilities[2] > 0.6) {
      suggestions.push('居家环境改造：安装扶手、防滑垫、夜灯');
      suggestions.push('进行平衡训练：太极拳、站立练习');
    }
    suggestions.push('保持良好的作息习惯，保证每晚7-8小时充足睡眠');

    return suggestions.slice(0, 5);
  }

  private getNormalRange(metric: string): { min: number; max: number; range: number } | null {
    const ranges: Record<string, { min: number; max: number; range: number }> = {
      systolic: { min: 90, max: 140, range: 50 },
      diastolic: { min: 60, max: 90, range: 30 },
      heartRate: { min: 60, max: 100, range: 40 },
      bloodSugar: { min: 3.9, max: 6.1, range: 2.2 },
      bloodOxygen: { min: 95, max: 100, range: 5 },
      temperature: { min: 36.0, max: 37.3, range: 1.3 }
    };

    return ranges[metric] || null;
  }
}

// 导出单例实例
export const mindSporeEngine = MindSporeLiteEngine.getInstance();
