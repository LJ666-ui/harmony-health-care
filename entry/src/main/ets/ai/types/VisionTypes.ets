export interface ImageData {
  uri?: string;
  pixelMap?: object;
  width: number;
  height: number;
  format: ImageFormat;
}

export enum ImageFormat {
  JPEG = 'jpeg',
  PNG = 'png',
  BMP = 'bmp',
  UNKNOWN = 'unknown'
}

export interface DetectionResult {
  objects: DetectedObject[];
  imageWidth: number;
  imageHeight: number;
  latency: number;
}

export interface DetectedObject {
  classId: number;
  className: string;
  confidence: number;
  bbox: BoundingBox;
  needsManualConfirm?: boolean;
}

export interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface PoseResult {
  keypoints: Keypoint[];
  score: number;
  latency: number;
}

export interface Keypoint {
  id: number;
  name: string;
  x: number;
  y: number;
  score: number;
  visible: boolean;
}

export const KEYPOINT_NAMES: string[] = [
  'nose', 'left_eye', 'right_eye', 'left_ear', 'right_ear',
  'left_shoulder', 'right_shoulder', 'left_elbow', 'right_elbow',
  'left_wrist', 'right_wrist', 'left_hip', 'right_hip',
  'left_knee', 'right_knee', 'left_ankle', 'right_ankle'
];

export interface PostureAssessment {
  isCorrect: boolean;
  score: number;
  issues: string[];
  suggestions: string[];
  jointAngles: Map<string, number>;
}

export interface EnhanceOptions {
  denoise?: boolean;
  deblur?: boolean;
  superResolution?: boolean;
  contrastEnhance?: boolean;
  colorCorrect?: boolean;
  scaleFactor?: number;
}

export interface OCRResult {
  texts: OCRTextItem[];
  fullText: string;
  latency: number;
}

export interface OCRTextItem {
  text: string;
  confidence: number;
  bbox: BoundingBox;
  needsManualCheck?: boolean;
}

export interface ClassificationResult {
  classes: ClassItem[];
  topClass: ClassItem;
  latency: number;
}

export interface ClassItem {
  classId: number;
  className: string;
  confidence: number;
}
