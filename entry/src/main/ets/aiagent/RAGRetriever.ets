import { RAGSource } from './MedicalAgent';

export interface KnowledgeDocument {
  id: string;
  title: string;
  content: string;
  category: string;
  tags: string[];
  keywords: string[];
}

export interface SearchResult {
  sources: RAGSource[];
  context: string;
}

export class RAGRetriever {
  private knowledgeBase: KnowledgeDocument[] = [];
  private isInitialized: boolean = false;

  constructor() {
    this.initializeKnowledgeBase();
  }

  private initializeKnowledgeBase(): void {
    this.knowledgeBase = [
      {
        id: 'kb_001',
        title: '高血压的预防与控制',
        content: '高血压是常见的慢性病，正常血压应低于140/90mmHg。预防措施包括：1.低盐饮食，每日盐摄入不超过6克；2.规律运动，每周至少150分钟中等强度有氧运动；3.控制体重，BMI保持在18.5-24；4.戒烟限酒；5.保持心情舒畅。治疗需要长期坚持，定期监测血压。',
        category: 'internal_medicine',
        tags: ['慢性病', '心血管', '预防'],
        keywords: ['血压', '高血压', '头晕', '头痛']
      },
      {
        id: 'kb_002',
        title: '糖尿病的饮食管理',
        content: '糖尿病饮食管理要点：1.控制碳水化合物总量，选择低GI食物如全谷物、豆类；2.少食多餐，定时定量进餐；3.增加膳食纤维摄入，多吃蔬菜；4.限制精制糖和含糖饮料；5.适量优质蛋白质。血糖目标：空腹4.4-7.0mmol/L，餐后2小时<10.0mmol/L。',
        category: 'internal_medicine',
        tags: ['慢性病', '代谢', '饮食'],
        keywords: ['糖尿病', '血糖', '饮食', '糖']
      },
      {
        id: 'kb_003',
        title: '外伤处理基本原则',
        content: '外伤处理步骤：1.评估伤情，检查意识、呼吸、脉搏；2.止血，用干净布料压迫伤口；3.清洁伤口，用生理盐水或清水冲洗；4.消毒，使用碘伏消毒周围皮肤；5.包扎，用无菌纱布覆盖固定。注意：深刺伤、动物咬伤、生锈金属划伤需及时就医打破伤风针。',
        category: 'surgery',
        tags: ['外伤', '急救', '处理'],
        keywords: ['外伤', '出血', '伤口', '划伤', '摔伤']
      },
      {
        id: 'kb_004',
        title: '手术前后的注意事项',
        content: '术前准备：1.术前8-12小时禁食禁水；2.告知医生用药史和过敏史；3.做好心理准备；4.术前洗澡清洁。术后护理：1.按医嘱休息，避免剧烈活动；2.观察伤口有无红肿渗液；3.按时换药拆线；4.合理饮食，促进恢复；5.如有发热、剧痛等异常及时就医。',
        category: 'surgery',
        tags: ['手术', '围术期', '护理'],
        keywords: ['手术', '术后', '麻醉', '拆线']
      },
      {
        id: 'kb_005',
        title: '中医体质辨识与调理',
        content: '中医九种体质：平和质（健康）、气虚质（易疲乏）、阳虚质（怕冷）、阴虚质（口干）、痰湿质（肥胖）、湿热质（面油）、血瘀质（肤色暗）、气郁质（情绪低）、特禀质（过敏）。调理原则：辨证施治，因人而异。常用方法：中药调理、针灸推拿、食疗养生、情志调摄。',
        category: 'tcm',
        tags: ['体质', '辨识', '调理'],
        keywords: ['体质', '中医', '调理', '虚实']
      },
      {
        id: 'kb_006',
        title: '常用中药材功效介绍',
        content: '常见中药：人参-大补元气、复脉固脱；黄芪-补气升阳、利水消肿；当归-补血活血、调经止痛；枸杞-滋补肝肾、益精明目；山楂-消食健胃、行气散瘀；红枣-补中益气、养血安神。用药禁忌：孕妇慎用活血化瘀药，感冒期间停服滋补药。',
        category: 'tcm',
        tags: ['中药', '功效', '用法'],
        keywords: ['中药', '药材', '方剂', '煎药']
      },
      {
        id: 'kb_007',
        title: '老年人营养需求与膳食指南',
        content: '老年人营养特点：基础代谢降低，但营养素需求不减少。推荐：1.蛋白质1.0-1.2g/kg体重，优先选择鱼禽蛋奶豆；2.钙1200mg/天，维生素D800-1000IU/天预防骨质疏松；3.膳食纤维25-30g/天改善肠道功能；4.少量多餐，每餐七分饱；5.充足饮水1500-1700ml/天。避免：高盐高糖高脂食物。',
        category: 'nutrition',
        tags: ['老年营养', '膳食', '均衡'],
        keywords: ['营养', '饮食', '膳食', '维生素', '矿物质']
      },
      {
        id: 'kb_008',
        title: '常见疾病的食疗方案',
        content: '食疗建议：高血压-芹菜、菠菜、香蕉富钾食物；糖尿病-苦瓜、秋葵、燕麦低GI食物；失眠-酸枣仁汤、百合莲子粥助眠；便秘-蜂蜜水、火龙果、酸奶润肠通便；贫血-红枣桂圆猪肝汤补血。注意：食疗辅助不能替代药物治疗。',
        category: 'nutrition',
        tags: ['食疗', '食谱', '调理'],
        keywords: ['食疗', '食谱', '养生', '滋补']
      },
      {
        id: 'kb_009',
        title: '康复训练的基本原则',
        content: '康复训练原则：1.循序渐进，从简单到复杂；2.个体化制定方案；3.持之以恒，规律训练；4.安全第一，避免过度疲劳。训练类型：主动运动、被动运动、助力运动、抗阻运动。注意事项：训练前热身5-10分钟，出现不适立即停止，定期评估调整方案。',
        category: 'rehab',
        tags: ['康复', '训练', '原则'],
        keywords: ['康复', '训练', '运动', '锻炼']
      },
      {
        id: 'kb_010',
        title: '运动处方制定指南',
        content: '运动处方五要素：FITT-频率(F)、强度(I)、时间(T)、类型(T)、总量(V)。推荐：有氧运动每周3-5次，每次30-60分钟，心率控制在(220-年龄)×60-80%；抗阻运动每周2-3次，每个肌群8-12次×2-3组；柔韧性训练每天进行。特殊人群需医生指导后开始运动。',
        category: 'rehab',
        tags: ['运动', '处方', '健身'],
        keywords: ['运动', '锻炼', '健身', '有氧', '力量']
      }
    ];

    this.isInitialized = true;
  }

  async search(query: string, specialty?: string, topK: number = 5): Promise<SearchResult> {
    if (!this.isInitialized) {
      this.initializeKnowledgeBase();
    }

    const queryLower: string = query.toLowerCase();
    const scoredDocuments: Array<{ doc: KnowledgeDocument; score: number }> = [];

    for (const doc of this.knowledgeBase) {
      if (specialty && !this.matchesSpecialty(doc.category, specialty)) {
        continue;
      }

      let score: number = this.calculateSimilarity(queryLower, doc);

      if (score > 0) {
        scoredDocuments.push({ doc, score });
      }
    }

    scoredDocuments.sort((a, b) => b.score - a.score);

    const topResults: Array<{ doc: KnowledgeDocument; score: number }> = scoredDocuments.slice(0, topK);

    const sources: RAGSource[] = topResults.map(result => ({
      id: result.doc.id,
      title: result.doc.title,
      content: result.doc.content,
      similarity: result.score,
      category: result.doc.category
    }));

    let context: string = '';
    if (sources.length > 0) {
      context = '以下是从知识库中检索到的相关内容：\n\n';
      for (const source of sources) {
        context += `【${source.title}】\n${source.content}\n\n`;
      }
    }

    return { sources, context };
  }

  private calculateSimilarity(query: string, doc: KnowledgeDocument): number {
    let score: number = 0;

    for (const keyword of doc.keywords) {
      if (query.indexOf(keyword) >= 0) {
        score += 0.3;
      }
    }

    for (const tag of doc.tags) {
      if (query.indexOf(tag) >= 0) {
        score += 0.15;
      }
    }

    if (query.indexOf(doc.title.substring(0, 3)) >= 0) {
      score += 0.2;
    }

    const queryWords: string[] = query.split(/\s+/);
    for (const word of queryWords) {
      if (word.length >= 2 && doc.content.indexOf(word) >= 0) {
        score += 0.05;
      }
    }

    return Math.min(score, 1.0);
  }

  private matchesSpecialty(docCategory: string, targetSpecialty: string): boolean {
    const specialtyMap: Record<string, string[]> = {
      'internal_medicine': ['internal_medicine', '内科', 'internal'],
      'surgery': ['surgery', '外科', 'surgical'],
      'tcm': ['tcm', '中医', 'chinese'],
      'nutrition': ['nutrition', '营养', 'dietary'],
      'rehab': ['rehab', '康复', 'rehabilitation']
    };

    const matchingCategories: string[] | undefined = specialtyMap[targetSpecialty];
    if (!matchingCategories) return true;

    return matchingCategories.indexOf(docCategory) >= 0;
  }

  addDocument(document: KnowledgeDocument): void {
    this.knowledgeBase.push(document);
  }

  getKnowledgeBaseSize(): number {
    return this.knowledgeBase.length;
  }
}
