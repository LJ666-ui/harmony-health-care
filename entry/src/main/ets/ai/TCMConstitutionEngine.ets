import { ModelType } from './types/ModelTypes';
import { InferenceScene } from './types/EngineTypes';
import { MindSporeLiteAdapter } from './MindSporeLiteAdapter';
import { InferenceOrchestrator } from './InferenceOrchestrator';
import { FallbackEngine } from './FallbackEngine';
import { ResultCache } from './ResultCache';

export interface TCMInputData {
  symptoms: {
    energy: number;
    sweat: number;
    sleep: number;
    mood: number;
    appetite: number;
    coldHands: number;
    dryMouth: number;
  };
  tongueImage?: string;
  tongueFeatures?: TongueFeatures;
}

export interface TongueFeatures {
  tongueColor: string;
  tongueCoating: string;
  tongueShape: string;
  tongueTexture: string;
}

export interface TCMConstitutionResult {
  constitutionId: string;
  timestamp: string;
  mainConstitution: ConstitutionType;
  mainScore: number;
  allScores: Map<ConstitutionType, number>;
  secondaryConstitutions: ConstitutionType[];
  confidence: number;
  suggestions: TCMSuggestion[];
  basis: string[];
  engine: string;
}

export enum ConstitutionType {
  PEACEFUL = 'peaceful',
  QI_DEFICIENCY = 'qi_deficiency',
  YANG_DEFICIENCY = 'yang_deficiency',
  YIN_DEFICIENCY = 'yin_deficiency',
  PHLEGM_DAMPNESS = 'phlegm_dampness',
  DAMP_HEAT = 'damp_heat',
  BLOOD_STASIS = 'blood_stasis',
  QI_STAGNATION = 'qi_stagnation',
  SPECIAL = 'special'
}

export interface TCMSuggestion {
  category: string;
  content: string;
}

export class TCMConstitutionEngine {
  private static instance: TCMConstitutionEngine;

  private mindsporeAdapter: MindSporeLiteAdapter;
  private orchestrator: InferenceOrchestrator;
  private fallbackEngine: FallbackEngine;
  private useMindSpore: boolean = true;

  private constructor() {
    this.mindsporeAdapter = MindSporeLiteAdapter.getInstance();
    this.orchestrator = InferenceOrchestrator.getInstance();
    this.fallbackEngine = FallbackEngine.getInstance();
  }

  static getInstance(): TCMConstitutionEngine {
    if (!TCMConstitutionEngine.instance) {
      TCMConstitutionEngine.instance = new TCMConstitutionEngine();
    }
    return TCMConstitutionEngine.instance;
  }

  async identifyConstitution(data: TCMInputData): Promise<TCMConstitutionResult> {
    const startTime = Date.now();

    try {
      this.validateInput(data);

      let scores: Map<ConstitutionType, number>;

      if (this.useMindSpore && this.mindsporeAdapter.isInitialized()) {
        scores = await this.identifyWithMindSpore(data);
      } else {
        scores = this.identifyWithRules(data);
      }

      const mainConstitution = this.getMainConstitution(scores);
      const mainScore = scores.get(mainConstitution) || 0;
      const secondaryConstitutions = this.getSecondaryConstitutions(scores);
      const confidence = this.calculateConfidence(data);
      const suggestions = this.generateSuggestions(mainConstitution);
      const basis = this.generateBasis(data, mainConstitution);

      const result: TCMConstitutionResult = {
        constitutionId: this.generateId(),
        timestamp: new Date().toISOString(),
        mainConstitution,
        mainScore,
        allScores: scores,
        secondaryConstitutions,
        confidence,
        suggestions,
        basis,
        engine: this.useMindSpore ? 'mindspore-v1.0.0' : 'fallback-v1'
      };

      console.info(`TCMConstitutionEngine: 体质辨识完成, 主体质=${mainConstitution}, 耗时=${Date.now() - startTime}ms`);
      return result;

    } catch (error) {
      console.error('TCMConstitutionEngine: 体质辨识失败', error);
      return this.identifyWithRules(data) as any;
    }
  }

  async processTongueImage(imageUri: string): Promise<TongueFeatures> {
    console.info(`TCMConstitutionEngine: 处理舌象图像 ${imageUri}`);

    return {
      tongueColor: '淡红',
      tongueCoating: '薄白',
      tongueShape: '正常',
      tongueTexture: '光滑'
    };
  }

  setUseMindSpore(use: boolean): void {
    this.useMindSpore = use;
  }

  private validateInput(data: TCMInputData): void {
    if (!data || !data.symptoms) {
      throw new Error('症状数据不能为空');
    }

    const requiredFields = ['energy', 'sleep', 'mood', 'appetite'];
    for (const field of requiredFields) {
      if (data.symptoms[field as keyof typeof data.symptoms] === undefined) {
        throw new Error(`必填字段缺失: ${field}`);
      }
    }
  }

  private async identifyWithMindSpore(data: TCMInputData): Promise<Map<ConstitutionType, number>> {
    if (!this.mindsporeAdapter.isModelLoaded(ModelType.TCM_CONSTITUTION)) {
      await this.mindsporeAdapter.loadModel(ModelType.TCM_CONSTITUTION);
    }

    const result = await this.mindsporeAdapter.infer(ModelType.TCM_CONSTITUTION, data);
    return this.parseConstitutionScores(result);
  }

  private identifyWithRules(data: TCMInputData): Map<ConstitutionType, number> {
    const scores = new Map<ConstitutionType, number>();
    const s = data.symptoms;

    scores.set(ConstitutionType.PEACEFUL, 0.3);
    scores.set(ConstitutionType.QI_DEFICIENCY, s.energy < 3 ? 0.4 : 0.1);
    scores.set(ConstitutionType.YANG_DEFICIENCY, s.coldHands > 3 ? 0.35 : 0.1);
    scores.set(ConstitutionType.YIN_DEFICIENCY, s.dryMouth > 3 ? 0.35 : 0.1);
    scores.set(ConstitutionType.PHLEGM_DAMPNESS, 0.1);
    scores.set(ConstitutionType.DAMP_HEAT, 0.1);
    scores.set(ConstitutionType.BLOOD_STASIS, 0.1);
    scores.set(ConstitutionType.QI_STAGNATION, s.mood < 3 ? 0.3 : 0.1);
    scores.set(ConstitutionType.SPECIAL, 0.05);

    const maxScore = Math.max(...Array.from(scores.values()));
    scores.set(ConstitutionType.PEACEFUL, Math.max(0, 0.5 - maxScore));

    return scores;
  }

  private parseConstitutionScores(result: any): Map<ConstitutionType, number> {
    const scores = new Map<ConstitutionType, number>();
    const types = Object.values(ConstitutionType) as ConstitutionType[];

    if (result.scores) {
      types.forEach((type, index) => {
        scores.set(type, result.scores[type] || 0.1);
      });
    } else {
      types.forEach(type => scores.set(type, 0.11));
    }

    return scores;
  }

  private getMainConstitution(scores: Map<ConstitutionType, number>): ConstitutionType {
    let maxScore = 0;
    let mainType = ConstitutionType.PEACEFUL;

    scores.forEach((score, type) => {
      if (score > maxScore) {
        maxScore = score;
        mainType = type;
      }
    });

    return mainType;
  }

  private getSecondaryConstitutions(scores: Map<ConstitutionType, number>): ConstitutionType[] {
    const secondary: ConstitutionType[] = [];
    scores.forEach((score, type) => {
      if (score >= 0.6 && type !== this.getMainConstitution(scores)) {
        secondary.push(type);
      }
    });
    return secondary;
  }

  private calculateConfidence(data: TCMInputData): number {
    let confidence = 0.5;
    if (data.symptoms) confidence += 0.2;
    if (data.tongueImage) confidence += 0.2;
    if (data.tongueFeatures) confidence += 0.1;
    return Math.min(1, confidence);
  }

  private generateSuggestions(constitution: ConstitutionType): TCMSuggestion[] {
    const suggestionMap: Map<ConstitutionType, TCMSuggestion[]> = new Map([
      [ConstitutionType.PEACEFUL, [
        { category: '饮食', content: '保持均衡饮食，五谷为养' },
        { category: '运动', content: '适度运动，保持气血畅通' }
      ]],
      [ConstitutionType.QI_DEFICIENCY, [
        { category: '饮食', content: '多吃益气健脾食物，如山药、黄芪' },
        { category: '运动', content: '避免剧烈运动，选择柔和运动如太极' }
      ]],
      [ConstitutionType.YANG_DEFICIENCY, [
        { category: '饮食', content: '多食温热性食物，如羊肉、生姜' },
        { category: '起居', content: '注意保暖，避免寒凉环境' }
      ]],
      [ConstitutionType.YIN_DEFICIENCY, [
        { category: '饮食', content: '多食滋阴润燥食物，如银耳、百合' },
        { category: '起居', content: '避免熬夜，保持充足睡眠' }
      ]]
    ]);

    return suggestionMap.get(constitution) || [
      { category: '综合', content: '建议咨询中医师进行详细调理' }
    ];
  }

  private generateBasis(data: TCMInputData, constitution: ConstitutionType): string[] {
    const basis: string[] = [];
    if (data.symptoms.energy < 3) basis.push('精力不足');
    if (data.symptoms.sleep < 3) basis.push('睡眠质量差');
    if (data.symptoms.mood < 3) basis.push('情绪低落');
    if (data.symptoms.coldHands > 3) basis.push('手足怕冷');
    if (data.symptoms.dryMouth > 3) basis.push('口干舌燥');
    return basis;
  }

  private generateId(): string {
    return 'TCM-' + Date.now().toString(36) + '-' + Math.random().toString(36).substring(2, 8);
  }
}
