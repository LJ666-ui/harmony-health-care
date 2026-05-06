 # 技术设计文档

## 文档信息
- **功能名称**: 古医图AI复原增强系统
- **版本**: v1.0
- **创建日期**: 2025-01-20
- **最后更新**: 2025-01-20
- **设计负责人**: AI开发团队

---

## 1. 设计概述

### 1.1 设计目标
- 实现完整的8阶段图像处理流水线，支持古医图AI复原增强
- 构建类型安全、可扩展的核心引擎架构
- 提供流畅的用户交互体验，支持实时进度反馈
- 实现与后端数据库的完整集成
- 支持批量处理和结果缓存优化

### 1.2 设计原则
- **单一职责原则**：每个处理模块只负责一个处理阶段
- **开闭原则**：处理流水线支持扩展新的处理阶段
- **依赖倒置原则**：高层引擎依赖抽象接口，不依赖具体实现
- **类型安全**：严格使用TypeScript类型系统，禁止any类型
- **性能优先**：使用缓存、懒加载、并发控制优化性能

### 1.3 技术选型
| 技术项 | 选择 | 理由 |
|--------|------|------|
| 开发平台 | HarmonyOS Next | 项目统一平台 |
| 开发语言 | ArkTS | HarmonyOS官方语言，TypeScript超集 |
| UI框架 | ArkUI声明式 | 高性能、类型安全 |
| 图像处理 | Canvas API | 模拟AI算法，无需真实模型 |
| 状态管理 | @State/@Link | ArkUI响应式状态管理 |
| 网络请求 | HttpUtil | 项目统一封装 |
| 数据Mock | Mock系统 | 开发阶段数据模拟 |

---

## 2. 系统架构

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                      用户界面层 (UI Layer)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ImageRestora- │  │ImageCompare- │  │AnnotationEd- │      │
│  │  tionPage    │  │    Page      │  │  itorPage    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    业务逻辑层 (Business Layer)                │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         ImageRestorationEngine (单例)                 │  │
│  │  - processImage()      - batchProcess()              │  │
│  │  - getProgress()       - cancelProcess()             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    处理引擎层 (Processing Layer)              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │Preprocess│→│ Denoiser │→│Deblurrer │→│SuperRes  │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│       ↓            ↓            ↓            ↓              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ColorRest │→│DetailEnh │→│OCRService│→│Annotation│      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    数据访问层 (Data Access Layer)             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  ApiService  │  │ CacheManager │  │ ReportGener- │      │
│  │              │  │              │  │    ator      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    基础设施层 (Infrastructure Layer)          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   HttpUtil   │  │  ToastUtil   │  │ PermissionM- │      │
│  │              │  │              │  │   anager     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 模块划分

| 模块名称 | 职责 | 文件路径 |
|----------|------|----------|
| ImageRestorationEngine | 核心处理引擎，协调各处理阶段 | ancientimage/ImageRestorationEngine.ets |
| ImagePreprocessor | 图像预处理（格式转换、尺寸调整） | ancientimage/ImagePreprocessor.ets |
| SuperResolutionProcessor | 超分辨率处理，提升图像清晰度 | ancientimage/SuperResolutionProcessor.ets |
| ColorRestorer | 颜色恢复，修复褪色问题 | ancientimage/ColorRestorer.ets |
| AncientOCRService | OCR文字识别服务 | ancientimage/AncientOCRService.ets |
| AnnotationEngine | 智能标注引擎 | ancientimage/AnnotationEngine.ets |
| ReportGenerator | 处理报告生成器 | ancientimage/ReportGenerator.ets |
| ImageRestorationPage | 主页面UI | pages/ImageRestorationPage.ets |
| ImageComparePage | 图片对比页面 | pages/ImageComparePage.ets |
| AnnotationEditorPage | 标注编辑页面 | pages/AnnotationEditorPage.ets |

### 2.3 数据流

```
用户上传图片
    ↓
[ImageRestorationPage] 接收用户输入
    ↓
[ImageRestorationEngine] 启动处理流水线
    ↓
[ImagePreprocessor] 预处理 → 生成标准格式图像
    ↓
[Denoiser] 降噪处理 → 去除噪点
    ↓
[Deblurrer] 去模糊处理 → 恢复清晰度
    ↓
[SuperResolutionProcessor] 超分辨率 → 提升分辨率
    ↓
[ColorRestorer] 颜色恢复 → 修复褪色
    ↓
[DetailEnhancer] 细节增强 → 强化细节
    ↓
[AncientOCRService] OCR识别 → 提取文字
    ↓
[AnnotationEngine] 智能标注 → 生成标注
    ↓
[ReportGenerator] 生成报告 → 汇总结果
    ↓
[ApiService] 保存到数据库
    ↓
[ImageRestorationPage] 显示处理结果
```

---

## 3. 核心模块设计

### 3.1 ImageRestorationEngine（核心引擎）

#### 3.1.1 职责定义
- 作为系统核心，协调所有处理阶段
- 管理处理任务队列和并发控制
- 提供进度回调和结果缓存
- 支持批量处理和任务取消

#### 3.1.2 接口设计
```typescript
/**
 * 图像复原引擎接口
 */
export interface IImageRestorationEngine {
  /**
   * 处理单张图片
   * @param imageId 图片ID
   * @param params 处理参数
   * @param progressCallback 进度回调
   * @returns 处理结果
   */
  processImage(
    imageId: number,
    params: ProcessingParams,
    progressCallback?: ProgressCallback
  ): Promise<ProcessingResult>;

  /**
   * 批量处理图片
   * @param imageIds 图片ID数组
   * @param params 处理参数
   * @param batchProgressCallback 批量进度回调
   * @returns 批量处理结果
   */
  batchProcess(
    imageIds: number[],
    params: ProcessingParams,
    batchProgressCallback?: BatchProgressCallback
  ): Promise<BatchProcessingResult>;

  /**
   * 获取处理进度
   * @param taskId 任务ID
   * @returns 当前进度
   */
  getProgress(taskId: string): ProcessingProgress | null;

  /**
   * 取消处理任务
   * @param taskId 任务ID
   */
  cancelProcess(taskId: string): void;

  /**
   * 获取缓存结果
   * @param imageId 图片ID
   * @returns 缓存的处理结果
   */
  getCachedResult(imageId: number): ProcessingResult | null;
}

/**
 * 进度回调函数类型
 */
export type ProgressCallback = (progress: ProcessingProgress) => void;

/**
 * 批量进度回调函数类型
 */
export type BatchProgressCallback = (batchProgress: BatchProgress) => void;
```

#### 3.1.3 类设计
```typescript
/**
 * 图像复原引擎（单例模式）
 */
export class ImageRestorationEngine implements IImageRestorationEngine {
  private static instance: ImageRestorationEngine | null = null;
  
  // 处理器实例
  private preprocessor: ImagePreprocessor;
  private denoiser: Denoiser;
  private deblurrer: Deblurrer;
  private superResolutionProcessor: SuperResolutionProcessor;
  private colorRestorer: ColorRestorer;
  private detailEnhancer: DetailEnhancer;
  private ocrService: AncientOCRService;
  private annotationEngine: AnnotationEngine;
  private reportGenerator: ReportGenerator;
  
  // 任务管理
  private activeTasks: Map<string, ProcessingTask> = new Map();
  private resultCache: Map<number, ProcessingResult> = new Map();
  private maxConcurrency: number = 3;
  
  private constructor() {
    // 初始化各处理器
    this.preprocessor = new ImagePreprocessor();
    this.denoiser = new Denoiser();
    this.deblurrer = new Deblurrer();
    this.superResolutionProcessor = new SuperResolutionProcessor();
    this.colorRestorer = new ColorRestorer();
    this.detailEnhancer = new DetailEnhancer();
    this.ocrService = new AncientOCRService();
    this.annotationEngine = new AnnotationEngine();
    this.reportGenerator = new ReportGenerator();
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): ImageRestorationEngine {
    if (!ImageRestorationEngine.instance) {
      ImageRestorationEngine.instance = new ImageRestorationEngine();
    }
    return ImageRestorationEngine.instance;
  }
  
  /**
   * 处理单张图片（实现接口方法）
   */
  public async processImage(
    imageId: number,
    params: ProcessingParams,
    progressCallback?: ProgressCallback
  ): Promise<ProcessingResult> {
    // 检查缓存
    const cached = this.getCachedResult(imageId);
    if (cached) {
      return cached;
    }
    
    const taskId = `task_${imageId}_${Date.now()}`;
    const startTime = Date.now();
    
    try {
      // 执行8阶段处理流水线
      let currentImage = await this.loadImage(imageId);
      const stageResults: StageResult[] = [];
      
      // 阶段1: 预处理
      this.updateProgress(taskId, 0, '预处理', progressCallback);
      currentImage = await this.preprocessor.process(currentImage, params.preprocessing);
      stageResults.push(this.createStageResult('预处理', startTime));
      
      // 阶段2: 降噪
      this.updateProgress(taskId, 12.5, '降噪处理', progressCallback);
      currentImage = await this.denoiser.process(currentImage, params.denoising);
      stageResults.push(this.createStageResult('降噪', Date.now()));
      
      // ... 其他6个阶段类似
      
      // 生成处理报告
      const report = this.reportGenerator.generate(stageResults, params);
      
      // 构建结果
      const result: ProcessingResult = {
        success: true,
        imageId: imageId,
        restoredImageUrl: currentImage.url,
        processingTime: Date.now() - startTime,
        report: report,
        stageResults: stageResults
      };
      
      // 缓存结果
      this.resultCache.set(imageId, result);
      
      return result;
    } catch (error) {
      // 错误处理
      return {
        success: false,
        imageId: imageId,
        error: error as ProcessingError
      };
    }
  }
  
  // 其他方法实现...
}
```

#### 3.1.4 关键算法
**并发控制算法**：
```
算法：批量处理并发控制
输入：imageIds[], maxConcurrency
输出：BatchProcessingResult

1. 初始化任务队列 queue = imageIds
2. 初始化活跃任务列表 active = []
3. 初始化结果列表 results = []

4. WHILE queue不为空 OR active不为空:
   4.1 WHILE active.length < maxConcurrency AND queue不为空:
       4.1.1 taskId = queue.dequeue()
       4.1.2 启动异步任务 task = processImage(taskId)
       4.1.3 active.add(task)
   
   4.2 IF active不为空:
       4.2.1 等待任意一个任务完成 completed = await Promise.race(active)
       4.2.2 active.remove(completed)
       4.2.3 results.add(completed)
       4.2.4 更新批量进度回调

5. RETURN BatchProcessingResult(results)
```

### 3.2 ImagePreprocessor（图像预处理器）

#### 3.2.1 职责定义
- 图像格式转换（统一转为PNG）
- 尺寸标准化（保持宽高比，限制最大尺寸）
- 质量评估（计算初始质量分数）

#### 3.2.2 接口设计
```typescript
export interface IImagePreprocessor {
  /**
   * 预处理图像
   * @param image 输入图像
   * @param params 预处理参数
   * @returns 预处理后的图像
   */
  process(image: ImageData, params: PreprocessingParams): Promise<ImageData>;
  
  /**
   * 评估图像质量
   * @param image 输入图像
   * @returns 质量评估结果
   */
  assessQuality(image: ImageData): QualityAssessment;
}
```

#### 3.2.3 实现要点
```typescript
export class ImagePreprocessor implements IImagePreprocessor {
  public async process(
    image: ImageData,
    params: PreprocessingParams
  ): Promise<ImageData> {
    // 1. 格式转换
    let processed = await this.convertFormat(image, 'PNG');
    
    // 2. 尺寸调整
    if (params.maxSize) {
      processed = this.resizeImage(processed, params.maxSize);
    }
    
    // 3. 质量评估
    const quality = this.assessQuality(processed);
    processed.qualityScore = quality.overallScore;
    
    return processed;
  }
  
  private resizeImage(image: ImageData, maxSize: number): ImageData {
    const ratio = Math.min(maxSize / image.width, maxSize / image.height);
    if (ratio >= 1) return image;
    
    // 使用Canvas进行缩放
    const newWidth = Math.floor(image.width * ratio);
    const newHeight = Math.floor(image.height * ratio);
    // ... Canvas缩放实现
  }
  
  public assessQuality(image: ImageData): QualityAssessment {
    // 计算清晰度分数（基于边缘检测）
    const sharpnessScore = this.calculateSharpness(image);
    
    // 计算噪点分数
    const noiseScore = this.calculateNoiseLevel(image);
    
    // 计算对比度分数
    const contrastScore = this.calculateContrast(image);
    
    // 综合评分
    const overallScore = (sharpnessScore * 0.4 + 
                          (100 - noiseScore) * 0.3 + 
                          contrastScore * 0.3);
    
    return {
      sharpness: sharpnessScore,
      noise: noiseScore,
      contrast: contrastScore,
      overallScore: overallScore
    };
  }
}
```

### 3.3 SuperResolutionProcessor（超分辨率处理器）

#### 3.3.1 职责定义
- 提升图像分辨率（2x或4x）
- 保持图像细节不丢失
- 使用双三次插值算法模拟

#### 3.3.2 实现要点
```typescript
export class SuperResolutionProcessor {
  public async process(
    image: ImageData,
    params: SuperResolutionParams
  ): Promise<ImageData> {
    const scale = params.scale || 2; // 默认2倍放大
    
    // 使用双三次插值算法
    const upscaled = this.bicubicInterpolation(image, scale);
    
    // 应用锐化增强细节
    const sharpened = this.applySharpening(upscaled, params.sharpenStrength);
    
    return sharpened;
  }
  
  /**
   * 双三次插值算法
   */
  private bicubicInterpolation(image: ImageData, scale: number): ImageData {
    const newWidth = Math.floor(image.width * scale);
    const newHeight = Math.floor(image.height * scale);
    
    // 创建Canvas
    const canvas = this.createCanvas(newWidth, newHeight);
    const ctx = canvas.getContext('2d');
    
    // 设置高质量插值
    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = 'high';
    
    // 绘制放大后的图像
    ctx.drawImage(image, 0, 0, newWidth, newHeight);
    
    return this.canvasToImageData(canvas);
  }
}
```

### 3.4 AncientOCRService（OCR识别服务）

#### 3.4.1 职责定义
- 识别图像中的文字内容
- 返回文字位置坐标
- 高亮医学术语

#### 3.4.2 实现要点
```typescript
export class AncientOCRService {
  // 医学术语词典
  private medicalTerms: Set<string> = new Set([
    '气', '血', '阴', '阳', '经络', '穴位', '脉象',
    '肝', '心', '脾', '肺', '肾', '胆', '胃', '大肠', '小肠', '膀胱', '三焦',
    // ... 更多术语
  ]);
  
  public async recognize(image: ImageData): Promise<OCRResult> {
    // 模拟OCR识别过程
    const textBlocks = await this.detectTextBlocks(image);
    
    // 识别文字内容
    const recognizedTexts: RecognizedText[] = [];
    for (const block of textBlocks) {
      const text = await this.recognizeBlock(block);
      const isMedicalTerm = this.medicalTerms.has(text);
      
      recognizedTexts.push({
        text: text,
        boundingBox: block.boundingBox,
        confidence: 0.85 + Math.random() * 0.1, // 模拟置信度
        isMedicalTerm: isMedicalTerm
      });
    }
    
    return {
      fullText: recognizedTexts.map(t => t.text).join(''),
      textBlocks: recognizedTexts,
      medicalTermCount: recognizedTexts.filter(t => t.isMedicalTerm).length
    };
  }
  
  /**
   * 检测文字区域（模拟）
   */
  private async detectTextBlocks(image: ImageData): Promise<TextBlock[]> {
    // 使用边缘检测和连通域分析
    // 这里简化为模拟实现
    return this.simulateTextDetection(image);
  }
}
```

### 3.5 AnnotationEngine（智能标注引擎）

#### 3.5.1 职责定义
- 基于OCR结果生成标注
- 标注文字区域边界框
- 高亮医学术语
- 支持用户手动编辑

#### 3.5.2 实现要点
```typescript
export class AnnotationEngine {
  public generateAnnotations(ocrResult: OCRResult): ImageAnnotation[] {
    const annotations: ImageAnnotation[] = [];
    
    for (const textBlock of ocrResult.textBlocks) {
      const annotation: ImageAnnotation = {
        id: `anno_${Date.now()}_${Math.random()}`,
        type: AnnotationType.TEXT_BOX,
        boundingBox: textBlock.boundingBox,
        content: textBlock.text,
        style: this.getAnnotationStyle(textBlock),
        editable: true
      };
      
      annotations.push(annotation);
    }
    
    return annotations;
  }
  
  private getAnnotationStyle(textBlock: RecognizedText): AnnotationStyle {
    if (textBlock.isMedicalTerm) {
      return {
        borderColor: '#722ED1', // 紫色高亮医学术语
        backgroundColor: '#F9F0FF',
        textColor: '#722ED1',
        borderWidth: 2
      };
    }
    
    return {
      borderColor: '#52C41A', // 绿色普通文字
      backgroundColor: 'transparent',
      textColor: '#333333',
      borderWidth: 1
    };
  }
}
```

---

## 4. 数据模型设计

### 4.1 数据实体

#### 4.1.1 核心接口定义（21个）

```typescript
// ==================== 枚举定义 ====================

/**
 * 图片处理状态
 */
export enum ImageStatus {
  PENDING = 'PENDING',           // 等待处理
  PROCESSING = 'PROCESSING',     // 处理中
  COMPLETED = 'COMPLETED',       // 已完成
  FAILED = 'FAILED'              // 处理失败
}

/**
 * 处理阶段枚举
 */
export enum ProcessingStage {
  PREPROCESSING = 'PREPROCESSING',           // 预处理
  DENOISING = 'DENOISING',                   // 降噪
  DEBLURRING = 'DEBLURRING',                 // 去模糊
  SUPER_RESOLUTION = 'SUPER_RESOLUTION',     // 超分辨率
  COLOR_RESTORATION = 'COLOR_RESTORATION',   // 颜色恢复
  DETAIL_ENHANCEMENT = 'DETAIL_ENHANCEMENT', // 细节增强
  OCR_RECOGNITION = 'OCR_RECOGNITION',       // OCR识别
  ANNOTATION = 'ANNOTATION'                  // 智能标注
}

/**
 * 图片分类
 */
export enum ImageCategory {
  MEDICAL_CLASSICS = '中医典籍',
  ACUPUNCTURE_ATLAS = '针灸图谱',
  HERBAL_ATLAS = '本草图谱',
  PRESCRIPTION_ILLUSTRATION = '方剂配图'
}

/**
 * 标注类型
 */
export enum AnnotationType {
  TEXT_BOX = 'TEXT_BOX',         // 文字框
  HIGHLIGHT = 'HIGHLIGHT',       // 高亮区域
  NOTE = 'NOTE',                 // 备注
  MARKER = 'MARKER'              // 标记点
}

// ==================== 核心数据接口 ====================

/**
 * 古医图数据模型
 */
export interface AncientImage {
  id: number;
  originalUrl: string;           // 原图URL
  restoredUrl?: string;          // 复原图URL
  thumbnailUrl?: string;         // 缩略图URL
  title: string;                 // 标题
  description?: string;          // 描述
  category: ImageCategory;       // 分类
  dynasty?: string;              // 朝代
  source?: string;               // 来源
  status: ImageStatus;           // 处理状态
  qualityScore?: number;         // 质量分数(0-100)
  uploadTime: string;            // 上传时间
  processTime?: string;          // 处理时间
  metadata?: ImageMetadata;      // 元数据
}

/**
 * 图像元数据
 */
export interface ImageMetadata {
  width: number;                 // 宽度
  height: number;                // 高度
  format: string;                // 格式
  fileSize: number;              // 文件大小(字节)
  colorSpace?: string;           // 色彩空间
  dpi?: number;                  // 分辨率
}

/**
 * 处理参数配置
 */
export interface ProcessingParams {
  preprocessing?: PreprocessingParams;
  denoising?: DenoisingParams;
  deblurring?: DeblurringParams;
  superResolution?: SuperResolutionParams;
  colorRestoration?: ColorRestorationParams;
  detailEnhancement?: DetailEnhancementParams;
  ocr?: OCRParams;
  annotation?: AnnotationParams;
}

/**
 * 预处理参数
 */
export interface PreprocessingParams {
  maxSize?: number;              // 最大尺寸
  targetFormat?: string;         // 目标格式
  normalizeBrightness?: boolean; // 是否标准化亮度
}

/**
 * 降噪参数
 */
export interface DenoisingParams {
  strength: 'low' | 'medium' | 'high';  // 降噪强度
  preserveEdges: boolean;               // 是否保留边缘
}

/**
 * 去模糊参数
 */
export interface DeblurringParams {
  method: 'wiener' | 'richardson_lucy' | 'blind';  // 去模糊方法
  iterations: number;                              // 迭代次数
}

/**
 * 超分辨率参数
 */
export interface SuperResolutionParams {
  scale: 2 | 4;                  // 放大倍数
  sharpenStrength?: number;      // 锐化强度(0-1)
}

/**
 * 颜色恢复参数
 */
export interface ColorRestorationParams {
  method: 'histogram' | 'adaptive' | 'deep_learning';  // 恢复方法
  saturationBoost?: number;                             // 饱和度增强(0-2)
}

/**
 * 细节增强参数
 */
export interface DetailEnhancementParams {
  edgeEnhancement: boolean;      // 边缘增强
  textureEnhancement: boolean;   // 纹理增强
  strength: number;              // 增强强度(0-1)
}

/**
 * OCR参数
 */
export interface OCRParams {
  language: 'zh' | 'en' | 'mixed';  // 识别语言
  detectOrientation: boolean;       // 检测文字方向
}

/**
 * 标注参数
 */
export interface AnnotationParams {
  autoHighlight: boolean;        // 自动高亮医学术语
  showBoundingBox: boolean;      // 显示边界框
  minConfidence: number;         // 最小置信度阈值
}

/**
 * 处理进度
 */
export interface ProcessingProgress {
  taskId: string;                // 任务ID
  imageId: number;               // 图片ID
  currentStage: ProcessingStage; // 当前阶段
  stageName: string;             // 阶段名称
  progress: number;              // 进度百分比(0-100)
  elapsedTime: number;           // 已耗时(毫秒)
  estimatedRemaining: number;    // 预计剩余时间(毫秒)
}

/**
 * 处理结果
 */
export interface ProcessingResult {
  success: boolean;              // 是否成功
  imageId: number;               // 图片ID
  restoredImageUrl?: string;     // 复原图URL
  processingTime?: number;       // 处理耗时(毫秒)
  report?: ProcessingReport;     // 处理报告
  stageResults?: StageResult[];  // 各阶段结果
  error?: ProcessingError;       // 错误信息
}

/**
 * 处理报告
 */
export interface ProcessingReport {
  imageId: number;
  totalTime: number;             // 总耗时
  originalQuality: number;       // 原始质量分数
  restoredQuality: number;       // 复原后质量分数
  improvement: number;           // 改善程度
  stageDetails: StageDetail[];   // 各阶段详情
  params: ProcessingParams;      // 使用的参数
  timestamp: string;             // 时间戳
}

/**
 * 阶段详情
 */
export interface StageDetail {
  stage: ProcessingStage;
  name: string;
  duration: number;              // 耗时(毫秒)
  inputQuality: number;          // 输入质量
  outputQuality: number;         // 输出质量
  improvement: number;           // 改善程度
}

/**
 * 阶段结果
 */
export interface StageResult {
  stage: ProcessingStage;
  name: string;
  startTime: number;
  endTime: number;
  duration: number;
  success: boolean;
  error?: string;
}

/**
 * OCR识别结果
 */
export interface OCRResult {
  fullText: string;              // 完整文本
  textBlocks: RecognizedText[];  // 文字块
  medicalTermCount: number;      // 医学术语数量
}

/**
 * 识别的文字
 */
export interface RecognizedText {
  text: string;                  // 文字内容
  boundingBox: BoundingBox;      // 边界框
  confidence: number;            // 置信度(0-1)
  isMedicalTerm: boolean;        // 是否为医学术语
}

/**
 * 边界框
 */
export interface BoundingBox {
  x: number;                     // 左上角X坐标
  y: number;                     // 左上角Y坐标
  width: number;                 // 宽度
  height: number;                // 高度
}

/**
 * 图像标注
 */
export interface ImageAnnotation {
  id: string;                    // 标注ID
  type: AnnotationType;          // 标注类型
  boundingBox: BoundingBox;      // 边界框
  content?: string;              // 标注内容
  style: AnnotationStyle;        // 样式
  editable: boolean;             // 是否可编辑
}

/**
 * 标注样式
 */
export interface AnnotationStyle {
  borderColor: string;           // 边框颜色
  backgroundColor: string;       // 背景颜色
  textColor: string;             // 文字颜色
  borderWidth: number;           // 边框宽度
  fontSize?: number;             // 字体大小
}

/**
 * 批量处理进度
 */
export interface BatchProgress {
  totalTasks: number;            // 总任务数
  completedTasks: number;        // 已完成任务数
  failedTasks: number;           // 失败任务数
  currentTask?: ProcessingProgress;  // 当前任务进度
  overallProgress: number;       // 总体进度(0-100)
}

/**
 * 批量处理结果
 */
export interface BatchProcessingResult {
  success: boolean;
  totalImages: number;
  successCount: number;
  failedCount: number;
  results: ProcessingResult[];
  totalTime: number;
}

/**
 * 处理错误
 */
export interface ProcessingError {
  code: string;                  // 错误代码
  message: string;               // 错误消息
  stage?: ProcessingStage;       // 发生错误的阶段
  details?: string;              // 详细信息
}

/**
 * 质量评估结果
 */
export interface QualityAssessment {
  sharpness: number;             // 清晰度分数(0-100)
  noise: number;                 // 噪点分数(0-100)
  contrast: number;              // 对比度分数(0-100)
  overallScore: number;          // 综合分数(0-100)
}

/**
 * 图像数据（处理中间结果）
 */
export interface ImageData {
  url: string;                   // 图像URL
  width: number;                 // 宽度
  height: number;                // 高度
  data?: PixelData;              // 像素数据
  qualityScore?: number;         // 质量分数
}

/**
 * 像素数据
 */
export interface PixelData {
  data: Uint8ClampedArray;       // 像素数组(RGBA)
  width: number;
  height: number;
}
```

### 4.2 数据存储

| 数据实体 | 存储位置 | 存储方式 | 说明 |
|----------|----------|----------|------|
| AncientImage | 后端数据库 | MySQL/PostgreSQL | 图片元数据 |
| 原图文件 | 对象存储 | OSS/MinIO | 原始图片文件 |
| 复原图文件 | 对象存储 | OSS/MinIO | 处理后图片 |
| ProcessingReport | 后端数据库 | JSON字段 | 处理报告 |
| ProcessingResult | 内存缓存 | Map<number, Result> | 临时缓存 |
| ImageAnnotation | 后端数据库 | JSON字段 | 标注数据 |

### 4.3 数据访问

```typescript
/**
 * 古医图数据访问接口
 */
export interface IAncientImageRepository {
  // 查询操作
  findById(id: number): Promise<AncientImage | null>;
  findAll(params: QueryParams): Promise<PaginatedResult<AncientImage>>;
  findByCategory(category: ImageCategory): Promise<AncientImage[]>;
  
  // 创建操作
  create(image: Omit<AncientImage, 'id'>): Promise<AncientImage>;
  
  // 更新操作
  update(id: number, updates: Partial<AncientImage>): Promise<AncientImage>;
  updateStatus(id: number, status: ImageStatus): Promise<void>;
  updateRestoredUrl(id: number, url: string): Promise<void>;
  
  // 删除操作
  delete(id: number): Promise<void>;
}
```

---

## 5. API 设计

### 5.1 内部 API（模块间调用）

```typescript
// ImageRestorationEngine API
engine.processImage(imageId, params, callback): Promise<ProcessingResult>
engine.batchProcess(imageIds, params, callback): Promise<BatchProcessingResult>
engine.getProgress(taskId): ProcessingProgress | null
engine.cancelProcess(taskId): void
engine.getCachedResult(imageId): ProcessingResult | null

// 处理器API
preprocessor.process(image, params): Promise<ImageData>
denoiser.process(image, params): Promise<ImageData>
deblurrer.process(image, params): Promise<ImageData>
superResolution.process(image, params): Promise<ImageData>
colorRestorer.process(image, params): Promise<ImageData>
detailEnhancer.process(image, params): Promise<ImageData>
ocrService.recognize(image): Promise<OCRResult>
annotationEngine.generateAnnotations(ocrResult): ImageAnnotation[]

// 报告生成API
reportGenerator.generate(stageResults, params): ProcessingReport
```

### 5.2 外部 API（后端接口）

| 接口名称 | 方法 | 路径 | 说明 |
|----------|------|------|------|
| 获取图片列表 | GET | /ancient-image/list | 分页查询图片列表 |
| 获取图片详情 | GET | /ancient-image/detail/{id} | 查询单张图片 |
| 上传图片 | POST | /ancient-image/upload | 上传新图片 |
| 启动复原 | POST | /ancient-image/{id}/restore | 启动AI复原处理 |
| 查询处理状态 | GET | /ancient-image/{id}/status | 查询处理进度 |
| 删除图片 | DELETE | /ancient-image/{id} | 删除图片 |
| 更新标注 | PUT | /ancient-image/{id}/annotations | 更新标注数据 |

**请求/响应示例**：

```typescript
// GET /ancient-image/list?page=1&size=20
interface ListResponse {
  success: boolean;
  data: {
    records: AncientImage[];
    total: number;
    page: number;
    size: number;
  };
}

// POST /ancient-image/upload
interface UploadRequest {
  file: File;              // 图片文件
  title: string;           // 标题
  description?: string;    // 描述
  category: ImageCategory; // 分类
}
interface UploadResponse {
  success: boolean;
  data: AncientImage;
}

// POST /ancient-image/{id}/restore
interface RestoreResponse {
  success: boolean;
  data: {
    taskId: string;
    estimatedTime: string;
  };
}
```

---

## 6. UI 设计

### 6.1 页面结构

```
ImageRestorationPage (主页面)
├── Header (标题栏)
├── CategoryTabs (分类筛选)
├── ImageList (图片列表)
│   └── ImageCard (图片卡片)
│       ├── ImagePreview (图片预览)
│       ├── StatusBadge (状态徽章)
│       ├── ProcessingProgress (处理进度)
│       └── ActionButtons (操作按钮)
├── UploadDialog (上传对话框)
│   ├── ImageSelector (图片选择器)
│   ├── TitleInput (标题输入)
│   ├── DescriptionInput (描述输入)
│   ├── CategorySelector (分类选择)
│   └── UploadButton (上传按钮)
└── CompareDialog (对比对话框)
    ├── BeforeAfterSlider (前后对比滑块)
    └── DownloadButton (下载按钮)

ImageComparePage (对比页面)
├── Header
├── BeforeAfterSlider (滑动对比组件)
└── AnnotationOverlay (标注叠加层)

AnnotationEditorPage (标注编辑页面)
├── Header
├── ImageViewer (图片查看器)
├── AnnotationList (标注列表)
└── AnnotationEditor (标注编辑器)
```

### 6.2 组件设计

#### 6.2.1 ImageCard（图片卡片）
```typescript
@Component
export struct ImageCard {
  @Prop image: AncientImage;
  @State isProcessing: boolean = false;
  
  private onRestoreClick: () => void;
  private onCompareClick: () => void;
  private onDeleteClick: () => void;
  
  build() {
    Column() {
      // 图片预览
      this.buildImagePreview();
      
      // 标题和描述
      this.buildImageInfo();
      
      // 处理进度（如果正在处理）
      if (this.image.status === ImageStatus.PROCESSING) {
        this.buildProgressBar();
      }
      
      // 操作按钮
      this.buildActionButtons();
    }
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#00000008' });
  }
}
```

#### 6.2.2 BeforeAfterSlider（前后对比滑块）
```typescript
@Component
export struct BeforeAfterSlider {
  @Prop beforeImage: string;
  @Prop afterImage: string;
  @State sliderPosition: number = 0.5; // 0-1
  
  build() {
    Stack() {
      // 原图（底层）
      Image(this.beforeImage)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain);
      
      // 复原图（上层，带裁剪）
      Image(this.afterImage)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .clip(new Rect({
          x: 0,
          y: 0,
          width: this.sliderPosition * 100 + '%',
          height: '100%'
        }));
      
      // 滑动分割线
      this.buildSliderLine();
    }
    .width('100%')
    .height(300)
    .gesture(
      PanGesture()
        .onActionUpdate((event: GestureEvent) => {
          this.sliderPosition = this.calculatePosition(event);
        })
    );
  }
}
```

#### 6.2.3 ProcessingProgressBar（处理进度条）
```typescript
@Component
export struct ProcessingProgressBar {
  @Prop progress: ProcessingProgress;
  
  build() {
    Column({ space: 8 }) {
      // 阶段名称
      Text(this.progress.stageName + '...')
        .fontSize(12)
        .fontColor('#722ED1');
      
      // 进度条
      Row() {
        Progress({
          value: this.progress.progress,
          total: 100,
          type: ProgressType.Linear
        })
          .width('80%')
          .color('#722ED1');
        
        Text(this.progress.progress.toFixed(0) + '%')
          .fontSize(12)
          .fontColor('#722ED1');
      }
      .width('100%');
      
      // 预计剩余时间
      Text('预计剩余: ' + this.formatTime(this.progress.estimatedRemaining))
        .fontSize(10)
        .fontColor('#999999');
    }
    .width('100%')
    .padding(12);
  }
}
```

### 6.3 状态管理

```typescript
@Entry
@Component
struct ImageRestorationPage {
  // 全局状态
  @StorageLink('isOldModeEnabled') isElderMode: boolean = false;
  
  // 页面状态
  @State images: AncientImage[] = [];
  @State currentCategory: ImageCategory | 'ALL' = 'ALL';
  @State isLoading: boolean = false;
  
  // 对话框状态
  @State showUploadDialog: boolean = false;
  @State showCompareDialog: boolean = false;
  @State selectedImage: AncientImage | null = null;
  
  // 处理状态
  @State processingTasks: Map<number, ProcessingProgress> = new Map();
  
  // 分页状态
  @State currentPage: number = 1;
  @State totalImages: number = 0;
  
  // 生命周期
  aboutToAppear() {
    this.loadImageList();
    this.subscribeToProcessingEvents();
  }
  
  aboutToDisappear() {
    this.unsubscribeFromProcessingEvents();
  }
  
  // 数据加载
  async loadImageList() {
    this.isLoading = true;
    try {
      const response = await ApiService.getAncientImages({
        page: this.currentPage,
        category: this.currentCategory
      });
      this.images = response.data.records;
      this.totalImages = response.data.total;
    } finally {
      this.isLoading = false;
    }
  }
  
  // 处理事件订阅
  private subscribeToProcessingEvents() {
    // 订阅处理进度更新事件
    EventBus.on('processing-progress', (progress: ProcessingProgress) => {
      this.processingTasks.set(progress.imageId, progress);
    });
  }
}
```

---

## 7. 性能设计

### 7.1 性能目标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| 单张图片处理时间 | < 30秒 | 8阶段总耗时 |
| UI响应时间 | < 200ms | 用户操作响应 |
| 进度更新延迟 | < 100ms | 进度回调延迟 |
| 批量处理并发数 | 3 | 同时处理图片数 |
| 缓存命中率 | > 80% | 重复请求缓存命中 |
| 内存占用 | < 200MB | 单次处理内存峰值 |

### 7.2 优化策略

#### 7.2.1 处理优化
- **并发控制**：批量处理时限制并发数为3，避免资源竞争
- **结果缓存**：使用Map缓存已处理结果，避免重复处理
- **增量处理**：支持断点续传，从中断阶段继续处理
- **任务队列**：使用队列管理处理任务，支持优先级调度

#### 7.2.2 UI优化
- **懒加载**：图片列表使用懒加载，滚动时动态加载
- **虚拟滚动**：大列表使用虚拟滚动，减少DOM节点
- **状态精确控制**：使用@State/@Prop精确控制重渲染范围
- **防抖节流**：进度更新使用节流，避免频繁重渲染

#### 7.2.3 内存优化
- **及时释放**：处理完成后及时释放中间图像数据
- **弱引用缓存**：使用WeakMap存储缓存，允许GC回收
- **分块处理**：大图像分块处理，降低内存峰值

#### 7.2.4 网络优化
- **请求合并**：批量查询合并为单次请求
- **数据压缩**：上传图片前进行压缩
- **断点续传**：支持网络中断后继续上传

---

## 8. 安全设计

### 8.1 安全措施

#### 8.1.1 数据安全
- **传输加密**：所有API请求使用HTTPS
- **文件验证**：上传文件验证类型和大小，防止恶意文件
- **数据脱敏**：敏感信息（如用户ID）进行脱敏处理

#### 8.1.2 权限控制
```typescript
// 权限检查
async function checkAndRequestPermission(): Promise<boolean> {
  const permission = 'ohos.permission.READ_MEDIA';
  
  // 检查权限
  const granted = await PermissionManager.check(permission);
  if (granted) {
    return true;
  }
  
  // 请求权限
  const result = await PermissionManager.request(permission);
  return result;
}
```

#### 8.1.3 输入验证
```typescript
// 文件验证
function validateImageFile(file: File): ValidationResult {
  // 验证文件类型
  const allowedTypes = ['image/jpeg', 'image/png'];
  if (!allowedTypes.includes(file.type)) {
    return { valid: false, error: '不支持的文件格式' };
  }
  
  // 验证文件大小（最大10MB）
  const maxSize = 10 * 1024 * 1024;
  if (file.size > maxSize) {
    return { valid: false, error: '文件大小超过限制' };
  }
  
  return { valid: true };
}

// 标题验证
function validateTitle(title: string): ValidationResult {
  if (!title || title.trim().length === 0) {
    return { valid: false, error: '标题不能为空' };
  }
  
  if (title.length > 100) {
    return { valid: false, error: '标题长度不能超过100字符' };
  }
  
  return { valid: true };
}
```

### 8.2 权限设计

| 权限名称 | 用途 | 何时请求 |
|----------|------|----------|
| ohos.permission.READ_MEDIA | 读取相册图片 | 用户点击"从相册选择"时 |
| ohos.permission.WRITE_MEDIA | 保存图片到相册 | 用户点击"保存图片"时 |
| ohos.permission.INTERNET | 网络请求 | 应用启动时 |

---

## 9. 异常处理

### 9.1 异常分类

```typescript
/**
 * 处理错误类型
 */
export enum ProcessingErrorCode {
  // 网络错误
  NETWORK_ERROR = 'NETWORK_ERROR',
  TIMEOUT_ERROR = 'TIMEOUT_ERROR',
  
  // 文件错误
  FILE_NOT_FOUND = 'FILE_NOT_FOUND',
  INVALID_FILE_FORMAT = 'INVALID_FILE_FORMAT',
  FILE_TOO_LARGE = 'FILE_TOO_LARGE',
  
  // 处理错误
  PROCESSING_FAILED = 'PROCESSING_FAILED',
  STAGE_FAILED = 'STAGE_FAILED',
  OUT_OF_MEMORY = 'OUT_OF_MEMORY',
  
  // 权限错误
  PERMISSION_DENIED = 'PERMISSION_DENIED',
  
  // 业务错误
  IMAGE_NOT_FOUND = 'IMAGE_NOT_FOUND',
  ALREADY_PROCESSING = 'ALREADY_PROCESSING'
}
```

### 9.2 处理策略

```typescript
/**
 * 统一错误处理
 */
export class ErrorHandler {
  public static handle(error: ProcessingError): void {
    switch (error.code) {
      case ProcessingErrorCode.NETWORK_ERROR:
        ToastUtil.showError('网络连接失败，请检查网络');
        break;
        
      case ProcessingErrorCode.PERMISSION_DENIED:
        this.showPermissionDialog();
        break;
        
      case ProcessingErrorCode.FILE_TOO_LARGE:
        ToastUtil.showError('文件大小超过限制（最大10MB）');
        break;
        
      case ProcessingErrorCode.PROCESSING_FAILED:
        ToastUtil.showError('处理失败: ' + error.message);
        this.logError(error);
        break;
        
      default:
        ToastUtil.showError('操作失败，请重试');
        this.logError(error);
    }
  }
  
  private static showPermissionDialog(): void {
    promptAction.showDialog({
      title: '需要权限',
      message: '需要访问相册权限才能选择图片',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '前往设置', color: '#1677FF' }
      ]
    });
  }
  
  private static logError(error: ProcessingError): void {
    console.error('[ProcessingError]', JSON.stringify(error));
  }
}
```

---

## 10. 测试设计

### 10.1 测试策略

| 测试类型 | 覆盖范围 | 工具 |
|----------|----------|------|
| 单元测试 | 核心算法、工具函数 | Jest |
| 集成测试 | 模块间交互、API调用 | Jest + Mock |
| UI测试 | 页面交互、组件渲染 | 集成测试框架 |
| 性能测试 | 处理性能、内存占用 | 性能分析工具 |

### 10.2 测试用例

#### 10.2.1 单元测试用例

```typescript
// ImagePreprocessor.test.ets
describe('ImagePreprocessor', () => {
  it('should_resize_image_correctly', async () => {
    const preprocessor = new ImagePreprocessor();
    const image = createTestImage(2000, 1500);
    
    const result = await preprocessor.process(image, {
      maxSize: 1000
    });
    
    expect(result.width).toBeLessThanOrEqual(1000);
    expect(result.height).toBeLessThanOrEqual(1000);
    expect(result.width / result.height).toBeCloseTo(2000 / 1500);
  });
  
  it('should_calculate_quality_score_correctly', () => {
    const preprocessor = new ImagePreprocessor();
    const blurryImage = createBlurryImage();
    const sharpImage = createSharpImage();
    
    const blurryScore = preprocessor.assessQuality(blurryImage);
    const sharpScore = preprocessor.assessQuality(sharpImage);
    
    expect(blurryScore.sharpness).toBeLessThan(sharpScore.sharpness);
  });
});

// ImageRestorationEngine.test.ets
describe('ImageRestorationEngine', () => {
  it('should_return_singleton_instance', () => {
    const instance1 = ImageRestorationEngine.getInstance();
    const instance2 = ImageRestorationEngine.getInstance();
    
    expect(instance1).toBe(instance2);
  });
  
  it('should_return_cached_result_for_same_image', async () => {
    const engine = ImageRestorationEngine.getInstance();
    const imageId = 1;
    const params = createDefaultParams();
    
    const result1 = await engine.processImage(imageId, params);
    const result2 = await engine.processImage(imageId, params);
    
    expect(result1).toBe(result2);
  });
  
  it('should_process_batch_with_concurrency_limit', async () => {
    const engine = ImageRestorationEngine.getInstance();
    const imageIds = [1, 2, 3, 4, 5, 6];
    
    const startTime = Date.now();
    const result = await engine.batchProcess(imageIds, defaultParams);
    const duration = Date.now() - startTime;
    
    // 验证并发数为3
    expect(result.success).toBe(true);
    expect(duration).toBeLessThan(60000); // 应在60秒内完成
  });
});
```

#### 10.2.2 集成测试用例

```typescript
// API集成测试
describe('AncientImageAPI', () => {
  it('should_upload_and_process_image_successfully', async () => {
    // 1. 上传图片
    const uploadResponse = await ApiService.uploadImage({
      file: testImageFile,
      title: '测试图片',
      category: ImageCategory.MEDICAL_CLASSICS
    });
    
    expect(uploadResponse.success).toBe(true);
    expect(uploadResponse.data.id).toBeDefined();
    
    // 2. 启动处理
    const restoreResponse = await ApiService.startRestore(uploadResponse.data.id);
    expect(restoreResponse.success).toBe(true);
    
    // 3. 等待处理完成
    await waitForProcessing(uploadResponse.data.id, 30000);
    
    // 4. 验证结果
    const detailResponse = await ApiService.getImageDetail(uploadResponse.data.id);
    expect(detailResponse.data.status).toBe(ImageStatus.COMPLETED);
    expect(detailResponse.data.restoredUrl).toBeDefined();
  });
});
```

---

## 11. 部署设计

### 11.1 部署架构

```
┌─────────────────────────────────────────┐
│         HarmonyOS 设备                   │
│  ┌───────────────────────────────────┐  │
│  │   古医图AI复原应用                  │  │
│  │  - UI层                            │  │
│  │  - 业务逻辑层                       │  │
│  │  - 处理引擎层（Canvas模拟）          │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
              ↓ HTTPS
┌─────────────────────────────────────────┐
│         后端服务器                       │
│  ┌───────────────────────────────────┐  │
│  │   API服务                          │  │
│  │  - 图片上传/下载                    │  │
│  │  - 数据库CRUD                       │  │
│  │  - 任务调度                         │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │   对象存储                          │  │
│  │  - 原图存储                         │  │
│  │  - 复原图存储                       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │   数据库                            │  │
│  │  - 图片元数据                       │  │
│  │  - 处理报告                         │  │
│  │  - 标注数据                         │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 11.2 配置管理

```typescript
// config.ets
export class AppConfig {
  // API配置
  static readonly API_BASE_URL = 'https://api.example.com';
  static readonly API_TIMEOUT = 30000; // 30秒
  
  // 处理配置
  static readonly MAX_CONCURRENCY = 3;
  static readonly MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
  static readonly SUPPORTED_FORMATS = ['image/jpeg', 'image/png'];
  
  // 缓存配置
  static readonly CACHE_MAX_SIZE = 100; // 最多缓存100个结果
  static readonly CACHE_EXPIRE_TIME = 3600000; // 1小时
  
  // UI配置
  static readonly PAGE_SIZE = 20; // 每页20条
  static readonly ELDER_MODE_FONT_SIZE = 18;
  static readonly NORMAL_MODE_FONT_SIZE = 14;
}
```

---

## 12. 附录

### 12.1 术语表

| 术语 | 定义 |
|------|------|
| 流水线 | 按顺序执行的多阶段处理流程 |
| 超分辨率 | 通过算法提升图像分辨率的技术 |
| 双三次插值 | 一种高质量的图像缩放算法 |
| OCR | 光学字符识别，从图像中提取文字 |
| Canvas | HTML5提供的绘图API，用于图像处理 |
| 单例模式 | 确保类只有一个实例的设计模式 |
| 懒加载 | 延迟加载数据，提升性能 |
| 虚拟滚动 | 只渲染可见区域，优化大列表性能 |

### 12.2 参考资料
- HarmonyOS应用开发指南
- ArkTS语言规范
- Canvas API文档
- 图像处理算法参考

### 12.3 变更历史
| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v1.0 | 2025-01-20 | 初始版本 | AI开发团队 |
