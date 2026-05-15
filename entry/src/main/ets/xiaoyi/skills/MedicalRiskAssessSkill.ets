/**
 * S3 - 健康风险评估技能 (待补充实现)
 * 
 * 属性 | 属性值
 * Skill ID | medical.riskassess
 * Skill 名称 | 健康风险评估
 * 功能描述 | 评估用户的慢病筛查、多维度风险计算、健康建议
 * 输出内容 | 风险评分、健康建议、风险数据计算文档文件
 * 所需权限 | ohos.permission.READ_HEALTH_DATA
 * 预计耗时 | ~1500ms
 * 触发动作 | 生成评估报告并展示
 */

import { HealthDataRecord } from '../models/HealthDataModel';
import { healthDataStore } from '../stores/HealthDataStore';

interface RiskFactor {
  name: string;
  value: number;
  unit: string;
  normalRange: { min: number; max: number };
  riskScore: number; // 0-100
  level: 'low' | 'medium' | 'high' | 'very_high';
}

interface RiskAssessmentResult {
  overallRiskScore: number;
  riskLevel: 'low' | 'medium' | 'high' | 'very_high';
  riskFactors: RiskFactor[];
  chronicDiseaseRisks: ChronicDiseaseRisk[];
  recommendations: string[];
  nextAssessmentDate: Date;
  reportGeneratedAt: Date;
}

interface ChronicDiseaseRisk {
  disease: string;
  probability: number; // 0-100%
  riskFactors: string[];
  preventionTips: string[];
}

export class MedicalRiskAssessSkill {
  private static readonly SKILL_ID = 'medical.riskassess';
  
  /**
   * 检查是否匹配该技能
   */
  static match(query: string): boolean {
    const triggers = [
      '风险评估', '健康评估', '体检评估',
      '我有...风险吗', '风险预测',
      '慢病筛查', '慢性病',
      '健康评分', '健康状况',
      '评估我的', '帮我评估',
      '高血压风险', '糖尿病风险', '心血管风险',
      '中医体质', '体质辨识'
    ];
    
    return triggers.some(trigger => query.includes(trigger));
  }

  /**
   * 执行健康风险评估
   */
  static async execute(query: string): Promise<RiskAssessmentResult> {
    // 步骤1：获取用户健康数据
    const healthData = await this.collectHealthData();
    
    // 步骤2：计算各项风险因子
    const riskFactors = this.calculateRiskFactors(healthData);
    
    // 步骤3：计算慢性病风险
    const chronicRisks = this.assessChronicDiseaseRisks(riskFactors, query);
    
    // 步骤4：计算综合风险评分
    const overallScore = this.calculateOverallRisk(riskFactors, chronicRisks);
    
    // 步骤5：生成个性化建议
    const recommendations = this.generateRecommendations(riskFactors, chronicRisks);
    
    return {
      overallRiskScore: overallScore.score,
      riskLevel: overallScore.level,
      riskFactors,
      chronicDiseaseRisks: chronicRisks,
      recommendations,
      nextAssessmentDate: this.calculateNextAssessmentDate(),
      reportGeneratedAt: new Date()
    };
  }

  /**
   * 收集用户健康数据
   */
  private static async collectHealthData(): Promise<Map<string, HealthDataRecord[]>> {
    const dataTypes = ['blood_pressure', 'blood_glucose', 'heart_rate', 'weight', 'blood_oxygen'];
    const dataMap = new Map<string, HealthDataRecord[]>();
    
    for (const type of dataTypes) {
      const records = await healthDataStore.getRecent(type, 30); // 最近30条记录
      dataMap.set(type, records);
    }
    
    return dataMap;
  }

  /**
   * 计算各项风险因子
   */
  private static calculateRiskFactors(healthData: Map<string, HealthDataRecord[]>): RiskFactor[] {
    const factors: RiskFactor[] = [];
    
    // 血压风险
    const bpRecords = healthData.get('blood_pressure') || [];
    if (bpRecords.length > 0) {
      const avgBP = bpRecords.reduce((sum, r) => sum + Number(r.value), 0) / bpRecords.length;
      factors.push(this.evaluateBloodPressure(avgBP));
    }
    
    // 血糖风险
    const bgRecords = healthData.get('blood_glucose') || [];
    if (bgRecords.length > 0) {
      const avgBG = bgRecords.reduce((sum, r) => sum + Number(r.value), 0) / bgRecords.length;
      factors.push(this.evaluateBloodGlucose(avgBG));
    }
    
    // 心率风险
    const hrRecords = healthData.get('heart_rate') || [];
    if (hrRecords.length > 0) {
      const avgHR = hrRecords.reduce((sum, r) => sum + Number(r.value), 0) / hrRecords.length;
      factors.push(this.evaluateHeartRate(avgHR));
    }
    
    // BMI风险（需要身高数据，这里简化处理）
    const weightRecords = healthData.get('weight') || [];
    if (weightRecords.length > 0) {
      const avgWeight = weightRecords.reduce((sum, r) => sum + Number(r.value), 0) / weightRecords.length;
      factors.push(this.evaluateBMI(avgWeight, 170)); // 假设身高170cm，实际应从用户资料获取
    }
    
    // 血氧风险
    const boRecords = healthData.get('blood_oxygen') || [];
    if (boRecords.length > 0) {
      const avgBO = boRecords.reduce((sum, r) => sum + Number(r.value), 0) / boRecords.length;
      factors.push(this.evaluateBloodOxygen(avgBO));
    }
    
    return factors;
  }

  /**
   * 评估血压风险
   */
  private static evaluateBloodPressure(value: number): RiskFactor {
    let score = 0;
    let level: 'low' | 'medium' | 'high' | 'very_high' = 'low';
    
    if (value >= 180) { score = 100; level = 'very_high'; }
    else if (value >= 140) { score = 75; level = 'high'; }
    else if (value >= 130) { score = 50; level = 'medium'; }
    else if (value < 90) { score = 40; level = 'medium'; }
    else { score = 10; level = 'low'; }
    
    return {
      name: '血压',
      value,
      unit: 'mmHg',
      normalRange: { min: 90, max: 140 },
      riskScore: score,
      level
    };
  }

  /**
   * 评估血糖风险
   */
  private static evaluateBloodGlucose(value: number): RiskFactor {
    let score = 0;
    let level: 'low' | 'medium' | 'high' | 'very_high' = 'low';
    
    if (value >= 16.7) { score = 100; level = 'very_high'; }
    else if (value >= 11.1) { score = 80; level = 'high'; }
    else if (value >= 7.0) { score = 55; level = 'medium'; }
    else if (value < 3.9) { score = 45; level = 'medium'; }
    else { score = 10; level = 'low'; }
    
    return {
      name: '血糖',
      value: parseFloat(value.toFixed(1)),
      unit: 'mmol/L',
      normalRange: { min: 3.9, max: 6.1 },
      riskScore: score,
      level
    };
  }

  /**
   * 评估心率风险
   */
  private static evaluateHeartRate(value: number): RiskFactor {
    let score = 0;
    let level: 'low' | 'medium' | 'high' | 'very_high' = 'low';
    
    if (value >= 150) { score = 90; level = 'very_high'; }
    else if (value >= 100) { score = 60; level = 'high'; }
    else if (value < 50) { score = 50; level = 'medium'; }
    else { score = 15; level = 'low'; }
    
    return {
      name: '心率',
      value: Math.round(value),
      unit: 'bpm',
      normalRange: { min: 60, max: 100 },
      riskScore: score,
      level
    };
  }

  /**
   * 评估BMI风险
   */
  private static evaluateBMI(weightKg: number, heightCm: number): RiskFactor {
    const heightM = heightCm / 100;
    const bmi = weightKg / (heightM * heightM);
    
    let score = 0;
    let level: 'low' | 'medium' | 'high' | 'very_high' = 'low';
    
    if (bmi >= 32) { score = 85; level = 'very_high'; }
    else if (bmi >= 28) { score = 65; level = 'high'; }
    else if (bmi >= 24 || bmi < 18.5) { score = 40; level = 'medium'; }
    else { score = 10; level = 'low'; }
    
    return {
      name: 'BMI',
      value: parseFloat(bmi.toFixed(1)),
      unit: 'kg/m²',
      normalRange: { min: 18.5, max: 24 },
      riskScore: score,
      level
    };
  }

  /**
   * 评估血氧风险
   */
  private static evaluateBloodOxygen(value: number): RiskFactor {
    let score = 0;
    let level: 'low' | 'medium' | 'high' | 'very_high' = 'low';
    
    if (value < 90) { score = 100; level = 'very_high'; }
    else if (value < 94) { score = 70; level = 'high'; }
    else if (value < 96) { score = 35; level = 'medium'; }
    else { score = 5; level = 'low'; }
    
    return {
      name: '血氧',
      value: Math.round(value),
      unit: '%',
      normalRange: { min: 95, max: 100 },
      riskScore: score,
      level
    };
  }

  /**
   * 评估慢性病风险
   */
  private static assessChronicDiseaseRisks(
    riskFactors: RiskFactor[], 
    query: string
  ): ChronicDiseaseRisk[] {
    const risks: ChronicDiseaseRisk[] = [];
    
    // 高血压风险
    const bpFactor = riskFactors.find(f => f.name === '血压');
    if (bpFactor && bpFactor.riskScore > 30) {
      risks.push({
        disease: '高血压',
        probability: Math.min(bpFactor.riskScore * 0.8, 95),
        riskFactors: [bpFactor.level === 'high' ? '血压持续偏高' : '血压波动较大'],
        preventionTips: [
          '低盐饮食（每日<6g）',
          '规律运动（每周150分钟有氧运动）',
          '控制体重',
          '戒烟限酒',
          '定期监测血压'
        ]
      });
    }
    
    // 糖尿病风险
    const bgFactor = riskFactors.find(f => f.name === '血糖');
    if (bgFactor && bgFactor.riskScore > 25) {
      risks.push({
        disease: '2型糖尿病',
        probability: Math.min(bgFactor.riskScore * 0.75, 90),
        riskFactors: [bgFactor.level === 'high' ? '血糖偏高' : '血糖调节能力下降'],
        preventionTips: [
          '控制碳水化合物摄入',
          '增加膳食纤维',
          '每周至少150分钟中等强度运动',
          '保持健康体重',
          '定期检测空腹血糖和糖化血红蛋白'
        ]
      });
    }
    
    // 心血管疾病风险（综合评估）
    const cvRiskFactors = riskFactors.filter(f => 
      ['血压', '血糖', '心率', 'BMI'].includes(f.name) && f.riskScore > 20
    );
    
    if (cvRiskFactors.length >= 2) {
      const avgScore = cvRiskFactors.reduce((sum, f) => sum + f.riskScore, 0) / cvRiskFactors.length;
      risks.push({
        disease: '心血管疾病',
        probability: Math.min(avgScore * 0.6, 85),
        riskFactors: cvRiskFactors.map(f => `${f.name}异常`),
        preventionTips: [
          '改善生活方式（饮食+运动）',
          '控制血脂水平',
          '管理压力，保证睡眠',
          '戒烟限酒',
          '定期做心电图和心脏超声检查'
        ]
      });
    }
    
    return risks;
  }

  /**
   * 计算综合风险评分
   */
  private static calculateOverallRisk(
    riskFactors: RiskFactor[], 
    chronicRisks: ChronicDiseaseRisk[]
  ): { score: number; level: 'low' | 'medium' | 'high' | 'very_high' } {
    if (riskFactors.length === 0) {
      return { score: 0, level: 'low' };
    }
    
    // 加权计算：风险因子占60%，慢性病风险占40%
    const factorScore = riskFactors.reduce((sum, f) => sum + f.riskScore, 0) / riskFactors.length;
    const chronicScore = chronicRisks.length > 0 
      ? chronicRisks.reduce((sum, r) => sum + r.probability, 0) / chronicRisks.length 
      : 0;
    
    const overallScore = factorScore * 0.6 + chronicScore * 0.4;
    
    let level: 'low' | 'medium' | 'high' | 'very_high';
    if (overallScore >= 70) level = 'very_high';
    else if (overallScore >= 50) level = 'high';
    else if (overallScore >= 30) level = 'medium';
    else level = 'low';
    
    return { score: Math.round(overallScore), level };
  }

  /**
   * 生成个性化建议
   */
  private static generateRecommendations(
    riskFactors: RiskFactor[], 
    chronicRisks: ChronicDiseaseRisk[]
  ): string[] {
    const recommendations: string[] = [];
    
    // 根据高风险因子给出建议
    const highRiskFactors = riskFactors.filter(f => f.level === 'high' || f.level === 'very_high');
    highRiskFactors.forEach(factor => {
      switch (factor.name) {
        case '血压':
          recommendations.push('🔴 优先控制血压：每日监测，低盐饮食，按时服药');
          break;
        case '血糖':
          recommendations.push('🔴 关注血糖管理：控制碳水摄入，规律运动，定期复查');
          break;
        case 'BMI':
          recommendations.push('🟠 控制体重：制定减重计划，合理膳食+运动');
          break;
        default:
          recommendations.push(`🟡 注意${factor.name}管理`);
      }
    });
    
    // 根据慢性病风险给出预防建议
    chronicRisks.forEach(risk => {
      if (risk.probability > 50) {
        recommendations.push(`⚠️ ${risk.disease}风险较高(${risk.probability}%)，建议：`);
        risk.preventionTips.slice(0, 2).forEach(tip => {
          recommendations.push(`  • ${tip}`);
        });
      }
    });
    
    // 通用建议
    if (recommendations.length === 0) {
      recommendations.push('✅ 目前各项指标良好，继续保持健康生活方式');
      recommendations.push('• 均衡饮食，少油少盐');
      recommendations.push('• 规律运动，每周至少150分钟');
      recommendations.push('• 保证充足睡眠（7-8小时）');
      recommendations.push('• 定期体检，每年至少1次');
    } else {
      recommendations.push('');
      recommendations.push('📅 建议3个月后重新评估');
      recommendations.push('🏥 如有疑虑，请咨询专业医生');
    }
    
    return recommendations;
  }

  /**
   * 计算下次评估时间
   */
  private static calculateNextAssessmentDate(): Date {
    const nextDate = new Date();
    nextDate.setMonth(nextDate.getMonth() + 3); // 3个月后
    return nextDate;
  }

  /**
   * 格式化输出评估报告
   */
  static formatReport(result: RiskAssessmentResult): string {
    const dateStr = result.reportGeneratedAt.toLocaleString('zh-CN');
    const nextDateStr = result.nextAssessmentDate.toLocaleDateString('zh-CN');
    
    let output = `📋 **健康风险评估报告**\n`;
    output += `📅 评估时间: ${dateStr}\n`;
    output += `🔄 下次评估: ${nextDateStr}\n\n`;
    
    // 总体风险
    output += `━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`;
    output += `📊 **综合风险评分**\n`;
    output += `┌─────────────────────────────┐\n`;
    const barLength = Math.round(result.overallRiskScore / 5);
    const bar = '█'.repeat(barLength) + '░'.repeat(20 - barLength);
    output += `│ ${bar} ${result.overallRiskScore}%     │\n`;
    output += `└─────────────────────────────┘\n`;
    output += `🎯 风险等级: ${this.getRiskLevelEmoji(result.riskLevel)} ${this.getRiskLevelText(result.riskLevel)}\n\n`;
    
    // 各项指标
    output += `📈 **各指标风险评估**\n\n`;
    result.riskFactors.forEach(factor => {
      const emoji = this.getRiskLevelEmoji(factor.level);
      output += `${emoji} **${factor.name}**: ${factor.value}${factor.unit} (${factor.riskScore}分)\n`;
      output += `   正常范围: ${factor.normalRange.min}-${factor.normalRange.max}${factor.unit}\n\n`;
    });
    
    // 慢性病风险
    if (result.chronicDiseaseRisks.length > 0) {
      output += `⚠️ **潜在疾病风险**\n\n`;
      result.chronicDiseaseRisks.forEach(risk => {
        output += `🔸 **${risk.disease}**: 风险概率 ${risk.probability}%\n`;
        output += `   风险因素: ${risk.riskFactors.join(', ')}\n`;
        output += `   预防要点:\n`;
        risk.preventionTips.slice(0, 3).forEach(tip => {
          output += `   • ${tip}\n`;
        });
        output += `\n`;
      });
    }
    
    // 建议
    output += `💡 **个性化建议**\n\n`;
    result.recommendations.forEach(rec => {
      output += `${rec}\n`;
    });
    
    // 免责声明
    output += `\n${'='.repeat(35)}\n`;
    output += `⚕️ 本评估基于您提供的健康数据，仅供参考。\n`;
    output += `不能替代专业医学诊断。如有疑问请咨询医生。\n`;
    
    return output;
  }

  private static getRiskLevelEmoji(level: string): string {
    const emojis = {
      low: '🟢',
      medium: '🟡',
      high: '🔴',
      very_high: '⚫'
    };
    return emojis[level] || '❓';
  }

  private static getRiskLevelText(level: string): string {
    const texts = {
      low: '低风险',
      medium: '中等风险',
      high: '高风险',
      very_high: '极高风险'
    };
    return texts[level] || '未知';
  }
}
