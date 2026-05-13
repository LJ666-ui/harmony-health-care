import { EngineType } from './types/EngineTypes';
import { ImageData, ImageFormat, DetectionResult, DetectedObject, PoseResult, Keypoint, OCRResult, OCRTextItem, ClassificationResult, ClassItem, EnhanceOptions, KEYPOINT_NAMES } from './types/VisionTypes';
import { ErrorCode, createAIError } from './types/ErrorTypes';
import { ResourceScheduler } from './ResourceScheduler';

export class HiAIAdapter {
  private static instance: HiAIAdapter;

  private initialized: boolean = false;
  private available: boolean = false;
  private supportedCapabilities: string[] = [];

  private readonly DETECTION_TIMEOUT: number = 300;
  private readonly POSE_TIMEOUT: number = 200;
  private readonly ENHANCE_TIMEOUT: number = 1000;
  private readonly OCR_TIMEOUT: number = 1500;

  private constructor() {}

  static getInstance(): HiAIAdapter {
    if (!HiAIAdapter.instance) {
      HiAIAdapter.instance = new HiAIAdapter();
    }
    return HiAIAdapter.instance;
  }

  async initialize(): Promise<void> {
    if (this.initialized) {
      return;
    }

    try {
      console.info('HiAIAdapter: 开始初始化');

      this.available = await this.checkAvailability();

      if (this.available) {
        this.supportedCapabilities = [
          'object_detection',
          'pose_detection',
          'image_enhancement',
          'ocr_recognition',
          'image_classification'
        ];
      }

      console.info(`HiAIAdapter: 初始化完成，可用=${this.available}`);
      this.initialized = true;
    } catch (error) {
      console.error('HiAIAdapter: 初始化失败', error);
      this.available = false;
      this.initialized = true;
    }
  }

  async checkAvailability(): Promise<boolean> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);
      }, 50);
    });
  }

  isAvailable(): boolean {
    return this.available;
  }

  isInitialized(): boolean {
    return this.initialized;
  }

  async detectObjects(image: ImageData, confidenceThreshold: number = 0.5): Promise<DetectionResult> {
    if (!this.available) {
      throw new Error('HiAI服务不可用');
    }

    this.validateImage(image);

    const scheduler = ResourceScheduler.getInstance();
    let acquired = false;

    try {
      acquired = await scheduler.acquireNPU(EngineType.HIAI);

      const startTime = Date.now();

      const objects: DetectedObject[] = await this.simulateObjectDetection(image);

      objects.forEach(obj => {
        obj.needsManualConfirm = obj.confidence < 0.5;
      });

      const filteredObjects = objects.filter(obj => obj.confidence >= confidenceThreshold);

      const result: DetectionResult = {
        objects: filteredObjects,
        imageWidth: image.width,
        imageHeight: image.height,
        latency: Date.now() - startTime
      };

      return result;
    } finally {
      if (acquired) {
        scheduler.releaseNPU(EngineType.HIAI);
      }
    }
  }

  async detectPose(image: ImageData): Promise<PoseResult> {
    if (!this.available) {
      throw new Error('HiAI服务不可用');
    }

    this.validateImage(image);

    const scheduler = ResourceScheduler.getInstance();
    let acquired = false;

    try {
      acquired = await scheduler.acquireNPU(EngineType.HIAI);

      const startTime = Date.now();

      const keypoints: Keypoint[] = await this.simulatePoseDetection(image);

      const result: PoseResult = {
        keypoints,
        score: 0.85,
        latency: Date.now() - startTime
      };

      return result;
    } finally {
      if (acquired) {
        scheduler.releaseNPU(EngineType.HIAI);
      }
    }
  }

  async enhanceImage(image: ImageData, options: EnhanceOptions): Promise<ImageData> {
    if (!this.available) {
      throw new Error('HiAI服务不可用');
    }

    this.validateImage(image);

    const scheduler = ResourceScheduler.getInstance();
    let acquired = false;

    try {
      acquired = await scheduler.acquireNPU(EngineType.HIAI);

      const startTime = Date.now();
      console.info('HiAIAdapter: 开始图像增强', options);

      const enhancedImage: ImageData = {
        uri: image.uri,
        pixelMap: image.pixelMap,
        width: options.superResolution ? image.width * (options.scaleFactor || 2) : image.width,
        height: options.superResolution ? image.height * (options.scaleFactor || 2) : image.height,
        format: image.format
      };

      console.info(`HiAIAdapter: 图像增强完成，耗时=${Date.now() - startTime}ms`);
      return enhancedImage;
    } finally {
      if (acquired) {
        scheduler.releaseNPU(EngineType.HIAI);
      }
    }
  }

  async recognizeText(image: ImageData, confidenceThreshold: number = 0.7): Promise<OCRResult> {
    if (!this.available) {
      throw new Error('HiAI服务不可用');
    }

    this.validateImage(image);

    const scheduler = ResourceScheduler.getInstance();
    let acquired = false;

    try {
      acquired = await scheduler.acquireNPU(EngineType.HIAI);

      const startTime = Date.now();

      const texts: OCRTextItem[] = await this.simulateOCR(image);

      texts.forEach(text => {
        text.needsManualCheck = text.confidence < confidenceThreshold;
      });

      const fullText = texts.map(t => t.text).join(' ');

      const result: OCRResult = {
        texts,
        fullText,
        latency: Date.now() - startTime
      };

      return result;
    } finally {
      if (acquired) {
        scheduler.releaseNPU(EngineType.HIAI);
      }
    }
  }

  async classifyImage(image: ImageData): Promise<ClassificationResult> {
    if (!this.available) {
      throw new Error('HiAI服务不可用');
    }

    this.validateImage(image);

    const scheduler = ResourceScheduler.getInstance();
    let acquired = false;

    try {
      acquired = await scheduler.acquireNPU(EngineType.HIAI);

      const startTime = Date.now();

      const classes: ClassItem[] = [
        { classId: 1, className: '古籍扫描件', confidence: 0.92 },
        { classId: 2, className: '手写处方', confidence: 0.05 },
        { classId: 3, className: '医学影像', confidence: 0.03 }
      ];

      const result: ClassificationResult = {
        classes,
        topClass: classes[0],
        latency: Date.now() - startTime
      };

      return result;
    } finally {
      if (acquired) {
        scheduler.releaseNPU(EngineType.HIAI);
      }
    }
  }

  private validateImage(image: ImageData): void {
    if (!image || (!image.uri && !image.pixelMap)) {
      throw new Error('图像数据无效');
    }

    if (image.format === ImageFormat.UNKNOWN) {
      throw new Error('不支持的图像格式');
    }
  }

  private async simulateObjectDetection(image: ImageData): Promise<DetectedObject[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve([
          { classId: 1, className: '人体', confidence: 0.95, bbox: { x: 100, y: 100, width: 200, height: 300 } },
          { classId: 2, className: '文字区域', confidence: 0.88, bbox: { x: 50, y: 400, width: 300, height: 50 } }
        ]);
      }, 100);
    });
  }

  private async simulatePoseDetection(image: ImageData): Promise<Keypoint[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        const keypoints: Keypoint[] = KEYPOINT_NAMES.map((name: string, index: number): Keypoint => {
          return {
            id: index,
            name: name,
            x: 100 + Math.random() * 100,
            y: 100 + Math.random() * 200,
            score: 0.8 + Math.random() * 0.2,
            visible: true
          };
        });
        resolve(keypoints);
      }, 80);
    });
  }

  private async simulateOCR(image: ImageData): Promise<OCRTextItem[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve([
          { text: '伤寒论', confidence: 0.95, bbox: { x: 50, y: 50, width: 100, height: 30 } },
          { text: '张仲景', confidence: 0.88, bbox: { x: 50, y: 90, width: 80, height: 30 } }
        ]);
      }, 120);
    });
  }
}
