import { ErrorCode, ErrorLevel, RecoveryStrategy, AIError, ErrorContext, createAIError } from './types/ErrorTypes';
import { EngineType } from './types/EngineTypes';
import { ModelType } from './types/ModelTypes';
import { MindSporeLiteAdapter } from './MindSporeLiteAdapter';
import { HiAIAdapter } from './HiAIAdapter';
import { ResultCache } from './ResultCache';
import { ResourceScheduler } from './ResourceScheduler';

export class ErrorHandler {
  private static instance: ErrorHandler;

  private errorLog: AIError[] = [];
  private readonly MAX_LOG_SIZE: number = 100;

  private constructor() {}

  static getInstance(): ErrorHandler {
    if (!ErrorHandler.instance) {
      ErrorHandler.instance = new ErrorHandler();
    }
    return ErrorHandler.instance;
  }

  handleError(error: Error | AIError, context?: ErrorContext): AIError {
    let aiError: AIError;

    if (this.isAIError(error)) {
      aiError = error as AIError;
    } else {
      aiError = this.convertToAIError(error, context);
    }

    this.logError(aiError);

    this.executeRecovery(aiError);

    return aiError;
  }

  handleModelError(error: Error, modelType: ModelType): AIError {
    const context: ErrorContext = {
      model: modelType,
      operation: 'model_load'
    };

    if (error.message.includes('not found') || error.message.includes('不存在')) {
      return this.handleError(createAIError(ErrorCode.MODEL_NOT_FOUND, error.message, context), context);
    }

    if (error.message.includes('signature') || error.message.includes('签名')) {
      return this.handleError(createAIError(ErrorCode.MODEL_SIGNATURE_INVALID, error.message, context), context);
    }

    return this.handleError(createAIError(ErrorCode.MODEL_LOAD_FAILED, error.message, context), context);
  }

  handleInferenceError(error: Error, requestId: string): AIError {
    const context: ErrorContext = {
      requestId,
      operation: 'inference'
    };

    if (error.message.includes('timeout') || error.message.includes('超时')) {
      return this.handleError(createAIError(ErrorCode.INFERENCE_TIMEOUT, error.message, context), context);
    }

    return this.handleError(createAIError(ErrorCode.INFERENCE_FAILED, error.message, context), context);
  }

  handleNPUError(error: Error): AIError {
    const context: ErrorContext = {
      operation: 'npu_access'
    };

    if (error.message.includes('unavailable') || error.message.includes('不可用')) {
      return this.handleError(createAIError(ErrorCode.NPU_UNAVAILABLE, error.message, context), context);
    }

    if (error.message.includes('conflict') || error.message.includes('竞争')) {
      return this.handleError(createAIError(ErrorCode.NPU_RESOURCE_CONFLICT, error.message, context), context);
    }

    if (error.message.includes('deadlock') || error.message.includes('死锁')) {
      return this.handleError(createAIError(ErrorCode.NPU_DEADLOCK, error.message, context), context);
    }

    return this.handleError(createAIError(ErrorCode.NPU_UNAVAILABLE, error.message, context), context);
  }

  handleHiAIError(error: Error): AIError {
    const context: ErrorContext = {
      engine: 'hiai',
      operation: 'hiai_call'
    };

    if (error.message.includes('unavailable') || error.message.includes('不可用')) {
      return this.handleError(createAIError(ErrorCode.HIAI_UNAVAILABLE, error.message, context), context);
    }

    if (error.message.includes('format') || error.message.includes('格式')) {
      return this.handleError(createAIError(ErrorCode.IMAGE_FORMAT_UNSUPPORTED, error.message, context), context);
    }

    return this.handleError(createAIError(ErrorCode.HIAI_UNAVAILABLE, error.message, context), context);
  }

  getRecentErrors(count: number = 10): AIError[] {
    return this.errorLog.slice(-count);
  }

  getErrorStats(): ErrorStats {
    const stats: ErrorStats = {
      total: this.errorLog.length,
      byCode: new Map(),
      byLevel: new Map()
    };

    this.errorLog.forEach(error => {
      const codeCount = stats.byCode.get(error.code) || 0;
      stats.byCode.set(error.code, codeCount + 1);

      const levelCount = stats.byLevel.get(error.level) || 0;
      stats.byLevel.set(error.level, levelCount + 1);
    });

    return stats;
  }

  clearLog(): void {
    this.errorLog = [];
  }

  private isAIError(error: any): boolean {
    return error && typeof error === 'object' && 'code' in error && 'recoveryStrategy' in error;
  }

  private convertToAIError(error: Error, context?: ErrorContext): AIError {
    return createAIError(ErrorCode.UNKNOWN, error.message, context);
  }

  private logError(error: AIError): void {
    this.errorLog.push(error);
    if (this.errorLog.length > this.MAX_LOG_SIZE) {
      this.errorLog.shift();
    }

    switch (error.level) {
      case ErrorLevel.CRITICAL:
        console.error(`[CRITICAL] ${error.code}: ${error.message}`, error.details);
        break;
      case ErrorLevel.ERROR:
        console.error(`[ERROR] ${error.code}: ${error.message}`, error.details);
        break;
      case ErrorLevel.WARNING:
        console.warn(`[WARNING] ${error.code}: ${error.message}`, error.details);
        break;
      case ErrorLevel.INFO:
        console.info(`[INFO] ${error.code}: ${error.message}`, error.details);
        break;
    }
  }

  private executeRecovery(error: AIError): void {
    switch (error.recoveryStrategy) {
      case RecoveryStrategy.FALLBACK_CPU:
        this.fallbackToCPU();
        break;
      case RecoveryStrategy.FALLBACK_ENGINE:
        console.info('ErrorHandler: 切换到降级引擎');
        break;
      case RecoveryStrategy.CLEAR_CACHE:
        this.clearCache();
        break;
      case RecoveryStrategy.RESTART_ENGINE:
        this.restartEngines();
        break;
      case RecoveryStrategy.RETRY:
        console.info('ErrorHandler: 标记为可重试');
        break;
      default:
        break;
    }
  }

  private fallbackToCPU(): void {
    console.info('ErrorHandler: 降级到CPU后端');
    const adapter = MindSporeLiteAdapter.getInstance();
    adapter.setBackend('cpu' as any);
  }

  private clearCache(): void {
    console.info('ErrorHandler: 清空缓存');
    const cache = ResultCache.getInstance();
    cache.clear();
  }

  private restartEngines(): void {
    console.info('ErrorHandler: 重启推理引擎');
    const scheduler = ResourceScheduler.getInstance();
    scheduler.reset();
  }
}

export interface ErrorStats {
  total: number;
  byCode: Map<ErrorCode, number>;
  byLevel: Map<ErrorLevel, number>;
}
