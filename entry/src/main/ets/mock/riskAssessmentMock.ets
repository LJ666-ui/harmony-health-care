import { BaseResponse } from '../common/utils/HttpUtil';
import { registerMockHandler } from './index';
import { RiskAssessmentResult, RiskItem, RiskLevel, RadarDataItem, RiskRisksMap } from '../models/AIModels';

class RiskRisksClass {
  hypertension: number = 0;
  diabetes: number = 0;
  fall: number = 0;
  frailty: number = 0;
  sarcopenia: number = 0;

  constructor(htn?: number, dia?: number, fall?: number, frl?: number, sarc?: number) {
    if (htn !== undefined) {
      this.hypertension = htn;
    }
    if (dia !== undefined) {
      this.diabetes = dia;
    }
    if (fall !== undefined) {
      this.fall = fall;
    }
    if (frl !== undefined) {
      this.frailty = frl;
    }
    if (sarc !== undefined) {
      this.sarcopenia = sarc;
    }
  }
}

class RiskHistoryRecord {
  id: string = '';
  date: string = '';
  overallScore: number = 0;
  overallLevel: RiskLevel = RiskLevel.LOW;
  risks: RiskRisksClass = new RiskRisksClass();
  suggestions: string[] = [];

  constructor(id?: string, date?: string, overallScore?: number, overallLevel?: RiskLevel,
              risks?: RiskRisksClass, suggestions?: string[]) {
    if (id !== undefined) {
      this.id = id;
    }
    if (date !== undefined) {
      this.date = date;
    }
    if (overallScore !== undefined) {
      this.overallScore = overallScore;
    }
    if (overallLevel !== undefined) {
      this.overallLevel = overallLevel;
    }
    if (risks !== undefined) {
      this.risks = risks;
    }
    if (suggestions !== undefined) {
      this.suggestions = suggestions;
    }
  }
}

class SuggestionTemplateMap {
  hypertension: string[] = [];
  diabetes: string[] = [];
  fall: string[] = [];
  frailty: string[] = [];
  sarcopenia: string[] = [];

  constructor(htn?: string[], dia?: string[], fall?: string[], frl?: string[], sarc?: string[]) {
    if (htn !== undefined) {
      this.hypertension = htn;
    }
    if (dia !== undefined) {
      this.diabetes = dia;
    }
    if (fall !== undefined) {
      this.fall = fall;
    }
    if (frl !== undefined) {
      this.frailty = frl;
    }
    if (sarc !== undefined) {
      this.sarcopenia = sarc;
    }
  }
}

function createRiskItem(key: string, label: string, value: number, level: RiskLevel, color: string, description: string): RiskItem {
  return new RiskItem(key, label, value, level, color, description);
}

function createLowRiskResult(): RiskAssessmentResult {
  const result: RiskAssessmentResult = new RiskAssessmentResult();
  result.assessmentId = 'mock-low-001';
  result.timestamp = '2026-04-20T08:00:00.000Z';
  result.risks = new RiskRisksMap(
    createRiskItem('hypertension', '高血压', 0.15, RiskLevel.LOW, '#52C41A', '血压 118/76mmHg'),
    createRiskItem('diabetes', '糖尿病', 0.12, RiskLevel.LOW, '#52C41A', '空腹血糖 4.8mmol/L'),
    createRiskItem('fall', '跌倒', 0.08, RiskLevel.LOW, '#52C41A', '跌倒风险较低'),
    createRiskItem('frailty', '衰弱', 0.18, RiskLevel.LOW, '#52C41A', 'BMI 22.5'),
    createRiskItem('sarcopenia', '肌少症', 0.10, RiskLevel.LOW, '#52C41A', '肌肉量正常')
  );
  result.overallScore = 0.13;
  result.overallLevel = RiskLevel.LOW;
  result.suggestions = [
    '保持良好的作息习惯，保证每晚7-8小时充足睡眠',
    '继续保持规律运动，每周至少150分钟中等强度运动',
    '定期体检，关注健康指标变化'
  ];
  result.modelVersion = 'rule-based-v1';
  result.processingTimeMs = 45;
  return result;
}

function createMediumRiskResult(): RiskAssessmentResult {
  const result: RiskAssessmentResult = new RiskAssessmentResult();
  result.assessmentId = 'mock-mid-001';
  result.timestamp = '2026-04-20T08:00:00.000Z';
  result.risks = new RiskRisksMap(
    createRiskItem('hypertension', '高血压', 0.55, RiskLevel.MEDIUM, '#FAAD14', '血压 135/88mmHg'),
    createRiskItem('diabetes', '糖尿病', 0.42, RiskLevel.MEDIUM, '#FAAD14', '空腹血糖 6.3mmol/L'),
    createRiskItem('fall', '跌倒', 0.25, RiskLevel.LOW, '#52C41A', '年龄 62岁，需注意'),
    createRiskItem('frailty', '衰弱', 0.38, RiskLevel.MEDIUM, '#FAAD14', 'BMI 26.8'),
    createRiskItem('sarcopenia', '肌少症', 0.20, RiskLevel.LOW, '#52C41A', '肌肉量基本正常')
  );
  result.overallScore = 0.39;
  result.overallLevel = RiskLevel.MEDIUM;
  result.suggestions = [
    '注意低盐饮食，每日盐摄入不超过6g',
    '控制甜食和精制碳水摄入',
    '保证每日蛋白质摄入达到1.0g/kg',
    '增加全谷物和蔬菜比例',
    '适当增加平衡训练，如太极拳',
    '保持良好的作息习惯，保证每晚7-8小时充足睡眠'
  ];
  result.modelVersion = 'rule-based-v1';
  result.processingTimeMs = 52;
  return result;
}

function createHighRiskResult(): RiskAssessmentResult {
  const result: RiskAssessmentResult = new RiskAssessmentResult();
  result.assessmentId = 'mock-high-001';
  result.timestamp = '2026-04-20T08:00:00.000Z';
  result.risks = new RiskRisksMap(
    createRiskItem('hypertension', '高血压', 0.82, RiskLevel.HIGH, '#FF4D4F', '血压 165/100mmHg'),
    createRiskItem('diabetes', '糖尿病', 0.75, RiskLevel.HIGH, '#FF4D4F', '空腹血糖 8.5mmol/L'),
    createRiskItem('fall', '跌倒', 0.68, RiskLevel.HIGH, '#FF4D4F', '年龄 78岁，存在跌倒风险'),
    createRiskItem('frailty', '衰弱', 0.72, RiskLevel.HIGH, '#FF4D4F', 'BMI 17.2'),
    createRiskItem('sarcopenia', '肌少症', 0.78, RiskLevel.HIGH, '#FF4D4F', '年龄 78岁，需关注肌肉量')
  );
  result.overallScore = 0.76;
  result.overallLevel = RiskLevel.HIGH;
  result.suggestions = [
    '控制盐摄入，每日不超过5g',
    '严格控制碳水化合物摄入，选择低GI食物',
    '居家环境改造：安装扶手、防滑垫、夜灯',
    '制定个性化营养方案，保证蛋白质摄入1.0-1.2g/kg/天',
    '增加蛋白质摄入至1.2-1.5g/kg/天',
    '定期监测血压，建议每天早晚各一次',
    '每日监测空腹及餐后血糖',
    '进行平衡训练：太极拳、站立练习',
    '保持良好的作息习惯，保证每晚7-8小时充足睡眠'
  ];
  result.modelVersion = 'rule-based-v1';
  result.processingTimeMs = 68;
  return result;
}

function createBoundaryRiskResult(): RiskAssessmentResult {
  const result: RiskAssessmentResult = new RiskAssessmentResult();
  result.assessmentId = 'mock-boundary-001';
  result.timestamp = '2026-04-20T08:00:00.000Z';
  result.risks = new RiskRisksMap(
    createRiskItem('hypertension', '高血压', 0.30, RiskLevel.MEDIUM, '#FAAD14', '血压 121/81mmHg'),
    createRiskItem('diabetes', '糖尿病', 0.29, RiskLevel.LOW, '#52C41A', '空腹血糖 5.5mmol/L'),
    createRiskItem('fall', '跌倒', 0.60, RiskLevel.HIGH, '#FF4D4F', '年龄 80岁，存在跌倒风险'),
    createRiskItem('frailty', '衰弱', 0.59, RiskLevel.MEDIUM, '#FAAD14', 'BMI 27.5'),
    createRiskItem('sarcopenia', '肌少症', 0.80, RiskLevel.CRITICAL, '#CF1322', '年龄 80岁，需关注肌肉量')
  );
  result.overallScore = 0.48;
  result.overallLevel = RiskLevel.MEDIUM;
  result.suggestions = [
    '注意低盐饮食，每日盐摄入不超过6g',
    '居家环境改造：安装扶手、防滑垫、夜灯',
    '保证每日蛋白质摄入达到1.0g/kg',
    '增加蛋白质摄入至1.2-1.5g/kg/天',
    '保持良好的作息习惯，保证每晚7-8小时充足睡眠'
  ];
  result.modelVersion = 'rule-based-v1';
  result.processingTimeMs = 55;
  return result;
}

function createExtremeRiskResult(): RiskAssessmentResult {
  const result: RiskAssessmentResult = new RiskAssessmentResult();
  result.assessmentId = 'mock-extreme-001';
  result.timestamp = '2026-04-20T08:00:00.000Z';
  result.risks = new RiskRisksMap(
    createRiskItem('hypertension', '高血压', 0.95, RiskLevel.CRITICAL, '#CF1322', '血压 190/115mmHg'),
    createRiskItem('diabetes', '糖尿病', 0.92, RiskLevel.CRITICAL, '#CF1322', '空腹血糖 15.0mmol/L'),
    createRiskItem('fall', '跌倒', 0.88, RiskLevel.CRITICAL, '#CF1322', '年龄 85岁，存在跌倒风险'),
    createRiskItem('frailty', '衰弱', 0.90, RiskLevel.CRITICAL, '#CF1322', 'BMI 15.0'),
    createRiskItem('sarcopenia', '肌少症', 0.93, RiskLevel.CRITICAL, '#CF1322', '年龄 85岁，需关注肌肉量')
  );
  result.overallScore = 0.92;
  result.overallLevel = RiskLevel.CRITICAL;
  result.suggestions = [
    '控制盐摄入，每日不超过5g',
    '严格控制碳水化合物摄入，选择低GI食物',
    '居家环境改造：安装扶手、防滑垫、夜灯',
    '制定个性化营养方案，保证蛋白质摄入1.0-1.2g/kg/天',
    '增加蛋白质摄入至1.2-1.5g/kg/天',
    '定期监测血压，建议每天早晚各一次',
    '每日监测空腹及餐后血糖',
    '进行平衡训练：太极拳、站立练习',
    '进行系统性抗阻训练，重点锻炼大肌群',
    '保持良好的作息习惯，保证每晚7-8小时充足睡眠'
  ];
  result.modelVersion = 'rule-based-v1';
  result.processingTimeMs = 72;
  return result;
}

export const LOW_RISK_RESULT: RiskAssessmentResult = createLowRiskResult();

export const MEDIUM_RISK_RESULT: RiskAssessmentResult = createMediumRiskResult();

export const HIGH_RISK_RESULT: RiskAssessmentResult = createHighRiskResult();

export const BOUNDARY_RISK_RESULT: RiskAssessmentResult = createBoundaryRiskResult();

export const EXTREME_RISK_RESULT: RiskAssessmentResult = createExtremeRiskResult();

function createHistoryRecord(id: string, date: string, overallScore: number, overallLevel: RiskLevel,
                              htn: number, dia: number, fall: number, frl: number, sarc: number,
                              suggestions: string[]): RiskHistoryRecord {
  return new RiskHistoryRecord(id, date, overallScore, overallLevel,
    new RiskRisksClass(htn, dia, fall, frl, sarc), suggestions);
}

export const MOCK_HISTORY: RiskHistoryRecord[] = [
  createHistoryRecord('hist-001', '2026-04-20', 0.76, RiskLevel.HIGH, 0.82, 0.75, 0.68, 0.72, 0.78,
    ['控制盐摄入', '严格控制碳水', '居家环境改造']),
  createHistoryRecord('hist-002', '2026-03-15', 0.62, RiskLevel.HIGH, 0.70, 0.65, 0.55, 0.60, 0.58,
    ['控制盐摄入', '注意饮食控制', '增加运动']),
  createHistoryRecord('hist-003', '2026-02-10', 0.45, RiskLevel.MEDIUM, 0.50, 0.48, 0.35, 0.42, 0.40,
    ['注意低盐饮食', '控制碳水摄入', '适当运动']),
  createHistoryRecord('hist-004', '2026-01-05', 0.38, RiskLevel.MEDIUM, 0.42, 0.40, 0.30, 0.35, 0.32,
    ['注意饮食', '增加运动', '定期监测']),
  createHistoryRecord('hist-005', '2025-11-20', 0.25, RiskLevel.LOW, 0.28, 0.22, 0.18, 0.25, 0.20,
    ['保持良好习惯', '定期体检'])
];

function createSuggestionTemplates(): SuggestionTemplateMap {
  return new SuggestionTemplateMap(
    [
      '控制盐摄入，每日不超过5g',
      '定期监测血压，建议每天早晚各一次',
      '减少高脂肪食物摄入，增加蔬菜水果',
      '遵医嘱服用降压药物，不可自行停药',
      '每周至少150分钟中等强度有氧运动',
      '限制饮酒，男性每日酒精量不超过25g',
      '保持情绪稳定，避免过度紧张和焦虑',
      '3个月后复查血压，评估治疗效果',
      '注意低盐饮食，每日盐摄入不超过6g',
      '保持健康体重，BMI控制在18.5-24之间'
    ],
    [
      '严格控制碳水化合物摄入，选择低GI食物',
      '每日监测空腹及餐后血糖',
      '遵医嘱使用降糖药物或胰岛素',
      '增加膳食纤维摄入，每日25-30g',
      '规律运动有助于提高胰岛素敏感性',
      '定期检查糖化血红蛋白(HbA1c)',
      '注意足部护理，预防糖尿病足',
      '3个月后复查血糖及相关指标',
      '控制甜食和精制碳水摄入',
      '增加全谷物和蔬菜比例'
    ],
    [
      '居家环境改造：安装扶手、防滑垫、夜灯',
      '进行平衡训练：太极拳、站立练习',
      '定期检查视力，佩戴合适的眼镜',
      '穿防滑鞋，避免穿拖鞋外出',
      '起床时先坐1-2分钟再站立',
      '评估药物副作用，避免使用影响平衡的药物',
      '使用辅助行走工具（拐杖/助行器）',
      '适当增加平衡训练，如太极拳',
      '定期进行骨密度检查',
      '保证充足的维生素D和钙摄入'
    ],
    [
      '制定个性化营养方案，保证蛋白质摄入1.0-1.2g/kg/天',
      '进行渐进式抗阻训练，每周2-3次',
      '补充维生素D，每日800-1000IU',
      '保证充足睡眠，每晚7-8小时',
      '定期评估躯体功能，监测衰弱进展',
      '参与社交活动，预防抑郁和认知下降',
      '增加蛋白质摄入，保证每餐有优质蛋白',
      '适度进行力量训练，如弹力带练习',
      '保持规律作息，避免久坐不动',
      '定期进行衰弱评估'
    ],
    [
      '增加蛋白质摄入至1.2-1.5g/kg/天',
      '进行系统性抗阻训练，重点锻炼大肌群',
      '补充亮氨酸和HMB，促进肌肉合成',
      '保证维生素D充足，每日800-1000IU',
      '避免长时间卧床，保持日常活动量',
      '定期评估肌肉量和肌力',
      '必要时咨询营养师制定饮食方案',
      '保证每日蛋白质摄入达到1.0g/kg',
      '每周进行2-3次力量训练',
      '注意补充钙和维生素D'
    ]
  );
}

export const SUGGESTION_TEMPLATES: SuggestionTemplateMap = createSuggestionTemplates();

export function getRadarDataFromResult(result: RiskAssessmentResult): RadarDataItem[] {
  return [
    new RadarDataItem('高血压', result.risks.hypertension.value, result.risks.hypertension.color),
    new RadarDataItem('糖尿病', result.risks.diabetes.value, result.risks.diabetes.color),
    new RadarDataItem('跌倒', result.risks.fall.value, result.risks.fall.color),
    new RadarDataItem('衰弱', result.risks.frailty.value, result.risks.frailty.color),
    new RadarDataItem('肌少症', result.risks.sarcopenia.value, result.risks.sarcopenia.color)
  ];
}
