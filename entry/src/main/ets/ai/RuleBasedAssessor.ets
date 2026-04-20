import { HealthData } from './HealthFeatureExtractor';

export interface RiskLevel {
  value: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  probability: number;
  label: string;
  color: string;
}

export interface DiseaseRisk {
  disease: string;
  risk: RiskLevel;
  factors: string[];
  evidence: string;
}

export interface DiseaseRisksMap {
  hypertension: DiseaseRisk;
  diabetes: DiseaseRisk;
  fall: DiseaseRisk;
  frailty: DiseaseRisk;
  sarcopenia: DiseaseRisk;
}

export interface RuleBasedResult {
  risks: DiseaseRisksMap;
  probabilities: number[];
  overallScore: number;
  assessmentMethod: 'RULE_BASED';
  confidence: number;
}

export interface BpRange {
  systolic: number[];
  diastolic: number[];
}

export interface HypertensionGuideline {
  normal: BpRange;
  elevated: BpRange;
  stage1: BpRange;
  stage2: BpRange;
  crisis: BpRange;
}

export interface GlucoseRange {
  fasting: number[];
  hba1c: number[];
}

export interface DiabetesGuideline {
  normal: GlucoseRange;
  prediabetes: GlucoseRange;
  diabetes: GlucoseRange;
}

export interface FallRiskScale {
  low: number;
  medium_low: number;
  medium_high: number;
  high: number;
}

export class RuleBasedAssessor {

  private static readonly HYPERTENSION_GUIDELINE: HypertensionGuideline = {
    normal: { systolic: [90, 120], diastolic: [60, 80] },
    elevated: { systolic: [120, 129], diastolic: [80, 84] },
    stage1: { systolic: [130, 139], diastolic: [80, 89] },
    stage2: { systolic: [140, 179], diastolic: [90, 119] },
    crisis: { systolic: [180, 200], diastolic: [120, 200] }
  };

  private static readonly DIABETES_GUIDELINE: DiabetesGuideline = {
    normal: { fasting: [3.9, 6.0], hba1c: [0, 5.6] },
    prediabetes: { fasting: [6.1, 6.9], hba1c: [5.7, 6.4] },
    diabetes: { fasting: [7.0, 30.0], hba1c: [6.5, 20.0] }
  };

  private static readonly FALL_RISK_SCALE: FallRiskScale = {
    low: 0,
    medium_low: 0.3,
    medium_high: 0.6,
    high: 1.0
  };

  private constructor() {}

  static assessHypertension(healthData: HealthData): DiseaseRisk {
    const bp = healthData.bloodPressure;
    let baseRisk = 0.05;
    const factors: string[] = [];
    let evidence = '';

    if (bp.systolic >= 180 || bp.diastolic >= 120) {
      baseRisk = 0.95;
      evidence = '高血压危象：收缩压≥180或舒张压≥120mmHg';
      factors.push('血压危象水平');
    } else if (bp.systolic >= 140 || bp.diastolic >= 90) {
      baseRisk = 0.75;
      evidence = '高血压2级：收缩压140-179或舒张压90-119mmHg';
      factors.push('2级高血压');
    } else if (bp.systolic >= 130 || bp.diastolic >= 80) {
      baseRisk = 0.55;
      evidence = '高血压1级：收缩压130-139或舒张压80-89mmHg';
      factors.push('1级高血压');
    } else if (bp.systolic >= 120) {
      baseRisk = 0.35;
      evidence = '血压升高：收缩压120-129且舒张压<80mmHg';
      factors.push('血压升高');
    } else {
      evidence = '血压正常范围';
    }

    if (healthData.age >= 65) {
      baseRisk += 0.08;
      factors.push('年龄≥65岁（老年性高血压风险增加）');
    }
    if (healthData.age >= 75) {
      baseRisk += 0.07;
      factors.push('年龄≥75岁（高龄）');
    }

    if (healthData.bodyMetrics.weight !== undefined && healthData.bodyMetrics.height !== undefined) {
      const bmi = healthData.bodyMetrics.bmi ||
        (healthData.bodyMetrics.weight / ((healthData.bodyMetrics.height / 100) ** 2));

      if (bmi >= 28) {
        baseRisk += 0.06;
        factors.push(`BMI=${bmi.toFixed(1)}（超重/肥胖增加高血压风险）`);
      }
    }

    if (healthData.medicationCount !== undefined && healthData.medicationCount > 4) {
      baseRisk += 0.04;
      factors.push(`多重用药(${healthData.medicationCount}种药物)可能影响血压控制`);
    }

    baseRisk = Math.min(0.98, baseRisk);

    return {
      disease: 'hypertension',
      risk: RuleBasedAssessor.classifyRisk(baseRisk),
      factors: factors,
      evidence: evidence
    };
  }

  static assessDiabetes(healthData: HealthData): DiseaseRisk {
    const glucose = healthData.bloodGlucose;
    let baseRisk = 0.05;
    const factors: string[] = [];
    let evidence = '';

    if (glucose.fasting >= 7.0 || (glucose.hba1c !== undefined && glucose.hba1c >= 6.5)) {
      baseRisk = 0.85;
      evidence = `符合糖尿病诊断标准：空腹血糖${glucose.fasting}mmol/L` +
        (glucose.hba1c ? `，HbA1c ${glucose.hba1c}%` : '');
      factors.push('血糖达到糖尿病诊断阈值');
    } else if (glucose.fasting >= 6.1 || (glucose.hba1c !== undefined && glucose.hba1c >= 5.7)) {
      baseRisk = 0.50;
      evidence = `糖前期：空腹血糖${glucose.fasting}mmol/L` +
        (glucose.hba1c ? `，HbA1c ${glucose.hba1c}%` : '');
      factors.push('糖耐量受损/糖尿病前期');
    } else {
      evidence = '血糖在正常范围内';
    }

    if (healthData.age >= 45) {
      baseRisk += 0.06;
      factors.push('年龄≥45岁（糖尿病发病风险随年龄增长）');
    }

    if (healthData.bodyMetrics.weight !== undefined && healthData.bodyMetrics.height !== undefined) {
      const bmi = healthData.bodyMetrics.bmi ||
        (healthData.bodyMetrics.weight / ((healthData.bodyMetrics.height / 100) ** 2));

      if (bmi >= 25) {
        baseRisk += 0.10;
        factors.push(`BMI=${bmi.toFixed(1)}（肥胖是2型糖尿病主要危险因素）`);
      }
    }

    baseRisk = Math.min(0.98, baseRisk);

    return {
      disease: 'diabetes',
      risk: RuleBasedAssessor.classifyRisk(baseRisk),
      factors: factors,
      evidence: evidence
    };
  }

  static assessFallRisk(healthData: HealthData): DiseaseRisk {
    let baseRisk = 0.15;
    const factors: string[] = [];
    let evidence = '';

    if (healthData.functionalTests?.gaitSpeed !== undefined) {
      if (healthData.functionalTests.gaitSpeed < 0.8) {
        baseRisk += 0.30;
        factors.push(`步速慢(${healthData.functionalTests.gaitSpeed}m/s，正常≥1.0m/s)`);
      } else if (healthData.functionalTests.gaitSpeed < 1.0) {
        baseRisk += 0.15;
        factors.push(`步速偏慢(${healthData.functionalTests.gaitSpeed}m/s)`);
      }
    }

    if (healthData.functionalTests?.tandemStandTime !== undefined) {
      if (healthData.functionalTests.tandemStandTime < 10) {
        baseRisk += 0.20;
        factors.push('平衡能力差（闭目站立时间<10秒）');
      } else if (healthData.functionalTests.tandemStandTime < 20) {
        baseRisk += 0.10;
        factors.push('平衡能力一般');
      }
    }

    if (healthData.cognitiveScores?.mmse !== undefined && healthData.cognitiveScores.mmse < 24) {
      baseRisk += 0.15;
      factors.push(`认知功能下降(MMSE=${healthData.cognitiveScores.mmse})`);
    }

    if (healthData.medicationCount !== undefined && healthData.medicationCount > 4) {
      baseRisk += 0.12;
      factors.push(`多重用药(${healthData.medicationCount}种)，部分可能导致头晕/嗜睡`);
    }

    if (healthData.age >= 75) {
      baseRisk += 0.10;
      factors.push('高龄（跌倒高风险人群）');
    } else if (healthData.age >= 65) {
      baseRisk += 0.05;
      factors.push('老年人（需关注跌倒预防）');
    }

    if (baseRisk <= 0.30) {
      evidence = '跌倒风险较低';
    } else if (baseRisk <= 0.55) {
      evidence = '存在中等跌倒风险因素';
    } else {
      evidence = '跌倒风险较高，建议进行专业评估和干预';
    }

    baseRisk = Math.min(0.95, baseRisk);

    return {
      disease: 'fall',
      risk: RuleBasedAssessor.classifyRisk(baseRisk),
      factors: factors,
      evidence: evidence
    };
  }

  static assessFrailty(healthData: HealthData): DiseaseRisk {
    let frailtyCriteriaMet = 0;
    const totalCriteria = 5;
    const factors: string[] = [];
    let evidence = '';

    if (healthData.bodyMetrics?.weight !== undefined && healthData.bodyMetrics.height !== undefined) {
      const bmi = healthData.bodyMetrics.bmi ||
        (healthData.bodyMetrics.weight / ((healthData.bodyMetrics.height / 100) ** 2));

      if (bmi < 18.5) {
        frailtyCriteriaMet++;
        factors.push(`非意愿体重下降(BMI=${bmi.toFixed(1)}，低于18.5)`);
      }
    }

    if (healthData.functionalTests?.gripStrength !== undefined) {
      const isMale = healthData.gender === 'MALE';
      const threshold = isMale ? 28 : 18;

      if (healthData.functionalTests.gripStrength < threshold) {
        frailtyCriteriaMet++;
        factors.push(`握力下降(${healthData.functionalTests.gripStrength}kg，${isMale ? '男' : '女'}性阈值${threshold}kg)`);
      }
    }

    if (healthData.functionalTests?.gaitSpeed !== undefined) {
      if (healthData.functionalTests.gaitSpeed < 1.0) {
        frailtyCriteriaMet++;
        factors.push(`步行速度慢(${healthData.functionalTests.gaitSpeed}m/s < 1.0m/s)`);
      }
    }

    if (healthData.exerciseFrequency !== undefined && healthData.exerciseFrequency < 1) {
      frailtyCriteriaMet++;
      factors.push('体力活动不足（每周运动少于1次）');
    }

    if (healthData.cognitiveScores?.gds !== undefined && healthData.cognitiveScores.gds > 5) {
      frailtyCriteriaMet++;
      factors.push(`自我报告疲乏(GDS抑郁评分=${healthData.cognitiveScores.gds})`);
    }

    const frailtyRatio = frailtyCriteriaMet / totalCriteria;

    if (frailtyRatio === 0) {
      evidence = '健壮（未满足任何衰弱标准）';
    } else if (frailtyRatio <= 0.4) {
      evidence = `衰弱前期（${frailtyCriteriaMet}/${totalCriteria}项指标异常）`;
    } else {
      evidence = `衰弱（${frailtyCriteriaMet}/${totalCriteria}项指标异常，需医疗干预）`;
    }

    const baseRisk = 0.3 + frailtyRatio * 0.55;

    return {
      disease: 'frailty',
      risk: RuleBasedAssessor.classifyRisk(baseRisk),
      factors: factors,
      evidence: evidence
    };
  }

  static assessSarcopenia(healthData: HealthData): DiseaseRisk {
    let baseRisk = 0.15;
    const factors: string[] = [];
    let evidence = '';

    if (healthData.functionalTests?.gripStrength !== undefined) {
      const isMale = healthData.gender === 'MALE';
      const awgsThreshold = isMale ? 28 : 18;

      if (healthData.functionalTests.gripStrength < awgsThreshold) {
        baseRisk += 0.35;
        factors.push(`握力低于AWGS2019阈值(${healthData.functionalTests.gripStrength}kg < ${awgsThreshold}kg)`);
      }
    }

    if (healthData.bodyMetrics?.weight !== undefined && healthData.bodyMetrics?.height !== undefined) {
      const heightM = healthData.bodyMetrics.height / 100;
      const isMale = healthData.gender === 'MALE';
      const smi = healthData.bodyMetrics.weight / (heightM ** 2);
      const smiThreshold = isMale ? 7.0 : 5.4;

      if (smi < smiThreshold) {
        baseRisk += 0.30;
        factors.push(`骨骼肌指数(SMI=${smi.toFixed(2)})低于阈值(${smiThreshold}kg/m²)`);
      }
    }

    if (healthData.functionalTests?.gaitSpeed !== undefined) {
      if (healthData.functionalTests.gaitSpeed < 1.0) {
        baseRisk += 0.15;
        factors.push(`步速慢提示可能存在肌少症(${healthData.functionalTests.gaitSpeed}m/s)`);
      }
    }

    if (healthData.age >= 60) {
      baseRisk += 0.08;
      factors.push('年龄相关肌肉流失风险');
    }

    if (healthData.nutrition !== undefined && healthData.nutrition < 8) {
      baseRisk += 0.10;
      factors.push('营养不良风险（MNA-SF评分低）');
    }

    if (baseRisk <= 0.30) {
      evidence = '肌少症风险低';
    } else if (baseRisk <= 0.55) {
      evidence = '可能存在肌少症，建议进一步检查';
    } else {
      evidence = '肌少症风险较高，建议进行DXA检查确诊';
    }

    baseRisk = Math.min(0.92, baseRisk);

    return {
      disease: 'sarcopenia',
      risk: RuleBasedAssessor.classifyRisk(baseRisk),
      factors: factors,
      evidence: evidence
    };
  }

  private static classifyRisk(probability: number): RiskLevel {
    if (probability >= 0.8) {
      return {
        value: 'CRITICAL',
        probability: probability,
        label: '极高危',
        color: '#CF1322'
      };
    } else if (probability >= 0.6) {
      return {
        value: 'HIGH',
        probability: probability,
        label: '高危',
        color: '#FF4D4F'
      };
    } else if (probability >= 0.3) {
      return {
        value: 'MEDIUM',
        probability: probability,
        label: '中危',
        color: '#FAAD14'
      };
    } else {
      return {
        value: 'LOW',
        probability: probability,
        label: '低危',
        color: '#52C41A'
      };
    }
  }

  static assessAllRisks(healthData: HealthData): RuleBasedResult {
    console.log('[RuleBasedAssessor] 开始基于规则的全面风险评估...');

    const hypertensionRisk = RuleBasedAssessor.assessHypertension(healthData);
    const diabetesRisk = RuleBasedAssessor.assessDiabetes(healthData);
    const fallRisk = RuleBasedAssessor.assessFallRisk(healthData);
    const frailtyRisk = RuleBasedAssessor.assessFrailty(healthData);
    const sarcopeniaRisk = RuleBasedAssessor.assessSarcopenia(healthData);

    const probabilities: number[] = [
      hypertensionRisk.risk.probability,
      diabetesRisk.risk.probability,
      fallRisk.risk.probability,
      frailtyRisk.risk.probability,
      sarcopeniaRisk.risk.probability
    ];

    const overallScore = RuleBasedAssessor.calculateOverallScore(probabilities);

    console.log('[RuleBasedAssessor] 规则引擎评估完成:');
    console.log(`  高血压: ${(probabilities[0] * 100).toFixed(1)}% (${hypertensionRisk.risk.label})`);
    console.log(`  糖尿病: ${(probabilities[1] * 100).toFixed(1)}% (${diabetesRisk.risk.label})`);
    console.log(`  跌倒风险: ${(probabilities[2] * 100).toFixed(1)}% (${fallRisk.risk.label})`);
    console.log(`  衰弱: ${(probabilities[3] * 100).toFixed(1)}% (${frailtyRisk.risk.label})`);
    console.log(`  肌少症: ${(probabilities[4] * 100).toFixed(1)}% (${sarcopeniaRisk.risk.label})`);
    console.log(`  综合评分: ${(overallScore * 100).toFixed(1)}`);

    const risksMap: DiseaseRisksMap = {
      hypertension: hypertensionRisk,
      diabetes: diabetesRisk,
      fall: fallRisk,
      frailty: frailtyRisk,
      sarcopenia: sarcopeniaRisk
    };

    return {
      risks: risksMap,
      probabilities: probabilities,
      overallScore: overallScore,
      assessmentMethod: 'RULE_BASED',
      confidence: 0.78
    };
  }

  private static calculateOverallScore(probabilities: number[]): number {
    const weights: number[] = [0.25, 0.25, 0.15, 0.20, 0.15];

    let weightedSum = 0;
    for (let i = 0; i < probabilities.length; i++) {
      weightedSum += probabilities[i] * weights[i];
    }

    return weightedSum;
  }

  static generateDetailedReport(result: RuleBasedResult, healthData: HealthData): string {
    const diseases: string[] = ['hypertension', 'diabetes', 'fall', 'frailty', 'sarcopenia'];
    const chineseNames: string[] = ['高血压', '糖尿病', '跌倒风险', '衰弱综合征', '肌少症'];

    let report = '══════════════════════════════════════\n';
    report += '       共病风险评估报告（规则引擎版）\n';
    report += '══════════════════════════════════════\n\n';
    report += `评估时间: ${new Date().toLocaleString()}\n`;
    report += `评估方法: ${result.assessmentMethod}\n`;
    report += `置信度: ${(result.confidence * 100).toFixed(0)}%\n\n`;

    report += '【各维度风险评估】\n';

    const hypertensionRisk = result.risks.hypertension;
    report += `\n1. 高血压 - ${hypertensionRisk.risk.label} (${(hypertensionRisk.risk.probability * 100).toFixed(1)}%)\n`;
    report += `   判定依据: ${hypertensionRisk.evidence}\n`;
    if (hypertensionRisk.factors.length > 0) {
      report += `   风险因素:\n`;
      for (const factor of hypertensionRisk.factors) {
        report += `     • ${factor}\n`;
      }
    }

    const diabetesRisk = result.risks.diabetes;
    report += `\n2. 糖尿病 - ${diabetesRisk.risk.label} (${(diabetesRisk.risk.probability * 100).toFixed(1)}%)\n`;
    report += `   判定依据: ${diabetesRisk.evidence}\n`;
    if (diabetesRisk.factors.length > 0) {
      report += `   风险因素:\n`;
      for (const factor of diabetesRisk.factors) {
        report += `     • ${factor}\n`;
      }
    }

    const fallRisk = result.risks.fall;
    report += `\n3. 跌倒风险 - ${fallRisk.risk.label} (${(fallRisk.risk.probability * 100).toFixed(1)}%)\n`;
    report += `   判定依据: ${fallRisk.evidence}\n`;
    if (fallRisk.factors.length > 0) {
      report += `   风险因素:\n`;
      for (const factor of fallRisk.factors) {
        report += `     • ${factor}\n`;
      }
    }

    const frailtyRisk = result.risks.frailty;
    report += `\n4. 衰弱综合征 - ${frailtyRisk.risk.label} (${(frailtyRisk.risk.probability * 100).toFixed(1)}%)\n`;
    report += `   判定依据: ${frailtyRisk.evidence}\n`;
    if (frailtyRisk.factors.length > 0) {
      report += `   风险因素:\n`;
      for (const factor of frailtyRisk.factors) {
        report += `     • ${factor}\n`;
      }
    }

    const sarcopeniaRisk = result.risks.sarcopenia;
    report += `\n5. 肌少症 - ${sarcopeniaRisk.risk.label} (${(sarcopeniaRisk.risk.probability * 100).toFixed(1)}%)\n`;
    report += `   判定依据: ${sarcopeniaRisk.evidence}\n`;
    if (sarcopeniaRisk.factors.length > 0) {
      report += `   风险因素:\n`;
      for (const factor of sarcopeniaRisk.factors) {
        report += `     • ${factor}\n`;
      }
    }

    report += `\n【综合评分】\n`;
    report += `总体风险得分: ${(result.overallScore * 100).toFixed(1)}/100\n`;

    if (result.overallScore < 0.3) {
      report += `风险等级: 低风险\n`;
    } else if (result.overallScore < 0.6) {
      report += `风险等级: 中等风险\n`;
    } else {
      report += `风险等级: 高风险 ⚠️\n`;
    }

    report += '\n══════════════════════════════════════\n';
    report += '⚠️ 本报告由AI辅助生成，仅供参考\n';
    report += '   请以专业医生诊断为准\n';
    report += '══════════════════════════════════════\n';

    return report;
  }
}
