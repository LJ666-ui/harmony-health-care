export const IMAGE_TYPE_LABELS: Record<string, string> = {
  'CHEST_XRAY': '胸部X光',
  'BONE_XRAY': '骨骼X光',
  'SKIN_PHOTO': '皮肤照片',
  'FUNDUS_PHOTO': '眼底照片',
  'BREAST_ULTRASOUND': '乳腺超声',
  'OTHER': '其他类型'
}

export const PROCESS_STEP_LABELS: Record<string, string> = {
  'UPLOAD': '上传影像',
  'AI_ANALYSIS': 'AI分析',
  'VIEW_RESULT': '查看结果',
  'LESION_DETAIL': '病灶详情'
}

export const SEVERITY_COLORS: Record<string, string> = {
  'CRITICAL': '#FF0000',
  'SEVERE': '#FF6600',
  'MODERATE': '#FFCC00',
  'MILD': '#0066FF'
}

export const SEVERITY_LABELS: Record<string, string> = {
  'CRITICAL': '危急',
  'SEVERE': '重度',
  'MODERATE': '中度',
  'MILD': '轻度'
}

export const API_ENDPOINTS = {
  UPLOAD: '/api/v1/medical-image/upload',
  ANALYZE: '/api/v1/medical-image/analyze',
  GET_RESULT: '/api/v1/medical-image/result',
  GET_LESION: '/api/v1/medical-image/lesion',
  GET_REPORT: '/api/v1/medical-image/report',
  GET_HISTORY: '/api/v1/medical-image/history'
}

export const ERROR_CODES = {
  INVALID_FORMAT: 40001,
  FILE_TOO_LARGE: 40002,
  FILE_CORRUPTED: 40003,
  NOT_FOUND: 40401,
  AI_ENGINE_ERROR: 50101,
  ANALYSIS_TIMEOUT: 50102
}
