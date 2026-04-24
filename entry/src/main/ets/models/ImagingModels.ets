/**
 * 医学影像AI病灶识别与分析系统 - 数据模型定义
 * 
 * 本文件定义了医学影像分析系统所需的所有数据模型、枚举类型和接口契约
 */

/**
 * 影像类型枚举
 * 支持5种常见医学影像类型
 */
export enum ImagingType {
  /** 胸部X光 */
  CHEST_XRAY = 'CHEST_XRAY',
  /** 骨骼X光 */
  BONE_XRAY = 'BONE_XRAY',
  /** 皮肤照片 */
  SKIN_PHOTO = 'SKIN_PHOTO',
  /** 眼底照片 */
  EYE_FUNDUS = 'EYE_FUNDUS',
  /** 乳腺超声 */
  BREAST_ULTRASOUND = 'BREAST_ULTRASOUND'
}

/**
 * 影像类型显示名称映射
 */
export class ImagingTypeLabels {
  private static labels: Map<ImagingType, string>;

  static getLabel(type: ImagingType): string {
    if (!ImagingTypeLabels.labels) {
      ImagingTypeLabels.labels = new Map<ImagingType, string>();
      ImagingTypeLabels.labels.set(ImagingType.CHEST_XRAY, '胸部X光');
      ImagingTypeLabels.labels.set(ImagingType.BONE_XRAY, '骨骼X光');
      ImagingTypeLabels.labels.set(ImagingType.SKIN_PHOTO, '皮肤照片');
      ImagingTypeLabels.labels.set(ImagingType.EYE_FUNDUS, '眼底照片');
      ImagingTypeLabels.labels.set(ImagingType.BREAST_ULTRASOUND, '乳腺超声');
    }
    return ImagingTypeLabels.labels.get(type) || '未知类型';
  }
}

/**
 * 风险等级枚举
 * 基于病灶数量、大小、置信度综合评定
 */
export enum RiskLevel {
  /** 高风险 - 需要尽快就医 */
  HIGH = 'HIGH',
  /** 中等风险 - 建议近期检查 */
  MEDIUM = 'MEDIUM',
  /** 低风险 - 建议定期体检 */
  LOW = 'LOW'
}

/**
 * 风险等级显示名称映射
 */
export class RiskLevelLabels {
  private static labels: Map<RiskLevel, string>;

  static getLabel(level: RiskLevel): string {
    if (!RiskLevelLabels.labels) {
      RiskLevelLabels.labels = new Map<RiskLevel, string>();
      RiskLevelLabels.labels.set(RiskLevel.HIGH, '高风险');
      RiskLevelLabels.labels.set(RiskLevel.MEDIUM, '中等风险');
      RiskLevelLabels.labels.set(RiskLevel.LOW, '低风险');
    }
    return RiskLevelLabels.labels.get(level) || '未知风险';
  }
}

/**
 * 风险等级颜色映射
 */
export class RiskLevelColors {
  private static colors: Map<RiskLevel, string>;

  static getColor(level: RiskLevel): string {
    if (!RiskLevelColors.colors) {
      RiskLevelColors.colors = new Map<RiskLevel, string>();
      RiskLevelColors.colors.set(RiskLevel.HIGH, '#FF0000');    // 红色
      RiskLevelColors.colors.set(RiskLevel.MEDIUM, '#FFA500');  // 橙色
      RiskLevelColors.colors.set(RiskLevel.LOW, '#FFFF00');     // 黄色
    }
    return RiskLevelColors.colors.get(level) || '#CCCCCC';
  }
}

/**
 * AI模型状态枚举
 */
export enum ModelStatus {
  /** 未加载 */
  NOT_LOADED = 'NOT_LOADED',
  /** 加载中 */
  LOADING = 'LOADING',
  /** 已加载 */
  LOADED = 'LOADED',
  /** 加载失败 */
  ERROR = 'ERROR'
}

/**
 * 边界框接口
 * 表示病灶在图像中的位置和大小
 */
export interface BoundingBox {
  /** 左上角X坐标 */
  x: number;
  /** 左上角Y坐标 */
  y: number;
  /** 宽度 */
  width: number;
  /** 高度 */
  height: number;
}

/**
 * 病灶尺寸接口(毫米单位)
 */
export interface SizeMM {
  /** 宽度(毫米) */
  widthMM: number;
  /** 高度(毫米) */
  heightMM: number;
}

/**
 * 病灶接口
 * 表示检测到的单个病灶完整信息
 */
export interface Lesion {
  /** 病灶唯一ID */
  id: string;
  /** 病灶类型名称(如"肺结节") */
  lesionType: string;
  /** 检测置信度(0-1) */
  confidence: number;
  /** 风险等级 */
  riskLevel: RiskLevel;
  /** 边界框坐标 */
  boundingBox: BoundingBox;
  /** 实际尺寸(毫米) */
  size?: SizeMM;
  /** 位置描述(如"右肺上叶") */
  locationDescription: string;
  /** 初步诊断建议 */
  suggestedDiagnosis: string;
  /** 就医建议列表 */
  recommendations: string[];
  /** 病灶描述 */
  description?: string;
}

/**
 * 原始检测结果接口(YOLO格式)
 */
export interface RawDetection {
  /** 边界框 */
  bbox: BoundingBox;
  /** 置信度 */
  confidence: number;
  /** 类别ID */
  classId: number;
  /** 类别名称 */
  className: string;
}

/**
 * 分析选项接口
 */
export interface AnalysisOptions {
  /** 指定影像类型(可选,不指定则自动识别) */
  imagingType?: ImagingType;
  /** 置信度阈值(默认0.5) */
  confidenceThreshold?: number;
  /** 是否保存历史记录(默认true) */
  saveHistory?: boolean;
  /** 进度回调函数 */
  onProgress?: (progress: number, message: string) => void;
}

/**
 * 分析报告接口
 */
export interface AnalysisReport {
  /** 报告唯一ID */
  reportId: string;
  /** 影像类型 */
  imagingType: ImagingType;
  /** 检测时间 */
  analyzedAt: string;
  /** 病灶列表 */
  lesions: Lesion[];
  /** 总体风险等级 */
  overallRiskLevel: RiskLevel;
  /** 总体评估描述 */
  overallAssessment: string;
  /** 就医建议 */
  medicalAdvice: string;
  /** 免责声明 */
  disclaimer: string;
  /** 分析摘要 */
  summary: string;
}

/**
 * 影像分析结果接口
 */
export interface ImageAnalysisResult {
  /** 分析任务唯一ID */
  analysisId: string;
  /** 原始影像URI */
  originalImageUri: string;
  /** 标注后影像URI */
  annotatedImageUri?: string;
  /** 影像类型 */
  imagingType: ImagingType;
  /** 检测到的病灶列表 */
  lesions: Lesion[];
  /** 分析报告 */
  report: AnalysisReport;
  /** 处理耗时(毫秒) */
  processingTimeMs: number;
  /** 分析时间(ISO字符串) */
  analyzedAt: string;
  /** 模型版本 */
  modelVersion?: string;
  /** 置信度阈值 */
  confidenceThreshold: number;
}

/**
 * 影像类型识别结果接口
 */
export interface ClassificationResult {
  /** 识别的影像类型 */
  imagingType: ImagingType;
  /** 识别置信度(0-1) */
  confidence: number;
  /** 是否需要用户确认(置信度<0.7时为true) */
  needsConfirmation: boolean;
}

/**
 * 历史记录接口
 */
export interface ImagingRecord {
  /** 记录唯一ID */
  recordId: string;
  /** 原始影像URI */
  originalImageUri: string;
  /** 标注影像URI */
  annotatedImageUri?: string;
  /** 影像类型 */
  imagingType: ImagingType;
  /** 检测到的病灶列表 */
  lesions: Lesion[];
  /** 总体风险等级 */
  overallRiskLevel: RiskLevel;
  /** 分析报告 */
  report: AnalysisReport;
  /** 分析时间 */
  analyzedAt: string;
  /** 处理耗时(毫秒) */
  processingTimeMs: number;
}

/**
 * 历史记录查询选项接口
 */
export interface RecordQueryOptions {
  /** 页码(从1开始) */
  page?: number;
  /** 每页数量(默认20) */
  pageSize?: number;
  /** 按影像类型筛选 */
  imagingType?: ImagingType;
  /** 按风险等级筛选 */
  riskLevel?: RiskLevel;
  /** 开始时间 */
  startTime?: string;
  /** 结束时间 */
  endTime?: string;
}

/**
 * 图像源接口
 */
export interface ImageSource {
  /** 图像URI */
  uri: string;
  /** 图像宽度 */
  width?: number;
  /** 图像高度 */
  height?: number;
}

/**
 * 进度信息接口
 */
export interface ProgressInfo {
  /** 进度百分比(0-100) */
  progress: number;
  /** 进度描述文本 */
  message: string;
  /** 当前步骤 */
  step?: number;
  /** 总步骤数 */
  totalSteps?: number;
}

/**
 * 错误信息接口
 */
export interface AnalysisError {
  /** 错误代码 */
  code: string;
  /** 错误消息 */
  message: string;
  /** 错误详情 */
  details?: string;
}

/**
 * 通用结果接口
 */
export interface Result<T> {
  /** 是否成功 */
  success: boolean;
  /** 成功时的数据 */
  data?: T;
  /** 失败时的错误 */
  error?: AnalysisError;
}

/**
 * 病灶类型映射配置
 * 每种影像类型对应的病灶类型字典
 */
export class LesionTypeMap {
  private static instance: Map<ImagingType, Map<number, string>>;

  static getMap(): Map<ImagingType, Map<number, string>> {
    if (!LesionTypeMap.instance) {
      LesionTypeMap.instance = new Map<ImagingType, Map<number, string>>();
      
      // 胸部X光
      const chestXrayMap = new Map<number, string>();
      chestXrayMap.set(0, '肺结节');
      chestXrayMap.set(1, '肺炎');
      chestXrayMap.set(2, '肺气肿');
      chestXrayMap.set(3, '胸腔积液');
      chestXrayMap.set(4, '心脏肥大');
      LesionTypeMap.instance.set(ImagingType.CHEST_XRAY, chestXrayMap);
      
      // 骨骼X光
      const boneXrayMap = new Map<number, string>();
      boneXrayMap.set(0, '骨折');
      boneXrayMap.set(1, '骨裂');
      boneXrayMap.set(2, '骨质增生');
      boneXrayMap.set(3, '骨肿瘤');
      LesionTypeMap.instance.set(ImagingType.BONE_XRAY, boneXrayMap);
      
      // 皮肤照片
      const skinPhotoMap = new Map<number, string>();
      skinPhotoMap.set(0, '色素痣');
      skinPhotoMap.set(1, '脂溢性角化');
      skinPhotoMap.set(2, '皮肤肿瘤');
      skinPhotoMap.set(3, '湿疹');
      skinPhotoMap.set(4, '银屑病');
      LesionTypeMap.instance.set(ImagingType.SKIN_PHOTO, skinPhotoMap);
      
      // 眼底照片
      const eyeFundusMap = new Map<number, string>();
      eyeFundusMap.set(0, '糖尿病视网膜病变');
      eyeFundusMap.set(1, '青光眼');
      eyeFundusMap.set(2, '黄斑变性');
      eyeFundusMap.set(3, '视网膜脱离');
      LesionTypeMap.instance.set(ImagingType.EYE_FUNDUS, eyeFundusMap);
      
      // 乳腺超声
      const breastUltrasoundMap = new Map<number, string>();
      breastUltrasoundMap.set(0, '乳腺结节');
      breastUltrasoundMap.set(1, '乳腺囊肿');
      breastUltrasoundMap.set(2, '乳腺肿瘤');
      breastUltrasoundMap.set(3, '乳腺增生');
      LesionTypeMap.instance.set(ImagingType.BREAST_ULTRASOUND, breastUltrasoundMap);
    }
    return LesionTypeMap.instance;
  }

  static getLesionType(imagingType: ImagingType, classId: number): string {
    const map = LesionTypeMap.getMap().get(imagingType);
    return map ? (map.get(classId) || '未知病灶') : '未知病灶';
  }
}

/**
 * AI模型路径映射
 */
export class ModelPathMap {
  private static instance: Map<ImagingType, string>;

  static getMap(): Map<ImagingType, string> {
    if (!ModelPathMap.instance) {
      ModelPathMap.instance = new Map<ImagingType, string>();
      ModelPathMap.instance.set(ImagingType.CHEST_XRAY, 'resources/rawfile/chest_xray_lesion.ms');
      ModelPathMap.instance.set(ImagingType.BONE_XRAY, 'resources/rawfile/bone_fracture.ms');
      ModelPathMap.instance.set(ImagingType.SKIN_PHOTO, 'resources/rawfile/skin_lesion.ms');
      ModelPathMap.instance.set(ImagingType.EYE_FUNDUS, 'resources/rawfile/eye_fundus.ms');
      ModelPathMap.instance.set(ImagingType.BREAST_ULTRASOUND, 'resources/rawfile/breast_ultrasound.ms');
    }
    return ModelPathMap.instance;
  }

  static getPath(imagingType: ImagingType): string {
    return ModelPathMap.getMap().get(imagingType) || '';
  }
}

/**
 * 免责声明常量
 */
export const DISCLAIMER = '本分析结果仅供参考,不能作为医学诊断依据,最终诊断请以专业医师意见为准。AI检测结果可能存在误差,如有疑问请咨询专业医生。'
