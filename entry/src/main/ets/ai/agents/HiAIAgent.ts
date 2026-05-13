import { AIRequest, AIResponse, AgentId } from '../models/AITypes';

export interface HiAIConfig {
  modelPath: string;
  deviceType: 'npu' | 'cpu' | 'gpu';
  enableDynamicBatch: boolean;
  threadsNum: number;
}

export interface ModelInput {
  type: 'image' | 'tensor' | 'audio';
  data: ArrayBuffer | number[];
  shape?: number[];
}

export interface ModelOutput {
  label: string;
  confidence: number;
  processingTime: number;
}

export interface ImageClassificationResult {
  labels: Array<{
    name: string;
    confidence: number;
  }>;
  processingTime: number;
}

export interface OCRResult {
  text: string;
  boxes: Array<{
    x: number;
    y: number;
    width: number;
    height: number;
  }>;
  processingTime: number;
}

export interface PoseDetectionResult {
  keypoints: Array<{
    name: string;
    x: number;
    y: number;
    confidence: number;
  }>;
  skeleton: Array<[string, string]>;
  fallDetected: boolean;
  processingTime: number;
}

export class HiAIAdapter {
  private static instance: HiAIAdapter | null = null;
  private readonly agentId: AgentId = 'hiai';
  private isInitialized: boolean = false;
  private isAvailable: boolean = false;
  private config: HiAIConfig;
  private loadedModels: Map<string, any> = new Map();

  private constructor() {
    this.config = {
      modelPath: '',
      deviceType: 'cpu',
      enableDynamicBatch: false,
      threadsNum: 4
    };
    console.log('[HiAIAdapter] HiAI NPU加速器实例创建');
  }

  static getInstance(): HiAIAdapter {
    if (!HiAIAdapter.instance) {
      HiAIAdapter.instance = new HiAIAdapter();
    }
    return HiAIAdapter.instance;
  }

  async initialize(config?: Partial<HiAIConfig>): Promise<boolean> {
    const startTime = Date.now();
    console.log('[HiAIAdapter] 初始化HiAI NPU加速器...');

    if (config) {
      this.config = { ...this.config, ...config };
    }

    try {
      const capability = await this.checkNPUCapability();

      if (capability.supported) {
        this.isAvailable = true;
        this.config.deviceType = capability.deviceType as 'npu' | 'cpu' | 'gpu';
        console.log(`[HiAIAdapter] ✅ NPU可用，设备类型: ${this.config.deviceType}`);
      } else {
        this.isAvailable = false;
        this.config.deviceType = 'cpu';
        console.log('[HiAIAdapter] ⚠️ NPU不可用，降级到CPU模式');
      }

      this.isInitialized = true;
      console.log(`[HiAIAdapter] 初始化完成，耗时: ${Date.now() - startTime}ms`);
      return true;

    } catch (error) {
      console.error('[HiAIAdapter] ❌ 初始化失败:', error);
      this.isAvailable = false;
      this.isInitialized = true;
      return false;
    }
  }

  private async checkNPUCapability(): Promise<{ supported: boolean; deviceType: string }> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const isMate60 = this.checkDeviceModel();
        resolve({
          supported: isMate60,
          deviceType: isMate60 ? 'npu' : 'cpu'
        });
      }, 100);
    });
  }

  private checkDeviceModel(): boolean {
    return false;
  }

  async loadModel(modelName: string, modelPath: string): Promise<boolean> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    console.log(`[HiAIAdapter] 加载模型: ${modelName} from ${modelPath}`);

    try {
      if (this.loadedModels.has(modelName)) {
        console.log(`[HiAIAdapter] 模型 ${modelName} 已加载`);
        return true;
      }

      if (this.isAvailable && this.config.deviceType === 'npu') {
        console.log(`[HiAIAdapter] ⚡ 使用NPU加载模型（待真机测试）`);
      } else {
        console.log(`[HiAIAdapter] 💻 使用CPU加载模型（模拟模式）`);
      }

      this.loadedModels.set(modelName, {
        name: modelName,
        path: modelPath,
        loadedAt: Date.now(),
        device: this.config.deviceType
      });

      return true;

    } catch (error) {
      console.error(`[HiAIAdapter] ❌ 模型加载失败: ${modelName}`, error);
      return false;
    }
  }

  async inference(input: ModelInput, modelName: string): Promise<ModelOutput[]> {
    if (!this.isInitialized) {
      await this.initialize();
    }

    const startTime = Date.now();
    console.log(`[HiAIAdapter] 执行推理: ${modelName}`);

    if (!this.loadedModels.has(modelName)) {
      await this.loadModel(modelName, this.config.modelPath);
    }

    if (this.isAvailable && this.config.deviceType === 'npu') {
      return this.npuInference(input, modelName, startTime);
    } else {
      return this.cpuInference(input, modelName, startTime);
    }
  }

  private async npuInference(input: ModelInput, modelName: string, startTime: number): Promise<ModelOutput[]> {
    console.log('[HiAIAdapter] ⚡ NPU推理（待真机测试）');
    await this.simulateDelay(50, 100);

    return this.generateMockResults(modelName, startTime);
  }

  private async cpuInference(input: ModelInput, modelName: string, startTime: number): Promise<ModelOutput[]> {
    console.log('[HiAIAdapter] 💻 CPU推理（模拟模式）');
    await this.simulateDelay(100, 200);

    return this.generateMockResults(modelName, startTime);
  }

  private generateMockResults(modelName: string, startTime: number): ModelOutput[] {
    const mockResults: Record<string, ModelOutput[]> = {
      'health_risk_assessment': [
        { label: 'low_risk', confidence: 0.75, processingTime: Date.now() - startTime },
        { label: 'blood_pressure_normal', confidence: 0.82, processingTime: Date.now() - startTime }
      ],
      'heart_anomaly': [
        { label: 'normal', confidence: 0.90, processingTime: Date.now() - startTime }
      ],
      'fall_detection': [
        { label: 'no_fall', confidence: 0.95, processingTime: Date.now() - startTime }
      ],
      'skin_classification': [
        { label: 'normal', confidence: 0.85, processingTime: Date.now() - startTime }
      ],
      'fundus_analysis': [
        { label: 'normal_fundus', confidence: 0.88, processingTime: Date.now() - startTime }
      ]
    };

    return mockResults[modelName] || [
      { label: 'unknown', confidence: 0.5, processingTime: Date.now() - startTime }
    ];
  }

  async classifyImage(imageUri: string): Promise<ImageClassificationResult> {
    console.log(`[HiAIAdapter] 图像分类: ${imageUri}`);
    const startTime = Date.now();

    const result = await this.inference(
      { type: 'image', data: new ArrayBuffer(0) },
      'skin_classification'
    );

    return {
      labels: result.map(r => ({ name: r.label, confidence: r.confidence })),
      processingTime: Date.now() - startTime
    };
  }

  async recognizeText(imageUri: string): Promise<OCRResult> {
    console.log(`[HiAIAdapter] OCR识别: ${imageUri}`);
    const startTime = Date.now();

    await this.simulateDelay(200, 400);

    return {
      text: '模拟OCR文本结果',
      boxes: [
        { x: 10, y: 10, width: 100, height: 20 }
      ],
      processingTime: Date.now() - startTime
    };
  }

  async detectPose(imageUri: string): Promise<PoseDetectionResult> {
    console.log(`[HiAIAdapter] 姿态检测: ${imageUri}`);
    const startTime = Date.now();

    await this.simulateDelay(100, 200);

    return {
      keypoints: [
        { name: 'head', x: 100, y: 50, confidence: 0.95 },
        { name: 'left_shoulder', x: 80, y: 100, confidence: 0.90 },
        { name: 'right_shoulder', x: 120, y: 100, confidence: 0.90 },
        { name: 'left_hand', x: 60, y: 150, confidence: 0.85 },
        { name: 'right_hand', x: 140, y: 150, confidence: 0.85 },
        { name: 'left_knee', x: 85, y: 200, confidence: 0.88 },
        { name: 'right_knee', x: 115, y: 200, confidence: 0.88 },
        { name: 'left_foot', x: 80, y: 250, confidence: 0.82 },
        { name: 'right_foot', x: 120, y: 250, confidence: 0.82 }
      ],
      skeleton: [
        ['head', 'left_shoulder'],
        ['head', 'right_shoulder'],
        ['left_shoulder', 'right_shoulder'],
        ['left_shoulder', 'left_hand'],
        ['right_shoulder', 'right_hand'],
        ['left_shoulder', 'left_knee'],
        ['right_shoulder', 'right_knee'],
        ['left_knee', 'left_foot'],
        ['right_knee', 'right_foot']
      ],
      fallDetected: false,
      processingTime: Date.now() - startTime
    };
  }

  async analyzeFundus(imageUri: string): Promise<ImageClassificationResult> {
    console.log(`[HiAIAdapter] 眼底分析: ${imageUri}`);
    return this.classifyImage(imageUri);
  }

  async processHealthData(healthData: {
    bloodPressure?: { systolic: number; diastolic: number };
    heartRate?: number;
    bloodSugar?: number;
    weight?: number;
    height?: number;
  }): Promise<{ riskScore: number; riskLevel: string; suggestions: string[] }> {
    console.log('[HiAIAdapter] 处理健康数据...');

    let riskScore = 30;
    const suggestions: string[] = [];

    if (healthData.bloodPressure) {
      const { systolic, diastolic } = healthData.bloodPressure;
      if (systolic > 140 || diastolic > 90) {
        riskScore += 25;
        suggestions.push('血压偏高，建议减少盐分摄入');
      }
    }

    if (healthData.heartRate) {
      if (healthData.heartRate > 100) {
        riskScore += 15;
        suggestions.push('心率偏快，建议适当休息');
      }
    }

    if (healthData.bloodSugar) {
      if (healthData.bloodSugar > 6.1) {
        riskScore += 20;
        suggestions.push('血糖偏高，注意饮食控制');
      }
    }

    if (healthData.weight && healthData.height) {
      const bmi = healthData.weight / ((healthData.height / 100) ** 2);
      if (bmi > 24) {
        riskScore += 10;
        suggestions.push('体重偏高，建议适当运动');
      }
    }

    const riskLevel = riskScore < 40 ? '低' : riskScore < 70 ? '中' : '高';

    if (suggestions.length === 0) {
      suggestions.push('各项指标基本正常，保持良好生活习惯');
    }
    suggestions.push('定期体检，关注健康变化');

    return { riskScore, riskLevel, suggestions };
  }

  async release(): Promise<void> {
    console.log('[HiAIAdapter] 释放资源...');
    this.loadedModels.clear();
    this.isInitialized = false;
    this.isAvailable = false;
  }

  getAvailability(): boolean {
    return this.isAvailable;
  }

  getDeviceType(): string {
    return this.config.deviceType;
  }

  private simulateDelay(minMs: number, maxMs: number): Promise<void> {
    const delay = Math.floor(Math.random() * (maxMs - minMs + 1)) + minMs;
    return new Promise(resolve => setTimeout(resolve, delay));
  }
}

export class HiAIAgent {
  private readonly agentId: AgentId = 'hiai';
  private adapter: HiAIAdapter;

  constructor() {
    this.adapter = HiAIAdapter.getInstance();
    console.log('[HiAIAgent] HiAI智能体初始化');
  }

  async process(request: AIRequest): Promise<AIResponse> {
    const startTime = Date.now();
    console.log(`[HiAIAgent] 处理请求: ${request.requestId}`);

    try {
      const inputText = this.extractInputText(request);
      let result: any;

      if (inputText.includes('风险') || inputText.includes('评估')) {
        result = await this.adapter.processHealthData({});
      } else if (inputText.includes('跌倒') || inputText.includes('姿态')) {
        const poseResult = await this.adapter.detectPose('');
        result = {
          content: poseResult.fallDetected ? '检测到跌倒！' : '姿态正常',
          data: poseResult
        };
      } else {
        result = { content: 'HiAI处理完成', data: null };
      }

      return {
        requestId: request.requestId,
        agentId: this.agentId,
        output: {
          type: 'text',
          content: typeof result === 'string' ? result : result.content,
          confidence: 0.85
        },
        metadata: {
          processingTime: Date.now() - startTime,
          modelUsed: 'HiAI-NPU-Simulated',
          isOffline: true,
          agentVersion: '1.0.0'
        },
        suggestions: ['查看详细报告', '继续其他操作']
      };

    } catch (error) {
      console.error('[HiAIAgent] 处理失败:', error);
      return this.createErrorResponse(request.requestId, startTime);
    }
  }

  private extractInputText(request: AIRequest): string {
    if (typeof request.input.content === 'string') {
      return request.input.content;
    }
    return '';
  }

  private createErrorResponse(requestId: string, startTime: number): AIResponse {
    return {
      requestId,
      agentId: this.agentId,
      output: {
        type: 'text',
        content: 'HiAI服务暂时不可用，请稍后重试。',
        confidence: 0.1
      },
      metadata: {
        processingTime: Date.now() - startTime,
        isOffline: false,
        agentVersion: '1.0.0'
      }
    };
  }
}
