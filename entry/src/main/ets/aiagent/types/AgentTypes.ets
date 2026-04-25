/**
 * 智能体相关类型定义
 * 包含智能体配置、状态、专科类型等数据结构
 */

/**
 * 医疗专科枚举
 */
export enum MedicalSpecialty {
  INTERNAL_MEDICINE = 'internal_medicine',  // 内科
  SURGERY = 'surgery',                      // 外科
  TCM = 'tcm',                              // 中医
  NUTRITION = 'nutrition',                  // 营养
  REHAB = 'rehab'                           // 康复
}

/**
 * 智能体状态枚举
 */
export enum AgentStatus {
  IDLE = 'idle',           // 空闲
  BUSY = 'busy',           // 忙碌
  ERROR = 'error'          // 错误
}

/**
 * 智能体能力
 */
export interface AgentCapability {
  name: string;                 // 能力名称
  description: string;          // 能力描述
  keywords: string[];           // 关键词
  examples: string[];           // 示例问题
}

/**
 * 智能体配置
 */
export interface AgentConfig {
  agentId: string;              // 智能体ID
  agentName: string;            // 智能体名称
  specialty: MedicalSpecialty;  // 专科领域
  description: string;          // 描述
  capabilities: AgentCapability[];  // 能力列表
  icon?: string;                // 图标
  color?: string;               // 颜色
}

/**
 * 智能体状态信息
 */
export interface AgentStatusInfo {
  agentId: string;              // 智能体ID
  status: AgentStatus;          // 状态
  lastActiveTime: number;       // 最后活跃时间
  requestCount: number;         // 请求计数
  errorCount: number;           // 错误计数
  averageResponseTime?: number; // 平均响应时间
}

/**
 * 智能体处理结果
 */
export interface AgentProcessResult {
  success: boolean;             // 是否成功
  answer?: AgentAnswer;         // 回答
  error?: AgentError;           // 错误信息
  processingTime: number;       // 处理时间（毫秒）
}

/**
 * 智能体回答
 */
export interface AgentAnswer {
  agentId: string;              // 智能体ID
  agentName: string;            // 智能体名称
  content: string;              // 回答内容
  confidence: number;           // 置信度 [0-1]
  knowledgeUsed: KnowledgeReference[];  // 知识引用
  timestamp?: number;           // 回答时间戳
}

/**
 * 知识引用
 */
export interface KnowledgeReference {
  id: string;                   // 知识ID
  title: string;                // 知识标题
  source: string;               // 知识来源
  url?: string;                 // 来源链接
}

/**
 * 智能体错误
 */
export interface AgentError {
  code: string;                 // 错误码
  message: string;              // 错误消息
  details?: string;             // 错误详情
}

/**
 * 智能体池配置
 */
export interface AgentPoolConfig {
  maxAgents: number;            // 最大智能体数量
  idleTimeout: number;          // 空闲超时时间（秒）
  enablePreload: boolean;       // 是否预加载
}
