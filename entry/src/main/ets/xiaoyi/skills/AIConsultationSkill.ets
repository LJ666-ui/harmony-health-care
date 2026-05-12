/**
 * AI智能问诊Skill
 * 触发词: "我不舒服"、"问诊"、"AI医生"、"头疼/肚子疼"
 */

import {
  XiaoyiSkillDefinition,
  XiaoyiSkillRequest,
  XiaoyiSkillResponse
} from '../types/XiaoyiTypes';

export class AIConsultationSkill {

  getDefinition(): XiaoyiSkillDefinition {
    return {
      config: {
        skillId: 'medical.ai.consultation',
        skillName: 'AI智能问诊',
        skillDescription: '启动AI智能体进行医疗问诊，支持症状分析、用药咨询、康复建议等',
        version: '1.0.0',
        author: '星云医疗团队'
      },
      intentPatterns: [
        {
          pattern: '不舒服|难受|身体不适|生病了|看病|问诊',
          confidence: 0.9,
          parameters: ['symptom'],
          examples: ['小艺，我不舒服', '我身体不舒服，帮我问问医生', '我想问诊']
        },
        {
          pattern: '(头|胃|肚子|胸|腰|腿).*(疼|痛|胀|酸)',
          confidence: 0.92,
          parameters: ['symptom'],
          examples: ['我头疼', '肚子疼怎么办', '胸闷气短']
        },
        {
          pattern: 'AI.*问诊|智能.*医生|在线.*咨询',
          confidence: 0.88,
          parameters: [],
          examples: ['打开AI问诊', '找AI医生聊聊', '在线咨询']
        }
      ],
      handler: 'handleAIConsultation',
      needAuth: true,
      responseType: 'voice+ui',
      fallbackAction: 'openAiChatPage',
      estimatedTime: 3000
    };
  }

  async handle(request: XiaoyiSkillRequest): Promise<XiaoyiSkillResponse> {
    const startTime = Date.now();

    try {
      console.info(`[AIConsultationSkill] 处理请求: query=${request.query}`);

      // 提取用户描述的症状
      const symptom = this.extractSymptom(request.query);
      console.info(`[AIConsultationSkill] 提取的症状: ${symptom}`);

      // 调用DeepSeek大模型进行分析（这里应该调用实际的AI服务）
      const aiAnalysis = await this.callDeepSeekForAnalysis(symptom, request.userId);

      // 构建语音回复
      const voiceResponse = this.generateVoiceResponse(symptom, aiAnalysis);

      // 构建UI响应 - 打开AI聊天页面并预填内容
      const uiResponse = {
        pageRoute: 'pages/AiChatPage',
        pageTitle: 'AI智能问诊',
        data: {
          prefillMessage: request.query,
          symptom: symptom,
          initialAnalysis: aiAnalysis,
          sessionId: request.sessionId
        },
        displayMode: 'fullScreen' as const
      };

      return {
        skillId: request.skillId,
        success: true,
        voiceResponse,
        uiResponse,
        action: {
          type: 'navigate',
          target: 'pages/AiChatPage',
          params: { prefillMessage: request.query }
        },
        followUpSuggestions: [
          '查看详细诊断建议',
          '预约挂号',
          '查看相关科普文章'
        ],
        processingTime: Date.now() - startTime
      };
    } catch (error) {
      console.error('[AIConsultationSkill] 处理失败:', error);
      return {
        skillId: request.skillId,
        success: false,
        voiceResponse: '抱歉，AI问诊服务暂时不可用。您可以尝试重新提问，或直接前往医院就诊。',
        processingTime: Date.now() - startTime,
        errorCode: 'AI_SERVICE_ERROR',
        errorMessage: error.message
      };
    }
  }

  private extractSymptom(query: string): string {
    // 简单的提取逻辑（实际可使用NLP）
    const symptoms = ['头疼', '头晕', '发烧', '咳嗽', '胃疼', '肚子疼', '胸闷', '腰疼', '腿疼'];

    for (const s of symptoms) {
      if (query.includes(s)) {
        return s;
      }
    }

    // 如果没有匹配到具体症状，返回整个查询
    return query.replace(/(小艺|帮|我|一下|怎么|怎么办)/g, '').trim() || '身体不适';
  }

  private async callDeepSeekForAnalysis(symptom: string, userId: string): Promise<any> {
    try {
      // 这里应该调用后端的AIClient或前端的SiliconFlowClient
      // 目前返回模拟数据用于演示

      console.info(`[AIConsultationSkill] 调用DeepSeek分析症状: ${symptom}`);

      // 模拟API调用延迟
      await new Promise(resolve => setTimeout(resolve, 1000));

      // 返回模拟的分析结果
      return {
        possibleCauses: [
          '可能原因1：疲劳或睡眠不足',
          '可能原因2：压力过大或情绪紧张',
          '可能原因3：需要进一步检查以明确诊断'
        ],
        recommendations: [
          '建议充分休息，保证7-8小时睡眠',
          '注意观察症状是否持续或加重',
          '如伴有其他不适，请及时就医'
        ],
        riskLevel: 'low', // low, medium, high
        suggestedDepartment: '内科',
        urgency: 'normal' // normal, urgent, emergency
      };
    } catch (error) {
      console.error('[AIConsultationSkill] DeepSeek调用失败:', error);
      return null;
    }
  }

  private generateVoiceResponse(symptom: string, analysis: any): string {
    if (!analysis) {
      return `您说的${symptom}我已经记录下来了，让我为您连接AI医生进行详细分析。`;
    }

    let response = `关于您提到的${symptom}，AI医生初步分析如下：\n\n`;
    response += `可能的原因包括：${analysis.possibleCauses?.join('、') || '需要进一步检查'}。\n\n`;
    response += `建议您：${analysis.recommendations?.[0] || '注意休息'}`;

    if (analysis.riskLevel === 'high') {
      response += '\n\n⚠️ 您的症状可能需要尽快就医，建议您立即拨打120或前往最近的急诊。';
    } else if (analysis.suggestedDepartment) {
      response += `\n\n如需进一步诊疗，建议挂${analysis.suggestedDepartment}。`;
    }

    response += '\n\n已为您打开AI对话界面，您可以继续详细描述症状。';

    return response;
  }
}
