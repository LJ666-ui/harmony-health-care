export enum ModelType {
  HEALTH_RISK_ASSESSMENT = 'health_risk_assessment',
  TCM_CONSTITUTION = 'tcm_constitution',
  MEDICAL_IMAGE_ANALYSIS = 'medical_image_analysis',
  OCR_RECOGNITION = 'ocr_recognition',
  OBJECT_DETECTION = 'object_detection',
  POSE_DETECTION = 'pose_detection',
  IMAGE_ENHANCEMENT = 'image_enhancement'
}

export enum ModelStatus {
  NOT_LOADED = 'not_loaded',
  LOADING = 'loading',
  LOADED = 'loaded',
  INFERRING = 'inferring',
  ERROR = 'error'
}

export enum BackendType {
  NPU = 'npu',
  CPU = 'cpu',
  GPU = 'gpu'
}

export interface ModelInfo {
  type: ModelType;
  version: string;
  path: string;
  status: ModelStatus;
  backend: BackendType;
  loadTime?: number;
  lastUsedTime?: number;
  memorySize?: number;
  error?: string;
}

export interface ModelConfig {
  type: ModelType;
  version: string;
  path: string;
  priority: number;
  preload: boolean;
  cacheTimeout: number;
}

export const MODEL_CONFIGS: Map<ModelType, ModelConfig> = new Map();

function initModelConfigs(): void {
  MODEL_CONFIGS.set(ModelType.HEALTH_RISK_ASSESSMENT, {
    type: ModelType.HEALTH_RISK_ASSESSMENT,
    version: '1.0.0',
    path: 'models/health_risk_assessment_v1.0.0.ms',
    priority: 1,
    preload: true,
    cacheTimeout: 1800000
  });
  MODEL_CONFIGS.set(ModelType.TCM_CONSTITUTION, {
    type: ModelType.TCM_CONSTITUTION,
    version: '1.0.0',
    path: 'models/tcm_constitution_v1.0.0.ms',
    priority: 2,
    preload: false,
    cacheTimeout: 1800000
  });
  MODEL_CONFIGS.set(ModelType.MEDICAL_IMAGE_ANALYSIS, {
    type: ModelType.MEDICAL_IMAGE_ANALYSIS,
    version: '1.0.0',
    path: 'models/medical_image_analysis_v1.0.0.ms',
    priority: 2,
    preload: false,
    cacheTimeout: 1800000
  });
  MODEL_CONFIGS.set(ModelType.OCR_RECOGNITION, {
    type: ModelType.OCR_RECOGNITION,
    version: '1.0.0',
    path: 'models/ocr_recognition_v1.0.0.ms',
    priority: 3,
    preload: false,
    cacheTimeout: 1800000
  });
}

initModelConfigs();
