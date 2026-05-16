/**
 * S2 - AI智能问诊技能
 * 
 * 属性 | 属性值
 * Skill ID | 医疗.ai.consultation
 * Skill 名称 | AI 智能问诊
 * 触发描述 | "我头疼"、"头疼怎么办"、"打开 AI 问诊"、"身体不适"
 * 处理流程 | 提取症状 → 调用 DeepSeek 分析 → 生成生活建议回复 → 打开 AiChatPage
 * 预计耗时 | ~3000ms (含 API 调用)
 * 触发动作 | 打开 AiChatPage 引导用户手动输入
 */

import { router } from '@kit.ArkUI';
import { symptomAnalysisPrompt } from '../../skill-offline-package/prompts/symptom_analysis';
import { AIService } from '../services/AIService';

interface SymptomInfo {
  mainSymptom: string;
  duration?: string;
  severity?: 'mild' | 'moderate' | 'severe';
  accompanyingSymptoms?: string[];
  additionalInfo?: string;
}

interface ConsultationResult {
  possibleCauses: Array<{ cause: string; probability: number }>;
  recommendations: string[];
  urgencyLevel: 'low' | 'medium' | 'high' | 'emergency';
  shouldSeeDoctor: boolean;
  suggestedDepartment?: string;
  lifestyleAdvice: string;
  disclaimer: string;
}

export class AIConsultationSkill {
  private static readonly SKILL_ID = '医疗.ai.consultation';
  
  /**
   * 检查是否匹配该技能
   */
  static match(query: string): boolean {
    const triggers = [
      '我头疼', '头疼怎么办', '头痛',
      '肚子疼', '胃疼', '腹痛',
      '发烧', '咳嗽', '恶心', '呕吐',
      '不舒服', '难受', '身体不适',
      '看医生', '问诊', '看病',
      '打开 AI 问诊', 'AI 问诊', '智能问诊',
      '我感觉', '我觉得', '好像得了'
    ];
    
    return triggers.some(trigger => query.includes(trigger));
  }

  /**
   * 执行AI智能问诊
   */
  static async execute(query: string): Promise<ConsultationResult> {
    // 步骤1：提取症状信息
    const symptomInfo = this.extractSymptoms(query);
    
    // 步骤2：紧急情况检测
    if (this.isEmergency(symptomInfo)) {
      return this.generateEmergencyResponse();
    }
    
    // 步骤3：调用DeepSeek分析
    try {
      const analysisResult = await this.callDeepSeekAnalysis(symptomInfo);
      
      // 步骤4：生成结构化回复
      return this.formatConsultationResponse(analysisResult, symptomInfo);
      
    } catch (error) {
      console.error('AI问诊分析失败:', error);
      return this.generateFallbackResponse(symptomInfo);
    }
  }

  /**
   * 从用户输入中提取症状信息
   */
  private static extractSymptoms(query: string): SymptomInfo {
    const symptomPatterns = {
      headache: /头疼|头痛|头晕|眩晕/,
      stomachache: /肚(子)?疼|胃疼|腹痛|腹泻/,
      fever: /发烧|发热|体温高/,
      cough: /咳嗽|咳嗦|嗓子疼|咽痛/,
      nausea: /恶心|呕吐|想吐/,
      fatigue: /疲劳|乏力|没劲|累/,
      chestPain: /胸闷|胸痛|心慌/
    };

    let mainSymptom = '';
    const accompanyingSymptoms: string[] = [];

    for (const [symptom, pattern] of Object.entries(symptomPatterns)) {
      if (pattern.test(query)) {
        if (!mainSymptom) {
          mainSymptom = symptom;
        } else {
          accompanyingSymptoms.push(symptom);
        }
      }
    }

    // 提取持续时间
    const durationMatch = query.match(/(\d+)(天|小时|周|月)/);
    const duration = durationMatch ? durationMatch[0] : undefined;

    // 提取严重程度
    let severity: 'mild' | 'moderate' | 'severe' = 'mild';
    if (query.includes('严重') || query.includes('剧烈') || query.includes('受不了')) {
      severity = 'severe';
    } else if (query.includes('有点') || query.includes('稍微') || query.includes('有些')) {
      severity = 'mild';
    } else {
      severity = 'moderate';
    }

    return {
      mainSymptom: mainSymptom || 'general_discomfort',
      duration,
      severity,
      accompanyingSymptoms: accompanyingSymptoms.length > 0 ? accompanyingSymptoms : undefined,
      additionalInfo: query
    };
  }

  /**
   * 紧急情况检测
   */
  private static isEmergency(symptomInfo: SymptomInfo): boolean {
    const emergencyKeywords = [
      '胸痛', '呼吸困难', '窒息', '意识不清', '昏迷',
      '大出血', '吐血', '便血', '休克',
      '中毒', '过敏反应', '过敏性休克',
      '自杀', '自残', '不想活'
    ];

    return emergencyKeywords.some(keyword => 
      symptomInfo.additionalInfo?.includes(keyword) ||
      symptomInfo.mainSymptom.includes(keyword)
    );
  }

  /**
   * 生成紧急响应
   */
  private static generateEmergencyResponse(): ConsultationResult {
    return {
      possibleCauses: [{ cause: '需要紧急医疗关注', probability: 100 }],
      recommendations: [
        '🚨 立即拨打急救电话 120',
        '🏥 前往最近的急诊科',
        '⛔ 不要驾车，让他人送医或叫救护车',
        '📱 告知家人您的位置'
      ],
      urgencyLevel: 'emergency',
      shouldSeeDoctor: true,
      suggestedDepartment: '急诊科',
      lifestyleAdvice: '在等待救援时保持冷静，松开紧身衣物',
      disclaimer: '⚠️ 您的情况可能危及生命，请立即寻求专业医疗帮助！'
    };
  }

  /**
   * 调用DeepSeek进行症状分析
   */
  private static async callDeepSeekAnalysis(symptomInfo: SymptomInfo): Promise<any> {
    const prompt = symptomAnalysisPrompt
      .replace('{SYMPTOM}', symptomInfo.mainSymptom)
      .replace('{DURATION}', symptomInfo.duration || '未知')
      .replace('{SEVERITY}', symptomInfo.severity)
      .replace('{ACCOMPANYING}', symptomInfo.accompanyingSymptoms?.join(', ') || '无');

    const aiService = AIService.getInstance();
    const response = await aiService.chat(prompt);

    return JSON.parse(response);
  }

  /**
   * 格式化问诊响应
   */
  private static formatConsultationResponse(analysis: any, symptomInfo: SymptomInfo): ConsultationResult {
    return {
      possibleCauses: analysis.possibleCauses || [],
      recommendations: analysis.recommendations || [],
      urgencyLevel: analysis.urgencyLevel || 'medium',
      shouldSeeDoctor: analysis.shouldSeeDoctor || false,
      suggestedDepartment: analysis.suggestedDepartment,
      lifestyleAdvice: analysis.lifestyleAdvice || '注意休息，多喝水',
      disclaimer: '⚕️ 本AI助手提供的建议仅供参考，不能替代专业医生诊断。如症状持续或加重，请及时就医。'
    };
  }

  /**
   * 降级响应（当API调用失败时）
   */
  private static generateFallbackResponse(symptomInfo: SymptomInfo): ConsultationResult {
    const symptomName = this.getSymptomDisplayName(symptomInfo.mainSymptom);
    
    return {
      possibleCauses: [{ cause: `${symptomName}可能由多种原因引起`, probability: 0 }],
      recommendations: [
        '注意休息，保证充足睡眠',
        '多喝温水',
        '观察症状变化',
        '如症状持续超过3天，建议就医'
      ],
      urgencyLevel: 'low',
      shouldSeeDoctor: false,
      lifestyleAdvice: '保持良好的作息和饮食习惯',
      disclaimer: '⚠️ AI服务暂时不可用，以上为通用建议。如感不适，请及时就医。'
    };
  }

  /**
   * 获取症状的中文名称
   */
  private static getSymptomDisplayName(symptom: string): string {
    const names: Record<string, string> = {
      headache: '头痛',
      stomachache: '腹痛',
      fever: '发热',
      cough: '咳嗽',
      nausea: '恶心呕吐',
      fatigue: '疲劳乏力',
      chestPain: '胸闷胸痛',
      general_discomfort: '身体不适'
    };
    return names[symptom] || symptom;
  }

  /**
   * 打开AiChatPage引导用户深入交互
   */
  static openAiChatPage(initialQuery?: string): void {
    router.pushUrl({
      url: 'pages/AiChatPage',
      params: {
        initialQuery: initialQuery || '',
        skillId: this.SKILL_ID
      }
    });
  }

  /**
   * 格式化输出给用户
   */
  static formatResult(result: ConsultationResult): string {
    let output = `🩺 **AI智能问诊结果**\n\n`;
    
    // 可能的原因
    if (result.possibleCauses.length > 0) {
      output += `🔍 **可能原因**:\n`;
      result.possibleCauses.forEach((cause, index) => {
        output += `${index + 1}. ${cause.cause} (${cause.probability}%)\n`;
      });
      output += '\n';
    }
    
    // 建议
    if (result.recommendations.length > 0) {
      output += `💡 **建议措施**:\n`;
      result.recommendations.forEach(rec => {
        output += `• ${rec}\n`;
      });
      output += '\n';
    }
    
    // 生活建议
    if (result.lifestyleAdvice) {
      output += `🌿 **生活调理**: ${result.lifestyleAdvice}\n\n`;
    }
    
    // 就医建议
    if (result.shouldSeeDoctor) {
      output += `🏥 **就医建议**: 建议前往${result.suggestedDepartment || '相关科室'}就诊\n\n`;
    }
    
    // 免责声明
    output += `${result.disclaimer}\n\n`;
    
    // 继续对话引导
    output += `💬 需要更详细的问诊？点击进入"AI智能问诊"页面继续对话`;
    
    return output;
  }
}
