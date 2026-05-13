/**
 * AI 统一调度层 (AI Orchestrator)
 * 统一管理所有AI能力的调用和协调
 *
 * 架构设计:
 * ┌─────────────────────────────────────────────┐
 * │              用户交互层                      │
 * │  (小艺语音 / UI界面 / API调用)               │
 * └──────────────────┬──────────────────────────┘
 *                    │
 * ┌──────────────────▼──────────────────────────┐
 * │           AI Orchestrator                    │
 * │  (统一入口 / 智能路由 / 结果聚合)             │
 * └─┬────────┬───────┬──────────┬───────────────┘
 *   │        │       │          │
 *   ▼        ▼       ▼          ▼
 * ┌──────┐┌──────┐┌──────┐  ┌──────────┐
 * │ 小艺  ││DeepSeek││ Coze │  │MindSpore/HiAI│
 * │ Skill ││(硅基流动)││ Bot  │  │(端侧推理)    │
 * └──────┘└──────┘└──────┘  └──────────┘
 *
 * 使用示例:
 * ```typescript
 * const orchestrator = new AIOrchestrator();
 *
 * // 统一处理用户请求
 * const result = await orchestrator.processRequest({
 *   type: 'symptom_analysis',
 *   query: '头疼，持续3天',
 *   userId: 'user_123'
 * });
 * ```
 */

import { xiaoyiSkillManager } from '../xiaoyi/XiaoyiSkillManager';
import { siliconFlowClient, deepSeekChatManager } from '../deepseek/SiliconFlowClient';
import { cozeApiClient } from '../coze/CozeApiClient';
import { mindSporeEngine } from '../mindsphere/MindSporeLiteEngine';
import { hiAIVisionClient } from '../hiai/HiAIVisionClient';

export interface AIRequest {
  type: 'voice_command' | 'chat' | 'risk_assessment' | 'image_analysis' | 'emergency';
  query?: string;
  userId: string;
  sessionId?: string;
  data?: any;
  source?: 'xiaoyi' | 'ui' | 'api' | 'device';
}

export interface AIResponse {
  success: boolean;
  voiceResponse?: string;
  uiData?: any;
  action?: {
    type: 'navigate' | 'alert' | 'call' | 'notify';
    target?: string;
    params?: any;
  };
  aiSource: string;         // 标记使用了哪个AI能力
  processingTime: number;
  metadata?: Record<string, any>;
}

export class AIOrchestrator {
  private static instance: AIOrchestrator | null = null;

  private constructor() {}

  public static getInstance(): AIOrchestrator {
    if (AIOrchestrator.instance === null) {
      AIOrchestrator.instance = new AIOrchestrator();
    }
    return AIOrchestrator.instance;
  }

  /**
   * 初始化所有AI组件
   */
  async initialize(): Promise<void> {
    console.info('[AI-Orch] 正在初始化AI统一调度层...');

    try {
      // 并行初始化各组件
      await Promise.all([
        xiaoyiSkillManager.initialize(),
        mindSporeEngine.initialize(),
        hiAIVisionClient.initialize()
      ]);

      console.info('[AI-Orch] 所有AI组件初始化完成');
    } catch (error) {
      console.error('[AI-Orch] 部分组件初始化失败:', error);
      // 不阻断，允许部分功能降级运行
    }
  }

  /**
   * 统一处理请求（主入口）
   */
  async processRequest(request: AIRequest): Promise<AIResponse> {
    const startTime = Date.now();

    console.info(`[AI-Orch] 处理请求: type=${request.type}, source=${request.source || 'unknown'}`);

    try {
      let response: AIResponse;

      switch (request.type) {
        case 'voice_command':
          response = await this.handleVoiceCommand(request);
          break;

        case 'chat':
          response = await this.handleChat(request);
          break;

        case 'risk_assessment':
          response = await this.handleRiskAssessment(request);
          break;

        case 'image_analysis':
          response = await this.handleImageAnalysis(request);
          break;

        case 'emergency':
          response = await this.handleEmergency(request);
          break;

        default:
          response = this.createErrorResponse('UNKNOWN_REQUEST_TYPE', `未知请求类型: ${request.type}`);
      }

      response.processingTime = Date.now() - startTime;
      return response;
    } catch (error) {
      console.error('[AI-Orch] 处理请求失败:', error);
      return {
        success: false,
        aiSource: 'error',
        processingTime: Date.now() - startTime,
        metadata: { error: error.message }
      };
    }
  }

  /**
   * 处理语音命令（小艺入口）
   */
  private async handleVoiceCommand(request: AIRequest): Promise<AIResponse> {
    if (!request.query) {
      return this.createErrorResponse('MISSING_QUERY', '缺少查询内容');
    }

    console.info(`[AI-Orch] 处理语音命令: ${request.query}`);

    // 使用小艺Skill管理器自动路由和处理
    const xiaoyiResponse = await xiaoyiSkillManager.autoRouteAndProcess(
      request.query,
      request.userId,
      request.sessionId
    );

    return {
      success: xiaoyiResponse.success,
      voiceResponse: xiaoyiResponse.voiceResponse,
      uiData: xiaoyiResponse.uiResponse,
      action: xiaoyiResponse.action,
      aiSource: 'xiaoyi_skill',
      processingTime: 0,
      metadata: {
        skillId: xiaoyiResponse.skillId,
        followUpSuggestions: xiaoyiResponse.followUpSuggestions
      }
    };
  }

  /**
   * 处理聊天请求（DeepSeek + Coze）
   */
  private async handleChat(request: AIRequest): Promise<AIResponse> {
    if (!request.query) {
      return this.createErrorResponse('MISSING_QUERY', '缺少聊天内容');
    }

    console.info(`[AI-Orch] 处理聊天请求`);

    // 根据内容复杂度选择AI引擎
    const isComplexQuery = this.isComplexMedicalQuery(request.query);

    let responseText: string;
    let aiSource: string;

    if (isComplexQuery && request.data?.specialty) {
      // 复杂专科问题 -> 使用Coze专业Bot
      console.info('[AI-Orch] 使用Coze专科Bot');
      responseText = await this.routeToCozeBot(request.query, request.data.specialty, request.userId);
      aiSource = 'coze_bot';
    } else {
      // 一般问题 -> 使用DeepSeek大模型
      console.info('[AI-Orch] 使用DeepSeek大模型');
      responseText = await deepSeekChatManager.analyzeSymptom(
        request.query,
        request.data?.age || 45,
        request.data?.gender || '未知'
      );
      aiSource = 'deepseek';
    }

    return {
      success: true,
      voiceResponse: responseText,
      uiData: { message: responseText },
      aiSource,
      processingTime: 0
    };
  }

  /**
   * 处理风险评估（MindSpore端侧）
   */
  private async handleRiskAssessment(request: AIRequest): Promise<AIResponse> {
    if (!request.data?.healthData) {
      return this.createErrorResponse('MISSING_HEALTH_DATA', '缺少健康数据');
    }

    console.info(`[AI-Orch] 执行风险评估`);

    // 使用MindSpore进行端侧推理
    const riskResult = await mindSporeEngine.assessRisk(request.data.healthData);

    return {
      success: true,
      voiceResponse: this.formatRiskVoiceResponse(riskResult),
      uiData: riskResult,
      action: {
        type: 'navigate',
        target: 'pages/RiskDetailPage',
        params: { result: riskResult }
      },
      aiSource: 'mindspore_lite',
      processingTime: 0,
      metadata: {
        overallLevel: riskResult.overallLevel,
        suggestions: riskResult.suggestions
      }
    };
  }

  /**
   * 处理图像分析（HiAI视觉）
   */
  private async handleImageAnalysis(request: AIRequest): Promise<AIResponse> {
    if (!request.data?.imageUri) {
      return this.createErrorResponse('MISSING_IMAGE', '缺少图像数据');
    }

    console.info(`[AI-Orch] 执行图像分析`);

    // 使用HiAI进行视觉分析
    const analysisResult = await hiAIVisionClient.analyzeMedicalImage(request.data.imageUri);

    return {
      success: true,
      voiceResponse: `影像类型识别为${analysisResult.classification.label}，置信度${(analysisResult.classification.confidence * 100).toFixed(1)}%`,
      uiData: analysisResult,
      aiSource: 'hiai_vision',
      processingTime: 0
    };
  }

  /**
   * 处理紧急情况
   */
  private async handleEmergency(request: AIRequest): Promise<AIResponse> {
    console.warn(`[AI-Orch] ⚠️ 紧急情况处理!`);

    const emergencyType = request.data?.type || 'sos';

    switch (emergencyType) {
      case 'fall_detected':
        return {
          success: true,
          voiceResponse: '检测到跌倒！正在通知紧急联系人并拨打急救电话...',
          action: {
            type: 'call',
            target: 'emergency_sos',
            params: { reason: 'fall_detection' }
          },
          aiSource: 'emergency_system',
          processingTime: 0
        };

      case 'vital_signs_abnormal':
        return {
          success: true,
          voiceResponse: '检测到生命体征异常！建议立即就医或联系医生。',
          action: {
            type: 'alert',
            target: 'abnormal_alert',
            params: { data: request.data }
          },
          aiSource: 'mindspore_anomaly',
          processingTime: 0
        };

      default:
        return {
          success: true,
          voiceResponse: '已收到您的求助信号，正在为您连接紧急服务...',
          action: {
            type: 'call',
            target: 'emergency_hotline'
          },
          aiSource: 'emergency_system',
          processingTime: 0
        };
    }
  }

  /**
   * 智能路由到Coze Bot
   */
  private async routeToCozeBot(query: string, specialty: string, userId: string): Promise<string> {
    switch (specialty.toLowerCase()) {
      case 'internal':
      case '内科':
        return cozeApiClient.consultInternalMedicine(query, request.data?.patientInfo || {});

      case 'ophthalmology':
      case '眼科':
        return cozeApiClient.consultOphthalmology(query, request.data?.visionData);

      case 'rehabilitation':
      case '康复':
        return cozeApiClient.consultRehabilitation(query, request.data?.surgeryInfo);

      default:
        return cozeApiClient.sendMessage(query, userId);
    }
  }

  /**
   * 判断是否为复杂医疗查询
   */
  private isComplexMedicalQuery(query: string): boolean {
    const complexKeywords = [
      '专科', '专家会诊', '手术方案', '详细诊断',
      '眼科', '康复', '神经科', '心血管'
    ];

    return complexKeywords.some(keyword => query.includes(keyword));
  }

  /**
   * 格式化风险评估的语音回复
   */
  private formatRiskVoiceResponse(result: any): string {
    const levelMap: Record<string, string> = {
      low: '低风险',
      medium: '中等风险',
      high: '高风险',
      critical: '严重风险'
    };

    let response = `您的综合健康评估结果为${levelMap[result.overallLevel]}。`;

    if (result.hypertensionRisk > 0.6) {
      response += '高血压风险较高，请注意控制盐摄入。';
    }
    if (result.diabetesRisk > 0.6) {
      response += '糖尿病风险较高，建议定期监测血糖。';
    }
    if (result.fallRisk > 0.6) {
      response += '跌倒风险较高，建议改善居家环境。';
    }

    response += '详细报告已在屏幕上显示。';

    return response;
  }

  /**
   * 创建错误响应
   */
  private createErrorResponse(code: string, message: string): AIResponse {
    return {
      success: false,
      voiceResponse: message,
      aiSource: 'error',
      processingTime: 0,
      metadata: { errorCode: code, errorMessage: message }
    };
  }
}

// 导出单例实例
export const aiOrchestrator = AIOrchestrator.getInstance();
