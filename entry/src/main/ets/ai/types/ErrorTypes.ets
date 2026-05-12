export enum ErrorCode {
  MODEL_NOT_FOUND = 'E001',
  MODEL_LOAD_FAILED = 'E002',
  MODEL_SIGNATURE_INVALID = 'E003',
  NPU_UNAVAILABLE = 'E004',
  NPU_RESOURCE_CONFLICT = 'E005',
  NPU_DEADLOCK = 'E006',
  MEMORY_INSUFFICIENT = 'E007',
  INFERENCE_TIMEOUT = 'E008',
  INFERENCE_FAILED = 'E009',
  INPUT_INVALID = 'E010',
  OUTPUT_INVALID = 'E011',
  HIAI_UNAVAILABLE = 'E012',
  IMAGE_FORMAT_UNSUPPORTED = 'E013',
  CACHE_MISS = 'E014',
  QUEUE_OVERFLOW = 'E015',
  ENGINE_UNAVAILABLE = 'E016',
  UNKNOWN = 'E999'
}

export enum ErrorLevel {
  INFO = 'info',
  WARNING = 'warning',
  ERROR = 'error',
  CRITICAL = 'critical'
}

export enum RecoveryStrategy {
  RETRY = 'retry',
  FALLBACK_CPU = 'fallback_cpu',
  FALLBACK_ENGINE = 'fallback_engine',
  CLEAR_CACHE = 'clear_cache',
  RESTART_ENGINE = 'restart_engine',
  NOTIFY_USER = 'notify_user',
  NONE = 'none'
}

export interface AIError {
  code: ErrorCode;
  level: ErrorLevel;
  message: string;
  details?: string;
  context?: ErrorContext;
  recoveryStrategy: RecoveryStrategy;
  timestamp: number;
}

export interface ErrorContext {
  engine?: string;
  model?: string;
  requestId?: string;
  operation?: string;
  input?: Record<string, string | number | boolean>;
}

export const ERROR_MESSAGES: Map<ErrorCode, string> = new Map();

export const ERROR_RECOVERY: Map<ErrorCode, RecoveryStrategy> = new Map();

function initErrorMaps(): void {
  ERROR_MESSAGES.set(ErrorCode.MODEL_NOT_FOUND, '模型文件不存在');
  ERROR_MESSAGES.set(ErrorCode.MODEL_LOAD_FAILED, '模型加载失败');
  ERROR_MESSAGES.set(ErrorCode.MODEL_SIGNATURE_INVALID, '模型签名校验失败，拒绝加载未授权模型');
  ERROR_MESSAGES.set(ErrorCode.NPU_UNAVAILABLE, 'NPU不可用，将降级至CPU');
  ERROR_MESSAGES.set(ErrorCode.NPU_RESOURCE_CONFLICT, 'NPU资源竞争，等待或降级');
  ERROR_MESSAGES.set(ErrorCode.NPU_DEADLOCK, 'NPU死锁，强制释放资源');
  ERROR_MESSAGES.set(ErrorCode.MEMORY_INSUFFICIENT, '内存不足，按LRU策略卸载模型');
  ERROR_MESSAGES.set(ErrorCode.INFERENCE_TIMEOUT, '推理超时，终止推理');
  ERROR_MESSAGES.set(ErrorCode.INFERENCE_FAILED, '推理执行失败');
  ERROR_MESSAGES.set(ErrorCode.INPUT_INVALID, '输入数据无效');
  ERROR_MESSAGES.set(ErrorCode.OUTPUT_INVALID, '输出数据无效');
  ERROR_MESSAGES.set(ErrorCode.HIAI_UNAVAILABLE, 'HiAI服务不可用');
  ERROR_MESSAGES.set(ErrorCode.IMAGE_FORMAT_UNSUPPORTED, '图像格式不支持');
  ERROR_MESSAGES.set(ErrorCode.CACHE_MISS, '缓存未命中');
  ERROR_MESSAGES.set(ErrorCode.QUEUE_OVERFLOW, '推理队列溢出');
  ERROR_MESSAGES.set(ErrorCode.ENGINE_UNAVAILABLE, '所有推理引擎不可用');
  ERROR_MESSAGES.set(ErrorCode.UNKNOWN, '未知错误');

  ERROR_RECOVERY.set(ErrorCode.MODEL_NOT_FOUND, RecoveryStrategy.NOTIFY_USER);
  ERROR_RECOVERY.set(ErrorCode.MODEL_LOAD_FAILED, RecoveryStrategy.RETRY);
  ERROR_RECOVERY.set(ErrorCode.MODEL_SIGNATURE_INVALID, RecoveryStrategy.NONE);
  ERROR_RECOVERY.set(ErrorCode.NPU_UNAVAILABLE, RecoveryStrategy.FALLBACK_CPU);
  ERROR_RECOVERY.set(ErrorCode.NPU_RESOURCE_CONFLICT, RecoveryStrategy.FALLBACK_CPU);
  ERROR_RECOVERY.set(ErrorCode.NPU_DEADLOCK, RecoveryStrategy.RESTART_ENGINE);
  ERROR_RECOVERY.set(ErrorCode.MEMORY_INSUFFICIENT, RecoveryStrategy.CLEAR_CACHE);
  ERROR_RECOVERY.set(ErrorCode.INFERENCE_TIMEOUT, RecoveryStrategy.RETRY);
  ERROR_RECOVERY.set(ErrorCode.INFERENCE_FAILED, RecoveryStrategy.FALLBACK_ENGINE);
  ERROR_RECOVERY.set(ErrorCode.INPUT_INVALID, RecoveryStrategy.NONE);
  ERROR_RECOVERY.set(ErrorCode.OUTPUT_INVALID, RecoveryStrategy.NONE);
  ERROR_RECOVERY.set(ErrorCode.HIAI_UNAVAILABLE, RecoveryStrategy.FALLBACK_ENGINE);
  ERROR_RECOVERY.set(ErrorCode.IMAGE_FORMAT_UNSUPPORTED, RecoveryStrategy.NOTIFY_USER);
  ERROR_RECOVERY.set(ErrorCode.CACHE_MISS, RecoveryStrategy.NONE);
  ERROR_RECOVERY.set(ErrorCode.QUEUE_OVERFLOW, RecoveryStrategy.NONE);
  ERROR_RECOVERY.set(ErrorCode.ENGINE_UNAVAILABLE, RecoveryStrategy.RESTART_ENGINE);
  ERROR_RECOVERY.set(ErrorCode.UNKNOWN, RecoveryStrategy.NONE);
}

initErrorMaps();

export function createAIError(code: ErrorCode, details?: string, context?: ErrorContext): AIError {
  return {
    code,
    level: getErrorLevel(code),
    message: ERROR_MESSAGES.get(code) || '未知错误',
    details,
    context,
    recoveryStrategy: ERROR_RECOVERY.get(code) || RecoveryStrategy.NONE,
    timestamp: Date.now()
  };
}

function getErrorLevel(code: ErrorCode): ErrorLevel {
  if (code === ErrorCode.NPU_DEADLOCK || code === ErrorCode.ENGINE_UNAVAILABLE) {
    return ErrorLevel.CRITICAL;
  }
  if (code === ErrorCode.MODEL_LOAD_FAILED || code === ErrorCode.INFERENCE_FAILED) {
    return ErrorLevel.ERROR;
  }
  if (code === ErrorCode.NPU_UNAVAILABLE || code === ErrorCode.CACHE_MISS) {
    return ErrorLevel.WARNING;
  }
  return ErrorLevel.INFO;
}
