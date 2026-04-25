/**
 * 错误相关类型定义
 * 包含错误码、错误响应等数据结构
 */

/**
 * 错误码枚举
 */
export enum ErrorCode {
  // 通用错误 (1000-1999)
  INVALID_REQUEST = 1000,
  UNAUTHORIZED = 1001,
  FORBIDDEN = 1002,
  NOT_FOUND = 1003,
  INTERNAL_ERROR = 1004,
  TIMEOUT = 1005,
  RATE_LIMIT_EXCEEDED = 1006,

  // 业务错误 (2000-2999)
  INTENT_CLASSIFICATION_FAILED = 2000,
  AGENT_UNAVAILABLE = 2001,
  LLM_ERROR = 2002,
  RAG_RETRIEVAL_FAILED = 2003,
  MEMORY_ERROR = 2004,
  REPORT_GENERATION_FAILED = 2005,
  SESSION_NOT_FOUND = 2006,
  SESSION_EXPIRED = 2007,
  INVALID_QUESTION = 2008,
  NO_AVAILABLE_AGENT = 2009,

  // 外部服务错误 (3000-3999)
  VECTOR_DB_ERROR = 3000,
  KNOWLEDGE_BASE_ERROR = 3001,
  LLM_SERVICE_ERROR = 3002,
  EMBEDDING_SERVICE_ERROR = 3003,
  STORAGE_SERVICE_ERROR = 3004
}

/**
 * 错误严重程度
 */
export enum ErrorSeverity {
  LOW = 'low',           // 低严重程度，可忽略
  MEDIUM = 'medium',     // 中等严重程度，需要记录
  HIGH = 'high',         // 高严重程度，需要告警
  CRITICAL = 'critical'  // 严重错误，需要立即处理
}

/**
 * 错误详情
 */
export interface ErrorDetail {
  field?: string;               // 错误字段
  value?: string;               // 错误值
  constraint?: string;          // 约束条件
  suggestion?: string;          // 修复建议
}

/**
 * 错误响应
 */
export interface ErrorResponse {
  code: ErrorCode;              // 错误码
  message: string;              // 错误消息
  details: string;              // 错误详情
  timestamp: number;            // 时间戳
  traceId?: string;             // 追踪ID
  severity?: ErrorSeverity;     // 严重程度
  errorDetails?: ErrorDetail[]; // 错误详情列表
}

/**
 * API响应包装
 */
export interface ApiResponse<T> {
  code: number;                 // 状态码，0表示成功
  message: string;              // 响应消息
  data?: T;                     // 响应数据
  timestamp: number;            // 时间戳
  traceId?: string;             // 追踪ID
}

/**
 * 错误处理配置
 */
export interface ErrorHandlingConfig {
  enableRetry: boolean;         // 是否启用重试
  maxRetries: number;           // 最大重试次数
  retryDelay: number;           // 重试延迟（毫秒）
  enableFallback: boolean;      // 是否启用降级
  logErrors: boolean;           // 是否记录错误
  alertOnCritical: boolean;     // 严重错误是否告警
}

/**
 * 错误统计
 */
export interface ErrorStatistics {
  totalErrors: number;          // 总错误数
  errorsByCode: Map<ErrorCode, number>;  // 按错误码统计
  errorsBySeverity: Map<ErrorSeverity, number>;  // 按严重程度统计
  lastErrorTime: number;        // 最后错误时间
  errorRate: number;            // 错误率
}
