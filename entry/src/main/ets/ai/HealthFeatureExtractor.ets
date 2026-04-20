export interface BloodPressure {
  systolic: number;
  diastolic: number;
}

export interface BloodGlucose {
  fasting: number;
  postprandial?: number;
  hba1c?: number;
}

export interface HeartRate {
  resting: number;
  variability?: number;
}

export interface BodyMetrics {
  height: number;
  weight: number;
  bmi?: number;
}

export interface FunctionalTests {
  gripStrength?: number;
  tandemStandTime?: number;
  gaitSpeed?: number;
}

export interface CognitiveScores {
  mmse?: number;
  gds?: number;
}

export interface SleepData {
  durationHours?: number;
  deepSleepRatio?: number;
}

export interface HealthData {
  age: number;
  gender: 'MALE' | 'FEMALE';
  bloodPressure: BloodPressure;
  bloodGlucose: BloodGlucose;
  heartRate: HeartRate;
  bodyMetrics: BodyMetrics;
  functionalTests?: FunctionalTests;
  cognitiveScores?: CognitiveScores;
  nutrition?: number;
  medicationCount?: number;
  sleepData?: SleepData;
  exerciseFrequency?: number;
}

export interface FeatureVector {
  values: number[];
  timestamp: number;
  metadata: FeatureMetadata;
}

export interface FeatureMetadata {
  dataSource: string;
  normalizationMethod: string;
}

export interface NormalizationRange {
  min: number;
  max: number;
}

export interface NormalizationRanges {
  age: NormalizationRange;
  bmi: NormalizationRange;
  systolicBP: NormalizationRange;
  diastolicBP: NormalizationRange;
  fastingGlucose: NormalizationRange;
  heartRate: NormalizationRange;
  sleepDuration: NormalizationRange;
  exerciseFreq: NormalizationRange;
}

export interface FeatureInterpretation {
  name: string;
  value: string;
  status: 'normal' | 'warning' | 'abnormal';
}

export interface TimeSeriesFeatures {
  mean: number[];
  std: number[];
  trend: number[];
}

export class HealthFeatureExtractor {

  static readonly FEATURE_DIMENSIONS = 10;

  static readonly FEATURE_NAMES: string[] = [
    'age_normalized',
    'bmi_normalized',
    'systolic_bp_norm',
    'diastolic_bp_norm',
    'fasting_glucose_norm',
    'heart_rate_norm',
    'sleep_quality_score',
    'exercise_frequency',
    'fall_risk_score',
    'frailty_indicator'
  ];

  static readonly NORMALIZATION_RANGES: NormalizationRanges = {
    age: { min: 0, max: 100 },
    bmi: { min: 10, max: 50 },
    systolicBP: { min: 70, max: 200 },
    diastolicBP: { min: 40, max: 130 },
    fastingGlucose: { min: 2.0, max: 15.0 },
    heartRate: { min: 40, max: 140 },
    sleepDuration: { min: 2, max: 12 },
    exerciseFreq: { min: 0, max: 7 }
  };

  private constructor() {}

  static normalize(value: number, min: number, max: number): number {
    if (max === min) return 0.5;
    const normalized = (value - min) / (max - min);
    return Math.max(0, Math.min(1, normalized));
  }

  static normalizeBMI(bmi: number): number {
    const optimalLow = 18.5;
    const optimalHigh = 24.9;

    if (bmi >= optimalLow && bmi <= optimalHigh) {
      const rangeWidth = optimalHigh - optimalLow;
      const position = (bmi - optimalLow) / rangeWidth;
      return 0.3 + position * 0.4;
    } else if (bmi < optimalLow) {
      const deviation = optimalLow - bmi;
      return Math.max(0, 0.3 - deviation * 0.05);
    } else {
      const deviation = bmi - optimalHigh;
      return Math.min(1, 0.7 + deviation * 0.03);
    }
  }

  static calculateSleepQualityScore(sleepData?: SleepData): number {
    if (!sleepData || sleepData.durationHours === undefined) {
      return 0.5;
    }

    const durationScore = HealthFeatureExtractor.normalize(
      sleepData.durationHours,
      HealthFeatureExtractor.NORMALIZATION_RANGES.sleepDuration.min,
      HealthFeatureExtractor.NORMALIZATION_RANGES.sleepDuration.max
    );

    let deepSleepBonus = 0;
    if (sleepData.deepSleepRatio !== undefined) {
      if (sleepData.deepSleepRatio >= 0.2 && sleepData.deepSleepRatio <= 0.25) {
        deepSleepBonus = 0.1;
      } else if (sleepData.deepSleepRatio < 0.15 || sleepData.deepSleepRatio > 0.3) {
        deepSleepBonus = -0.1;
      }
    }

    return Math.max(0, Math.min(1, durationScore + deepSleepBonus));
  }

  static calculateFallRiskScore(healthData: HealthData): number {
    let riskScore = 0;

    if (healthData.age >= 75) {
      riskScore += 0.25;
    } else if (healthData.age >= 65) {
      riskScore += 0.15;
    }

    if (healthData.functionalTests?.gaitSpeed !== undefined) {
      if (healthData.functionalTests.gaitSpeed < 0.8) {
        riskScore += 0.25;
      } else if (healthData.functionalTests.gaitSpeed < 1.0) {
        riskScore += 0.15;
      }
    }

    if (healthData.functionalTests?.tandemStandTime !== undefined) {
      if (healthData.functionalTests.tandemStandTime < 10) {
        riskScore += 0.2;
      } else if (healthData.functionalTests.tandemStandTime < 20) {
        riskScore += 0.1;
      }
    }

    if (healthData.cognitiveScores?.mmse !== undefined && healthData.cognitiveScores.mmse < 24) {
      riskScore += 0.15;
    }

    if (healthData.medicationCount !== undefined && healthData.medicationCount > 4) {
      riskScore += Math.min(0.15, (healthData.medicationCount - 4) * 0.03);
    }

    return Math.max(0, Math.min(1, riskScore));
  }

  static calculateFrailtyIndicator(healthData: HealthData): number {
    let frailtyScore = 0;
    const totalCriteria = 5;

    if (healthData.bodyMetrics.weight !== undefined) {
      const bmi = healthData.bodyMetrics.bmi ||
        (healthData.bodyMetrics.weight / ((healthData.bodyMetrics.height / 100) ** 2));

      if (bmi < 18.5) {
        frailtyScore++;
      }
    }

    if (healthData.functionalTests?.gripStrength !== undefined) {
      const isMale = healthData.gender === 'MALE';
      const threshold = isMale ? 28 : 18;

      if (healthData.functionalTests.gripStrength < threshold) {
        frailtyScore++;
      }
    }

    if (healthData.functionalTests?.gaitSpeed !== undefined) {
      if (healthData.functionalTests.gaitSpeed < 1.0) {
        frailtyScore++;
      }
    }

    if (healthData.exerciseFrequency !== undefined && healthData.exerciseFrequency < 1) {
      frailtyScore++;
    }

    if (healthData.cognitiveScores?.gds !== undefined && healthData.cognitiveScores.gds > 5) {
      frailtyScore++;
    }

    return frailtyScore / totalCriteria;
  }

  static extractFeatures(healthData: HealthData): number[] {
    console.log('[HealthFeatureExtractor] 开始提取10维特征向量...');

    const features: number[] = new Array(HealthFeatureExtractor.FEATURE_DIMENSIONS);

    features[0] = HealthFeatureExtractor.normalize(
      healthData.age,
      HealthFeatureExtractor.NORMALIZATION_RANGES.age.min,
      HealthFeatureExtractor.NORMALIZATION_RANGES.age.max
    );

    const bmi = healthData.bodyMetrics.bmi ||
      (healthData.bodyMetrics.weight / ((healthData.bodyMetrics.height / 100) ** 2));
    features[1] = HealthFeatureExtractor.normalizeBMI(bmi);

    features[2] = HealthFeatureExtractor.normalize(
      healthData.bloodPressure.systolic,
      HealthFeatureExtractor.NORMALIZATION_RANGES.systolicBP.min,
      HealthFeatureExtractor.NORMALIZATION_RANGES.systolicBP.max
    );

    features[3] = HealthFeatureExtractor.normalize(
      healthData.bloodPressure.diastolic,
      HealthFeatureExtractor.NORMALIZATION_RANGES.diastolicBP.min,
      HealthFeatureExtractor.NORMALIZATION_RANGES.diastolicBP.max
    );

    features[4] = HealthFeatureExtractor.normalize(
      healthData.bloodGlucose.fasting,
      HealthFeatureExtractor.NORMALIZATION_RANGES.fastingGlucose.min,
      HealthFeatureExtractor.NORMALIZATION_RANGES.fastingGlucose.max
    );

    features[5] = HealthFeatureExtractor.normalize(
      healthData.heartRate.resting,
      HealthFeatureExtractor.NORMALIZATION_RANGES.heartRate.min,
      HealthFeatureExtractor.NORMALIZATION_RANGES.heartRate.max
    );

    features[6] = HealthFeatureExtractor.calculateSleepQualityScore(healthData.sleepData);

    features[7] = HealthFeatureExtractor.normalize(
      healthData.exerciseFrequency ?? 0,
      HealthFeatureExtractor.NORMALIZATION_RANGES.exerciseFreq.min,
      HealthFeatureExtractor.NORMALIZATION_RANGES.exerciseFreq.max
    );

    features[8] = HealthFeatureExtractor.calculateFallRiskScore(healthData);

    features[9] = HealthFeatureExtractor.calculateFrailtyIndicator(healthData);

    console.log('[HealthFeatureExtractor] 特征提取完成:');
    for (let i = 0; i < features.length; i++) {
      console.log(`  [${i}] ${HealthFeatureExtractor.FEATURE_NAMES[i]}: ${features[i].toFixed(4)}`);
    }

    return features;
  }

  static extractTimeSeriesFeatures(history: HealthData[]): TimeSeriesFeatures | null {
    if (!history || history.length < 2) {
      console.warn('[HealthFeatureExtractor] 历史数据不足，无法计算时间序列特征');
      return null;
    }

    console.log(`[HealthFeatureExtractor] 提取时间序列特征，历史记录数: ${history.length}`);

    const featureMatrix: number[][] = history.map(data => HealthFeatureExtractor.extractFeatures(data));

    const n = featureMatrix.length;
    const dim = HealthFeatureExtractor.FEATURE_DIMENSIONS;

    const mean: number[] = new Array(dim).fill(0);
    const std: number[] = new Array(dim).fill(0);
    const trend: number[] = new Array(dim).fill(0);

    for (let j = 0; j < dim; j++) {
      let sum = 0;
      for (let i = 0; i < n; i++) {
        sum += featureMatrix[i][j];
      }
      mean[j] = sum / n;

      let varianceSum = 0;
      for (let i = 0; i < n; i++) {
        varianceSum += Math.pow(featureMatrix[i][j] - mean[j], 2);
      }
      std[j] = Math.sqrt(varianceSum / n);

      if (n >= 3) {
        const firstHalf = Math.floor(n / 2);
        let firstSum = 0;
        let secondSum = 0;

        for (let i = 0; i < firstHalf; i++) {
          firstSum += featureMatrix[i][j];
        }
        for (let i = firstHalf; i < n; i++) {
          secondSum += featureMatrix[i][j];
        }

        const firstMean = firstSum / firstHalf;
        const secondMean = secondSum / (n - firstHalf);

        trend[j] = secondMean - firstMean;
      }
    }

    console.log('[HealthFeatureExtractor] 时间序列特征计算完成');
    const result: TimeSeriesFeatures = { mean, std, trend };
    return result;
  }

  static getFeatureInterpretation(features: number[]): FeatureInterpretation[] {
    const interpretations: FeatureInterpretation[] = [];

    interpretations.push({
      name: '年龄因素',
      value: `${Math.round(features[0] * 100)}岁等效`,
      status: features[0] > 0.7 ? 'warning' : 'normal'
    });

    interpretations.push({
      name: 'BMI指数',
      value: features[1].toFixed(2),
      status: (features[1] < 0.25 || features[1] > 0.75) ? 'abnormal' : 'normal'
    });

    interpretations.push({
      name: '收缩压',
      value: `${Math.round(70 + features[2] * 130)}mmHg`,
      status: features[2] > 0.65 ? 'warning' : 'normal'
    });

    interpretations.push({
      name: '舒张压',
      value: `${Math.round(40 + features[3] * 90)}mmHg`,
      status: features[3] > 0.7 ? 'warning' : 'normal'
    });

    interpretations.push({
      name: '空腹血糖',
      value: `${(2 + features[4] * 13).toFixed(1)}mmol/L`,
      status: features[4] > 0.55 ? 'abnormal' : 'normal'
    });

    interpretations.push({
      name: '静息心率',
      value: `${Math.round(40 + features[5] * 100)}bpm`,
      status: (features[5] < 0.25 || features[5] > 0.7) ? 'warning' : 'normal'
    });

    interpretations.push({
      name: '睡眠质量',
      value: `${(features[6] * 100).toFixed(0)}%`,
      status: features[6] < 0.4 ? 'warning' : 'normal'
    });

    interpretations.push({
      name: '运动频率',
      value: `${Math.round(features[7] * 7)}天/周`,
      status: features[7] < 0.3 ? 'warning' : 'normal'
    });

    interpretations.push({
      name: '跌倒风险',
      value: `${(features[8] * 100).toFixed(0)}%`,
      status: features[8] > 0.5 ? 'abnormal' : (features[8] > 0.3 ? 'warning' : 'normal')
    });

    interpretations.push({
      name: '衰弱指标',
      value: `${(features[9] * 100).toFixed(0)}%`,
      status: features[9] > 0.6 ? 'abnormal' : (features[9] > 0.33 ? 'warning' : 'normal')
    });

    return interpretations;
  }
}
