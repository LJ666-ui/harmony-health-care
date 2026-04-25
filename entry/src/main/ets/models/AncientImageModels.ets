/**
 * 古医图AI复原增强系统 - 数据模型定义
 * 
 * 本文件定义了古医图AI复原系统的所有数据模型，包括：
 * - 枚举类型：图像状态、处理阶段、图像分类、标注类型等
 * - 核心接口：图像实体、处理参数、处理结果、标注数据等
 * - 辅助接口：边界框、质量评估、处理报告等
 * 
 * @version 1.0
 * @date 2025-01-20
 */

// ==================== 枚举类型定义 ====================

/**
 * 图像处理状态枚举
 */
export enum ImageStatus {
  /** 等待处理 */
  PENDING = 'PENDING',
  /** 处理中 */
  PROCESSING = 'PROCESSING',
  /** 处理完成 */
  COMPLETED = 'COMPLETED',
  /** 处理失败 */
  FAILED = 'FAILED'
}

/**
 * 处理阶段枚举
 * 定义了完整的8阶段处理流水线
 */
export enum ProcessingStage {
  /** 预处理：格式转换、尺寸调整、质量评估 */
  PREPROCESSING = 'PREPROCESSING',
  /** 降噪：去除图像噪点 */
  DENOISING = 'DENOISING',
  /** 去模糊：恢复图像清晰度 */
  DEBLURRING = 'DEBLURRING',
  /** 超分辨率：提升图像分辨率 */
  SUPER_RESOLUTION = 'SUPER_RESOLUTION',
  /** 颜色恢复：恢复褪色颜色 */
  COLOR_RESTORATION = 'COLOR_RESTORATION',
  /** 细节增强：增强图像细节 */
  DETAIL_ENHANCEMENT = 'DETAIL_ENHANCEMENT',
  /** OCR识别：识别文字内容 */
  OCR_RECOGNITION = 'OCR_RECOGNITION',
  /** 智能标注：生成标注信息 */
  ANNOTATION = 'ANNOTATION'
}

/**
 * 图像分类枚举
 * 古医图的主要分类
 */
export enum ImageCategory {
  /** 中医典籍：黄帝内经、伤寒论等 */
  CLASSICS = 'CLASSICS',
  /** 针灸图谱：经络图、穴位图 */
  ACUPUNCTURE = 'ACUPUNCTURE',
  /** 本草图谱：草药形态图 */
  HERBAL = 'HERBAL',
  /** 方剂配图：药方插图 */
  PRESCRIPTION = 'PRESCRIPTION'
}

/**
 * 标注类型枚举
 */
export enum AnnotationType {
  /** 文字框标注 */
  TEXT_BOX = 'TEXT_BOX',
  /** 穴位标注 */
  ACUPOINT = 'ACUPOINT',
  /** 经络线标注 */
  MERIDIAN = 'MERIDIAN',
  /** 草药标注 */
  HERB = 'HERB'
}

/**
 * 处理错误代码枚举
 */
export enum ProcessingErrorCode {
  /** 图像加载失败 */
  IMAGE_LOAD_FAILED = 'IMAGE_LOAD_FAILED',
  /** 处理超时 */
  PROCESSING_TIMEOUT = 'PROCESSING_TIMEOUT',
  /** 内存不足 */
  OUT_OF_MEMORY = 'OUT_OF_MEMORY',
  /** 参数错误 */
  INVALID_PARAMS = 'INVALID_PARAMS',
  /** OCR识别失败 */
  OCR_FAILED = 'OCR_FAILED',
  /** 未知错误 */
  UNKNOWN_ERROR = 'UNKNOWN_ERROR'
}

/**
 * 降噪强度枚举
 */
export enum DenoiseStrength {
  /** 低强度 */
  LOW = 'LOW',
  /** 中强度 */
  MEDIUM = 'MEDIUM',
  /** 高强度 */
  HIGH = 'HIGH'
}

/**
 * 超分辨率倍数枚举
 */
export enum SuperResolutionScale {
  /** 2倍放大 */
  X2 = 2,
  /** 4倍放大 */
  X4 = 4
}

// ==================== 核心数据接口 ====================

/**
 * 边界框接口
 * 使用百分比坐标，便于不同尺寸适配
 */
export interface BoundingBox {
  /** 左上角X坐标（百分比 0-100） */
  x: number;
  /** 左上角Y坐标（百分比 0-100） */
  y: number;
  /** 宽度（百分比 0-100） */
  width: number;
  /** 高度（百分比 0-100） */
  height: number;
}

/**
 * 图像元数据接口
 */
export interface ImageMetadata {
  /** 图像宽度（像素） */
  width: number;
  /** 图像高度（像素） */
  height: number;
  /** 图像格式（PNG/JPEG/WEBP） */
  format: string;
  /** 文件大小（字节） */
  fileSize: number;
  /** DPI分辨率 */
  dpi?: number;
  /** 色彩空间 */
  colorSpace?: string;
}

/**
 * 质量评估接口
 */
export interface QualityAssessment {
  /** 清晰度分数（0-100） */
  clarity: number;
  /** 对比度分数（0-100） */
  contrast: number;
  /** 噪点水平（0-100，越低越好） */
  noise: number;
  /** 综合质量分数（0-100） */
  overall: number;
  /** 评估时间戳 */
  timestamp: number;
}

/**
 * 古医图主实体接口
 */
export interface AncientImage {
  /** 图像唯一ID */
  id: number;
  /** 图像标题 */
  title: string;
  /** 图像描述 */
  description?: string;
  /** 图像分类 */
  category: ImageCategory;
  /** 处理状态 */
  status: ImageStatus;
  /** 原始图像URL */
  originalUrl: string;
  /** 复原后图像URL */
  restoredUrl?: string;
  /** 缩略图URL */
  thumbnailUrl?: string;
  /** 图像元数据 */
  metadata: ImageMetadata;
  /** 质量评估 */
  quality?: QualityAssessment;
  /** 处理进度（0-100） */
  progress?: number;
  /** 当前处理阶段 */
  currentStage?: ProcessingStage;
  /** 创建时间 */
  createdAt: number;
  /** 更新时间 */
  updatedAt: number;
  /** 用户ID */
  userId?: number;
}

// ==================== 处理参数接口 ====================

/**
 * 预处理参数接口
 */
export interface PreprocessingParams {
  /** 目标宽度（像素） */
  targetWidth?: number;
  /** 目标高度（像素） */
  targetHeight?: number;
  /** 是否保持宽高比 */
  keepAspectRatio?: boolean;
  /** 输出格式 */
  outputFormat?: string;
}

/**
 * 降噪参数接口
 */
export interface DenoisingParams {
  /** 降噪强度 */
  strength: DenoiseStrength;
  /** 是否保留边缘 */
  preserveEdges?: boolean;
}

/**
 * 去模糊参数接口
 */
export interface DeblurringParams {
  /** 去模糊方法 */
  method?: 'wiener' | 'lucy_richardson' | 'blind';
  /** 迭代次数 */
  iterations?: number;
}

/**
 * 超分辨率参数接口
 */
export interface SuperResolutionParams {
  /** 放大倍数 */
  scale: SuperResolutionScale;
  /** 是否应用锐化 */
  applySharpening?: boolean;
  /** 锐化强度（0-100） */
  sharpeningStrength?: number;
}

/**
 * 颜色恢复参数接口
 */
export interface ColorRestorationParams {
  /** 是否使用直方图均衡化 */
  useHistogramEqualization?: boolean;
  /** 饱和度增强系数（0-2） */
  saturationBoost?: number;
  /** 是否自动白平衡 */
  autoWhiteBalance?: boolean;
}

/**
 * 细节增强参数接口
 */
export interface DetailEnhancementParams {
  /** 边缘增强强度（0-100） */
  edgeStrength?: number;
  /** 纹理增强强度（0-100） */
  textureStrength?: number;
}

/**
 * OCR参数接口
 */
export interface OCRParams {
  /** 识别语言 */
  language?: string;
  /** 是否识别竖排文字 */
  detectVerticalText?: boolean;
  /** 是否高亮医学术语 */
  highlightMedicalTerms?: boolean;
}

/**
 * 标注参数接口
 */
export interface AnnotationParams {
  /** 是否生成文字框标注 */
  generateTextBoxes?: boolean;
  /** 是否高亮医学术语 */
  highlightMedicalTerms?: boolean;
  /** 标注样式 */
  style?: AnnotationStyle;
}

/**
 * 综合处理参数接口
 */
export interface ProcessingParams {
  /** 预处理参数 */
  preprocessing?: PreprocessingParams;
  /** 降噪参数 */
  denoising?: DenoisingParams;
  /** 去模糊参数 */
  deblurring?: DeblurringParams;
  /** 超分辨率参数 */
  superResolution?: SuperResolutionParams;
  /** 颜色恢复参数 */
  colorRestoration?: ColorRestorationParams;
  /** 细节增强参数 */
  detailEnhancement?: DetailEnhancementParams;
  /** OCR参数 */
  ocr?: OCRParams;
  /** 标注参数 */
  annotation?: AnnotationParams;
}

// ==================== 处理结果接口 ====================

/**
 * 阶段结果接口
 */
export interface StageResult {
  /** 处理阶段 */
  stage: ProcessingStage;
  /** 是否成功 */
  success: boolean;
  /** 输出图像URL */
  outputUrl?: string;
  /** 处理耗时（毫秒） */
  duration: number;
  /** 输入质量分数 */
  inputQuality: number;
  /** 输出质量分数 */
  outputQuality: number;
  /** 改善程度（百分比） */
  improvement: number;
  /** 错误信息 */
  error?: string;
}

/**
 * OCR识别文字接口
 */
export interface RecognizedText {
  /** 文字内容 */
  text: string;
  /** 文字边界框 */
  boundingBox: BoundingBox;
  /** 识别置信度（0-1） */
  confidence: number;
  /** 是否为医学术语 */
  isMedicalTerm?: boolean;
  /** 是否为竖排文字 */
  isVertical?: boolean;
}

/**
 * OCR结果接口
 */
export interface OCRResult {
  /** 完整识别文本 */
  fullText: string;
  /** 识别的文字块列表 */
  textBlocks: RecognizedText[];
  /** 平均置信度 */
  averageConfidence: number;
  /** 医学术语数量 */
  medicalTermCount: number;
  /** 识别耗时（毫秒） */
  duration: number;
}

/**
 * 标注样式接口
 */
export interface AnnotationStyle {
  /** 边框颜色（十六进制） */
  borderColor: string;
  /** 边框宽度 */
  borderWidth: number;
  /** 背景颜色（十六进制，带透明度） */
  backgroundColor?: string;
  /** 文字颜色（十六进制） */
  textColor?: string;
  /** 字体大小 */
  fontSize?: number;
}

/**
 * 图像标注接口
 */
export interface ImageAnnotation {
  /** 标注唯一ID */
  id: string;
  /** 标注类型 */
  type: AnnotationType;
  /** 标注标签 */
  label: string;
  /** 标注边界框 */
  boundingBox: BoundingBox;
  /** 标注描述 */
  description?: string;
  /** 标注样式 */
  style: AnnotationStyle;
  /** 置信度（0-1） */
  confidence: number;
  /** 是否可编辑 */
  editable: boolean;
  /** 创建时间 */
  createdAt: number;
}

/**
 * 处理进度接口
 */
export interface ProcessingProgress {
  /** 图像ID */
  imageId: number;
  /** 当前进度（0-100） */
  progress: number;
  /** 当前处理阶段 */
  currentStage: ProcessingStage;
  /** 已处理阶段数 */
  completedStages: number;
  /** 总阶段数 */
  totalStages: number;
  /** 预计剩余时间（秒） */
  estimatedTimeRemaining?: number;
  /** 处理开始时间 */
  startTime: number;
}

/**
 * 处理结果接口
 */
export interface ProcessingResult {
  /** 图像ID */
  imageId: number;
  /** 是否成功 */
  success: boolean;
  /** 复原后图像URL */
  restoredUrl?: string;
  /** 各阶段结果 */
  stageResults: StageResult[];
  /** OCR结果 */
  ocrResult?: OCRResult;
  /** 标注列表 */
  annotations: ImageAnnotation[];
  /** 处理报告 */
  report: ProcessingReport;
  /** 总处理时间（毫秒） */
  totalDuration: number;
  /** 错误信息 */
  error?: ProcessingError;
}

// ==================== 报告相关接口 ====================

/**
 * 阶段详情接口
 */
export interface StageDetail {
  /** 处理阶段 */
  stage: ProcessingStage;
  /** 阶段描述 */
  description: string;
  /** 处理耗时（毫秒） */
  duration: number;
  /** 输入质量分数 */
  inputQuality: number;
  /** 输出质量分数 */
  outputQuality: number;
  /** 改善程度（百分比） */
  improvement: number;
}

/**
 * 处理报告接口
 */
export interface ProcessingReport {
  /** 报告ID */
  id: string;
  /** 图像ID */
  imageId: number;
  /** 总处理时间（毫秒） */
  totalDuration: number;
  /** 各阶段详情 */
  stageDetails: StageDetail[];
  /** 原始质量评估 */
  originalQuality: QualityAssessment;
  /** 最终质量评估 */
  finalQuality: QualityAssessment;
  /** 总体改善程度（百分比） */
  overallImprovement: number;
  /** 处理参数 */
  params: ProcessingParams;
  /** 生成时间 */
  generatedAt: number;
}

// ==================== 批量处理接口 ====================

/**
 * 批量进度接口
 */
export interface BatchProgress {
  /** 批次ID */
  batchId: string;
  /** 总任务数 */
  total: number;
  /** 已完成数 */
  completed: number;
  /** 失败数 */
  failed: number;
  /** 当前进度（0-100） */
  progress: number;
  /** 各任务进度 */
  taskProgress: Map<number, ProcessingProgress>;
  /** 开始时间 */
  startTime: number;
  /** 预计剩余时间（秒） */
  estimatedTimeRemaining?: number;
}

/**
 * 批量处理结果接口
 */
export interface BatchProcessingResult {
  /** 批次ID */
  batchId: string;
  /** 成功的任务ID列表 */
  succeeded: number[];
  /** 失败的任务ID列表 */
  failed: number[];
  /** 各任务结果 */
  results: Map<number, ProcessingResult>;
  /** 总处理时间（毫秒） */
  totalDuration: number;
}

// ==================== 辅助接口 ====================

/**
 * 处理错误接口
 */
export interface ProcessingError {
  /** 错误代码 */
  code: ProcessingErrorCode;
  /** 错误消息 */
  message: string;
  /** 发生阶段 */
  stage?: ProcessingStage;
  /** 错误详情 */
  details?: string;
  /** 发生时间 */
  timestamp: number;
}

/**
 * 图像数据接口
 */
export interface ImageData {
  /** 图像宽度 */
  width: number;
  /** 图像高度 */
  height: number;
  /** 像素数据（RGBA） */
  data: Uint8ClampedArray;
}

/**
 * 像素数据接口
 */
export interface PixelData {
  /** 红色分量（0-255） */
  r: number;
  /** 绿色分量（0-255） */
  g: number;
  /** 蓝色分量（0-255） */
  b: number;
  /** 透明度（0-255） */
  a: number;
}

/**
 * 进度回调函数类型
 */
export type ProgressCallback = (progress: ProcessingProgress) => void;

/**
 * 处理完成回调函数类型
 */
export type CompletionCallback = (result: ProcessingResult) => void;

/**
 * 错误回调函数类型
 */
export type ErrorCallback = (error: ProcessingError) => void;
