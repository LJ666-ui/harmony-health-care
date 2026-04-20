import { AnalysisResult, Finding, SampleImageInfo } from '../medical/ImageAnalysisService';

export class MedicalImageMock {
  private static instance: MedicalImageMock | null = null;

  private constructor() {}

  static getInstance(): MedicalImageMock {
    if (!MedicalImageMock.instance) {
      MedicalImageMock.instance = new MedicalImageMock();
    }
    return MedicalImageMock.instance;
  }

  getMockAnalysisResult(sampleImageName: string): AnalysisResult {
    const mockResults: Record<string, AnalysisResult> = {
      'chest_xray_normal.jpg': this.getNormalChestXray(),
      'chest_xray_pneumonia.jpg': this.getPneumoniaXray(),
      'ct_lung_nodule.jpg': this.getLungNoduleCT(),
      'skin_lesion_melanoma.jpg': this.getMelanomaSkin(),
      'retina_diabetic.jpg': this.getDiabeticRetina()
    };

    const result = mockResults[sampleImageName];

    if (result) {
      return JSON.parse(JSON.stringify(result));
    }

    console.warn(`[MedicalImageMock] 未找到预设数据: ${sampleImageName}`);
    
    return this.getRandomAnalysisResult();
  }

  getSampleImagesList(): SampleImageInfo[] {
    return [
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
        description: '右下肺炎症伴胸腔积液（高风险示例）',
        path: 'sample_images/chest_xray_pneumonia.jpg'
      },
      {
        id: 'SAMPLE_003',
        name: 'ct_lung_nodule.jpg',
        displayName: '肺结节CT',
        category: 'CT_SCAN',
        icon: '🔬',
        color: '#FAAD14',
        description: '左上肺结节，需进一步评估（中风险示例）',
        path: 'sample_images/ct_lung_nodule.jpg'
      },
      {
        id: 'SAMPLE_004',
        name: 'skin_lesion_melanoma.jpg',
        displayName: '黑色素瘤',
        category: 'SKIN_LESION',
        icon: '🎨',
        color: '#722ED1',
        description: '皮肤恶性黑色素瘤（高风险示例）',
        path: 'sample_images/skin_lesion_melanoma.jpg'
      },
      {
        id: 'SAMPLE_005',
        name: 'retina_diabetic.jpg',
        displayName: '糖尿病视网膜病变',
        category: 'RETINA',
        icon: '👁️',
        color: '#CF1322',
        description: '糖尿病视网膜病变中期（中风险示例）',
        path: 'sample_images/retina_diabetic.jpg'
      }
    ];
  }

  getNormalChestXray(): AnalysisResult {
    return {
      imageType: 'CHEST_XRAY',
      findings: [],
      overallDiagnosis: '胸部X线影像未见明显异常。\n\n双肺野清晰，未见实变影或结节影。心影大小形态正常，心胸比约0.5。双侧膈肌光滑，肋膈角锐利。骨骼结构完整。\n\n结论：胸部X线表现正常。',
      urgencyLevel: 'LOW',
      recommendations: [
        '✅ 影像表现正常，无需特殊处理',
        '继续保持健康生活方式：均衡饮食、适量运动、充足睡眠',
        '建议每年进行一次胸部体检或低剂量CT筛查（尤其吸烟者）',
        '如有咳嗽、咳痰、胸痛、呼吸困难等不适请及时就医',
        '避免长期暴露于空气污染环境或职业粉尘环境'
      ],
      disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业放射科医生诊断报告为准。',
      analysisTimeMs: 1250,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }

  getPneumoniaXray(): AnalysisResult {
    return {
      imageType: 'CHEST_XRAY',
      findings: [
        {
          label: '肺炎病灶',
          confidence: 0.92,
          bbox: { x: 120, y: 200, width: 180, height: 220 },
          severity: 'HIGH',
          description: '右下肺可见斑片状高密度影，边缘模糊，符合炎症性改变。病变范围约4.5cm×5.5cm，累及右下叶大部。'
        },
        {
          label: '胸腔积液',
          confidence: 0.78,
          bbox: { x: 300, y: 400, width: 150, height: 80 },
          severity: 'MEDIUM',
          description: '右侧肋膈角变钝，提示少量胸腔积液可能。估计积液量约100-200ml。'
        }
      ],
      overallDiagnosis: '考虑右下肺炎症伴少量胸腔积液。\n\n影像学特点：\n• 右下肺斑片状实变影，密度不均，边界模糊\n• 支气管充气征阳性\n• 右侧肋膈角变钝\n• 余肺野大致正常\n\n建议结合临床症状（发热、咳嗽、咳痰等）、实验室检查（血常规、CRP、PCT、血培养）及体征综合判断，必要时行胸部CT进一步明确诊断并排除其他疾病（如肺结核、肿瘤等）。',
      urgencyLevel: 'HIGH',
      recommendations: [
        '🔴 建议尽快就医（24-48小时内），优先选择呼吸内科或急诊科',
        '完善实验室检查：血常规+CRP、PCT、血沉、肝肾功能、电解质',
        '如有条件，行胸部HRCT检查明确病变范围和性质',
        '注意休息，保证充足饮水（每日2000ml以上），清淡易消化饮食',
        '监测体温变化：如发热>38.5°C应使用退热药（对乙酰氨基酚/布洛芬）并及时就医',
        '观察症状变化：咳嗽加重、呼吸困难、胸痛、咯血等为警示症状',
        '遵医嘱合理使用抗生素治疗（通常疗程7-14天）',
        '3-5天后复查胸部影像学评估治疗效果',
        '老年人、免疫功能低下者需警惕重症肺炎可能'
      ],
      disclaimer: '⚠️⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。\n\n重要提示：\n1. 肺炎可能危及生命，尤其是老年人和有基础疾病者\n2. 请务必及时就医，遵从专业医生诊疗方案\n3. 本AI分析不能替代专业医疗诊断和治疗决策',
      analysisTimeMs: 1580,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }

  getLungNoduleCT(): AnalysisResult {
    return {
      imageType: 'CT_SCAN',
      findings: [
        {
          label: '肺结节',
          confidence: 0.87,
          bbox: { x: 180, y: 140, width: 60, height: 55 },
          severity: 'MEDIUM',
          description: '左上肺叶尖段可见一实性结节，直径约12mm×11mm，边缘尚清，密度均匀，内部未见钙化或空洞，无毛刺征或分叶征。'
        },
        {
          label: '纤维灶',
          confidence: 0.65,
          bbox: { x: 280, y: 280, width: 40, height: 35 },
          severity: 'LOW',
          description: '右下肺背段胸膜下可见条索状高密度影，邻近胸膜轻度牵拉，考虑陈旧性病变或纤维灶可能性大。'
        }
      ],
      overallDiagnosis: '左上肺结节（约12mm），性质待定；右下肺纤维灶（良性可能大）。\n\n影像学特征分析：\n• 结节位置：左上叶尖段（肺癌好发部位之一）\n• 大小：12mm（处于随访与干预的临界值）\n• 密度：实性结节\n• 边缘：尚清（相对良性特征）\n• 内部特征：无钙化、无空洞、无脂肪密度\n\n根据Fleischner协会指南，该结节属于需要积极评估的范畴。',
      urgencyLevel: 'MEDIUM',
      recommendations: [
        '🟡 建议尽快至胸外科或呼吸内科专科就诊（1-2周内）',
        '完善肿瘤标志物全套：CEA、NSE、CYFRA21-1、SCC-Ag、ProGRP等',
        '详细询问病史：吸烟史（包年数）、职业暴露史、肿瘤家族史、既往肿瘤病史',
        '如为高危人群（年龄>40岁+吸烟>20包年），建议直接行PET-CT评估代谢活性',
        '低危者可先3个月后复查胸部薄层CT（≤1.5mm层厚）对比变化',
        '如结节增大、密度增高或出现恶性征象（毛刺、分叶、胸膜牵拉），应及时活检',
        '有长期吸烟史者应立即戒烟（最重要！）',
        '避免空气污染环境，室内保持通风良好',
        '保持良好生活习惯：规律作息、均衡营养、适度运动',
        '心理调节：大多数肺结节为良性，不必过度焦虑'
      ],
      disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。\n\n特别说明：\n• 肺结节的良恶性判断需要多学科综合评估\n• AI分析仅供参考，最终诊断依赖病理检查\n• 请遵循专业医生的诊疗建议',
      analysisTimeMs: 1420,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }

  getMelanomaSkin(): AnalysisResult {
    return {
      imageType: 'SKIN_LESION',
      findings: [
        {
          label: '恶性黑色素瘤',
          confidence: 0.89,
          bbox: { x: 150, y: 120, width: 100, height: 90 },
          severity: 'HIGH',
          description: '皮肤病变呈不规则形状，边界不清且不对称，颜色不均一（深浅不一，含黑色、棕色、灰色成分）。最大径约18mm×16mm，符合ABCDE法则中的多项恶性特征。'
        },
        {
          label: '色素沉着区',
          confidence: 0.62,
          bbox: { x: 130, y: 100, width: 140, height: 110 },
          severity: 'LOW',
          description: '主病变周围可见不规则色素沉着区域（卫星灶），范围较主病灶更大，提示可能有局部扩散。'
        }
      ],
      overallDiagnosis: '皮肤病变高度怀疑恶性黑色素瘤（高度恶性皮肤肿瘤）。\n\nABCDE法则评估：\n• A（Asymmetry）：不对称 ✓\n• B（Border）：边界不规则/模糊 ✓\n• C（Color）：颜色不均（多种颜色混杂）✓\n• D（Diameter）：直径>6mm（实际约18mm）✓\n• E（Evolution）：近期变化（需临床确认）\n\n恶性风险评分：高（符合4/5项标准）',
      urgencyLevel: 'HIGH',
      recommendations: [
        '🔴⚠️ 高度可疑恶性肿瘤，请立即就医！（强烈建议3天内就诊）',
        '首选科室：皮肤科（有皮肤肿瘤专病门诊更佳）或整形外科',
        '绝对禁止：自行切除、激光冷冻、药物腐蚀等处理！',
        '尽快行病理活检确诊（推荐切除活检而非穿刺活检）',
        '完善全身检查评估分期：\n  - 区域淋巴结超声\n  - 腹部B超或CT\n  - 必要时PET-CT\n  - 血清LDH（乳酸脱氢酶）',
        '确诊后尽早行扩大切除术（切缘1-2cm，视浸润深度而定）',
        '前哨淋巴结活检评估淋巴结转移情况',
        '术后根据分期决定是否需要辅助治疗（免疫治疗、靶向治疗等）',
        '记录病变照片供医生参考，测量大小变化',
        '避免阳光暴晒，做好防晒措施（SPF50+）',
        '术后需终身定期随访监测复发和转移（前2年每3个月一次）',
        '心理支持：黑色素瘤可治愈，早期发现治愈率>90%'
      ],
      disclaimer: '⚠️⚠️⚠️ 本结果由AI辅助生成，仅供参考，绝对不作为最终诊断依据！\n\n重要声明：\n1. 恶性黑色素瘤是高度恶性肿瘤，早期诊治至关重要\n2. 本AI分析仅为初步筛查工具，不能替代专业医生面诊和病理检查\n3. 任何皮肤可疑病变都应由皮肤科医生亲自检查评估\n4. 请勿因本结果过度恐慌或延误就医，尽快寻求专业医疗帮助',
      analysisTimeMs: 1680,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }

  getDiabeticRetina(): AnalysisResult {
    return {
      imageType: 'RETINA',
      findings: [
        {
          label: '微血管瘤',
          confidence: 0.85,
          bbox: { x: 100, y: 80, width: 80, height: 60 },
          severity: 'MEDIUM',
          description: '视网膜后极部（黄斑周围）可见多个点状红色微血管瘤，数量较多（>20个），分布广泛，部分呈串珠样排列。'
        },
        {
          label: '出血斑',
          confidence: 0.78,
          bbox: { x: 220, y: 150, width: 60, height: 45 },
          severity: 'MEDIUM',
          description: '视网膜深层可见火焰状或斑点状出血斑，位于血管弓附近，提示视网膜血管通透性增加和脆性增强。'
        },
        {
          label: '硬性渗出',
          confidence: 0.72,
          bbox: { x: 180, y: 200, width: 50, height: 40 },
          severity: 'LOW',
          description: '黄斑颞侧可见蜡黄色硬性渗出环（环状渗出），提示黄斑区存在慢性水肿可能。'
        }
      ],
      overallDiagnosis: '糖尿病视网膜病变（中度非增殖期，NPDR Moderate）。\n\n国际糖尿病视网膜病变分级标准：\n• 微血管瘤：+++\n• 出血斑：++\n• 硬性渗出：+\n• 棉絮斑：-\n• 新生血管：-\n• IRMA（视网膜内微血管异常）：-\n\n综合判定：中度NPDR，尚未进入增殖期，但已有累及黄斑趋势。',
      urgencyLevel: 'MEDIUM',
      recommendations: [
        '🟡 尽快至眼科专科就诊进行全面眼底检查（建议1周内）',
        '必查项目：\n  - 散瞳眼底检查（金标准）\n  - 眼底照相（彩色+无赤光）\n  - 光学相干断层扫描（OCT）评估黄斑水肿\n  - 荧光素眼底血管造影（FFA）必要时',
        '内分泌科协同管理：\n  - 严格控制血糖：空腹<7.0mmol/L，餐后<10mmol/L，HbA1c<7%\n  - 控制血压：<130/80mmHg\n  - 控制血脂：LDL-C<2.6mmolL，TG<1.7mmol/L',
        '眼科治疗选项（由医生决定）：\n  - 黄斑水肿：抗VEGF玻璃体腔注射 ± 局部激光\n  - 广泛缺血区域：视网膜激光光凝术（PRP）',
        '自我监测：\n  - 每日自测视力（Amsler方格表）\n  - 注意飞蚊症、闪光感、视野缺损等症状\n  - 如视力突然下降，立即急诊',
        '随访频率：\n  - 当前阶段：每3-6个月复查\n  - 如病情进展：缩短至1-3个月\n  - 稳定后：6-12个月',
        '全身管理：\n  - 戒烟限酒\n  - 控制体重（BMI<24）\n  - 规律运动（每周150分钟中等强度）\n  - 定期检测尿微量白蛋白（早期肾病筛查）',
        '教育：了解DR的危害性和可控性，提高依从性'
      ],
      disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。\n\n特别说明：\n• 糖尿病视网膜病变是可防可治的，关键在于早发现早治疗\n• 严格的全身代谢控制是最根本的治疗手段\n• 定期眼底筛查可使严重视力丧失风险降低90%以上\n• 请以专业眼科医生的诊断和治疗建议为准',
      analysisTimeMs: 1350,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }

  getRandomAnalysisResult(): AnalysisResult {
    const hasFinding = Math.random() > 0.35;
    const findings: Finding[] = [];

    if (hasFinding) {
      const numFindings = Math.floor(Math.random() * 3) + 1;
      
      for (let i = 0; i < numFindings; i++) {
        const labels = ['异常阴影', '结节', '渗出', '钙化', '积液', '增厚', '肿块', '溃疡'];
        const severities: ('HIGH' | 'MEDIUM' | 'LOW')[] = ['HIGH', 'MEDIUM', 'LOW'];
        
        findings.push({
          label: labels[Math.floor(Math.random() * labels.length)],
          confidence: parseFloat((0.65 + Math.random() * 0.30).toFixed(2)),
          bbox: {
            x: Math.floor(Math.random() * 250 + 50),
            y: Math.floor(Math.random() * 180 + 50),
            width: Math.floor(Math.random() * 100 + 40),
            height: Math.floor(Math.random() * 80 + 30)
          },
          severity: severities[Math.floor(Math.random() * severities.length)],
          description: '系统检测到影像异常区域，具体性质待进一步检查确认。'
        });
      }
    }

    const urgencies: ('CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW')[] = ['LOW', 'MEDIUM', 'HIGH'];
    const urgencyLevel = hasFinding ?
      urgencies[Math.min(findings.filter(f => f.severity === 'HIGH').length, 2)] :
      'LOW';

    return {
      imageType: 'GENERAL',
      findings: findings,
      overallDiagnosis: hasFinding ?
        '影像显示存在异常发现，建议携带资料至相关科室进一步评估。' :
        '当前影像未检出明显异常，建议定期健康体检。',
      urgencyLevel: urgencyLevel,
      recommendations: hasFinding ? [
        '请携带影像资料至医院相关科室就诊',
        '结合临床症状、体征及实验室检查综合判断',
        '遵医嘱进行必要的后续检查或治疗',
        '注意观察身体变化，如有不适及时就医',
        '保持良好心态，配合医生诊疗'
      ] : [
        '✅ 当前影像未检出明显异常',
        '继续保持健康生活方式',
        '按医嘱定期进行健康体检（每年至少1次）',
        '如有任何身体不适请及时就医检查'
      ],
      disclaimer: '⚠️ 本结果由AI辅助生成，仅供参考，不作为最终诊断依据。请以专业医生诊断为准。',
      analysisTimeMs: Math.floor(900 + Math.random() * 800),
      modelVersion: '1.0.0-Mock-Random',
      timestamp: new Date().toISOString()
    };
  }

  getEdgeCaseResults(): AnalysisResult[] {
    return [
      this.getEmptyFindingResult(),
      this.getMaxFindingsResult(),
      this.getBoundaryConfidenceResult()
    ];
  }

  getEmptyFindingResult(): AnalysisResult {
    return {
      imageType: 'CHEST_XRAY',
      findings: [],
      overallDiagnosis: '影像检查未见明显异常发现。各组织器官结构及密度在正常范围内。',
      urgencyLevel: 'LOW',
      recommendations: ['✅ 未检出异常', '建议定期体检'],
      disclaimer: '⚠️ AI辅助结果，仅供参考。',
      analysisTimeMs: 980,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }

  getMaxFindingsResult(): AnalysisResult {
    const findings: Finding[] = [];
    
    for (let i = 0; i < 8; i++) {
      findings.push({
        label: `异常区域${i + 1}`,
        confidence: parseFloat((0.55 + Math.random() * 0.40).toFixed(2)),
        bbox: {
          x: Math.floor(Math.random() * 300),
          y: Math.floor(Math.random() * 220),
          width: Math.floor(Math.random() * 80 + 20),
          height: Math.floor(Math.random() * 60 + 15)
        },
        severity: i < 3 ? 'HIGH' : i < 6 ? 'MEDIUM' : 'LOW',
        description: `第${i + 1}个异常区域`
      });
    }

    return {
      imageType: 'GENERAL',
      findings: findings,
      overallDiagnosis: '影像显示多处异常发现，情况复杂，需全面评估。',
      urgencyLevel: 'HIGH',
      recommendations: ['多处异常发现，建议尽早就医'],
      disclaimer: '⚠️ AI辅助结果，仅供参考。',
      analysisTimeMs: 2100,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }

  getBoundaryConfidenceResult(): AnalysisResult {
    return {
      imageType: 'SKIN_LESION',
      findings: [
        {
          label: '临界病变',
          confidence: 0.51,
          bbox: { x: 200, y: 150, width: 70, height: 60 },
          severity: 'MEDIUM',
          description: '置信度接近阈值，难以确定良恶性。'
        },
        {
          label: '高置信度异常',
          confidence: 0.99,
          bbox: { x: 100, y: 100, width: 90, height: 80 },
          severity: 'HIGH',
          description: '极高置信度异常。'
        }
      ],
      overallDiagnosis: '包含边界值和高置信度异常的混合情况。',
      urgencyLevel: 'MEDIUM',
      recommendations: ['注意边界值结果的解读'],
      disclaimer: '⚠️ AI辅助结果，仅供参考。',
      analysisTimeMs: 1450,
      modelVersion: '1.0.0-Mock',
      timestamp: new Date().toISOString()
    };
  }
}

export const medicalImageMock = MedicalImageMock.getInstance();
