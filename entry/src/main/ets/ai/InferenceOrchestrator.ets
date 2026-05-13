import { ModelType, BackendType } from './types/ModelTypes';
import { EngineType, InferencePriority, InferenceScene, SCENE_ENGINE_MAP } from './types/EngineTypes';
import { InferenceRequest, InferenceResult, InferenceError, InferenceMetrics, InferenceOutput, HealthDataInput } from './types/InferenceTypes';
import { ResultCache } from './ResultCache';
import { ResourceScheduler } from './ResourceScheduler';
import { MindSporeLiteAdapter } from './MindSporeLiteAdapter';
import { HiAIAdapter } from './HiAIAdapter';
import { ImageData, EnhanceOptions, ImageFormat } from './types/VisionTypes';

export class InferenceOrchestrator {
  private static instance: InferenceOrchestrator;

  private resultCache: ResultCache;
  private resourceScheduler: ResourceScheduler;
  private mindsporeAdapter: MindSporeLiteAdapter;
  private hiaiAdapter: HiAIAdapter;

  private metrics: InferenceMetrics[] = [];
  private readonly MAX_METRICS: number = 1000;

  private constructor() {
    this.resultCache = ResultCache.getInstance();
    this.resourceScheduler = ResourceScheduler.getInstance();
    this.mindsporeAdapter = MindSporeLiteAdapter.getInstance();
    this.hiaiAdapter = HiAIAdapter.getInstance();
  }

  static getInstance(): InferenceOrchestrator {
    if (!InferenceOrchestrator.instance) {
      InferenceOrchestrator.instance = new InferenceOrchestrator();
    }
    return InferenceOrchestrator.instance;
  }

  async executeInference(request: InferenceRequest): Promise<InferenceResult> {
    const startTime = Date.now();
    const traceId = this.generateTraceId();

    console.info(`InferenceOrchestrator: 开始推理 traceId=${traceId}, scene=${request.scene}`);

    try {
      if (request.enableCache !== false) {
        const cacheKey = this.resultCache.generateKey(request.input, request.modelType);
        const cachedResult = this.resultCache.get(cacheKey);
        if (cachedResult) {
          console.info(`InferenceOrchestrator: 缓存命中 traceId=${traceId}`);
          const cachedResponse: InferenceResult = {
            requestId: cachedResult.requestId,
            success: cachedResult.success,
            output: cachedResult.output,
            engine: cachedResult.engine,
            backend: cachedResult.backend,
            modelVersion: cachedResult.modelVersion,
            latency: cachedResult.latency,
            cached: true,
            timestamp: cachedResult.timestamp
          };
          return cachedResponse;
        }
      }

      const engine = this.selectEngine(request);
      console.info(`InferenceOrchestrator: 选择引擎=${engine} traceId=${traceId}`);

      let result: InferenceOutput;
      let usedBackend = BackendType.CPU;

      switch (engine) {
        case EngineType.MINDSPORE_LITE:
          result = await this.executeWithMindSpore(request);
          usedBackend = this.mindsporeAdapter.getCurrentBackend();
          break;
        case EngineType.HIAI:
          result = await this.executeWithHiAI(request);
          usedBackend = BackendType.NPU;
          break;
        case EngineType.FALLBACK:
          result = await this.executeWithFallback(request);
          usedBackend = BackendType.CPU;
          break;
      }

      const inferenceResult: InferenceResult = {
        requestId: request.requestId,
        success: true,
        output: result,
        engine: engine,
        backend: usedBackend,
        modelVersion: '1.0.0',
        latency: Date.now() - startTime,
        cached: false,
        timestamp: Date.now()
      };

      if (request.enableCache !== false) {
        const cacheKey = this.resultCache.generateKey(request.input, request.modelType);
        this.resultCache.set(cacheKey, inferenceResult);
      }

      this.collectMetrics(request, inferenceResult);

      console.info(`InferenceOrchestrator: 推理完成 traceId=${traceId}, latency=${inferenceResult.latency}ms`);
      return inferenceResult;

    } catch (error) {
      console.error(`InferenceOrchestrator: 推理失败 traceId=${traceId}`, error);

      const errorOutput = new InferenceOutput();
      const errorResult: InferenceResult = {
        requestId: request.requestId,
        success: false,
        output: errorOutput,
        engine: EngineType.FALLBACK,
        backend: BackendType.CPU,
        modelVersion: 'fallback-v1',
        latency: Date.now() - startTime,
        cached: false,
        timestamp: Date.now(),
        error: {
          code: 'INFERENCE_ERROR',
          message: String(error),
          recoverable: true
        }
      };

      return errorResult;
    }
  }

  async batchExecute(requests: InferenceRequest[]): Promise<InferenceResult[]> {
    const promises = requests.map(req => this.executeInference(req));
    return Promise.all(promises);
  }

  selectEngine(request: InferenceRequest): EngineType {
    if (request.preferredEngine) {
      return request.preferredEngine;
    }

    const sceneEngine = SCENE_ENGINE_MAP.get(request.scene);
    if (sceneEngine) {
      return sceneEngine;
    }

    switch (request.modelType) {
      case ModelType.HEALTH_RISK_ASSESSMENT:
      case ModelType.TCM_CONSTITUTION:
      case ModelType.MEDICAL_IMAGE_ANALYSIS:
        return EngineType.MINDSPORE_LITE;
      case ModelType.OBJECT_DETECTION:
      case ModelType.POSE_DETECTION:
      case ModelType.IMAGE_ENHANCEMENT:
      case ModelType.OCR_RECOGNITION:
        return EngineType.HIAI;
      default:
        return EngineType.FALLBACK;
    }
  }

  getCacheStats() {
    return this.resultCache.getStats();
  }

  getResourceMetrics() {
    return this.resourceScheduler.getMetrics();
  }

  clearCache(): void {
    this.resultCache.clear();
  }

  private async executeWithMindSpore(request: InferenceRequest): Promise<InferenceOutput> {
    if (!this.mindsporeAdapter.isModelLoaded(request.modelType)) {
      await this.mindsporeAdapter.loadModel(request.modelType);
    }
    const healthData: HealthDataInput = {
      age: request.input.age,
      bmi: request.input.bmi,
      systolic: request.input.systolic,
      diastolic: request.input.diastolic,
      fastingGlucose: request.input.fastingGlucose,
      totalCholesterol: request.input.totalCholesterol
    };
    const result = await this.mindsporeAdapter.infer(request.modelType, healthData);
    const output = new InferenceOutput();
    output.probabilities = result.probabilities;
    return output;
  }

  private async executeWithHiAI(request: InferenceRequest): Promise<InferenceOutput> {
    if (!this.hiaiAdapter.isAvailable()) {
      throw new Error('HiAI服务不可用');
    }

    const imageData: ImageData = {
      uri: request.input.uri || '',
      width: request.input.width || 0,
      height: request.input.height || 0,
      format: (request.input.format as ImageFormat) || ImageFormat.JPEG
    };

    switch (request.scene) {
      case InferenceScene.OBJECT_DETECTION:
        await this.hiaiAdapter.detectObjects(imageData, 0.5);
        return new InferenceOutput();
      case InferenceScene.POSE_DETECTION:
        await this.hiaiAdapter.detectPose(imageData);
        return new InferenceOutput();
      case InferenceScene.IMAGE_ENHANCEMENT:
        await this.hiaiAdapter.enhanceImage(imageData, (request.input.options as EnhanceOptions) || {});
        return new InferenceOutput();
      case InferenceScene.OCR_RECOGNITION:
        await this.hiaiAdapter.recognizeText(imageData, 0.7);
        return new InferenceOutput();
      case InferenceScene.IMAGE_CLASSIFICATION:
        await this.hiaiAdapter.classifyImage(imageData);
        return new InferenceOutput();
      default:
        throw new Error(`HiAI不支持的场景: ${request.scene}`);
    }
  }

  private async executeWithFallback(request: InferenceRequest): Promise<InferenceOutput> {
    console.info(`InferenceOrchestrator: 使用降级引擎 scene=${request.scene}`);
    const output = new InferenceOutput();
    output.fallback = true;
    output.input = request.input;
    return output;
  }

  private collectMetrics(request: InferenceRequest, result: InferenceResult): void {
    const metrics: InferenceMetrics = {
      requestId: request.requestId,
      scene: request.scene,
      engine: result.engine,
      backend: result.backend,
      inputSize: JSON.stringify(request.input).length,
      outputSize: JSON.stringify(result.output).length,
      preprocessingTime: 0,
      inferenceTime: result.latency,
      postprocessingTime: 0,
      totalTime: result.latency,
      cached: result.cached,
      timestamp: Date.now()
    };

    this.metrics.push(metrics);
    if (this.metrics.length > this.MAX_METRICS) {
      this.metrics.shift();
    }
  }

  private generateTraceId(): string {
    return 'TRACE-' + Date.now().toString(36) + '-' + Math.random().toString(36).substring(2, 8);
  }
}
