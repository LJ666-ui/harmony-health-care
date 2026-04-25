export interface BMICategoryResult {
  label: string;
  color: string;
}

export interface UserProfile {
  age: number;
  gender: 'male' | 'female';
  height: number;
  weight: number;
  systolicBP: number;
  diastolicBP: number;
  totalCholesterol: number;
  hdlCholesterol: number;
  fastingGlucose: number;
  isSmoker: boolean;
  hasDiabetes: boolean;
  isHypertensive: boolean;
  familyHistoryCVD: boolean;
  physicalActivity: 'low' | 'moderate' | 'high';
}

export interface DiseaseRisk {
  diseaseName: string;
  category: string;
  currentRisk: number;
  riskLevel: 'low' | 'moderate' | 'high' | 'very_high';
  riskFactors: string[];
  recommendations: string[];
  predictionCurve: RiskPoint[];
}

export interface RiskPoint {
  year: number;
  risk: number;
}

export class DiseasePredictor {

  static calculateBMI(profile: UserProfile): number {
    const heightInMeters: number = profile.height / 100;
    return Math.round((profile.weight / (heightInMeters * heightInMeters)) * 10) / 10;
  }

  static getBMICategory(bmi: number): BMICategoryResult {
    const result: BMICategoryResult = { label: '', color: '' };
    if (bmi < 18.5) {
      result.label = '偏瘦';
      result.color = '#1677FF';
    } else if (bmi < 24) {
      result.label = '正常';
      result.color = '#52C41A';
    } else if (bmi < 28) {
      result.label = '超重';
      result.color = '#FAAD14';
    } else {
      result.label = '肥胖';
      result.color = '#FF4D4F';
    }
    return result;
  }

  static predictCardiovascularDisease(profile: UserProfile, years: number = 10): DiseaseRisk {
    let score: number = 0;

    const agePoints: number[] = [0, 0, 0, 1, 2, 3, 4, 6, 8];
    const ageIndex: number = Math.min(Math.floor((profile.age - 30) / 5), 8);
    score += (ageIndex >= 0 ? agePoints[ageIndex] : 0);

    if (profile.gender === 'male') {
      score += 2;
    }

    if (profile.systolicBP >= 140 || profile.diastolicBP >= 90) {
      score += 3;
    } else if (profile.systolicBP >= 130 || profile.diastolicBP >= 85) {
      score += 1;
    }

    if (profile.totalCholesterol >= 240) {
      score += 3;
    } else if (profile.totalCholesterol >= 200) {
      score += 1;
    }

    if (profile.hdlCholesterol < 40) {
      score += 2;
    } else if (profile.hdlCholesterol > 60) {
      score -= 1;
    }

    if (profile.isSmoker) {
      score += 3;
    }

    if (profile.hasDiabetes) {
      score += 3;
    }

    if (profile.familyHistoryCVD) {
      score += 2;
    }

    const bmi: number = DiseasePredictor.calculateBMI(profile);
    if (bmi >= 28) {
      score += 2;
    } else if (bmi >= 24) {
      score += 1;
    }

    if (profile.physicalActivity === 'low') {
      score += 2;
    } else if (profile.physicalActivity === 'high') {
      score -= 1;
    }

    const baseRisk: number = Math.min(score * 2.5, 95);
    const currentRisk: number = Math.round(baseRisk);

    const riskLevel: 'low' | 'moderate' | 'high' | 'very_high' = DiseasePredictor.getRiskLevelTyped(currentRisk);

    const factors: string[] = [];
    if (profile.age > 50) factors.push('年龄>50岁');
    if (profile.systolicBP >= 140) factors.push('高血压');
    if (profile.totalCholesterol > 200) factors.push('高胆固醇');
    if (profile.isSmoker) factors.push('吸烟');
    if (profile.hasDiabetes) factors.push('糖尿病');
    if (bmi >= 24) factors.push(`超重/肥胖(BMI:${bmi})`);
    if (profile.familyHistoryCVD) factors.push('家族病史');
    if (profile.physicalActivity === 'low') factors.push('缺乏运动');

    const recommendations: string[] = [
      '定期监测血压、血脂',
      '保持健康饮食，减少盐和脂肪摄入',
      '每周进行150分钟中等强度运动',
      '戒烟限酒',
      '控制体重在正常范围'
    ];

    const result: DiseaseRisk = {
      diseaseName: '心血管疾病',
      category: 'cardiovascular',
      currentRisk: currentRisk,
      riskLevel: riskLevel,
      riskFactors: factors,
      recommendations: recommendations,
      predictionCurve: DiseasePredictor.generatePredictionCurve(currentRisk, years)
    };
    return result;
  }

  static predictDiabetesRisk(profile: UserProfile, years: number = 10): DiseaseRisk {
    let score: number = 0;

    if (profile.age >= 45) {
      score += 2;
    }
    if (profile.age >= 55) {
      score += 1;
    }

    if (profile.familyHistoryCVD) {
      score += 2;
    }

    const bmi: number = DiseasePredictor.calculateBMI(profile);
    if (bmi >= 28) {
      score += 3;
    } else if (bmi >= 25) {
      score += 2;
    } else if (bmi >= 23) {
      score += 1;
    }

    if (profile.fastingGlucose >= 7.0) {
      score += 4;
    } else if (profile.fastingGlucose >= 6.1) {
      score += 2;
    } else if (profile.fastingGlucose >= 5.6) {
      score += 1;
    }

    if (profile.systolicBP >= 140) {
      score += 1;
    }

    if (profile.physicalActivity === 'low') {
      score += 2;
    }

    const baseRisk: number = Math.min(score * 3, 90);
    const currentRisk: number = Math.round(baseRisk);
    const riskLevel: 'low' | 'moderate' | 'high' | 'very_high' = DiseasePredictor.getRiskLevelTyped(currentRisk);

    const factors: string[] = [];
    if (profile.age >= 45) factors.push('年龄≥45岁');
    if (profile.familyHistoryCVD) factors.push('家族糖尿病史');
    if (bmi >= 23) factors.push(`超重(BMI:${bmi})`);
    if (profile.fastingGlucose >= 5.6) factors.push('血糖偏高');
    if (profile.systolicBP >= 140) factors.push('高血压');
    if (profile.physicalActivity === 'low') factors.push('缺乏运动');

    const recommendations: string[] = [
      '控制饮食，减少精制糖摄入',
      '每周至少150分钟有氧运动',
      '保持健康体重',
      '定期检测空腹血糖',
      '增加膳食纤维摄入'
    ];

    const result: DiseaseRisk = {
      diseaseName: '2型糖尿病',
      category: 'endocrine',
      currentRisk: currentRisk,
      riskLevel: riskLevel,
      riskFactors: factors,
      recommendations: recommendations,
      predictionCurve: DiseasePredictor.generatePredictionCurve(currentRisk, years)
    };
    return result;
  }

  static predictOsteoporosisRisk(profile: UserProfile, years: number = 10): DiseaseRisk {
    let score: number = 0;

    if (profile.gender === 'female' && profile.age >= 50) {
      score += 3;
    } else if (profile.gender === 'female' && profile.age >= 40) {
      score += 1;
    }

    if (profile.gender === 'male' && profile.age >= 65) {
      score += 2;
    }

    const bmi: number = DiseasePredictor.calculateBMI(profile);
    if (bmi < 20) {
      score += 3;
    } else if (bmi < 22) {
      score += 1;
    }

    if (profile.physicalActivity === 'low') {
      score += 2;
    } else if (profile.physicalActivity === 'high') {
      score -= 1;
    }

    if (profile.isSmoker) {
      score += 2;
    }

    if (profile.weight < 57 && profile.gender === 'female') {
      score += 1;
    }

    const baseRisk: number = Math.min(score * 4 + 5, 80);
    const currentRisk: number = Math.round(baseRisk);
    const riskLevel: 'low' | 'moderate' | 'high' | 'very_high' = DiseasePredictor.getRiskLevelTyped(currentRisk);

    const factors: string[] = [];
    if (profile.gender === 'female' && profile.age >= 45) factors.push('女性+年龄');
    if (bmi < 22) factors.push(`低体重(BMI:${bmi})`);
    if (profile.physicalActivity === 'low') factors.push('缺乏运动');
    if (profile.isSmoker) factors.push('吸烟');

    const recommendations: string[] = [
      '补充钙质和维生素D',
      '进行负重运动增强骨密度',
      '避免过量饮酒和咖啡因',
      '定期进行骨密度检查',
      '预防跌倒'
    ];

    const result: DiseaseRisk = {
      diseaseName: '骨质疏松',
      category: 'skeletal',
      currentRisk: currentRisk,
      riskLevel: riskLevel,
      riskFactors: factors,
      recommendations: recommendations,
      predictionCurve: DiseasePredictor.generatePredictionCurve(currentRisk, years)
    };
    return result;
  }

  static predictStrokeRisk(profile: UserProfile, years: number = 10): DiseaseRisk {
    let score: number = 0;

    if (profile.age >= 55) {
      score += 2;
    }
    if (profile.age >= 65) {
      score += 1;
    }

    if (profile.systolicBP >= 160) {
      score += 4;
    } else if (profile.systolicBP >= 140) {
      score += 2;
    }

    if (profile.hasDiabetes) {
      score += 2;
    }

    if (profile.isSmoker) {
      score += 2;
    }

    if (profile.totalCholesterol > 240) {
      score += 1;
    }

    if (profile.familyHistoryCVD) {
      score += 1;
    }

    if (profile.physicalActivity === 'low') {
      score += 1;
    }

    const baseRisk: number = Math.min(score * 2.2, 75);
    const currentRisk: number = Math.round(baseRisk);
    const riskLevel: 'low' | 'moderate' | 'high' | 'very_high' = DiseasePredictor.getRiskLevelTyped(currentRisk);

    const factors: string[] = [];
    if (profile.age >= 55) factors.push('年龄≥55岁');
    if (profile.systolicBP >= 140) factors.push('高血压');
    if (profile.hasDiabetes) factors.push('糖尿病');
    if (profile.isSmoker) factors.push('吸烟');
    if (profile.totalCholesterol > 240) factors.push('高血脂');

    const recommendations: string[] = [
      '严格控制血压',
      '管理血糖水平',
      '戒烟',
      '低盐低脂饮食',
      '规律体检筛查颈动脉斑块'
    ];

    const result: DiseaseRisk = {
      diseaseName: '脑卒中(中风)',
      category: 'neurological',
      currentRisk: currentRisk,
      riskLevel: riskLevel,
      riskFactors: factors,
      recommendations: recommendations,
      predictionCurve: DiseasePredictor.generatePredictionCurve(currentRisk, years)
    };
    return result;
  }

  static getAllPredictions(profile: UserProfile, years: number = 5): DiseaseRisk[] {
    return [
      DiseasePredictor.predictCardiovascularDisease(profile, years),
      DiseasePredictor.predictDiabetesRisk(profile, years),
      DiseasePredictor.predictOsteoporosisRisk(profile, years),
      DiseasePredictor.predictStrokeRisk(profile, years)
    ];
  }

  private static generatePredictionCurve(baseRisk: number, years: number): RiskPoint[] {
    const points: RiskPoint[] = [];
    for (let year = 0; year <= years; year++) {
      const growthRate: number = 1 + (year * 0.08);
      const risk: number = Math.min(Math.round(baseRisk * growthRate), 98);
      const point: RiskPoint = { year: new Date().getFullYear() + year, risk: risk };
      points.push(point);
    }
    return points;
  }

  private static getRiskLevelTyped(risk: number): 'low' | 'moderate' | 'high' | 'very_high' {
    if (risk < 20) {
      return 'low';
    } else if (risk < 40) {
      return 'moderate';
    } else if (risk < 60) {
      return 'high';
    } else {
      return 'very_high';
    }
  }

  static getRiskLevelText(level: string): string {
    switch (level) {
      case 'low':
        return '低风险';
      case 'moderate':
        return '中等风险';
      case 'high':
        return '高风险';
      case 'very_high':
        return '极高风险';
      default:
        return '未知';
    }
  }

  static getRiskLevelColor(level: string): string {
    switch (level) {
      case 'low':
        return '#52C41A';
      case 'moderate':
        return '#FAAD14';
      case 'high':
        return '#FF7A45';
      case 'very_high':
        return '#FF4D4F';
      default:
        return '#999999';
    }
  }
}
