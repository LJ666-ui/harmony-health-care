export interface ModelInfo {
  name: string;
  version: string;
  path: string;
  inputSize: number[];
  outputSize: number[];
  loadedAt?: number;
}

export interface LoadResult {
  success: boolean;
  modelInfo?: ModelInfo;
  error?: string;
  loadTimeMs: number;
}

export interface InferenceResult {
  output: number[];
  inferenceTimeMs: number;
  modelVersion: string;
}

export interface ModelStatus {
  isLoaded: boolean;
  modelName: string | null;
  version: string | null;
}

export class ModelLoader {
  private static instance: ModelLoader | null = null;
  private currentModel: ModelInfo | undefined = undefined;
  private isModelLoaded: boolean = false;
  private modelCache: Map<string, ModelInfo> = new Map<string, ModelInfo>();

  static getInstance(): ModelLoader {
    if (!ModelLoader.instance) {
      ModelLoader.instance = new ModelLoader();
    }
    return ModelLoader.instance;
  }

  private constructor() {
    console.log('[ModelLoader] 模型加载器初始化完成');
  }

  async load(modelName: string): Promise<LoadResult> {
    const startTime = Date.now();

    console.log(`[ModelLoader] 开始加载模型: ${modelName}`);

    try {
      if (this.modelCache.has(modelName)) {
        const cachedModel = this.modelCache.get(modelName);
        if (cachedModel) {
          this.currentModel = cachedModel;
          this.isModelLoaded = true;

          console.log(`[ModelLoader] 从缓存中加载模型成功`);

          return {
            success: true,
            modelInfo: this.currentModel,
            loadTimeMs: Date.now() - startTime
          };
        }
      }

      const modelPath = await ModelLoader.resolveModelPath(modelName);

      if (!modelPath) {
        throw new Error(`模型文件未找到: ${modelName}`);
      }

      const modelInfo = await ModelLoader.loadMindSporeModel(modelName, modelPath);

      this.currentModel = modelInfo;
      this.isModelLoaded = true;
      this.modelCache.set(modelName, modelInfo);

      const loadTime = Date.now() - startTime;

      console.log(`[ModelLoader] 模型加载成功:`);
      console.log(`  名称: ${modelInfo.name}`);
      console.log(`  版本: ${modelInfo.version}`);
      console.log(`  输入维度: [${modelInfo.inputSize.join(', ')}]`);
      console.log(`  输出维度: [${modelInfo.outputSize.join(', ')}]`);
      console.log(`  加载耗时: ${loadTime}ms`);

      return {
        success: true,
        modelInfo: modelInfo,
        loadTimeMs: loadTime
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);

      console.error(`[ModelLoader] 模型加载失败:`, errorMsg);

      this.isModelLoaded = false;
      this.currentModel = undefined;

      return {
        success: false,
        error: errorMsg,
        loadTimeMs: Date.now() - startTime
      };
    }
  }

  private static async resolveModelPath(modelName: string): Promise<string | null> {
    console.log(`[ModelLoader] 解析模型路径: ${modelName}`);

    const possiblePaths: string[] = [
      `entry/src/main/resources/rawfile/${modelName}`,
      `entry/src/main/resources/rawfile/models/${modelName}`,
      `/data/storage/el2/base/haps/entry/cache/${modelName}`,
      `${modelName}`
    ];

    for (const path of possiblePaths) {
      if (await ModelLoader.fileExists(path)) {
        console.log(`[ModelLoader] 找到模型文件: ${path}`);
        return path;
      }
    }

    console.warn(`[ModelLoader] 未找到模型文件，将使用Mock推理`);
    return null;
  }

  private static async fileExists(path: string): Promise<boolean> {
    try {
      return false;
    } catch (e) {
      return false;
    }
  }

  private static async loadMindSporeModel(modelName: string, modelPath: string): Promise<ModelInfo> {
    try {
      console.warn('[ModelLoader] MindSpore Kit不可用，创建Mock模型');
      return ModelLoader.createMockModelInfo(modelName, modelPath);

    } catch (error) {
      console.warn('[ModelLoader] MindSpore模型加载失败，降级为Mock模式:',
        error instanceof Error ? error.message : String(error));

      return ModelLoader.createMockModelInfo(modelName, modelPath);
    }
  }

  private static createMockModelInfo(modelName: string, modelPath: string): ModelInfo {
    return {
      name: modelName,
      version: '1.0.0-Mock',
      path: modelPath || 'mock_model_path',
      inputSize: [1, 10],
      outputSize: [1, 5],
      loadedAt: Date.now()
    };
  }

  async runInference(inputData: number[]): Promise<InferenceResult> {
    const startTime = Date.now();

    if (!this.isModelLoaded || !this.currentModel) {
      console.warn('[ModelLoader] 模型未加载，执行Mock推理');
      return this.runMockInference(inputData);
    }

    try {
      console.log('[ModelLoader] 使用Mock推理模式');
      return this.runMockInference(inputData);

    } catch (error) {
      console.error('[ModelLoader] 推理失败:', error instanceof Error ? error.message : String(error));
      return this.runMockInference(inputData);
    }
  }

  private runMockInference(inputData: number[]): InferenceResult {
    console.log('[ModelLoader] 执行基于规则的Mock推理...');

    const startTime = Date.now();

    const mockOutput = ModelLoader.generateRuleBasedOutput(inputData);

    const inferenceTime = Date.now() - startTime + Math.random() * 50 + 20;

    console.log(`[ModelLoader] Mock推理完成，耗时: ${inferenceTime.toFixed(1)}ms`);
    console.log(`[ModelLoader] Mock输出: [${mockOutput.map(v => v.toFixed(3)).join(', ')}]`);

    const version = this.currentModel ? this.currentModel.version : '1.0.0-Mock';

    return {
      output: mockOutput,
      inferenceTimeMs: inferenceTime,
      modelVersion: version
    };
  }

  private static generateRuleBasedOutput(features: number[]): number[] {
    let hypertensionRisk = 0.05;
    let diabetesRisk = 0.05;
    let fallRisk = 0.15;
    let frailtyRisk = 0.10;
    let sarcopeniaRisk = 0.08;

    if (features[2] > 0.65) {
      hypertensionRisk += (features[2] - 0.5) * 1.2;
    }
    if (features[3] > 0.7) {
      hypertensionRisk += (features[3] - 0.6) * 0.8;
    }
    if (features[0] > 0.7) {
      hypertensionRisk += 0.12;
    }

    if (features[4] > 0.55) {
      diabetesRisk += (features[4] - 0.45) * 1.5;
    }
    if (features[1] > 0.75) {
      diabetesRisk += 0.15;
    }
    if (features[0] > 0.55) {
      diabetesRisk += 0.08;
    }

    fallRisk = features[8];

    frailtyRisk = features[9] * 0.9 + 0.05;

    if (features[5] < 0.25 || features[5] > 0.75) {
      fallRisk += 0.08;
    }

    if (features[7] < 0.3) {
      frailtyRisk += 0.15;
      sarcopeniaRisk += 0.12;
    }

    hypertensionRisk = Math.min(0.98, Math.max(0.02, hypertensionRisk));
    diabetesRisk = Math.min(0.98, Math.max(0.02, diabetesRisk));
    fallRisk = Math.min(0.95, Math.max(0.03, fallRisk));
    frailtyRisk = Math.min(0.92, Math.max(0.02, frailtyRisk));
    sarcopeniaRisk = Math.min(0.90, Math.max(0.02, sarcopeniaRisk));

    return [
      parseFloat(hypertensionRisk.toFixed(4)),
      parseFloat(diabetesRisk.toFixed(4)),
      parseFloat(fallRisk.toFixed(4)),
      parseFloat(frailtyRisk.toFixed(4)),
      parseFloat(sarcopeniaRisk.toFixed(4))
    ];
  }

  unload(): boolean {
    try {
      if (this.currentModel) {
        console.log(`[ModelLoader] 卸载模型: ${this.currentModel.name}`);

        this.modelCache.clear();
        this.currentModel = undefined;
        this.isModelLoaded = false;

        return true;
      }

      return false;
    } catch (error) {
      console.error('[ModelLoader] 卸载模型失败:', error instanceof Error ? error.message : String(error));
      return false;
    }
  }

  getModelStatus(): ModelStatus {
    return {
      isLoaded: this.isModelLoaded,
      modelName: this.currentModel?.name || null,
      version: this.currentModel?.version || null
    };
  }

  clearCache(): void {
    this.modelCache.clear();
    console.log('[ModelLoader] 模型缓存已清空');
  }
}
