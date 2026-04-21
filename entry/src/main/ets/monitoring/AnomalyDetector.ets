export interface HealthValues {
  systolic?: number;
  diastolic?: number;
  value?: number;
  type?: string;
}

export type HealthRecordType = 'blood_pressure' | 'blood_sugar' | 'heart_rate' | 'weight' | 'temperature';

export interface HealthRecord {
  recordId: string;
  type: HealthRecordType;
  timestamp: string;
  source: 'MANUAL' | 'DEVICE' | 'WEARABLE';
  userId: string;
  values?: HealthValues;
}

export type RiskLevelType = 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

export interface AnomalyDetectionResult {
  isAnomalous: boolean;
  riskLevel: RiskLevelType;
  confidence: number;
  detectionStrategies: StrategyResult[];
  summary: string;
  recommendations: string[];
}

export interface StrategyResult {
  strategyName: string;
  isAnomalous: boolean;
  riskLevel: RiskLevelType;
  details: string;
  confidence: number;
}

export type AlertSeverity = 'INFO' | 'WARNING' | 'DANGER' | 'CRITICAL';

export interface Alert {
  alertId: string;
  recordId: string;
  type: HealthRecordType;
  severity: AlertSeverity;
  title: string;
  message: string;
  timestamp: string;
  isRead: boolean;
  isHandled: boolean;
  handlingNotes?: string;
  riskLevel: RiskLevelType;
  detectionDetails: AnomalyDetectionResult;
}

export interface StatisticsResult {
  mean: number;
  stdDev: number;
  min: number;
  max: number;
}

export interface TrendResult {
  isIncreasing: boolean;
  consecutiveChanges: number;
  avgChangeRate: number;
  totalChange: number;
}

export interface ThresholdRange {
  criticalHigh: number;
  high: number;
  normalHigh: number;
  normalLow: number;
  low: number;
  criticalLow: number;
}

export interface BloodPressureThresholds {
  systolic: ThresholdRange;
  diastolic: ThresholdRange;
}

export interface BloodSugarThresholds {
  fasting: ThresholdRange;
  random: ThresholdRange;
}

export interface HeartRateThresholds {
  criticalHigh: number;
  high: number;
  normalHigh: number;
  normalLow: number;
  low: number;
  criticalLow: number;
}

export interface WeightThresholds {
  deviationPercent: number;
}

export interface TemperatureThresholds {
  criticalHigh: number;
  high: number;
  normalHigh: number;
  normalLow: number;
  low: number;
  criticalLow: number;
}

export interface ThresholdsConfig {
  bloodPressure: BloodPressureThresholds;
  bloodSugar: BloodSugarThresholds;
  heartRate: HeartRateThresholds;
  weight: WeightThresholds;
  temperature: TemperatureThresholds;
}

export interface StatisticalParams {
  standardDeviations: number;
  minSampleSize: number;
  trendWindow: number;
}

export class RiskLevelMap {
  static getPriority(level: RiskLevelType): number {
    switch (level) {
      case 'NORMAL': return 0;
      case 'LOW': return 1;
      case 'MEDIUM': return 2;
      case 'HIGH': return 3;
      case 'CRITICAL': return 4;
      default: return 0;
    }
  }
}

export class AnomalyDetector {
  private static instance: AnomalyDetector | null = null;

  private static readonly THRESHOLDS: ThresholdsConfig = (() => {
    const systolicRange: ThresholdRange = { criticalHigh: 180, high: 160, normalHigh: 140, normalLow: 90, low: 80, criticalLow: 70 };
    const diastolicRange: ThresholdRange = { criticalHigh: 110, high: 100, normalHigh: 90, normalLow: 60, low: 50, criticalLow: 40 };
    const bloodPressureThresholds: BloodPressureThresholds = { systolic: systolicRange, diastolic: diastolicRange };

    const fastingRange: ThresholdRange = { criticalHigh: 11.0, high: 7.0, normalHigh: 6.1, normalLow: 3.9, low: 3.3, criticalLow: 2.8 };
    const randomRange: ThresholdRange = { criticalHigh: 13.9, high: 11.1, normalHigh: 7.8, normalLow: 3.9, low: 3.3, criticalLow: 2.8 };
    const bloodSugarThresholds: BloodSugarThresholds = { fasting: fastingRange, random: randomRange };

    const heartRateThresholds: HeartRateThresholds = { criticalHigh: 120, high: 100, normalHigh: 85, normalLow: 60, low: 50, criticalLow: 40 };
    const weightThresholds: WeightThresholds = { deviationPercent: 5 };
    const temperatureThresholds: TemperatureThresholds = { criticalHigh: 39.5, high: 38.5, normalHigh: 37.3, normalLow: 36.0, low: 35.5, criticalLow: 35.0 };

    return {
      bloodPressure: bloodPressureThresholds,
      bloodSugar: bloodSugarThresholds,
      heartRate: heartRateThresholds,
      weight: weightThresholds,
      temperature: temperatureThresholds
    };
  })();

  private static readonly STATISTICAL_PARAMS: StatisticalParams = {
    standardDeviations: 2,
    minSampleSize: 5,
    trendWindow: 3
  };

  private constructor() {
    console.log('[AnomalyDetector] 初始化异常检测器');
  }

  static getInstance(): AnomalyDetector {
    if (!AnomalyDetector.instance) {
      AnomalyDetector.instance = new AnomalyDetector();
    }
    return AnomalyDetector.instance;
  }

  detect(record: HealthRecord, history: HealthRecord[]): AnomalyDetectionResult {
    console.log(`[AnomalyDetector] 开始检测异常 - 类型: ${record.type}`);

    const result1 = this.thresholdCheck(record);
    const result2 = this.deviationCheck(record, history);
    const result3 = this.trendCheck(history.slice(-5));

    return this.mergeResults([result1, result2, result3]);
  }

  thresholdCheck(record: HealthRecord): StrategyResult {
    console.log(`[AnomalyDetector] 执行策略1: 阈值规则检测`);

    switch (record.type) {
      case 'blood_pressure':
        return this.checkBloodPressureThresholds(record);
      case 'blood_sugar':
        return this.checkBloodSugarThresholds(record);
      case 'heart_rate':
        return this.checkHeartRateThresholds(record);
      case 'temperature':
        return this.checkTemperatureThresholds(record);
      default:
        return this.createNormalResult('阈值检测', `${record.type}暂无阈值规则`);
    }
  }

  private checkBloodPressureThresholds(record: HealthRecord): StrategyResult {
    const systolic = record.values?.systolic || 0;
    const diastolic = record.values?.diastolic || 0;
    const thresholds = AnomalyDetector.THRESHOLDS.bloodPressure;

    let maxRiskLevel: 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' = 'NORMAL';
    let details: string[] = [];

    if (systolic >= thresholds.systolic.criticalHigh || diastolic >= thresholds.diastolic.criticalHigh ||
        systolic <= thresholds.systolic.criticalLow || diastolic <= thresholds.diastolic.criticalLow) {
      maxRiskLevel = 'CRITICAL';
      details.push(`血压${systolic}/${diastolic}处于危险范围！`);
    } else if (systolic >= thresholds.systolic.high || diastolic >= thresholds.diastolic.high) {
      maxRiskLevel = 'HIGH';
      details.push(`收缩压${systolic}或舒张压${diastolic}偏高`);
    } else if (systolic < thresholds.systolic.low || diastolic < thresholds.diastolic.low) {
      maxRiskLevel = 'MEDIUM';
      details.push(`血压偏低，需关注`);
    } else if (systolic > thresholds.systolic.normalHigh || diastolic > thresholds.diastolic.normalHigh) {
      maxRiskLevel = 'LOW';
      details.push(`血压略高于正常范围`);
    }

    return {
      strategyName: '阈值规则检测',
      isAnomalous: maxRiskLevel !== 'NORMAL',
      riskLevel: maxRiskLevel,
      details: details.length > 0 ? details.join('; ') : `血压${systolic}/${diastolic}mmHg正常`,
      confidence: maxRiskLevel === 'CRITICAL' ? 0.95 : 
                maxRiskLevel === 'HIGH' ? 0.88 : 
                maxRiskLevel === 'MEDIUM' ? 0.75 : 0.60
    };
  }

  private checkBloodSugarThresholds(record: HealthRecord): StrategyResult {
    const value = record.values?.value || 0;
    const type = record.values?.type || 'fasting';
    const bloodSugarThresholds = AnomalyDetector.THRESHOLDS.bloodSugar;
    const thresholds = (type === 'random') ? bloodSugarThresholds.random : bloodSugarThresholds.fasting;

    let riskLevel: 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' = 'NORMAL';
    let details: string = '';

    if (value >= thresholds.criticalHigh) {
      riskLevel = 'CRITICAL';
      details = `血糖${value.toFixed(1)}mmol/L严重偏高，可能存在酮症酸中毒风险`;
    } else if (value >= thresholds.high) {
      riskLevel = 'HIGH';
      details = `血糖${value.toFixed(1)}mmol/L明显偏高`;
    } else if (value <= thresholds.low) {
      riskLevel = 'HIGH';
      details = `血糖${value.toFixed(1)}mmol/L偏低，可能低血糖`;
    } else if (value <= thresholds.criticalLow) {
      riskLevel = 'CRITICAL';
      details = `血糖${value.toFixed(1)}mmol/L极低，有低血糖昏迷风险！`;
    } else if (value > thresholds.normalHigh) {
      riskLevel = 'LOW';
      details = `血糖${value.toFixed(1)}mmol/L略高`;
    }

    return {
      strategyName: '阈值规则检测',
      isAnomalous: riskLevel !== 'NORMAL',
      riskLevel: riskLevel,
      details: details || `血糖${value.toFixed(1)}mmol/L(${type})正常`,
      confidence: riskLevel === 'CRITICAL' ? 0.95 : 
                riskLevel === 'HIGH' ? 0.88 : 0.65
    };
  }

  private checkHeartRateThresholds(record: HealthRecord): StrategyResult {
    const value = record.values?.value || 0;
    const thresholds = AnomalyDetector.THRESHOLDS.heartRate;

    let riskLevel: 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' = 'NORMAL';
    let details: string = '';

    if (value >= thresholds.criticalHigh) {
      riskLevel = 'CRITICAL';
      details = `心率${value}bpm过快，可能心动过速或心律失常`;
    } else if (value <= thresholds.criticalLow) {
      riskLevel = 'CRITICAL';
      details = `心率${value}bpm过慢，可能心动过缓`;
    } else if (value >= thresholds.high) {
      riskLevel = 'MEDIUM';
      details = `心率${value}bpm偏快`;
    } else if (value <= thresholds.low) {
      riskLevel = 'MEDIUM';
      details = `心率${value}bpm偏慢`;
    }

    return {
      strategyName: '阈值规则检测',
      isAnomalous: riskLevel !== 'NORMAL',
      riskLevel: riskLevel,
      details: details || `心率${value}bpm正常`,
      confidence: riskLevel === 'CRITICAL' ? 0.92 : 0.75
    };
  }

  private checkTemperatureThresholds(record: HealthRecord): StrategyResult {
    const value = record.values?.value || 0;
    const thresholds = AnomalyDetector.THRESHOLDS.temperature;

    let riskLevel: 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' = 'NORMAL';
    let details: string = '';

    if (value >= thresholds.criticalHigh) {
      riskLevel = 'CRITICAL';
      details = `体温${value.toFixed(1)}°C极高，需立即就医`;
    } else if (value >= thresholds.high) {
      riskLevel = 'HIGH';
      details = `体温${value.toFixed(1)}°C发热`;
    } else if (value <= thresholds.criticalLow) {
      riskLevel = 'CRITICAL';
      details = `体温${value.toFixed(1)}°C过低，可能有失温风险`;
    } else if (value <= thresholds.low) {
      riskLevel = 'MEDIUM';
      details = `体温${value.toFixed(1)}°C偏低`;
    }

    return {
      strategyName: '阈值规则检测',
      isAnomalous: riskLevel !== 'NORMAL',
      riskLevel: riskLevel,
      details: details || `体温${value.toFixed(1)}°C正常`,
      confidence: riskLevel === 'CRITICAL' ? 0.95 : 0.78
    };
  }

  deviationCheck(record: HealthRecord, history: HealthRecord[]): StrategyResult {
    console.log('[AnomalyDetector] 执行策略2: 偏移检测（基于个人基线）');

    const typedHistory = history.filter(h => h.type === record.type);
    
    if (typedHistory.length < AnomalyDetector.STATISTICAL_PARAMS.minSampleSize) {
      return this.createNormalResult(
        '偏移检测', 
        `历史数据不足（需要至少${AnomalyDetector.STATISTICAL_PARAMS.minSampleSize}条记录），当前${typedHistory.length}条`
      );
    }

    const currentValue = this.extractNumericValue(record);
    const historicalValues = typedHistory.map(h => this.extractNumericValue(h)).filter(v => v > 0);

    if (historicalValues.length < AnomalyDetector.STATISTICAL_PARAMS.minSampleSize) {
      return this.createNormalResult('偏移检测', '有效数值不足');
    }

    const stats = this.calculateStatistics(historicalValues);
    const zScore = Math.abs((currentValue - stats.mean) / (stats.stdDev > 0 ? stats.stdDev : 1));
    
    const numStdDevs = AnomalyDetector.STATISTICAL_PARAMS.standardDeviations;
    
    let riskLevel: 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' = 'NORMAL';
    let details: string = '';

    if (zScore > 3 * numStdDevs) {
      riskLevel = 'CRITICAL';
      details = `当前值${currentValue.toFixed(1)}偏离个人基线超过3倍标准差（Z=${zScore.toFixed(2)}）`;
    } else if (zScore > 2 * numStdDevs) {
      riskLevel = 'HIGH';
      details = `当前值${currentValue.toFixed(1)}显著偏离个人基线（Z=${zScore.toFixed(2)}，均值${stats.mean.toFixed(1)}）`;
    } else if (zScore > 1.5 * numStdDevs) {
      riskLevel = 'MEDIUM';
      details = `当前值${currentValue.toFixed(1)}略偏离个人基线（Z=${zScore.toFixed(2)}）`;
    } else if (zScore > numStdDevs) {
      riskLevel = 'LOW';
      details = `当前值轻微波动（Z=${zScore.toFixed(2)}）`;
    } else {
      details = `当前值在个人基线范围内（Z=${zScore.toFixed(2)}，均值${stats.mean.toFixed(1)}±${stats.stdDev.toFixed(1)}）`;
    }

    return {
      strategyName: '偏移检测',
      isAnomalous: riskLevel !== 'NORMAL',
      riskLevel: riskLevel,
      details: details,
      confidence: Math.min(0.95, 0.6 + zScore * 0.12)
    };
  }

  trendCheck(recentRecords: HealthRecord[]): StrategyResult {
    console.log('[AnomalyDetector] 执行策略3: 趋势突变检测');

    if (recentRecords.length < AnomalyDetector.STATISTICAL_PARAMS.trendWindow) {
      return this.createNormalResult(
        '趋势检测', 
        `数据点不足（需要${AnomalyDetector.STATISTICAL_PARAMS.trendWindow}个连续测量值）`
      );
    }

    const values = recentRecords.map(r => this.extractNumericValue(r));
    const validValues = values.filter(v => v > 0);

    if (validValues.length < AnomalyDetector.STATISTICAL_PARAMS.trendWindow) {
      return this.createNormalResult('趋势检测', '有效数据点不足');
    }

    const trends = this.calculateTrend(validValues);
    
    let riskLevel: 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' = 'NORMAL';
    let details: string = '';
    const direction = trends.isIncreasing ? '上升' : '下降';

    if (trends.consecutiveChanges >= 4 && Math.abs(trends.avgChangeRate) > 15) {
      riskLevel = 'CRITICAL';
      details = `连续${trends.consecutiveChanges}次${direction}趋势，平均变化率${Math.abs(trends.avgChangeRate).toFixed(1)}%，情况危急！`;
    } else if (trends.consecutiveChanges >= 3 && Math.abs(trends.avgChangeRate) > 10) {
      riskLevel = 'HIGH';
      details = `连续${trends.consecutiveChanges}次${direction}趋势，变化显著`;
    } else if (trends.consecutiveChanges >= 3) {
      riskLevel = 'MEDIUM';
      details = `连续${trends.consecutiveChanges}次${direction}，建议关注`;
    } else if (Math.abs(trends.avgChangeRate) > 10) {
      riskLevel = 'LOW';
      details = `存在${direction}趋势迹象`;
    } else {
      details = `趋势稳定（变化率±${Math.abs(trends.avgChangeRate).toFixed(1)}%）`;
    }

    return {
      strategyName: '趋势突变检测',
      isAnomalous: riskLevel !== 'NORMAL',
      riskLevel: riskLevel,
      details: details,
      confidence: Math.min(0.92, 0.55 + trends.consecutiveChanges * 0.1 + Math.abs(trends.avgChangeRate) * 0.02)
    };
  }

  mergeResults(results: StrategyResult[]): AnomalyDetectionResult {
    const anomalousResults = results.filter(r => r.isAnomalous);

    const overallRiskLevel = this.getHighestRiskLevel(results.map(r => r.riskLevel));
    
    const avgConfidence = results.reduce((sum, r) => sum + r.confidence, 0) / results.length;

    const summaries: string[] = [];
    const allRecommendations: string[] = [];

    for (const result of results) {
      if (result.isAnomalous) {
        summaries.push(`[${result.strategyName}] ${result.details}`);
        
        const recs = this.generateRecommendations(result);
        recs.forEach(rec => {
          if (!allRecommendations.includes(rec)) {
            allRecommendations.push(rec);
          }
        });
      }
    }

    return {
      isAnomalous: anomalousResults.length > 0,
      riskLevel: overallRiskLevel,
      confidence: parseFloat(avgConfidence.toFixed(3)),
      detectionStrategies: results,
      summary: anomalousResults.length > 0 ? 
        `检测到${anomalousResults.length}项异常：\n${summaries.join('\n')}` : 
        '所有指标正常',
      recommendations: allRecommendations.slice(0, 5)
    };
  }

  private extractNumericValue(record: HealthRecord): number {
    switch (record.type) {
      case 'blood_pressure':
        return record.values?.systolic || 0;
      case 'blood_sugar':
      case 'heart_rate':
      case 'weight':
      case 'temperature':
        return record.values?.value || 0;
      default:
        return 0;
    }
  }

  private calculateStatistics(values: number[]): StatisticsResult {
    const n = values.length;
    const mean = values.reduce((sum, val) => sum + val, 0) / n;
    const variance = values.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / (n - 1);
    const stdDev = Math.sqrt(variance);

    let minVal = values[0];
    let maxVal = values[0];
    for (let i = 1; i < values.length; i++) {
      if (values[i] < minVal) minVal = values[i];
      if (values[i] > maxVal) maxVal = values[i];
    }

    return {
      mean: parseFloat(mean.toFixed(2)),
      stdDev: parseFloat(stdDev.toFixed(2)),
      min: minVal,
      max: maxVal
    };
  }

  private calculateTrend(values: number[]): TrendResult {
    let consecutiveChanges = 0;
    let isIncreasing = false;
    const changes: number[] = [];

    for (let i = 1; i < values.length; i++) {
      const change = values[i] - values[i - 1];
      changes.push(change);

      if (i === 1) {
        consecutiveChanges = 1;
        isIncreasing = change > 0;
      } else if ((change > 0 && isIncreasing) || (change < 0 && !isIncreasing)) {
        consecutiveChanges++;
      } else if (change !== 0) {
        consecutiveChanges = 1;
        isIncreasing = change > 0;
      }
    }

    const avgChangeRate = changes.length > 0 ?
      (changes.reduce((sum, c) => sum + c, 0) / changes.length) / 
      (values[0] > 0 ? values[0] : 1) * 100 : 0;

    const totalChange = values.length > 1 ? 
      values[values.length - 1] - values[0] : 0;

    return {
      isIncreasing: isIncreasing,
      consecutiveChanges: consecutiveChanges,
      avgChangeRate: parseFloat(avgChangeRate.toFixed(2)),
      totalChange: parseFloat(totalChange.toFixed(2))
    };
  }

  private getHighestRiskLevel(levels: ('NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL')[]):
    'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' {

    let highestLevel: 'NORMAL' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' = 'NORMAL';
    let highestPriority = 0;

    for (const level of levels) {
      const priority = RiskLevelMap.getPriority(level);
      if (priority > highestPriority) {
        highestPriority = priority;
        highestLevel = level;
      }
    }

    return highestLevel;
  }

  private generateRecommendations(result: StrategyResult): string[] {
    const recommendations: string[] = [];

    switch (result.riskLevel) {
      case 'CRITICAL':
        recommendations.push('⚠️ 立即联系医生或急救服务');
        recommendations.push('📞 通知紧急联系人');
        break;
      
      case 'HIGH':
        recommendations.push('🔍 建议尽快就医检查');
        recommendations.push('📊 持续监测并记录数据');
        break;
      
      case 'MEDIUM':
        recommendations.push('⏰ 建议在本周内咨询医生');
        recommendations.push('📝 注意观察症状变化');
        break;
      
      case 'LOW':
        recommendations.push('💡 保持健康生活方式');
        recommendations.push('📅 定期复查');
        break;
    }

    if (result.strategyName.includes('趋势')) {
      recommendations.push('📈 关注后续测量值的趋势变化');
    }

    return recommendations;
  }

  private createNormalResult(strategy: string, details: string): StrategyResult {
    return {
      strategyName: strategy,
      isAnomalous: false,
      riskLevel: 'NORMAL',
      details: details,
      confidence: 0.50
    };
  }
}
