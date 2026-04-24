/**
 * 意图分类器
 * 识别用户问题的医疗意图类型
 */

import { LLMClient } from './infrastructure/LLMClient';
import {
  Intent,
  IntentType,
  MedicalEntity,
  EntityType,
  IntentClassificationResult
} from './types/IntentTypes';

/**
 * 意图分类器类
 */
export class IntentClassifier {
  private llmClient: LLMClient;

  /**
   * 构造函数
   * @param llmClient LLM客户端
   */
  constructor(llmClient: LLMClient) {
    this.llmClient = llmClient;
  }

  /**
   * 分类用户意图
   * @param question 用户问题
   * @returns 意图类型
   */
  async classify(question: string): Promise<Intent> {
    // 基于关键词的简单意图识别
    const intent = this.classifyByKeywords(question);

    return intent;
  }

  /**
   * 提取医疗实体
   * @param question 用户问题
   * @returns 医疗实体列表
   */
  async extractEntities(question: string): Promise<MedicalEntity[]> {
    const entities: MedicalEntity[] = [];

    // 症状实体
    const symptoms = ['头痛', '发烧', '咳嗽', '腹痛', '恶心', '乏力', '失眠'];
    for (const symptom of symptoms) {
      const index = question.indexOf(symptom);
      if (index !== -1) {
        entities.push({
          type: EntityType.SYMPTOM,
          value: symptom,
          position: { start: index, end: index + symptom.length },
          confidence: 0.9
        });
      }
    }

    // 疾病实体
    const diseases = ['感冒', '高血压', '糖尿病', '冠心病', '胃炎'];
    for (const disease of diseases) {
      const index = question.indexOf(disease);
      if (index !== -1) {
        entities.push({
          type: EntityType.DISEASE,
          value: disease,
          position: { start: index, end: index + disease.length },
          confidence: 0.9
        });
      }
    }

    // 药物实体
    const medicines = ['阿司匹林', '布洛芬', '感冒药', '降压药'];
    for (const medicine of medicines) {
      const index = question.indexOf(medicine);
      if (index !== -1) {
        entities.push({
          type: EntityType.MEDICINE,
          value: medicine,
          position: { start: index, end: index + medicine.length },
          confidence: 0.9
        });
      }
    }

    // 身体部位实体
    const bodyParts = ['头', '胃', '心', '肺', '肝', '肾', '腿', '手'];
    for (const part of bodyParts) {
      const index = question.indexOf(part);
      if (index !== -1) {
        entities.push({
          type: EntityType.BODY_PART,
          value: part,
          position: { start: index, end: index + part.length },
          confidence: 0.8
        });
      }
    }

    return entities;
  }

  /**
   * 完整的意图分类（包含实体提取）
   * @param question 用户问题
   * @returns 意图分类结果
   */
  async classifyWithEntities(question: string): Promise<IntentClassificationResult> {
    const primaryIntent = await this.classify(question);
    const allEntities = await this.extractEntities(question);

    return {
      primaryIntent,
      allEntities
    };
  }

  /**
   * 基于关键词的意图分类
   * @param question 用户问题
   * @returns 意图
   */
  private classifyByKeywords(question: string): Intent {
    const questionLower = question.toLowerCase();

    // 症状咨询关键词
    const symptomKeywords = ['症状', '头痛', '发烧', '咳嗽', '腹痛', '恶心', '乏力', '不舒服', '疼痛'];
    if (symptomKeywords.some(kw => questionLower.includes(kw))) {
      return {
        type: IntentType.SYMPTOM_CONSULTATION,
        confidence: 0.85,
        entities: []
      };
    }

    // 用药指导关键词
    const medicationKeywords = ['用药', '药物', '吃药', '剂量', '副作用', '阿司匹林', '布洛芬'];
    if (medicationKeywords.some(kw => questionLower.includes(kw))) {
      return {
        type: IntentType.MEDICATION_GUIDANCE,
        confidence: 0.85,
        entities: []
      };
    }

    // 康复建议关键词
    const rehabKeywords = ['康复', '运动', '锻炼', '恢复', '训练', '理疗'];
    if (rehabKeywords.some(kw => questionLower.includes(kw))) {
      return {
        type: IntentType.REHABILITATION_ADVICE,
        confidence: 0.85,
        entities: []
      };
    }

    // 营养咨询关键词
    const nutritionKeywords = ['饮食', '营养', '吃', '食物', '蔬菜', '水果', '减肥'];
    if (nutritionKeywords.some(kw => questionLower.includes(kw))) {
      return {
        type: IntentType.NUTRITION_CONSULTATION,
        confidence: 0.85,
        entities: []
      };
    }

    // 中医咨询关键词
    const tcmKeywords = ['中医', '中药', '针灸', '体质', '调理', '养生'];
    if (tcmKeywords.some(kw => questionLower.includes(kw))) {
      return {
        type: IntentType.TCM_CONSULTATION,
        confidence: 0.85,
        entities: []
      };
    }

    // 外科咨询关键词
    const surgeryKeywords = ['手术', '外伤', '伤口', '骨折', '缝合', '切除'];
    if (surgeryKeywords.some(kw => questionLower.includes(kw))) {
      return {
        type: IntentType.SURGERY_CONSULTATION,
        confidence: 0.85,
        entities: []
      };
    }

    // 默认为一般咨询
    return {
      type: IntentType.GENERAL_INQUIRY,
      confidence: 0.6,
      entities: []
    };
  }

  /**
   * 获取意图对应的智能体ID列表
   * @param intent 意图类型
   * @returns 智能体ID列表
   */
  getAgentIdsForIntent(intent: IntentType): string[] {
    const mapping: Record<IntentType, string[]> = {
      [IntentType.SYMPTOM_CONSULTATION]: ['internal_medicine'],
      [IntentType.MEDICATION_GUIDANCE]: ['internal_medicine', 'tcm'],
      [IntentType.REHABILITATION_ADVICE]: ['rehab', 'nutrition'],
      [IntentType.NUTRITION_CONSULTATION]: ['nutrition'],
      [IntentType.TCM_CONSULTATION]: ['tcm'],
      [IntentType.SURGERY_CONSULTATION]: ['surgery', 'rehab'],
      [IntentType.GENERAL_INQUIRY]: ['internal_medicine']
    };

    return mapping[intent] || ['internal_medicine'];
  }
}
