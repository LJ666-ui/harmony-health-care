/**
 * AI智能体类型定义导出索引
 * 统一导出所有类型定义
 */

// 问诊相关类型
export {
  PatientInfo,
  UserPreferences,
  RequestContext,
  ConsultationRequest,
  KnowledgeReference,
  AgentAnswer,
  ConsultationResponse,
  AggregatedResult
} from './ConsultationTypes';

// 对话记忆相关类型
export {
  MessageMetadata,
  ConversationMessage,
  ConversationContext,
  ConversationMemoryConfig,
  ConversationSummary
} from './ConversationTypes';

// 意图分类相关类型
export {
  IntentType,
  EntityType,
  EntityPosition,
  MedicalEntity,
  Intent,
  IntentClassificationResult,
  IntentAgentMapping
} from './IntentTypes';

// RAG检索相关类型
export {
  KnowledgeMetadata,
  KnowledgeDocument,
  SearchResultMetadata,
  SearchResult,
  KnowledgeContext,
  RAGConfig,
  EmbeddingRequest,
  EmbeddingResponse
} from './RAGTypes';

// 报告相关类型
export {
  ReportType,
  ExportFormat,
  ReportSection,
  MedicalReport,
  ReportMetadata,
  ExportFile,
  ReportGenerateRequest,
  ReportTemplate
} from './ReportTypes';

// 智能体相关类型
export {
  MedicalSpecialty,
  AgentStatus,
  AgentCapability,
  AgentConfig,
  AgentStatusInfo,
  AgentProcessResult,
  AgentError,
  AgentPoolConfig
} from './AgentTypes';

// 错误相关类型
export {
  ErrorCode,
  ErrorSeverity,
  ErrorDetail,
  ErrorResponse,
  ApiResponse,
  ErrorHandlingConfig,
  ErrorStatistics
} from './ErrorTypes';
