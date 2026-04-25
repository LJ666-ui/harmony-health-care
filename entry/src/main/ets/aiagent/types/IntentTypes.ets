/**
 * 意图分类相关类型定义
 * 包含意图类型、医疗实体等数据结构
 */

/**
 * 意图类型枚举
 */
export enum IntentType {
  SYMPTOM_CONSULTATION = 'symptom_consultation',      // 症状咨询
  MEDICATION_GUIDANCE = 'medication_guidance',        // 用药指导
  REHABILITATION_ADVICE = 'rehabilitation_advice',    // 康复建议
  NUTRITION_CONSULTATION = 'nutrition_consultation',  // 营养咨询
  TCM_CONSULTATION = 'tcm_consultation',              // 中医咨询
  SURGERY_CONSULTATION = 'surgery_consultation',      // 外科咨询
  GENERAL_INQUIRY = 'general_inquiry'                 // 一般咨询
}

/**
 * 实体类型枚举
 */
export enum EntityType {
  SYMPTOM = 'symptom',         // 症状
  DISEASE = 'disease',         // 疾病
  MEDICINE = 'medicine',       // 药物
  BODY_PART = 'body_part',     // 身体部位
  TIME = 'time',               // 时间
  DURATION = 'duration'        // 持续时间
}

/**
 * 实体位置信息
 */
export interface EntityPosition {
  start: number;               // 起始位置
  end: number;                 // 结束位置
}

/**
 * 医疗实体
 */
export interface MedicalEntity {
  type: EntityType;            // 实体类型
  value: string;               // 实体值
  position: EntityPosition;    // 位置信息
  confidence?: number;         // 置信度
}

/**
 * 意图
 */
export interface Intent {
  type: IntentType;            // 意图类型
  confidence: number;          // 置信度 [0-1]
  entities: MedicalEntity[];   // 医疗实体
  relatedIntents?: IntentType[];  // 相关意图
}

/**
 * 意图分类结果
 */
export interface IntentClassificationResult {
  primaryIntent: Intent;       // 主要意图
  secondaryIntents?: Intent[]; // 次要意图
  allEntities: MedicalEntity[]; // 所有实体
}

/**
 * 意图到智能体的映射
 */
export interface IntentAgentMapping {
  intent: IntentType;          // 意图类型
  agentIds: string[];          // 对应的智能体ID列表
  priority: number;            // 优先级
}
