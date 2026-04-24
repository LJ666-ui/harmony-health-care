/**
 * 问诊相关类型定义
 * 包含问诊请求、会诊响应、智能体回答等核心数据结构
 */

/**
 * 患者信息
 */
export interface PatientInfo {
  age?: number;                    // 年龄
  gender?: 'male' | 'female';      // 性别
  medicalHistory?: string[];       // 病史
  allergies?: string[];            // 过敏史
}

/**
 * 用户偏好设置
 */
export interface UserPreferences {
  language?: string;               // 语言偏好
  detailLevel?: 'brief' | 'normal' | 'detailed';  // 详细程度
}

/**
 * 请求上下文
 */
export interface RequestContext {
  patientInfo?: PatientInfo;       // 患者信息
  preferences?: UserPreferences;   // 用户偏好
}

/**
 * 问诊请求
 */
export interface ConsultationRequest {
  sessionId?: string;              // 会话ID，可选
  question: string;                // 用户问题，必填
  userId: string;                  // 用户ID，必填
  context?: RequestContext;        // 请求上下文，可选
  timestamp?: number;              // 请求时间戳
}

/**
 * 知识引用
 */
export interface KnowledgeReference {
  id: string;                      // 知识ID
  title: string;                   // 知识标题
  source: string;                  // 知识来源
  url?: string;                    // 来源链接
}

/**
 * 智能体回答
 */
export interface AgentAnswer {
  agentId: string;                 // 智能体ID
  agentName: string;               // 智能体名称
  content: string;                 // 回答内容
  confidence: number;              // 置信度 [0-1]
  knowledgeUsed: KnowledgeReference[];  // 知识引用
  timestamp?: number;              // 回答时间戳
}

/**
 * 会诊响应
 */
export interface ConsultationResponse {
  responseId: string;              // 响应ID
  sessionId: string;               // 会话ID
  answers: AgentAnswer[];          // 智能体回答列表
  summary?: string;                // 会诊总结
  knowledgeRefs?: KnowledgeReference[];  // 知识引用列表
  timestamp: number;               // 时间戳
}

/**
 * 汇总结果
 */
export interface AggregatedResult {
  summary: string;                 // 汇总摘要
  keyPoints: string[];             // 关键要点
  recommendations: string[];       // 建议
  warnings: string[];              // 注意事项
}
