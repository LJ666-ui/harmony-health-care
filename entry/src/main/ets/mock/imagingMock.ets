/**
 * 医学影像分析Mock数据
 * 
 * 提供5种影像类型的模拟分析结果,用于前端开发和测试
 */

import {
  ImagingType,
  RiskLevel,
  Lesion,
  ImageAnalysisResult,
  AnalysisReport,
  ImagingRecord,
  DISCLAIMER
} from '../models/ImagingModels';

/**
 * 生成UUID
 */
function generateUUID(): string {
  // 简化的UUID生成,避免使用function表达式和索引访问
  const chars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];
  const specialChars = ['8', '9', 'a', 'b'];
  let uuid = '';
  for (let i = 0; i < 36; i++) {
    if (i === 8 || i === 13 || i === 18 || i === 23) {
      uuid += '-';
    } else if (i === 14) {
      uuid += '4';
    } else if (i === 19) {
      const randomIndex = Math.floor(Math.random() * 4);
      uuid += specialChars[randomIndex];
    } else {
      const randomIndex = Math.floor(Math.random() * 16);
      uuid += chars[randomIndex];
    }
  }
  return uuid;
}

/**
 * 创建Mock病灶数据
 */
function createMockLesion(
  type: string,
  confidence: number,
  riskLevel: RiskLevel,
  location: string
): Lesion {
  return {
    id: generateUUID(),
    lesionType: type,
    confidence: confidence,
    riskLevel: riskLevel,
    boundingBox: {
      x: Math.random() * 100 + 50,
      y: Math.random() * 100 + 50,
      width: Math.random() * 50 + 30,
      height: Math.random() * 50 + 30
    },
    size: {
      widthMM: Math.random() * 10 + 5,
      heightMM: Math.random() * 10 + 5
    },
    locationDescription: location,
    suggestedDiagnosis: `疑似${type}`,
    recommendations: [
      '建议3个月后复查',
      '如有不适请及时就医',
      '保持定期体检习惯'
    ],
    description: `检测到${type},置信度${(confidence * 100).toFixed(0)}%`
  };
}

/**
 * 创建Mock分析报告
 */
function createMockReport(
  imagingType: ImagingType,
  lesions: Lesion[],
  riskLevel: RiskLevel
): AnalysisReport {
  // 使用Map替代对象字面量
  const medicalAdviceMap = new Map<RiskLevel, string>();
  medicalAdviceMap.set(RiskLevel.HIGH, '检测到明显异常,建议尽快前往医院进行专业检查');
  medicalAdviceMap.set(RiskLevel.MEDIUM, '存在可疑异常,建议近期预约医生检查');
  medicalAdviceMap.set(RiskLevel.LOW, '未发现明显异常,建议保持定期体检习惯');

  const medicalAdvice = medicalAdviceMap.get(riskLevel) || '';

  return {
    reportId: generateUUID(),
    imagingType: imagingType,
    analyzedAt: new Date().toISOString(),
    lesions: lesions,
    overallRiskLevel: riskLevel,
    overallAssessment: `检测到${lesions.length}个病灶,总体风险等级为${riskLevel}`,
    medicalAdvice: medicalAdvice,
    disclaimer: DISCLAIMER,
    summary: `本次分析检测到${lesions.length}个病灶,其中高风险${lesions.filter(l => l.riskLevel === RiskLevel.HIGH).length}个,中风险${lesions.filter(l => l.riskLevel === RiskLevel.MEDIUM).length}个,低风险${lesions.filter(l => l.riskLevel === RiskLevel.LOW).length}个。`
  };
}

/**
 * 胸部X光Mock数据
 */
export const mockChestXrayResult: ImageAnalysisResult = {
  analysisId: generateUUID(),
  originalImageUri: 'mock://chest_xray.jpg',
  annotatedImageUri: 'mock://chest_xray_annotated.jpg',
  imagingType: ImagingType.CHEST_XRAY,
  lesions: [
    createMockLesion('肺结节', 0.92, RiskLevel.MEDIUM, '右肺上叶'),
    createMockLesion('肺炎', 0.78, RiskLevel.HIGH, '左肺下叶')
  ],
  report: createMockReport(
    ImagingType.CHEST_XRAY,
    [
      createMockLesion('肺结节', 0.92, RiskLevel.MEDIUM, '右肺上叶'),
      createMockLesion('肺炎', 0.78, RiskLevel.HIGH, '左肺下叶')
    ],
    RiskLevel.HIGH
  ),
  processingTimeMs: 8500,
  analyzedAt: new Date().toISOString(),
  modelVersion: 'v1.0.0',
  confidenceThreshold: 0.5
};

/**
 * 骨骼X光Mock数据
 */
export const mockBoneXrayResult: ImageAnalysisResult = {
  analysisId: generateUUID(),
  originalImageUri: 'mock://bone_xray.jpg',
  annotatedImageUri: 'mock://bone_xray_annotated.jpg',
  imagingType: ImagingType.BONE_XRAY,
  lesions: [
    createMockLesion('骨折', 0.95, RiskLevel.HIGH, '左侧桡骨')
  ],
  report: createMockReport(
    ImagingType.BONE_XRAY,
    [createMockLesion('骨折', 0.95, RiskLevel.HIGH, '左侧桡骨')],
    RiskLevel.HIGH
  ),
  processingTimeMs: 7200,
  analyzedAt: new Date().toISOString(),
  modelVersion: 'v1.0.0',
  confidenceThreshold: 0.5
};

/**
 * 皮肤照片Mock数据
 */
export const mockSkinPhotoResult: ImageAnalysisResult = {
  analysisId: generateUUID(),
  originalImageUri: 'mock://skin_photo.jpg',
  annotatedImageUri: 'mock://skin_photo_annotated.jpg',
  imagingType: ImagingType.SKIN_PHOTO,
  lesions: [
    createMockLesion('色素痣', 0.88, RiskLevel.LOW, '左臂'),
    createMockLesion('脂溢性角化', 0.75, RiskLevel.LOW, '右肩')
  ],
  report: createMockReport(
    ImagingType.SKIN_PHOTO,
    [
      createMockLesion('色素痣', 0.88, RiskLevel.LOW, '左臂'),
      createMockLesion('脂溢性角化', 0.75, RiskLevel.LOW, '右肩')
    ],
    RiskLevel.LOW
  ),
  processingTimeMs: 6800,
  analyzedAt: new Date().toISOString(),
  modelVersion: 'v1.0.0',
  confidenceThreshold: 0.5
};

/**
 * 眼底照片Mock数据
 */
export const mockEyeFundusResult: ImageAnalysisResult = {
  analysisId: generateUUID(),
  originalImageUri: 'mock://eye_fundus.jpg',
  annotatedImageUri: 'mock://eye_fundus_annotated.jpg',
  imagingType: ImagingType.EYE_FUNDUS,
  lesions: [
    createMockLesion('糖尿病视网膜病变', 0.91, RiskLevel.HIGH, '右眼')
  ],
  report: createMockReport(
    ImagingType.EYE_FUNDUS,
    [createMockLesion('糖尿病视网膜病变', 0.91, RiskLevel.HIGH, '右眼')],
    RiskLevel.HIGH
  ),
  processingTimeMs: 7800,
  analyzedAt: new Date().toISOString(),
  modelVersion: 'v1.0.0',
  confidenceThreshold: 0.5
};

/**
 * 乳腺超声Mock数据
 */
export const mockBreastUltrasoundResult: ImageAnalysisResult = {
  analysisId: generateUUID(),
  originalImageUri: 'mock://breast_ultrasound.jpg',
  annotatedImageUri: 'mock://breast_ultrasound_annotated.jpg',
  imagingType: ImagingType.BREAST_ULTRASOUND,
  lesions: [
    createMockLesion('乳腺结节', 0.85, RiskLevel.MEDIUM, '左侧乳腺')
  ],
  report: createMockReport(
    ImagingType.BREAST_ULTRASOUND,
    [createMockLesion('乳腺结节', 0.85, RiskLevel.MEDIUM, '左侧乳腺')],
    RiskLevel.MEDIUM
  ),
  processingTimeMs: 6500,
  analyzedAt: new Date().toISOString(),
  modelVersion: 'v1.0.0',
  confidenceThreshold: 0.5
};

/**
 * 所有Mock数据集合
 */
export const allMockResults: Record<ImagingType, ImageAnalysisResult> = {
  [ImagingType.CHEST_XRAY]: mockChestXrayResult,
  [ImagingType.BONE_XRAY]: mockBoneXrayResult,
  [ImagingType.SKIN_PHOTO]: mockSkinPhotoResult,
  [ImagingType.EYE_FUNDUS]: mockEyeFundusResult,
  [ImagingType.BREAST_ULTRASOUND]: mockBreastUltrasoundResult
};

/**
 * Mock历史记录数据
 */
export const mockHistoryRecords: ImagingRecord[] = [
  {
    recordId: generateUUID(),
    originalImageUri: 'mock://history1.jpg',
    annotatedImageUri: 'mock://history1_annotated.jpg',
    imagingType: ImagingType.CHEST_XRAY,
    lesions: [createMockLesion('肺结节', 0.90, RiskLevel.MEDIUM, '右肺')],
    overallRiskLevel: RiskLevel.MEDIUM,
    report: createMockReport(
      ImagingType.CHEST_XRAY,
      [createMockLesion('肺结节', 0.90, RiskLevel.MEDIUM, '右肺')],
      RiskLevel.MEDIUM
    ),
    analyzedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(), // 7天前
    processingTimeMs: 8000
  },
  {
    recordId: generateUUID(),
    originalImageUri: 'mock://history2.jpg',
    annotatedImageUri: 'mock://history2_annotated.jpg',
    imagingType: ImagingType.SKIN_PHOTO,
    lesions: [createMockLesion('色素痣', 0.85, RiskLevel.LOW, '背部')],
    overallRiskLevel: RiskLevel.LOW,
    report: createMockReport(
      ImagingType.SKIN_PHOTO,
      [createMockLesion('色素痣', 0.85, RiskLevel.LOW, '背部')],
      RiskLevel.LOW
    ),
    analyzedAt: new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString(), // 14天前
    processingTimeMs: 6500
  }
];

/**
 * 获取Mock分析结果
 * 
 * @param imagingType 影像类型
 * @returns Mock分析结果
 */
export function getMockResult(imagingType: ImagingType): ImageAnalysisResult {
  return allMockResults[imagingType];
}

/**
 * 模拟分析延迟
 * 
 * @param ms 延迟毫秒数
 */
export function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}
