export enum ImageType {
  CHEST_XRAY = 'CHEST_XRAY',
  BONE_XRAY = 'BONE_XRAY',
  SKIN_PHOTO = 'SKIN_PHOTO',
  FUNDUS_PHOTO = 'FUNDUS_PHOTO',
  BREAST_ULTRASOUND = 'BREAST_ULTRASOUND',
  OTHER = 'OTHER'
}

export enum ProcessStep {
  UPLOAD = 'UPLOAD',
  AI_ANALYSIS = 'AI_ANALYSIS',
  VIEW_RESULT = 'VIEW_RESULT',
  LESION_DETAIL = 'LESION_DETAIL'
}

export enum StepStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  ERROR = 'ERROR'
}

export enum Severity {
  CRITICAL = 'CRITICAL',
  SEVERE = 'SEVERE',
  MODERATE = 'MODERATE',
  MILD = 'MILD'
}

export interface Lesion {
  lesionId: string;
  lesionType: string;
  lesionName: string;
  confidence: number;
  severity: Severity;
  description: string;
  positionX?: number;
  positionY?: number;
  boundingBox?: string;
  sizeMm?: number;
  shape?: string;
  density?: string;
  edge?: string;
  internalStructure?: string;
}

export interface DiagnosisResult {
  resultId: string;
  imageId: string;
  userId: number;
  imageType: ImageType;
  lesionCount: number;
  overallConfidence: number;
  lesions: Lesion[];
  recommendations: string[];
  analysisDuration: number;
  analysisTime: string;
}

export interface UploadResponse {
  imageId: string;
  previewUrl: string;
  originalSize: number;
  compressedSize: number;
  compressionRatio: number;
}

export interface AnalyzeResponse {
  resultId: string;
  lesionCount: number;
  overallConfidence: number;
  lesions: Lesion[];
  recommendations: string[];
  analysisDuration: number;
}
