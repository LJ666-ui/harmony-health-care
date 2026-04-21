import { HealthData, HealthFeatureExtractor } from './HealthFeatureExtractor';
import { RiskAssessmentResult, RisksMap, RiskItem } from './RiskAssessmentEngine';

export interface TrendPoint {
  timestamp: string;
  date: string;
  values: number[];
}

export interface TrendAnalysis {
  disease: string;
  label: string;
  currentScore: number;
  previousScore?: number;
  changeRate: number;
  trendDirection: 'IMPROVING' | 'STABLE' | 'WORSENING';
  trendDescription: string;
  dataPoints: TrendPoint[];
  volatility: number;
  prediction?: PredictionInfo;
}

export interface PredictionInfo {
  nextMonthScore: number;
  confidence: number;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
}

export interface OverallTrend {
  assessmentCount: number;
  timeSpanDays: number;
  overallTrend: 'IMPROVING' | 'STABLE' | 'WORSENING';
  overallChangeRate: number;
  diseaseTrends: TrendAnalysis[];
  keyFindings: string[];
  recommendations: string[];
}

interface TrendThresholds {
  improving: number;
  stable_low: number;
  stable_high: number;
  worsening: number;
}

interface OverallTrendResult {
  direction: 'IMPROVING' | 'STABLE' | 'WORSENING';
  changeRate: number;
}

class DiseaseDataPoints {
  hypertension: TrendPoint[] = [];
  diabetes: TrendPoint[] = [];
  fall: TrendPoint[] = [];
  frailty: TrendPoint[] = [];
  sarcopenia: TrendPoint[] = [];
}

export class TrendAnalyzer {

  private static readonly TREND_THRESHOLDS: TrendThresholds = {
    improving: -0.08,
    stable_low: -0.08,
    stable_high: 0.08,
    worsening: 0.08
  };

  private constructor() {}

  static analyzeTrend(
    historyResults: RiskAssessmentResult[],
    currentResult: RiskAssessmentResult
  ): OverallTrend {
    
    console.log(`[TrendAnalyzer] 开始分析趋势，历史记录数: ${historyResults.length}`);

    if (historyResults.length < 2) {
      return TrendAnalyzer.createInsufficientDataResult(currentResult);
    }

    const diseaseTrends: TrendAnalysis[] = [];
    const dataPoints = new DiseaseDataPoints();

    for (const result of historyResults) {
      dataPoints.hypertension.push({
        timestamp: result.timestamp,
        date: new Date(result.timestamp).toLocaleDateString('zh-CN'),
        values: [
          result.risks.hypertension.probability,
          result.risks.diabetes.probability,
          result.risks.fall.probability,
          result.risks.frailty.probability,
          result.risks.sarcopenia.probability
        ]
      });
      dataPoints.diabetes.push({
        timestamp: result.timestamp,
        date: new Date(result.timestamp).toLocaleDateString('zh-CN'),
        values: [
          result.risks.hypertension.probability,
          result.risks.diabetes.probability,
          result.risks.fall.probability,
          result.risks.frailty.probability,
          result.risks.sarcopenia.probability
        ]
      });
      dataPoints.fall.push({
        timestamp: result.timestamp,
        date: new Date(result.timestamp).toLocaleDateString('zh-CN'),
        values: [
          result.risks.hypertension.probability,
          result.risks.diabetes.probability,
          result.risks.fall.probability,
          result.risks.frailty.probability,
          result.risks.sarcopenia.probability
        ]
      });
      dataPoints.frailty.push({
        timestamp: result.timestamp,
        date: new Date(result.timestamp).toLocaleDateString('zh-CN'),
        values: [
          result.risks.hypertension.probability,
          result.risks.diabetes.probability,
          result.risks.fall.probability,
          result.risks.frailty.probability,
          result.risks.sarcopenia.probability
        ]
      });
      dataPoints.sarcopenia.push({
        timestamp: result.timestamp,
        date: new Date(result.timestamp).toLocaleDateString('zh-CN'),
        values: [
          result.risks.hypertension.probability,
          result.risks.diabetes.probability,
          result.risks.fall.probability,
          result.risks.frailty.probability,
          result.risks.sarcopenia.probability
        ]
      });
    }

    const histHypertension = historyResults.map(r => r.risks.hypertension.probability);
    const histDiabetes = historyResults.map(r => r.risks.diabetes.probability);
    const histFall = historyResults.map(r => r.risks.fall.probability);
    const histFrailty = historyResults.map(r => r.risks.frailty.probability);
    const histSarcopenia = historyResults.map(r => r.risks.sarcopenia.probability);

    diseaseTrends.push(TrendAnalyzer.analyzeDiseaseTrend(
      'hypertension', '高血压', histHypertension, dataPoints.hypertension,
      currentResult.risks.hypertension.probability
    ));
    diseaseTrends.push(TrendAnalyzer.analyzeDiseaseTrend(
      'diabetes', '糖尿病', histDiabetes, dataPoints.diabetes,
      currentResult.risks.diabetes.probability
    ));
    diseaseTrends.push(TrendAnalyzer.analyzeDiseaseTrend(
      'fall', '跌倒风险', histFall, dataPoints.fall,
      currentResult.risks.fall.probability
    ));
    diseaseTrends.push(TrendAnalyzer.analyzeDiseaseTrend(
      'frailty', '衰弱综合征', histFrailty, dataPoints.frailty,
      currentResult.risks.frailty.probability
    ));
    diseaseTrends.push(TrendAnalyzer.analyzeDiseaseTrend(
      'sarcopenia', '肌少症', histSarcopenia, dataPoints.sarcopenia,
      currentResult.risks.sarcopenia.probability
    ));

    const overallTrend = TrendAnalyzer.calculateOverallTrend(diseaseTrends);
    const timeSpanDays = TrendAnalyzer.calculateTimeSpan(historyResults);
    const keyFindings = TrendAnalyzer.generateKeyFindings(diseaseTrends, overallTrend);
    const recommendations = TrendAnalyzer.generateRecommendations(diseaseTrends);

    const result: OverallTrend = {
      assessmentCount: historyResults.length + 1,
      timeSpanDays: timeSpanDays,
      overallTrend: overallTrend.direction,
      overallChangeRate: overallTrend.changeRate,
      diseaseTrends: diseaseTrends,
      keyFindings: keyFindings,
      recommendations: recommendations
    };

    console.log('[TrendAnalyzer] 趋势分析完成:');
    console.log(`  总体趋势: ${result.overallTrend}`);
    console.log(`  变化率: ${(result.overallChangeRate * 100).toFixed(1)}%`);
    console.log(`  关键发现数: ${keyFindings.length}`);
    console.log(`  建议数: ${recommendations.length}`);

    return result;
  }

  private static analyzeDiseaseTrend(
    disease: string,
    label: string,
    historicalValues: number[],
    dataPoints: TrendPoint[],
    currentValue: number
  ): TrendAnalysis {
    
    const previousValue = historicalValues[historicalValues.length - 2] || historicalValues[0];
    const changeRate = currentValue - previousValue;

    let trendDirection: 'IMPROVING' | 'STABLE' | 'WORSENING';
    if (changeRate < TrendAnalyzer.TREND_THRESHOLDS.improving) {
      trendDirection = 'IMPROVING';
    } else if (changeRate > TrendAnalyzer.TREND_THRESHOLDS.worsening) {
      trendDirection = 'WORSENING';
    } else {
      trendDirection = 'STABLE';
    }

    const volatility = TrendAnalyzer.calculateVolatility(historicalValues);

    const prediction = TrendAnalyzer.predictNextMonth(historicalValues, currentValue, volatility);

    const trendDescription = TrendAnalyzer.generateTrendDescription(
      label,
      currentValue,
      previousValue,
      changeRate,
      trendDirection,
      prediction
    );

    return {
      disease: disease,
      label: label,
      currentScore: currentValue,
      previousScore: previousValue,
      changeRate: parseFloat(changeRate.toFixed(4)),
      trendDirection: trendDirection,
      trendDescription: trendDescription,
      dataPoints: dataPoints,
      volatility: volatility,
      prediction: prediction
    };
  }

  private static calculateVolatility(values: number[]): number {
    if (values.length < 2) return 0;

    const mean = values.reduce((sum, val) => sum + val, 0) / values.length;
    
    const varianceSum = values.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0);
    const variance = varianceSum / (values.length - 1);

    return Math.sqrt(variance);
  }

  private static predictNextMonth(
    historicalValues: number[],
    currentValue: number,
    volatility: number
  ): PredictionInfo | undefined {
    
    if (historicalValues.length < 3) return undefined;

    const n = historicalValues.length;
    let sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;

    for (let i = 0; i < n; i++) {
      sumX += i;
      sumY += historicalValues[i];
      sumXY += i * historicalValues[i];
      sumXX += i * i;
    }

    const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    const intercept = (sumY - slope * sumX) / n;

    const predictedRaw = slope * n + intercept;
    const predictedScore = Math.max(0, Math.min(1, predictedRaw));

    const confidence = Math.max(0.4, Math.min(0.95, 1 - volatility));

    let riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
    if (predictedScore >= 0.8) riskLevel = 'CRITICAL';
    else if (predictedScore >= 0.6) riskLevel = 'HIGH';
    else if (predictedScore >= 0.3) riskLevel = 'MEDIUM';
    else riskLevel = 'LOW';

    return {
      nextMonthScore: parseFloat(predictedScore.toFixed(4)),
      confidence: parseFloat(confidence.toFixed(2)),
      riskLevel: riskLevel
    };
  }

  private static generateTrendDescription(
    label: string,
    current: number,
    previous: number,
    changeRate: number,
    direction: 'IMPROVING' | 'STABLE' | 'WORSENING',
    prediction?: PredictionInfo
  ): string {
    
    const currentPercent = (current * 100).toFixed(1);
    const changePercent = (Math.abs(changeRate) * 100).toFixed(1);

    let description = '';

    switch (direction) {
      case 'IMPROVING':
        description = `${label}风险改善，当前${currentPercent}%，较上次下降${changePercent}%`;
        break;
      case 'WORSENING':
        description = `${label}风险上升⚠️，当前${currentPercent}%，较上次增加${changePercent}%`;
        break;
      case 'STABLE':
        description = `${label}风险稳定，当前${currentPercent}%，变化幅度<8%`;
        break;
    }

    if (prediction && direction === 'WORSENING') {
      description += `，预计下月可能达到${(prediction.nextMonthScore * 100).toFixed(1)}%`;
    }

    return description;
  }

  private static calculateOverallTrend(diseaseTrends: TrendAnalysis[]): OverallTrendResult {
    
    const weights = [0.25, 0.25, 0.15, 0.20, 0.15];
    let weightedChange = 0;

    for (let i = 0; i < diseaseTrends.length; i++) {
      weightedChange += diseaseTrends[i].changeRate * weights[i];
    }

    let direction: 'IMPROVING' | 'STABLE' | 'WORSENING';
    if (weightedChange < TrendAnalyzer.TREND_THRESHOLDS.improving) {
      direction = 'IMPROVING';
    } else if (weightedChange > TrendAnalyzer.TREND_THRESHOLDS.worsening) {
      direction = 'WORSENING';
    } else {
      direction = 'STABLE';
    }

    return {
      direction: direction,
      changeRate: parseFloat(weightedChange.toFixed(4))
    };
  }

  private static calculateTimeSpan(results: RiskAssessmentResult[]): number {
    if (results.length < 2) return 0;

    const firstDate = new Date(results[0].timestamp).getTime();
    const lastDate = new Date(results[results.length - 1].timestamp).getTime();

    return Math.round((lastDate - firstDate) / (1000 * 60 * 60 * 24));
  }

  private static generateKeyFindings(trends: TrendAnalysis[], overall: OverallTrendResult): string[] {
    const findings: string[] = [];

    findings.push(`在${trends[0].dataPoints.length}次评估中，整体健康风险呈${overall.direction === 'IMPROVING' ? '改善' : overall.direction === 'WORSENING' ? '恶化' : '稳定'}趋势`);

    const worseningDiseases = trends.filter(t => t.trendDirection === 'WORSENING');
    if (worseningDiseases.length > 0) {
      findings.push(`${worseningDiseases.length}项指标呈现恶化趋势：${worseningDiseases.map(d => d.label).join('、')}`);
    }

    const improvingDiseases = trends.filter(t => t.trendDirection === 'IMPROVING');
    if (improvingDiseases.length > 0) {
      findings.push(`${improvingDiseases.length}项指标有所改善：${improvingDiseases.map(d => d.label).join('、')}`);
    }

    const highRiskDiseases = trends.filter(t => t.currentScore > 0.6);
    if (highRiskDiseases.length > 0) {
      findings.push(`当前高风险项目：${highRiskDiseases.map(d => `${d.label}(${(d.currentScore * 100).toFixed(0)}%)`).join('、')}`);
    }

    const highVolatilityDiseases = trends.filter(t => t.volatility > 0.12);
    if (highVolatilityDiseases.length > 0) {
      findings.push(`${highVolatilityDiseases.map(d => d.label).join('、')}波动较大，需关注稳定性`);
    }

    const criticalPredictions = trends.filter(t => t.prediction !== undefined && t.prediction.riskLevel === 'CRITICAL');
    if (criticalPredictions.length > 0) {
      findings.push(`⚠️ 预警：${criticalPredictions.map(d => d.label).join('、')}可能在下月达到极高风险`);
    }

    return findings.slice(0, 5);
  }

  private static generateRecommendations(trends: TrendAnalysis[]): string[] {
    const recommendations: string[] = [];

    for (const trend of trends) {
      if (trend.trendDirection === 'WORSENING' && trend.currentScore > 0.5) {
        recommendations.push(`${trend.label}风险持续升高，建议尽快就医检查`);
      }
    }

    const hypertensionTrend = trends.find(t => t.disease === 'hypertension');
    if (hypertensionTrend !== undefined && hypertensionTrend.trendDirection === 'WORSENING') {
      recommendations.push('血压管理需要加强，建议每日监测并记录血压值');
    }

    const diabetesTrend = trends.find(t => t.disease === 'diabetes');
    if (diabetesTrend !== undefined && diabetesTrend.trendDirection === 'WORSENING') {
      recommendations.push('血糖控制不佳，建议调整饮食结构并复查糖化血红蛋白');
    }

    const fallTrend = trends.find(t => t.disease === 'fall');
    if (fallTrend !== undefined && fallTrend.currentScore > 0.45) {
      recommendations.push('跌倒风险较高，建议进行居家环境安全评估和平衡训练');
    }

    const frailtyTrend = trends.find(t => t.disease === 'frailty');
    if (frailtyTrend !== undefined && frailtyTrend.trendDirection === 'WORSENING') {
      recommendations.push('衰弱迹象加重，建议增加蛋白质摄入和抗阻力运动');
    }

    if (recommendations.length === 0) {
      recommendations.push('各项指标总体稳定，继续保持健康生活方式');
      recommendations.push('建议每月进行一次风险评估以监控健康状况');
    }

    return recommendations.slice(0, 6);
  }

  private static createInsufficientDataResult(currentResult: RiskAssessmentResult): OverallTrend {
    return {
      assessmentCount: 1,
      timeSpanDays: 0,
      overallTrend: 'STABLE',
      overallChangeRate: 0,
      diseaseTrends: [],
      keyFindings: ['评估次数不足，无法进行趋势分析。建议至少进行2-3次评估后再查看趋势'],
      recommendations: ['请定期进行风险评估以积累足够的历史数据']
    };
  }

  static generateTrendReport(trend: OverallTrend): string {
    let report = '\n══════════════════════════════════════\n';
    report += '       健康风险趋势分析报告\n';
    report += '══════════════════════════════════════\n\n';

    report += `评估记录数: ${trend.assessmentCount}次\n`;
    report += `时间跨度: ${trend.timeSpanDays}天\n`;
    report += `总体趋势: ${TrendAnalyzer.getTrendLabel(trend.overallTrend)}\n`;
    report += `综合变化率: ${(trend.overallChangeRate * 100).toFixed(1)}%\n\n`;

    report += '【各维度趋势详情】\n';
    for (const dt of trend.diseaseTrends) {
      const arrow = dt.trendDirection === 'IMPROVING' ? '↓' : 
                    dt.trendDirection === 'WORSENING' ? '↑' : '→';
      report += `\n${dt.label} ${arrow} ${(dt.currentScore * 100).toFixed(1)}% `;
      report += `(变化: ${(dt.changeRate * 100 > 0 ? '+' : '')}${(dt.changeRate * 100).toFixed(1)}%)\n`;
      report += `  ${dt.trendDescription}\n`;
      
      if (dt.prediction) {
        report += `  📈 预测下月: ${(dt.prediction.nextMonthScore * 100).toFixed(1)}% `;
        report += `(置信度: ${(dt.prediction.confidence * 100).toFixed(0)}%)\n`;
      }
    }

    if (trend.keyFindings.length > 0) {
      report += '\n【关键发现】\n';
      trend.keyFindings.forEach((finding, idx) => {
        report += `${idx + 1}. ${finding}\n`;
      });
    }

    if (trend.recommendations.length > 0) {
      report += '\n【改进建议】\n';
      trend.recommendations.forEach((rec) => {
        report += `• ${rec}\n`;
      });
    }

    report += '\n══════════════════════════════════════\n';

    return report;
  }

  private static getTrendLabel(direction: string): string {
    switch (direction) {
      case 'IMPROVING': return '改善 ✅';
      case 'WORSENING': return '恶化 ⚠️';
      case 'STABLE': return '稳定 ➡️';
      default: return '未知';
    }
  }
}
