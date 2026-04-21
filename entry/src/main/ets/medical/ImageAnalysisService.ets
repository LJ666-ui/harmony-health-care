export type ModelType = 'CHEST_XRAY' | 'CT_SCAN' | 'SKIN_LESION' | 'RETINA' | 'GENERAL';

export interface BoundingBox {
  x: number;
  y: number;
  width: number;
  height: number;
}

export type FindingSeverity = 'HIGH' | 'MEDIUM' | 'LOW';

export interface Finding {
  label: string;
  confidence: number;
  bbox: BoundingBox;
  severity: 'HIGH' | 'MEDIUM' | 'LOW';
  description: string;
}

export interface AnalysisResult {
  imageType: ModelType | string;
  findings: Finding[];
  overallDiagnosis: string;
  urgencyLevel: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';
  recommendations: string[];
  disclaimer: string;
  analysisTimeMs: number;
  modelVersion: string;
  timestamp: string;
}

export interface SampleImageInfo {
  id: string;
  name: string;
  displayName: string;
  category: ModelType;
  icon: string;
  color: string;
  description: string;
  path: string;
}

export interface ImageSourceResult {
  uri?: string;
  sampleInfo?: SampleImageInfo;
  source: 'album' | 'sample';
  index?: number;
  timestamp: string;
}

export interface AnnotationData {
  originalImage: ImageSourceResult;
  annotations: AnnotationItem[];
  canvasSize: CanvasSize;
}

export interface AnnotationItem {
  id: string;
  finding: Finding;
  style: AnnotationStyle;
  label: string;
  bbox: BoundingBox;
}

export interface AnnotationStyle {
  strokeColor: string;
  fillColor: string;
  lineWidth: number;
}

export interface CanvasSize {
  width: number;
  height: number;
}

export interface ModelStatus {
  isLoaded: boolean;
  version: string;
  mode: 'REAL' | 'MOCK';
}

export interface MockFinding {
  label: string;
  confidence: number;
  bbox: BoundingBox;
  severity: 'HIGH' | 'MEDIUM' | 'LOW';
  description: string;
}

export class ImageAnalysisService {
  private static instance: ImageAnalysisService | null = null;

  private isModelLoaded: boolean = false;
  private modelVersion: string = '1.0.0-Mock';
  private useRealModel: boolean = false;

  private static readonly SAMPLE_IMAGES: SampleImageInfo[] = [
    {
      id: 'SAMPLE_001',
      name: 'chest_xray_normal.jpg',
      displayName: '正常胸部X光',
      category: 'CHEST_XRAY',
      icon: '🫁',
      color: '#52C41A',
      description: '正常胸部X光片，用于对比参考',
      path: 'sample_images/chest_xray_normal.jpg'
    },
    {
      id: 'SAMPLE_002',
      name: 'chest_xray_pneumonia.jpg',
      displayName: '肺炎X光片',
      category: 'CHEST_XRAY',
      icon: '🦠',
      color: '#FF4D4F',
      description: '右下肺炎症伴胸腔积液',
      path: 'sample_images/chest_xray_pneumonia.jpg'
    },
    {
      id: 'SAMPLE_003',
      name: 'ct_lung_nodule.jpg',
      displayName: '肺结节CT',
      category: 'CT_SCAN',
      icon: '🔬',
      color: '#FAAD14',
      description: '左上肺可见结节影，需进一步评估',
      path: 'sample_images/ct_lung_nodule.jpg'
    },
    {
      id: 'SAMPLE_004',
      name: 'skin_lesion_melanoma.jpg',
      displayName: '黑色素瘤',
      category: 'SKIN_LESION',
      icon: '🎨',
      color: '#722ED1',
      description: '皮肤病变疑似恶性黑色素瘤',
      path: 'sample_images/skin_lesion_melanoma.jpg'
    },
    {
      id: 'SAMPLE_005',
      name: 'retina_diabetic.jpg',
      displayName: '糖尿病视网膜病变',
      category: 'RETINA',
      icon: '👁️',
      color: '#CF1322',
      description: '视网膜微血管异常，需眼科检查',
      path: 'sample_images/retina_diabetic.jpg'
    }
  ];

  private constructor() {
    console.log('[ImageAnalysisService] 初始化影像分析服务');
  }

  static getInstance(): ImageAnalysisService {
    if (!ImageAnalysisService.instance) {
      ImageAnalysisService.instance = new ImageAnalysisService();
    }
    return ImageAnalysisService.instance;
  }

  async selectImageFromAlbum(): Promise<ImageSourceResult | null> {
    console.log('[ImageAnalysisService] 打开相册选择图片');

    try {
      console.log('[ImageAnalysisService] 模拟打开相册选择图片');
      
      return null;

    } catch (error) {
      console.error('[ImageAnalysisService] 相册选择失败:', error instanceof Error ? error.message : String(error));
      
      return null;
    }
  }

  loadSampleImage(index: number): ImageSourceResult | null {
    if (index < 0 || index >= ImageAnalysisService.SAMPLE_IMAGES.length) {
      console.error(`[ImageAnalysisService] 索引超出范围: ${index}`);
      return null;
    }

    const sampleInfo = ImageAnalysisService.SAMPLE_IMAGES[index];

    console.log(`[ImageAnalysisService] 加载示例图片: ${sampleInfo.name}`);

    return {
      sampleInfo: sampleInfo,
      source: 'sample',
      index: index,
      timestamp: new Date().toISOString()
    };
  }

  async analyzeImage(imageSource: ImageSourceResult, modelType?: ModelType): Promise<AnalysisResult> {
    const startTime = Date.now();

    console.log('[ImageAnalysisService] ══════════════════════════');
    console.log('[ImageAnalysisService] 开始AI影像分析...');
    console.log(`[ImageAnalysisService] 来源: ${imageSource.source}`);

    try {
      let analysisResult: AnalysisResult;

      if (this.useRealModel) {
        console.log('  使用真实AI模型进行推理');
        analysisResult = await this.performRealInference(imageSource, modelType);
      } else {
        console.log('  使用Mock模式进行模拟分析');
        analysisResult = await this.performMockAnalysis(imageSource, modelType);
      }

      const processingTime = Date.now() - startTime;

      analysisResult.analysisTimeMs = processingTime;
      analysisResult.timestamp = new Date().toISOString();

      console.log(`[ImageAnalysisService] ✅ 分析完成`);
      console.log(`  耗时: ${processingTime}ms`);
      console.log(`  检出病灶数: ${analysisResult.findings.length}`);
      console.log(`  紧急程度: ${analysisResult.urgencyLevel}`);

      return analysisResult;

    } catch (error) {
      console.error('[ImageAnalysisService] ❌ 分析失败:', error instanceof Error ? error.message : String(error));

      throw new Error(
        `影像分析失败: ${error instanceof Error ? error.message : '未知错误'}`
      );
    }
  }

  renderAnnotationsOnImage(
    imageSource: ImageSourceResult,
    findings: Finding[],
    canvasWidth: number = 400,
    canvasHeight: number = 300
  ): AnnotationData {

    console.log(`[ImageAnalysisService] 渲染${findings.length}个病灶标注`);

    const annotationData: AnnotationData = {
      originalImage: imageSource,
      annotations: findings.map((finding, index): AnnotationItem => ({
        id: `ANNOTATION_${index}`,
        finding: finding,
        style: this.getAnnotationStyle(finding.severity),
        label: `${finding.label} ${(finding.confidence * 100).toFixed(0)}%`,
        bbox: finding.bbox
      })),
      canvasSize: {
        width: canvasWidth,
        height: canvasHeight
      }
    };

    console.log(`[ImageAnalysisService] 标注数据准备完成`);

    return annotationData;
  }

  getSampleImagesList(): SampleImageInfo[] {
    return Array.from(ImageAnalysisService.SAMPLE_IMAGES);
  }

  getSampleImageByIndex(index: number): SampleImageInfo | null {
    if (index >= 0 && index < ImageAnalysisService.SAMPLE_IMAGES.length) {
      return ImageAnalysisService.SAMPLE_IMAGES[index];
    }
    return null;
  }

  setUseRealModel(useReal: boolean): void {
    this.useRealModel = useReal;
    console.log(`[ImageAnalysisService] 模式切换为: ${useReal ? '真实AI模型' : 'Mock模式'}`);
  }

  getModelStatus(): ModelStatus {
    const status: ModelStatus = {
      isLoaded: this.isModelLoaded,
      version: this.modelVersion,
      mode: this.useRealModel ? 'REAL' : 'MOCK'
    };
    return status;
  }

  async performRealInference(imageSource: ImageSourceResult, modelType?: ModelType): Promise<AnalysisResult> {
    console.log('[ImageAnalysisService] 执行真实AI模型推理');

    if (!this.isModelLoaded) {
      console.log('  首次加载模型...');
      await this.loadModel(modelType);
    }

    await new Promise<void>(resolve => setTimeout(resolve, 1500));

    console.log('  模型推理完成');

    const realResult: AnalysisResult = {
      imageType: modelType || 'GENERAL',
      findings: [],
      overallDiagnosis: '真实模型推理结果（待实现）',
      urgencyLevel: 'LOW',
      recommendations: [
        '真实AI模型推理功能开发中...',
        '当前使用Mock数据进行演示'
      ],
      disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业医生诊断为准。',
      analysisTimeMs: 0,
      modelVersion: this.modelVersion,
      timestamp: ''
    };
    return realResult;
  }

  async performMockAnalysis(imageSource: ImageSourceResult, modelType?: ModelType): Promise<AnalysisResult> {
    console.log('[ImageAnalysisService] 执行Mock模拟分析');

    await new Promise<void>(resolve => setTimeout(resolve, 800 + Math.random() * 700));

    let mockResult: AnalysisResult;

    if (imageSource.source === 'sample' && imageSource.sampleInfo !== undefined) {
      console.log(`  使用预设Mock数据: ${imageSource.sampleInfo.name}`);
      
      mockResult = this.getPredefinedMockResult(imageSource.sampleInfo);
    } else {
      console.log('  使用随机生成Mock数据');
      
      mockResult = this.generateRandomMockResult(modelType);
    }

    return mockResult;
  }

  async loadModel(modelType?: ModelType): Promise<void> {
    console.log(`[ImageAnalysisService] 加载AI模型: ${modelType || '通用'}`);

    try {
      await new Promise<void>(resolve => setTimeout(resolve, 500));

      this.isModelLoaded = true;
      this.modelVersion = '2.0.0-Enhanced';

      console.log(`[ImageAnalysisService] ✅ 模型加载成功`);

    } catch (error) {
      console.error('[ImageAnalysisService] 模型加载失败:', error instanceof Error ? error.message : String(error));
      this.isModelLoaded = false;
      if (error instanceof Error) {
        throw error;
      } else {
        throw new Error(String(error));
      }
    }
  }

  private getPredefinedMockResult(sampleInfo: SampleImageInfo): AnalysisResult {
    const mockResults: Record<string, AnalysisResult> = {
      'chest_xray_normal.jpg': {
        imageType: 'CHEST_XRAY',
        findings: [],
        overallDiagnosis: '胸部X线影像未见明显异常。双肺野清晰，心影大小形态正常，膈肌光滑，肋膈角锐利。建议定期体检随访。',
        urgencyLevel: 'LOW',
        recommendations: [
          '✅ 影像表现正常，无需特殊处理',
          '继续保持健康生活方式',
          '建议每年进行一次胸部体检',
          '如有咳嗽、胸痛等不适请及时就医'
        ],
        disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业医生诊断为准。',
        analysisTimeMs: 0,
        modelVersion: '1.0.0-Mock',
        timestamp: ''
      },

      'chest_xray_pneumonia.jpg': {
        imageType: 'CHEST_XRAY',
        findings: [
          {
            label: '肺炎病灶',
            confidence: 0.92,
            bbox: { x: 120, y: 200, width: 180, height: 220 },
            severity: 'HIGH',
            description: '右下肺可见斑片状高密度影，边缘模糊，符合炎症表现。病灶范围约4.5cm×5.5cm。'
          },
          {
            label: '胸腔积液',
            confidence: 0.78,
            bbox: { x: 300, y: 400, width: 150, height: 80 },
            severity: 'MEDIUM',
            description: '右侧肋膈角变钝，提示少量胸腔积液可能。积液深度约15mm。'
          }
        ],
        overallDiagnosis: '考虑右下肺炎症伴少量胸腔积液，建议结合临床症状、实验室检查（血常规、CRP、PCT）及临床体征综合判断，必要时行胸部CT进一步明确诊断。',
        urgencyLevel: 'HIGH',
        recommendations: [
          '🔴 建议尽快就医，完善血常规、CRP、PCT等炎症指标检查',
          '注意休息，保证充足饮水（每日2000ml以上）',
          '监测体温变化，如发热>38.5°C应及时退热并就医',
          '避免劳累，暂停剧烈运动直至症状缓解',
          '遵医嘱合理使用抗生素治疗',
          '3-5天后复查胸部影像学评估治疗效果'
        ],
        disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业医生诊断为准。',
        analysisTimeMs: 0,
        modelVersion: '1.0.0-Mock',
        timestamp: ''
      },

      'ct_lung_nodule.jpg': {
        imageType: 'CT_SCAN',
        findings: [
          {
            label: '肺结节',
            confidence: 0.87,
            bbox: { x: 180, y: 140, width: 60, height: 55 },
            severity: 'MEDIUM',
            description: '左上肺叶可见一实性结节，直径约12mm，边缘尚清，密度均匀，内部未见钙化或空洞。'
          },
          {
            label: '纤维灶',
            confidence: 0.65,
            bbox: { x: 280, y: 280, width: 40, height: 35 },
            severity: 'LOW',
            description: '右下肺胸膜下可见条索状高密度影，考虑陈旧性病变或纤维灶可能性大。'
          }
        ],
        overallDiagnosis: '左上肺结节（约12mm），性质待定。建议结合患者年龄、吸烟史、肿瘤标志物等综合评估，必要时行PET-CT或穿刺活检明确性质。右下肺纤维灶考虑良性改变。',
        urgencyLevel: 'MEDIUM',
        recommendations: [
          '🟡 建议完善肿瘤标志物（CEA、NSE、CYFRA21-1等）检查',
          '有长期吸烟史者应尽快戒烟',
          '3个月后复查胸部CT观察结节变化',
          '如结节增大或出现新发病变，及时就医评估',
          '保持良好生活习惯，避免空气污染环境'
        ],
        disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业医生诊断为准。',
        analysisTimeMs: 0,
        modelVersion: '1.0.0-Mock',
        timestamp: ''
      },

      'skin_lesion_melanoma.jpg': {
        imageType: 'SKIN_LESION',
        findings: [
          {
            label: '恶性黑色素瘤',
            confidence: 0.89,
            bbox: { x: 150, y: 120, width: 100, height: 90 },
            severity: 'HIGH',
            description: '皮肤病变呈不规则形状，边界不清，颜色不均（深浅不一），符合ABCDE法则中的恶性特征。最大径约18mm。'
          },
          {
            label: '色素沉着区',
            confidence: 0.62,
            bbox: { x: 130, y: 100, width: 140, height: 110 },
            severity: 'LOW',
            description: '病变周围可见不规则色素沉着区域，范围较主病灶更大。'
          }
        ],
        overallDiagnosis: '皮肤病变高度怀疑恶性黑色素瘤（恶性程度高）。建议立即至皮肤科或肿瘤科就诊，尽早行病理活检明确诊断，必要时行扩大切除手术及淋巴结评估。',
        urgencyLevel: 'HIGH',
        recommendations: [
          '🔴⚠️ 高度可疑恶性肿瘤，请立即就医！',
          '尽快到正规医院皮肤科就诊，不要自行处理',
          '完善全身检查排除转移（腹部B超、CT、PET-CT等）',
          '避免搔抓、挤压或刺激病变部位',
          '记录病变变化情况（拍照留档）供医生参考',
          '术后需长期随访监测复发和转移'
        ],
        disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业医生诊断和病理检查结果为准。',
        analysisTimeMs: 0,
        modelVersion: '1.0.0-Mock',
        timestamp: ''
      },

      'retina_diabetic.jpg': {
        imageType: 'RETINA',
        findings: [
          {
            label: '微血管瘤',
            confidence: 0.85,
            bbox: { x: 100, y: 80, width: 80, height: 60 },
            severity: 'MEDIUM',
            description: '视网膜后极部可见多个点状红色微血管瘤，数量较多，分布广泛。'
          },
          {
            label: '出血斑',
            confidence: 0.78,
            bbox: { x: 220, y: 150, width: 60, height: 45 },
            severity: 'MEDIUM',
            description: '视网膜深层可见火焰状出血斑，提示血管通透性增加。'
          },
          {
            label: '硬性渗出',
            confidence: 0.72,
            bbox: { x: 180, y: 200, width: 50, height: 40 },
            severity: 'LOW',
            description: '黄斑区附近可见蜡黄色硬性渗出环。'
          }
        ],
        overallDiagnosis: '糖尿病视网膜病变（中度非增殖期）。可见微血管瘤、出血斑及硬性渗出，尚未出现新生血管。建议严格控制血糖血压血脂，定期眼底复查，必要时行激光光凝治疗。',
        urgencyLevel: 'MEDIUM',
        recommendations: [
          '🟡 尽快至眼科专科就诊，进行全面眼底检查',
          '严格控制血糖：空腹血糖<7.0mmol/L，糖化血红蛋白<7%',
          '控制血压：<130/80mmHg',
          '控制血脂：LDL-C<2.6mmol/L',
          '每3-6个月复查眼底照相和OCT检查',
          '如视力下降明显，需警惕黄斑水肿可能'
        ],
        disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业眼科医生诊断为准。',
        analysisTimeMs: 0,
        modelVersion: '1.0.0-Mock',
        timestamp: ''
      }
    };

    const result = mockResults[sampleInfo.name];

    if (!result) {
      console.warn(`[ImageAnalysisService] 未找到预设Mock数据: ${sampleInfo.name}`);
      return this.generateRandomMockResult(sampleInfo.category as ModelType);
    }

    return JSON.parse(JSON.stringify(result));
  }

  private generateRandomMockResult(modelType?: ModelType): AnalysisResult {
    const hasFinding = Math.random() > 0.3;

    const findings: Finding[] = [];

    if (hasFinding) {
      const numFindings = Math.floor(Math.random() * 3) + 1;

      for (let i = 0; i < numFindings; i++) {
        const labels = ['异常阴影', '结节', '渗出', '钙化', '积液', '增厚'];
        const severities: ('HIGH' | 'MEDIUM' | 'LOW')[] = ['HIGH', 'MEDIUM', 'LOW'];

        const findingBbox: BoundingBox = {
          x: Math.floor(Math.random() * 250 + 50),
          y: Math.floor(Math.random() * 180 + 50),
          width: Math.floor(Math.random() * 100 + 40),
          height: Math.floor(Math.random() * 80 + 30)
        };

        const mockFinding: MockFinding = {
          label: labels[Math.floor(Math.random() * labels.length)],
          confidence: parseFloat((0.65 + Math.random() * 0.30).toFixed(2)),
          bbox: findingBbox,
          severity: severities[Math.floor(Math.random() * severities.length)],
          description: '系统检测到影像异常区域，建议进一步检查确认。'
        };
        findings.push(mockFinding as Finding);
      }
    }

    const urgencies: ('CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW')[] = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];
    const selectedUrgency: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW' = hasFinding ?
      urgencies[Math.min(findings.filter(f => f.severity === 'HIGH').length, 3)] :
      'LOW';

    const resultRecommendations: string[] = hasFinding ? [
      '建议携带影像资料至相关科室就诊',
      '结合临床症状和实验室检查综合判断',
      '遵医嘱进行必要的后续检查或治疗',
      '注意观察身体变化，如有不适及时就医'
    ] : [
      '✅ 当前影像未检出明显异常',
      '继续保持健康生活方式',
      '按医嘱定期进行健康体检',
      '如有任何不适请及时就医检查'
    ];

    const mockResult: AnalysisResult = {
      imageType: modelType || 'GENERAL',
      findings: findings,
      overallDiagnosis: hasFinding ?
        '影像显示存在异常发现，建议结合临床资料进一步评估。' :
        '当前影像未见明显异常，建议定期随访复查。',
      urgencyLevel: selectedUrgency,
      recommendations: resultRecommendations,
      disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业医生诊断为准。',
      analysisTimeMs: 0,
      modelVersion: '1.0.0-Mock-Random',
      timestamp: ''
    };

    return mockResult;
  }

  private getAnnotationStyle(severity: FindingSeverity): AnnotationStyle {
    let style: AnnotationStyle;

    switch (severity) {
      case 'HIGH':
        style = {
          strokeColor: '#FF4D4F',
          fillColor: 'rgba(255,77,79,0.12)',
          lineWidth: 3
        };
        break;
      case 'MEDIUM':
        style = {
          strokeColor: '#FAAD14',
          fillColor: 'rgba(250,173,20,0.10)',
          lineWidth: 2
        };
        break;
      case 'LOW':
        style = {
          strokeColor: '#52C41A',
          fillColor: 'rgba(82,196,26,0.08)',
          lineWidth: 1
        };
        break;
      default:
        style = {
          strokeColor: '#999999',
          fillColor: 'rgba(153,153,153,0.05)',
          lineWidth: 1
        };
        break;
    }

    return style;
  }
}
