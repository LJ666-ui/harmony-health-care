export enum EngineType {
  MINDSPORE_LITE = 'mindspore_lite',
  HIAI = 'hiai',
  FALLBACK = 'fallback'
}

export enum InferencePriority {
  HIGH = 1,
  NORMAL = 2,
  LOW = 3,
  BACKGROUND = 4
}

export enum InferenceScene {
  HEALTH_RISK_PREDICTION = 'health_risk_prediction',
  TCM_CONSTITUTION_IDENTIFICATION = 'tcm_constitution_identification',
  MEDICAL_IMAGE_ANALYSIS = 'medical_image_analysis',
  OBJECT_DETECTION = 'object_detection',
  POSE_DETECTION = 'pose_detection',
  IMAGE_ENHANCEMENT = 'image_enhancement',
  OCR_RECOGNITION = 'ocr_recognition',
  IMAGE_CLASSIFICATION = 'image_classification'
}

export const SCENE_ENGINE_MAP: Map<InferenceScene, EngineType> = new Map();

function initSceneEngineMap(): void {
  SCENE_ENGINE_MAP.set(InferenceScene.HEALTH_RISK_PREDICTION, EngineType.MINDSPORE_LITE);
  SCENE_ENGINE_MAP.set(InferenceScene.TCM_CONSTITUTION_IDENTIFICATION, EngineType.MINDSPORE_LITE);
  SCENE_ENGINE_MAP.set(InferenceScene.MEDICAL_IMAGE_ANALYSIS, EngineType.MINDSPORE_LITE);
  SCENE_ENGINE_MAP.set(InferenceScene.OBJECT_DETECTION, EngineType.HIAI);
  SCENE_ENGINE_MAP.set(InferenceScene.POSE_DETECTION, EngineType.HIAI);
  SCENE_ENGINE_MAP.set(InferenceScene.IMAGE_ENHANCEMENT, EngineType.HIAI);
  SCENE_ENGINE_MAP.set(InferenceScene.OCR_RECOGNITION, EngineType.HIAI);
  SCENE_ENGINE_MAP.set(InferenceScene.IMAGE_CLASSIFICATION, EngineType.HIAI);
}

initSceneEngineMap();
