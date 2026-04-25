import { DiseasePredictor, UserProfile, RiskPoint } from './DiseasePredictor';

export interface SimulationPlan {
  id: string;
  name: string;
  icon: string;
  category: 'exercise' | 'diet' | 'lifestyle' | 'medication';
  description: string;
}

export interface SimulationResult {
  planName: string;
  metricName: string;
  currentValue: number;
  projectedValues: number[];
  unit: string;
  improvement: number;
  timeFrameMonths: number;
  notes: string[];
}

export interface SimulationConfig {
  profile: UserProfile;
  selectedPlan: SimulationPlan;
  durationMonths: number;
  adherenceLevel: 'low' | 'medium' | 'high';
}

export class TreatmentSimulator {

  static readonly PLANS: SimulationPlan[] = [
    TreatmentSimulator.createPlan('exercise_regular', '规律运动', '🏃', 'exercise',
      '每周5次，每次30分钟中等强度有氧运动（快走、游泳、骑行）'),
    TreatmentSimulator.createPlan('strength_training', '力量训练', '💪', 'exercise',
      '每周3次，每次45分钟力量训练（器械/自重）'),
    TreatmentSimulator.createPlan('mediterranean_diet', '地中海饮食', '🥗', 'diet',
      '高纤维、橄榄油、鱼类、坚果、全谷物为主'),
    TreatmentSimulator.createPlan('low_salt_diet', '低盐饮食', '🧂', 'diet',
      '每日钠摄入<2000mg，减少加工食品'),
    TreatmentSimulator.createPlan('weight_loss', '减重计划', '⚖️', 'lifestyle',
      '目标减重5-10%，通过饮食控制+运动实现'),
    TreatmentSimulator.createPlan('quit_smoking', '戒烟计划', '🚭', 'lifestyle',
      '完全戒烟，配合尼古丁替代疗法'),
    TreatmentSimulator.createPlan('sleep_optimization', '睡眠优化', '😴', 'lifestyle',
      '保证7-8小时睡眠，规律作息')
  ];

  private static createPlan(id: string, name: string, icon: string,
    category: 'exercise' | 'diet' | 'lifestyle' | 'medication', description: string): SimulationPlan {
    const plan: SimulationPlan = { id: id, name: name, icon: icon, category: category, description: description };
    return plan;
  }

  static simulate(config: SimulationConfig): SimulationResult[] {
    const results: SimulationResult[] = [];

    switch (config.selectedPlan.id) {
      case 'exercise_regular':
        results.push(...TreatmentSimulator.simulateExerciseRegular(config));
        break;
      case 'strength_training':
        results.push(...TreatmentSimulator.simulateStrengthTraining(config));
        break;
      case 'mediterranean_diet':
        results.push(...TreatmentSimulator.simulateMediterraneanDiet(config));
        break;
      case 'low_salt_diet':
        results.push(...TreatmentSimulator.simulateLowSaltDiet(config));
        break;
      case 'weight_loss':
        results.push(...TreatmentSimulator.simulateWeightLoss(config));
        break;
      case 'quit_smoking':
        results.push(...TreatmentSimulator.simulateQuitSmoking(config));
        break;
      case 'sleep_optimization':
        results.push(...TreatmentSimulator.simulateSleepOptimization(config));
        break;
      default:
        break;
    }

    return results;
  }

  private static getAdherenceMultiplier(adherence: string): number {
    switch (adherence) {
      case 'high': return 1.0;
      case 'medium': return 0.7;
      case 'low': return 0.4;
      default: return 0.7;
    }
  }

  private static generateProjectedValues(
    startValue: number,
    monthlyChange: number,
    months: number,
    targetValue?: number
  ): number[] {
    const values: number[] = [];
    let current: number = startValue;

    for (let i = 0; i <= months; i++) {
      if (targetValue !== undefined) {
        const progress: number = i / months;
        current = startValue + (targetValue - startValue) * TreatmentSimulator.easeOutQuad(progress);
      } else {
        current = startValue + (monthlyChange * i);
      }

      values.push(Math.round(current * 100) / 100);
    }

    return values;
  }

  private static easeOutQuad(t: number): number {
    return t * (2 - t);
  }

  private static simulateExerciseRegular(config: SimulationConfig): SimulationResult[] {
    const multiplier: number = TreatmentSimulator.getAdherenceMultiplier(config.adherenceLevel);
    const months: number = config.durationMonths;
    const bmi: number = DiseasePredictor.calculateBMI(config.profile);

    const weightLossPerMonth: number = 0.3 * multiplier;
    const projectedWeights: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.weight,
      -weightLossPerMonth,
      months
    );

    const bpReductionPerMonth: number = 0.8 * multiplier;
    const projectedBP: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.systolicBP,
      -bpReductionPerMonth,
      months,
      Math.max(115, config.profile.systolicBP - 15 * multiplier)
    );

    const cholesterolReduction: number = 2 * multiplier;
    const projectedCholesterol: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.totalCholesterol,
      -cholesterolReduction * (months > 12 ? 12 : months) / months,
      months,
      Math.max(160, config.profile.totalCholesterol - 20 * multiplier)
    );

    return [
      TreatmentSimulator.buildWeightResult(config, projectedWeights, weightLossPerMonth),
      TreatmentSimulator.buildBPResult(config, projectedBP, bpReductionPerMonth),
      TreatmentSimulator.buildCholesterolResult(config, projectedCholesterol, cholesterolReduction)
    ];
  }

  private static buildWeightResult(config: SimulationConfig, projectedWeights: number[],
    _weightLossPerMonth: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '体重(kg)';
    result.currentValue = config.profile.weight;
    result.projectedValues = projectedWeights;
    result.unit = 'kg';
    result.improvement = ((config.profile.weight -
      projectedWeights[projectedWeights.length - 1]) / config.profile.weight * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['有氧运动可有效降低体重', '建议结合力量训练效果更佳'];
    return result;
  }

  private static buildBPResult(config: SimulationConfig, projectedBP: number[],
    _bpReductionPerMonth: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '收缩压(mmHg)';
    result.currentValue = config.profile.systolicBP;
    result.projectedValues = projectedBP;
    result.unit = 'mmHg';
    result.improvement = ((config.profile.systolicBP -
      projectedBP[projectedBP.length - 1]) / config.profile.systolicBP * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['运动可改善血管弹性', '持续坚持效果更显著'];
    return result;
  }

  private static buildCholesterolResult(config: SimulationConfig, projectedCholesterol: number[],
    _cholesterolReduction: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '总胆固醇(mmol/L)';
    result.currentValue = config.profile.totalCholesterol;
    result.projectedValues = projectedCholesterol;
    result.unit = 'mmol/L';
    result.improvement = ((config.profile.totalCholesterol -
      projectedCholesterol[projectedCholesterol.length - 1]) / config.profile.totalCholesterol * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['有氧运动提升HDL胆固醇', '降低心血管疾病风险'];
    return result;
  }

  private static simulateStrengthTraining(config: SimulationConfig): SimulationResult[] {
    const multiplier: number = TreatmentSimulator.getAdherenceMultiplier(config.adherenceLevel);
    const months: number = config.durationMonths;

    const muscleGainPerMonth: number = 0.2 * multiplier;
    const projectedMuscle: number[] = TreatmentSimulator.generateProjectedValues(0, muscleGainPerMonth, months);

    const bmdImprovement: number = 0.5 * multiplier;
    const projectedBMD: number[] = TreatmentSimulator.generateProjectedValues(-2, bmdImprovement / 10, months);

    const metabolicRateIncrease: number = 30 * multiplier;
    const projectedMetabolicRate: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.weight * 22,
      metabolicRateIncrease / months,
      months
    );

    return [
      TreatmentSimulator.buildMuscleResult(config, projectedMuscle, muscleGainPerMonth),
      TreatmentSimulator.buildBMDResult(config, projectedBMD, bmdImprovement),
      TreatmentSimulator.buildMetabolicResult(config, projectedMetabolicRate, metabolicRateIncrease)
    ];
  }

  private static buildMuscleResult(config: SimulationConfig, projectedMuscle: number[],
    _muscleGainPerMonth: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '肌肉量变化(kg)';
    result.currentValue = 0;
    result.projectedValues = projectedMuscle;
    result.unit = 'kg';
    result.improvement = projectedMuscle[projectedMuscle.length - 1];
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['力量训练增加肌肉质量', '基础代谢率随之提升'];
    return result;
  }

  private static buildBMDResult(config: SimulationConfig, projectedBMD: number[],
    _bmdImprovement: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '骨密度T值变化';
    result.currentValue = -2;
    result.projectedValues = projectedBMD;
    result.unit = 'T值';
    result.improvement = (projectedBMD[projectedBMD.length - 1] + 2) / 2 * 100;
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['负重运动增强骨密度', '预防骨质疏松'];
    return result;
  }

  private static buildMetabolicResult(config: SimulationConfig, projectedMetabolicRate: number[],
    metabolicRateIncrease: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '基础代谢率(kcal/天)';
    result.currentValue = Math.round(config.profile.weight * 22);
    result.projectedValues = projectedMetabolicRate.map(v => Math.round(v));
    result.unit = 'kcal';
    result.improvement = (metabolicRateIncrease / (config.profile.weight * 22)) * 100;
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['肌肉量增加提升代谢', '有助于长期体重管理'];
    return result;
  }

  private static simulateMediterraneanDiet(config: SimulationConfig): SimulationResult[] {
    const multiplier: number = TreatmentSimulator.getAdherenceMultiplier(config.adherenceLevel);
    const months: number = config.durationMonths;

    const glucoseReduction: number = 0.15 * multiplier;
    const projectedGlucose: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.fastingGlucose,
      -glucoseReduction,
      months,
      Math.max(4.5, config.profile.fastingGlucose - 1.5 * multiplier)
    );

    const ldlReduction: number = 0.25 * multiplier;
    const projectedLDL: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.totalCholesterol * 0.6,
      -ldlReduction,
      months,
      Math.max(80, config.profile.totalCholesterol * 0.6 - 15 * multiplier)
    );

    const inflammationReduction: number = 2 * multiplier;
    const projectedInflammation: number[] = TreatmentSimulator.generateProjectedValues(
      8, -inflammationReduction / months, months);

    return [
      TreatmentSimulator.buildGlucoseResult(config, projectedGlucose, glucoseReduction),
      TreatmentSimulator.buildLDLResult(config, projectedLDL, ldlReduction),
      TreatmentSimulator.buildInflammationResult(projectedInflammation)
    ];
  }

  private static buildGlucoseResult(config: SimulationConfig, projectedGlucose: number[],
    _glucoseReduction: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '空腹血糖(mmol/L)';
    result.currentValue = config.profile.fastingGlucose;
    result.projectedValues = projectedGlucose;
    result.unit = 'mmol/L';
    result.improvement = ((config.profile.fastingGlucose -
      projectedGlucose[projectedGlucose.length - 1]) / config.profile.fastingGlucose * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['地中海饮食富含健康脂肪', '稳定血糖水平'];
    return result;
  }

  private static buildLDLResult(config: SimulationConfig, projectedLDL: number[],
    _ldlReduction: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = 'LDL胆固醇(mmol/L)';
    result.currentValue = Math.round(config.profile.totalCholesterol * 0.6 * 10) / 10;
    result.projectedValues = projectedLDL;
    result.unit = 'mmol/L';
    result.improvement = ((config.profile.totalCholesterol * 0.6 -
      projectedLDL[projectedLDL.length - 1]) / (config.profile.totalCholesterol * 0.6) * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['单不饱和脂肪酸降低坏胆固醇', '保护心血管健康'];
    return result;
  }

  private static buildInflammationResult(projectedInflammation: number[]): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '地中海饮食';
    result.metricName = '炎症指标(CRP)';
    result.currentValue = 8;
    result.projectedValues = projectedInflammation;
    result.unit = 'mg/L';
    result.improvement = (8 - projectedInflammation[projectedInflammation.length - 1]) / 8 * 100;
    result.notes = ['抗炎食物降低全身炎症', '预防慢性疾病'];
    return result;
  }

  private static simulateLowSaltDiet(config: SimulationConfig): SimulationResult[] {
    const multiplier: number = TreatmentSimulator.getAdherenceMultiplier(config.adherenceLevel);
    const months: number = config.durationMonths;

    const systolicDrop: number = 1.5 * multiplier;
    const projectedSystolic: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.systolicBP,
      -systolicDrop,
      months,
      Math.max(120, config.profile.systolicBP - 18 * multiplier)
    );

    const diastolicDrop: number = 0.8 * multiplier;
    const projectedDiastolic: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.diastolicBP,
      -diastolicDrop,
      months,
      Math.max(75, config.profile.diastolicBP - 10 * multiplier)
    );

    return [
      TreatmentSimulator.buildSystolicResult(config, projectedSystolic, systolicDrop),
      TreatmentSimulator.buildDiastolicResult(config, projectedDiastolic, diastolicDrop)
    ];
  }

  private static buildSystolicResult(config: SimulationConfig, projectedSystolic: number[],
    _systolicDrop: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '收缩压(mmHg)';
    result.currentValue = config.profile.systolicBP;
    result.projectedValues = projectedSystolic;
    result.unit = 'mmHg';
    result.improvement = ((config.profile.systolicBP -
      projectedSystolic[projectedSystolic.length - 1]) / config.profile.systolicBP * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['低盐饮食直接降压', '对高血压患者效果显著'];
    return result;
  }

  private static buildDiastolicResult(config: SimulationConfig, projectedDiastolic: number[],
    _diastolicDrop: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '舒张压(mmHg)';
    result.currentValue = config.profile.diastolicBP;
    result.projectedValues = projectedDiastolic;
    result.unit = 'mmHg';
    result.improvement = ((config.profile.diastolicBP -
      projectedDiastolic[projectedDiastolic.length - 1]) / config.profile.diastolicBP * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['舒张压同步下降', '减轻心脏负担'];
    return result;
  }

  private static simulateWeightLoss(config: SimulationConfig): SimulationResult[] {
    const multiplier: number = TreatmentSimulator.getAdherenceMultiplier(config.adherenceLevel);
    const months: number = config.durationMonths;
    const currentBMI: number = DiseasePredictor.calculateBMI(config.profile);
    const targetWeight: number = config.profile.weight * 0.92;

    const monthlyLoss: number = (config.profile.weight - targetWeight) / months * multiplier;
    const projectedWeights: number[] = TreatmentSimulator.generateProjectedValues(
      config.profile.weight,
      -monthlyLoss,
      months,
      targetWeight
    );

    const projectedBMIs: number[] = projectedWeights.map(w =>
      Math.round((w / ((config.profile.height / 100) ** 2)) * 10) / 10
    );

    const riskReduction: number[] = projectedBMIs.map(bmi => {
      if (bmi < 24) return 85;
      if (bmi < 28) return 70;
      return 55;
    });

    return [
      TreatmentSimulator.buildWLWeightResult(config, projectedWeights, targetWeight, monthlyLoss, multiplier),
      TreatmentSimulator.buildWLBMIResult(config, projectedBMIs, currentBMI),
      TreatmentSimulator.buildWLRiskResult(riskReduction, multiplier)
    ];
  }

  private static buildWLWeightResult(config: SimulationConfig, projectedWeights: number[],
    targetWeight: number, _monthlyLoss: number, multiplier: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = '体重(kg)';
    result.currentValue = config.profile.weight;
    result.projectedValues = projectedWeights;
    result.unit = 'kg';
    result.improvement = ((config.profile.weight - targetWeight) / config.profile.weight * 100) * multiplier;
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['减重5-10%可显著改善健康', '建议每周减重0.5-1kg'];
    return result;
  }

  private static buildWLBMIResult(config: SimulationConfig, projectedBMIs: number[],
    currentBMI: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = config.selectedPlan.name;
    result.metricName = 'BMI指数';
    result.currentValue = currentBMI;
    result.projectedValues = projectedBMIs;
    result.unit = '';
    result.improvement = ((currentBMI - projectedBMIs[projectedBMIs.length - 1]) / currentBMI * 100);
    result.timeFrameMonths = config.durationMonths;
    result.notes = ['目标BMI范围: 18.5-23.9', '亚洲人标准更严格'];
    return result;
  }

  private static buildWLRiskResult(riskReduction: number[], multiplier: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '减重计划';
    result.metricName = '综合风险指数';
    result.currentValue = 60;
    result.projectedValues = riskReduction;
    result.unit = '%';
    result.improvement = 25 * multiplier;
    result.notes = ['减重降低多种慢性病风险', '包括糖尿病、高血压等'];
    return result;
  }

  private static simulateQuitSmoking(config: SimulationConfig): SimulationResult[] {
    const multiplier: number = TreatmentSimulator.getAdherenceMultiplier(config.adherenceLevel);
    const months: number = config.durationMonths;

    const lungFunctionRecovery: number[] = [0, 10, 20, 30, 40, 50, 55, 60, 65, 70, 73, 76];
    const projectedLung: number[] = lungFunctionRecovery.slice(0,
      Math.min(months + 1, lungFunctionRecovery.length)).map(v => v * multiplier);

    const cvdRiskReduction: number[] = [0, 15, 27, 37, 46, 53, 59, 64, 68, 71, 74, 77];
    const projectedCVD: number[] = cvdRiskReduction.slice(0,
      Math.min(months + 1, cvdRiskReduction.length)).map(v => v * multiplier);

    const cancerRiskReduction: number[] = [0, 5, 10, 14, 18, 21, 24, 27, 29, 31, 33, 35];
    const projectedCancer: number[] = cancerRiskReduction.slice(0,
      Math.min(months + 1, cancerRiskReduction.length)).map(v => v * multiplier);

    while (projectedLung.length <= months) {
      projectedLung.push(projectedLung[projectedLung.length - 1] + 1);
    }
    while (projectedCVD.length <= months) {
      projectedCVD.push(projectedCVD[projectedCVD.length - 1] + 1);
    }
    while (projectedCancer.length <= months) {
      projectedCancer.push(projectedCancer[projectedCancer.length - 1] + 0.5);
    }

    return [
      TreatmentSimulator.buildLungResult(projectedLung),
      TreatmentSimulator.buildCVDResult(projectedCVD),
      TreatmentSimulator.buildCancerResult(projectedCancer)
    ];
  }

  private static buildLungResult(projectedLung: number[]): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '戒烟计划';
    result.metricName = '肺功能恢复(%)';
    result.currentValue = 0;
    result.projectedValues = projectedLung;
    result.unit = '%';
    result.improvement = projectedLung[projectedLung.length - 1];
    result.notes = ['戒烟后肺功能逐步恢复', '1年恢复约70%'];
    return result;
  }

  private static buildCVDResult(projectedCVD: number[]): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '戒烟计划';
    result.metricName = '心血管风险下降(%)';
    result.currentValue = 0;
    result.projectedValues = projectedCVD;
    result.unit = '%';
    result.improvement = projectedCVD[projectedCVD.length - 1];
    result.notes = ['戒烟显著降低心脏病风险', '1年后风险减半'];
    return result;
  }

  private static buildCancerResult(projectedCancer: number[]): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '戒烟计划';
    result.metricName = '癌症风险下降(%)';
    result.currentValue = 0;
    result.projectedValues = projectedCancer;
    result.unit = '%';
    result.improvement = projectedCancer[projectedCancer.length - 1];
    result.notes = ['肺癌风险逐年下降', '10年后接近不吸烟者'];
    return result;
  }

  private static simulateSleepOptimization(config: SimulationConfig): SimulationResult[] {
    const multiplier: number = TreatmentSimulator.getAdherenceMultiplier(config.adherenceLevel);
    const months: number = config.durationMonths;

    const cognitiveImprovement: number[] =
      TreatmentSimulator.generateProjectedValues(65, 1.5 * multiplier, months, 90);
    const immuneImprovement: number[] =
      TreatmentSimulator.generateProjectedValues(70, 1.2 * multiplier, months, 88);
    const stressReduction: number[] =
      TreatmentSimulator.generateProjectedValues(75, -1.8 * multiplier, months, 40);

    return [
      TreatmentSimulator.buildCognitiveResult(cognitiveImprovement, multiplier),
      TreatmentSimulator.buildImmuneResult(immuneImprovement, multiplier),
      TreatmentSimulator.buildStressResult(stressReduction, multiplier)
    ];
  }

  private static buildCognitiveResult(cognitiveImprovement: number[], multiplier: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '睡眠优化';
    result.metricName = '认知功能评分';
    result.currentValue = 65;
    result.projectedValues = cognitiveImprovement;
    result.unit = '分';
    result.improvement = (cognitiveImprovement[cognitiveImprovement.length - 1] - 65) / 65 * 100;
    result.notes = ['充足睡眠提升记忆力和注意力', '大脑在睡眠中清理代谢废物'];
    return result;
  }

  private static buildImmuneResult(immuneImprovement: number[], multiplier: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '睡眠优化';
    result.metricName = '免疫功能指数';
    result.currentValue = 70;
    result.projectedValues = immuneImprovement;
    result.unit = '%';
    result.improvement = (immuneImprovement[immuneImprovement.length - 1] - 70) / 70 * 100;
    result.notes = ['睡眠时免疫系统释放细胞因子', '缺乏睡眠易感染疾病'];
    return result;
  }

  private static buildStressResult(stressReduction: number[], multiplier: number): SimulationResult {
    const result: SimulationResult = { planName: '', metricName: '', currentValue: 0, projectedValues: [],
      unit: '', improvement: 0, timeFrameMonths: 0, notes: [] };
    result.planName = '睡眠优化';
    result.metricName = '压力水平评分';
    result.currentValue = 75;
    result.projectedValues = stressReduction;
    result.unit = '分';
    result.improvement = (75 - stressReduction[stressReduction.length - 1]) / 75 * 100;
    result.notes = ['优质睡眠调节皮质醇水平', '降低焦虑和抑郁风险'];
    return result;
  }
}
