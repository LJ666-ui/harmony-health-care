import { ModelType, ModelStatus, BackendType, MODEL_CONFIGS } from './types/ModelTypes';
import { EngineType } from './types/EngineTypes';
import { InferenceResult, InferenceError, HealthDataInput, InferenceResultData } from './types/InferenceTypes';
import { ErrorCode, createAIError } from './types/ErrorTypes';
import { ResourceScheduler } from './ResourceScheduler';

interface Model {
  type: ModelType;
  handle: object;
  backend: BackendType;
  loadedAt: number;
}

export class MindSporeLiteAdapter {
  private static instance: MindSporeLiteAdapter;

  private initialized: boolean = false;
  private npuAvailable: boolean = false;
  private currentBackend: BackendType = BackendType.CPU;
  private modelRegistry: Map<ModelType, Model> = new Map();

  private readonly LOAD_TIMEOUT: number = 3000;
  private readonly INFERENCE_TIMEOUT: number = 5000;

  private constructor() {}

  static getInstance(): MindSporeLiteAdapter {
    if (!MindSporeLiteAdapter.instance) {
      MindSporeLiteAdapter.instance = new MindSporeLiteAdapter();
    }
    return MindSporeLiteAdapter.instance;
  }

  async initialize(): Promise<void> {
    if (this.initialized) {
      return;
    }

    try {
      console.info('MindSporeLiteAdapter: 开始初始化');

      this.npuAvailable = await this.checkNPUAvailability();
      this.currentBackend = this.npuAvailable ? BackendType.NPU : BackendType.CPU;

      console.info(`MindSporeLiteAdapter: 初始化完成，后端=${this.currentBackend}, NPU可用=${this.npuAvailable}`);
      this.initialized = true;
    } catch (error) {
      console.error('MindSporeLiteAdapter: 初始化失败', error);
      this.currentBackend = BackendType.CPU;
      this.initialized = true;
    }
  }

  async loadModel(modelType: ModelType): Promise<Model> {
    const config = MODEL_CONFIGS.get(modelType);
    if (!config) {
      throw new Error(`不支持的模型类型: ${modelType}`);
    }

    const existingModel = this.modelRegistry.get(modelType);
    if (existingModel) {
      return existingModel;
    }

    const scheduler = ResourceScheduler.getInstance();
    let acquired = false;

    try {
      if (this.npuAvailable) {
        acquired = await scheduler.acquireNPU(EngineType.MINDSPORE_LITE);
      }

      console.info(`MindSporeLiteAdapter: 开始加载模型 ${modelType} from ${config.path}`);

      const modelHandle = await this.simulateLoadModel(config.path);

      const model: Model = {
        type: modelType,
        handle: modelHandle,
        backend: acquired ? BackendType.NPU : BackendType.CPU,
        loadedAt: Date.now()
      };

      this.modelRegistry.set(modelType, model);
      console.info(`MindSporeLiteAdapter: 模型加载成功 ${modelType}`);

      return model;
    } catch (error) {
      console.error(`MindSporeLiteAdapter: 模型加载失败 ${modelType}`, error);
      const err = error instanceof Error ? error : new Error('模型加载失败');
      throw err;
    } finally {
      if (acquired) {
        scheduler.releaseNPU(EngineType.MINDSPORE_LITE);
      }
    }
  }

  async infer(modelType: ModelType, inputData: HealthDataInput): Promise<InferenceResultData> {
    const model = this.modelRegistry.get(modelType);
    if (!model) {
      throw new Error(`模型未加载: ${modelType}`);
    }

    const scheduler = ResourceScheduler.getInstance();
    let acquired = false;

    try {
      if (model.backend === BackendType.NPU) {
        acquired = await scheduler.acquireNPU(EngineType.MINDSPORE_LITE);
      }

      const preprocessed = this.preprocessInput(inputData, modelType);
      const output = await this.simulateInference(model.handle, preprocessed);
      const result = this.postprocessOutput(output, modelType);

      return result;
    } catch (error) {
      console.error(`MindSporeLiteAdapter: 推理失败 ${modelType}`, error);
      const err = error instanceof Error ? error : new Error('推理失败');
      throw err;
    } finally {
      if (acquired) {
        scheduler.releaseNPU(EngineType.MINDSPORE_LITE);
      }
    }
  }

  setBackend(backend: BackendType): void {
    if (backend === BackendType.NPU && !this.npuAvailable) {
      console.warn('MindSporeLiteAdapter: NPU不可用，保持CPU后端');
      return;
    }
    this.currentBackend = backend;
    console.info(`MindSporeLiteAdapter: 后端已设置为 ${backend}`);
  }

  async checkNPUAvailability(): Promise<boolean> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);
      }, 50);
    });
  }

  isInitialized(): boolean {
    return this.initialized;
  }

  isNPUAvailable(): boolean {
    return this.npuAvailable;
  }

  getCurrentBackend(): BackendType {
    return this.currentBackend;
  }

  isModelLoaded(modelType: ModelType): boolean {
    return this.modelRegistry.has(modelType);
  }

  unloadModel(modelType: ModelType): void {
    this.modelRegistry.delete(modelType);
    console.info(`MindSporeLiteAdapter: 模型已卸载 ${modelType}`);
  }

  unloadAllModels(): void {
    this.modelRegistry.clear();
    console.info('MindSporeLiteAdapter: 所有模型已卸载');
  }

  private preprocessInput(data: HealthDataInput, modelType: ModelType): number[] {
    switch (modelType) {
      case ModelType.HEALTH_RISK_ASSESSMENT:
        return this.preprocessHealthData(data);
      case ModelType.TCM_CONSTITUTION:
        return this.preprocessTCMData(data);
      case ModelType.MEDICAL_IMAGE_ANALYSIS:
        return this.preprocessImageData(data);
      default:
        return [0];
    }
  }

  private preprocessHealthData(data: HealthDataInput): number[] {
    const features: number[] = [];
    features.push(Math.min(1, data.age / 100));
    features.push(Math.min(1, data.bmi / 40));
    features.push(Math.min(1, data.systolic / 200));
    features.push(Math.min(1, data.diastolic / 120));
    features.push(Math.min(1, data.fastingGlucose / 15));
    features.push(Math.min(1, data.totalCholesterol / 10));
    return features;
  }

  private preprocessTCMData(data: HealthDataInput): number[] {
    const features: number[] = [];
    return features;
  }

  private preprocessImageData(data: HealthDataInput): number[] {
    return [0.5, 0.5, 0.5];
  }

  private postprocessOutput(output: InferenceResultData, modelType: ModelType): InferenceResultData {
    return output;
  }

  private async simulateLoadModel(path: string): Promise<object> {
    interface LoadResult {
      path: string;
      loaded: boolean;
    }
    return new Promise<LoadResult>((resolve) => {
      setTimeout(() => {
        const result: LoadResult = { path: path, loaded: true };
        resolve(result);
      }, 100);
    });
  }

  private async simulateInference(model: object, input: number[]): Promise<InferenceResultData> {
    return new Promise<InferenceResultData>((resolve) => {
      setTimeout(() => {
        const result: InferenceResultData = { probabilities: [0.3, 0.2, 0.1, 0.15, 0.1] };
        resolve(result);
      }, 50);
    });
  }
}
