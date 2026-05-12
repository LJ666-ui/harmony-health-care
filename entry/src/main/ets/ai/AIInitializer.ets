import { ModelType, MODEL_CONFIGS } from './types/ModelTypes';
import { MindSporeLiteAdapter } from './MindSporeLiteAdapter';
import { HiAIAdapter } from './HiAIAdapter';
import { ResourceScheduler } from './ResourceScheduler';
import { ResultCache } from './ResultCache';
import { PerformanceMonitor } from './PerformanceMonitor';
import { ErrorHandler } from './ErrorHandler';

export interface InitializationResult {
  success: boolean;
  mindsporeInitialized: boolean;
  hiaiInitialized: boolean;
  npuAvailable: boolean;
  preloadedModels: ModelType[];
  errors: string[];
  duration: number;
}

export class AIInitializer {
  private static instance: AIInitializer;

  private initialized: boolean = false;
  private mindsporeAdapter: MindSporeLiteAdapter;
  private hiaiAdapter: HiAIAdapter;
  private resourceScheduler: ResourceScheduler;
  private resultCache: ResultCache;
  private performanceMonitor: PerformanceMonitor;
  private errorHandler: ErrorHandler;

  private constructor() {
    this.mindsporeAdapter = MindSporeLiteAdapter.getInstance();
    this.hiaiAdapter = HiAIAdapter.getInstance();
    this.resourceScheduler = ResourceScheduler.getInstance();
    this.resultCache = ResultCache.getInstance();
    this.performanceMonitor = PerformanceMonitor.getInstance();
    this.errorHandler = ErrorHandler.getInstance();
  }

  static getInstance(): AIInitializer {
    if (!AIInitializer.instance) {
      AIInitializer.instance = new AIInitializer();
    }
    return AIInitializer.instance;
  }

  async initialize(): Promise<InitializationResult> {
    if (this.initialized) {
      console.info('AIInitializer: 已经初始化');
      return {
        success: true,
        mindsporeInitialized: true,
        hiaiInitialized: true,
        npuAvailable: this.mindsporeAdapter.isNPUAvailable(),
        preloadedModels: [],
        errors: [],
        duration: 0
      };
    }

    const startTime = Date.now();
    const errors: string[] = [];
    const preloadedModels: ModelType[] = [];

    console.info('AIInitializer: 开始AI引擎初始化');

    let mindsporeInitialized = false;
    let hiaiInitialized = false;
    let npuAvailable = false;

    try {
      console.info('AIInitializer: 初始化MindSpore Lite');
      await this.mindsporeAdapter.initialize();
      mindsporeInitialized = true;
      npuAvailable = this.mindsporeAdapter.isNPUAvailable();
      console.info(`AIInitializer: MindSpore Lite初始化完成, NPU可用=${npuAvailable}`);
    } catch (error) {
      errors.push(`MindSpore Lite初始化失败: ${error}`);
      console.error('AIInitializer: MindSpore Lite初始化失败', error);
    }

    try {
      console.info('AIInitializer: 初始化HiAI');
      await this.hiaiAdapter.initialize();
      hiaiInitialized = this.hiaiAdapter.isAvailable();
      console.info(`AIInitializer: HiAI初始化完成, 可用=${hiaiInitialized}`);
    } catch (error) {
      errors.push(`HiAI初始化失败: ${error}`);
      console.error('AIInitializer: HiAI初始化失败', error);
    }

    if (mindsporeInitialized) {
      try {
        console.info('AIInitializer: 预加载核心模型');
        const preloadModels = [
          ModelType.HEALTH_RISK_ASSESSMENT
        ];

        for (const modelType of preloadModels) {
          const config = MODEL_CONFIGS.get(modelType);
          if (config && config.preload) {
            try {
              await this.mindsporeAdapter.loadModel(modelType);
              preloadedModels.push(modelType);
              console.info(`AIInitializer: 预加载模型成功 ${modelType}`);
            } catch (error) {
              errors.push(`预加载模型失败 ${modelType}: ${error}`);
              console.error(`AIInitializer: 预加载模型失败 ${modelType}`, error);
            }
          }
        }
      } catch (error) {
        errors.push(`预加载模型失败: ${error}`);
        console.error('AIInitializer: 预加载模型失败', error);
      }
    }

    this.initialized = true;
    const duration = Date.now() - startTime;

    const result: InitializationResult = {
      success: mindsporeInitialized || hiaiInitialized,
      mindsporeInitialized,
      hiaiInitialized,
      npuAvailable,
      preloadedModels,
      errors,
      duration
    };

    console.info(`AIInitializer: 初始化完成, 成功=${result.success}, 耗时=${duration}ms`);
    return result;
  }

  async cleanup(): Promise<void> {
    console.info('AIInitializer: 开始清理AI资源');

    try {
      this.mindsporeAdapter.unloadAllModels();
      console.info('AIInitializer: MindSpore模型已卸载');
    } catch (error) {
      console.error('AIInitializer: 卸载MindSpore模型失败', error);
    }

    try {
      this.resourceScheduler.reset();
      console.info('AIInitializer: 资源调度器已重置');
    } catch (error) {
      console.error('AIInitializer: 重置资源调度器失败', error);
    }

    try {
      this.resultCache.clear();
      this.resultCache.stopCleanupTimer();
      console.info('AIInitializer: 结果缓存已清空');
    } catch (error) {
      console.error('AIInitializer: 清空结果缓存失败', error);
    }

    try {
      this.performanceMonitor.clearMetrics();
      console.info('AIInitializer: 性能监控数据已清空');
    } catch (error) {
      console.error('AIInitializer: 清空性能监控数据失败', error);
    }

    this.initialized = false;
    console.info('AIInitializer: AI资源清理完成');
  }

  isInitialized(): boolean {
    return this.initialized;
  }

  getStatus(): AIStatus {
    return {
      initialized: this.initialized,
      mindsporeReady: this.mindsporeAdapter.isInitialized(),
      hiaiReady: this.hiaiAdapter.isAvailable(),
      npuAvailable: this.mindsporeAdapter.isNPUAvailable(),
      currentBackend: this.mindsporeAdapter.getCurrentBackend()
    };
  }
}

export interface AIStatus {
  initialized: boolean;
  mindsporeReady: boolean;
  hiaiReady: boolean;
  npuAvailable: boolean;
  currentBackend: string;
}
